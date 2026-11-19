// OptSys - printable threads.
//
// helix_solid() builds a solid whose radius varies with angle and height
// following an ISO 60 deg trapezoidal profile (P/8 flat at rmax, P/4 flat
// at rmin). Used as a cutter for internal threads and as the body of
// external threads. Right-handed. Works for metric and UN (inch) threads,
// which share the same 60 deg profile.

function pmod(a, b) = a - b * floor(a / b);

function thr_r(u, P, rmin, rmax) =
    let(fh = P / 8, fl = P / 4, dz = (P - fh - fl) / 2)
    u < fh ? rmax :
    u < fh + dz ? rmax - (rmax - rmin) * (u - fh) / dz :
    u < fh + dz + fl ? rmin :
    rmin + (rmax - rmin) * (u - fh - dz - fl) / dz;

// N = segments per turn, zres = samples per pitch along Z.
module helix_solid(h, P, rmin, rmax, N = 180, zres = 16) {
    nz = max(2, ceil(h / (P / zres)));
    pts = concat(
        [for (j = [0:nz]) for (i = [0:N - 1])
            let(z = h * j / nz, th = 360 * i / N, r = thr_r(pmod(z - P * th / 360, P), P, rmin, rmax))
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
// starting at z = 0. `clearance` is diametral and enlarges the hole.
module internal_thread_cutter(d, P, h, clearance = 0.2, N = 180, zres = 16) {
    helix_solid(h, P, thread_minor_d(d, P) / 2 + clearance / 2, d / 2 + clearance / 2, N, zres);
}

// External thread body (no bore) of nominal diameter d and pitch P, height h.
// `clearance` is diametral and shrinks the thread.
module external_thread(d, P, h, clearance = 0.2, N = 180, zres = 16) {
    helix_solid(h, P, thread_minor_d(d, P) / 2 - clearance / 2, d / 2 - clearance / 2, N, zres);
}
