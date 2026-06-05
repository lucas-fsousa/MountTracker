-- Core/Waypoint.lua
-- Define um waypoint para o vendedor de uma montaria. Usa o waypoint NATIVO do
-- Blizzard (seta na tela + pin no mapa, sem dependencia) e, se o TomTom estiver
-- instalado, tambem cria um waypoint nele. Tudo protegido (nunca quebra a tela).

local ADDON, ns = ...

ns.Waypoint = ns.Waypoint or {}

-- map = uiMapID; x, y em 0-100 (como o jogo mostra). title = texto opcional.
-- Retorna true se conseguiu setar em pelo menos um sistema.
function ns.Waypoint.Set(map, x, y, title)
    if not (map and x and y) then return false end
    local fx, fy = x / 100, y / 100
    local done = false

    -- Waypoint nativo (Blizzard): so em mapas que aceitam (zonas/cidades/dungeons).
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

    -- TomTom (opcional): cria a seta/linha do TomTom se ele estiver carregado.
    if TomTom and TomTom.AddWaypoint then
        ns.Safe.Call("set TomTom waypoint", function()
            TomTom:AddWaypoint(map, fx, fy, {
                title = title or "MountTracker",
                from = "MountTracker",
                persistent = false,
                crazy = true,
            })
            done = true
        end)
    end

    return done
end

-- Conveniencia: seta o waypoint a partir de um item do roadmap (usa entry.coords).
-- Retorna true/false; tambem da um feedback no chat.
function ns.Waypoint.ToItem(item)
    local e = item and item.entry
    local co = e and e.coords
    if not (co and co.map and co.x and co.y) then return false end
    local label = (e.vendor and (e.vendor .. (e.zone and (" — " .. e.zone) or "")))
        or item.name or "vendor"
    local ok = ns.Waypoint.Set(co.map, co.x, co.y, item.name)
    if ok then
        ns.Print(("waypoint set: |cffffff00%s|r (%.1f, %.1f)"):format(label, co.x, co.y))
    else
        ns.Print("couldn't set a waypoint for this map.")
    end
    return ok
end
