// OptSys - slotted aluminium profiles (approximate outlines, for ghost
// previews and fit checks; the interface data lives in standards.scad).

// Cross-section of a square V-slot profile, centered on the origin.
// Simplified: one slot per face (V entry, lips, rectangular cavity with a
// 45 deg floor), square core and a round core bore.
module vslot_profile2d(name) {
    s  = extrusion_size(name);   h = s / 2;
    so = extrusion_slot_w(name) / 2;
    vw = extrusion_v_w(name) / 2;
    lt = extrusion_lip_t(name);
    sd = extrusion_slot_depth(name);
    cw = extrusion_cavity_w(name) / 2;
    vd = vw - so;                       // depth of the 45 deg V entry
    fl = min(cw - so, sd - lt);         // 45 deg cavity floor
    difference() {
        square(s, center = true);
        for (a = [0, 90, 180, 270]) rotate(a)
            polygon([[h + 1, vw + 1], [h, vw], [h - vd, so], [h - lt, so], [h - lt, cw],
                     [h - sd + fl, cw], [h - sd, cw - fl], [h - sd, -cw + fl], [h - sd + fl, -cw],
                     [h - lt, -cw], [h - lt, -so], [h - vd, -so], [h, -vw], [h + 1, -vw - 1]]);
        circle(d = extrusion_core_d(name), $fn = 32);
    }
}
