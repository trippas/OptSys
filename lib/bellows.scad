// OptSys - printed bellows.
//
// A stack of flat TPU sheets joined alternately at their outer and inner
// edges, printed compressed with sacrificial PLA spacers in the gaps (TPU
// does not bond to PLA). After printing the spacers are pulled out and the
// stack opens like an accordion. Needs a multi-material printer; the TPU,
// the spacers and any rigid end frames are exported as separate bodies.
//
// The outline comes in as children, both 2D and centered on the axis:
//   children(0) = outer outline, children(1) = inner outline (the bore).
// n sheets of thickness t, separated by gaps of height g (pitch t + g);
// sheet 0 starts at z0. Gap k (between sheets k and k + 1) is closed by a
// TPU joint of width joint_w at the outer edge when k is even and at the
// inner edge when k is odd; its spacer is open on the other edge.

// Height of the stack of n sheets.
function bellows_stack_h(n, t, g) = n * t + (n - 1) * g;

// Joint ring of gap k.
module bellows_joint2d(k, joint_w) {
    if (k % 2 == 0) difference() { children(0); offset(delta = -joint_w) children(0); }
    else            difference() { offset(delta = joint_w) children(1); children(1); }
}

// Spacer of gap k (one piece, before cutting).
module bellows_spacer2d(k, joint_w) {
    if (k % 2 == 0) difference() { offset(delta = -joint_w) children(0); children(1); }
    else            difference() { children(0); offset(delta = joint_w) children(1); }
}

// TPU body: sheets and joints (overlapping by eps so they fuse into one body).
module bellows_tpu(n, t, g, joint_w, z0 = 0, eps = 0.01) {
    for (k = [0 : n - 1]) translate([0, 0, z0 + k * (t + g)])
        linear_extrude(t) difference() { children(0); children(1); }
    for (k = [0 : n - 2]) translate([0, 0, z0 + k * (t + g) + t - eps])
        linear_extrude(g + 2 * eps) bellows_joint2d(k, joint_w) { children(0); children(1); }
}

// PLA spacers, cut into pieces by slots of width cut_w at x = +-cut_x (use
// the half width of the bore across its flats), so every piece slides out
// of its pocket flat:
//   outer-open pockets (odd k): 4 pieces; pull the +-x pieces out to the
//     side, then the +-y pieces.
//   inner-open pockets (even k): with corner_cuts, also slots at
//     y = +-cut_x for |x| > cut_x -> 8 pieces; slide the +-y pieces into
//     the bore, then the +-x pieces, then the 4 corners diagonally. Without corner_cuts, 4 pieces: the +-y
//     pieces slide into the bore, the +-x pieces are longer than the bore
//     and must bow (out of plane) to come out.
module bellows_spacers(n, t, g, joint_w, cut_x, cut_w, z0 = 0, corner_cuts = true) {
    for (k = [0 : n - 2]) translate([0, 0, z0 + k * (t + g) + t])
        linear_extrude(g) difference() {
            bellows_spacer2d(k, joint_w) { children(0); children(1); }
            for (s = [-1, 1]) {
                translate([s * cut_x - cut_w / 2, -1000]) square([cut_w, 2000]);
                if (corner_cuts && k % 2 == 0) for (sx = [-1, 1])   // only outside |x| > cut_x: separates the corners
                    translate([sx > 0 ? cut_x : -1000, s * cut_x - cut_w / 2]) square([1000 - cut_x, cut_w]);
            }
        }
}
