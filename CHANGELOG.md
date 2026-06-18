# Changelog

All notable changes to **MountTracker** are documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and the project adheres to [Semantic Versioning](https://semver.org/).

<!--
HOW TO RELEASE (see RELEASING.md):
  1. Move the items below from [Unreleased] into a new "## [X.Y.Z] - YYYY-MM-DD" section.
  2. Bump "## Version:" in MountTracker.toc to X.Y.Z.
  3. Commit, then: git tag vX.Y.Z && git push --tags
     -> the Release workflow builds the .zip and publishes a GitHub Release.
-->

## [Unreleased]

### Added
- **Curated *Tortured Gorger*** (new Midnight patch mount): vendor Kifaan in Naigtal, 15×
  Voidlight Marl, gated by the *Heroic Showdowns* achievement — so it glows only when you've
  earned the achievement and can afford it.

## [0.12.0] - 2026-06-18

### Changed
- **Expansion coverage is now 100%** (0 "Unknown" across all 1623 journal mounts): the last
  class/racial/legacy mounts with no readable Wowhead item (Warhorse, Dreadsteed, Thalassian,
  Acherus Deathcharger, PvP "Vicious", …) were resolved — most from Wowhead's authoritative
  data, the rest curated by hand.
- **Midnight spell-ID threshold reviewed.** TWW and Midnight spell IDs overlap, so the
  heuristic that promotes a reused-zone mount to Midnight was over-reaching (it could mislabel
  late-TWW mounts). It's now pinned just above TWW's highest mount spell ID, and the affected
  mounts get their *real* expansion harvested from Wowhead instead of a guess. Expansion is
  also derived from a mount's curated zone when the overlay has the zone but no expansion.
- **Location coverage greatly expanded** (~180 more "Current zone" assignments). A journal-wide
  sweep of Drop/Quest/Vendor mounts resolved most from the game's own source text (`Zone:`),
  the rest via the source NPC/object/item, the item's Location, or a curated source→zone map;
  plus racial "Legacy" mounts mapped to their race's capital (Wolf→Orgrimmar, Ram→Ironforge,
  Kodo→Thunder Bluff, Saber→Darnassus, …). Achievement/Profession/Promotion/TCG/Store mounts
  are account-wide and have no zone by design, so they stay out of the current-zone filter.

## [0.11.0] - 2026-06-15

### Added
- **Location curated for ~70 more drop/reward mounts.** A journal-wide sweep resolved the
  "Current zone" of mounts whose source had no mappable NPC — via the source's NPC/object/item
  page, the item's "Location", the source name when it's itself a zone (e.g. *X Rare
  Creatures* → X), and a curated source→zone map for reputation caches/eggs/troves that carry
  no location on Wowhead (Undermine troves → Undermine, Necroray Egg → Maldraxxus, Nightfallen
  Cache → Suramar, Cracked Egg → Sholazar Basin, …). Added to `Mounts_ManualMeta.lua`.
  Missing-location dropped 115 → 42; the rest are inherently zone-less (Island Expeditions,
  holiday bags, world drops) or unreleased-Midnight sources Wowhead doesn't map yet.
- **Manual overlay can mark a mount *unobtainable*.** `Data/Mounts_ManualMeta.lua` entries
  may carry `unavailable = true` (with an optional `note`), and the addon then shows the mount
  as *Unavailable* instead of letting it look obtainable — for legacy mounts the game itself
  doesn't flag. First case: the **Black Qiraji Battle Tank** (one-time Gates of Ahn'Qiraj
  event reward; 3 spell IDs, all flagged). The four colored Qiraji Battle Tanks (Blue/Red/
  Yellow/Green) got their zone (Temple of Ahn'Qiraj) — they remain obtainable.
- **"Current zone" location harvested from the item page too.** For drop/world-drop mounts
  whose vendor/NPC has no mappable coordinates, the harvester now reads the *teaching item's*
  "Location" (e.g. *The Big G* → Liberation of Undermine). Only works when the mount's item is
  discoverable from the spell page or its name; items with an unrelated name (e.g. Qiraji
  Battle Tank → "Qiraji Resonating Crystal") still need manual curation.
- **Faction-specific reputation requirements.** A requirement's `factionID` may now be a
  `{ Horde = …, Alliance = … }` table, resolved to the player's faction at check time (same
  pattern the Brawler's Guild already used). Lets cross-faction vendor mounts gate correctly
  for both sides — *Drake of the West Wind* (Tol Barad: Hellscream's Reach / Baradin's
  Wardens) and the Nazjatar mounts (The Unshackled / Waveblade Ankoan) now use it.

### Fixed
- **Requirement harvesting now uses only *authoritative* Wowhead data — never comments.** The
  parser was matching reputation/renown text anywhere on the page, including the user-comment
  section, which produced **wrong gates** (e.g. three Undermine mounts were curated as "Renown
  with the Cartels of Undermine" when they actually need *Exalted with a specific cartel*, and
  one needs no gate at all). It now reads the item's structured requirement (`reqfaction`/
  `reqrep`) for reputation and the item *tooltip* for renown (resolving the faction by name),
  so a comment can never become a false gate.
