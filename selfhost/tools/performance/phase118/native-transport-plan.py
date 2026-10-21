#!/usr/bin/env python3
"""Prepare a qualified Phase118 native timing manifest; execute no targets."""
import argparse
import importlib.util
import json
from pathlib import Path
import re
import sys

HERE = Path(__file__).resolve().parent
ROOT = HERE.parents[3]
spec = importlib.util.spec_from_file_location('phase118_native_plan', HERE / 'native-plan.py')
native = importlib.util.module_from_spec(spec)
spec.loader.exec_module(native)
pin, verify, require, read = native.pin, native.verify, native.require, native.read
BASE = ROOT / 'selfhost/build/phase114/native-final02-transport-manifest.json'
BASE_HASH = '58361b0ad4f5cae149344ae47b6c085b5220a7355f8fbd2f88c1e41fc25aaebf'
RUNNER = ROOT / 'selfhost/tools/performance/phase112/transport/run.py'
RUNNER_HASH = 'bde6f9dae553a15055c89f578fc9575b48ab3a7f4868b2cc4db4c893a19bd41f'


def pins(value):
    if isinstance(value, dict):
        if all(k in value for k in ['file', 'bytes', 'sha256']):
            yield value
        for child in value.values():
            yield from pins(child)
    elif isinstance(value, list):
        for child in value:
            yield from pins(child)


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--plan', type=Path, required=True)
    parser.add_argument('--out', type=Path, required=True)
    parser.add_argument('--tag', required=True)
    parser.add_argument('--repeat-phase114', action='store_true')
    args = parser.parse_args()
    out = args.out.resolve()
    require(not out.exists() and out.is_relative_to(ROOT / 'selfhost/build/phase118'), 'Fresh Phase118 manifest required')
    require(re.fullmatch(r'p118-[a-z0-9_-]+', args.tag), 'Lowercase p118- tag required')
    require(pin(RUNNER)['sha256'] == RUNNER_HASH, 'Frozen timing runner changed')
    require(pin(BASE)['sha256'] == BASE_HASH, 'Frozen Phase114 timing manifest changed')
    plan = native.verify_plan(args.plan)
    jobs_receipt = Path(plan['artifacts']['jobs']) / 'report.json'
    finished = read(jobs_receipt)
    require(finished.get('complete') and [row['name'] for row in finished['jobs']] == [row['name'] for row in plan['jobs']] and all(row.get('status') == 0 for row in finished['jobs']), 'Full qualification job sequence must finish successfully first')
    comparison_path = Path(plan['artifacts']['comparison'])
    comparison = read(comparison_path)
    require(comparison.get('complete') and comparison.get('byteExact') and comparison.get('kind') == 'phase118-integrated-native-qbe-reproduction', 'Actual N1/N2 reproduction receipt required')
    for record in comparison['inputs']:
        verify(record)
    require(pin(args.plan) in comparison['inputs'], 'Reproduction receipt belongs to another plan')
    n1 = pin(Path(plan['artifacts']['n1']) / 'program')
    n2 = pin(Path(plan['artifacts']['self']) / 'build/program')
    require(comparison['n1'] == n1 and comparison['n2'] == n2, 'Native image lineage mismatch')
    receipts = []
    for key, image, positive, refused in [('n1Focused', n1, 16, 3), ('n2Focused', n2, 16, 3), ('n2Full45', n2, 45, 0)]:
        file = Path(plan['artifacts'][key]) / 'report.json'
        report = read(file)
        require(report.get('complete') and report.get('passed'), 'Incomplete semantic gate: ' + key)
        require(report['summary']['semanticPasses'] == positive and report['summary']['expectedRefusals'] == refused and report['summary']['pending'] == 0, 'Semantic scope changed: ' + key)
        require(image in report['inputs'] and plan['runtime'] in report['inputs'], 'Semantic image/runtime binding mismatch: ' + key)
        receipts.append(pin(file))
    base = read(BASE)
    keys = ['kind', 'upstreamRevision', 'cases', 'nativeAssets', 'tools', 'scope', 'timer', 'buildPolicy', 'limits']
    manifest = {key: base[key] for key in keys}
    for key in ['base', 'cache', 'selection', 'admission']:
        require(manifest['nativeAssets'][key] == plan['assets'][key], 'Changed Base/cache preparation: ' + key)
    manifest.update(preparedOnly=True, targetsRun=False, runtime=plan['runtime'], roles={
        'phase111': dict(binary=n1, source=plan['source'], generation='Phase118 N1; legacy phase111 key'),
        'phase112': dict(binary=n2, source=plan['source'], generation='Phase118 N2; legacy phase112 key'),
        'upstream': base['roles']['upstream']}, lineage=dict(
            comparison='Same qualified Phase118 source, actual N1/N2 versus unchanged pinned upstream.',
            roleKeys=dict(phase111='Phase118 N1', phase112='Phase118 N2', upstream='pinned TypeScript/Bun C compiler'),
            sameCompilerSource=plan['source'], qbeByteExact=True, reproductionReceipt=pin(comparison_path),
            historicalPhase114Report=pin(ROOT / 'selfhost/build/phase112/p114-native-final02-transport/report.json')),
        inputs=[pin(__file__), pin(RUNNER), pin(BASE), pin(args.plan), pin(jobs_receipt), pin(comparison_path), plan['sourceManifest'], plan['apiReport'], plan['runtimeReport'], *receipts],
        derivation=dict(kind='phase118-qualified-native-transport', unchanged='Phase114 cases, outputs, upstream, Base/cache, timing runner, schedule, clocks, tools, limits and build policy. Only the native generation pair/runtime and their exact qualification lineage change.'))
    for record in pins(manifest):
        verify(record)
    target = ROOT / 'selfhost/build/phase112' / args.tag
    jobs_path = out.with_name(out.stem + '-jobs.json')
    require(not target.exists() and not jobs_path.exists(), 'Fresh result and job-plan paths required')
    command = [sys.executable, '-B', str(RUNNER), '--manifest', str(out), '--out', str(target), '--rounds', '3', '--modes', 'cache']
    jobs = [dict(name='phase118-n1-n2-upstream-three-source', seconds=180, command=command)]
    if args.repeat_phase114:
        for record in pins(base):
            verify(record)
        old_target = target.with_name(args.tag + '-phase114')
        require(not old_target.exists(), 'Fresh Phase114 repeat path required')
        jobs.append(dict(name='phase114-contemporaneous-repeat', seconds=180, command=[sys.executable, '-B', str(RUNNER), '--manifest', str(BASE), '--out', str(old_target), '--rounds', '3', '--modes', 'cache']))
    out.parent.mkdir(parents=True, exist_ok=True)
    with out.open('x') as stream:
        json.dump(manifest, stream, indent=2); stream.write('\n')
    with jobs_path.open('x') as stream:
        json.dump(dict(kind='phase118-native-timing-jobs', targetsRun=False, inputs=[pin(out)], jobs=jobs), stream, indent=2); stream.write('\n')
    print(json.dumps(dict(complete=True, targetsRun=False, manifest=pin(out), jobPlan=pin(jobs_path), jobs=jobs)))


if __name__ == '__main__':
    main()
