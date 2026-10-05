#!/usr/bin/env python3
"""Root-only serial integration queue; retained tools own their resource guards."""
import argparse
from collections import Counter
import hashlib
import json
from pathlib import Path
import subprocess
import time

HERE = Path(__file__).resolve().parent
ROOT = HERE.parents[3]
SH = ROOT / 'selfhost'
RAW = SH / 'build/phase51'
NODE = Path('/home/ai/.nvm/versions/node/v24.18.0/bin/node')


def identity(file):
    file = Path(file).resolve(strict=True)
    digest = hashlib.sha256()
    with file.open('rb') as stream:
        for chunk in iter(lambda: stream.read(2**20), b''):
            digest.update(chunk)
    return dict(file=str(file), sha256=digest.hexdigest(), bytes=file.stat().st_size)


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('attempt', type=Path, nargs='?', default=RAW / 'checked-candidate01')
    parser.add_argument('out', type=Path, nargs='?', default=RAW / 'qualification01')
    parser.add_argument('--baseline-preparation', type=Path)
    args = parser.parse_args()
    attempt, out = args.attempt.resolve(strict=True), args.out.resolve()
    assert out.is_relative_to(RAW) and not out.exists() and not out.is_relative_to(attempt)
    out.mkdir(parents=True)
    pins = {}
    report = dict(kind='phase51-selected-semantic-queue', complete=False, passed=False,
                  serial=True, started=time.time(), jobs=[], plannedEntries=11,
                  scope='Focused runtime/guard controls, maintained8 and backend81; no timing, installation, frontend renewal or fixed-point claim.')

    def save():
        report['inputs'] = list(pins.values())
        (out / 'report.json').write_text(json.dumps(report, indent=2) + '\n')

    def pin(file, want=None):
        row = identity(file)
        if want:
            assert row['sha256'] == want['sha256'], row['file']
        if row['file'] in pins:
            assert row == pins[row['file']], row['file']
        pins[row['file']] = row
        return row

    def read(file):
        pin(file)
        return json.loads(Path(file).read_text())

    def module_check(module, owner, catalog):
        manifest = json.loads((owner / 'attempt.json').read_text())
        receipt = json.loads(Path(str(module) + '.json').read_text())
        assert receipt['kind'] == 'bend-program-checked-emission' and receipt['complete']
        assert receipt['observation']['checked'] and receipt['observation']['status'] == 'ok'
        assert receipt['output']['sha256'] == identity(module)['sha256']
        assert receipt['attempt']['sha256'] == identity(owner / 'attempt.json')['sha256']
        assert Path(receipt['attempt']['file']).resolve() == owner / 'attempt.json'
        assert receipt['compiler']['kind'] == 'checked-development-attempt'
        for key in ['api', 'runtime', 'base']:
            assert receipt['compiler'][key]['sha256'] == manifest[key]['sha256']
        source = catalog.parent / json.loads(catalog.read_text())['cases'][0]['source']['path']
        assert receipt['input']['sha256'] == identity(source)['sha256']
        assert receipt['catalog']['sha256'] == identity(catalog)['sha256']
        return receipt

    def execute(name, command, receipt, counts=None, mode='control'):
        command = list(map(str, command))
        row = dict(name=name, command=command, cwd=str(ROOT), started=time.time(), passed=False)
        report['jobs'].append(row)
        save()
        print(json.dumps(dict(starting=name, entry=len(report['jobs']), total=11)), flush=True)
        with (out / (name + '.stdout.log')).open('x') as stdout, (out / (name + '.stderr.log')).open('x') as stderr:
            process = subprocess.run(command, cwd=ROOT, stdout=stdout, stderr=stderr)
        row.update(returncode=process.returncode, finished=time.time())
        row['wallSeconds'] = row['finished'] - row['started']
        save()
        assert process.returncode == 0, name + ': see saved stdout/stderr'
        child = read(receipt)
        assert child['complete'], name
        if mode == 'control':
            assert child['pass'] and not child.get('error'), name
        elif mode == 'backend':
            assert child['agreementComplete'] and child['rowsExpected'] == 81
            assert not child['unexecuted'] and not child['incompleteBatchRows']
            assert len(child['rows']) == 81 and all(r['exactAgreement'] for r in child['rows'])
            assert Counter(r['candidateVerdict'] for r in child['rows']) == {'pass': 69, 'not-applicable': 8, 'fail': 4}
        for key, expected in (counts or {}).items():
            assert len(child[key]) == expected, (name, key)
        row.update(passed=True, report=pin(receipt), counts=counts or {})
        save()
        return child

    try:
        pin(__file__)
        selected = read(attempt / 'attempt.json')
        assert selected['checked'] and selected['config']['strictExact']
        focused = read(attempt / 'validation-001/report.json')
        assert focused['complete'] and focused['pass'] and focused['strictExact']
        assert focused['attempt']['sha256'] == pin(attempt / 'attempt.json')['sha256']
        assert focused['api']['sha256'] == selected['api']['sha256']
        report['selected'] = dict(attempt=pin(attempt / 'attempt.json'))
        for key in ['api', 'runtime', 'base', 'node']:
            report['selected'][key] = pin(selected[key]['file'], selected[key])
        assert Path(selected['node']['file']).resolve() == NODE.resolve()
        baseline = SH / 'build/phase48/checked-combined-rnfa04'
        reference = read(baseline / 'attempt.json')
        assert reference['api']['sha256'] == '6f9d111aa68c19f3ce45b80785621d57c4d10efb12d50164f5cb0597bc952100'
        assert reference['runtime']['sha256'] == '880bce50e3194b9ee9d99bd57c18ef88bcb8925d9d1668dec6765040a4d3219b'
        prepare = HERE.parent / 'programs/prepare.py'
        guard = HERE.parent / 'phase46/job.py'
        qualify = HERE.parent / 'phase47/qualify.py'
        backend = HERE / 'backend-plan.py'
        backend_runner = SH / 'build/phase43/integration01/final-plan/tools/backend-run.py'
        for file in [prepare, guard, qualify, backend, backend_runner]:
            pin(file)
        catalogs = {name: HERE.parent / relative for name, relative in [
            ('nullary', 'phase45/nullary-demand21-catalog-v2.json'),
            ('view', 'phase47/controls/array-view-catalog-v1.json'),
            ('tree', 'phase47/controls/array-tree-catalog-v4.json')]}
        stems = dict(nullary='nullary-demand21-v2', view='array-view-v1', tree='array-tree-v4')
        for catalog in catalogs.values():
            data = read(catalog)
            assert data['upstreamCommit'] == '018751270e800bc222a93dad7f257083ee53a5f7'
            pin(catalog.parent / data['cases'][0]['source']['path'], data['cases'][0]['source'])

        def acquire(name, role, owner, destination):
            execute('acquire-' + name, ['python3', prepare, '--catalog', catalogs[name.split('-')[0]],
                    '--set', 'full', '--role', role, '--attempt', owner, '--node', NODE, '--cpu', '3',
                    '--heap-mib', '1024', '--rss-mib', '2048', '--available-mib', '4096', '--timeout', '180',
                    '--out', destination], destination / 'manifest.json', mode='acquisition')
            key = name.split('-')[0]
            module = destination / 'modules' / (stems[key] + '.mjs')
            module_check(module, owner, catalogs[key])
            pin(module)
            pin(str(module) + '.json')
            return module

        # Reuse only a complete source-identical acquisition of RNFA04, never a
        # similarly named Phase45 runtime. No target is imported during discovery.
        choices = [args.baseline_preparation.resolve(strict=True)] if args.baseline_preparation else []
        if not choices:
            for phase in ['phase48', 'phase51']:
                for pattern in ['*/modules/nullary-demand21-v2.mjs', '*/*/modules/nullary-demand21-v2.mjs']:
                    choices.extend(p.parent.parent for p in (SH / 'build' / phase).glob(pattern))
        old = None
        for directory in sorted(set(choices)):
            module = directory / 'modules/nullary-demand21-v2.mjs'
            try:
                assert json.loads((directory / 'manifest.json').read_text())['complete']
                module_check(module, baseline, catalogs['nullary'])
            except (AssertionError, KeyError, OSError, ValueError):
                if args.baseline_preparation:
                    raise
                continue
            old = module
            report['jobs'].append(dict(name='acquire-nullary-baseline', passed=True, executed=False,
                reuse='Earlier complete RNFA04 acquisition; no fresh execution claimed.',
                manifest=pin(directory / 'manifest.json'), module=pin(module), emission=pin(str(module) + '.json')))
            save()
            break
        if old is None:
            old = acquire('nullary-baseline', 'baseline', baseline, out / 'nullary-baseline')
        modules = {name: acquire(name + '-candidate', 'candidate', attempt, out / (name + '-candidate'))
                   for name in ['nullary', 'view', 'tree']}
        controls = [
            ('exact-entry', HERE.parent / 'phase45/exact-entry-host-hooks-controls-v1.mjs', [old, modules['nullary']], {'observations': 6}),
            ('nullary', HERE.parent / 'phase45/nullary-demand21-controls-v3.mjs', [old, modules['nullary'], SH / 'build/phase45/nullary21v2-typescript/modules/nullary-demand21-v2.mjs'], {'oracles': 6, 'boundaries': 39, 'metadata': 9, 'activation': 6}),
            ('view', HERE.parent / 'phase48/controls/array-view-controls-v4.mjs', [SH / 'build/phase47/array-controls-baseline01/modules/array-view-v1.mjs', modules['view']], {'oracles': 24, 'boundaries': 39}),
            ('tree', HERE.parent / 'phase48/controls/array-tree-controls-v6.mjs', [SH / 'build/phase47/tree-controls-baseline04/modules/array-tree-v4.mjs', modules['tree']], {'oracles': 159, 'boundaries': 11})]
        for name, script, arguments, counts in controls:
            pin(script)
            for file in arguments:
                pin(file)
                pin(str(file) + '.json')
            execute(name, ['python3', guard, '--out', out / ('job-' + name), '--seconds', '120', '--',
                    NODE, '--stack-size=4096', '--max-old-space-size=1024', script, *arguments, out / name],
                    out / name / 'report.json', counts)
        execute('maintained8', ['python3', qualify, attempt, out / 'maintained8'], out / 'maintained8/report.json', {'tests': 8})
        execute('prepare-backend81', ['python3', backend, attempt, out / 'backend'], out / 'backend/preparation.json', mode='plan')
        execute('backend81', ['python3', guard, '--out', out / 'job-backend81', '--seconds', '930', '--',
                'python3', backend_runner, out / 'backend/pilot.json'], out / 'backend/pilot/report.json', mode='backend')
        assert len(report['jobs']) == 11 and all(row['passed'] for row in report['jobs'])
        for row in list(pins.values()):
            assert identity(row['file']) == row, row['file']
        report.update(complete=True, passed=True, inputsUnchanged=True)
    except Exception as error:
        report['error'] = repr(error)
    report['finished'] = time.time()
    report['wallSeconds'] = report['finished'] - report['started']
    save()
    print(json.dumps({key: report.get(key) for key in ['complete', 'passed', 'wallSeconds', 'error']}), flush=True)
    return 0 if report['passed'] else 1


if __name__ == '__main__':
    raise SystemExit(main())