- **Swept every vendor mount for hidden gates and corrected the base.** With the fixed parser,
  found and added 11 missing reputation gates (Bloodfang Widow, Crimson Tidestallion, Inkscale
  Deepseeker, Palehide Direhorn, Ravenous Black Gryphon, Dark War Talbuk, Champion's Treadblade,
  the Undermine cartel mounts, …) so they no longer false-glow when you have the currency but
  not the standing; and fixed three mislabeled Undermine gates (Crimson Armored Growler →
  Bilgewater, Ochre Delivery Rocket → Venture Company; Innovation Investigator → no gate).
- **No false glow on *Radiant Imperial Lynx*.** It was curated as a plain currency purchase,
  but it also needs **Renown 9 with Flame's Radiance** — a gate the game's source text never
  shows. Added the renown requirement (harvested from Wowhead), so it stays *Need requirement*
  until you reach it. Also made the requirement parser tolerant of Wowhead's markup
  (`Renown [b]Rank 9[/b] with …`) and of the dots in the faction link URL, which had stopped
  these gates from being detected.
- **Corrected *Delver's Gob-Trotter* source.** The game's journal labels it a *World Quest*,
  but it's bought from **Reno Jackson** in Dornogal for 10,000 Resonance Crystals. Curated as
  a vendor mount so it shows the seller, location and currency (and a waypoint) instead of
  "World Quest".

### Changed
- **Metadata overlay now covers the *whole game*, not just what you're missing.** The
  harvest used to read only your *obtainable-now* mounts, so anything you'd already collected
  (or can't get on this character) never got a map/expansion — wrong for *other* players who
  still need it. A new `tools/dump_journal.lua` feeds the full Mount Journal (collected +
  hidden + missing) into the harvester, so the Expansion/Current-zone filters are correct for
  everyone. Coverage across all 1607 journal mounts: missing-expansion **509→20**,
  missing-location **577→128** (1004 overlay entries).
- **Expansion is now read from Wowhead's "Added in patch X.Y.Z" too.** Many old/promo/TCG
  mounts have no "World of Warcraft: <expansion>" meta tag, so they fell through as Unknown.
  Wowhead records the introduction patch for every database item, so the harvester reads it
  from the *teaching item* (the item that grants the mount) and maps its major version to the
  expansion. Because that item rarely shares the mount's name, it's matched by **exact
  name-template** (`<mount> Bridle`, `Reins of the <mount>`, `<mount>'s Reins`, `Horn of the
  <mount>`, `<mount> Egg`, …) — exact-only, so it never grabs an unrelated item and mislabels
  the expansion. Cut the Unknown bucket from 179 to **20**. The last 20 are class mounts with
  no item (Felsteed, paladin Warhorse, …) and a few old racials/holiday mounts whose item
  name fits no template — all old Classic content.
- **Classic-reputation fallback for expansion.** When neither the expansion meta nor an
  introduction patch is available, a mount bought with a vanilla reputation (Orgrimmar,
  Stormwind, Wintersaber Trainers, Brood of Nozdormu, … — the Classic faction set) is now
  classified as Classic.
- **Expansion is also read from the *teaching item linked on the spell page*.** Some mounts'
  spell pages don't carry a patch but link the item that grants them (e.g. *Headless
  Horseman's Mount* → *The Horseman's Reins*), alongside unrelated items. The harvester now
  follows those links, keeps only the actual mount item (tooltip "summon this mount"), and
  reads its introduction patch — pulling a few more mounts out of Unknown. Combined with the
  manual overlay, the Unknown bucket is down to **10** (all class mounts with no item and a
  couple of irregular-item racials).

