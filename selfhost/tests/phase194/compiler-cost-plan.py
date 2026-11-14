#!/usr/bin/env python3
"""Prepare Phase193/194 paired compiler requests using the Phase193 validator; no targets."""
import argparse
import importlib.util
import json
from pathlib import Path
import sys

sys.dont_write_bytecode = True
ROOT = Path(__file__).resolve().parents[3]
METHOD = ROOT/'selfhost/tests/phase193/compiler-cost-plan-v2.py'
spec = importlib.util.spec_from_file_location('phase193_cost', METHOD)
P = importlib.util.module_from_spec(spec)
spec.loader.exec_module(P)
B, C = P.B, P.C


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--stage', choices=['N1', 'N2'], required=True)
    parser.add_argument('--source', type=Path, required=True)
    parser.add_argument('--candidate-build', type=Path, required=True)
    parser.add_argument('--assets', type=Path, default=ROOT/'selfhost/build/phase194/assets.json')
    parser.add_argument('--out', type=Path, required=True)
    args = parser.parse_args()
    baseline = ROOT/'selfhost/build/phase193'/('budget-native45-01' if args.stage == 'N1' else 'budget-native45-02')
    prepared = {}
    for alias, directory, source, qualification in [
        ('baseline', baseline, ROOT/'selfhost/build/phase193/selected-source02/compiler.bend', ROOT/'implementation/phase193/evidence.json'),
        ('candidate', args.candidate_build, args.source, None),
    ]:
        # The reused validator's candidate branch accepts an explicit source;
        # its baseline branch is historically fixed to Phase192. Both calls
        # therefore use that explicit-source branch, then receive logical roles.
        prepared[alias] = P.prepare_role(directory.resolve(), qualification, args.assets.resolve(),
            args.out.resolve()/alias, 'candidate', args.stage, source.resolve())
    a, b = prepared['baseline'], prepared['candidate']
    C.require(a[3][0] != b[3][0] and a[3][2:] == b[3][2:] and a[0]['runtime'] == b[0]['runtime'],
              'Different compilers with identical Base/carrier/stamp/runtime required')
    if args.stage == 'N1':
        C.require(all(a[4]['request'][k] == b[4]['request'][k] for k in ('image', 'imageMetadata'))
                  and a[4]['toolchain'] == b[4]['toolchain'], 'Identical QBE producer/toolchain required')
    cases = []
    for name in P.CASES:
        C.require(a[2][name]['source'] == b[2][name]['source']
                  and a[1][name]['command'][1:] == b[1][name]['command'][1:],
                  'Exact request input/preparation differs: '+name)
        cases.append(dict(id=name, source=a[2][name]['source'],
            requests={alias: value[1][name] for alias, value in prepared.items()}))
    for value in prepared.values():
        value[0]['inputs'] += [C.pin(__file__)]
    output = C.fresh_output(args.out, ROOT)
    scope = ('Two balanced rounds of four complete source-to-object requests; fresh processes, cached Base, '
        'own-role exact object oracles. Same request input, different compiler source. '
        'N1 compares under a common QBE producer; N2 measures the net x86 compiler change. '
        'No linking, program execution, statistical significance or research-throughput claim.')
    C.write_json(output/'recipe.json', dict(kind='compiler', cwd=str(ROOT), reference='baseline',
        roles={alias: value[0] for alias, value in prepared.items()}, cases=cases, scope=scope))
    B.freeze(output/'recipe.json', output/'manifest.json')
    C.write_json(output/'report.json', dict(kind='phase194-compiler-cost-preparation', complete=True,
        targetsRun=False, stage=args.stage, method=C.pin(__file__), inheritedMethod=C.pin(METHOD),
        manifest=C.pin(output/'manifest.json'), source=C.pin(args.source), rounds=2, requests=16, scope=scope))
    print(output/'manifest.json')


if __name__ == '__main__':
    main()
