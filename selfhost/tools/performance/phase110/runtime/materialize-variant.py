#!/usr/bin/env python3
"""Freeze explicit constructor-body and atomic Take2 ABI variants, no targets.

The source prefix through the complete Phase109 adapter stays byte-identical.
Only the exact Phase110 extension suffix is substituted, if selected.
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
    p.add_argument('--construct', choices=['helper','direct'], default='helper')
    p.add_argument('--take-pair', action='store_true')
    a = p.parse_args()
    base, out = a.base.resolve(), a.out.resolve()
    if out.exists() or not out.is_relative_to(ROOT / 'selfhost/build/phase110'):
        raise ValueError('fresh output required under selfhost/build/phase110')
    manifest = base / 'manifest.json'
    facts = json.loads(manifest.read_text())
    if facts.get('kind') != 'phase110-additive-runtime-core' or not facts.get('complete'):
        raise ValueError('requires original complete Phase110 runtime materialization')
    for record in [*facts['inputs'], *facts['outputs']]:
        authenticate(record)
    source = (base / 'runtime.c').read_text()
    original = HERE / 'adapter.inc.c'
    if not any(r == pin(original) for r in facts['inputs']):
        raise ValueError('extension adapter was not authenticated by base receipt')
    suffix = original.read_text()
    if not source.endswith(suffix) or source.count(suffix) != 1:
        raise ValueError('exact extension suffix is not unique')
    inputs = [pin(manifest),*facts['outputs'],pin(Path(__file__)),pin(original)]
    if a.construct == 'direct':
        direct = HERE / 'adapter-direct.inc.c'
        source = source[:-len(suffix)] + direct.read_text()
        inputs.append(pin(direct))
    header = (base / 'abi-extension.h').read_text()
    if a.take_pair:
        take = HERE / 'take-pair.inc.c'
        source += '\n' + take.read_text()
        header += '\n/* Atomic binary ownership transfer; first/second are owned. */\nNxRtPair nx_rt_pair_take2(NxRt*, uint64_t);\n'
        inputs.append(pin(take))
    out.mkdir(parents=True)
    (out / 'runtime.c').write_text(source)
    (out / 'abi.h').write_bytes((base / 'abi.h').read_bytes())
    (out / 'abi-extension.h').write_text(header)
    record = dict(kind='phase110-explicit-runtime-variant', version=3, complete=True,
        targetsRun=False, productionWorkers=facts['productionWorkers'], inputs=inputs,
        construct=a.construct, atomicTakePair=a.take_pair, termABI=facts['termABI'],
        specializedDescriptors=facts['specializedDescriptors'], pairABI=facts['pairABI'],
        outputs=[pin(out / n) for n in ['runtime.c','abi.h','abi-extension.h']])
    (out / 'manifest.json').write_text(json.dumps(record,indent=2)+'\n')
    print(json.dumps(record))

if __name__ == '__main__':
    main()
