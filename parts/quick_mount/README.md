# QM quick-mount lens adapters

*Part of [OptSys](../../README.md).*

One small adapter per lens, one receptor per cage position. The adapter carries the lens (enlarger lens, microscope objective) or screws into a bellows / helicoid, and drops into a **QM receptor**: a cage plate with `lens_mount = "qm"` ([`parts/cage_plates`](../cage_plates/README.md)). Print the adapters small and fine (0.08 mm layers work well for the L39 thread).

## How the QM interface works

Taken from the user's tested quick mount (epi-illuminator cage, Pentax bellows):

- The adapter has a **Ø42 spigot** and a **Ø50 × 3 flange**. The spigot goes into a Ø42 bore in the receptor; the flange underside rests on the receptor seat face.
- Around the spigot runs a **groove** with a flat step on top and a **conical flank** below.
- A radial **M4 lock screw** in the receptor (heat-set insert or captive nut) presses on the conical flank. Part of its force pulls the flange onto the seat face (about 1.4 × the screw force with the 55° flank): the seat face sets the axial position and the tilt. The rest pushes the spigot against the bore wall (or two locating pins): that sets the centering.
- The groove runs all around, so the lens can be clocked freely (aperture scale where you want it).

All dimensions live in `OPTSYS_QUICKMOUNTS` (`lib/standards.scad`); the geometry in `lib/quickmount.scad` (`qm_spigot_flange`, `qm_receptor_cut`).

| QM42 | Value |
|---|---|
| Spigot | Ø42 × 10 mm (= receptor thickness) |
| Flange | Ø50 × 3 mm |
| Lock screw | M4, 5 mm below the seat face |
| Groove | flat step 3.4 mm below the seat, bottom Ø38.6, conical flank from 5.2 to 6.4 mm |

## Adapter (`qm_adapter.scad`)

| Preset | Mode | Thread | Use |
|---|---|---|---|
| `L39 enlarger lens (QM42)` | female | 39 mm × 26 TPI | El-Nikkor, Componon, Rodagon ... (sold as "M39") |
| `RMS objective (QM42)` | female | 0.8" × 36 TPI | Most finite microscope objectives |
| `M25 x 0.75 objective (QM42)` | female | M25 × 0.75 | Leica / Nikon objectives |
| `M42 x 1 male - Pentax bellows / helicoid (QM42)` | male | M42 × 1 | Screws into an M42 bellows, helicoid or extension tube |
| `T2 male - M42 x 0.75 (QM42)` | male | M42 × 0.75 | T2 accessories |

Parameters:

- `thread_clearance`: diametral clearance of the lens thread. Default 0.15 mm, which reproduces the tested M39 adapter. Calibrate with the [thread test rings](../test_coupons/README.md).
- `hub_h`: raises the lens register above the receptor seat face (e.g. to set an objective's parfocal distance). The console prints where the lens flange / objective shoulder sits.
- `bore_d_set`: clear bore under the thread (automatic = as large as the spigot walls allow, Ø35.4 for QM42).
- `orientation`: `spigot_down` (as the tested adapter) or `lens_down` (lens face on the bed: the flange underside, which is the seat reference, prints as a top surface).

## Receptor

Use `parts/cage_plates/lens_cage_plate.scad` with one of the QM presets:

- `50 mm QM42 receptor, V rod seats (EPI style)`
- `60 mm QM42 receptor, V rod seats` (no front bellows recess: the flange does not fit in the 60 mm recess)
- `100 mm QM42 receptor, V rod seats` (flange seats on the front recess floor)

Receptor options (section *Lens mount*): `qm_screw_side`, `qm_fixing` (`insert` Ø5.4 hole, or captive `nut` dropped in from the seat face, outside the flange), `qm_locate` (`bore`: tight Ø42.04 bore as tested; `pins`: two Ø3 dowel pins opposite the screw at ±50° and a Ø42.3 bore, so the centering no longer depends on how the bore prints). The console prints the lock screw length (M4 setscrew).

## Hardware

- Receptor: one M4 heat-set insert (or M4 nut) and one M4 setscrew (length printed in the console: M4 × 14 on the 50 mm plate). Optional: two Ø3 × 10 dowel pins.
- Adapter: none.