## [0.10.0] - 2026-06-11

### Added
- **Hand-curated metadata overlay (`Data/Mounts_ManualMeta.lua`) with a `manualUpdate` flag.**
  A few mounts can't be resolved safely from Wowhead — racials the game reports only as
  "Legacy", with no patch on the spell page and an irregular/absent item (Winter Wolf,
  Felsteed, Skeletal Horse, Tiger, Black Qiraji Battle Tank, …). These get expansion/zone by
  hand. Every entry carries `manualUpdate = true`, which the harvest scripts (`enrich_meta`,
  `enrich_requirement`) **skip entirely** — they're never regenerated or overwritten.
- **"Current zone" and the filters now cover *uncurated* mounts too.** A metadata overlay
  (`Data/Mounts_Meta.lua`, harvested from Wowhead and keyed by spell ID) gives every mount
  a strict obtain **map** and **expansion** — even the ones that aren't in the curated
  eligibility table. The Expansion/Category/Current-zone filters no longer leave those
  mounts behind. Generated by `tools/enrich_meta.py`; doesn't touch eligibility or the glow.
- **Garrison mounts now show under "Only current zone."** Standing in your Garrison is
  detected via `C_Garrison.IsOnGarrisonMap()`, so its mounts match the current-zone filter.
- **Friendship-rank gates are verified, not guessed.** Mounts gated by a Brawler's Guild
  rank or an Archivists' Codex tier are checked live via the friendship-reputation API
  (`C_GossipInfo.GetFriendshipReputationRanks`) — they glow only when you actually hold the
  required rank.

### Fixed
- **"Current zone" no longer hides mounts obtained in revamped old zones.** A recent mount
  sold in an old-world venue (e.g. *Brawlin' Bruno* / *Ballistic Bronco* at the Brawl'gar
  Arena, which the game places in Classic Orgrimmar) was wrongly filtered out because its
  expansion didn't match the zone's. The name-fallback no longer gates on expansion at all
  — same-name cross-expansion collisions (Nagrand TBC vs WoD, …) are already handled by the
  strict map-ID match, so the expansion check only caused false negatives.
- **No more false "obtainable now" glow on gated vendor mounts.** Mounts behind a gate the
  addon can't verify — Brawler's Guild rank, or any `Faction:`/`Rank` requirement the game
  shows but we haven't curated — were treated as a plain gold purchase and lit up green
  (e.g. *Brawler's Burly Mushan Beast*, *Brawlin' Bruno*). They now show *Need requirement*
  ("verify in-game") instead of glowing, detected systemically: an unresolved faction/rank
  line in the source text, or a vendor in a Brawler's Guild venue (Brawl'gar Arena /
  Bizmo's Brawlpub).
- **No more false glow on vendor mounts gated by a *hidden* reputation.** Some vendors
  require a standing the game never prints in the source text (a hidden rep), so the mount
  was curated as a plain purchase and lit up green even when locked — e.g. *Ivory
  Hawkstrider* needs **Exalted with Talon's Vengeance**. These gates are now harvested from
  the Wowhead tooltip (`tools/enrich_requirement.py`) and verified in-game, so they show
  *Need requirement* until met. Caught 4 mounts (1 reputation + 3 renown).
- **No more false glow on *Preyseeker's Wrath*.** It requires *Preyseeker's Journey rank 10*
  — a progression tracked by a **currency** (3387), not a faction, and shown only in the
  tooltip text. Added a `currency`-type requirement that reads the live rank via
  `C_CurrencyInfo`, so the mount stays *Need requirement* until you reach rank 10.

## [0.9.0] - 2026-06-10

### Added
- **Filter by category.** A new *Category* dropdown (next to *Expansion* on the top row)
  narrows the roadmap to how a mount is obtained — Vendor, Reputation, Drop, Achievement,
  and the source types of uncurated mounts (Quest, PvP, Profession, Holiday, Treasure, …).
  The list is built from whatever's actually in your roadmap.

