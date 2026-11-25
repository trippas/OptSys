// =====================================================================
//  OptSys - QM quick-mount lens adapter
//
//  Small adapter that carries a lens (or objective, bellows, helicoid)
//  and drops into a QM receptor plate (parts/cage_plates/lens_cage_plate
//  with lens_mount = "qm"). One adapter per lens, one receptor per cage
//  position: print the adapters small and fine (e.g. 0.08 mm layers).
//
//  The interface (spigot, groove, flange) comes from OPTSYS_QUICKMOUNTS
//  in lib/standards.scad: QM42 for OptSys plates (10 mm with 1.5 mm
//  bellows recesses), QM42-EPI for the user's tested EPI plates, BQ42 for
//  the bayonet receptor (experimental: push in, turn 45 deg clockwise; it
//  rides on a printed TPU spring ring, part = spring).
//    female - the lens screws into the adapter (enlarger lenses: L39;
//             objectives: RMS, M25, ...). The lens flange or objective
//             shoulder rests on the top face.
//    male   - the adapter screws into something (M42 x 1 Pentax bellows
//             or helicoid, T2, ...).
//
//  Coordinates (assembly): optical axis = Z, seat plane (flange
//  underside; = receptor seat face for QM, gap above it for BQ) at z = 0, lens side toward +Z, spigot
//  toward -Z. The output is placed in print orientation.
// =====================================================================

use <../../lib/optsys.scad>

/* [Output] */
// adapter, or the TPU spring ring of a bayonet (BQ) adapter
part = "adapter"; // [adapter:Adapter, spring:Bayonet spring ring (TPU, BQ only)]

/* [Lens thread] */
// female: lens screws in; male: the adapter screws into a bellows / helicoid
mode = "female"; // [female:Female (lens screws in), male:Male (screws into a bellows / helicoid)]
// Thread (from lib/standards.scad)
thread = "L39"; // [L39:L39 - 39 mm x 26 TPI (enlarger lenses), M39x1:M39 x 1, M42x1:M42 x 1 (Pentax screw mount), T2:T2 - M42 x 0.75, RMS:RMS - 0.8 in x 36 TPI (objectives), M25x0.75:M25 x 0.75 (Leica / Nikon objectives), M27x0.75:M27 x 0.75 (Zeiss objectives), M26x36TPI:M26 x 36 TPI (Mitutoyo objectives)]
// Diametral thread clearance (calibrate with parts/test_coupons/thread_ring_test). Keep it small: a large value leaves the lens thread so shallowly engaged that it can start one turn ahead on one side and seat tilted
thread_clearance = 0.15; // [0:0.01:1]
// Axial thread clearance: play along Z between the flanks, without loosening the radial engagement. Printed flat, the flanks are 30 deg from the bed (layer steps, sag): raise this one, not thread_clearance, if the lens is hard to screw in. Max = pitch / 2
thread_z_clearance = 0.2; // [0:0.01:0.5]
// Thread length
thread_l = 5; // [2:0.5:20]
// Extra height above the flange: raises the lens register (objective parfocal spacer). Raised automatically if the thread needs it
hub_h = 0; // [0:0.5:60]
// Radial wall around a female thread in the hub. 0 = no hub: the lens rests on the flange top (the thread is shortened if it does not fit in the spigot + flange)
hub_wall = 2.5; // [0:0.1:8]
// Clear bore below the thread (0 = automatic: as large as the walls allow)
bore_d_set = 0; // [0:0.1:60]
// 45 deg entry chamfer of the thread
entry_chamfer = 0.6; // [0:0.1:2]

/* [Interface] */
// Quick-mount interface
qm = "QM42"; // [QM42:QM42 - Ø42 x 7 spigot, Ø46 flange (OptSys plates), QM42-EPI:QM42-EPI - Ø42 x 10 spigot, Ø50 flange (EPI plates), BQ42:BQ42 - bayonet, Ø42 spigot with 3 lugs, Ø46 flange (experimental)]

/* [Bayonet spring ring (BQ only)] */
// Lip thickness of the TPU spring ring (sets the force; choose it with parts/test_coupons/bayonet_test)
spring_t = 0.7; // [0.3:0.05:1.5]
// Spring compression when locked
spring_preload = 0.3; // [0.1:0.05:1]

