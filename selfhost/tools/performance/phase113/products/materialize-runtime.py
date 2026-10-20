#!/usr/bin/env python3
"""Prepare exact runtime04 prefix plus profile11301; no compilation or execution."""
import argparse
import hashlib
import json
from pathlib import Path

HERE = Path(__file__).resolve().parent
ROOT = HERE.parents[4]
BASE = ROOT / 'selfhost/build/phase111/runtime-source04'
PINNED = {
    'runtime.c': 'c0fc18aabb2749cc85b5040c29756d8d73d90b73bb954d10ed1d0d410528aa50',
    'runtime.h': 'fa91b9a250ce735aaaa59e5515efebd42b9544da825841021887406193c1d5c1',
    'primitives.h': 'ecbdfe62b875fc20e5805840b83c3779ed8fb8fb1de83c543ba1ce1217165d20',
}


def pin(path):
    data = path.read_bytes()
    return dict(file=str(path.resolve()), bytes=len(data), sha256=hashlib.sha256(data).hexdigest())


def main():
    ap = argparse.ArgumentParser(description=__doc__)
    ap.add_argument('--out', type=Path, required=True)
    args = ap.parse_args()
    out = args.out.resolve()
    if out.exists() or not out.is_relative_to(ROOT / 'selfhost/build/phase113'):
        raise ValueError('Use fresh Phase113 output')
    original = {}
    for name, sha in PINNED.items():
        path = BASE / name
        if pin(path)['sha256'] != sha:
            raise ValueError('Authenticated runtime04 changed: ' + name)
        original[name] = path.read_bytes()
    inputs = [pin(BASE / name) for name in PINNED]
    inputs += [pin(HERE / name) for name in ['materialize-runtime.py', 'runtime.inc.c', 'runtime-header.inc.h', 'imports.json']]
    out.mkdir(parents=True)
    for name, data in original.items():
        suffix = b''
        if name == 'runtime.c': suffix = b'\n' + (HERE / 'runtime.inc.c').read_bytes()
        if name == 'runtime.h': suffix = (HERE / 'runtime-header.inc.h').read_bytes()
        (out / name).write_bytes(data + suffix)
        if (out / name).read_bytes()[:len(data)] != data:
            raise ValueError('Prefix changed')
    for item in inputs:
        if pin(Path(item['file'])) != item:
            raise ValueError('Input changed during preparation')
    report = dict(kind='phase113-array-pair-runtime-source', profile=11301, stateAbi=11101,
                  complete=True, targetsExecuted=False, inputs=inputs,
                  outputs=[pin(out / name) for name in PINNED], exactRuntime04Prefix=True,
                  semantics='Existing array operations; only temporary Tuple construction removed.',
                  qualification='CPU single-thread/GPUoff runtime04 scope; separately build and qualify this additive object.')
    (out / 'manifest.json').write_text(json.dumps(report, indent=2)+'\n')
    print(json.dumps(dict(complete=True, targetsExecuted=False, output=str(out))))


if __name__ == '__main__':
    main()
