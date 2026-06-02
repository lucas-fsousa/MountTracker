# MountTracker — curation tools

Semi-automated curation: turn a `/mtrack dump` into ready-to-paste Lua entries for
the curated overlay, pulling the **requirement the game doesn't expose** (Renown /
Reputation + faction ID) from Wowhead's public endpoints.

## Why

The in-game Mount Journal gives us vendor / zone / cost via `sourceText`, but **not**
the renown/reputation requirement to buy a mount. That gap is what causes false
"obtainable now" glows. This tool fills it from Wowhead so we don't hand-search.

## How it works

1. `dump_to_json.lua` converts your SavedVariables `MountTracker.lua` to JSONL.
2. `curate.py` (CLI/orchestration) selects candidate mounts and, for each, drives the
   specialized modules in the **`mtcurate/`** package:
   - resolves the Wowhead **item id** by name (`/search/suggestions-template`),
   - reads the item page and extracts the requirement
     (`Requires Renown Rank N with X` / `Requires <Standing> with X`) or drop chance,
   - resolves the **faction id** by name (same suggestions endpoint),
   - parses the **cost** (currency/item/gold) and the requirement from the dump's
     `sourceText` as a fallback,
   - emits a Lua entry.

### Modules (`mtcurate/`)

| Module | Responsibility |
|---|---|
| `http.py` | Polite GET: disk cache, rate-limit, retry/backoff |
| `dump.py` | Load the `/mtrack dump` (via `dump_to_json.lua`) |
| `wowhead.py` | ID resolution (item/faction) via the suggestions endpoint |
| `sourcetext.py` | Parse the game's `sourceText`: fields, cost, requirement, expansion |
| `extract.py` | Extract from the Wowhead item page: requirement, drop chance |
| `emit.py` | Build the curated Lua entries |

It is **polite**: identifiable User-Agent, on-disk cache (only hits the network for
pages it hasn't seen), and a configurable rate-limit (`--delay`). Run it sparingly,
for new content only.

## Requirements

- Python 3 (standard library only — no pip packages).
- A `lua` interpreter on PATH (or pass `--lua /path/to/lua`) to read the dump.

## Usage

```bash
# 1) In game: /mtrack dump  then  /reload   (writes SavedVariables/MountTracker.lua)
# 2) Run the tool, filtered to the content you want to curate:

python3 curate.py \
    --dump "/path/to/WTF/Account/<ID>/SavedVariables/MountTracker.lua" \
    --filter "Zul'Aman" \
    --expansion Midnight \
    --delay 1.0 > out.lua

# 3) Review out.lua, fold the entries into Data/Mounts_<Expansion>.lua, commit.
```

Options:

| Flag | Meaning |
|---|---|
| `--dump` | Path to the SavedVariables `MountTracker.lua` (required) |
| `--filter` | Substring match on name + sourceText (e.g. a zone) |
| `--expansion` | Label for the generated `ns.Data.Register("<exp>", …)` block |
| `--lua` | Lua binary (default `lua`) |
| `--delay` | Seconds between network requests (default 1.0) |
| `--limit` | Max mounts to process (0 = all) |
| `--include-collected` | Also process mounts you already own |
| `--cache` | Cache directory (default `tools/cache`) |

## Validating the curated data

`validate.lua` loads the whole curated overlay outside the game and checks integrity
(unique spell IDs; renown entries have a faction id/name; reputation entries have a
faction id + valid standing; costs are well-formed; drop chances in range):

```bash
lua tools/validate.lua .
```

It runs in CI (`.github/workflows/ci.yml`) on every push/PR, alongside Lua syntax
(`luac -p`) and Python syntax checks.

## Status / limitations

- ✅ **Modern renown mounts** (requirement encoded on the item tooltip): fully
  automated — faction id, renown level, currency cost.
- ⚠️ **Classic reputation mounts** (the rep gate lives on the *vendor* sale
  condition, not the item tooltip): the requirement is **not** auto-extracted yet;
  the entry is emitted without it (fill in by hand, or improve the "sold by" parser).
- Always **review** the output before committing — Wowhead text/formatting can change.

> Data comes from Wowhead (community-maintained). Treat drop rates and edge cases as
> estimates, and double-check anything that looks off.