/* [Print] */
// spigot_down: as the tested adapter (flange underside bridged); lens_down: lens face on the bed, flange underside printed as a top surface
orientation = "spigot_down"; // [spigot_down:Spigot down (as tested), lens_down:Lens face down]

/* [Quality] */
$fn = 144;
// Thread segments per turn
thread_n = 180; // [48:12:360]
// Thread samples per pitch along Z
thread_zres = 16; // [4:1:32]

/* [Hidden] */
eps = 0.01;
female = mode == "female";
d  = thread_spec_d(thread);
P  = thread_spec_pitch(thread);
c  = thread_clearance;
bq = is_bayonet(qm);
S  = bq ? bayonet_named(qm) : undef;
R  = bq ? bay_R(S) : qm_d(qm) / 2;
F  = (bq ? bq_flange_d(qm) : qm_flange_d(qm)) / 2;
ft = bq ? bq_flange_t(qm) : qm_flange_t(qm);
l  = bq ? bay_spigot_l(S) : qm_l(qm);
gd = bq ? 0 : qm_groove_depth(qm);
seat_off = bq ? bay_gap(S) : 0;          // flange underside above the receptor seat face
max_bore = bq ? 2 * R - 2 * 1.6 : qm_max_bore(qm);
min_wall = 1;

// female thread radii (enlarged by the clearance) / male (reduced)
f_rmaj = (d + c) / 2;
f_rmin = (thread_minor_d(d, P) + c) / 2;
m_rmaj = (d - c) / 2;
m_rmin = (thread_minor_d(d, P) - c) / 2;

// how high the female thread must start: inside the spigot only if the wall
// to the spigot surface (and to the groove) stays >= min_wall
f_bottom_min = !female ? 0 :
    f_rmaj + min_wall <= R - gd ? -l + 1 :                  // fits inside the groove bottom
    f_rmaj + min_wall <= R      ? -(qm_groove_top(qm) - 0.8) :   // above the groove
    f_rmaj + min_wall <= F      ? 0.4 :                      // inside the flange
    1e9;
no_hub  = female && hub_wall == 0;                          // lens rests on the flange top
// without a hub the female thread must fit in the spigot + flange: shortened if needed
tl      = no_hub ? min(thread_l, ft - f_bottom_min) : thread_l;
hub_eff = female ? (no_hub ? 0 : max(hub_h, f_bottom_min + tl - ft)) : hub_h;
z_top   = female ? ft + hub_eff : ft + hub_h + tl;
z_thr   = female ? z_top - tl : ft + hub_h;           // thread start
hub_od  = female ? min(2 * F, 2 * f_rmaj + 2 * hub_wall) : 0;
bore_auto = female ? min(2 * f_rmin - 1, max_bore) : min(2 * m_rmin - 3, max_bore);
bore_d  = bore_d_set > 0 ? bore_d_set : bore_auto;

assert(f_bottom_min < 1e8, str("The ", thread, " thread (Ø", d, ") is too large for the ", qm, " flange (Ø", 2 * F, ")"));
assert(female || m_rmaj <= F, str("The male thread is larger than the flange"));
assert(bore_d <= (female ? 2 * f_rmin : 2 * m_rmin - 2), "bore_d_set cuts into the thread");
assert(bore_d <= max_bore, str("bore_d_set too large for the spigot walls (max Ø", max_bore, ")"));
assert(bq || part != "spring", "The spring ring is only for bayonet (BQ) adapters: set qm = BQ42");
assert(thread_l >= 2 * P, "thread_l too short: at least two turns");
assert(thread_z_clearance <= P / 2 + 1e-9, str("thread_z_clearance is larger than half the pitch (", P / 2, ")"));
assert(!no_hub || hub_h == 0, "hub_wall = 0 (no hub) cannot raise the lens register: set hub_h = 0 or give the hub a wall");
assert(tl >= 2 * P, str("Without a hub only ", tl, " mm of thread fits in the spigot + flange (less than two turns): give the hub a wall (hub_wall > 0)"));
if (no_hub && tl < thread_l) echo(str("Note: no hub, the thread is shortened to ", tl, " mm (", round(10 * tl / P) / 10, " turns) to fit in the spigot + flange"));

