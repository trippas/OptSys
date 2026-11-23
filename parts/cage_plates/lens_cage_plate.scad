// =====================================================================
//  OptSys - lens cage plate
//
//  Parametric cage plate - lens mount with a thread for a retaining
//  ring (or a QM quick-mount receptor for lens adapters), recess for a
//  magnetic bellows (both faces) and compliant clamps for 4 steel rods
//  (V rod seats).
//
//  Works in OpenSCAD 2021.01+, but use a recent development snapshot
//  with the Manifold backend: rendering is MUCH faster.
//
//  Multi-material: export part="rigid" and part="tpu" separately
//  (same origin) and load them in the slicer as ONE object with two
//  parts, assigning PLA/PETG to "rigid" and TPU95A to "tpu".
//
//  Coordinates: plate from z=0 to z=plate_t. The z=plate_t face is the
//  "front" (thread side, nut slots open on this face).
//
//  Shared code (threads, chamfers, standards, ...) lives in ../../lib.
// =====================================================================

use <../../lib/optsys.scad>

/* [Output] */
// What to generate
part = "assembly"; // [assembly:Assembly (view), rigid:Rigid (PLA/PETG), tpu:Flexible (TPU95A), single:Single part 1 material, ring:Retaining ring]
// Which zones are printed in TPU
tpu_mode = "hinge"; // [none:None (1 material), hinge:Hinges only, hinge_liner:Hinges + rod seat liner, arm:Whole arm]
// Show ghost rods in the assembly
show_rods = true;

/* [Standard] */
// System size. Every parameter marked "0 = from standard" takes the preset value; any number you enter overrides it.
standard = "100mm"; // [100mm:100 mm - Ø8 rods at 85 mm (original), 60mm:60 mm - Ø6 rods at 60 mm (Thorlabs 60 mm compatible), 50mm:50 mm - Ø6 rods at 50 mm (OptSys, QM42 quick mount)]

/* [Plate] */
// Plate width (0 = automatic from the rods)
plate_w_set = 0; // [0:0.5:300]
plate_t = 10; // [2:0.5:40]
// Outline edge chamfer (0 = none)
edge_chamfer = 0.5; // [0:0.1:3]

/* [Rods] */
// Radial wall of the arm around the rod (sets the automatic plate width)
arm_wall = 3.375; // [1:0.025:10]
// Rod diameter (0 = from standard)
rod_d_set = 0; // [0:0.05:30]
// Diametral clearance of the arm side of the rod seat (the body side is a V)
rod_clearance = 0.25; // [0:0.05:2]
// Distance from plate center to each rod axis (rod spacing = 2x) (0 = from standard)
rod_c_set = 0; // [0:0.05:200]
// Rod seat: the arm pushes the rod into a V on the body side, so it touches two lines along the whole thickness, without play (the plate cannot tilt on the rod).
// Included angle of the V seat (smaller = stiffer centering, but the arm must open more to snap the rod in)
rod_v_angle = 120; // [60:1:150]
// The body face continues this far past the upper V contact before the rod opening
rod_v_margin = 0.3; // [0:0.05:2]

/* [Compliant clamp] */
// Width of the slot between arm and body
slot_w = 2; // [0.5:0.1:6]
// Hinge height |y| (0 = from standard)
hinge_y_set = 0; // [0:0.1:100]
// Hinge neck thickness in rigid material
hinge_w = 2; // [0.5:0.1:8]
// Width of the relief notch cut from the outer edge
notch_w = 2; // [0.5:0.1:6]
// Entry radius of the relief notch
notch_entry_r = 1; // [0:0.1:3]
// Arm tip angle from horizontal (smaller = wraps more around the rod -> snap fit)
tip_ang = 15; // [-60:1:90]
// Fillet between slot and rod seat
seat_fillet = 0.94; // [0:0.02:3]
// Body corner radius next to the rod
body_corner_r = 2; // [0:0.1:6]

/* [Clamp screw] */
// Y distance between rod axis and screw axis (0 = from standard)
screw_offset_set = 0; // [0:0.1:50]
// Screw hole diameter (M3 -> 3.5)
screw_hole = 3.5; // [1:0.05:10]
// How far the hole goes toward the center, measured from the rod axis
screw_end = 7.5; // [0:0.1:30]
// Counterbore for the screw head
head_d = 6; // [2:0.1:15]
head_depth = 3; // [0:0.1:10]
// Captive nut (M3: 5.5 across flats, 2.4 thick)
nut_af = 5.5; // [2:0.05:15]
nut_t = 2.4; // [1:0.05:8]
// Extra clearance of the nut slot
nut_clearance = 0; // [0:0.05:1]
// X distance from rod axis to nut center, inward (0 = from standard)
nut_x_off_set = 0; // [0:0.1:20]

/* [Magnetic bellows recess] */
// Bellows recess on the front face (thread side)
recess_front = true;
// Bellows recess on the back face
recess_back = true;
// Side of the recess floor square (0 = from standard)
recess_sq_set = 0; // [0:0.5:250]
// 45 deg chamfer of the square corners
recess_chamfer = 5; // [0:0.5:30]
recess_corner_r = 1; // [0:0.1:5]
// Recess depth
recess_depth = 1.5; // [0.2:0.1:5]
// Horizontal wall growth from floor to surface (= depth -> 45 deg)
recess_draft = 1.5; // [0:0.1:5]
// Pry notches (lobes) to remove the bellows (0 = from standard)
lobe_w_set = 0; // [0:0.5:60]
// Distance from center to the lobe end, at the floor (0 = from standard)
lobe_reach_set = 0; // [0:0.1:150]
// Notch corner radius (0 = from standard)
lobe_r_set = 0; // [0:0.1:20]
lobe_fillet = 2; // [0:0.1:6]
// Extra notch depth below the recess floor
lobe_extra_depth = 1; // [0:0.1:5]

