// =====================================================================
//  OptSys - bayonet quick mount test coupon (experimental)
//
//  A receptor disc (one per detent depth), a short adapter with a grip
//  ring standing in for the lens, and printed TPU spring rings (one per
//  lip thickness). Push the adapter in, turn it clockwise until it clicks
//  into the detent, and check: click, centering, play, how hard it is to
//  push in and release, and wear after many cycles. See lib/bayonet.scad.
//
//  Coordinates: optical axis = Z. Receptor: back face at z = 0, seat face
//  at z = receptor_t (print it seat face up: the groove floor is flat and
//  its roof is a 45 deg cone). Adapter: printed grip down (its lugs face
//  up, 45 deg). Springs: printed in TPU, base ring down.
// =====================================================================

use <../../lib/optsys.scad>

/* [Output] */
// What to output. all = print set laid out flat; assembly = locked view
part = "all"; // [all:Print set (receptors + adapter + springs), assembly:Assembly (locked), receptor:Receptor discs, adapter:Adapter, spring:Spring rings (TPU)]
// Which receptor / spring to output (0 = all of them; 1 = first value of the list)
which = 0; // [0:1:10]
// Assembly: cut away a quarter to see the lugs in the pocket
section = true;

/* [Tests] */
// Detent pocket depths, one receptor each (how far the lugs drop at the end of the turn)
detents = [0.2, 0.35, 0.5];
// Spring lip thicknesses, one TPU ring each (sets the force)
spring_t = [0.5, 0.7, 0.9];
// Spring compression when locked
preload = 0.3; // [0.1:0.05:1]

/* [Bayonet] */
// Diametral clearance of the bore for the Ø42 spigot (0.4 fits well with QM42)
bore_clearance = 0.4; // [0.1:0.05:1]
// Number of lugs
lugs = 3; // [2:1:6]
// Lug width (deg)
lug_a = 35; // [10:1:60]
// Radial lug height outside the spigot (60 mm plates: up to ~1.8, the bellows magnets start at r 23.4)
lug_depth = 1.8; // [1:0.1:4]
// Lug height along Z at the spigot (top face at 45 deg; tip = lug_h - lug_depth)
lug_h = 2.6; // [1.5:0.1:5]
// Rotation to lock (deg, clockwise seen from the front)
turn = 45; // [20:1:90]
// Ledge thickness at the bore, at the pocket (below the entry chamfer)
ledge_t = 1.0; // [0.6:0.1:3]
// Flange underside to seat face, locked (room for the spring)
gap = 1.8; // [1:0.1:3]

/* [Clearances] */
// Lug tips to groove wall
radial_clearance = 0.3; // [0.1:0.05:1]
// Extra push needed to turn freely under the ledge
axial_clearance = 0.15; // [0.05:0.05:0.5]
// Lugs (pushed fully in) to groove floor
floor_clearance = 0.25; // [0.1:0.05:1]
// Around the lugs in the notches and pockets (mm of arc)
arc_clearance = 0.3; // [0.1:0.05:1]
// 45 deg bore chamfer on the seat face
entry_chamfer = 0.5; // [0.2:0.1:1.5]

/* [Spring ring] */
// Base ring height (sits under the flange)
spring_base_h = 0.8; // [0.4:0.1:2]
// Base ring radial width
spring_base_w = 1.4; // [0.8:0.1:3]
// Diametral interference of the base ring on the spigot
spring_fit = 0.3; // [0:0.05:1]

/* [Coupon] */
// Receptor disc diameter
receptor_d = 64; // [52:1:90]
// Receptor thickness (7 = web of a 10 mm OptSys plate with 1.5 mm recesses)
receptor_t = 7; // [5:0.5:12]
// Adapter flange diameter
flange_d = 46; // [44:0.5:60]
// Adapter flange thickness
flange_t = 3; // [1.5:0.5:6]
// Grip ring diameter (stands in for the lens; 48 = about the widest El-Nikkor body). At least flange_d: it is printed grip down
grip_d = 48; // [46:1:80]
// Grip ring height
grip_h = 8; // [3:0.5:20]
// Adapter clear bore
adapter_bore = 35; // [20:0.5:39]
// Outer edge chamfers
chamfer = 0.6; // [0:0.1:1.5]
// Gap between parts in the print set
spacing = 6; // [2:1:20]

/* [Labels] */
// Text height (detent depth, engraved on the receptor)
text_size = 3; // [1.5:0.1:5]
// Engraving depth
engrave = 0.4; // [0.2:0.1:1]

/* [Quality] */
// Circle resolution
fn = 180; // [60:12:360]

/* [Hidden] */
$fn = fn;
eps = 0.01;

S = bayonet_spec(d = 42, bore_clearance = bore_clearance, n = lugs, lug_a = lug_a, lug_depth = lug_depth,
                 lug_h = lug_h, turn = turn, ledge_t = ledge_t, entry_chamfer = entry_chamfer, gap = gap,
                 radial_clearance = radial_clearance, axial_clearance = axial_clearance,
                 floor_clearance = floor_clearance, arc_clearance = arc_clearance);
nd = len(detents);
ns = len(spring_t);
L  = bay_spigot_l(S);
H  = bayonet_spring_h(S, preload);
sod = bayonet_spring_od(S, preload, spring_base_h, spring_base_w, spring_fit);

