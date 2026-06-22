<div align="center">

# 🐎 MountTracker

### Your personal mount-collecting roadmap — surfacing the mounts you can grab *right now* but didn't know about.

**Language:** **English** · [Português (BR)](README.pt-BR.md)

![Game](https://img.shields.io/badge/WoW-Midnight%2012.0.5-8B0000)
![Interface](https://img.shields.io/badge/Interface-120005-444)
![Dependencies](https://img.shields.io/badge/dependencies-none-2ea44f)
![Lua](https://img.shields.io/badge/Lua-5.1-000080)
![Status](https://img.shields.io/badge/status-active%20development-blue)

</div>

---

## ✨ Why MountTracker?

There are plenty of addons that list the mounts you're missing. **None of them tell you which ones you can already claim.**

You've been playing for years. Somewhere along the way you hit **Exalted** with a faction, finished an **achievement**, or stockpiled a **currency** — and the mount tied to it has just been sitting there, unclaimed, because the game never told you.

> **MountTracker's killer feature:** it cross-references your *live* reputation, currencies, gold and achievements against every mount you don't own, and **lights up the ones you're already eligible for** with a pulsing green border. No more "wait, I could have had this the whole time?"

It then builds a **roadmap** of everything else, sorted from *easiest to obtain* to *hardest*, with the exact vendor, location, cost, and how much of that currency you currently hold.

---

## 🎯 What it does

- **Tracks your whole account's collection** live from the Mount Journal.
- **Builds a prioritized roadmap** of missing mounts — easiest first.
- **Detects hidden eligibility** — the green glow means *"you can get this now."*
- **Shows you exactly how to get each mount:** vendor name, zone, cost (with currency icon **and how much you own**), or the drop source and its rate.
- **Filters out what you can't get** — opposite-faction, class-locked, and legacy/unobtainable mounts are hidden by default (and one click away when you want them).
- **Filter by expansion**, toggle owned/unavailable, and manage your list manually.
- **Search the roadmap** by name, vendor or zone to jump straight to a specific mount.

---

## 🚀 Features at a glance

| Feature | Description |
|---|---|
| 🟢 **Obtainable-now glow** | A pulsing border on any mount whose requirements you already meet (reputation OK + currency/gold OK). |
| 🗺️ **Full-collection coverage** | Every missing mount in the game, using the game's own source data — not a hand-typed list. |
| 💰 **Currency "have" tracker** | Costs show the icon, name **and your current balance** — green when you can afford it, orange when you can't. |
| 🎲 **Drop-rate grading** | RNG drops are ranked by their odds: `1/25` is "go farm it," `1/200` sinks to the bottom — each shown with its percentage. |
| ⚔️ **Smart faction filter** | Uses the game's own visibility signal to correctly hide opposite-faction and class-locked mounts (not just the "paired" ones other tools miss). |
| 📂 **Expansion filter** | Narrow the roadmap to Classic, TBC, WotLK … all the way to The War Within and Midnight. |
| 🔎 **Text search** | A free-text box filters the roadmap by name, vendor or zone — combine it with the other filters to pull up a specific mount fast. |
| 🏷️ **Curated overlay** | Hand-verified data (from Wowhead) adds precise eligibility detection, drop rates and Wowhead links on top of the live base. |
| ✎ **In-game curation editor** | Contributor tool: edit a mount's acquisition data (vendor, cost, requirement, coords…) right in the detail panel and watch the roadmap update live. See the note below before using. |
| 🧭 **Minimap button** | Drag it anywhere around the ring; click to open. Zero external libraries. |
| 🔗 **One-click Wowhead** | Every mount has a Wowhead link — copy it straight from the row. |
| 🛡️ **No mid-screen errors** | Every entry point is sandboxed; if something fails you get a quiet chat message, never a Lua error popup. |
| 🔒 **Midnight Secret-Value safe** | Handles the 12.0 "Secret Value" API gracefully instead of breaking. |
| 🪶 **Zero dependencies** | Pure Blizzard API. No Ace3, no LibDBIcon, nothing to install alongside it. |

---

## 📸 Screenshots

![The roadmap window](images/roadmap.png)

*The roadmap — your missing mounts, easiest first, each with vendor, location and **cost vs. your balance**.*

| | |
|:---:|:---:|
| ![Obtainable-now glow](images/glow.png) | ![Per-mount detail](images/row.png) |
| **Green glow = you can get it right now** | Clean, click-to-open rows |
| ![Detail panel](images/detail-panel.png) | ![Vendor waypoint](images/waypoint.png) |
| Click a mount → detail panel with a **3D model** + all actions | One click sets a **waypoint** to the vendor |
| ![Expansion filter](images/expansion-filter.png) | ![Category filter](images/category-filter.png) |
| Filter by expansion | Filter by category (Vendor / Reputation / Drop / …) |
| ![Search & filters](images/free-filter.png) | ![Show owned](images/owned-toggle.png) |
| Free-text search + toggles (current zone, owned, unavailable) | Owned (colored) vs. missing (gray) |
| ![Minimap button](images/minimap.png) | ![Curation editor](images/editmode.png) |
| Minimap button — drag anywhere, click to open | In-game curation editor (contributor tool) |

---

## 📥 Installation

1. Download **[`MountTracker.zip`](../../releases/latest/download/MountTracker.zip)** (always the latest release).
   *(Don't use the "Source code (zip)" link — that one won't load in-game.)*
2. Extract it into:
   ```
   World of Warcraft\_retail_\Interface\AddOns\
   ```
   (You'll get a `MountTracker` folder containing `MountTracker.toc`.)
3. Restart the game, or `/reload` if it was already running.
4. Make sure **MountTracker** is enabled in the AddOns list on the character screen.

> Targeting **Midnight 12.0.5** (`## Interface: 120005`). Playing a different build? Just edit the `## Interface:` line at the top of `MountTracker.toc`, or tick *"Load out of date AddOns."*

---

## 🕹️ Usage

Open the window from the **minimap button** or with a slash command:

| Command | What it does |
|---|---|
| `/mtrack` (or `/mtr`, `/mounttracker`) | Open / close the roadmap window |
| `/mtrack scan` | Print a summary to chat (owned / obtainable / unavailable) |
| `/mtrack find <name>` | Look up a mount's internal ID |
| `/mtrack minimap` | Show / hide the minimap button |
| `/mtrack enable edit` / `/mtrack disable edit` | Turn the in-game curation editor on/off (see below) |
| `/mtrack export` | List your pending manual edits (for contributing) |
| `/mtrack reset` | Clear your manual overrides (marked-owned / hidden) |
| `/mtrack debug` | Toggle technical error details |
| `/mtrack help` | List all commands |

**In the window:**
- **Search box** — type part of a name, vendor or zone to filter the roadmap.
- **Wowhead** — copy the mount's Wowhead link.
- **Hide** — hide a mount you don't care about.
- **Owned** — mark a mount as owned (fixes a wrongly-tracked one).
- Use the **Expansion** dropdown and the **Show owned / Show unavailable** checkboxes to shape the list.

### ✎ In-game curation editor (contributors)

Run `/mtrack enable edit` and an **"Edit data"** button appears on each mount's detail panel. It lets you fill in or correct a mount's acquisition data — vendor, zone, map, coords, cost, requirement, expansion — and see the roadmap update **live**, which is great for validating a specific mount before contributing the fix.

> **Heads-up — your edits are local until you share them.** They're saved only on your client (the `MountTrackerEdits` SavedVariable) and are **not** uploaded anywhere. To get a fix into the official addon (and help everyone), **[open a Pull Request](../../pulls)** with your data — we review it and merge it into the master repo. Until then, your local edits **override** the addon's data: if you keep an edit for a mount that later receives an official curation, your local copy wins and can **mask** the official fix. After your PR is merged, hit **Revert** on that mount to drop the local copy. This is a contributor tool — regular collectors don't need it.

---

## 🧠 How it works

MountTracker uses a **hybrid model**:

1. **Live base — total coverage.** It reads *every* mount from the Mount Journal and uses the game's own `sourceText` (vendor, zone, faction, renown, quest) to describe how to get each one. This covers the entire game with zero manual data and is always up to date.
2. **Curated overlay — the magic.** A hand-verified table (sourced from Wowhead, keyed by spell ID) sits on top and adds what the API can't: precise **eligibility detection** (do you already meet the reputation/currency requirement?), **drop rates**, and **Wowhead links**.

Eligibility, currency balances and reputation are read **live** every time, so the roadmap always reflects your character's real state — including correctly handling Midnight's **Secret Values**.

A built-in `/mtrack dump` tool exports your journal so contributors can expand the curated overlay with accurate, language-independent data.

---

## 🐞 Spotted a wrong glow? Please report it

This is the single most useful thing you can do for the project. 🙏

The green **"obtainable now"** glow is only as good as the data behind it — and some gates are **invisible to the game itself**. A handful of mounts are locked behind a *hidden* reputation, a friendship rank, or a currency-tracked progression that the game **never prints** in its source text (real examples we've already fixed: *Ivory Hawkstrider* needs Exalted with a hidden faction; *Preyseeker's Wrath* needs *Preyseeker's Journey* rank 10). When that happens, a mount can light up green even though you can't actually buy it yet — a **false positive**.

We hunt these down through a strict chain of sources, in order of trust:

> **game data → Wowhead → Wowhead comments → your feedback**

When the game doesn't expose a gate, we harvest it from Wowhead; when even Wowhead's structured data is silent, the answer often lives only in the page **comments** — or in **your report**. Many of these have to be curated **by hand**, one mount at a time, so each report genuinely moves the needle.

**If you see a mount glow green that you *can't* actually get** (or one that *should* glow but doesn't), please **[open an issue](../../issues/new)** with:

- the **mount name**,
- what's actually gating it (the requirement you're missing), and
- the output of `/mtrack check <name>` if you can.

We'll curate the fix and ship it in the next version. Even a one-line "X glows but needs Y" is a huge help. 💚

---

## 🗺️ Project status & roadmap

MountTracker is in **active development**. The live base already covers the whole collection; the curated eligibility overlay is being expanded **expansion by expansion** (Classic → TBC → WotLK → …).

- [x] Live base over the full Mount Journal
- [x] Hidden-eligibility detection + obtainable-now glow
- [x] Currency "have", drop-rate grading, faction & expansion filters
- [x] Minimap button, manual overrides, error-safety
- [ ] Full curated eligibility overlay across all expansions
- [ ] Boss/dungeon → expansion mapping (shrink the "Unknown" bucket)
- [ ] Optional TomTom waypoints

---

## 🤝 Contributing

Curation help is very welcome! The most valuable contribution is **verified acquisition data** for mounts (spell ID, faction/standing, vendor, cost, drop rate, Wowhead link).

1. Run `/mtrack dump` in game, then `/reload`.
2. The export lands in your `SavedVariables\MountTracker.lua`.
3. Open an issue or PR with the data — or just the dump and we'll convert it.

Bug reports and UI feedback are equally appreciated. Please include the output of `/mtrack debug` if you hit an error.

---

## ❓ FAQ

**Does it work for the opposite faction / other classes?**
Mounts your character can't obtain are hidden by default (using the game's own signal). Tick **"Show unavailable / hidden"** to see them.

**Why is a mount under "Unknown" expansion?**
Its source text doesn't mention a recognizable zone (common for boss drops, professions and holidays). It's still in the list — just in the catch-all bucket.

**Are drop rates exact?**
No — they're community estimates (Wowhead). Treat them as a guide, not gospel.

**Does it need any other addon?**
No. It's pure Blizzard API with zero dependencies.

---

## 🏆 Companion addon — AchievementTracker

Love how MountTracker surfaces the easiest mounts to grab? There's a sibling addon for
**achievements**: **[AchievementTracker](https://github.com/lucas-fsousa/AchievementTracker)**.

It builds the same kind of priority roadmap for the achievements you're missing — sorted
**easiest first, "can do it solo right now"** at the top, with the group-required and
multi-day grinds pushed to the bottom. Same clean UI, same zero-fuss philosophy.

👉 **Get it here: https://github.com/lucas-fsousa/AchievementTracker**

---

## 📜 License

Released under the **MIT License** — free to use, study and improve. See `LICENSE`.

> _World of Warcraft and related assets are trademarks of Blizzard Entertainment. This is an unofficial, fan-made addon._

---

<div align="center">

Made for the WoW mount-collecting community.
**Happy hunting**

</div>