/* [Post mount] */
// Captive M4 nut in the middle of one side, to attach the plate to a post with an M4 setscrew stud. Removes the recess notch on that side
post_mount = "none"; // [none:No mount, bottom:-Y side (bottom), top:+Y side (top), left:-X side (left), right:+X side (right)]
// Nut (M4: 7 across flats, 3.2 thick)
post_nut_af = 7; // [3:0.05:15]
post_nut_t = 3.2; // [1:0.05:8]
// Extra clearance of the nut slot
post_nut_clearance = 0.2; // [0:0.05:1]
// Distance from the edge to the nut center
post_nut_depth = 5; // [3:0.1:20]
// Clearance hole for the stud
post_hole_d = 4.5; // [2:0.05:8]
// How far the hole continues past the nut (auto-shortened if it would reach the thread)
post_hole_extra = 4; // [0:0.1:15]

/* [Magnets] */
magnet_enable = true;
// Magnet diameter (0 = from standard)
magnet_d_set = 0; // [0:0.1:30]
// Magnet position (+-x, +-y) (0 = from standard)
magnet_offset_set = 0; // [0:0.1:100]
// Through hole between both floors (only with a recess on both faces); otherwise blind from each recessed face. No recess = no magnets
magnet_through = true;
magnet_depth = 3; // [0.5:0.1:10]

/* [Lens mount] */
// thread: lens + retaining ring (section below). qm: quick-mount receptor for lens adapters (parts/quick_mount)
lens_mount = "thread"; // [thread:Lens + retaining ring thread, qm:QM quick-mount receptor]
// Quick-mount interface (lib/standards.scad)
qm = "QM42"; // [QM42:QM42 - Ø42 x 7 spigot, Ø50 flange (OptSys 10 mm plates with 1.5 mm recesses), QM42-EPI:QM42-EPI - Ø42 x 10 spigot (EPI plates without recess)]
// The seat face (flange underside) is placed so the lock screw is centered in the plate thickness: on the front recess floor if there is one, otherwise in a round flange pocket (needs plate_t = 10 for QM42 with 1.5 mm recesses)
// Diametral clearance of the flange pocket (only when the seat is below a face without recess)
qm_pocket_clearance = 0.6; // [0:0.05:2]
// Side of the QM lock screw (must differ from the post mount side)
qm_screw_side = "top"; // [top:+Y side (top), bottom:-Y side (bottom), left:-X side (left), right:+X side (right)]
// Lock screw fixing: heat-set insert at the edge, or captive nut dropped in from the seat face
qm_fixing = "insert"; // [insert:Heat-set insert, nut:Captive nut]
// Hole for the heat-set insert
qm_insert_d = 5.4; // [3:0.05:10]
qm_insert_l = 8; // [3:0.5:20]
// Centering: tight bore (spigot pushed against the bore wall) or two steel dowel pins opposite the screw (looser bore)
qm_locate = "bore"; // [bore:Tight bore, pins:Two dowel pins]
// Diametral bore clearance (0 = automatic: 0.04 with a tight bore, 0.3 with pins)
qm_bore_clearance_set = 0; // [0:0.01:1]
// Dowel pin diameter and its hole (press fit: adjust to your printer)
qm_pin_d = 3; // [1.5:0.1:6]
qm_pin_hole_d = 3; // [1.5:0.05:6]
// Angle of each pin from the side opposite the screw
qm_pin_a = 50; // [20:1:80]

/* [Lens and thread] */
// Lens diameter: aperture, thread and retaining ring are derived from it (0 = from standard)
lens_d_set = 0; // [0:0.05:200]
// Radial width of the ledge the lens rests on (aperture = lens_d - 2x)
lens_ledge = 1.5; // [0.2:0.1:10]
// Manual clear aperture (0 = automatic)
aperture_d_set = 0; // [0:0.05:200]
// Height of the cylindrical lip below the seat cone
lip_h = 0.5; // [0:0.1:5]
thread_enable = true;
// Minimum radial margin between lens and nominal thread diameter (thread is rounded up to the next whole mm)
thread_margin = 2; // [0.5:0.1:10]
// Manual nominal thread diameter (0 = automatic: lens_d=60 -> M64)
thread_d_set = 0; // [0:0.5:250]
thread_pitch = 1.5; // [0.25:0.05:4]
// Diametral thread clearance (radial play, split between plate and ring)
thread_clearance = 0.2; // [0:0.05:1]
// Axial thread clearance: extra play along Z between plate and ring flanks (split between both), without loosening the radial engagement. Printed flat, the flanks are 30 deg from the bed: layer steps and sag land there. Max = pitch / 2
thread_z_clearance = 0.25; // [0:0.05:2]