### Changed
- **Current-zone filter is now an "Only current zone" checkbox** (next to *Show owned*),
  replacing the zone dropdown — quicker to toggle and frees the top row for Expansion +
  Category.

### Fixed
- **"Current zone" now matches by map ID, not zone name — no more wrong-expansion mixups.**
  Zones reused across expansions share a name (Nagrand TBC vs WoD, Shadowmoon Valley,
  Dalaran…), which made the filter show the wrong one (e.g. the TBC *Dark Riding Talbuk*
  while you stood in WoD Nagrand). Each curated mount now carries a strict **`map`
  (uiMapID)** for its obtain zone — harvested from Wowhead — and the filter compares
  unique IDs, which can't collide. Mounts without a map fall back to name matching, now
  also gated by your current expansion (derived from the continent). This is data-driven:
  no per-mount fixes, it just resolves itself from the harvested IDs.
- **Garrison mounts now show under "Current zone".** Your garrison's zone name
  (Lunarfall/Frostwall/…) didn't match the curated `Garrison: …` source, so they never
  appeared; the filter now recognises when you're on your garrison map.
- **More reliable expansion tagging.** 30 curated drops in reused/ambiguous zones that the
  heuristic couldn't place (Arathi/Darkshore Warfronts, Island Expeditions, Tazavesh, …)
  now carry an explicit expansion harvested from Wowhead, so the expansion filter and the
  current-zone disambiguation are accurate for them too.

## [0.8.0] - 2026-06-07

