// OptSys - generic 2D/3D geometry helpers.

// Morphological closing: fills concave corners of the children with radius r.
module closing2d(r) { offset(r = -r) offset(r = r) children(); }

// Pie slice of radius r from angle a0 to a1 (degrees).
module sector2d(r, a0, a1, n = 48) {
    polygon(concat([[0, 0]], [for (i = [0:n]) let(a = a0 + (a1 - a0) * i / n) r * [cos(a), sin(a)]]));
}

// Ring slice between radii r0 and r1, from angle a0 to a1.
module annular_sector2d(r0, r1, a0, a1) {
    difference() { sector2d(r1, a0, a1); circle(r0); }
}

// Square of side s centered on the origin, with 45 deg corner chamfers of leg c.
module chamfered_square2d(s, c) {
    h = s / 2;
    polygon([[h - c, h], [-h + c, h], [-h, h - c], [-h, -h + c],
             [-h + c, -h], [h - c, -h], [h, -h + c], [h, h - c]]);
}

// Repeats the children mirrored into the four XY quadrants (D2 symmetry).
module mirror4() {
    for (mx = [0, 1], my = [0, 1])
        mirror([mx, 0, 0]) mirror([0, my, 0]) children();
}

// Box from p0 to p1 with all 12 edges chamfered at 45 deg (leg c). Convex.
module chamfered_box(p0, p1, c) {
    s = p1 - p0;
    translate(p0) if (c <= 0) cube(s);
    else hull() {
        translate([0, c, c]) cube([s[0], s[1] - 2 * c, s[2] - 2 * c]);
        translate([c, 0, c]) cube([s[0] - 2 * c, s[1], s[2] - 2 * c]);
        translate([c, c, 0]) cube([s[0] - 2 * c, s[1] - 2 * c, s[2]]);
    }
}

// Extrudes a 2D outline drawn in the YZ plane (2D x -> Y, 2D y -> Z)
// along +X, from x0 to x1.
module yz_extrude(x0, x1) {
    translate([x0, 0, 0]) rotate([90, 0, 90]) linear_extrude(x1 - x0) children();
}

// Extrudes a 2D outline drawn in the XZ plane (2D x -> X, 2D y -> Z)
// along Y, centered on y = 0, total width w.
module xz_extrude(w) {
    rotate([90, 0, 0]) linear_extrude(w, center = true) children();
}