/* [TPU interfaces] */
// Hinge neck thickness when printed in TPU (TPU is ~50x softer)
tpu_hinge_w = 3; // [0.5:0.1:10]
// Half-height of the TPU block around the hinge (0 = from standard)
tpu_block_h_set = 0; // [0:0.1:15]
// Dovetails anchoring TPU <-> rigid
dovetail_root = 2.5; // [0.5:0.1:10]
dovetail_tip = 3.5; // [0.5:0.1:12]
dovetail_h = 2; // [0.5:0.1:8]
// TPU liner on the arm side of the rod seat
liner_t = 1; // [0.2:0.1:4]
// Radial interference of the liner (preload on the rod)
liner_preload = 0.15; // [0:0.01:1]
liner_keys = 3;

/* [Retaining ring] */
// Ring height (cannot exceed the thread length)
ring_h = 3; // [0.5:0.1:20]
// Radial overlap of the ring on the lens edge (inner diameter = lens_d - 2x)
ring_overlap = 2; // [0:0.1:10]
// Manual inner diameter (0 = automatic)
ring_id_set = 0; // [0:0.05:200]
ring_slot_w = 3; // [0:0.1:15]
ring_slot_d = 1.5; // [0:0.1:10]
// 45 deg chamfer on both ends of the ring thread (removes the elephant foot and the thin start of the thread)
ring_chamfer = 0.5; // [0:0.1:1.5]

/* [Quality] */
$fn = 96;
// Thread segments per turn
thread_fn = 180;
// Thread samples per pitch along Z
thread_zres = 16;
// Steps of the outline chamfer (5 -> 0.1 mm, finer than a layer: invisible when printed).
// 0 = exact via minkowski: ~4x slower and may leave zero-volume slivers in the mesh.
chamfer_steps = 5;

/* [Hidden] */
eps = 0.01;

// ---------------------------------------------------------------------
// Presets per standard: std(value_100, value_60, value_50)
// ---------------------------------------------------------------------
// str() because the Customizer may pass the value as a number or as text
is60 = str(standard) == "60mm" || str(standard) == "60";
is50 = str(standard) == "50mm" || str(standard) == "50";
function std(v100, v60, v50) = is60 ? v60 : is50 ? v50 : v100;
function pick(set, v100, v60, v50) = set > 0 ? set : std(v100, v60, v50);

rod_d         = pick(rod_d_set,         cage_rod_d("100mm"), cage_rod_d("60mm"), cage_rod_d("50mm"));
rod_c         = pick(rod_c_set,         cage_rod_spacing("100mm") / 2, cage_rod_spacing("60mm") / 2, cage_rod_spacing("50mm") / 2);
lens_d        = pick(lens_d_set,        60,   38.1, 25.4);   // 60 mm: Ø1.5", 50 mm: Ø1"
hinge_y       = pick(hinge_y_set,       17.5, 14.5, 10.6);
nut_x_off     = pick(nut_x_off_set,     4.5,  3.5,  3.5);
recess_sq     = pick(recess_sq_set,     70,   47,   37);
lobe_w        = pick(lobe_w_set,        14,   10,   6);
lobe_reach    = pick(lobe_reach_set,    45,   31.5, 26);
lobe_r        = pick(lobe_r_set,        3,    2.5,  2);
magnet_d      = pick(magnet_d_set,      6,    5,    4);
magnet_offset = pick(magnet_offset_set, 26.5, 18.3, 14);
tpu_block_h   = pick(tpu_block_h_set,   4,    4,    3);

// ---------------------------------------------------------------------
// Derived values
// ---------------------------------------------------------------------
// Lens -> aperture, thread and ring
aperture_d = aperture_d_set > 0 ? aperture_d_set : lens_d - 2 * lens_ledge;
thread_d   = thread_d_set   > 0 ? thread_d_set   : ceil(lens_d + 2 * thread_margin);
thread_D1  = thread_minor_d(thread_d, thread_pitch);   // minor diameter (crests of the internal thread)
ring_id    = ring_id_set    > 0 ? ring_id_set    : lens_d - 2 * ring_overlap;

seat_r   = (rod_d + rod_clearance) / 2;
plate_w  = plate_w_set > 0 ? plate_w_set : 2 * (rod_c + seat_r + arm_wall);
arm_r    = plate_w / 2 - rod_c;            // outer radius of the arm around the rod
screw_offset = screw_offset_set > 0 ? screw_offset_set : arm_r;
big      = 3 * plate_w;
tip_r    = (arm_r - seat_r) / 2;
use_tpu  = (tpu_mode != "none") && (part != "single");
neck_w   = use_tpu ? tpu_hinge_w : hinge_w;
notch_cx = rod_c + slot_w / 2 + neck_w + notch_w / 2;
screw_y  = rod_c - screw_offset;
screw_z  = plate_t / 2;
chan_x0  = rod_c - screw_end;
nut_x    = rod_c - nut_x_off;
nut_ac   = nut_af / cos(30);
nut_z0   = screw_z - nut_ac / 2;
any_recess = recess_front || recess_back;
magnets_on = magnet_enable && any_recess;
z_fb     = recess_back  ? recess_depth : 0;                  // back recess floor (or back face)
z_ft     = recess_front ? plate_t - recess_depth : plate_t;  // front recess floor (or front face)
z_ct     = z_fb + lip_h + (lens_d - aperture_d) / 2;   // top of the seat cone
thread_len = z_ft - z_ct;
// quick-mount receptor
qm_on    = lens_mount == "qm";
qm_bc    = qm_bore_clearance_set > 0 ? qm_bore_clearance_set : qm_locate == "pins" ? 0.3 : 0.04;
qm_angle = qm_screw_side == "right" ? 0 : qm_screw_side == "top" ? 90 : qm_screw_side == "left" ? 180 : 270;
qm_seat_z = min(z_ft, plate_t / 2 + qm_screw_depth(qm));   // lock screw centered in the thickness when possible
qm_zs    = qm_seat_z - qm_screw_depth(qm);
qm_pocket = qm_on && qm_seat_z < z_ft - 1e-6;   // the flange sits in its own round pocket
qm_pocket_r = (qm_flange_d(qm) + qm_pocket_clearance) / 2;
// radius of the central feature (thread or QM bore), for the interference checks
center_r = qm_on ? qm_d(qm) / 2 + qm_bc / 2 : (thread_d + thread_clearance) / 2;
// rod seat (V)
open_x0  = rod_c - rod_d / 2 * sin(rod_v_angle / 2) + rod_v_margin;   // left edge of the rod opening

