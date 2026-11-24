// OptSys - preview-only annotations: dimension lines and text notes, flat
// on the XY plane. Call them under the % modifier, e.g. %dim_linear(...):
// OpenSCAD then shows them in the F5 preview only; they are never part of
// the render (F6) or of an exported STL.

// Two decimals ("42.30") / one decimal ("5.0") for labels.
function fmt2(x) = let(n = round(abs(x) * 100), i = floor(n / 100), f = n - 100 * i) str(x < 0 ? "-" : "", i, ".", f < 10 ? "0" : "", f);
function fmt1(x) = let(n = round(abs(x) * 10), i = floor(n / 10)) str(x < 0 ? "-" : "", i, ".", n - 10 * i);

// Dimension line from p1 to p2 (2D points) with arrowheads and its label
// centered above it, at height z. size = text height.
module dim_linear(p1, p2, label, size = 3, z = 0, t = 0.2) {
    v = p2 - p1;
    L = norm(v);
    a = min(size, L / 3);            // arrowhead length
    w = size / 12;                    // line width
    translate([p1[0], p1[1], z]) rotate(atan2(v[1], v[0])) linear_extrude(t) {
        translate([a / 2, -w / 2]) square([L - a, w]);
        polygon([[0, 0], [a, a / 3], [a, -a / 3]]);
        polygon([[L, 0], [L - a, a / 3], [L - a, -a / 3]]);
        translate([L / 2, size * 0.5]) text(label, size = size, halign = "center", valign = "bottom");
    }
}

// Lines of text starting at pos (top left), at height z.
module note_block(lines, pos, size = 3, z = 0, t = 0.2) {
    translate([pos[0], pos[1], z]) linear_extrude(t)
        for (i = [0:len(lines) - 1]) translate([0, -i * 1.5 * size]) text(lines[i], size = size, valign = "top");
}
