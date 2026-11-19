// OptSys - fasteners: metric nut and clearance hole data, captive nut slots.

// [size, nut across flats, nut thickness, clearance hole (medium fit)]
// Nuts: ISO 4032 nominal. Clearance holes: ISO 273 medium series.
OPTSYS_METRIC = [
    ["M2",   4.0, 1.6, 2.4],
    ["M2.5", 5.0, 2.0, 2.9],
    ["M3",   5.5, 2.4, 3.4],
    ["M4",   7.0, 3.2, 4.5],
    ["M5",   8.0, 4.7, 5.5],
    ["M6",  10.0, 5.2, 6.6],
];

function _metric(size) = OPTSYS_METRIC[search([size], OPTSYS_METRIC)[0]];
function nut_af(size)       = _metric(size)[1];   // across flats
function nut_t(size)        = _metric(size)[2];   // thickness
function clearance_d(size)  = _metric(size)[3];   // clearance hole
function nut_ac(af)         = af / cos(30);       // across corners

// Slot for a hex nut standing on edge, open toward +Z, so the nut drops in
// from the top face. The nut axis is along Y; the slot is centered on the
// nut center `c` = [x, y, z]. `top` is the Z of the face it opens on.
// clearance is added to across-flats and thickness.
module captive_nut_slot_y(c, af, t, top, clearance = 0, extra_below = 0.1) {
    w = af + clearance; d = t + clearance;
    z0 = c[2] - nut_ac(af) / 2 - extra_below;
    translate([c[0] - w / 2, c[1] - d / 2, z0]) cube([w, d, top - z0 + 1]);
}