### Added
- **Detail panel with a 3D model preview.** Clicking a mount opens a panel docked to the
  roadmap with a rotating 3D model, its source/zone/cost and current standing, and roomy
  action buttons. It moves and closes with the roadmap (and flips to the other side when
  there's no room). This declutters the list — rows are now clean and click-to-open
  (just a `›` hint on hover).
- **Waypoint to the vendor.** Vendor mounts get a **Set waypoint to vendor** button that
  drops a map waypoint at the seller — the native Blizzard arrow/pin (no dependency) plus
  a TomTom waypoint if you have it installed. Coordinates are harvested from Wowhead: when
  a map ID is exposed we use it directly, otherwise we store the zone name and resolve the
  map at runtime. The button only appears when a route can actually be made.
  (`Core/Waypoint.lua`)
- **`/mtrack unhide <name>` and `/mtrack hidden`.** Undo an accidental *Hide* on a single
  mount without wiping all your overrides, and list everything you've hidden. `/mtrack
  check` now also reports a mount's `hidden` flag and computed status.

### Fixed
- **Opposite-faction mounts no longer show as obtainable.** Some account-wide mounts are
  gated by a faction-specific *acquisition* (e.g. *Ankoan Waveray* needs Ankoan reputation,
  which only Alliance can earn) — the game doesn't flag the mount itself, so a Horde
  character saw it as just "need requirement." Curated entries now carry a `faction` tag
  (from Wowhead's faction side); wrong-faction ones are hidden unless *Show unavailable /
  hidden* is on.

## [0.7.0] - 2026-06-03

### Added
- **Each row now shows your current standing toward the mount.** A fourth, colour-coded
  line spells out exactly what's missing and where you are — e.g. a renown mount reads
  `Hara'ti: Renown 8 / 14` (faction name + current/required) instead of a bare
  *"Need Requirement"* badge. Works for reputation (current vs required standing),
  renown, achievements, and currency costs. Rows are a bit taller to fit it.
- **74 vendor mounts curated in one automated pass** (`Data/Mounts_Vendors.lua`,
  generated by `tools/curate_vendors.py`). Cost comes from the game's own source text
  when present, otherwise from the Wowhead "sold by" data (each cost id resolved as
  currency or item), plus faction ID and expansion. Mounts whose cost can't be
  determined with confidence are skipped rather than guessed (a free class-hall mount
  curated with "no cost" would falsely glow as buyable). This makes the "obtainable
  now" glow work for real vendor mounts (e.g. Darkmoon, Vicious PvP, Time Rift).
- **71 achievement-reward mounts curated in one automated pass** (`Data/Mounts_Achievements.lua`,
  generated by `tools/curate_achievements.py`). Each had its achievement requirement
  unverifiable (the game only names the achievement) — now resolved against Wowhead
  (achievement ID + expansion via the "World of Warcraft: <expansion>" page metadata),
  so they evaluate, show progress, and disappear once earned. New reusable extractors:
  `wowhead.achievement_id`/`spell_html` + `extract.expansion`, and `tools/dump_curated.lua`
  for idempotent regeneration.
- **Mount data audit tooling** (`tools/audit.lua` + `tools/audit_report.py`): reuses
  the addon's own parsing over a `/mtrack dump` to list every obtainable mount with
  incomplete data (missing zone/cost/expansion, or an unverifiable requirement gate),
  grouped by tier and expansion — so gaps get fixed in batches instead of one-by-one.
- **Expansion heuristic** learned more raid/dungeon zones (Nerub-ar Palace, Manaforge
  Omega, Darkflame Cleft, Necrotic Wake, Sepulcher, Ny'alotha, Freehold, Underrot,
  Chamber of Heart, Horrific Visions, Nighthold, Tyrhold/Time Rifts), correctly filing
  ~13 more mounts that were showing as *Unknown* expansion.
- **Curated *Unbound Manawyrm*** (Midnight, Sergeant Vornin in Silvermoon City). It's
  gated by the *Void Response Team* achievement, which the game only exposes by name
  (no checkable ID) in the source text — so an uncurated copy never lit up the
  "obtainable now" glow even with the achievement done. Curated with the achievement
  ID (62563) + cost (200 Field Accolade), so it now evaluates and glows correctly.
- **Zones for boss/rare drops.** Several drop mounts had no location, so the roadmap
  showed the drop odds but not *where*. Where the source is an NPC/boss (e.g. *Shackled
  Ur'zul* → Antorus, *Brewfest Bomber* → Blackrock Depths) or a `"<Zone> Rare Creatures"`
  source (e.g. *Cerulean Hawkstrider* → Eversong Woods), the zone is now filled in and
  shown / usable by the **Current zone** filter. (Faction reward caches, holiday chests
  and egg-style item sources genuinely have no single zone, so those keep showing just
  the source.) New tooling: `tools/enrich_zones.py` + Wowhead NPC/zone extraction in
  `mtcurate`.

### Fixed
- **Treasure-chest mounts (and other unusual sources) now read correctly.** The source
  parser only understood a fixed set of labels (Vendor/Drop/Quest/…), so a
  `Treasure: <object>` source (e.g. *Hexed Vilefeather Eagle* in Zul'Aman) showed a
  bare `?`. It now treats **any** non-attribute label as a real source, so the line
  reads `Treasure: Abandoned Ritual Skull`. *Treasure* is also its own category, and
  mounts whose text doesn't classify fall back to the game's native source *type*
  (Drop / Vendor / Quest / …) instead of a generic *Other*.
- `/mtrack check <name>` now also prints the mount's raw `sourceType`/`sourceText`
  (a diagnostic aid).
- **World drops in revamped zones no longer vanish under the Midnight filter.** A
  curated drop whose origin lived only in its `source`/`zone` field (e.g. a mount
  from *Eversong Woods Rare Creatures* in the Midnight version of the map) was
  classified from the live source text alone — which often omits the zone — so it
  fell into *Unknown* and was filtered out of both **Midnight** and **Current zone**.
  The curated source/zone now feeds the expansion check, the spell-ID override also
  promotes *Unknown* (not just old buckets) to Midnight, and the zone filter reads
  the curated `source` too.

## [0.6.1] - 2026-06-02

### Changed
- **The source line now always shows the source type.** The second row line is
  labelled with the source kind — `Vendor:`, `Drop:`, `Quest:`, `Faction:`, etc. —
  so a vendor mount reads `Vendor: <name>` instead of just the bare NPC name.
- **Release packaging.** The Release asset is now a version-less `MountTracker.zip`
  (stable URL: `.../releases/latest/download/MountTracker.zip`); the folder inside is
  always `MountTracker`, so manual installs load correctly. Tagging a version can also
  publish to **CurseForge** automatically (via the BigWigs packager) once the repo's
  `CF_API_KEY` secret and `CF_PROJECT_ID` variable are set — see `RELEASING.md`.

## [0.6.0] - 2026-06-02

### Added
- `/mtrack zone` — prints the current-zone names the addon detects and how many
  missing mounts match (diagnostics for the **Current zone** filter).
- `/mtrack marked` — lists the mounts you manually marked as owned.

### Changed
- **"Current zone" now includes the zone's dungeons and raids.** A dungeon is part
  of the zone it sits in, so mounts that drop there (e.g. a Zul'Farrak drop while
  you're standing in Tanaris) now show under the current-zone filter — you no longer
  have to be physically inside the instance. The addon walks down the map tree to
  each zone's child instances, in addition to walking up sub-zones to the parent map.

### Fixed
- **The Midnight expansion now appears in the Expansion filter.** It was missing
  from the dropdown list, so Midnight mounts could never be filtered to (even though
  they were correctly classified).
- **All in-game and tooling messages are now in English** (including developer
  diagnostics), for consistency across the public release.
- **Filters no longer leave the window blank.** The virtualized list rows were
  children of the scroll frame, so its internal scroll offset pushed them out of
  view (rows were "shown" but invisible). Rows are now children of the main frame,
  anchored over the scroll area, with the data offset clamped to the list size and
  a return-to-top on filter changes. (This was the cause behind "Current zone shows
  nothing" / "only appears with Show owned".)
- Mounts from **revamped zones** (e.g. Isle of Quel'Danas) are no longer filed
  under the old expansion's filter — a recent spell ID now overrides the zone
  heuristic (so Midnight content in old zones shows as Midnight).
- **Marking a mount as "Owned" is now reversible.** A manually-marked mount (that
  you don't actually own) shows an **Unmark** button under *Show owned*, so an
  accidental click no longer hides it from the roadmap for good.

## [0.5.0] - 2026-06-02

First public release.

### Added
- **Full-collection roadmap.** Lists every mount your account is missing, sorted
  easiest-first, using the game's own data (live base) + a curated overlay.
- **Hidden-eligibility detection.** A pulsing green border on mounts whose
  requirements you already meet (reputation/renown OK + affordable now).
- **Rich per-mount detail.** Vendor(s) (with Alliance/Horde tags), zone, and cost
  with the currency icon, name, **and how much you currently own**.
- **Drop-rate grading.** RNG drops ranked by odds; guaranteed rare-elite drops sit
  mid-priority; very rare ones sink to the bottom.
- **Smart faction filter** via the game's own visibility signal (hides opposite
  faction / class-locked / legacy mounts; one click to reveal).
- **Filters:** by expansion and by **current zone** (works in dungeons/raids and
  resolves sub-zones, e.g. Tazavesh → K'aresh).
- **Curated eligibility overlay** (122 mounts): renown, reputation and notable
  drops across Classic → Midnight, with precise requirement + currency checks.
- **Minimap button**, slash commands (`/mtrack`, `/mtr`, `/mounttracker`),
  one-click Wowhead links, manual "mark owned" / "hide".
- **Login banner** with addon version + game version, and a peer-to-peer
  **update check** (announces version over guild/party/raid).
- **Curation tool** (`tools/`) that extracts data from Wowhead + the game dump,
  plus a data-integrity validator and CI.

### Notes
- Targets **Midnight 12.0.5** (`## Interface: 120005`).
- Zero dependencies (pure Blizzard API). Handles Midnight "Secret Values" safely.
- Errors are sandboxed — no mid-screen Lua error popups.

[Unreleased]: https://github.com/lucas-fsousa/MountTracker/compare/v0.9.0...HEAD
[0.9.0]: https://github.com/lucas-fsousa/MountTracker/compare/v0.8.0...v0.9.0
[0.8.0]: https://github.com/lucas-fsousa/MountTracker/compare/v0.7.0...v0.8.0
[0.7.0]: https://github.com/lucas-fsousa/MountTracker/compare/v0.6.1...v0.7.0
[0.6.1]: https://github.com/lucas-fsousa/MountTracker/compare/v0.6.0...v0.6.1
[0.6.0]: https://github.com/lucas-fsousa/MountTracker/compare/v0.5.0...v0.6.0
[0.5.0]: https://github.com/lucas-fsousa/MountTracker/releases/tag/v0.5.0
