// =====================================================================
//  OptSys - internal thread test rings
//
//  A set of short rings with the same internal thread and increasing
//  diametral clearance. Screw the real lens (or objective) into each one
//  and keep the clearance that turns smoothly without play; use that
//  value in the parts that carry this thread.
//
//  Threads come from OPTSYS_THREADS (lib/standards.scad) and are printed
//  with the OptSys 60 deg profile. Enlarger lenses: "L39" (39 mm x 26 TPI,
//  the usual "M39" enlarger thread).
//
//  Coordinates: ring axes along Z, bottom face at z = 0 (print flat, at
//  fine layers, e.g. 0.08 mm). Rings in a grid on the XY plane; the
//  clearance is engraved on the top face.
// =====================================================================

use <../../lib/optsys.scad>

/* [Thread] */
// Thread (from lib/standards.scad)
thread = "L39"; // [L39:L39 - 39 mm x 26 TPI (enlarger lenses), M39x1:M39 x 1, M42x1:M42 x 1, T2:T2 - M42 x 0.75, RMS:RMS - 0.8 in x 36 TPI (objectives), M25x0.75:M25 x 0.75 (Leica / Nikon objectives), M27x0.75:M27 x 0.75 (Zeiss objectives), M26x36TPI:M26 x 36 TPI (Mitutoyo objectives)]
// Diametral clearances to test, one ring each
clearances = [0.05, 0.15, 0.25, 0.35, 0.45];
// Axial clearance (play along Z between flanks) added to every ring: printed flat, the flanks are 30 deg from the bed, so FDM threads mostly need axial play. Max = pitch / 2
z_clearance = 0.2; // [0:0.01:0.5]

/* [Rings] */
// Ring height (thread length)
ring_h = 5; // [2:0.5:15]
// Radial wall outside the thread (holds the engraved label)
ring_wall = 5.5; // [3:0.1:12]
// 45 deg entry chamfer on both ends of the thread
entry_chamfer = 0.6; // [0:0.1:2]
// Outer edge chamfer
chamfer = 0.4; // [0:0.1:1.5]
// Gap between rings
spacing = 4; // [1:0.5:20]
// Which ring to output (0 = all, in a grid)
which = 0; // [0:1:10]

/* [Labels] */
// Text height
text_size = 3; // [1.5:0.1:5]
// Engraving depth
engrave = 0.5; // [0.2:0.1:1.5]

/* [Quality] */
// Thread segments per turn
thread_n = 180; // [48:12:360]
// Thread samples per pitch along Z
thread_zres = 16; // [4:1:32]

/* [Hidden] */
$fn = 120;
eps = 0.01;

d = thread_spec_d(thread);
P = thread_spec_pitch(thread);
od = d + 2 * ring_wall;
n = len(clearances);
sel = which == 0 ? [0:n - 1] : [which - 1];

assert(n > 0, "Add at least one value to clearances");
assert(which <= n, str("which = ", which, " but there are only ", n, " rings"));
assert(ring_h >= 2 * P, "ring_h too short: at least two turns");
assert(text_size <= ring_wall * 0.7, "text_size too large for ring_wall");

echo(str("Thread ", thread, ": Ø", d, " x ", P, " mm pitch (", 25.4 / P, " TPI), ", n, " rings Ø", od, " x ", ring_h,
         ", clearances ", clearances, " diametral + ", z_clearance, " axial"));
for (c = clearances)
    echo(str("  clearance ", c, ": major Ø", d + c, ", minor Ø", thread_minor_d(d, P) + c));

module ring(c) {
    rmin = thread_minor_d(d, P) / 2 + c / 2;
    rmaj = d / 2 + c / 2;
    difference() {
        chamfered_extrude(ring_h, chamfer, 4, eps) circle(d = od);
        translate([0, 0, -P]) internal_thread_cutter(d, P, ring_h + 2 * P, c, thread_n, thread_zres, z_clearance);
        // entry chamfers (45 deg cones from the major diameter)
        for (z = [0, ring_h]) translate([0, 0, z]) mirror([0, 0, z == 0 ? 0 : 1])
            translate([0, 0, -eps]) cylinder(r1 = rmaj + entry_chamfer, r2 = rmin - eps, h = rmaj + entry_chamfer - rmin + eps);
        // label on the top face, centered on the wall
        translate([0, (rmaj + od / 2) / 2, ring_h - engrave])
            linear_extrude(engrave + 1) text(str(c), size = text_size, halign = "center", valign = "center");
    }
}

cols = ceil(sqrt(n));
for (i = sel)
    translate(which == 0 ? [(i % cols) * (od + spacing), -floor(i / cols) * (od + spacing), 0] : [0, 0, 0])
        color("SteelBlue") render(convexity = 8) ring(clearances[i]);
