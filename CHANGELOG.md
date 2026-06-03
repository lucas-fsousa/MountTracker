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

[Unreleased]: https://github.com/lucas-fsousa/MountTracker/compare/v0.6.0...HEAD
[0.6.0]: https://github.com/lucas-fsousa/MountTracker/compare/v0.5.0...v0.6.0
[0.5.0]: https://github.com/lucas-fsousa/MountTracker/releases/tag/v0.5.0
