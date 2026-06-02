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
- zips the addon (`.toc`, `Core/`, `Data/`, `Logic/`, `UI/`, `LICENSE`, `README.md`)
  under a top-level `MountTracker/` folder,
- reads the matching `CHANGELOG.md` section as the release notes,
- publishes the Release with the `MountTracker-X.Y.Z.zip` attached.

## Versioning

[Semantic Versioning](https://semver.org/): `MAJOR.MINOR.PATCH`.
- **PATCH** — bug fixes / data corrections.
- **MINOR** — new features, new curated mounts.
- **MAJOR** — breaking changes (rare for an addon).

## Keeping the changelog current

Add a bullet under `## [Unreleased]` in `CHANGELOG.md` as part of each change, so a
release is just "move Unreleased → version + tag".
