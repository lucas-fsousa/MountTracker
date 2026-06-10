-- Core/Events.lua
-- Registra eventos do jogo e os slash commands. Carregado por ultimo.

local ADDON, ns = ...

local f = CreateFrame("Frame")
f:RegisterEvent("PLAYER_LOGIN")
f:RegisterEvent("NEW_MOUNT_ADDED")
f:RegisterEvent("CURRENCY_DISPLAY_UPDATE")
f:RegisterEvent("UPDATE_FACTION")
f:RegisterEvent("ZONE_CHANGED_NEW_AREA")
f:RegisterEvent("PLAYER_ENTERING_WORLD")   -- transicoes de dungeon/raid
f:RegisterEvent("CHAT_MSG_ADDON")          -- checagem de versao entre pares
f:RegisterEvent("GROUP_ROSTER_UPDATE")

-- Marca o roadmap como "sujo"; recalcula na proxima abertura/refresh.
local dirty = true
local function markDirty() dirty = true end

local function rebuildIfNeeded()
    if dirty then
        ns.Logic.Roadmap.Build()
        dirty = false
    end
    if ns.UI and ns.UI.Refresh then ns.UI.Refresh() end
end

-- Handler blindado: qualquer erro nosso vira msg no chat, nunca no meio da tela.
local function handleEvent(_, event, arg1, arg2)
    if event == "PLAYER_LOGIN" then
        ns.DB.Init()
        ns.Logic.Roadmap.Build()
        if ns.UI.Minimap then ns.UI.Minimap.Init() end
        if ns.Version then ns.Version.Init() end
        dirty = false
        local s = ns._stats or {}
        ns.Print(("v%s loaded  ·  WoW %s  ·  %d obtainable mounts. Type |cffffff00/mtrack|r to open.")
            :format((ns.Version and ns.Version.current) or ns.VERSION or "?",
                    (ns.Version and ns.Version.GameString()) or "?", s.pending or 0))
        -- Anuncia a versao apos o roster carregar (checagem de update entre pares).
        if ns.Version and C_Timer then
            C_Timer.After(5, function() ns.Safe.Call("broadcast version", ns.Version.Broadcast) end)
        end

    elseif event == "CHAT_MSG_ADDON" then
        if ns.Version then ns.Version.OnAddonMessage(arg1, arg2) end

    elseif event == "GROUP_ROSTER_UPDATE" then
        if ns.Version then ns.Version.Broadcast() end

    elseif event == "ZONE_CHANGED_NEW_AREA" or event == "PLAYER_ENTERING_WORLD" then
        -- Mudou de zona/instancia: o roadmap nao muda, so o filtro "Current zone".
        if MountTrackerFrame and MountTrackerFrame:IsShown()
            and (ns.DB.Settings().zoneFilter or "All") == "Current" then
            ns.UI.Refresh()
        end
    else
        -- Coleta nova montaria, mudou ouro/currency ou reputacao -> recalcular.
        markDirty()
        -- Se a janela estiver aberta, atualiza ao vivo.
        if MountTrackerFrame and MountTrackerFrame:IsShown() then
            rebuildIfNeeded()
        end
    end
end

f:SetScript("OnEvent", function(self, event, ...)
    ns.Safe.Call("process event " .. tostring(event), handleEvent, self, event, ...)
end)

-- ---- Slash commands ----
SLASH_MOUNTTRACKER1 = "/mtrack"
SLASH_MOUNTTRACKER2 = "/mounttracker"
SLASH_MOUNTTRACKER3 = "/mtr"

