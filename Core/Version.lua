-- Core/Version.lua
-- Versao do addon (lida do .toc), versao do jogo e checagem de update entre pares.
-- Sem acesso a web in-game: os jogadores trocam a versao via mensagem de addon no
-- guild/grupo; se alguem anuncia uma versao maior, avisamos o jogador (uma vez).

local ADDON, ns = ...

local V = {}
ns.Version = V

local PREFIX = "MountTrackerVer"
local notified, newestSeen = false, nil

-- Versao do addon: do metadata do .toc (fonte unica), com fallbacks.
V.current = (C_AddOns and C_AddOns.GetAddOnMetadata and C_AddOns.GetAddOnMetadata(ADDON, "Version"))
    or (GetAddOnMetadata and GetAddOnMetadata(ADDON, "Version"))
    or ns.VERSION or "?"
ns.VERSION = V.current

-- Versao do jogo: "12.0.5 (120005)".
function V.GameString()
    local version, _, _, tocversion = GetBuildInfo()
    return ("%s (%s)"):format(version or "?", tostring(tocversion or "?"))
end

-- Compara "1.2.3" numericamente. Retorna true se `a` > `b`.
local function parse(v)
    local t = {}
    for n in tostring(v):gmatch("%d+") do t[#t + 1] = tonumber(n) end
    return t
end
function V.IsNewer(a, b)
    local pa, pb = parse(a), parse(b)
    for i = 1, math.max(#pa, #pb) do
        local x, y = pa[i] or 0, pb[i] or 0
        if x ~= y then return x > y end
    end
    return false
end

function V.Init()
    if C_ChatInfo and C_ChatInfo.RegisterAddonMessagePrefix then
        C_ChatInfo.RegisterAddonMessagePrefix(PREFIX)
    end
end

-- Anuncia a nossa versao p/ guild e grupo (quem ouvir compara com a sua).
function V.Broadcast()
    if not (C_ChatInfo and C_ChatInfo.SendAddonMessage) then return end
    local msg = "V:" .. V.current
    if IsInGuild and IsInGuild() then
        C_ChatInfo.SendAddonMessage(PREFIX, msg, "GUILD")
    end
    local ch = (IsInRaid and IsInRaid() and "RAID")
        or (IsInGroup and IsInGroup() and "PARTY") or nil
    if ch then C_ChatInfo.SendAddonMessage(PREFIX, msg, ch) end
end

-- Recebe a versao de outro jogador; avisa (uma vez) se for mais nova que a nossa.
function V.OnAddonMessage(prefix, message)
    if prefix ~= PREFIX or not message then return end
    local remote = message:match("^V:(.+)$")
    if not (remote and V.IsNewer(remote, V.current)) then return end
    if not newestSeen or V.IsNewer(remote, newestSeen) then newestSeen = remote end
    if not notified then
        notified = true
        ns.Print(("|cffffcc00update available: v%s (you have v%s).|r"):format(remote, V.current))
    end
end
