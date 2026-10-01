#!/usr/bin/env python3
"""Freeze fresh acquisitions for all seven inherited Phase36 owner groups.

This is a write-only planner, compatible with the unchanged serial Phase35
runner. The inherited semantic controls and closer remain unchanged.
"""
import argparse
import hashlib
import json
from pathlib import Path
import sys

HERE = Path(__file__).resolve().parent
ROOT = HERE.parents[3]
P35, P36, PROGRAMS = HERE.parent/'phase35', HERE.parent/'phase36', HERE.parent/'programs'


def main():
    ap = argparse.ArgumentParser(description=__doc__)
    ap.add_argument('attempt', type=Path)
    ap.add_argument('prepared', type=Path)
    ap.add_argument('out', type=Path)
    a = ap.parse_args()
    attempt, prepared, out = a.attempt.resolve(), a.prepared.resolve(), a.out.resolve()
    if prepared.is_dir():
        prepared = prepared/'manifest.json'
    inputs, commands = {}, []

    def keep(file, expected=None):
        file = Path(file).resolve()
        digest = hashlib.sha256()
        with file.open('rb') as stream:
            for block in iter(lambda: stream.read(2**20), b''):
                digest.update(block)
        row = dict(file=str(file), sha256=digest.hexdigest(), bytes=file.stat().st_size)
        if expected is not None:
            assert row['sha256'] == expected, file
        inputs[str(file)] = row
        return row

    def read(file):
        keep(file)
        return json.loads(Path(file).read_text())

    def save(file, data):
        file.write_text(json.dumps(data, indent=2)+'\n')

    manifest, bundle = read(attempt/'attempt.json'), read(prepared)
    assert manifest['checked'] and manifest['artifactKind'] == 'derived-b1'
    assert manifest['config']['strictExact'] and manifest['config']['jobs'] == 1
    assert str(manifest['config']['cpu']) == '3' and 0 < manifest['config']['heapMb'] <= 1024
    assert bundle['complete'] and set(bundle['roles']) == {'candidate'}
    compiler = bundle['roles']['candidate']['compiler']
    assert compiler['kind'] == 'checked-development-attempt'
    for key in ['api', 'runtime', 'base']:
        assert compiler[key]['sha256'] == manifest[key]['sha256']
    for key in ['api', 'checkedApi', 'runtime', 'base', 'node', 'bootstrapReport', 'derivationReport']:
        keep(manifest[key]['file'], manifest[key]['sha256'])
    for row in manifest['snapshot']['sources']:
        keep(row['frozen']['file'], row['frozen']['sha256'])
    node = Path(manifest['node']['file'])
    assert node == Path('/home/ai/.nvm/versions/node/v24.18.0/bin/node')
    cases = {row['id']: row for row in bundle['cases']}
    assert {'raytrace', 'symreg'} <= set(cases)
    ray = prepared.parent/cases['raytrace']['modules']['candidate']['path']
    keep(ray, cases['raytrace']['modules']['candidate']['sha256'])
    keep(Path(str(ray)+'.json'))
    prep = prepared.parent/bundle['preparation']['path']
    assert read(prep)['complete']
    keep(prep, bundle['preparation']['sha256'])
    baseline = ROOT/'selfhost/build/phase35/checked09'
    old = read(baseline/'attempt.json')
    assert old['api']['sha256'] == '467bc7dec2751a94cb677c5eb2da22a8fb69ee3522c6e164cb2bfcc147a78d82'
    for key in ['api', 'runtime', 'base']:
        keep(old[key]['file'], old[key]['sha256'])
    keep(__file__)
    for tool in [P35/'final-integration-run.py', HERE.parent/'phase32/bounded-run.py',
                 PROGRAMS/'support.py', PROGRAMS/'prepare.py', PROGRAMS/'emit-worker.mjs',
                 PROGRAMS/'catalog.json', P36/'cohort-acquire.py',
                 ROOT/'selfhost/tools/development/workflow.mjs', ROOT/'selfhost/tools/development/release.mjs',
                 P35/'region-colf-controls.mjs', P36/'guard-scope-controls-v2.mjs']:
        keep(tool)
    for source in ['guard-overflow-v2.bend', 'guard-array-refusal-v2.bend',
                   'producer-fixtures-v2.bend', 'producer-selectors-v2.bend']:
        keep(P36/source)
    out.mkdir(parents=True, exist_ok=False)

    def command(name, argv, seconds=180, self_supervised=False):
        argv = ['taskset', '-c', '3', *map(str, argv)]
        wrapped = [sys.executable, str(HERE.parent/'phase32/bounded-run.py'),
            '--seconds', str(seconds), '--rss-mib', '2048', '--available-mib', '2048',
            str(out/('run-'+name)), '--', *argv]
        commands.append(dict(name=name, command=argv,
            supervisedCommand=argv if self_supervised else wrapped,
            selfSupervised=self_supervised, stage='owner', executed=False, cpu=3,
            outerTimeoutSeconds=seconds, treeRssMiB=2048, availableFloorMiB=2048))

    def py(name, tool, args, seconds=180, self_supervised=False):
        keep(tool)
        command(name, [sys.executable, tool, *args], seconds, self_supervised)

    def js(name, tool, args, seconds=180):
        if tool.is_file():
            keep(tool)
        command(name, [node, '--stack-size=4096', '--max-old-space-size=1024', tool, *args], seconds)

    baseline_ray, cohorts, guards = out/'baseline-ray', out/'cohorts', out/'guards'
    # Reacquire this one old-API source so the untouched adapter sees a genuine
    # current checked-emitter receipt, rather than remapping an old live producer.
    py('baseline-ray', PROGRAMS/'prepare.py', ['--attempt', baseline, '--role', 'baseline',
        '--cases', 'raytrace', '--out', baseline_ray, '--node', node, '--cpu', '3',
        '--heap-mib', '1024', '--rss-mib', '2048', '--available-mib', '2048', '--timeout', '180'],
        240, True)
    py('cohorts', P36/'cohort-acquire-v2.py', ['--attempt', attempt, '--baseline-attempt', baseline,
        '--upstream', ROOT/'selfhost/.bootstrap/upstream-phase23', '--out', cohorts,
        '--cases', 'overflow-v2,array-refusal-v2,producer-fixtures-v2,producer-selectors-v2',
        '--node', node, '--cpu', '3', '--rss-mib', '2048', '--available-mib', '2048', '--timeout', '180'],
        2400, True)
    js('derive-guards', P36/'guard-checked-controls-derive.mjs',
       [baseline_ray/'modules/raytrace.mjs', ray, guards])
    js('guardcolf', guards/'controls.mjs', [guards, out/'guardcolf'])
    js('guardscope', guards/'scope-controls.mjs', [guards, out/'guardscope'])
    js('error', P36/'guard-overflow-controls-v2.mjs', [cohorts/'overflow-v2', out/'error'])
    js('array', P36/'guard-array-controls-v2.mjs', [cohorts/'array-refusal-v2', out/'array'])
    producer, selector = cohorts/'producer-fixtures-v2', cohorts/'producer-selectors-v2'
    js('producerfixture', P36/'producer-fixture-controls.mjs',
       [producer/'baseline.mjs', producer/'candidate.mjs', out/'producerfixture'])
    js('producerreviewed', P36/'producer-reviewed-controls.mjs',
       [producer/'baseline.mjs', producer/'candidate.mjs', producer/'typescript.mjs', out/'producerreviewed'])
    js('selector', P36/'producer-selector-controls.mjs',
       [selector/'baseline.mjs', selector/'candidate.mjs', selector/'typescript.mjs', out/'selector'])
    groups = ['guardcolf', 'guardscope', 'error', 'array', 'producerfixture', 'producerreviewed', 'selector']
    save(out/'mapping.json', {name: str(out/name/'report.json') for name in groups})
    keep(out/'mapping.json')
    py('close', P36/'owner-close.py', [attempt, prepared, cohorts, out/'mapping.json', out/'report.json'])
    save(out/'plan.json', dict(kind='phase35-final-integration-plan', complete=True, executed=False,
        actualScope='Phase37 actual-API rebinding of all seven Phase36 owners only; inherited15 and new Phase37 finite/native/cast controls are separate.',
        attempt=keep(attempt/'attempt.json'), api=manifest['api'], inputs=list(inputs.values()),
        commands=commands, ownerGates=groups,
        cpuPolicy='Root serial runner only. Acquirers own the shared ExecutionGuard; other commands own a bounded-run guard. Never wrap the whole runner in that same lock.'))
    print(json.dumps(dict(complete=True, executed=False, commands=len(commands),
                         ownerGates=groups, out=str(out), api=manifest['api']['sha256'])))


if __name__ == '__main__':
    main()
