#!/usr/bin/env python3
"""Versioned compiler-cost adapter with explicit candidate-source identity.

Uses maintained request planning and bench freezing; executes no targets.
"""
import argparse
import json
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]
sys.path[:0] = [str(ROOT/'selfhost/tools/bench'), str(ROOT/'selfhost/tools/build')]
import bench as B
import common as C
import request as R

CASES = ['coverage-numeric-recurrence-256', 'coverage-expression-32', 'tree-bitonic', 'test-map-set-ops']
PARENT_METHOD = ROOT/'selfhost/tests/phase192/compiler-cost-plan.py'


def prepare_role(directory, qualification, assets, out, alias, stage, candidate_source=None):
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
            '--source', row['source']['file'], '--host', 'native', '--stage', stage,
            '--target', 'x86', '--emit', 'object', '--mode', 'cache',
            '--expected-object', row['object']['file'], '--seconds', '60',
            '--out', str(out/(alias+'-'+case))])
        planned = R.plan(args)  # Authentication and argv construction only; never execute().
        C.require(planned['imageMetadata']['protocol'] == 'native-x86-source-v1'
                  and planned['outputContract'] == 'stdout', 'Unexpected compiler protocol')
        C.require(planned['command'] == old['command'], 'Request differs from frozen acquisition')
        C.require(planned['expected'] == row['object'], 'Expected object differs from frozen product')
        phase = 'phase192' if alias == 'baseline' else 'phase193'
        source_path = candidate_source if alias == 'candidate' and candidate_source is not None else ROOT/'selfhost/build'/phase/'selected-source01/compiler.bend'
        compiler_source = C.pin(source_path)
        C.require(planned['imageMetadata']['sourceIdentity'] == compiler_source,
                  'Compiler is not bound to the selected phase source: '+alias)
        image_receipt = json.loads(C.verify(C.pin(image.parent/'report.json')).read_text())
        C.require(image_receipt.get('complete') and not image_receipt.get('changedInputs')
                  and image_receipt.get('target') == ('qbe' if stage == 'N1' else 'x86'),
                  'Wrong/incomplete actual image producer target: '+alias)
        C.require(image_receipt['imageBinding'] == planned['imageMetadata'],
                  'Image receipt and request binding differ')
        identity = [planned[k] for k in ('image', 'imageMetadata', 'base', 'carrier', 'stamp')]
        if binding is not None:
            C.require(identity == binding, 'Mixed compiler/preparation within role')
        binding = identity
        inputs = [*planned['inputs'], acquisition_pin, row['buildReceipt'], row['oracleReceipt'],
                  C.pin(__file__), C.pin(PARENT_METHOD), C.pin(Path(__file__).with_name('compiler-cost-plan.py')), compiler_source]
        if qualification:
            inputs.append(C.pin(qualification))
        result[case] = dict(scope='request', command=planned['command'], stdout=row['object'],
            stderr=str(ROOT/'selfhost/tools/bench/examples/expected-empty.stderr'), inputs=inputs)
        role = dict(host='native', stage=stage, target='x86', emit='object',
            preparation='cache', policy='ordinary-single-cpu',
            status='explicit-'+stage+'-bindings; frozen-products-pass; candidate-bootstrap-not-inferred',
            compiler=planned['image'], runtime=planned['imageRuntime'],
            inputs=[acquisition_pin, C.pin(__file__), C.pin(PARENT_METHOD)])
        if qualification:
            role['qualification'] = C.pin(qualification)
    return role, result, rows, binding, image_receipt


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--stage', choices=['N1', 'N2'], required=True)
    parser.add_argument('--baseline-build', type=Path)
    parser.add_argument('--baseline-qualification', type=Path, default=ROOT/'implementation/phase192/evidence.json')
    parser.add_argument('--candidate-build', type=Path, required=True)
    parser.add_argument('--candidate-source', type=Path,
                        default=ROOT/'selfhost/build/phase193/selected-source01/compiler.bend',
                        help='Exact frozen source bound by the candidate image; no identity inference')
    parser.add_argument('--candidate-qualification', type=Path,
                        help='Optional completed qualification evidence; N1 admission does not require N2 qualification')
    parser.add_argument('--assets', type=Path, default=ROOT/'selfhost/build/phase192/assets.json')
    parser.add_argument('--out', type=Path, required=True)
    args = parser.parse_args()
    if args.baseline_build is None:
        args.baseline_build = ROOT/'selfhost/build/phase192'/('native45-01' if args.stage == 'N1' else 'native45-02')
    prepared = {}
    for alias in ['baseline', 'candidate']:
        prepared[alias] = prepare_role(getattr(args, alias+'_build').resolve(),
            getattr(args, alias+'_qualification'), args.assets.resolve(), args.out.resolve(), alias, args.stage, args.candidate_source.resolve())
    a, b = prepared['baseline'], prepared['candidate']
    C.require(a[3][0] != b[3][0], 'Baseline and candidate compiler identities must differ')
    C.require(a[3][2:] == b[3][2:], 'Base/carrier/stamp must be identical across roles')
    C.require(a[0]['runtime'] == b[0]['runtime'], 'Compiler linked runtimes must match')
    if args.stage == 'N1':
        for key in ('image', 'imageMetadata'):
            C.require(a[4]['request'][key] == b[4]['request'][key],
                      'N1 images must use the identical QBE producer binding: '+key)
        C.require(a[4]['toolchain'] == b[4]['toolchain'], 'N1 machine toolchains differ')
    cases = []
    for case in CASES:
        C.require(a[2][case]['source'] == b[2][case]['source'], 'Source must match across roles: '+case)
        C.require(a[1][case]['command'][1:] == b[1][case]['command'][1:],
                  'Exact request arguments differ across roles: '+case)
        cases.append(dict(id=case, source=a[2][case]['source'],
            requests={alias: value[1][case] for alias, value in prepared.items()}))
    out = C.fresh_output(args.out, ROOT)
    scope = ('Fresh '+args.stage+' compiler process source-to-object cost; no linking or program runtime. '
             'Each role must reproduce its own frozen complete object exactly. Two balanced rounds. '
             'Qualification receipts, if supplied, are pinned, not independently established. '
             + ('N1 compares new compiler source under the identical QBE producer/toolchain; '
                'generated layout can also differ. N2 qualification is deliberately not inferred.'
                if args.stage == 'N1' else
                'N2 compares the net compiler-source change and its x86-generated implementation.'))
    C.write_json(out/'recipe.json', dict(kind='compiler', cwd=str(ROOT), reference='baseline',
        roles={alias: value[0] for alias, value in prepared.items()}, cases=cases, scope=scope))
    B.freeze(out/'recipe.json', out/'manifest.json')
    C.write_json(out/'report.json', dict(kind='phase193-compiler-cost-preparation', complete=True, stage=args.stage,
        targetsRun=False, manifest=C.pin(out/'manifest.json'), cases=CASES, rounds=2,
        requests=16, budgetSeconds=60, guardSeconds=70, diskMiB=128,
        baselineAcquisition=C.pin(args.baseline_build/'report.json'),
        candidateAcquisition=C.pin(args.candidate_build/'report.json'),
        candidateSource=C.pin(args.candidate_source), scope=scope))
    print(out/'manifest.json')


if __name__ == '__main__':
    main()
