#!/usr/bin/env python3
"""Materialize additive ABI v2 over an authenticated Phase109 runtime receipt.

No target compiler or executable runs. The complete previous source is retained
as a byte prefix; this addition never rewrites allocator or ownership helpers.
"""
import argparse
import hashlib
import json
from pathlib import Path

HERE = Path(__file__).resolve().parent
ROOT = HERE.parents[4]

def pin(path):
    raw = path.read_bytes()
    return dict(file=str(path.resolve()), bytes=len(raw), sha256=hashlib.sha256(raw).hexdigest())

def authenticate(record):
    if pin(Path(record['file'])) != record:
        raise ValueError('changed authenticated input: ' + record['file'])

def main():
    p = argparse.ArgumentParser(description=__doc__)
    p.add_argument('--base', type=Path, required=True)
    p.add_argument('--out', type=Path, required=True)
    a = p.parse_args()
    base, out = a.base.resolve(), a.out.resolve()
    if out.exists() or not out.is_relative_to(ROOT / 'selfhost/build/phase110'):
        raise ValueError('fresh output required under selfhost/build/phase110')
    manifest = base / 'manifest.json'
    facts = json.loads(manifest.read_text())
    if facts.get('kind') != 'phase109-production-runtime-core' or not facts.get('complete'):
        raise ValueError('requires complete Phase109 runtime materialization')
    if facts['base']['sha256'] != '9e1c59078878be94052cb4d2d63a713e19e29b41ed3f94b034f2175a50efd0a9':
        raise ValueError('unknown production TermABI')
    for record in [facts['base'], *facts['inputs'], *facts['outputs']]:
        authenticate(record)
    source = (base / 'runtime.c').read_text()
    aux = 'INLINE u64 term_aux(Term t) {\n  return (t >> 40) & 0xFFFF;\n}'
    if source.count(aux) != 1:
        raise ValueError('authenticated TermABI accessor differs')
    out.mkdir(parents=True)
    (out / 'runtime.c').write_text(source + '\n' + (HERE / 'adapter.inc.c').read_text())
    (out / 'abi.h').write_bytes((base / 'abi.h').read_bytes())
    (out / 'abi-extension.h').write_bytes((HERE / 'abi-extension.h').read_bytes())
    record = dict(kind='phase110-additive-runtime-core', version=2, complete=True,
        targetsRun=False, productionWorkers=facts['productionWorkers'],
        inputs=[pin(manifest), *facts['outputs'], pin(Path(__file__)),
                pin(HERE / 'adapter.inc.c'), pin(HERE / 'abi-extension.h')],
        termABI=dict(auxShift=40, auxMask=65535, authenticatedAccessor=aux,
                     semantics='Pure borrowed constructor identity on admitted Terms'),
        specializedDescriptors=[dict(cid=c, keepIndex=k) for c in [1,3] for k in [0,1]],
        pairABI=dict(cType='struct NxRtPair', fields=['first:u64:built:owned', 'second:u64:remaining:owned'],
                     bytes=16, scratch='not read or written',
                     callingConvention='platform C aggregate; inspect actual QBE/Clang code'),
        ownership='Exact ctr_take, heap_alloc, rfc_seal; reuse only spare >= HEAP_OFF',
        outputs=[pin(out / n) for n in ['runtime.c', 'abi.h', 'abi-extension.h']])
    (out / 'manifest.json').write_text(json.dumps(record, indent=2) + '\n')
    print(json.dumps(record))

if __name__ == '__main__':
    main()
