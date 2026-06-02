-- Logic/SourceParse.lua
-- Converte o sourceText cru do Mount Journal em dados estruturados (puro, sem API).
-- Formato observado:
--   |cFFFFD200Vendor: |rNAME|n|cFFFFD200Zone: |rZONE|n|cFFFFD200Cost: |rAMOUNT|Hcurrency:ID|h|TICON:0|t|h...
-- Vendedores de duas faccoes repetem o bloco Vendor/Zone/Cost separados por |n|n.

local ADDON, ns = ...

-- Tokens que o jogo as vezes mostra sem link |H (so numero + icone). Mapeamos pelo
-- caminho do icone (substring, lowercase) -> itemID, para resolver nome + posse.
ns.KNOWN_TOKEN_ICONS = ns.KNOWN_TOKEN_ICONS or {
    ["achievement_bg_kill_on_mount"] = 103533,  -- Vicious Saddle (mounts Vicious de PvP)
}

-- Remove markup inline (hyperlinks, texturas, cor, quebras) mantendo so o texto.
local function inline(v)
    if not v then return "" end
    v = v:gsub("|T.-|t", "")
    v = v:gsub("|H.-|h(.-)|h", "%1")
    v = v:gsub("|c%x%x%x%x%x%x%x%x", ""):gsub("|r", "")
    v = v:gsub("|n", " ")
    v = v:gsub("%s+", " "):gsub("^%s+", ""):gsub("%s+$", "")
    return v
end

-- Extrai os custos de um valor "Cost:". Retorna lista de { amount, ctype, id, icon }.
-- ctype = "currency" | "item" | "gold".
-- Trata: separador de milhar (5,000), moeda/item (|Hcurrency/item:ID|h|Ticon|t|h),
-- e ouro combinado (ex.: "5,000<gold> + 5,000 Apexis").
local function parseCosts(value)
    if not value then return {} end
    value = value:gsub(",", "")        -- remove separador de milhar antes de parsear
    local costs = {}

    -- 1) moeda/item: NUM|Htype:ID|h|Ticon|t|h  (consome do texto)
    local rest = value:gsub("(%d+)|H(%a+):(%d+)|h|T(.-):%d+|t|h", function(amount, ctype, id, icon)
        costs[#costs + 1] = { amount = tonumber(amount), ctype = ctype, id = tonumber(id), icon = icon }
        return ""
    end)

    -- 2) NUM|Ticon|t (sem |H). Ouro SO se o icone for de dinheiro; alguns tokens
    --    conhecidos (sem link p/ o ID) sao mapeados pelo icone -> item (nome + have);
    --    o resto vira "token" opaco (so o icone).
    for amount, icon in rest:gmatch("(%d+)|T(.-):%d+|t") do
        local low = icon:lower()
        if low:find("moneyframe", 1, true) or low:find("goldicon", 1, true) then
            costs[#costs + 1] = { amount = tonumber(amount), ctype = "gold", icon = icon }
        else
            local known
            for pat, id in pairs(ns.KNOWN_TOKEN_ICONS) do
                if low:find(pat, 1, true) then known = id break end
            end
            costs[#costs + 1] = {
                amount = tonumber(amount),
                ctype  = known and "item" or "token",
                id     = known,
                icon   = icon,
            }
        end
    end

    -- 3) fallback: numero solto sem icone
    if #costs == 0 then
        local g = value:match("%d+")
        if g then costs[#costs + 1] = { amount = tonumber(g), ctype = "gold" } end
    end
    return costs
end

-- Detecta a faccao a partir do nome do vendedor: "Aldraan (Alliance)" -> "Alliance".
local function detectFaction(who)
    return who:match("%((Alliance)%)") or who:match("%((Horde)%)")
end

-- Parseia o sourceText em uma lista de "fontes". Cada fonte:
--   { kind = "Vendor"/"Quest"/"Faction"/"Drop"/..., who, faction, zone, renown, costs={...} }
function ns.SourceParse(raw)
    if not raw or raw == "" then return {} end
    -- Marca cada rotulo com \1 para separar os segmentos.
    local s = raw:gsub("|c[Ff][Ff]%x%x%x%x%x%x", "\1")
    local sources, cur = {}, nil

    for label, value in s:gmatch("\1%s*(.-):%s*|r([^\1]*)") do
        if label == "Vendor" or label == "Quest" or label == "Drop"
            or label == "Faction" or label == "Profession" or label == "Achievement"
            or label == "World Quest" then
            local who = inline(value)
            cur = { kind = label, who = who:gsub("%s*%(%a+%)%s*", ""), faction = detectFaction(who) }
            sources[#sources + 1] = cur
        elseif label == "Zone" or label == "Location" then
            if not cur then cur = { kind = "Source" }; sources[#sources + 1] = cur end
            cur.zone = inline(value)
        elseif label == "Cost" then
            if cur then cur.costs = parseCosts(value) end
        elseif label == "Renown" then
            if cur then cur.renown = inline(value) end
        else
            if cur then cur[label] = inline(value) end
        end
    end

    return sources
end
