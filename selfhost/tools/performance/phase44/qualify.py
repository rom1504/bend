#!/usr/bin/env python3
"""Eight maintained semantic gates, serial and bounded; no build or installation."""
import argparse
import json
import os
from pathlib import Path
import shutil
import sys
import time

HERE = Path(__file__).resolve().parent
ROOT = HERE.parents[3]
SH = ROOT / 'selfhost'
sys.path.insert(0, str(HERE.parent / 'programs'))
from support import ExecutionGuard, identity, save


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('attempt', type=Path)
    parser.add_argument('out', type=Path)
    args = parser.parse_args()
    attempt, out = args.attempt.resolve(), args.out.resolve()
    out.mkdir(parents=True, exist_ok=False)
    report = dict(kind='phase44-maintained-semantic-qualification', complete=False, pass_=False,
                  scope='Eight current maintained suites against one passed checked attempt. No full-language, performance, fixed-point or installation claim.',
                  cpu=3, heapMiB=1024, treeRssMiB=2048, availableMiB=2048, secondsPerTest=120, inputs=[], tests=[])
    report['pass'] = report.pop('pass_')
    def persist(): save(out / 'report.json', report)
    def pin(file, expected=None):
        row = identity(file)
        if expected: assert row['sha256'] == expected['sha256'], row['path']
        if row not in report['inputs']: report['inputs'].append(row)
        return row
    def unchanged():
        for row in report['inputs']: assert identity(row['path']) == row, row['path']
    persist()
    try:
        os.chdir(ROOT)
        pin(__file__); pin(HERE.parent / 'programs/support.py')
        shutil.copyfile(__file__, out / 'consumed-qualify.py')
        pin(attempt / 'attempt.json'); manifest = json.loads((attempt / 'attempt.json').read_text())
        assert manifest['checked'] and manifest['config']['strictExact']
        pin(attempt / 'validation-001/report.json')
        focused = json.loads((attempt / 'validation-001/report.json').read_text())
        assert focused['complete'] and focused['pass'] and focused['api']['sha256'] == manifest['api']['sha256']
        for key in ['api','checkedApi','runtime','base','node','bootstrapReport']:
            pin(manifest[key]['file'], manifest[key])
        snapshot = Path(manifest['snapshot']['root'])
        for name in ['typed-driver','compiler-abi','native-build','node-resource-args','assemble','stage0-library']:
            current, frozen = SH / ('tools/' + name + '.mjs'), snapshot / ('tools/' + name + '.mjs')
            assert pin(current)['sha256'] == pin(frozen)['sha256'], 'Host changed: ' + name
        assert pin(SH / 'src/compiler.json')['sha256'] == pin(snapshot / 'src/compiler.json')['sha256']
        pin(SH / 'tests/fixtures/choice.bend')
        pin(SH / 'tools/backend-test-api.mjs')
        bindings = {key:manifest[key]['file'] for key in ['api','runtime','base']}
        bindings['driver'] = str(snapshot / 'tools/typed-driver.mjs')
        report['armExpectation'] = dict(expectExactArms=False, reason='Phase43 selected matcher emission has no prebind-arm path; maintained04b passed all72+22 behavior observations before its incorrect true shape expectation failed. All arm semantics remain required.')
        config = out / 'arm-config.json'; save(config, dict(candidate=bindings, expectExactArms=False)); pin(config)
        env = dict(BEND_TYPED_API=bindings['api'], BEND_TYPED_RUNTIME=bindings['runtime'], BEND_BASE=bindings['base'],
                   BEND_JS_RUNTIME=bindings['runtime'], BEND_JS_BACKEND=str(SH / 'tools/backend-test-api.mjs'),
                   BEND_UPSTREAM=manifest['config']['upstream'], NODE_OPTIONS='--max-old-space-size=1024')
        js = SH / 'src/back/js'
        tests = [('ir', js/'ir/test.mjs', [attempt, out/'ir', '--expect-statements', '--expect-folds']),
                 ('backend', js/'test.mjs', []), ('global-initializers', js/'test-global-initializers.mjs', []),
                 ('choice', js/'test-choice.mjs', []), ('arm', js/'test-arm.mjs', [config, out/'arm']),
                 ('primitive-guards', HERE.parent/'phase29/controls-guards.mjs', [config, out/'primitive-guards']),
                 ('provenance', js/'test-provenance.mjs', []), ('foreign', js/'test-foreign.mjs', [])]
        for _, script, _ in tests: pin(script)
        pin(HERE.parent/'phase29/controls-operations.json')
        report['attempt'] = identity(attempt/'attempt.json'); report['api'] = identity(bindings['api']); persist()
        with ExecutionGuard(rss_mib=2048, available_mib=2048) as guard:
            for name, script, arguments in tests:
                unchanged(); command = ['taskset','-c','3',manifest['node']['file'],'--stack-size=4096','--max-old-space-size=1024',script,*arguments]
                result = guard.run(command, out/('process-'+name), time.monotonic()+120, env=env)
                row = dict(name=name, process=result, pass_=False); row['pass'] = row.pop('pass_'); report['tests'].append(row); persist()
                assert result['complete'] and result.get('returncode') == 0 and not result.get('stoppedFor'), name
                if name in ['ir','arm','primitive-guards']:
                    receipt = out/name/'report.json'; child=json.loads(receipt.read_text())
                    assert child['complete'] and child['pass'] and not child.get('error'), name
                    row['report'] = identity(receipt)
                    if name == 'ir': assert len(child['checks']) == 37; row['checks'] = len(child['checks'])
                    elif name == 'primitive-guards':
                        assert len(child['guards']) == 1129 and len(child['observations']) == 25
                        row.update(guards=1129, observations=25)
                    else: row['observations'] = len(child['observations'])
                elif name == 'provenance':
                    receipt = out/'provenance-report.json'; shutil.copyfile(SH/'build/js-provenance/report.json', receipt)
                    child=json.loads(receipt.read_text()); assert child['status'] == 'pass' and child['checked'] is True and len(child['constructors']) == 10
                    row.update(report=identity(receipt), constructors=10, checked=True)
                unchanged(); row['pass'] = True; persist()
        report['complete'] = report['pass'] = True
    except Exception as error:
        report['error'] = repr(error)
    persist()
    print(json.dumps(dict(complete=report['complete'], **{'pass':report['pass']},
                          tests=len(report['tests']), passed=[r['name'] for r in report['tests'] if r['pass']],
                          error=report.get('error'))))
    return 0 if report['pass'] else 1


if __name__ == '__main__':
    raise SystemExit(main())