screw_len = (plate_w / 2 - head_depth) - (nut_x - nut_t / 2) + 1.5;
echo(str("Recommended clamp screw: M3 x ", ceil(screw_len / 2) * 2, " (minimum length ", screw_len, " mm)"));
if (!qm_on) echo(str("Lens Ø", lens_d, " -> aperture Ø", aperture_d, ", thread M", thread_d, "x", thread_pitch, " (usable length ", thread_len, " mm), ring ID Ø", ring_id,
                     ". Ring play: radial ", thread_clearance, " mm, axial ", round(100 * (thread_z_clearance + 2 * thread_clearance * tan(30))) / 100, " mm"));
if (qm_on) echo(str("QM receptor ", qm, ": bore Ø", 2 * center_r, " (", qm_locate == "pins" ? str("2 dowel pins Ø", qm_pin_d, " x ", plate_t, " mm") : "tight bore", "), seat face at z = ", qm_seat_z,
                    ", lock screw ", qm_screw(qm), " x ", ceil(qm_screw_len(qm, plate_w / 2) / 2) * 2, " setscrew on the ", qm_screw_side, " side (",
                    qm_fixing == "insert" ? str("heat-set insert, hole Ø", qm_insert_d) : str(qm_screw(qm), " nut from the front face"), ")",
                    qm_pocket ? str(", flange pocket Ø", 2 * qm_pocket_r, " x ", plate_t - qm_seat_z, " mm") : "",
                    ", spigot ", qm_seat_z - qm_l(qm) >= z_fb - 1e-6 ? str("ends ", qm_seat_z - qm_l(qm) - z_fb, " mm above the back floor") : str("sticks out ", z_fb - (qm_seat_z - qm_l(qm)), " mm past the back floor")));
if (qm_on && abs(qm_zs - plate_t / 2) > 0.01)
    echo(str("Note: the ", qm, " lock screw is ", plate_t / 2 - qm_zs, " mm off the plate center (seat face on the front recess floor at z = ", z_ft,
             "). Centered with ", qm == "QM42-EPI" ? "plate_t = 10 and no front recess" : str("plate_t = ", 2 * (qm_screw_depth(qm) + recess_depth), " (1.5 mm recesses)")));
echo(str("V rod seats ", rod_v_angle, " deg: the rod snaps past the arm tip with ~", rod_d - (rod_c + seat_r * cos(tip_ang) - open_x0), " mm interference (loosen the clamp screw to fit it)"));
magnet_clear = magnet_offset * sqrt(2) - magnet_d / 2 - center_r;
assert(aperture_d < lens_d, "The aperture must be smaller than the lens");
assert(qm_on || thread_D1 > lens_d + 0.5, str("The lens does not fit through the thread: the minor diameter (", thread_D1, ") must exceed lens_d + 0.5. Increase thread_margin or thread_d_set"));
assert(!magnets_on || magnet_clear >= 1, str("Thread M", thread_d, " cuts into the magnet holes (wall ", magnet_clear, " mm). Max lens with these magnets ~", floor(2 * (magnet_offset * sqrt(2) - magnet_d / 2 - 1) - thread_clearance) - 2 * thread_margin, " mm: move magnet_offset or use a smaller lens"));
assert(qm_on || !thread_enable || ring_h <= thread_len, str("The ring (", ring_h, " mm) is taller than the thread (", thread_len, " mm)"));
assert(qm_on || ring_id < lens_d - 0.5, "The ring does not overlap the lens: increase ring_overlap");
assert(qm_on || thread_z_clearance <= thread_pitch / 2 + 1e-9, str("thread_z_clearance is larger than half the pitch (", thread_pitch / 2, ")"));
assert(qm_on || 2 * ring_chamfer < ring_h, "ring_chamfer is too large for ring_h");
echo(str("Rod spacing: ", 2 * rod_c, " mm"));
assert(qm_on || thread_len > thread_pitch, "No height left for the thread: check plate_t / recess_depth / lip_h");
// --- post mount ---
post_on    = post_mount != "none";
post_angle = post_mount == "right" ? 0 : post_mount == "top" ? 90 : post_mount == "left" ? 180 : 270;
lobe_angles = [for (a = [0, 90, 180, 270]) if ((!post_on || a != post_angle) && (!qm_on || a != qm_angle)) a];
post_nut_ac   = post_nut_af / cos(30);
post_slot_in  = plate_w / 2 - post_nut_depth - (post_nut_t + post_nut_clearance) / 2;   // inner face of the slot (from the center)
post_hole_end = max(plate_w / 2 - (post_nut_depth + post_nut_t / 2 + post_hole_extra), center_r + 1.5);
if (post_on) echo(str("Post mount: M4 nut on side ", post_mount, ". M4 stud ", ceil(post_nut_depth + post_nut_t / 2 + 1.5 + 6), " to ", floor(plate_w / 2 - post_hole_end + 6), " mm long (with 6 mm threaded into the post)"));

