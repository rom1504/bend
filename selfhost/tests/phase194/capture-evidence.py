#!/usr/bin/env python3
"""Authenticate final Phase194 receipts/products; never execute targets."""
import argparse
import hashlib
import json
from pathlib import Path
ROOT = Path(__file__).resolve().parents[3]
BUILD = ROOT / 'selfhost/build/phase194'
SOURCE = '4b29752fec8fbdb593a86b80f99ea18b7705dfc9fe56a364280bebb1f46c5e63'

def pin(path):
    path = Path(path)
    data = path.read_bytes()
    return dict(file=str(path.relative_to(ROOT)), bytes=len(data), sha256=hashlib.sha256(data).hexdigest())

def same_identity(actual, expected):
    assert Path(actual['file']).resolve() == Path(expected['file']).resolve(), 'Artifact path differs'
    assert all(actual[key] == expected[key] for key in ('bytes', 'sha256')), 'Artifact identity differs'

def authenticate(expected):
    actual = pin(Path(expected['file']))
    same_identity(actual, expected)
    return actual

def read(name):
    return json.loads((BUILD/name/'report.json').read_text())

def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--out', type=Path, required=True)
    args = parser.parse_args()
    assert not args.out.exists(), 'Fresh evidence output required'
    names = ['selected-source-check03', 'float-controls01', 'predicate-controls01',
        'combined-float-controls02', 'combined-predicate-controls02', 'stress-controls03',
        'commutative-controls01', 'final-api01', 'final-dev-build01',
        'hosted-native-compare01', 'native-image01', 'native-self01',
        'native64-01', 'runtime10-01', 'native-reproduction01',
        'native45-01', 'native45-02', 'native-generations-compare01',
        'compiler-cost-n1-02', 'compiler-cost-n2-01', 'runtime02',
        'diagnostic-runtime01', 'diagnostic-commutative-runtime01']
    reports = {}
    for name in names:
        doc = read(name)
        assert doc.get('complete') is True and not doc.get('error') and not doc.get('changedInputs'), name
        reports[name] = pin(BUILD/name/'report.json')
    for name in ('native64-01', 'runtime10-01'):
        assert read(name)['passed'] is True, name
    for name in ('native45-01', 'native45-02'):
        assert len(read(name)['rows']) == 45, name
    source = pin(BUILD/'selected-source02/compiler.bend')
    assert source['sha256'] == SOURCE
    checked = read('selected-source-check03')
    assert checked['checked'] and checked['unresolvedHoles'] == 0
    assert all(checked['source'][key] == source[key] for key in ('bytes', 'sha256'))
    for name in ('native-image01', 'native-self01', 'native-reproduction01'):
        assert all(read(name)['request']['source'][key] == source[key] for key in ('bytes', 'sha256')), name
    assert read('hosted-native-compare01')['comparedCases'] == 6
    comparison = read('native-generations-compare01')
    assert comparison['objectsIdentical'] == 45 and comparison['linkedSectionsIdentical'] == 135
    # Authenticate current products against the original qualification bindings,
    # rather than merely recording fresh hashes after qualification.
    for name in ('native-image01', 'native-self01', 'native-reproduction01'):
        built = read(name)
        authenticate(built['binary'])
        same_identity(built['binary'], built['imageBinding']['image'])
        same_identity(source, built['imageBinding']['sourceIdentity'])
        if 'object' in built:
            authenticate(built['object'])
    n1, n2 = read('native-image01')['binary'], read('native-self01')['binary']
    same_identity(read('native-self01')['request']['image'], n1)
    same_identity(read('native-reproduction01')['request']['image'], n2)
    for name in ('native64-01', 'runtime10-01'):
        same_identity(read(name)['image'], n2)
    for name, compiler in (('native45-01', n1), ('native45-02', n2)):
        role = read(name)['roles']['candidate']
        same_identity(role['compiler'], compiler)
        same_identity(role['compilerSource'], source)
    timing = read('runtime02')
    same_identity(timing['roles']['candidate']['compiler'], n2)
    same_identity(timing['roles']['candidate']['compilerSource'], source)
    partition = json.loads((ROOT/'selfhost/tests/phase194/cases.json').read_text())
    expected_cases = set(partition['development'] + partition['heldout'])
    assert timing['fullCatalog'] is True and len(expected_cases) == 45
    assert len(timing['selectedCaseIds']) == 45 and set(timing['selectedCaseIds']) == expected_cases
    assert len(timing['cases']) == 45 and {row['id'] for row in timing['cases']} == expected_cases
    assert read('native-reproduction01')['comparedToReference'] is True
    assert (BUILD/'native-self01/program.o').read_bytes() == (BUILD/'native-reproduction01/program.o').read_bytes()
    for name in ('diagnostic-runtime01', 'diagnostic-commutative-runtime01'):
        doc = read(name)
        assert doc['diagnosticOnly'] is True and doc['native45Membership'] is False
        assert len(doc['correctness']) == 96 and all(row['correct'] for row in doc['correctness'])
    artifacts = ['selected-source02/compiler.bend', 'selected-source02/compiler.bend.map.json',
        'native-self01/program', 'native-self01/program.o', 'assets.json',
        'final-api-source01/compiler.bend', 'references01/manifest.json']
    result = dict(kind='phase194-qualified-evidence', version=1, complete=True,
        baselineCommit='ad9b27d', designCommit='969e335', installedSelectionChanged=False,
        method=pin(__file__), reports=reports,
        artifacts={name:pin(BUILD/name) for name in artifacts},
        qualification='Source acceptance; finite component/machine controls; six exact B1/N1 products; all45 N1/N2 objects and135 linked sections; N2/N3 exact compiler object; native64/runtime10; immutable45 output/runtime observations.',
        scope='Program runtime, compiler cost and diagnostic discovery remain separate. Twelve diagnostics are outside native45. No new BendTT theorem, whole-compiler proof, installed promotion, or recursive-acceleration claim.')
    args.out.parent.mkdir(parents=True, exist_ok=True)
    args.out.write_text(json.dumps(result,indent=2)+'\n')
    print(json.dumps(dict(complete=True, reports=len(reports), out=str(args.out))))

if __name__ == '__main__':
    main()
