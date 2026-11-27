# CLAUDE.md

Notes for Claude working in this repository. Read `README.md` first: it has the parts table, the interface standards, the repository layout and the conventions for adding a part. This file adds how the owner works and what has gone wrong before.

## The owner and the setup

- The owner writes in Spanish (Argentina): answer in Spanish. Code, comments, READMEs, commit messages and PRs stay in English.
- Windows clone at `C:\Users\T14S GEN 2\OptSys`, edited in VS Code; terminal is PowerShell or Git Bash. OpenSCAD **nightly** with the **Manifold** backend, open next to VS Code with *Automatic Reload and Preview* and the editor hidden.
- Printer: Snapmaker U1 (toolchanger), sliced in Snapmaker Orca. Plates print in a **single material**; TPU 95A only where a part needs it (bayonet spring ring, printed bellows). Filaments on hand: PLA, PETG HS black, PETG-CF, TPU 95A.
- The owner tests parts physically and reports back; tested values become defaults (see PR #6: `bq_detent` 0.5, spring ring 0.9 / 0.7 / 0.6).

## Owner preferences (apply to every part)

- Keep the software simple: don't add options the owner doesn't use, and remove ones they dropped.
- Rod seats: **V seat only** (`rod_v_angle` 100), never a round seat.
- **Captive nuts, not heat-set inserts** (nut 3.5 mm from the edge). No dowel-pin centering.
- Post mount at the bottom by default. Magnets in blind holes by default.
- Dimensions for the user go to the console (`echo`) and to **preview-only annotations called with `%`** (`show_dims`); never engraved or exported in the part.
- Customizer groups ordered by use: Output, Standard and the main interface first; fine geometry and Quality last.
- The presets in the repo are the owner's: don't rename, reorder or "fix" their values without asking. If a preset fails `check.sh`, say so instead of changing it silently.

## Presets (`<part>.json`)

- The OpenSCAD Customizer writes them, and saves numbers as strings (`"0.35000000000000003"`). In the repo, numbers are numeric (`0.35`); booleans, text and vectors stay strings (`"true"`, `"qm"`, `"[0.5, 0.7]"`).
- **Before any git operation that touches a `.json` (checkout, pull, merge, stash), check for uncommitted preset changes** (`git diff -- '*.json'`) and copy them to `.presets_backup/<file>.<date>` (ignored by git). Then merge them back by key, not by text.
- After normalizing or merging presets, render the CSG of every preset from the new file and from the owner's file and compare them (see Checking): they must be identical except for changes the owner asked for.
- OpenSCAD reads the `.json` only when it opens the `.scad`; an old OpenSCAD window can overwrite it when the owner saves presets. Ask the owner to reopen the part after you change its presets.

## Lessons learned (don't repeat)

1. Customizer rounds fields with an integer default: every numeric parameter needs `// [min:step:max]`.
2. Dropdowns with numeric values arrive as numbers: use non-numeric keys (`"30mm"`) compared with `str()`.
3. Blank preview ("Normalized tree has 0 elements"): wrap heavy subtrees in `render()`.
4. Don't share one `render()` node between parts of different `color()`: the cache keeps the first color.
5. `minkowski` in Manifold leaves zero-volume slivers: use stepped chamfers (0.1 mm) or `hull()` of convex pieces.
6. Avoid exactly coincident faces between solids that are unioned: shrink by 0.02 mm.
7. Horizontal screw holes: round.
8. With `use`, library variables are not exported: expose data through functions.
9. Printed FDM threads (printed flat): radial clearance alone isn't enough; add axial play with `z_clearance` and end chamfers. Too much radial clearance makes the lens start a turn early and sit tilted.
10. Any radial screw in a plate with bellows recesses: check that its channel doesn't break a recess floor; center it in the thickness.
11. Before diagnosing a fit problem from a printed part, **measure the owner's STL**: OpenSCAD exports the last F6 render, which may be stale.
12. Non-fatal messages start with `Note:`; never print the word WARNING (`check.sh` treats it as a failure).
13. Line endings are LF (`.gitattributes`); diffs that only change CRLF are noise, not edits.

## Checking

- `tools/check.sh` (or Ctrl+Shift+B in VS Code) compiles every part with its defaults and every preset; it must pass before a commit.
- Refactors, reordering or text-only changes: export `.csg` before and after (`show_dims = false`), drop the lines that are only `group() {`, `}` or `group();`, and compare: they must be identical.
- Threads: check the profile numerically (axial play, radial overlap) and that plate ∩ ring is empty.
- Multimaterial parts: zero-volume intersection between the STLs of each material.
- New or changed part: README, image in `docs/`, row in the root README parts table.

## Git workflow

- Never commit to `main`: every change goes on a branch and a PR; the owner reviews and merges.
- Commit only what the task changed; never commit `.presets_backup/`, STL, 3MF or G-code.
- Ask before deleting branches, force-pushing, or discarding local changes (`git checkout -- .`, `git reset --hard`, `git stash drop`); restore single files after checking them instead.
- Open branch not yet merged: `printed-bellows` (printed TPU bellows with PLA spacers and PETG frames, `lib/bellows.scad`); untested on the printer. An iris diaphragm branch exists only as a patch from an earlier session.

## Pending ideas

Blind and adapter cage plates (30↔60), 30 mm lens plate, retaining rings and lens tubes, C-mount adapter, kinematic mirror mount, filter holder, cage cube, post holders and breadboard adapters, magnetic frame for the paper bellows, printed bellows for the owner's lathe and mill, round and 4-blade rectangular irises (including large ones for Durst Laborator Latico condensers), rail accessories (cage adapters, end stops, breadboard feet), better Z-on-XY carriage stacking. Standa compatibility: verify their system before designing for it.