// --- interference checks between features (for when presets are changed) ---
hinge_reach = use_tpu ? tpu_block_h + dovetail_h : notch_w / 2;
recess_top_half = recess_sq / 2 + recess_draft;
nut_in_x = nut_x - (nut_t + nut_clearance) / 2;
nut_in_y = screw_y - (nut_af + nut_clearance) / 2;
echo(str("Standard ", standard, ": plate ", plate_w, " mm, Ø", rod_d, " rods at ", 2 * rod_c, " mm, ", magnets_on ? str("Ø", magnet_d, " magnets at ±", magnet_offset) : "no magnets", ", recess ", recess_front && recess_back ? "on both faces" : recess_front ? "front only" : recess_back ? "back only" : "none"));
assert(!any_recess || nut_in_x - recess_top_half >= 0.2, str("The nut slot touches the recess: reduce recess_sq or nut_x_off (margin ", nut_in_x - recess_top_half, ")"));
assert(!any_recess || (nut_in_x + nut_in_y - (recess_sq - recess_chamfer + recess_draft * sqrt(2))) / sqrt(2) >= 0.5, "The recess corner touches the nut slot: increase recess_chamfer or reduce recess_sq");
assert(nut_x + nut_t / 2 + 0.8 <= rod_c - slot_w / 2, "The nut is too close to the clamp slot: increase nut_x_off");
// free distance between the thread and the nearest clamp feature (nut, screw, slot, TPU block)
clamp_clear = min(norm([nut_in_x, nut_in_y]), norm([chan_x0, screw_y - screw_hole / 2]),
                  norm([rod_c - slot_w / 2, hinge_y - slot_w / 2]), norm([rod_c, hinge_y - hinge_reach - dovetail_h]))
              - center_r;
assert(!post_on || post_slot_in - center_r >= 1.5, str("The post nut is too close to the thread / QM bore: reduce post_nut_depth (wall ", post_slot_in - center_r, " mm)"));
assert(!post_on || !recess_front || post_slot_in - recess_top_half >= 0.5, "The post nut slot touches the front recess: reduce post_nut_depth");
assert(!post_on || plate_t / 2 - post_nut_ac / 2 - 0.1 >= 0.6, "The plate is too thin for the post nut");
assert(clamp_clear >= 1.5, str(qm_on ? str("The ", qm, " bore") : str("Thread M", thread_d), " is too close to the clamp (wall ", clamp_clear, " mm): use a smaller lens"));
assert(qm_on || !recess_front || thread_d / 2 + thread_clearance / 2 + 1 <= recess_sq / 2, str("The M", thread_d, " ring does not fit through the recess floor (", recess_sq, "): use a smaller lens or a larger recess_sq"));
assert(!magnets_on || magnet_offset + magnet_d / 2 + 0.5 <= recess_sq / 2 && (recess_sq - recess_chamfer - 2 * magnet_offset) / sqrt(2) >= magnet_d / 2 + 0.5, "The magnets fall outside the recess floor: check magnet_offset / magnet_d");
assert(!any_recess || hinge_y - hinge_reach - 1 >= lobe_w / 2 + recess_draft, "The side recess notches touch the hinge: reduce lobe_w or increase hinge_y");
assert(hinge_y + hinge_reach + 1 <= screw_y - screw_hole / 2, "The hinge is too close to the screw: reduce hinge_y or tpu_block_h");
assert(!any_recess || lobe_reach + recess_draft + 1.5 <= plate_w / 2, "The notches come too close to the edge: reduce lobe_reach");
assert(notch_cx + notch_w / 2 < plate_w / 2, "The hinge does not fit: reduce tpu_hinge_w / hinge_w");
// V rod seat
assert(rod_d / 2 * sin(rod_v_angle / 2) >= slot_w / 2 + seat_fillet + 0.2, str("The lower V contact falls on the clamp slot: use a larger rod_v_angle (min ~", ceil(2 * asin(min(1, (slot_w / 2 + seat_fillet + 0.2) / (rod_d / 2)))), " deg) or a smaller slot_w"));
// quick-mount receptor
assert(!qm_on || part != "ring", "There is no retaining ring in QM mode: the lens goes in a QM adapter (parts/quick_mount)");
assert(!qm_on || !recess_front || qm_flange_d(qm) <= recess_sq - 1, str("The ", qm, " flange (Ø", qm_flange_d(qm), ") does not fit on the front recess floor (", recess_sq, "): disable recess_front or enlarge recess_sq"));
assert(!qm_on || !post_on || post_angle != qm_angle, "The QM lock screw and the post mount are on the same side: change qm_screw_side or post_mount");
assert(!qm_on || qm_fixing != "insert" || qm_zs - qm_insert_d / 2 >= 0.6 - 1e-6, "The plate is too thin below the seat face for the QM insert: increase plate_t or disable recess_front");
assert(!qm_on || qm_fixing != "nut" || qm_zs - nut_ac(nut_af(qm_screw(qm))) / 2 - 0.1 >= 0.6, "The plate is too thin below the seat face for the QM nut: increase plate_t or use the insert");
assert(!qm_on || qm_fixing != "nut" || qm_nut_r(qm) + (nut_t(qm_screw(qm)) + 0.2) / 2 + 1.2 <= plate_w / 2, "No room for the QM nut between the flange and the edge: use the insert");
assert(!qm_on || qm_fixing != "insert" || qm_insert_l <= plate_w / 2 - center_r - 1, "qm_insert_l is longer than the wall between the bore and the edge");
assert(!qm_on || qm_zs + clearance_d(qm_screw(qm)) / 2 <= z_ft - 0.6 && qm_zs - clearance_d(qm_screw(qm)) / 2 >= z_fb + 0.6 - 1e-6,
       "The QM lock screw hole breaks into a bellows recess: use plate_t = 10 with 1.5 mm recesses (QM42) or no recesses and plate_t = 10 (QM42-EPI)");
