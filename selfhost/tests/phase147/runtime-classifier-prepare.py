#!/usr/bin/env python3
"""Prepare finite controls for the current production classifier; run no targets."""
import argparse
import hashlib
import json
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]
sys.dont_write_bytecode = True
sys.path.insert(0, str(ROOT / 'experiments/phase147/tools'))
from prepare import assembly, extract, fresh_output, guard, pin, require, write_json


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--out', required=True, type=Path)
    args = parser.parse_args()
    out = fresh_output(args.out, ROOT)
    recipe = ROOT / 'selfhost/src/compiler.json'
    canonical = assembly.maintained_assemble(recipe, ROOT / 'selfhost', 'qbe')
    fixture = ROOT / 'selfhost/tests/phase147/runtime-classifier-cases.json'
    cases = json.loads(fixture.read_text())
    require(cases['kind'] == 'phase147-runtime-classifier-cases' and cases['complete'], 'Invalid cases')
    require(len(cases['cases']) == 677 and len(set(cases['accepted'])) == 25, 'Reviewed corpus changed')
    require(len({row['symbol'] for row in cases['cases']}) == 677, 'Duplicate cases')
    require(all(type(row['expected']) is bool and row['expected'] == (row['symbol'] in cases['accepted'])
                for row in cases['cases']), 'Closed-set oracle inconsistent')
    body, declarations = extract([('canonical', canonical)], ['p118z_runtime'], 100_000)
    (out / 'api.bend').write_bytes(body)
    write_json(out / 'exports.json', dict(kind='bend-hosted-api-exports', version=1,
        exports=['p118z_runtime'], protocol='hosted-api-v1', targets=['qbe'],
        preparationModes=['live'], scope='Current exact classifier closure, finite controls only.'))
    inputs = [pin(__file__), pin(ROOT / 'experiments/phase147/tools/prepare.py'), pin(assembly.__file__),
              pin(recipe), pin(ROOT / 'selfhost/src/back/qbe/ownership.bend'), pin(fixture),
              pin(ROOT / 'selfhost/tests/phase147/runtime-classifier-check.mjs'),
              pin(ROOT / 'experiments/phase147/tools/support.mjs')]
    report = dict(kind='phase147-current-runtime-classifier', complete=True, targetsRun=False,
        canonicalSourceIdentity=dict(bytes=len(canonical), sha256=hashlib.sha256(canonical).hexdigest()),
        apiSource=pin(out / 'api.bend'), exports=pin(out / 'exports.json'), cases=pin(fixture),
        declarations=declarations, inputs=inputs,
        scope='Exact production extraction. Finite independent closed-set expectations; no universal proof, native lifetime or compiler image qualification.')
    write_json(out / 'manifest.json', report)
    bun = ROOT / 'selfhost/.assets/bin/bun'
    jobs = [guard('classifier-checked-api', out / 'api', [bun, ROOT / 'selfhost/tools/build/hosted.mjs',
        'acquire', '--source', out / 'api.bend', '--exports', out / 'exports.json', '--upstream',
        ROOT / 'selfhost/.bootstrap/upstream-phase66', '--engine', bun, '--out', out / 'api'], 90, 2048, 128),
        guard('classifier-finite-controls', out / 'controls', [bun,
        ROOT / 'selfhost/tests/phase147/runtime-classifier-check.mjs', '--preparation',
        out / 'manifest.json', '--out', out / 'controls'], 30, 1024, 32)]
    write_json(out / 'jobs.json', jobs)
    print(json.dumps(dict(complete=True, targetsRun=False, cases=677, declarations=len(declarations),
                         source=report['canonicalSourceIdentity'], jobs=str(out / 'jobs.json'))))


if __name__ == '__main__':
    main()
