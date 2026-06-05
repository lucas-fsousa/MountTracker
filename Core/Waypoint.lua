-- Core/Waypoint.lua
-- Define um waypoint para o vendedor de uma montaria. Usa o waypoint NATIVO do
-- Blizzard (seta na tela + pin no mapa, sem dependencia) e, se o TomTom estiver
-- instalado, tambem cria um waypoint nele. Tudo protegido (nunca quebra a tela).

local ADDON, ns = ...

ns.Waypoint = ns.Waypoint or {}

-- Indice nome-da-zona -> uiMapID, construido sob demanda (1x) varrendo os mapas do
-- jogo. Necessario quando a coordenada curada so tem a ZONA (sem uiMapID) -- ex.:
-- vendedores de conteudo antigo, cujo Wowhead nao expoe o uiMapId.
local zoneIndex
local function buildZoneIndex()
    zoneIndex = {}
    if not (C_Map and C_Map.GetMapInfo) then return end
    for id = 1, 2700 do
        local info = C_Map.GetMapInfo(id)
        if info and info.name and info.name ~= "" and info.mapType then
            local key = info.name:lower()
            local cur = zoneIndex[key]
            -- Zona (mapType 3) tem prioridade sobre dungeon/micro com mesmo nome.
            if not cur or (info.mapType == 3 and cur.mapType ~= 3) then
                zoneIndex[key] = { id = id, mapType = info.mapType }
            end
        end
    end
end

function ns.Waypoint.MapForZone(name)
    if not name then return nil end
    if not zoneIndex then ns.Safe.Call("build zone index", buildZoneIndex) end
    local e = zoneIndex and zoneIndex[name:lower()]
    return e and e.id
end

-- map = uiMapID; x, y em 0-100 (como o jogo mostra). title = texto opcional.
-- Retorna true se conseguiu setar em pelo menos um sistema.
function ns.Waypoint.Set(map, x, y, title)
    if not (map and x and y) then return false end
    local fx, fy = x / 100, y / 100
    local done = false

    if C_Map and C_Map.SetUserWaypoint and UiMapPoint and UiMapPoint.CreateFromCoordinates then
        ns.Safe.Call("set native waypoint", function()
            local canSet = not C_Map.CanSetUserWaypointOnMap
                or C_Map.CanSetUserWaypointOnMap(map)
            if canSet then
                C_Map.SetUserWaypoint(UiMapPoint.CreateFromCoordinates(map, fx, fy))
                if C_SuperTrack and C_SuperTrack.SetSuperTrackedUserWaypoint then
                    C_SuperTrack.SetSuperTrackedUserWaypoint(true)
                end
                done = true
            end
        end)
    end

    if TomTom and TomTom.AddWaypoint then
        ns.Safe.Call("set TomTom waypoint", function()
            TomTom:AddWaypoint(map, fx, fy, {
                title = title or "MountTracker", from = "MountTracker",
                persistent = false, crazy = true,
            })
            done = true
        end)
    end

    return done
end

-- Conveniencia: seta o waypoint a partir de um item do roadmap. A coord curada e
-- `{ map=uiMapID, x, y }` OU `{ zone="Nome", x, y }` (uiMapID resolvido pela zona).
function ns.Waypoint.ToItem(item)
    local e = item and item.entry
    local co = e and e.coords
    if not (co and co.x and co.y) then return false end
    local map = co.map or ns.Waypoint.MapForZone(co.zone)
    if not map then
        ns.Print("couldn't resolve the map for this vendor's zone (" ..
            tostring(co.zone or "?") .. ").")
        return false
    end
    local label = (e.vendor and (e.vendor .. (e.zone and (" — " .. e.zone) or "")))
        or item.name or "vendor"
    local ok = ns.Waypoint.Set(map, co.x, co.y, item.name)
    if ok then
        ns.Print(("waypoint set: |cffffff00%s|r (%.1f, %.1f)"):format(label, co.x, co.y))
    else
        ns.Print("couldn't set a waypoint for this map.")
    end
    return ok
end

-- A montaria pode receber waypoint? Tem coord com uiMapID, OU uma zona que o jogo
-- consegue resolver para um uiMapID (zonas compostas/sub-areas que nao resolvem nao
-- mostram o botao, evitando um "Way" que nao funcionaria).
function ns.Waypoint.CanRoute(item)
    local e = item and item.entry
    local co = e and e.coords
    if not (co and co.x and co.y) then return false end
    if co.map then return true end
    return (co.zone and ns.Waypoint.MapForZone(co.zone) ~= nil) or false
end
