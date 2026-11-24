# Lens cage plate

*Part of [OptSys](../../README.md).*

An OpenSCAD lens mount plate for a rod-based optical cage system. Each plate holds a lens with a threaded retaining ring (or works as a receptor for [QM quick-mount lens adapters](../quick_mount/README.md)), can carry a magnetic bellows on either face, and clamps onto four steel rods with compliant clamps. Printed in a single material (PLA / PETG).

![100 mm and 60 mm plates](../../docs/lens_cage_plate.png)

*Top: 60 mm standard with a lens thread, and 60 mm QM42 receptor. Bottom: the preview-only dimensions of the threaded plate.*

## Features

- **Three standards** from one file:
  - **100 mm**: 100 × 100 mm plate, Ø8 rods at 85 mm spacing, Ø60 lens (M64×1.5 thread).
  - **60 mm**: 73 × 73 mm plate, Ø6 rods at 60 mm spacing (same rod size and spacing as the Thorlabs 60 mm cage system), Ø38.1 (1.5") lens (M43×1.5 thread). Without the bellows recess it takes a Ø50.8 (2") lens.
  - **50 mm**: 63 × 63 mm plate, Ø6 rods at 50 mm spacing (the user's epi-illuminator cage), Ø25.4 (1") lens (M30×1.5 thread), or a QM42-EPI receptor.
- **Lens mount** (`lens_mount`): `thread` (lens + retaining ring) or `qm`, a receptor for QM quick-mount adapters: Ø42 bore with `qm_bore_clearance` (diametral, default 0.3), M4 lock screw with a captive nut on the side you choose. The seat face is placed so the lock screw is centered in the plate thickness: with `QM42` (Ø46 flange) on a 10 mm plate it is the front recess floor (1.5 mm) of the 60 and 100 mm plates, or a Ø46.6 × 1.5 flange pocket when the front face has no recess.
- **V rod seats**: the clamp arm pushes the rod into a V on the body side, so it touches two lines along the whole thickness and the plate cannot tilt on the rod. `rod_v_angle` (default 100°) trades centering stiffness for snap-in effort; the console prints the snap interference. (The earlier round seat with clearance was dropped: the rod touched it on a single line and the plate could rock around it.)
- **Thread clearances**: `thread_clearance` (diametral, 0.2) plus `thread_z_clearance` (axial, 0.25), both split between plate and ring: about 0.48 mm of axial play while keeping the full radial engagement. Printed flat, the 60° thread flanks are only 30° from the bed, so layer steps and sag land on them: radial clearance alone opens the flanks by half its value and loosens the thread. The ring has 45° chamfers on both ends (`ring_chamfer`) against the elephant foot.
- **Lens-driven geometry**: set the lens diameter and the aperture, seat cone, internal thread and retaining ring follow automatically.
- **Magnetic bellows recess** on the front, back, both or neither face: 45° walls for self-centering, pry notches for removal, and magnet pockets.
- **Compliant rod clamps**: slotted arm with a flexure hinge, locked with an M3 screw into a captive nut.
- **Dimensions in the preview** (`show_dims`): the F5 preview shows the bore or thread diameter, the plate width and the key data (QM bore Ø and clearance, lock screw, or thread, length, clearances, lens, aperture and ring). They use OpenSCAD's `%` modifier, so they never appear in the render (F6) or in the exported STL.
- **Post mount**: captive M4 nut in the middle of one side (bottom by default, or none), to fix the plate on a post with an M4 setscrew stud.
- **Retaining ring** generated to match the thread.
- **Interference checks**: when a parameter change makes features collide, OpenSCAD stops with a message saying what to adjust.

## Usage

1. Open `lens_cage_plate.scad` from this folder. It loads the shared library from `../../lib`, so keep the repository structure intact; `lens_cage_plate.json` must stay next to it.
2. In the Customizer, pick a preset from the drop-down at the top:
   - `50 mm standard (Ø6 rods at 50 mm, 1 in lens)`: M30 thread and retaining ring, no recess
   - `50 mm QM42 receptor, V rod seats`: QM42-EPI receptor (the user's EPI plates), no recess
   - `60 mm QM42 receptor, V rod seats`: recess on both faces, Ø4 blind magnets, M4 holes Ø4.2
   - `100 mm QM42 receptor, V rod seats`: recess on both faces

   All with the post mount on the bottom side. For a threaded 60 or 100 mm plate, pick the standard and set `lens_mount = thread`.
3. Adjust any parameter (the Customizer groups go from the most used, *Output*, *Standard*, *Lens mount*, to the fine geometry at the end). Fields marked **"0 = from standard"** take the preset value; any number you enter overrides it.
4. Check the console: it reports the resulting thread, plate size, recommended screw lengths and any interference errors.

### Parts (`part`)

| Value | Output |
|---|---|
| `assembly` | Preview of the plate with ghost rods (and the QM adapter outline) |
| `plate` | Plate (older presets with `single` or `rigid` give the same) |
| `ring` | Retaining ring |

### Hardware

- Clamp screws: 4 × M3 screw + M3 nut (length printed in the console, M3 × 10 or 12).
- Post mount: 1 × M4 nut + M4 setscrew stud (length printed in the console).
- QM receptor: 1 × M4 nut + M4 setscrew (length printed in the console).
- Magnets: Ø6 (100 mm standard) or Ø5 (60 mm standard), when the recess is enabled.

## Files

| File | Content |
|---|---|
| `lens_cage_plate.scad` | Parametric model |
| `lens_cage_plate.json` | Customizer presets for each standard |
