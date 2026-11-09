#!/bin/sh
# Source transport only. Actual checking/emission uses the pinned Bend compiler.
set -eu
out="$1"
python3 - "$out-source" <<'PYROOT'
import json, pathlib, sys
out = pathlib.Path(sys.argv[1]); out.mkdir(parents=True, exist_ok=False)
manifest = json.loads(pathlib.Path('selfhost/src/compiler.json').read_text())
manifest['profiles']['x86']['roots'].append('x187_assemble')
(out/'api-source.json').write_text(json.dumps(manifest,indent=2)+'\n')
PYROOT
python3 -B selfhost/tools/build/source.py assemble \
 --manifest "$out-source/api-source.json" --root selfhost --profile x86 \
 --out "$out-source/compiler.bend" --map "$out-source/source-map.json"
python3 -B selfhost/tests/phase181/prepare.py \
 --parent-source "$out-source/compiler.bend" \
 --module selfhost/tests/phase187/object-elf-controls.bend \
 --module selfhost/tests/phase187/object-parse-controls.bend \
 --module selfhost/tests/phase187/object-encode-controls.bend \
 --export x187_assemble --export p187el_controls --export p187el_object \
 --export p187el_assembly --export x187_parse_controls --export x187ec_controls --out "$out"
