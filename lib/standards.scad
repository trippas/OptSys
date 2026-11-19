// OptSys - interface standards shared by all parts.
//
// Cage systems: [name, rod spacing (center to center), rod diameter,
//                series thread name, typical plate width]
// The 16/30/60 mm entries follow the Thorlabs cage standards (rod spacing,
// rod size and SM thread series); "100mm" is the OptSys own large format.
OPTSYS_CAGES = [
    ["16mm",  16, 4, "SM05", 25],
    ["30mm",  30, 6, "SM1",  41],
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
];

function _thread(name) = OPTSYS_THREADS[search([name], OPTSYS_THREADS)[0]];
function thread_spec_d(name) = _thread(name)[1];
function thread_spec_pitch(name) = _thread(name)[2];

// Optical posts (metric): diameter, top thread, bottom thread.
OPTSYS_POST_D = 12.7;
OPTSYS_POST_TOP_THREAD = "M4";
OPTSYS_POST_BOTTOM_THREAD = "M6";
// Metric breadboard: M6 holes on a 25 mm grid.
OPTSYS_BREADBOARD_PITCH = 25;
OPTSYS_BREADBOARD_THREAD = "M6";
