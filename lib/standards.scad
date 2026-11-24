// OptSys - interface standards shared by all parts.
//
// Cage systems: [name, rod spacing (center to center), rod diameter,
//                series thread name, typical plate width]
// The 16/30/60 mm entries follow the Thorlabs cage standards (rod spacing,
// rod size and SM thread series); "50mm" and "100mm" are OptSys formats
// ("50mm" comes from the user's epi-illuminator cage, with the QM42-EPI quick
// mount as its series interface).
OPTSYS_CAGES = [
    ["16mm",  16, 4, "SM05", 25],
    ["30mm",  30, 6, "SM1",  41],
    ["50mm",  50, 6, "QM42-EPI", 63],
    ["60mm",  60, 6, "SM2",  71.1],
    ["100mm", 85, 8, "M64x1.5", 100],
];

function _cage(name) = OPTSYS_CAGES[search([str(name)], OPTSYS_CAGES)[0]];
function cage_rod_spacing(name) = _cage(name)[1];
function cage_rod_d(name)       = _cage(name)[2];
function cage_thread(name)      = _cage(name)[3];
function cage_plate_w(name)     = _cage(name)[4];

// Threads: [name, nominal diameter (mm), pitch (mm)]
// SM series are UN 40 TPI (pitch 0.635 mm): at the limit of FDM printing,
// test before relying on them for commercial lens tubes.
OPTSYS_THREADS = [
    ["SM05",   0.535 * 25.4, 25.4 / 40],
    ["SM1",    1.035 * 25.4, 25.4 / 40],
    ["SM2",    2.035 * 25.4, 25.4 / 40],
    ["SM30",   30.5,         0.5],
    ["C-mount", 1.0 * 25.4,  25.4 / 32],
    // Lens threads. Enlarger lenses use the Leica thread mount: 39 mm x
    // 26 TPI (sold as "M39x1"; true M39x1 differs by 0.023 mm per turn).
    // OptSys prints them with its 60 deg profile plus clearance.
    ["L39",      39,           25.4 / 26],
    ["M39x1",    39,           1],
    ["M42x1",    42,           1],
    ["T2",       42,           0.75],
    // Microscope objectives (RMS = 0.8"-36 Whitworth; M25 Leica/Nikon,
    // M27 Zeiss, M26 x 36 TPI Mitutoyo).
    ["RMS",      0.8 * 25.4,   25.4 / 36],
    ["M25x0.75", 25,           0.75],
    ["M27x0.75", 27,           0.75],
    ["M26x36TPI", 26,          25.4 / 36],
];

function _thread(name) = OPTSYS_THREADS[search([name], OPTSYS_THREADS)[0]];
function thread_spec_d(name) = _thread(name)[1];
function thread_spec_pitch(name) = _thread(name)[2];

// Quick mounts (QM): a flanged spigot on the lens adapter goes into a bore
// in the receptor plate; a radial screw presses on a conical flank of a
// groove in the spigot, which pulls the flange against the seat face
// (axial position and tilt) and pushes the spigot against the opposite
// bore wall (centering). The groove runs all around, so the
// adapter can be clocked freely.
//   QM42      OptSys: 7 mm spigot and screw 3.5 mm below the seat face, so
//             in a 10 mm plate with 1.5 mm bellows recesses on both faces
//             the flange sits on the front recess floor, the spigot fills
//             the web between both floors and the screw is centered.
//             Ø46 flange: fits on the 47 mm recess floor of the 60 mm
//             plate, inside its magnets (from r = 23.4).
//   QM42-EPI  the user's tested EPI quick-mount plate and M39 adapter
//             (10 mm plate without recesses, screw at mid thickness).
//             Same groove, 1.5 mm deeper; not interchangeable with QM42.
// [name, spigot d, spigot length, flange d, flange t, screw depth,
//  groove top depth, cone top depth, cone bottom depth, groove depth, screw]
// Depths are measured from the seat plane (flange underside) into the
// receptor. Groove: flat step at "groove top", bottom (r - groove depth)
// down to "cone top", conical flank back to r at "cone bottom".
OPTSYS_QUICKMOUNTS = [
    ["QM42",     42,  7, 46, 3, 3.5, 1.9, 3.7, 4.9, 1.7, "M4"],
    ["QM42-EPI", 42, 10, 50, 3, 5,   3.4, 5.2, 6.4, 1.7, "M4"],
];

function _qm(name) = OPTSYS_QUICKMOUNTS[search([str(name)], OPTSYS_QUICKMOUNTS)[0]];
function qm_d(name)            = _qm(name)[1];
function qm_l(name)            = _qm(name)[2];
function qm_flange_d(name)     = _qm(name)[3];
function qm_flange_t(name)     = _qm(name)[4];
function qm_screw_depth(name)  = _qm(name)[5];
function qm_groove_top(name)   = _qm(name)[6];
function qm_cone_top(name)     = _qm(name)[7];
function qm_cone_bottom(name)  = _qm(name)[8];
function qm_groove_depth(name) = _qm(name)[9];
function qm_screw(name)        = _qm(name)[10];

// Optical posts (metric): diameter, top thread, bottom thread.
OPTSYS_POST_D = 12.7;
OPTSYS_POST_TOP_THREAD = "M4";
OPTSYS_POST_BOTTOM_THREAD = "M6";
// Metric breadboard: M6 holes on a 25 mm grid.
OPTSYS_BREADBOARD_PITCH = 25;
OPTSYS_BREADBOARD_THREAD = "M6";

// Aluminium extrusions (slotted profiles):
// [name, size, slot opening, V width at the face (90 deg V), lip thickness,
//  slot depth (face to cavity floor), cavity width, core bore]
// "2020V" = 2020 V-slot (OpenBuilds type): 20 x 20, 6.2 mm slot, 90 deg V,
// 4.2 mm core (tapped M5 by default; a 4.2 core can also take an M4 tap).
// The V width and the slot cavity reproduce the tested OptSys rail
// carriage and rack (PETG-CF, Nov 2026); check them against your profile.
OPTSYS_EXTRUSIONS = [
    ["2020V", 20, 6.2, 9.26, 1.9, 6.0, 11.0, 4.2],
];

function _extrusion(name) = OPTSYS_EXTRUSIONS[search([str(name)], OPTSYS_EXTRUSIONS)[0]];
function extrusion_size(name)      = _extrusion(name)[1];
function extrusion_slot_w(name)    = _extrusion(name)[2];
function extrusion_v_w(name)       = _extrusion(name)[3];
function extrusion_lip_t(name)     = _extrusion(name)[4];
function extrusion_slot_depth(name)= _extrusion(name)[5];
function extrusion_cavity_w(name)  = _extrusion(name)[6];
function extrusion_core_d(name)    = _extrusion(name)[7];
