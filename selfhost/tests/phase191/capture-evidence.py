#!/usr/bin/env python3
"""Pin completed Phase191 evidence without executing compiler products."""
import argparse
import hashlib
import json
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]
BUILD = ROOT / 'selfhost/build/phase191'


def pin(path):
    data = path.read_bytes()
    return dict(file=str(path.relative_to(ROOT)), bytes=len(data),
                sha256=hashlib.sha256(data).hexdigest())


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--out', type=Path, required=True)
    args = parser.parse_args()
    if args.out.exists():
        parser.error('Fresh evidence output required')
    names = ['source-check01', 'controls02', 'extra-controls01',
             'native-image01', 'native-self01', 'native-reproduction01',
             'native64-01', 'runtime10-01', 'native45-01', 'native45-02',
             'hosted-native-compare01', 'native-generations-compare01',
             'unchanged-targets02', 'runtime01', 'profile-capture01', 'profile-capture03']
    reports = {}
    for name in names:
        path = BUILD / name / 'report.json'
        report = json.loads(path.read_text())
        if report.get('complete') is not True:
            raise ValueError('Incomplete required evidence: ' + name)
        reports[name] = pin(path)
    files = ['selected-source01/compiler.bend', 'selected-source01/source-map.json',
             'native-self01/program', 'native-self01/program.o',
             'runtime-summary01.json', 'family-summary01.json',
             'ablation-summary01.json', 'extra-summary01.json',
             'mini-summary01.json', 'call-summary01.json',
             'profile-plan03/plan.json', 'profile-plan03/comparison.json',
             'profile-analysis03/report.json']
    evidence = dict(kind='phase191-final-evidence', version=1, complete=True,
        baselineCommit='e4cdffa', installedSelectionChanged=False,
        method=pin(Path(__file__)),
        sourceAndProducts={name: pin(BUILD / name) for name in files},
        reports=reports,
        scope='Pins completed independent source/finite controls, runtime, native reproduction and exact cross-host products. Not a mathematical compiler-correctness proof, installed promotion, or recursive-acceleration result.')
    args.out.parent.mkdir(parents=True, exist_ok=True)
    with args.out.open('x') as output:
        json.dump(evidence, output, indent=2)
        output.write('\n')
    print(json.dumps(dict(complete=True, reports=len(reports), out=str(args.out))))


if __name__ == '__main__':
    main()
