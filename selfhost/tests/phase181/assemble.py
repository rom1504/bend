#!/usr/bin/env python3
"""Assemble the experimental x86 entry from the maintained Bend modules.

Metadata-only declaration selection; checking/lowering remain in Bend. This
does not modify the production source manifest, assets, or installed selection.
Pass --export NAME for a hosted API; otherwise build the native CLI source.
Additional --module files may supply test declarations. No historical snapshot
is needed to assemble the current backend.
"""
import hashlib
import importlib.util
from pathlib import Path
import sys

sys.dont_write_bytecode = True
ROOT = Path(__file__).resolve().parents[3]
method = ROOT / 'selfhost/tests/phase175/frontend-prepare.py'
spec = importlib.util.spec_from_file_location('x86_source_transport', method)
M = importlib.util.module_from_spec(spec)
spec.loader.exec_module(M)
source = M.assembly.maintained_assemble(ROOT/'selfhost/src/compiler.json', ROOT/'selfhost', 'qbe')
M.PARENT = dict(bytes=len(source), sha256=hashlib.sha256(source).hexdigest())
modules = ['model', 'frame', 'scalar', 'regalloc', 'function', 'program', 'stream', 'entry']
sys.argv[1:1] = [word for name in modules for word in ['--module', str(ROOT/'selfhost/src/back/x86'/f'{name}.bend')]]
if '--export' not in sys.argv:
    sys.argv.append('--native-main')
write_original = M.write_json


def write_manifest(path, value):
    if Path(path).name == 'manifest.json':
        value = dict(value)
        value['kind'] = 'phase181-maintained-x86-source'
        value['inputs'] += [M.pin(__file__)]
        value['scope'] = 'Maintained semantic modules plus experimental Bend x86 modules; explicit declaration closure. Independent source checking still required. No production profile or installed target change.'
    write_original(path, value)


M.write_json = write_manifest
M.main()