// flange pocket (front face without recess): walls to the clamp features that reach the front face
qm_pocket_clear = min(norm([nut_in_x, nut_in_y]), norm([rod_c - slot_w / 2, hinge_y - slot_w / 2]), norm([rod_c, hinge_y - hinge_reach - dovetail_h]),
                      post_on ? post_slot_in : 1e9) - qm_pocket_r;
assert(!qm_pocket || qm_pocket_clear >= 1, str("The ", qm, " flange pocket (Ø", 2 * qm_pocket_r, ") is too close to the clamp nuts / slots (wall ", qm_pocket_clear,
       " mm): this plate is too small for a recessed flange, use qm = QM42-EPI with plate_t = 10 and no front recess"));
assert(!qm_on || !magnets_on || !recess_front || magnet_offset * sqrt(2) - magnet_d / 2 >= qm_flange_d(qm) / 2 + 0.5, "The magnets fall under the QM flange: move magnet_offset");

// ---------------------------------------------------------------------
// 2D plate outline (+x,+y quadrant; mirrored to all 4)
// ---------------------------------------------------------------------
module arm_top2d() {
    translate([rod_c, rod_c]) {
        annular_sector2d(seat_r, arm_r, -1, tip_ang);
        rotate(tip_ang) translate([seat_r + tip_r, 0]) circle(tip_r);
    }
}

module corner_void2d() {
    difference() {
        union() {
            // rod seat + slot, filleted where they meet
            closing2d(seat_fillet) union() {
                translate([rod_c, rod_c]) {
                    // body side: V with its bisector along -X (the arm pushes the rod
                    // toward the body), limited to 1 mm around the rod
                    intersection() { rotate(-90) rod_seat_v2d(rod_d, rod_v_angle, 0.01); circle(rod_d / 2 + 1); }
                    // arm side: round seat
                    intersection() { circle(seat_r); translate([0, -seat_r - 1]) square(2 * seat_r + 2); }
                }
                translate([rod_c - slot_w / 2, hinge_y]) square([slot_w, rod_c - hinge_y]);
                translate([rod_c, hinge_y]) circle(slot_w / 2);
            }
            // opening above the rod axis
            translate([open_x0, rod_c]) square([big, big]);
            // body corner rounding
            translate([open_x0 - body_corner_r, plate_w / 2 - body_corner_r])
                difference() { square([body_corner_r + eps, body_corner_r + 1]); circle(body_corner_r); }
        }
        arm_top2d();
    }
    // hinge relief notch, with rounded entry
    intersection() {
        closing2d(notch_entry_r) union() {
            translate([notch_cx, hinge_y - notch_w / 2]) square([big, notch_w]);
            translate([notch_cx, hinge_y]) circle(notch_w / 2);
            translate([plate_w / 2, hinge_y - 4 * notch_w]) square([big, 8 * notch_w]);
        }
        translate([0, hinge_y - 3 * notch_w]) square([big, 6 * notch_w]);
    }
}

module outline2d() {
    difference() {
        square(plate_w, center = true);
        for (mx = [0, 1], my = [0, 1]) mirror([mx, 0]) mirror([0, my]) corner_void2d();
    }
}

// ---------------------------------------------------------------------
// Bellows recess
// ---------------------------------------------------------------------
module lobe2d() {
    hull() {
        for (s = [-1, 1]) translate([lobe_reach - lobe_r, s * (lobe_w / 2 - lobe_r)]) circle(lobe_r);
        translate([recess_sq / 2 - 5, -lobe_w / 2]) square([1, lobe_w]);
    }
}

module recess_floor2d() {
    closing2d(lobe_fillet) union() {
        offset(r = recess_corner_r) offset(delta = -recess_corner_r) chamfered_square2d(recess_sq, recess_chamfer);
        for (a = lobe_angles) rotate(a) lobe2d();
    }
}

