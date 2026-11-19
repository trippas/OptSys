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
