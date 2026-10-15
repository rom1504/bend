#!/usr/bin/env python3
"""Data-only accounting of accepted laws on the actual minimal origin candidate."""
import argparse
import hashlib
import json
from pathlib import Path

HERE = Path(__file__).resolve().parent
ROOT = HERE.parents[2]
BUILD = ROOT / 'selfhost/build/phase98'
SOURCE_SHA = '2a72bbdc3d757982d7dd4804d8a1312f9427e3b2822ed9d187424c2d9f4de051'


def pin(path):
    path = Path(path).resolve()
    data = path.read_bytes()
    return dict(file=str(path), bytes=len(data), sha256=hashlib.sha256(data).hexdigest())


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--catalog', type=Path, required=True)
    parser.add_argument('--out', type=Path, required=True)
    args = parser.parse_args()
    out = args.out.resolve()
    assert out.is_relative_to(BUILD) and not out.exists()
    inputs = {}

    def bind(path):
        row = pin(path)
        assert inputs.setdefault(row['file'], row) == row
        return row

    def verify(value):
        if isinstance(value, dict):
            if {'file', 'bytes', 'sha256'} <= value.keys():
                assert bind(value['file']) == value
            else:
                for item in value.values():
                    verify(item)
        elif isinstance(value, list):
            for item in value:
                verify(item)

    def read(path):
        binding = bind(path)
        data = json.loads(Path(binding['file']).read_text())
        verify(data)
        return data

    source = bind(BUILD / 'origin-guard-source01/compiler.bend')
    assert source['sha256'] == SOURCE_SHA
    source_text = Path(source['file']).read_text()
    recipe = read(BUILD / 'origin-guard-source01/changes.json')
    assert recipe['candidate'] == source and len(recipe['localChanges']) == 1
    assert recipe['localChanges'][0]['function'] == 'noa_below'
    catalog = read(args.catalog)
    assert catalog['complete'] and catalog['targetsRun'] is False
    roles = {law['name']: law['role'] for law in catalog['laws']}
    instances = {row['report']['file']: row for row in catalog['acceptedInstances']}
    accepted = []
    names = set()
    for package, entry, expected_count in [('tag', 'tag.bend', 6), ('membership', 'bridge.bend', 9)]:
        prepared = BUILD / ('origin-' + package + '-proof-source01')
        manifest_file = prepared / 'manifest.json'
        check_file = BUILD / ('origin-' + package + '-proof-check01/report.json')
        manifest = read(manifest_file)
        report = read(check_file)
        assert manifest['candidate'] == source and manifest['targetsRun'] is False
        assert manifest['entry'] == str(prepared / entry)
        assert report['complete'] and report['independentlyChecked'] and report['inputsUnchanged']
        assert report['sourceOnly'] is False and not report['opaqueDefinitions']
        assert report['source'] == bind(prepared / entry)
        assert len(report['lawNames']) == expected_count
        assert instances[str(check_file)]['report'] == bind(check_file)
        assert instances[str(check_file)]['lawNames'] == report['lawNames']
        closure = {row['origin']['file']: row for row in report['sourceClosure']}
        for path in prepared.glob('*.bend'):
            assert str(path) in closure, ('Prepared module absent from accepted closure', path)
            row = closure[str(path)]
            assert row['origin'] == bind(path)
            assert Path(row['snapshot']['file']).read_bytes() == path.read_bytes()
        if package == 'tag':
            extraction = manifest
            expected_candidate = 'import Base\n\n' + ''.join(row['extracted'] for row in extraction['candidateDefinitions'])
        else:
            extraction = read(manifest['originalExtraction']['file'])
            assert extraction['candidate'] == source
            old_member = manifest['definition']
            assert source_text.count(old_member['original']) == 1
            assert old_member['extracted'] == old_member['original'].removeprefix('@unsafe\n')
            expected_candidate = (prepared / 'extracted/candidate.bend').read_text() + old_member['extracted']
        assert (prepared / 'candidate.bend').read_text() == expected_candidate
        for declaration in extraction['candidateDefinitions']:
            assert source_text.count(declaration['original']) == 1
            assert declaration['extracted'] == declaration['original'].removeprefix('@unsafe\n')
        names.update(report['lawNames'])
        accepted.append(dict(package=package, preparation=bind(manifest_file), check=bind(check_file),
                             lawNames=report['lawNames'], definitions=len(report['definitions']),
                             targetSeconds=sum(row['process']['wallSeconds'] for row in report['rows'].values())))
    public = sorted(name for name in names if roles[name] == 'public')
    support = sorted(name for name in names if roles[name] == 'support')
    assert len(names) == 13 and len(public) == 8 and len(support) == 5
    for row in inputs.values():
        assert pin(row['file']) == row
    result = dict(kind='phase98-origin-source-accepted-law-account', complete=True, targetsRun=False,
                  method=pin(__file__), source=source, recipe=bind(BUILD / 'origin-guard-source01/changes.json'),
                  catalog=bind(args.catalog), acceptedPackages=accepted,
                  sourceCounts=dict(public=len(public), support=len(support), distinctNames=len(names),
                                    repeatedLawInstances=sum(len(row['lawNames']) for row in accepted)),
                  publicLaws=public, supportLemmas=support, inputsUnchanged=True,
                  interpretation=[
                      'Two freshly checked closures bind the exact current compiler; membership includes all seven permission laws.',
                      'The six-law and nine-law closures share two comparator laws, yielding thirteen names, eight public and five support.',
                      'These are existing contracts checked on another implementation instance; no new named law is added.',
                      'The changed unsafe noa_below recursion guard is outside these safe extracted declarations and laws.',
                      'Origin finite controls and generated-C inspection are separate evidence; no origin termination or native evaluation theorem is claimed.',
                      'The larger catalog includes historical and unpromoted packages, including redirect/cache work absent from this compiler.',
                      'This account runs no compiler or proof target and does not qualify or promote an image.'],
                  inputs=list(inputs.values()))
    out.parent.mkdir(parents=True, exist_ok=True)
    out.write_text(json.dumps(result, indent=2) + '\n')
    print(json.dumps(dict(complete=True, targetsRun=False, sourceCounts=result['sourceCounts'], out=str(out))))


if __name__ == '__main__':
    main()
