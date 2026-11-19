#!/usr/bin/env bash
# Compile every OptSys part with its defaults and with every preset in its
# .json file. Fails on any OpenSCAD error or warning.
#
#   tools/check.sh                          # uses `openscad` from PATH
#   OPENSCAD=openscad-nightly tools/check.sh
set -u
OPENSCAD="${OPENSCAD:-openscad}"
cd "$(dirname "$0")/.."

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
            [ -n "$preset" ] && run "$scad [$preset]" -p "$json" -P "$preset" "$scad"
        done < <(python3 -c 'import json,sys; print("\n".join(json.load(open(sys.argv[1]))["parameterSets"]))' "$json")
    fi
done < <(find parts -name '*.scad' | sort)

exit $fail