module recess_top_cut() {
    translate([0, 0, plate_t - recess_depth])
        union() {
            drafted_convex(recess_depth, recess_draft)
                offset(r = recess_corner_r) offset(delta = -recess_corner_r) chamfered_square2d(recess_sq, recess_chamfer);
            for (a = lobe_angles) rotate(a) {
                drafted_convex(recess_depth, recess_draft) lobe2d();
                if (lobe_fillet > 0) for (s = [0, 1]) mirror([0, s, 0]) {
                    P = [recess_sq / 2, lobe_w / 2];
                    c = P + [lobe_fillet, lobe_fillet];
                    n = max(4, ceil($fn / 4));
                    for (j = [0:n - 1]) let(a0 = 180 + 90 * j / n, a1 = 180 + 90 * (j + 1) / n)
                        drafted_convex(recess_depth, recess_draft)
                            polygon([P, c + lobe_fillet * [cos(a0), sin(a0)], c + lobe_fillet * [cos(a1), sin(a1)]]);
                }
            }
        }
    // notches: vertical walls. Shrunk 0.02 mm and raised 0.2 mm into the recess
    // so they share no exact edges with the sloped wall (avoids mesh slivers)
    translate([0, 0, plate_t - recess_depth - lobe_extra_depth])
        linear_extrude(lobe_extra_depth + 0.2)
            offset(delta = -0.02) difference() { recess_floor2d(); square(recess_sq, center = true); }
}

// ---------------------------------------------------------------------
// Plate
// ---------------------------------------------------------------------
// M4 nut + hole for the post stud. Built on the -Y side and rotated to the chosen side.
module post_features() {
    if (post_on) rotate(post_angle - 270) {
        translate([0, -plate_w / 2 - 1, plate_t / 2]) rotate([-90, 0, 0])
            cylinder(d = post_hole_d, h = plate_w / 2 + 1 - post_hole_end, $fn = 48);
        translate([-(post_nut_af + post_nut_clearance) / 2, -post_slot_in - (post_nut_t + post_nut_clearance), plate_t / 2 - post_nut_ac / 2 - 0.1])
            cube([post_nut_af + post_nut_clearance, post_nut_t + post_nut_clearance, plate_t]);
    }
}

module screw_features() {
    mirror4() {
        // screw clearance hole (round along its whole length)
        translate([chan_x0, screw_y, screw_z]) rotate([0, 90, 0]) cylinder(d = screw_hole, h = plate_w / 2 - chan_x0 + 1, $fn = 48);
        // head counterbore
        translate([plate_w / 2 - head_depth, screw_y, screw_z]) rotate([0, 90, 0]) cylinder(d = head_d, h = head_depth + 1);
        // nut slot (open on the front face)
        translate([nut_x - (nut_t + nut_clearance) / 2, screw_y - (nut_af + nut_clearance) / 2, nut_z0])
            cube([nut_t + nut_clearance, nut_af + nut_clearance, plate_t]);
    }
}

// Outer body: outline + chamfers + screws (no central features)
module outline_body() {
    difference() {
        chamfered_extrude(plate_t, edge_chamfer, chamfer_steps, eps) outline2d();
        screw_features();
        post_features();
    }
}

module central_cuts() {
    // recess(es)
    // render(): the recess is hundreds of hull()s; without it the F5 preview gives up
    if (recess_front) render(convexity = 4) recess_top_cut();
    if (recess_back) translate([0, 0, plate_t / 2]) mirror([0, 0, 1]) translate([0, 0, -plate_t / 2]) render(convexity = 4) recess_top_cut();
    if (qm_on)
    {
        qm_receptor_cut(qm, qm_seat_z, plate_w / 2, qm_angle, qm_bc, qm_fixing, qm_insert_d, qm_insert_l, 0.2,
                        qm_locate, qm_pin_d, qm_pin_hole_d, qm_pin_a, 0.4, -1, nut_top = plate_t);
        // round pocket for the flange, so the seat face (and the screw) can sit below a face without recess
        if (qm_pocket) {
            translate([0, 0, qm_seat_z]) cylinder(r = qm_pocket_r, h = plate_t - qm_seat_z + 1);
            translate([0, 0, plate_t - 0.4]) cylinder(r1 = qm_pocket_r, r2 = qm_pocket_r + 0.4 + 2 * eps, h = 0.4 + eps);
        }
    }
    else lens_cuts();

    // magnets
    if (magnets_on) for (sx = [-1, 1], sy = [-1, 1]) translate([sx * magnet_offset, sy * magnet_offset, 0]) {
        if (magnet_through && recess_front && recess_back) translate([0, 0, z_fb - eps]) cylinder(d = magnet_d, h = z_ft - z_fb + 2 * eps);
        else {
            if (recess_front) translate([0, 0, z_ft - magnet_depth]) cylinder(d = magnet_d, h = magnet_depth + eps);
            if (recess_back) translate([0, 0, z_fb - eps]) cylinder(d = magnet_d, h = magnet_depth + eps);
        }
    }
}

// aperture + lip + seat cone + thread (lens_mount = "thread")
module lens_cuts() {
    translate([0, 0, -1]) cylinder(d = aperture_d, h = z_fb + lip_h + 1 + eps);
    translate([0, 0, z_fb + lip_h]) cylinder(d1 = aperture_d, d2 = lens_d, h = (lens_d - aperture_d) / 2 + eps);
    // thread
    if (thread_enable) {
        translate([0, 0, z_ct]) internal_thread_cutter(thread_d, thread_pitch, thread_len + 0.5, thread_clearance, thread_fn, thread_zres, thread_z_clearance / 2);
        // entry chamfer where the thread exits (front face or front recess floor)
        translate([0, 0, z_ft - 0.6]) cylinder(d1 = thread_d + thread_clearance, d2 = thread_d + thread_clearance + 1.2 + 2 * eps, h = 0.6 + eps);
    } else {
        translate([0, 0, z_ct - eps]) cylinder(d = lens_d + 0.4, h = plate_t);
    }
}

