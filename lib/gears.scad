// OptSys - involute spur gears and racks (2D outlines, extrude them).
//
// m = module (mm), z = number of teeth, pa = pressure angle (deg).
// Standard proportions: addendum = m, dedendum = 1.25 m.
// `backlash` is removed from the tooth thickness at the pitch line, so a
// pinion and a rack each with backlash b mesh with a total play of 2b.

function gear_pitch_r(m, z) = m * z / 2;
function gear_tip_r(m, z)   = m * z / 2 + m;
function gear_root_r(m, z)  = m * z / 2 - 1.25 * m;
function rack_pitch(m)      = PI * m;

// involute function, angle in degrees -> radians
function _inv(a) = tan(a) - a * PI / 180;

// Spur gear outline centered on the origin.
module spur_gear2d(m, z, pa = 20, backlash = 0, steps = 10) {
    rp = gear_pitch_r(m, z);
    rb = rp * cos(pa);
    ra = gear_tip_r(m, z);
    rf = gear_root_r(m, z);
    // half tooth thickness at the pitch circle, as an angle (rad)
    half_t = (PI * m / 2 - backlash) / 2 / rp;
    // polar angle (deg) of the flank at radius r, from the tooth axis
    function flank_a(r) = let(a_r = acos(rb / max(r, rb)))
        (half_t + _inv(pa) - _inv(a_r)) * 180 / PI;
    r0 = max(rb, rf);
    flank = [for (i = [0:steps]) let(r = r0 + (ra - r0) * i / steps) [r, flank_a(r)]];
    tip_a = flank_a(ra);
    tooth = concat(
        rf < rb ? [[rf * 0.99 * cos(-flank_a(rb)), rf * 0.99 * sin(-flank_a(rb))]] : [],
        [for (p = flank) p[0] * [cos(-p[1]), sin(-p[1])]],
        [for (i = [1:3]) let(a = -tip_a + 2 * tip_a * i / 4) ra * [cos(a), sin(a)]],
        [for (j = [0:steps]) let(p = flank[steps - j]) p[0] * [cos(p[1]), sin(p[1])]],
        rf < rb ? [[rf * 0.99 * cos(flank_a(rb)), rf * 0.99 * sin(flank_a(rb))]] : []);
    union() {
        circle(rf, $fn = 4 * z);
        for (k = [0:z - 1]) rotate(360 * k / z) polygon(tooth);
    }
}

// Rack outline along +X from x = 0 to x = n * pitch, pitch line on y = 0,
// teeth pointing +Y. Both ends fall in the middle of a tooth gap, so racks
// placed end to end keep the tooth spacing. The body goes down to y = -depth
// (measured from the pitch line).
module rack2d(m, n, pa = 20, backlash = 0, depth = 3) {
    p = rack_pitch(m);
    ha = m; hf = 1.25 * m;
    w = p / 4 - backlash / 2;        // half tooth thickness at the pitch line
    k = tan(pa);
    union() {
        translate([0, -depth]) square([n * p, depth - hf + 0.01]);
        for (i = [0:n - 1]) translate([(i + 0.5) * p, 0])
            polygon([[-w - hf * k, -hf], [w + hf * k, -hf], [w - ha * k, ha], [-w + ha * k, ha]]);
    }
}
