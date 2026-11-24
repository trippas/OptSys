// OptSys - quick mounts (QM).
//
// A lens adapter with a flanged spigot drops into a bore in a receptor
// plate and is locked by a radial screw (see OPTSYS_QUICKMOUNTS in
// standards.scad). The screw presses on the conical flank of a groove in
// the spigot, which pulls the flange onto the seat face (axial position
// and tilt) and pushes the spigot against the opposite bore wall
// (centering). The groove runs all around: the adapter can be
// clocked freely.
//
// Coordinates: optical axis = Z, seat plane (flange underside) at
// z = seat_z (0 for the adapter); the spigot points toward -Z.

// Solid of revolution of the adapter interface: spigot (z = -l .. 0) and
// flange (z = 0 .. flange_t). No bore.
module qm_spigot_flange(name, tip_chamfer = 0.5, flange_chamfer = 0.4) {
    R  = qm_d(name) / 2;
    F  = qm_flange_d(name) / 2;
    ft = qm_flange_t(name);
    l  = qm_l(name);
    gd = qm_groove_depth(name);
    rotate_extrude(convexity = 4) polygon([
        [0, -l], [R - tip_chamfer, -l], [R, -l + tip_chamfer],
        [R, -qm_cone_bottom(name)], [R - gd, -qm_cone_top(name)],
        [R - gd, -qm_groove_top(name)], [R, -qm_groove_top(name)],
        [R, 0], [F - flange_chamfer, 0], [F, flange_chamfer],
        [F, ft - flange_chamfer], [F - flange_chamfer, ft], [0, ft]]);
}

// Smallest wall-safe bore through an adapter spigot.
function qm_max_bore(name, min_wall = 1.6) = qm_d(name) - 2 * qm_groove_depth(name) - 2 * min_wall;

// Lock screw length from a plate edge at edge_d from the axis to 1 mm
// into the groove.
function qm_screw_len(name, edge_d) = edge_d - (qm_d(name) / 2 - qm_groove_depth(name)) + 1;

// Cutter for a QM receptor in a plate whose seat face is at z = seat_z
// and whose edge, in the screw direction, is at edge_d from the axis.
//   screw_a  direction of the lock screw in XY (deg, 90 = +Y)
//   bore_clearance  diametral clearance of the bore for the spigot
//   nut_depth  captive nut of the lock screw, nut_depth from the edge (like
//              a post-mount nut); its slot is open up to nut_top (pass the
//              front face z; default: the seat face)
//   screw_hole_d  diameter of the lock screw channel (default: clearance hole)
module qm_receptor_cut(name, seat_z, edge_d, screw_a = 90, bore_clearance = 0.3,
                       nut_depth = 5, nut_top = undef, nut_clearance = 0.2, screw_hole_d = undef,
                       entry_chamfer = 0.4, z_bottom = -1) {
    R  = qm_d(name) / 2;
    rb = R + bore_clearance / 2;
    zs = seat_z - qm_screw_depth(name);
    s  = qm_screw(name);
    // bore (through) + entry chamfer on the seat face
    translate([0, 0, z_bottom]) cylinder(r = rb, h = seat_z - z_bottom + 1);
    translate([0, 0, seat_z - entry_chamfer]) cylinder(r1 = rb, r2 = rb + entry_chamfer + 0.01, h = entry_chamfer + 0.01);
    rotate(screw_a - 90) {
        // screw channel along +Y (round: it is horizontal when printed)
        translate([0, R - 1, zs]) rotate([-90, 0, 0]) cylinder(d = is_undef(screw_hole_d) ? clearance_d(s) : screw_hole_d, h = edge_d - R + 2, $fn = 48);
        // captive nut
        captive_nut_slot_y([0, edge_d - nut_depth, zs], nut_af(s), nut_t(s), is_undef(nut_top) ? seat_z : nut_top, nut_clearance);
    }
}
