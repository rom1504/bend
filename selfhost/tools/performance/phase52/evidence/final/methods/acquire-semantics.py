#!/usr/bin/env python3
"""Serial checked acquisition for mixed library/program semantic fixtures."""
import argparse
import json
from pathlib import Path
import shutil
import sys
import time

HERE = Path(__file__).resolve().parent
sys.path.insert(0, str(HERE.parent / 'programs'))
from support import ExecutionGuard, identity, save


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--catalog', type=Path, required=True)
    parser.add_argument('--selection', required=True, help='upstream:CHECKOUT or checked ATTEMPT directory')
    parser.add_argument('--role', choices=['typescript', 'direct'], required=True)
    parser.add_argument('--out', type=Path, required=True)
    parser.add_argument('--node', type=Path, default=Path('/home/ai/.nvm/versions/node/v24.18.0/bin/node'))
    args = parser.parse_args()
    assert args.selection.startswith('upstream:') == (args.role == 'typescript')
    catalog = args.catalog.resolve(strict=True)
    data = json.loads(catalog.read_text())
    assert data['kind'] == 'phase52-direct-semantic-catalog' and data['schemaVersion'] == 1
    out = args.out.resolve()
    assert not out.exists()
    pins = [identity(file) for file in [__file__, catalog, args.node, HERE / 'emit-worker.mjs', HERE.parent / 'programs/support.py']]
    cases = data['cases']
    assert len({c['id'] for c in cases}) == len(cases)
    for case in cases:
        assert case['id'].replace('-', '').replace('_', '').isalnum()
        assert case['mode'] in ['library', 'program']
        for entry in [case['source'], *case.get('auxiliary', [])]:
            relative = Path(entry['path'])
            assert not relative.is_absolute() and '..' not in relative.parts
            file = (catalog.parent / relative).resolve(strict=True)
            assert file.is_relative_to(catalog.parent)
            row = identity(file)
            assert row['sha256'] == entry['sha256']
            pins.append(row)
    role = dict(modules={})
    if args.role == 'direct':
        attempt = Path(args.selection).resolve(strict=True)
        row = identity(attempt / 'attempt.json')
        pins.append(row)
        role['attempt'] = dict(file=row['path'], sha256=row['sha256'])
    manifest = dict(kind='phase52-semantic-acquisition', complete=False, passed=False,
                    catalog=dict(file=str(catalog), sha256=identity(catalog)['sha256']),
                    roles={args.role: role}, inputs=pins, jobs=[],
                    scope='Checked emission only, no emitted-program execution or semantic PASS. All failures are retained; no case is silently dropped.')
    with ExecutionGuard(rss_mib=2048, available_mib=4096) as guard:
        out.mkdir(parents=True)
        (out / 'modules').mkdir()
        (out / 'consumed').mkdir()
        for file in [Path(__file__), HERE / 'emit-worker.mjs', catalog]:
            shutil.copyfile(file, out / 'consumed' / file.name)
        save(out / 'manifest.json', manifest)
        for case in cases:
            source = (catalog.parent / case['source']['path']).resolve(strict=True)
            module = out / 'modules' / (case['id'] + '.mjs')
            mode = 'library' if case['mode'] == 'library' else 'compile'
            command = ['taskset', '-c', '3', str(args.node.resolve()), '--stack-size=4096', '--max-old-space-size=1024',
                       str(HERE / 'emit-worker.mjs'), args.selection, str(source), str(module), str(catalog), 'direct', mode]
            print(json.dumps(dict(starting=case['id'], mode=mode, role=args.role)), flush=True)
            process = guard.run(command, out / 'jobs' / case['id'], time.monotonic() + 120)
            receipt = Path(str(module) + '.json')
            emitted = json.loads(receipt.read_text()) if receipt.exists() else {}
            passed = bool(process['complete'] and process.get('returncode') == 0 and emitted.get('complete'))
            row = dict(id=case['id'], mode=mode, command=command, process=process, passed=passed)
            if receipt.exists():
                row['emission'] = identity(receipt)
            if passed:
                assert emitted['input']['sha256'] == case['source']['sha256']
                assert emitted['catalog']['sha256'] == manifest['catalog']['sha256']
                assert emitted['output']['sha256'] == identity(module)['sha256']
                assert emitted['observation']['status'] == 'ok' and emitted['observation']['checked']
                assert emitted['compiler']['upstreamCommit'] == data['upstreamCommit']
                if args.role == 'direct':
                    assert emitted['attempt']['sha256'] == role['attempt']['sha256']
                    assert emitted['compiler']['backend'] == 'direct'
                else:
                    assert emitted['compiler']['kind'] == 'checked-pinned-typescript'
                assert emitted['compiler']['callingContract'] == 'upstream-compatible-direct-v1'
                role['modules'][case['id']] = str(module)
                row['module'] = identity(module)
            else:
                row['error'] = emitted.get('error', process.get('stoppedFor', 'Missing complete checked emission'))
            manifest['jobs'].append(row)
            save(out / 'manifest.json', manifest)
            print(json.dumps(dict(case=case['id'], passed=passed, error=row.get('error'))), flush=True)
            if guard.interrupted:
                break
        for row in pins:
            assert identity(row['path']) == row, row['path']
        manifest['complete'] = len(manifest['jobs']) == len(cases)
        manifest['passed'] = manifest['complete'] and all(row['passed'] for row in manifest['jobs'])
        manifest['inputsUnchanged'] = True
        save(out / 'manifest.json', manifest)
    print(json.dumps(dict(complete=manifest['complete'], passed=manifest['passed'], emitted=len(role['modules']), total=len(cases))))
    return 0 if manifest['passed'] else 1


if __name__ == '__main__':
    raise SystemExit(main())
