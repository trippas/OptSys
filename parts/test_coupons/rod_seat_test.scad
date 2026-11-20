// =====================================================================
//  OptSys - rod seat test coupon
//
//  A bar with one rod seat per cell, to choose how cage plates sit on
//  their rods before using it in real parts:
//    round  - the current plate seat: round, with diametral clearance,
//             the rod pushed against it by a screw (reference)
//    v      - V seats of several angles, the rod pushed into the V by a
//             screw: two contact lines along the whole thickness, no play
//    hole   - closed holes with several clearances (tight-hole style)
//  Slide the bar onto one rod per cell, tighten the screw (screw cells)
//  and check how much the bar can rock or tilt on the rod.
//
//  Screw cells: M3 screw entering from the +Y face, through a captive
//  nut dropped in from the top face, pressing the rod toward -Y.
//
//  Coordinates: bar along X, rod axes along Z (vertical as printed, like
//  the rods in a plate printed flat), rod axes at y = 0, bottom face at
//  z = 0. Labels are engraved on the top face.
// =====================================================================

use <../../lib/optsys.scad>

/* [Rods] */
// Rod standard (sets the rod diameter)
standard = "60mm"; // [60mm:Ø6 rods (30 / 50 / 60 mm cages), 100mm:Ø8 rods (OptSys 100)]
// Rod diameter (0 = from standard)
rod_d_set = 0; // [0:0.05:20]

/* [Cells] */
// Diametral clearance of the round reference seat (0 = no reference cell)
round_clearance = 0.25; // [0:0.05:1]
// V seat angles (degrees)
v_angles = [60, 90, 120];
// Diametral clearances of the closed holes
hole_clearances = [0, 0.1, 0.2, 0.3];

/* [Body] */
// Thickness = length of contact with the rod (same as the plates)
block_t = 10; // [6:0.5:30]
// Wall on each side of every seat
wall = 3; // [1.5:0.1:8]
// Floor below the deepest seat
floor_t = 2.5; // [1:0.1:6]
// Gap between the rod and the screw bridge
gap = 1; // [0.3:0.1:4]
// Material on each side of the captive nut in the bridge
bridge_wall = 1.5; // [0.8:0.1:4]
// Extra clearance of the nut slot
nut_clearance = 0.2; // [0:0.05:1]
// Edge chamfer (also opens the hole entries)
chamfer = 0.4; // [0:0.1:1.5]

/* [Labels] */
// Strip below the seats for the engraved labels
label_h = 6; // [0:0.5:12]
// Maximum text height
text_size = 3.5; // [2:0.1:6]
// Engraving depth
engrave = 0.6; // [0.2:0.1:1.5]

/* [View] */
// Ghost rods in the preview
show_rods = true;

/* [Hidden] */
$fn = 96;
eps = 0.01;
screw = "M3";

rod_d = rod_d_set > 0 ? rod_d_set : cage_rod_d(standard);
r = rod_d / 2;

cells = concat(
    round_clearance > 0 ? [["round", round_clearance]] : [],
    [for (a = v_angles) ["v", a]],
    [for (c = hole_clearances) ["hole", c]]);
n = len(cells);

function has_screw(c) = c[0] != "hole";
function half_cut(c) = c[0] == "v" ? rod_seat_v_halfwidth(rod_d, c[1]) : r + c[1] / 2;
function depth(c) = c[0] == "v" ? rod_seat_v_depth(rod_d, c[1]) : r + c[1] / 2;
function cell_w(c) = 2 * max(half_cut(c), has_screw(c) ? nut_af(screw) / 2 + nut_clearance / 2 + 0.8 : 0) + 2 * wall;
function x0(i) = i == 0 ? 0 : x0(i - 1) + cell_w(cells[i - 1]);
function cx(i) = x0(i) + cell_w(cells[i]) / 2;
function label(c) = c[0] == "round" ? str("R", c[1]) : c[0] == "v" ? str("V", c[1]) : str(c[1]);

total_l  = x0(n);
bridge_t = nut_t(screw) + nut_clearance + 2 * bridge_wall;
y_cav    = r + gap;                       // bottom of the screw bridge
y_top    = y_cav + bridge_t;
y_nut    = y_cav + bridge_t / 2;
y_bot    = -max([for (c = cells) depth(c)]) - floor_t - label_h;
screw_len = y_top - r + 1;                // from the outer face to 1 mm past the rod surface

assert(n > 0, "No cells: set round_clearance > 0 or add v_angles / hole_clearances");
assert(min([for (a = v_angles) a]) >= 30 && max([for (a = v_angles) a]) <= 150, "V angles must be between 30 and 150 degrees");
assert(block_t / 2 - nut_ac(nut_af(screw)) / 2 >= 0.6, "block_t too thin for the M3 nut slot: use block_t >= 8");

echo(str("Rod Ø", rod_d, ": ", n, " cells ", [for (c = cells) label(c)], ", bar ", total_l, " x ", y_top - y_bot, " x ", block_t, " mm"));
echo(str("Screw cells: M3 x ", ceil(screw_len / 2) * 2, " (minimum ", screw_len, " mm) + M3 nut"));
for (c = cells) if (c[0] == "v")
    echo(str("V", c[1], ": rod axis ", rod_seat_v_depth(rod_d, c[1]), " mm above the apex, V ", 2 * rod_seat_v_halfwidth(rod_d, c[1]), " mm wide at the axis"));

// ---------------------------------------------------------------------
module cut2d(c) {
    if (c[0] == "v") rod_seat_v2d(rod_d, c[1], y_cav);
    else if (c[0] == "round") {
        circle(r + c[1] / 2);
        translate([-(r + c[1] / 2), 0]) square([2 * (r + c[1] / 2), y_cav]);
    }
    else circle(r + c[1] / 2);
}

module outline2d() {
    difference() {
        translate([0, y_bot]) square([total_l, y_top - y_bot]);
        for (i = [0:n - 1]) translate([cx(i), 0]) cut2d(cells[i]);
    }
}

module coupon() {
    difference() {
        chamfered_extrude(block_t, chamfer, 4, eps) outline2d();
        for (i = [0:n - 1]) if (has_screw(cells[i])) {
            // screw hole along Y (round, horizontal)
            translate([cx(i), y_cav - 1, block_t / 2]) rotate([-90, 0, 0])
                cylinder(d = clearance_d(screw), h = bridge_t + 2);
            captive_nut_slot_y([cx(i), y_nut, block_t / 2], nut_af(screw), nut_t(screw), block_t, nut_clearance);
        }
        if (label_h > 0) for (i = [0:n - 1]) {
            s = label(cells[i]);
            translate([cx(i), y_bot + label_h / 2, block_t - engrave])
                linear_extrude(engrave + 1)
                    text(s, size = min(text_size, label_h * 0.7, 0.85 * cell_w(cells[i]) / (0.72 * len(s))),
                         halign = "center", valign = "center");
        }
    }
}

color("SteelBlue") render(convexity = 6) coupon();
if (show_rods && $preview)
    for (i = [0:n - 1]) {
        c = cells[i];
        // rod resting where the screw pushes it: on the V flanks or the seat bottom
        dy = c[0] == "v" ? 0 : c[0] == "round" ? -c[1] / 2 : 0;
        %translate([cx(i), dy, -10]) cylinder(d = rod_d, h = block_t + 20);
    }
