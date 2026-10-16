#!/usr/bin/env python3
"""Recompute current independent app oracles against preserved successful runs."""
import argparse
import importlib.util
import json
from pathlib import Path
import shutil
import sys
sys.dont_write_bytecode = True
HERE = Path(__file__).resolve().parent
spec = importlib.util.spec_from_file_location('app_methods', HERE / 'run.py')
M = importlib.util.module_from_spec(spec)
spec.loader.exec_module(M)


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--out', required=True, type=Path)
    args = parser.parse_args()
    out = args.out.resolve()
    assert out.is_relative_to(M.ROOT / 'selfhost/build/phase100') and not out.exists()
    out.mkdir(parents=True)
    expected = {}
    runs = []
    for path in sorted((M.ROOT / 'selfhost/build/phase100').glob('*/report.json')):
        run = M.read(path)
        if run.get('kind') != 'phase100-applications-measure' or not run['complete']:
            continue
        runs.append(M.pin(path))
        for case in run['cases']:
            M.verify(case['expected'])
            value = Path(case['expected']['file']).read_bytes()
            key = (case['app'], case['id'])
            assert expected.setdefault(key, value) == value, key
    report = dict(kind='phase100-current-oracle-audit', complete=False,
                  targetsExecuted=False, method=M.pin(__file__), runs=runs, oracles=[], cases=[])
    M.save(out / 'audit.json', report)
    try:
        for app in M.APPS:
            path = M.ROOT / 'selfhost/apps' / app / 'oracle.py'
            identity = M.pin(path)
            report['oracles'].append(identity)
            shutil.copyfile(path, out / (app + '-oracle.py'))
            oracle = M.module('audit_' + app.replace('-', '_'), path)
            for row in oracle.cases(out / app, depth='survey'):
                key = (app, row['id'])
                assert key in expected and row['expected'].encode() == expected[key], key
                report['cases'].append(dict(app=app, id=row['id'], exact=True))
            M.verify(identity)
        assert {(r['app'], r['id']) for r in report['cases']} == set(expected)
        report['complete'] = True
    except Exception as error:
        report['error'] = repr(error)
        raise
    finally:
        M.save(out / 'audit.json', report)
    print(json.dumps(dict(complete=True, cases=len(report['cases']), targetsExecuted=False)))


if __name__ == '__main__':
    main()
