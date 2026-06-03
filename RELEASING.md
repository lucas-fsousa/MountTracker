# Releasing

Releases are automated. Pushing a `vX.Y.Z` tag builds the addon zip and publishes a
GitHub Release with a permanent download link (`.../releases/latest`).

## Steps

1. **Update the changelog.** In `CHANGELOG.md`, move the items under `## [Unreleased]`
   into a new dated section:
   ```
   ## [0.6.0] - 2026-07-01
   ### Added / Changed / Fixed
   - ...
   ```
2. **Bump the version** in `MountTracker.toc`:
   ```
   ## Version: 0.6.0
   ```
   (The release workflow fails if the tag and the `.toc` version don't match.)
3. **Commit** both changes.
4. **Tag and push:**
   ```bash
   git tag v0.6.0
   git push origin v0.6.0
   ```

The **Release** workflow (`.github/workflows/release.yml`) then:
- verifies the `.toc` version equals the tag,
- zips the addon (`.toc`, `Core/`, `Data/`, `Logic/`, `UI/`, `LICENSE`, `README*`)
  under a top-level `MountTracker/` folder,
- reads the matching `CHANGELOG.md` section as the release notes,
- publishes the Release with **`MountTracker.zip`** attached (no version in the file
  name — the Release tag carries the version, and this gives a stable download URL:
  `.../releases/latest/download/MountTracker.zip`).

> **Why the zip is version-less:** WoW only loads an addon whose folder is named
> exactly `MountTracker`. The folder *inside* the zip is always `MountTracker`; the
> file name has no version so users can't accidentally end up with a
> `MountTracker-X.Y.Z` folder. Do **not** point users at GitHub's auto-generated
> "Source code (zip)" — that extracts to `MountTracker-X.Y.Z/` with dev files and
> won't load.

## CurseForge (optional, automatic)

The same tag also publishes to CurseForge via the community
[BigWigs packager](https://github.com/BigWigsMods/packager) (`.pkgmeta` controls what
ships). It auto-maps the game version from `## Interface:` in the `.toc`. It runs only
if both of these are configured in the GitHub repo (otherwise the step is skipped):

1. **Secret** `CF_API_KEY` — a CurseForge API token
   (curseforge.com -> Account -> *API Tokens*).
   Repo -> *Settings* -> *Secrets and variables* -> *Actions* -> *New repository secret*.
2. **Variable** `CF_PROJECT_ID` — the numeric project ID shown on the addon's
   CurseForge page (right sidebar, "Project ID").
   Same screen -> *Variables* tab -> *New repository variable*.

Create the CurseForge project once (the first upload must be done manually on the
CurseForge site), then every `vX.Y.Z` tag updates it automatically.

## Versioning

[Semantic Versioning](https://semver.org/): `MAJOR.MINOR.PATCH`.
- **PATCH** — bug fixes / data corrections.
- **MINOR** — new features, new curated mounts.
- **MAJOR** — breaking changes (rare for an addon).

## Keeping the changelog current

Add a bullet under `## [Unreleased]` in `CHANGELOG.md` as part of each change, so a
release is just "move Unreleased → version + tag".
