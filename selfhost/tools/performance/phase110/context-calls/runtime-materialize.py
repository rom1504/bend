#!/usr/bin/env python3
"""Append context-layout static assertions to an authenticated runtime; data only."""
import argparse
import hashlib
import importlib.util
import json
import sys
from pathlib import Path
sys.dont_write_bytecode = True
HERE = Path(__file__).resolve().parent
ROOT = HERE.parents[4]
spec = importlib.util.spec_from_file_location('runtime_auth', HERE.parent / 'runtime-ir/stored-field-admit-v2.py')
S = importlib.util.module_from_spec(spec)
spec.loader.exec_module(S)


def main():
    p = argparse.ArgumentParser(description=__doc__)
    p.add_argument('--runtime', required=True, type=Path)
    p.add_argument('--out', required=True, type=Path)
    a = p.parse_args()
    base, out = a.runtime.resolve(), a.out.resolve()
    if out.exists() or not out.is_relative_to(ROOT / 'selfhost/build/phase110'):
        raise ValueError('fresh Phase110 output required')
    S.runtime_chain(base / 'manifest.json')
    assertion = HERE / 'runtime-assert.inc.c'
    headers = sorted(base.glob('*.h'))
    inputs = [base / 'manifest.json', base / 'runtime.c', assertion, Path(__file__), *headers]
    out.mkdir()
    (out / 'runtime.c').write_text((base / 'runtime.c').read_text() + '\n' + assertion.read_text())
    for path in headers:
        (out / path.name).write_bytes(path.read_bytes())
    record = dict(kind='phase110-context-call-runtime-core', complete=True, targetsRun=False,
        base=S.pin(base / 'manifest.json'), inputs=[S.pin(path) for path in inputs],
        outputs=[S.pin(out / 'runtime.c'), *[S.pin(out / path.name) for path in headers]],
        behavior='Unchanged: exact assertion-only C suffix; no functions, allocator or payload writers added',
        offsets=dict(heap=0, allocator=8), pointerBytes=8)
    (out / 'manifest.json').write_text(json.dumps(record, indent=2) + '\n')
    print(out / 'manifest.json')


if __name__ == '__main__':
    main()