local function handleSlash(msg)
    msg = (msg or ""):gsub("^%s+", ""):gsub("%s+$", "")
    local cmd, rest = msg:match("^(%S*)%s*(.*)$")
    cmd = (cmd or ""):lower()

    if cmd == "" then
        ns.UI.Toggle()   -- Toggle ja reconstroi o roadmap ao abrir

    elseif cmd == "find" then
        ns.Logic.Scanner.Find(rest)

    elseif cmd == "dump" then
        ns.Logic.Scanner.Dump()

    elseif cmd == "minimap" then
        if ns.UI.Minimap then ns.UI.Minimap.Toggle() end

    elseif cmd == "zone" then
        local cands, matched, examples, playerExp, nmaps = ns.Logic.Roadmap.ZoneDebug()
        ns.Print(("current zone (exp=%s, %s maps) -> [%s]")
            :format(tostring(playerExp), tostring(nmaps), table.concat(cands, "] [")))
        ns.Print(("matches %d missing mount(s)%s"):format(
            matched, #examples > 0 and (": " .. table.concat(examples, ", ")) or ""))

    elseif cmd == "marked" then
        local names = {}
        for mid in pairs(ns.DB.data.markedObtained or {}) do
            local nm = C_MountJournal and C_MountJournal.GetMountInfoByID(mid)
            names[#names + 1] = (nm or "?") .. " (" .. tostring(mid) .. ")"
        end
        ns.Print(("marked as owned (%d): %s"):format(
            #names, #names > 0 and table.concat(names, ", ") or "(none) - use /mtrack reset to clear all"))

    elseif cmd == "check" then
        -- Estado AO VIVO de uma montaria: isCollected (Blizzard) vs marked (nosso DB).
        local q = rest:lower()
        if q == "" then ns.Print("usage: /mtrack check <part of name>") return end
        local found = 0
        for _, mid in ipairs(C_MountJournal.GetMountIDs()) do
            local nm = C_MountJournal.GetMountInfoByID(mid)
            if nm and nm:lower():find(q, 1, true) then
                local _, sp, _, _, _, srcType, _, _, _, _, isColl = C_MountJournal.GetMountInfoByID(mid)
                local _, _, srcText = C_MountJournal.GetMountInfoExtraByID(mid)
                local label = ns.NativeSourceLabel and ns.NativeSourceLabel(srcType)
                -- Escapa as barras p/ o texto cru aparecer legivel no chat.
                local rawSafe = ns.Safe.IsSecret(srcText) and "<secret>"
                    or (tostring(srcText or ""):gsub("|", "||"))
                ns.Print(("%s (id %d, spell %s): isCollected=%s | marked=%s | hidden=%s")
                    :format(nm, mid, tostring(sp), tostring(isColl),
                        tostring(ns.DB.IsMarkedObtained(mid)), tostring(ns.DB.IsHidden(mid))))
                ns.Print(("  sourceType=%s (%s) | sourceText=[%s]")
                    :format(tostring(srcType), tostring(label), rawSafe))
                -- Status calculado + faction curada (procura no roadmap ja construido).
                for _, it in ipairs(ns._roadmap or {}) do
                    if it.mountID == mid then
                        ns.Print(("  status=%s | readyNow=%s | category=%s | expansion=%s | map=%s")
                            :format(tostring(it.status), tostring(it.readyNow),
                                tostring(it.category), tostring(it.expansion),
                                tostring(it.entry and it.entry.map)))
                        ns.Print("  filter -> " .. tostring(ns.Logic.Roadmap.WhyHidden(it)))
                        break
                    end
                end
                found = found + 1
                if found >= 8 then break end
            end
        end
        if found == 0 then ns.Print("no mount matching '" .. q .. "'") end

    elseif cmd == "hidden" then
        -- Lista as montarias ocultadas manualmente (status HIDDEN).
        local names = {}
        for mid in pairs(ns.DB.data.hidden or {}) do
            local nm = C_MountJournal and C_MountJournal.GetMountInfoByID(mid)
            names[#names + 1] = (nm or "?") .. " (" .. tostring(mid) .. ")"
        end
        ns.Print(("manually hidden (%d): %s"):format(
            #names, #names > 0 and table.concat(names, ", ")
                or "(none) — use the Hide button to hide a mount"))

    elseif cmd == "unhide" then
        -- Desfaz o "hide" de UMA montaria pelo nome (sem apagar o resto, como o reset).
        local q = rest:lower()
        if q == "" then ns.Print("usage: /mtrack unhide <part of name>") return end
        local n = 0
        for mid in pairs(ns.DB.data.hidden or {}) do
            local nm = C_MountJournal and C_MountJournal.GetMountInfoByID(mid)
            if nm and nm:lower():find(q, 1, true) then
                ns.DB.SetHidden(mid, false)
                ns.Print("unhidden: " .. nm)
                n = n + 1
            end
        end
        if n == 0 then ns.Print("no hidden mount matching '" .. q .. "'") end
        ns.Logic.Roadmap.Build()
        if ns.UI and ns.UI.Refresh then ns.UI.Refresh() end

    elseif cmd == "faction" then
        -- Diagnostico: dump das APIs de reputacao p/ um factionID (ex.: Brawler's Guild
        -- Horde 2766 / Alliance 2767), p/ descobrir como ler o "rank".
        local id = tonumber(rest)
        if not id then ns.Print("usage: /mtrack faction <factionID>") return end
        if C_Reputation and C_Reputation.GetFactionDataByID then
            local d = C_Reputation.GetFactionDataByID(id)
            if d then
                ns.Print(("rep %d: name=%s reaction=%s standing=%s/%s"):format(id,
                    tostring(d.name), tostring(ns.Safe.Value(d.reaction, "?")),
                    tostring(ns.Safe.Value(d.currentStanding, "?")),
                    tostring(ns.Safe.Value(d.currentReactionThreshold, "?"))))
            else ns.Print("  C_Reputation: nil for " .. id) end
        end
        if C_MajorFactions and C_MajorFactions.GetMajorFactionData then
            local m = C_MajorFactions.GetMajorFactionData(id)
            ns.Print(m and ("major %d: name=%s renown=%s"):format(id, tostring(m.name),
                tostring(m.renownLevel)) or ("  C_MajorFactions: nil for " .. id))
        end
        if C_GossipInfo and C_GossipInfo.GetFriendshipReputation then
            local ok, f = pcall(C_GossipInfo.GetFriendshipReputation, id)
            if ok and f and f.friendshipFactionID and f.friendshipFactionID ~= 0 then
                ns.Print(("friendship %d: name=%s rank=%s/%s text=%s"):format(id,
                    tostring(f.name), tostring(f.reaction), tostring(f.maxRank),
                    tostring(f.reactionText)))
            else ns.Print("  C_GossipInfo.GetFriendshipReputation: none for " .. id) end
        end
        if C_GossipInfo and C_GossipInfo.GetFriendshipReputationRanks then
            local ok, r = pcall(C_GossipInfo.GetFriendshipReputationRanks, id)
            if ok and r and r.currentLevel then
                ns.Print(("ranks %d: currentLevel=%s maxLevel=%s"):format(id,
                    tostring(r.currentLevel), tostring(r.maxLevel)))
            else ns.Print("  C_GossipInfo.GetFriendshipReputationRanks: none for " .. id) end
        end

    elseif cmd == "scan" then
        ns.Logic.Roadmap.Build()
        local s = ns._stats or {}
        ns.Print(("scan: %d mounts | %d owned | %d obtainable | %d unavailable | overlay %d/%d")
            :format(s.total or 0, s.owned or 0, s.pending or 0, s.unavailable or 0, s.applied or 0, s.curated or 0))
        if (s.unresolved or 0) > 0 and ns._unresolved then
            ns.Print("  curated not in journal: " .. table.concat(ns._unresolved, ", "))
        end

    elseif cmd == "reset" then
        wipe(MountTrackerDB.markedObtained)
        wipe(MountTrackerDB.hidden)
        ns.Print("overrides (obtained/hidden) cleared.")
        ns.Logic.Roadmap.Build()
        if ns.UI and ns.UI.Refresh then ns.UI.Refresh() end

    elseif cmd == "debug" then
        ns.DEBUG = not ns.DEBUG
        ns.Print("debug " .. (ns.DEBUG and "on" or "off") ..
            (ns._lastError and (" | last error: " .. ns._lastError) or ""))

    elseif cmd == "help" then
        ns.Print("commands: /mtrack (open) | find <name> | check <name> | scan | dump | minimap | zone | marked | hidden | unhide <name> | faction <id> | reset | debug | help")

    else
        ns.Print("unknown command. /mtrack help")
    end
end

-- Hardened slash: an error here becomes a chat message, never a mid-screen error.
SlashCmdList["MOUNTTRACKER"] = function(msg)
    ns.Safe.Call("run command", handleSlash, msg)
end
