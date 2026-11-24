// =====================================================================
//  OptSys - printed cage bellows
//
//  Light-tight bellows between two OptSys cage plates, printed compressed
//  in three materials:
//    TPU   the bellows: flat sheets joined alternately at the outer and
//          inner edges (lib/bellows.scad)
//    PLA   sacrificial spacers in the gaps, pulled out after printing
//          (TPU does not bond to PLA)
//    PETG  end frames that drop into the magnetic bellows recess of the
//          plates, with pockets for the magnets (TPU bonds to PETG)
//  Export part = tpu, spacers and frames, load the three STLs as parts of
//  one object in the slicer and give each its own extruder.
//
//  Outline: an octagon (square with big 45 deg chamfers) that clears the
//  cage rods; the bore clears the lens or the QM42 flange, so the bellows
//  fits either face of a plate.
//
//  Coordinates: axis +Z, z = 0 on the mating face of the bottom end
//  (printed on the bed). The lower tier of each frame sits in the plate
//  recess; the upper tier rests on the plate face.
// =====================================================================

use <../../lib/optsys.scad>

/* [Output] */
// What to generate (export tpu, spacers and frames as separate STLs)
part = "assembly"; // [assembly:Assembly (view), tpu:TPU bellows, spacers:PLA spacers, frames:PETG frames]
// Cut the assembly in half to show the pleats
show_section = true;
// Show ghost rods in the assembly
show_rods = true;
// Show dimensions and key data in the preview (F5) only: never rendered or exported
show_dims = true;

/* [Standard] */
standard = "60mm"; // [60mm:60 mm (Ø6 rods at 60 mm), 100mm:OptSys 100 (Ø8 rods at 85 mm)]

/* [Length] */
// Distance between the plate faces with the bellows compressed (as printed)
length_min = 40; // [10:0.5:300]
// Wanted distance fully extended: checked against the estimate
length_max = 150; // [10:1:1000]
// Number of TPU sheets (0 = as many as fit in length_min)
sheets_set = 0; // [0:1:400]

/* [Ends] */
// Bottom end (on the bed)
end_bottom = "frame"; // [frame:PETG frame with magnets, flange:TPU flange (to glue onto another frame)]
// Top end
end_top = "frame"; // [frame:PETG frame with magnets, flange:TPU flange (to glue onto another frame)]

/* [Profile] */
// Outer width across the flats (0 = from standard)
outer_w_set = 0; // [0:0.5:300]
// Free bore, across the flats of the bore and in the frames (0 = from standard). Must pass the lens (or the QM42 flange, Ø46)
clear_d_set = 0; // [0:0.1:300]
// Minimum gap between the outline and the rods (the corner chamfer grows to keep it)
rod_margin = 1; // [0:0.1:5]
// Corner rounding of the octagon
corner_r = 2; // [0:0.1:10]

/* [Pleats] */
// Must match the slicer layer height
layer_h = 0.15; // [0.05:0.01:0.4]
// Must match the slicer first layer height
first_layer_h = 0.2; // [0.05:0.01:0.4]
// TPU sheet thickness in layers
sheet_layers = 2; // [1:1:10]
// Spacer (gap) thickness in layers
gap_layers = 3; // [1:1:10]
// Width of the TPU joint that closes each gap (2 lines with a 0.4 nozzle)
joint_w = 0.8; // [0.3:0.05:3]
// Usable opening of each gap, as a fraction of the sheet width (estimate: calibrate with the test coupon)
stretch = 0.3; // [0.05:0.01:1]

/* [Spacers] */
// Width of the slots that cut each spacer into 4 pieces
cut_w = 0.4; // [0.2:0.05:2]
// Also cut the corners off the spacers that open into the bore (8 pieces instead of 4), so every piece slides out flat. Without it the two long pieces must bow to come out through the bore
corner_cuts = true;

/* [Frames] */
// Height of the frame above the plate face
frame_top_h = 2; // [0.5:0.1:10]
// Clearance per side in the plate recess
frame_clearance = 0.2; // [0:0.05:1]
// The lower tier stops this short of the recess floor, so the frame rests on the plate face
recess_gap = 0.1; // [0:0.05:1]
// TPU flange thickness in layers (end = flange)
flange_layers = 6; // [2:1:40]

/* [Magnets] */
// Magnet diameter (0 = from standard)
magnet_d_set = 4; // [0:0.1:30]
magnet_h = 2.5; // [0.5:0.1:10]
// Diametral clearance of the pocket (press fit)
magnet_clearance = 0.15; // [0:0.05:1]

/* [Quality] */
// Segments of the round frame bore
bore_fn = 128; // [32:8:512]

/* [Hidden] */
eps = 0.01;

