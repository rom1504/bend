#!/usr/bin/env python3
"""Reuse the existing extractor on an explicit immutable source snapshot."""
import hashlib
import importlib.util
import json
from pathlib import Path
import sys

sys.dont_write_bytecode = True
ROOT = Path(__file__).resolve().parents[3]
key = sys.argv.index('--parent-source')
source = Path(sys.argv[key + 1]).resolve(strict=True)
del sys.argv[key:key + 2]
data = source.read_bytes()
parent = {'bytes': len(data), 'sha256': hashlib.sha256(data).hexdigest()}
method = ROOT / 'selfhost/tests/phase175/frontend-prepare.py'
spec = importlib.util.spec_from_file_location('frontend_transport', method)
M = importlib.util.module_from_spec(spec)
spec.loader.exec_module(M)
M.PARENT = parent
# Exact snapshot transport. Semantic parsing/checking still happens in Bend
# and the unchanged upstream checker, never in this host metadata adapter.
M.assembly.maintained_assemble = lambda *a, **k: (data, [])
write_original = M.write_json


def write_manifest(path, value):
    if Path(path).name == 'manifest.json':
        value = dict(value)
        value['kind'] = 'phase180-api-source'
        value['inputs'] += [M.pin(source), M.pin(__file__)]
        value['parentScope'] = 'Explicit immutable source snapshot; maintained module pins record surrounding workspace only. No source-map claim.'
    write_original(path, value)


M.write_json = write_manifest
M.main()
M.require(source.read_bytes() == data, 'Snapshot changed during extraction')
