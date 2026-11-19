// OptSys - helpers for multi-material (rigid + TPU) parts.
//
// Pattern used by the parts: define a 3D `region` for the flexible zones,
// then   rigid = body - region   and   flexible = body ∩ region.
// The two outputs are exactly complementary and share the same origin, so
// they load in the slicer as one object with two parts.

// Dovetail key in 2D, rooted on the X axis. up = true grows toward +Y.
// root = width at the base, tip = width at the far end (tip > root locks).
module dovetail2d(root, tip, h, up = true, eps = 0.01) {
    polygon(up ? [[-root / 2, -eps], [root / 2, -eps], [tip / 2, h], [-tip / 2, h]]
               : [[-root / 2, eps], [root / 2, eps], [tip / 2, -h], [-tip / 2, -h]]);
}
