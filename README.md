# Parametric 3D-printable lens cage plate

An OpenSCAD lens mount plate for a rod-based optical cage system. Each plate holds a lens with a threaded retaining ring, can carry a magnetic bellows on either face, and clamps onto four steel rods with compliant clamps. The hinges can optionally be printed in TPU (multi-material).

![Overview](docs/overview.png)

## Features

- **Two standards** from one file:
  - **100 mm**: 100 × 100 mm plate, Ø8 rods at 85 mm spacing, Ø60 lens (M64×1.5 thread).
  - **60 mm**: 73 × 73 mm plate, Ø6 rods at 60 mm spacing (same rod size and spacing as the Thorlabs 60 mm cage system), Ø38.1 (1.5") lens (M43×1.5 thread). Without the bellows recess it takes a Ø50.8 (2") lens.
- **Lens-driven geometry**: set the lens diameter and the aperture, seat cone, internal thread and retaining ring follow automatically.
- **Magnetic bellows recess** on the front, back, both or neither face: 45° walls for self-centering, pry notches for removal, and magnet pockets.
- **Compliant rod clamps**: slotted arm with a flexure hinge, locked with an M3 screw into a captive nut.
- **Multi-material option**: hinges (optionally plus a rod-seat liner, or the whole arm) printed in TPU95A, anchored to the rigid part with dovetails.
- **Post mount**: optional captive M4 nut in the middle of any side, to fix the plate on a post with an M4 setscrew stud.
- **Retaining ring** generated to match the thread.
- **Interference checks**: when a parameter change makes features collide, OpenSCAD stops with a message saying what to adjust.

## Requirements

Use a recent **OpenSCAD development snapshot** ([openscad.org/downloads](https://openscad.org/downloads.html)) and turn on the **Manifold** backend in *Preferences → Advanced*. The file also opens in OpenSCAD 2021.01, but rendering there is extremely slow.

## Usage

1. Keep `lens_cage_plate.scad` and `lens_cage_plate.json` in the same folder and open the `.scad`.
2. In the Customizer, pick a preset from the drop-down at the top:
   - `100 mm standard (Ø8 rods at 85 mm)`
   - `60 mm standard (Ø6 rods at 60 mm)`
   - `60 mm standard, no recess (2 in lens)`
3. Adjust any parameter. Fields marked **"0 = from standard"** take the preset value; any number you enter overrides it.
4. Check the console: it reports the resulting thread, plate size, recommended screw lengths and any interference errors.

### Parts (`part`)

| Value | Output |
|---|---|
| `assembly` | Preview of rigid + TPU parts with ghost rods |
| `rigid` | Rigid part (PLA/PETG) |
| `tpu` | Flexible part (TPU95A) |
| `single` | Whole plate in a single material |
| `ring` | Retaining ring |

### Multi-material printing

1. Export `part = "rigid"` and `part = "tpu"` as separate STLs (binary STL is recommended).
2. Load both in the slicer **as one object with two parts**. They share the same origin, so they line up automatically.
3. Assign PLA/PETG to the rigid part and TPU95A to the flexible part.

`tpu_mode` options:

| Mode | TPU zones | Notes |
|---|---|---|
| `none` | – | Single material, 2 mm rigid hinge |
| `hinge` | Hinges | Recommended. The clamped load path goes through the screw, not the hinge, so alignment stays rigid |
| `hinge_liner` | Hinges + rod seat liner | Liner on the arm side only, with slight preload; the rigid body side stays the reference |
| `arm` | Whole arm | Not recommended for optics: the screw head clamps on TPU, which creeps |

In `hinge` mode the rigid arms are separate islands in the rigid STL, held only by the TPU. That is expected.

### Hardware

- Clamp screws: 4 × M3 screw + M3 nut (length printed in the console, M3 × 10 or 12).
- Post mount: 1 × M4 nut + M4 setscrew stud (length printed in the console).
- Magnets: Ø6 (100 mm standard) or Ø5 (60 mm standard), when the recess is enabled.

## Files

| File | Content |
|---|---|
| `lens_cage_plate.scad` | Parametric model |
| `lens_cage_plate.json` | Customizer presets for each standard |
| `docs/overview.png` | Overview image |

Exported meshes (`*.stl`, `*.3mf`) are not tracked; regenerate them from the `.scad`.