module plate() { difference() { render(convexity = 4) outline_body(); central_cuts(); } }

// ---------------------------------------------------------------------
// TPU zones (+x,+y quadrant) - must stay clear of the central
// features: the TPU part is computed as outline_body() ∩ region.
// ---------------------------------------------------------------------
module hinge_region2d(with_top = true) {
    y0 = hinge_y - tpu_block_h;
    y1 = hinge_y + tpu_block_h;
    translate([rod_c, y0]) square([arm_r + 1, y1 - y0]);
    if (with_top) translate([(rod_c + slot_w / 2 + plate_w / 2) / 2, y1]) dovetail2d(dovetail_root, dovetail_tip, dovetail_h, true);
    translate([(rod_c + plate_w / 2) / 2, y0]) dovetail2d(dovetail_root, dovetail_tip, dovetail_h, false);
}

liner_a0 = -acos((slot_w / 2 + seat_fillet) / (seat_r + seat_fillet)) + 5;   // starts past the slot fillet
function liner_angles() = [for (k = [0:liner_keys - 1]) liner_a0 + 10 + (tip_ang - 10 - liner_a0 - 10) * (liner_keys == 1 ? 0.5 : k / (liner_keys - 1))];

module liner_region2d() {
    translate([rod_c, rod_c]) {
        annular_sector2d(seat_r - eps, seat_r + liner_t, liner_a0, tip_ang);
        for (a = liner_angles()) rotate(a)
            polygon([[seat_r + liner_t - eps, -0.6], [seat_r + liner_t + 1.2, -0.9], [seat_r + liner_t + 1.2, 0.9], [seat_r + liner_t - eps, 0.6]]);
    }
}

module liner_protrusion2d() {
    translate([rod_c, rod_c]) annular_sector2d(seat_r - liner_preload, seat_r + 0.05, liner_a0 + 1, tip_ang - 1);
}

module tpu_region2d() {
    if (tpu_mode == "hinge" || tpu_mode == "hinge_liner") hinge_region2d(true);
    if (tpu_mode == "hinge_liner") liner_region2d();
    if (tpu_mode == "arm") { hinge_region2d(false); translate([rod_c, hinge_y]) square([big, big]); }
}

module tpu_region3d() {
    translate([0, 0, -1]) linear_extrude(plate_t + 2)
        for (mx = [0, 1], my = [0, 1]) mirror([mx, 0]) mirror([0, my]) tpu_region2d();
}

module rigid_part() {
    if (use_tpu) difference() { plate(); tpu_region3d(); }
    else plate();
}

module tpu_part() {
    if (use_tpu) union() {
        intersection() { outline_body(); tpu_region3d(); }
        if (tpu_mode == "hinge_liner")
            translate([0, 0, edge_chamfer]) linear_extrude(plate_t - 2 * edge_chamfer)
                for (mx = [0, 1], my = [0, 1]) mirror([mx, 0]) mirror([0, my]) liner_protrusion2d();
    }
}

// ---------------------------------------------------------------------
// Retaining ring (external thread)
// ---------------------------------------------------------------------
module retaining_ring() {
    difference() {
        external_thread(thread_d, thread_pitch, ring_h, thread_clearance, thread_fn, thread_zres, thread_z_clearance / 2);
        translate([0, 0, -1]) cylinder(d = ring_id, h = ring_h + 2);
        // 45 deg chamfers on both ends of the thread
        if (ring_chamfer > 0) for (top = [0, 1]) translate([0, 0, top * ring_h]) mirror([0, 0, top]) {
            ro = (thread_d - thread_clearance) / 2;
            difference() {
                translate([0, 0, -1]) cylinder(r = ro + 1, h = ring_chamfer + 1);
                translate([0, 0, -eps]) cylinder(r1 = ro - ring_chamfer, r2 = ro + eps, h = ring_chamfer + 2 * eps);
            }
        }
        for (a = [0, 180]) rotate(a) translate([ring_id / 2 - 1, -ring_slot_w / 2, ring_h - ring_slot_d]) cube([(thread_d - ring_id) / 2, ring_slot_w, ring_slot_d + 1]);
    }
}

// ---------------------------------------------------------------------
// Output
// ---------------------------------------------------------------------
if (part == "rigid") rigid_part();
else if (part == "tpu") tpu_part();
else if (part == "single") plate();
else if (part == "ring") retaining_ring();
else union() {
    color("SteelBlue") rigid_part();
    color("OrangeRed") render(convexity = 4) tpu_part();   // render(): keeps the preview from painting the whole plate orange
    if (show_rods) for (sx = [-1, 1], sy = [-1, 1]) %translate([sx * rod_c, sy * rod_c, -20]) cylinder(d = rod_d, h = plate_t + 40);
    if (show_rods && qm_on) %translate([0, 0, qm_seat_z]) qm_spigot_flange(qm);
}