echo(str("QM adapter ", qm, " ", mode, " ", thread, " (Ø", d, " x ", P, ", clearance ", c, " radial + ", thread_z_clearance, " axial: play vs. a metal thread ",
         round(100 * (thread_z_clearance + c * tan(30))) / 100, " mm axial, engagement ", round(100 * ((d - thread_minor_d(d, P)) / 2 - c / 2)) / 100, " of ", round(100 * (d - thread_minor_d(d, P)) / 2) / 100, " mm radial): ",
         female ? str("lens register (top face) ", z_top + seat_off, " mm above the receptor seat face") :
                  str("thread from ", z_thr + seat_off, " to ", z_top + seat_off, " mm above the receptor seat face"),
         ", clear bore Ø", bore_d, female && hub_eff > hub_h ? str(" (hub raised to ", hub_eff, " mm for the thread)") : ""));

module adapter() {
    difference() {
        union() {
            if (bq) {
                translate([0, 0, -l]) cylinder(r = R, h = l + eps);
                rotate_extrude(convexity = 4) polygon([[0, 0], [F - 0.4, 0], [F, 0.4], [F, ft - 0.4], [F - 0.4, ft], [0, ft]]);
                bayonet_lugs(S);
            }
            else qm_spigot_flange(qm);
            if (female && z_top > ft) translate([0, 0, ft - eps]) cylinder(d = hub_od, h = z_top - ft + eps);
            if (!female) {
                if (hub_h > 0) translate([0, 0, ft - eps]) cylinder(r = m_rmin, h = hub_h + 2 * eps);
                translate([0, 0, z_thr]) difference() {
                    external_thread(d, P, thread_l, c, thread_n, thread_zres, thread_z_clearance);
                    // 45 deg chamfer on the top of the external thread
                    translate([0, 0, thread_l - entry_chamfer]) difference() {
                        cylinder(r = m_rmaj + 1, h = entry_chamfer + 1);
                        translate([0, 0, -eps]) cylinder(r1 = m_rmaj, r2 = m_rmaj - entry_chamfer - 1, h = entry_chamfer + 1 + 2 * eps);
                    }
                }
            }
        }
        // clear bore
        translate([0, 0, -l - 1]) cylinder(d = bore_d, h = z_top + l + 2);
        if (female) {
            translate([0, 0, z_thr]) internal_thread_cutter(d, P, tl + 1, c, thread_n, thread_zres, thread_z_clearance);
            // 45 deg transition from the bore to the thread (no flat overhang in either orientation)
            // (runs 0.2 mm into the thread so it shares no face with the thread cutter)
            translate([0, 0, z_thr - (f_rmin - bore_d / 2)])
                cylinder(r1 = bore_d / 2, r2 = f_rmin + 0.2, h = f_rmin - bore_d / 2 + 0.2);
            // entry chamfer
            translate([0, 0, z_top - (f_rmaj + entry_chamfer - f_rmin)])
                cylinder(r1 = f_rmin - eps, r2 = f_rmaj + entry_chamfer, h = f_rmaj + entry_chamfer - f_rmin + eps);
        }
        // small chamfer on the bore at the spigot tip
        translate([0, 0, -l - eps]) cylinder(r1 = bore_d / 2 + 0.4, r2 = bore_d / 2 - eps, h = 0.4 + eps);
    }
}

if (bq) echo(str("Bayonet ", qm, ": push in, turn ", bay_turn(S), " deg clockwise (seen from the front) until it clicks; spring ring: lip ",
                 spring_t, " mm, Ø", bayonet_spring_od(S, spring_preload), ", print in TPU, base ring down (part = spring)"));

if (part == "spring")
    color("DimGray") render(convexity = 6) translate([0, 0, bayonet_spring_h(S, spring_preload)]) mirror([0, 0, 1]) bayonet_spring(S, spring_t, spring_preload);
else color("SteelBlue") render(convexity = 8)
    if (orientation == "lens_down") translate([0, 0, z_top]) mirror([0, 0, 1]) adapter();
    else translate([0, 0, l]) adapter();
