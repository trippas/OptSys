#!/usr/bin/env bash
# Compile every OptSys part with its defaults and with every preset in its
# .json file. Fails on any OpenSCAD error or warning.
#
#   tools/check.sh                          # finds OpenSCAD (see below)
#   OPENSCAD=openscad-nightly tools/check.sh
#   OPENSCAD="/c/Program Files/OpenSCAD (Nightly)/openscad.com" tools/check.sh
#
# Without OPENSCAD it uses `openscad` from PATH or, on Windows (Git Bash), an
# install under "C:\Program Files\OpenSCAD*", preferring a Nightly one.
# Python (to read the presets) is python3, python or py, whichever runs.
set -u
cd "$(dirname "$0")/.."

if [ -z "${OPENSCAD:-}" ]; then
    if command -v openscad >/dev/null 2>&1; then
        OPENSCAD=openscad
    else
        for exe in "/c/Program Files/OpenSCAD"*Nightly*/openscad.com \
                   "/c/Program Files/OpenSCAD"*Nightly*/openscad.exe \
                   "/c/Program Files/OpenSCAD"*/openscad.com \
                   "/c/Program Files/OpenSCAD"*/openscad.exe; do
            if [ -f "$exe" ]; then OPENSCAD="$exe"; break; fi
        done
    fi
fi
if [ -z "${OPENSCAD:-}" ]; then
    echo "OpenSCAD not found: set OPENSCAD to its executable." >&2
    exit 2
fi

if [ -z "${PYTHON:-}" ]; then
    for py in python3 python py; do
        if "$py" -c 'import json' >/dev/null 2>&1; then PYTHON="$py"; break; fi
    done
fi
if [ -z "${PYTHON:-}" ]; then
    echo "Python not found: install it or set PYTHON to its executable." >&2
    exit 2
fi
echo "Using $OPENSCAD"

fail=0
tmp="$(mktemp -d)"
trap 'rm -rf "$tmp"' EXIT

run() {  # run <label> <openscad args...>
    local label="$1"; shift
    if ! "$OPENSCAD" -o "$tmp/out.csg" "$@" >"$tmp/log" 2>&1 \
       || grep -qE "ERROR|WARNING" "$tmp/log"; then
        echo "FAIL  $label"
        grep -E "ERROR|WARNING" "$tmp/log" | sed 's/^/      /'
        fail=1
    else
        echo "ok    $label"
    fi
}

while IFS= read -r scad; do
    run "$scad (defaults)" "$scad"
    json="${scad%.scad}.json"
    if [ -f "$json" ]; then
        while IFS= read -r preset; do
            preset="${preset%$'\r'}"   # Python on Windows ends lines with CRLF
            [ -n "$preset" ] && run "$scad [$preset]" -p "$json" -P "$preset" "$scad"
        done < <("$PYTHON" -c 'import json,sys; print("\n".join(json.load(open(sys.argv[1]))["parameterSets"]))' "$json")
    fi
done < <(find parts -name '*.scad' | sort)

exit $fail
