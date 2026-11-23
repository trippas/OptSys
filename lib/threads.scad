// OptSys - printable threads.
//
// helix_solid() builds a solid whose radius varies with angle and height
// following an ISO 60 deg trapezoidal profile (P/8 flat at rmax, P/4 flat
// at rmin). Used as a cutter for internal threads and as the body of
// external threads. Right-handed. Works for metric and UN (inch) threads,
// which share the same 60 deg profile.
//
// Clearances: `clearance` is diametral (moves the whole profile radially:
// opens crest/root and, at 60 deg, the flanks by only half of it).
// `z_clearance` is axial: it moves the flanks along Z only (wider groove in
// a nut, thinner tooth on a screw) and keeps the radial engagement. Printed
// with the axis vertical the flanks are only 30 deg from the bed, so layer
// steps and sag land on them: that play is what an FDM thread needs.

function pmod(a, b) = a - b * floor(a / b);

// Radius at axial position u (0..P) of the profile: rmax plateau centered
// at u = P/16, half width P/16 + w (w > 0 widens it, w < 0 narrows it, with
// the same flank slopes); w = 0 is the ISO profile (P/8 flat at rmax, P/4
// flat at rmin).
function thr_r(u, P, rmin, rmax, w = 0) =
    let(dz = 5 * P / 16,                              // axial length of a flank
        v  = pmod(u - P / 16 + P / 2, P) - P / 2)     // offset from the plateau center
    max(rmin, min(rmax, rmax - (abs(v) - P / 16 - w) * (rmax - rmin) / dz));

// N = segments per turn, zres = samples per pitch along Z, w as in thr_r().
module helix_solid(h, P, rmin, rmax, N = 180, zres = 16, w = 0) {
    nz = max(2, ceil(h / (P / zres)));
    pts = concat(
        [for (j = [0:nz]) for (i = [0:N - 1])
            let(z = h * j / nz, th = 360 * i / N, r = thr_r(pmod(z - P * th / 360, P), P, rmin, rmax, w))
            [r * cos(th), r * sin(th), z]],
        [[0, 0, 0], [0, 0, h]]);
    B = (nz + 1) * N; T = B + 1;
    faces = concat(
        [for (j = [0:nz - 1]) for (i = [0:N - 1]) each [
            [j * N + i, (j + 1) * N + i, (j + 1) * N + (i + 1) % N],
            [j * N + i, (j + 1) * N + (i + 1) % N, j * N + (i + 1) % N]]],
        [for (i = [0:N - 1]) [B, i, (i + 1) % N]],
        [for (i = [0:N - 1]) [T, nz * N + (i + 1) % N, nz * N + i]]);
    polyhedron(pts, faces, convexity = 6);
}

// Basic minor diameter of an internal 60 deg thread (ISO 68-1: D1 = D - 1.082532 P).
function thread_minor_d(d, P) = d - 1.082532 * P;

// Cutter for an internal thread of nominal diameter d and pitch P, height h,
// starting at z = 0. `clearance` is diametral and enlarges the hole;
// `z_clearance` is the axial play this part adds (widens the groove).
module internal_thread_cutter(d, P, h, clearance = 0.2, N = 180, zres = 16, z_clearance = 0) {
    assert(z_clearance >= 0 && z_clearance <= P / 4 + 1e-9, str("z_clearance of an internal thread must be 0..P/4 (", P / 4, ")"));
    helix_solid(h, P, thread_minor_d(d, P) / 2 + clearance / 2, d / 2 + clearance / 2, N, zres, z_clearance / 2);
}

// External thread body (no bore) of nominal diameter d and pitch P, height h.
// `clearance` is diametral and shrinks the thread; `z_clearance` is the
// axial play this part adds (thins the tooth).
module external_thread(d, P, h, clearance = 0.2, N = 180, zres = 16, z_clearance = 0) {
    assert(z_clearance >= 0 && z_clearance <= P / 2, str("z_clearance of an external thread must be 0..P/2 (", P / 2, ")"));
    helix_solid(h, P, thread_minor_d(d, P) / 2 - clearance / 2, d / 2 - clearance / 2, N, zres, -z_clearance / 2);
}
