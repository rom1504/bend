#!/usr/bin/env python3
"""Reuse exact Phase175 metadata transport with an explicit Phase177 parent."""
import importlib.util
import json
from pathlib import Path
import sys

sys.dont_write_bytecode = True
ROOT = Path(__file__).resolve().parents[3]
method = ROOT/'selfhost/tests/phase175/frontend-prepare.py'
spec = importlib.util.spec_from_file_location('p177_transport',method)
M = importlib.util.module_from_spec(spec)
spec.loader.exec_module(M)
M.PARENT = dict(bytes=3163584,sha256='a0e953a84de73aa22403dde7ec2144540197633857a0f7b5b9784f9e66f5ad04')
snapshot = None
if '--snapshot-parser' in sys.argv:
    sys.argv.remove('--snapshot-parser')
    snapshot = ROOT/'selfhost/build/phase175/parse-lookahead-source01/compiler.bend'
    M.PARENT = dict(bytes=358267,sha256='3f104e77908bd517d7981a3bbbafdbf5ebe769547117360e1fe878173ab8c323')
    identity = M.pin(snapshot)
    M.require(all(identity[k]==v for k,v in M.PARENT.items()),'Historical parser differs')
    # Preserve the exact old declaration order for a matched prebuilt-image
    # comparison. This is a frozen parser closure, not the maintained compiler.
    M.assembly.maintained_assemble = lambda *args, **kwargs: (snapshot.read_bytes(), [])
# Keep parent positions only for retained declarations, before serializing.
# Do not materialize another 3MB source-map file for every tiny closure.
write_original = M.write_json
def write_compact(path,value):
    if Path(path).name == 'manifest.json' and 'parentSourceMapEntries' not in value:
        value = dict(value)
        retained = {(r['kind'],r['name']) for r in value['declarations']}
        full_map = value['originalSourceMap']
        value['originalSourceMap'] = [r for r in full_map if (r['kind'],r['name']) in retained]
        value['parentSourceMapEntries'] = len(full_map)
        value['sourceMapScope'] = 'Parent positions for retained declarations only; reconstruct the full map from pinned maintained sources.'
    write_original(path,value)
M.write_json = write_compact
M.main()
out = Path(sys.argv[sys.argv.index('--out')+1])
manifest = json.loads((out/'manifest.json').read_text())
manifest['kind'] = 'phase177-api-source'
manifest['inputs'].append(M.pin(__file__))
if snapshot:
    manifest['inputs'].append(identity)
    manifest['parentScope'] = 'Frozen Phase175 parser-only source, exact order; installed Phase171 producer required for matched native comparison.'
M.write_json(out/'manifest.json',manifest)
