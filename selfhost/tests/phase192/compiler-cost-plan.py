#!/usr/bin/env python3
"""Freeze a paired N2 source-to-object cost recipe; execute no compiler/target."""
import argparse
import json
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]
sys.path[:0] = [str(ROOT/'selfhost/tools/bench'), str(ROOT/'selfhost/tools/build')]
import bench as B
import common as C
import request as R

CASES = ['coverage-numeric-recurrence-256', 'coverage-expression-32', 'tree-bitonic']


def prepare_role(directory, qualification, assets, out, alias):
    acquisition_pin = C.pin(directory/'report.json')
    acquisition = json.loads(C.verify(acquisition_pin).read_text())
    C.require(acquisition.get('complete') and not acquisition.get('changedInputs')
              and not acquisition.get('error'), 'Incomplete frozen acquisition: '+alias)
    rows = {row['id']: row for row in acquisition['rows']}
    result, role, binding = {}, None, None
    for case in CASES:
        row = rows[case]
        C.require(row.get('complete') and row.get('status') == 'executed-independent-oracle-pass',
                  'Missing frozen native oracle: '+alias+'/'+case)
        built = json.loads(C.verify(row['buildReceipt']).read_text())
        C.verify(row['oracleReceipt'])
        C.require(built.get('complete') and not built.get('changedInputs')
                  and built.get('emissionFormat') == R.X86_OBJECT_FORMAT,
                  'Incomplete native object build: '+alias+'/'+case)
        old = built['request']
        C.require(old['source'] == row['source'] and built['object'] == row['object'],
                  'Frozen source/object binding differs: '+alias+'/'+case)
        C.verify(row['object'])
        for pin in old['inputs']:
            C.verify(pin)
        image = Path(old['image']['file'])
        parser = argparse.ArgumentParser()
        R.arguments(parser)
        args = parser.parse_args(['--workspace', str(ROOT), '--assets', str(assets),
            '--image', str(image), '--image-receipt', str(image.parent/'report.json'),
            '--source', row['source']['file'], '--host', 'native', '--stage', 'N2',
            '--target', 'x86', '--emit', 'object', '--mode', 'cache',
            '--expected-object', row['object']['file'], '--seconds', '60',
            '--out', str(out/(alias+'-'+case))])
        planned = R.plan(args)  # Authentication and argv construction only; never execute().
        C.require(planned['imageMetadata']['protocol'] == 'native-x86-source-v1'
                  and planned['outputContract'] == 'stdout', 'Unexpected compiler protocol')
        C.require(planned['command'] == old['command'], 'Request differs from frozen acquisition')
        C.require(planned['expected'] == row['object'], 'Expected object differs from frozen product')
        phase = 'phase191' if alias == 'baseline' else 'phase192'
        compiler_source = C.pin(ROOT/'selfhost/build'/phase/'selected-source01/compiler.bend')
        C.require(planned['imageMetadata']['sourceIdentity'] == compiler_source,
                  'Compiler is not bound to the selected phase source: '+alias)
        identity = [planned[k] for k in ('image', 'imageMetadata', 'base', 'carrier', 'stamp')]
        if binding is not None:
            C.require(identity == binding, 'Mixed compiler/preparation within role')
        binding = identity
        inputs = [*planned['inputs'], acquisition_pin, row['buildReceipt'], row['oracleReceipt'],
                  C.pin(__file__), C.pin(qualification), compiler_source]
        result[case] = dict(scope='request', command=planned['command'], stdout=row['object'],
            stderr=str(ROOT/'selfhost/tools/bench/examples/expected-empty.stderr'), inputs=inputs)
        role = dict(host='native', stage='N2', target='x86', emit='object',
            preparation='cache', policy='ordinary-single-cpu',
            status='explicit-N2-bindings; qualification-receipt-pinned-not-reproved',
            compiler=planned['image'], runtime=planned['imageRuntime'],
            qualification=C.pin(qualification), inputs=[acquisition_pin, C.pin(__file__)])
    return role, result, rows, binding


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--baseline-build', type=Path, default=ROOT/'selfhost/build/phase191/native45-02')
    parser.add_argument('--baseline-qualification', type=Path, default=ROOT/'implementation/phase191/evidence.json')
    parser.add_argument('--candidate-build', type=Path, required=True)
    parser.add_argument('--candidate-qualification', type=Path, required=True)
    parser.add_argument('--assets', type=Path, default=ROOT/'selfhost/build/phase192/assets.json')
    parser.add_argument('--out', type=Path, required=True)
    args = parser.parse_args()
    prepared = {}
    for alias in ['baseline', 'candidate']:
        prepared[alias] = prepare_role(getattr(args, alias+'_build').resolve(),
            getattr(args, alias+'_qualification').resolve(), args.assets.resolve(), args.out.resolve(), alias)
    a, b = prepared['baseline'], prepared['candidate']
    C.require(a[3][0] != b[3][0], 'Baseline and candidate compiler identities must differ')
    C.require(a[3][2:] == b[3][2:], 'Base/carrier/stamp must be identical across roles')
    C.require(a[0]['runtime'] == b[0]['runtime'], 'Compiler linked runtimes must match')
    cases = []
    for case in CASES:
        C.require(a[2][case]['source'] == b[2][case]['source'], 'Source must match across roles: '+case)
        cases.append(dict(id=case, source=a[2][case]['source'],
            requests={alias: value[1][case] for alias, value in prepared.items()}))
    out = C.fresh_output(args.out, ROOT)
    scope = ('Fresh N2 compiler process source-to-object cost; no linking or program runtime. '
             'Each role must reproduce its own frozen complete object exactly. Two balanced rounds. '
             'Qualification receipts are pinned, not independently established by this metadata helper.')
    C.write_json(out/'recipe.json', dict(kind='compiler', cwd=str(ROOT), reference='baseline',
        roles={alias: value[0] for alias, value in prepared.items()}, cases=cases, scope=scope))
    B.freeze(out/'recipe.json', out/'manifest.json')
    C.write_json(out/'report.json', dict(kind='phase192-compiler-cost-preparation', complete=True,
        targetsRun=False, manifest=C.pin(out/'manifest.json'), cases=CASES, rounds=2,
        requests=12, budgetSeconds=60, scope=scope))
    print(out/'manifest.json')


if __name__ == '__main__':
    main()