// ---------------------------------------------------------------------
// Standard
// ---------------------------------------------------------------------
std_name = str(standard) == "100mm" || str(standard) == "100" ? "100mm" : "60mm";
function std(v100, v60) = std_name == "100mm" ? v100 : v60;

outer_w   = outer_w_set > 0 ? outer_w_set : std(96, 70);
clear_d   = clear_d_set > 0 ? clear_d_set : std(62, 48);   // 60 mm: the user's widest lens is Ø47.5
rod_c     = cage_rod_spacing(std_name) / 2;
rod_d     = cage_rod_d(std_name);
recess_sq = cage_recess_sq(std_name);
recess_ch = cage_recess_chamfer(std_name);
recess_cr = cage_recess_corner_r(std_name);
recess_depth = cage_recess_depth(std_name);
magnet_d  = magnet_d_set > 0 ? magnet_d_set : cage_magnet_d(std_name);
magnet_offset = cage_magnet_offset(std_name);

// ---------------------------------------------------------------------
// Derived values
// ---------------------------------------------------------------------
// Octagon: square of half width a with 45 deg chamfers of leg c. The
// chamfer face lies at d = (2a - c) / sqrt(2) from the axis; it must clear
// the rods by rod_margin.
a      = outer_w / 2;
d_rod  = rod_c * sqrt(2) - rod_d / 2 - rod_margin;
c_out  = max(0, 2 * a - sqrt(2) * d_rod);
d_out  = (2 * a - c_out) / sqrt(2);
sheet_w = min(a, d_out) - clear_d / 2;          // sheet width (radial)
a_in   = a - sheet_w;
c_in   = c_out - (2 - sqrt(2)) * sheet_w;      // same chamfer faces, offset by the sheet width

lh = layer_h;
t  = sheet_layers * lh;
g  = gap_layers * lh;
pitch = t + g;

// End tiers, in whole layers. Bottom end: first layer + layer_h layers.
function zt(n) = n <= 0 ? 0 : first_layer_h + (n - 1) * lh;   // top of layer n (bottom end)
n_low = floor((recess_depth - recess_gap - first_layer_h) / lh + 1e-6) + 1;  // frame tier in the recess
n_up  = ceil(frame_top_h / lh - 1e-6);                                       // frame tier above the face
bot_frame = end_bottom == "frame";
top_frame = end_top == "frame";
// bottom end: mating face at z = 0, top of the end at z0
bot_low = bot_frame ? zt(n_low) : 0;                    // part below the plate face
z0      = bot_frame ? zt(n_low + n_up) : zt(flange_layers);
bot_up  = z0 - bot_low;                                 // part above the plate face (or flange)
// top end: all layers of layer_h
top_low = top_frame ? n_low * lh : 0;
top_up  = top_frame ? n_up * lh : flange_layers * lh;

n_fit  = floor((length_min - bot_up - top_up - t) / pitch + 1e-6) + 1;
n      = sheets_set > 0 ? sheets_set : n_fit;
stack_h = bellows_stack_h(n, t, g);
z_top   = z0 + stack_h;                     // bottom of the top end
total_h = z_top + top_up + top_low;
len_min = bot_up + stack_h + top_up;        // between plate faces, as printed
len_max = len_min + (n - 1) * (stretch * sheet_w - g);

n_pieces = ceil((n - 1) / 2) * (corner_cuts ? 8 : 4) + floor((n - 1) / 2) * 4;

// Magnets
pocket_d = magnet_d + magnet_clearance;
pocket_h = magnet_h + 0.1;
magnet_r = magnet_offset * sqrt(2);         // distance of the magnet centers from the axis
magnet_bore_wall = magnet_r - pocket_d / 2 - clear_d / 2;
frame_sq = recess_sq - 2 * frame_clearance;

// ---------------------------------------------------------------------
// Checks
// ---------------------------------------------------------------------
echo(str("Bellows ", std_name, ": outline ", outer_w, " mm (chamfer ", round(c_out * 10) / 10, "), bore ", clear_d,
         ", sheet ", round(sheet_w * 10) / 10, " mm wide; ", n, " sheets of ", t, " + gaps of ", g,
         " -> ", round(len_min * 10) / 10, " mm compressed, ~", round(len_max), " mm extended (stretch ", stretch, "); ",
         n - 1, " spacers in ", n_pieces, " pieces; print height ", round(total_h * 100) / 100));
assert(sheet_w >= 3, str("The sheets are only ", sheet_w, " mm wide: increase outer_w_set or reduce clear_d_set"));
assert(c_in >= 0, "The bore corners would stick out of the outline chamfers: reduce rod_margin or outer_w_set");
assert(n >= 2, str("No room for 2 sheets in length_min = ", length_min, ": increase length_min or use thinner frames"));
assert(sheets_set > 0 || len_min <= length_min + 1e-6, "Internal: compressed length above length_min");
assert(!bot_frame && !top_frame || pocket_h <= bot_low + bot_up - 0.6,
       str("The magnet pockets leave less than 0.6 mm of frame above them: increase frame_top_h or reduce magnet_h"));
