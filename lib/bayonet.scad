// OptSys - bayonet quick mount (experimental, under test).
//
// A lens adapter with a spigot and n lugs drops into a receptor bore through
// n notches and turns `turn` degrees clockwise (seen from the front) under a
// ledge. A spring ring between the flange and the seat face pushes the
// adapter forward, so the lugs press on the back face of the ledge:
//   - lug and ledge faces are 45 deg cones: they print without supports and,
//     pulled together, center the adapter (3 lugs = position and tilt);
//   - at the end of the turn the ledge has a shallow pocket (`detent`): the
//     spring drops the lugs into it with a click and they cannot turn back
//     until the adapter is pushed in (like a BNC connector);
//   - the flange does not touch the seat: the lugs are the reference.
//
// The spring is a printed TPU ring with a conical lip (bayonet_spring), so
// no O-ring is needed.
//
// Coordinates: optical axis = Z. Receptor: seat face at z = seat_z.
// Adapter: flange underside at z = 0, spigot toward -Z (as in quickmount.scad).
// Angles: locked lug i is centered at i * 360 / n; it enters through the
// notch at that angle + turn and turns clockwise (decreasing angle) to lock.

// Interface parameters, bundled in a list (read them with the accessors).
//   d                 spigot diameter
//   bore_clearance    diametral clearance of the receptor bore
//   n                 number of lugs
//   lug_a             lug width (deg)
//   lug_depth         radial lug height outside the spigot
//   lug_h             lug height along Z at the spigot (the top face is a
//                     45 deg cone, so the tip is lug_h - lug_depth high)
//   turn              rotation to lock (deg)
//   ledge_t           ledge thickness at the bore, at the detent pocket
//                     (thinnest point), below the entry chamfer
//   entry_chamfer     45 deg chamfer of the bore on the seat face
//   gap               flange underside to seat face, locked
//   radial_clearance  between the lug tips and the groove wall
//   axial_clearance   extra push needed to turn freely under the ledge
//   floor_clearance   between the lugs (pushed fully in) and the groove floor
//   arc_clearance     around the lugs in the notches and pockets (mm of arc)
function bayonet_spec(d = 42, bore_clearance = 0.4, n = 3, lug_a = 35, lug_depth = 1.8, lug_h = 2.6,
                      turn = 45, ledge_t = 1.0, entry_chamfer = 0.5, gap = 1.8,
                      radial_clearance = 0.3, axial_clearance = 0.15, floor_clearance = 0.25,
                      arc_clearance = 0.3) =
    [d, bore_clearance, n, lug_a, lug_depth, lug_h, turn, ledge_t, entry_chamfer, gap,
     radial_clearance, axial_clearance, floor_clearance, arc_clearance];

// Spec of a named bayonet from OPTSYS_BAYONETS (lib/standards.scad).
function bayonet_named(name) = let(b = _bq(name))
    bayonet_spec(d = b[1], bore_clearance = b[2], n = b[3], lug_a = b[4], lug_depth = b[5], lug_h = b[6],
                 turn = b[7], ledge_t = b[8], entry_chamfer = b[9], gap = b[10], radial_clearance = b[11],
                 axial_clearance = b[12], floor_clearance = b[13], arc_clearance = b[14]);

function bay_d(s)                = s[0];
function bay_bore_clearance(s)   = s[1];
function bay_n(s)                = s[2];
function bay_lug_a(s)            = s[3];
function bay_lug_depth(s)        = s[4];
function bay_lug_h(s)            = s[5];
function bay_turn(s)             = s[6];
function bay_ledge_t(s)          = s[7];
function bay_entry_chamfer(s)    = s[8];
function bay_gap(s)              = s[9];
function bay_radial_clearance(s) = s[10];
function bay_axial_clearance(s)  = s[11];
function bay_floor_clearance(s)  = s[12];
function bay_arc_clearance(s)    = s[13];

// Derived values.
function bay_R(s)       = bay_d(s) / 2;                                  // spigot radius
function bay_rb(s)      = bay_R(s) + bay_bore_clearance(s) / 2;         // bore radius
function bay_lug_r(s)   = bay_R(s) + bay_lug_depth(s);                   // lug tip radius
function bay_groove_r(s)= bay_lug_r(s) + bay_radial_clearance(s);        // groove outer radius
function bay_arc_deg(s) = bay_arc_clearance(s) / bay_lug_r(s) * 180 / PI;
// Depth of the ledge back face at the bore below the seat face, at the pocket.
function bay_pocket_depth(s) = bay_entry_chamfer(s) + bay_ledge_t(s);
// Spigot length below the flange underside (lugs at its end).
function bay_spigot_l(s) = bay_gap(s) + bay_pocket_depth(s) - bay_bore_clearance(s) / 2 + bay_lug_h(s);
// Groove floor depth below the seat face for a given detent.
function bay_floor_depth(s, detent) =
    bay_spigot_l(s) - bay_gap(s) + detent + bay_axial_clearance(s) + bay_floor_clearance(s);
// Free web of ledge between two neighbouring grooves (deg).
function bay_web_deg(s) = 360 / bay_n(s) - (bay_lug_a(s) + bay_turn(s) + 2 * bay_arc_deg(s));

