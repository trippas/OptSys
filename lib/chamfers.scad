// OptSys - chamfered extrusions and drafted pockets.

// Linear extrusion of a 2D outline with a 45 deg chamfer of size c on the
// top and bottom convex edges.
//   steps > 0: stepped approximation (steps per chamfer). 5 steps on a
//              0.5 mm chamfer = 0.1 mm, finer than a printed layer.
//   steps = 0: exact minkowski (slower; may leave zero-volume slivers
//              with the Manifold backend).
module chamfered_extrude(h, c, steps = 5, eps = 0.01) {
    if (c <= 0) linear_extrude(h) children();
    else if (steps == 0)
        minkowski() {
            translate([0, 0, c]) linear_extrude(h - 2 * c) offset(delta = -c) children();
            hull() { cylinder(r1 = c, r2 = 0, h = c, $fn = 16); mirror([0, 0, 1]) cylinder(r1 = c, r2 = 0, h = c, $fn = 16); }
        }
    else union() {
        n = steps;
        translate([0, 0, c - eps]) linear_extrude(h - 2 * c + 2 * eps) children();
        for (i = [0:n - 1]) {
            d  = c * (1 - (i + 0.5) / n);
            z0 = c * i / n;
            translate([0, 0, z0]) linear_extrude(c / n + eps) offset(delta = -d) children();
            translate([0, 0, h - z0 - c / n - eps]) linear_extrude(c / n + eps) offset(delta = -d) children();
        }
    }
}

// Pocket cutter with an exact sloped wall for a CONVEX 2D piece: hull
// between the piece at the floor (z = 0) and the piece grown by `draft`
// per `depth`, extended 1 mm above the surface (z = depth).
// (minkowski with a cone == hull when the piece is convex.) For non-convex
// shapes, split them into convex pieces and union one call per piece.
module drafted_convex(depth, draft, eps = 0.01) {
    k = draft / depth;
    hull() {
        linear_extrude(eps) children();
        translate([0, 0, depth + 1 - eps]) linear_extrude(eps) offset(r = k * (depth + 1)) children();
    }
}