assert(!bot_frame && !top_frame || magnet_offset + pocket_d / 2 + 0.5 <= frame_sq / 2,
       "The magnets fall outside the frame: check magnet_d_set");
if (len_max < length_max)
    echo(str("Note: estimated extension ~", round(len_max), " mm, below length_max = ", length_max,
             ": increase length_min (more sheets), use thinner sheets/gaps or a wider outline"));
if (clear_d < qm_flange_d("QM42") + 0.6)
    echo(str("Note: the bore (", clear_d, ") does not pass over a QM42 flange (Ø", qm_flange_d("QM42"), "): use this bellows on faces without a QM receptor"));
if ((bot_frame || top_frame) && magnet_bore_wall < 0)
    echo(str("Note: the magnet pockets open into the bore by ", round(-magnet_bore_wall * 100) / 100,
             " mm (the magnets are still held by the frame; glue them)"));
if (!bot_frame || !top_frame)
    echo("Note: lengths of flange ends are measured from the flange face");

// ---------------------------------------------------------------------
// 2D outlines
// ---------------------------------------------------------------------
module rounded2d(r) { if (r > 0) offset(r = r) offset(delta = -r) children(); else children(); }
module outer2d() { rounded2d(corner_r) chamfered_square2d(2 * a, c_out); }
module inner2d() { rounded2d(min(corner_r, c_in / 2)) chamfered_square2d(2 * a_in, c_in); }
module bore2d()  { circle(d = clear_d, $fn = bore_fn); }
module recess_floor2d() { rounded2d(recess_cr) chamfered_square2d(recess_sq, recess_ch); }

// ---------------------------------------------------------------------
// Parts
// ---------------------------------------------------------------------
// Frame with its mating face at z = 0, growing up (+z)
module frame(h_low, h_up) {
    difference() {
        union() {
            linear_extrude(h_low + eps) difference() { offset(delta = -frame_clearance) recess_floor2d(); bore2d(); }
            translate([0, 0, h_low]) linear_extrude(h_up) difference() { outer2d(); bore2d(); }
        }
        mirror4() translate([magnet_offset, magnet_offset, -eps]) cylinder(d = pocket_d, h = pocket_h + eps, $fn = 48);
    }
}

module flange(h) { linear_extrude(h) difference() { outer2d(); bore2d(); } }

module tpu() {
    bellows_tpu(n, t, g, joint_w, z0) { outer2d(); inner2d(); }
    if (!bot_frame) translate([0, 0, 0]) flange(z0 + eps);
    if (!top_frame) translate([0, 0, z_top - eps]) flange(top_up + eps);
}

module spacers() {
    bellows_spacers(n, t, g, joint_w, a_in, cut_w, z0, corner_cuts) { outer2d(); inner2d(); }
}

module frames() {
    if (bot_frame) frame(bot_low, bot_up);
    if (top_frame) translate([0, 0, total_h]) mirror([0, 0, 1]) frame(top_low, top_up);
}

module section() {
    if (show_section) difference() { children(); translate([-500, -1000, -1]) cube([1000, 1000, 1000]); }
    else children();
}

module assembly() {
    color("dimgray")   render() section() tpu();
    color("hotpink")   render() section() spacers();
    color("steelblue") render() section() frames();
    if (show_rods)
        %mirror4() translate([rod_c, rod_c, -10]) cylinder(d = rod_d, h = total_h + 20, $fn = 32);
}

if (part == "assembly") assembly();
else if (part == "tpu") tpu();
else if (part == "spacers") spacers();
else if (part == "frames") frames();

// ---------------------------------------------------------------------
// Preview-only data
// ---------------------------------------------------------------------
if (show_dims && part == "assembly") {
    zd = total_h + 1;
    %dim_linear([-a, -a - 6], [a, -a - 6], str(fmt1(outer_w)), size = 3, z = zd);
    %dim_linear([-a_in, a_in - 6], [a_in, a_in - 6], str("bore ", fmt1(clear_d)), size = 3, z = zd);
    %note_block([
        str("Bellows ", std_name, ", sheet ", fmt1(sheet_w), " mm wide"),
        str(n, " sheets ", fmt2(t), " + gaps ", fmt2(g), " (", sheet_layers, "+", gap_layers, " layers of ", lh, ")"),
        str("Between plates: ", fmt1(len_min), " compressed, ~", round(len_max), " extended"),
        str("Ends: ", end_bottom, " / ", end_top, (bot_frame || top_frame) ? str(", magnets Ø", magnet_d, " x ", magnet_h) : ""),
        str("Print height ", fmt1(total_h), " mm"),
    ], [a + 8, a], size = 3, z = zd);
}