module bayonet_check(s, detent = 0.3) {
    assert(bay_lug_h(s) - bay_lug_depth(s) >= 0.4,
           str("Lug tip only ", bay_lug_h(s) - bay_lug_depth(s), " mm high: raise lug_h or lower lug_depth"));
    assert(bay_web_deg(s) >= 5,
           str("Grooves overlap (", bay_web_deg(s), " deg of web): lower lug_a or turn, or use fewer lugs"));
    assert(detent >= 0 && detent < bay_ledge_t(s) + bay_entry_chamfer(s),
           "detent must be smaller than the ledge (ledge_t + entry_chamfer)");
    // groove outer wall must stay above the floor
    assert(bay_pocket_depth(s) + detent + (bay_groove_r(s) - bay_rb(s)) < bay_floor_depth(s, detent) - 0.3,
           "Groove outer wall too low: raise lug_h or floor_clearance, or lower lug_depth");
}

// Adapter lugs (to union with the spigot). Adapter frame: flange underside
// at z = 0, locked position.
module bayonet_lugs(s) {
    R = bay_R(s); l = bay_spigot_l(s); ld = bay_lug_depth(s); h = bay_lug_h(s);
    for (i = [0:bay_n(s) - 1])
        rotate(i * 360 / bay_n(s) - bay_lug_a(s) / 2)
            rotate_extrude(angle = bay_lug_a(s), convexity = 4)
                polygon([[R - 0.5, -l], [R + ld, -l], [R + ld, -l + h - ld], [R, -l + h], [R - 0.5, -l + h]]);
}

// Groove cross-section (r, z) with the ledge back face `raise` above its
// pocket level; z relative to the seat face.
module _bay_groove2d(s, detent, raise) {
    rb = bay_rb(s); rg = bay_groove_r(s);
    zf = -bay_pocket_depth(s) - raise;          // ledge back face at the bore
    zfl = -bay_floor_depth(s, detent);
    polygon([[rb - 0.5, zfl], [rg, zfl], [rg, zf - (rg - rb)], [rb, zf], [rb - 0.5, zf + 0.5]]);
}

// Receptor cutter: bore with entry chamfer, notches, grooves under the
// ledge and detent pockets. The seat face is at z = seat_z; the bore goes
// down to z_bottom.
module bayonet_receptor_cut(s, seat_z, detent = 0.3, z_bottom = -1) {
    rb = bay_rb(s); rg = bay_groove_r(s); ec = bay_entry_chamfer(s);
    n = bay_n(s); la = bay_lug_a(s); t = bay_turn(s); ac = bay_arc_deg(s);
    zfl = -bay_floor_depth(s, detent);
    bayonet_check(s, detent);
    translate([0, 0, seat_z]) {
        translate([0, 0, z_bottom - seat_z]) cylinder(r = rb, h = seat_z - z_bottom + 1);
        translate([0, 0, -ec]) cylinder(r1 = rb, r2 = rb + ec + 0.01, h = ec + 0.01);
        for (i = [0:n - 1]) rotate(i * 360 / n) {
            // groove at the running level (ledge face `detent` lower), from
            // the end stop to the far side of the notch
            rotate(-la / 2 - ac) rotate_extrude(angle = la + t + 2 * ac, convexity = 4) _bay_groove2d(s, detent, detent);
            // detent pocket at the locked position
            rotate(-la / 2 - ac) rotate_extrude(angle = la + 2 * ac, convexity = 4) _bay_groove2d(s, detent, 0);
            // entry notch through the ledge
            rotate(t - la / 2 - ac) rotate_extrude(angle = la + 2 * ac, convexity = 4)
                polygon([[rb - 0.5, zfl], [rg, zfl], [rg, 1], [rb - 0.5, 1]]);
        }
    }
}

// Printed spring ring (TPU): a base ring that sits on the spigot under the
// flange and a 45 deg conical lip that rests on the seat face. Seat frame:
// seat face at z = 0, flange underside at z = bayonet_spring_h(...).
//   t        lip thickness (perpendicular to the lip); sets the force
//   preload  compression when locked (free height = gap + preload)
//   base_h, base_w  base ring height and radial width
//   fit      diametral interference of the base ring on the spigot
//   marks    small notches on the base bore, to tell the variants apart
function bayonet_spring_h(s, preload) = bay_gap(s) + preload;
function bayonet_spring_od(s, preload, base_h = 0.8, base_w = 1.4, fit = 0.3) =
    2 * (bay_R(s) - fit / 2 + base_w + bayonet_spring_h(s, preload) - base_h);
module bayonet_spring(s, t = 0.7, preload = 0.3, base_h = 0.8, base_w = 1.4, fit = 0.3, marks = 0) {
    H  = bayonet_spring_h(s, preload);
    ri = bay_R(s) - fit / 2;
    ro = ri + base_w;
    v  = H - base_h;
    th = t * sqrt(2);
    assert(v > 0.3, "preload + gap too small for the lip: raise gap or lower base_h");
    assert(th < base_w, "Lip thicker than the base ring: lower t or raise base_w");
    assert(ro - th + v > bay_rb(s) + bay_entry_chamfer(s) + 0.2, "Lip would land in the bore chamfer: raise base_w");
    difference() {
        rotate_extrude(convexity = 4) polygon([
            [ri, H], [ri, H - base_h], [ro - th, H - base_h],
            [ro - th + v, 0], [ro + v, 0], [ro, H - base_h], [ro, H]]);
        if (marks > 0) for (k = [0:marks - 1]) rotate(k * 12)
            translate([ri - 0.4, -0.5, H - base_h - 0.01]) cube([0.8, 1, base_h + 0.02]);
    }
}
