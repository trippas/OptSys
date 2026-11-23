// OptSys - rod seats.
//
// V seat: the rod is pushed (by a clamp arm or a screw coming from +Y)
// into a V cut in the body. It touches the two flanks along the whole
// plate thickness, so the plate cannot tilt on the rod and needs no
// clearance: a printed hole that comes out a bit large or small only moves
// the rod along the V bisector.
//
// 2D, rod axis at the origin, V apex on -Y, opening toward +Y.

// Distance from the rod axis to the V apex.
function rod_seat_v_depth(rod_d, angle) = rod_d / 2 / sin(angle / 2);
// Half width of the V at the height of the rod axis (y = 0).
function rod_seat_v_halfwidth(rod_d, angle) = rod_d / 2 / cos(angle / 2);
// Contact points of the rod on the two flanks (y < 0).
function rod_seat_v_contacts(rod_d, angle) =
    let(r = rod_d / 2) [[-r * cos(angle / 2), -r * sin(angle / 2)], [r * cos(angle / 2), -r * sin(angle / 2)]];

// Cutout: the V from its apex up to the rod axis, then straight walls up
// to y = top (>= 0) so the rod can enter from +Y.
module rod_seat_v2d(rod_d, angle = 90, top = 0) {
    a = rod_seat_v_depth(rod_d, angle);
    w = rod_seat_v_halfwidth(rod_d, angle);
    polygon([[0, -a], [w, 0], [w, top], [-w, top], [-w, 0]]);
}
