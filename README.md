# OptSys

A family of parametric, 3D-printable optomechanical parts written in OpenSCAD, organized like a catalog (in the spirit of Thorlabs, Edmund Optics or Standa). Parts share interface standards (rod spacing, rod diameter, threads, posts, fasteners), so they fit together and, where possible, with commercial components.

![Lens cage plates](docs/lens_cage_plate.png)

## Parts

| Part | Folder | Standards | Description |
|---|---|---|---|
| Lens cage plate | [`parts/cage_plates`](parts/cage_plates/README.md) | 60 mm, OptSys 100 | Lens mount with retaining-ring thread, magnetic bellows recess, compliant rod clamps, optional TPU hinges and post mount |

## Interface standards

Defined once in [`lib/standards.scad`](lib/standards.scad) and used by every part.

| Cage system | Rod spacing | Rods | Series thread | Typical plate |
|---|---|---|---|---|
| `16mm` | 16 mm | Ø4 | SM05 (0.535"-40) | 25 mm |
| `30mm` | 30 mm | Ø6 | SM1 (1.035"-40) | 41 mm |
| `60mm` | 60 mm | Ø6 | SM2 (2.035"-40) | 71.1 mm |
| `100mm` (OptSys) | 85 mm | Ø8 | M64×1.5 | 100 mm |

The 16/30/60 mm rows match the Thorlabs cage standards. Metric posts are Ø12.7 mm with M4 on top and M6 at the bottom; metric breadboards use M6 holes on a 25 mm grid.

Note: the SM thread series are 40 TPI (0.635 mm pitch), at the limit of FDM printing. OptSys parts use coarser threads (1.5 mm pitch) for their own interfaces; test before relying on printed SM threads with commercial lens tubes.

## Repository layout

```
lib/                     shared code, no output of its own
  optsys.scad            entry point: use <../../lib/optsys.scad>
  standards.scad         cage, thread and post standards
  hardware.scad          metric nuts / clearance holes, captive nut slots
  geometry.scad          2D/3D helpers (sectors, closing, mirror4, ...)
  chamfers.scad          chamfered extrusions, drafted pockets
  threads.scad           printable internal/external threads
  multimaterial.scad     dovetails for rigid + TPU parts
parts/<family>/          one folder per part family
  <part>.scad            the part, with Customizer parameters
  <part>.json            Customizer presets (same base name)
  README.md              what it is, how to print, hardware
docs/                    images
tools/check.sh           compiles every part and preset, fails on errors
```

## Requirements

A recent **OpenSCAD development snapshot** ([openscad.org/downloads](https://openscad.org/downloads.html)) with the **Manifold** backend enabled in *Preferences → Advanced*. OpenSCAD 2021.01 also works but renders very slowly.

Open parts from their folder inside the repository: they load the library through a relative path.

## Adding a part

1. Create `parts/<family>/<part>.scad` and start it with `use <../../lib/optsys.scad>`.
2. Pick the interface from `lib/standards.scad` (e.g. `cage_rod_d("30mm")`, `cage_rod_spacing("30mm")`); never hard-code interface dimensions in the part. Anything another part could reuse goes into `lib/`.
3. Follow the conventions:
   - Optical axis is +Z, centered on the origin; the front face is the highest Z.
   - English names, `family_function` (e.g. `cage_plate_lens`, `mirror_mount_kinematic`).
   - A `standard` selector when the part comes in several sizes, using non-numeric keys (`"30mm"`) compared with `str()`.
   - Every numeric Customizer parameter has an explicit range and step: `x = 0; // [0:0.05:200]` (otherwise the Customizer may round decimals).
   - Presets in `<part>.json` with numeric (not quoted) values.
   - A `part` selector (`assembly`, `rigid`, `tpu`, `single`, accessories) for multi-material parts: `rigid = body - region`, `tpu = body ∩ region`.
   - One `echo` summary line (standard, key dimensions, hardware) and `assert()` checks with messages that say which parameter to change.
   - Wrap heavy subtrees in `render()` so the F5 preview keeps working.
4. Add a `README.md` and an image, list the part in the table above, and run `tools/check.sh`.

## Checking

```
tools/check.sh            # uses `openscad` from PATH
OPENSCAD=openscad-nightly tools/check.sh
```

It compiles every part with its defaults and with each preset of its `.json`, and fails on any error or warning.

Exported meshes (`*.stl`, `*.3mf`) are not tracked; regenerate them from the `.scad` files.