assert(nd > 0 && ns > 0, "Add at least one value to detents and spring_t");
assert(which <= max(nd, ns), str("which = ", which, " but the lists have ", nd, " / ", ns, " values"));
assert(bay_floor_depth(S, max(detents)) <= receptor_t - 1.2,
       str("Groove floor too deep for receptor_t (needs ", bay_floor_depth(S, max(detents)) + 1.2, " mm)"));
assert(receptor_d >= 2 * bay_groove_r(S) + 2 * text_size + 6, "receptor_d too small for the groove and the label");
assert(flange_d / 2 > bay_rb(S) + entry_chamfer + 0.5, "flange_d must cover the bore chamfer");
assert(grip_d >= flange_d, "grip_d must be at least flange_d (the adapter prints grip down)");
assert(adapter_bore < 42 - 3, "adapter_bore leaves less than 1.5 mm of spigot wall");

echo(str("Bayonet: ", lugs, " lugs x ", lug_a, " deg, ", turn, " deg turn; bore Ø", 2 * bay_rb(S),
         ", lug tips Ø", 2 * bay_lug_r(S), ", groove Ø", 2 * bay_groove_r(S), ", web ", round(bay_web_deg(S) * 10) / 10, " deg"));
echo(str("Adapter: spigot Ø42 x ", L, " below the flange; flange-to-seat gap ", gap, " when locked"));
for (dd = detents)
    echo(str("  receptor detent ", dd, ": groove floor ", bay_floor_depth(S, dd), " below the seat; push ",
             dd + axial_clearance, " mm in to turn"));
echo(str("Spring: free height ", H, " (", preload, " preload), OD ", sod, "; lip t ", spring_t,
         "; compression to turn: ", preload + max(detents) + axial_clearance, " of ", H - spring_base_h));

module receptor(dd) {
    difference() {
        chamfered_extrude(receptor_t, chamfer, 4, eps) circle(d = receptor_d);
        bayonet_receptor_cut(S, receptor_t, dd, -1);
        // locked position of lug 1: radial line on the seat face
        rotate(0) translate([bay_groove_r(S) + 1.5, -0.4, receptor_t - engrave]) cube([4, 0.8, engrave + 1]);
        // detent depth, engraved on the seat face
        rotate(180 + 360 / lugs / 2) translate([(bay_groove_r(S) + receptor_d / 2) / 2, 0, receptor_t - engrave])
            rotate(90) linear_extrude(engrave + 1) text(str(dd), size = text_size, halign = "center", valign = "center");
    }
}

module grip2d() {
    difference() {
        circle(d = grip_d);
        for (k = [0:23]) rotate(k * 15 + 7.5) translate([grip_d / 2 + 0.4, 0]) circle(r = 1.4, $fn = 24);
    }
}

// Adapter frame: flange underside at z = 0, spigot toward -Z, locked position.
module adapter() {
    difference() {
        union() {
            translate([0, 0, -L]) cylinder(r = 21, h = L + eps);
            chamfered_extrude(flange_t, min(chamfer, 0.4), 4, eps) circle(d = flange_d);
            translate([0, 0, flange_t - eps]) chamfered_extrude(grip_h + eps, chamfer, 4, eps) grip2d();
            bayonet_lugs(S);
        }
        translate([0, 0, -L - 1]) cylinder(d = adapter_bore, h = L + flange_t + grip_h + 2);
        // mark over lug 1 on the grip top
        translate([adapter_bore / 2 + 1, -0.4, flange_t + grip_h - engrave]) cube([grip_d / 2 - adapter_bore / 2 - 3, 0.8, engrave + 1]);
    }
}

sel_d = which == 0 ? [0:nd - 1] : [min(which, nd) - 1];
sel_s = which == 0 ? [0:ns - 1] : [min(which, ns) - 1];

module print_receptors() {
    for (i = sel_d) translate([which == 0 ? i * (receptor_d + spacing) : 0, 0, 0])
        color("SteelBlue") render(convexity = 8) receptor(detents[i]);
}
module print_adapter() {
    color("Orange") render(convexity = 8) translate([0, 0, flange_t + grip_h]) mirror([0, 0, 1]) adapter();
}
module print_springs() {
    for (i = sel_s) translate([which == 0 ? i * (sod + spacing) : 0, 0, 0])
        color("DimGray") render(convexity = 6) translate([0, 0, H]) mirror([0, 0, 1])
            bayonet_spring(S, spring_t[i], preload, spring_base_h, spring_base_w, spring_fit, i + 1);
}

module assembly() {
    module cut() {
        difference() { children(); if (section) translate([0, -100, -50]) cube([100, 100, 100]); }
    }
    color("SteelBlue") render(convexity = 8) cut() receptor(detents[min(max(which, 1), nd) - 1]);
    color("DimGray") render(convexity = 6) cut() translate([0, 0, receptor_t])
        bayonet_spring(S, spring_t[min(max(which, 1), ns) - 1], 0, spring_base_h, spring_base_w, spring_fit);
    color("Orange") render(convexity = 8) cut() translate([0, 0, receptor_t + gap]) adapter();
}

if (part == "assembly") assembly();
else if (part == "receptor") print_receptors();
else if (part == "adapter") print_adapter();
else if (part == "spring") print_springs();
else {
    print_receptors();
    translate([0, -(receptor_d + grip_d) / 2 - spacing, 0]) print_adapter();
    translate([grip_d / 2 + spacing + sod / 2, -(receptor_d + sod) / 2 - spacing, 0]) print_springs();
}
