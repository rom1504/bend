#!/usr/bin/env python3
"""Prepare a qualified staged Phase126 native timing manifest; execute no targets."""
import argparse
import importlib.util
import json
from pathlib import Path
import re
import sys

HERE = Path(__file__).resolve().parent
ROOT = HERE.parents[4]
spec = importlib.util.spec_from_file_location('phase118_native_plan', HERE / 'plan-v2.py')
native = importlib.util.module_from_spec(spec)
spec.loader.exec_module(native)
pin, verify, require, read = native.pin, native.verify, native.require, native.read
BASE = ROOT / 'selfhost/build/phase114/native-final02-transport-manifest.json'
BASE_HASH = '58361b0ad4f5cae149344ae47b6c085b5220a7355f8fbd2f88c1e41fc25aaebf'
PARENT = ROOT / 'selfhost/tools/performance/phase125/native'
RUNNER = PARENT / 'timing-run.py'
RUNNER_HASH = 'd11362384088effd695e2872e7a55cb8e2c4cf943fdc8eeace10bca4780e9e6f'
BASE125 = ROOT / 'selfhost/build/phase125/native06-transport-manifest.json'
SMALL_GUARD = HERE.parent/'guard-small-files.py'
SMALL_GUARD_HASH = '1a4f99e03b9e06bf0b00622be0aff5309c2dc95ead87232f224851b1dd73f2c0'
BASE125_HASH = '408e75dcc0bda78d55fff8a75baec9e4a798daef788b6aa89072617988013b4d'
QUALIFIED_JOBS = ['authenticate-plan','full-hosted-integrated-emission','n1-build','n1-focused19',
    'storage-after-n1','native-self-emission-only','storage-before-n2','n2-build',
    'exact-hosted-native-qbe','dedup-completed-machine-artifacts','n2-focused19','n2-original-full45']


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
    parser.add_argument('--repeat-phase125', action='store_true', help='Separate contemporaneous block with old qualified images, same aligned output build policy')
    args = parser.parse_args()
    out = args.out.resolve()
    require(not out.exists() and out.is_relative_to(ROOT / 'selfhost/build/phase126'), 'Fresh Phase126 manifest required')
    require(re.fullmatch(r'p126-[a-z0-9_-]+', args.tag), 'Lowercase p126- tag required')
    require(pin(RUNNER)['sha256'] == RUNNER_HASH, 'Frozen timing runner changed')
    require(pin(BASE)['sha256'] == BASE_HASH, 'Frozen Phase114 timing manifest changed')
    require(pin(SMALL_GUARD)['sha256'] == SMALL_GUARD_HASH, 'Frozen eight-MiB guard changed')
    plan = native.verify_plan(args.plan)
    require([j['name'] for j in plan['jobs']] == QUALIFIED_JOBS, 'All twelve staged qualification jobs required')
    require(plan.get('stagedStorageAdapter') and plan.get('storageCheckpoints'), 'Staged lineage required')
    jobs_receipt = Path(plan['artifacts']['jobs']) / 'report.json'
    finished = read(jobs_receipt)
    require(finished.get('complete') and [row['name'] for row in finished['jobs']] == [row['name'] for row in plan['jobs']] and all(row.get('status') == 0 for row in finished['jobs']), 'Full qualification job sequence must finish successfully first')
    require(pin(args.plan) in finished['inputs'], 'Qualification report belongs to another plan')
    require(all(done['command'] == declared['command'] for done, declared in zip(finished['jobs'], plan['jobs'])), 'Qualification command changed')
    storage_receipts = []
    for key in ['afterN1','beforeN2','completedBuildDedup']:
        file = Path(plan['storageCheckpoints'][key]); receipt = read(file)
        require(receipt.get('complete') and pin(args.plan) in receipt['inputs'], 'Incomplete or unrelated storage gate')
        if key == 'beforeN2': require(receipt.get('byteExact'), 'Prebuild raw QBE equality missing')
        for row in receipt['inputs']: verify(row)
        storage_receipts.append(pin(file))
    comparison_path = Path(plan['artifacts']['comparison'])
    comparison = read(comparison_path)
    require(comparison.get('complete') and comparison.get('byteExact') and comparison.get('kind') == 'phase125-integrated-native-qbe-reproduction', 'Actual N1/N2 reproduction receipt required')
    require(comparison.get('stagedAdapter', {}).get('independentlyBuiltN2') is True, 'Separate N2 build lineage required')
    require(pin(HERE/'comparison-staged.py') in comparison['inputs'], 'Staged comparison method mismatch')
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
        require(report.get('complete') and report.get('passed') and report.get('kind') == 'phase125-aligned-native-source-semantic-coverage', 'Incomplete aligned semantic gate: ' + key)
        require(report['summary']['semanticPasses'] == positive and report['summary']['expectedRefusals'] == refused and report['summary']['pending'] == 0, 'Semantic scope changed: ' + key)
        require(image in report['inputs'] and plan['runtime'] in report['inputs'], 'Semantic image/runtime binding mismatch: ' + key)
        receipts.append(pin(file))
    base = read(BASE)
    keys = ['kind', 'upstreamRevision', 'cases', 'nativeAssets', 'tools', 'scope', 'timer', 'buildPolicy', 'limits']
    manifest = {key: base[key] for key in keys}
    manifest['buildPolicy'] = dict(base['buildPolicy'], native='Pinned QBE amd64_sysv, GNU as -mbranches-within-32B-boundaries, gcc -no-pie objects -pthread -lm')
    manifest['assemblerOption'] = '-mbranches-within-32B-boundaries'
    for key in ['base', 'cache', 'selection', 'admission']:
        require(manifest['nativeAssets'][key] == plan['assets'][key], 'Changed Base/cache preparation: ' + key)
    manifest.update(preparedOnly=True, targetsRun=False, runtime=plan['runtime'], roles={
        'phase111': dict(binary=n1, source=plan['source'], generation='Phase126 N1; legacy phase111 key'),
        'phase112': dict(binary=n2, source=plan['source'], generation='Phase126 N2; legacy phase112 key'),
        'upstream': base['roles']['upstream']}, lineage=dict(
            comparison='Same qualified Phase126 source, actual N1/N2 versus unchanged pinned upstream.',
            roleKeys=dict(phase111='Phase126 N1', phase112='Phase126 N2', upstream='pinned TypeScript/Bun C compiler'),
            sameCompilerSource=plan['source'], qbeByteExact=True, reproductionReceipt=pin(comparison_path),
            historicalPhase114Report=pin(ROOT / 'selfhost/build/phase112/p114-native-final02-transport/report.json')),
        inputs=[pin(__file__), pin(RUNNER), pin(SMALL_GUARD), pin(PARENT / 'derivation01.json'), pin(PARENT / 'timing-plan.py'), pin(HERE/'plan-v2.py'), pin(HERE/'comparison-staged.py'), pin(BASE), pin(args.plan), pin(jobs_receipt), pin(comparison_path), plan['sourceManifest'], plan['apiReport'], plan['runtimeReport'], *receipts, *storage_receipts],
        derivation=dict(kind='phase126-staged-qualified-native-transport', unchanged='Phase114 cases, complete outputs, upstream, Base/cache, schedule, clocks, tools and limits. Native generations/runtime are source-bound to qualification; only GNU as gains the selected Phase123 alignment option.'))
    for record in pins(manifest):
        verify(record)
    target = ROOT / 'selfhost/build/phase112' / args.tag
    jobs_path = out.with_name(out.stem + '-jobs.json')
    require(not target.exists() and not jobs_path.exists(), 'Fresh result and job-plan paths required')
    command = [sys.executable, '-B', str(RUNNER), '--manifest', str(out), '--out', str(target), '--rounds', '3', '--modes', 'cache']
    jobs = [dict(name='phase126-n1-n2-upstream-three-source', seconds=180, command=command)]
    timing_inputs = []
    out.parent.mkdir(parents=True, exist_ok=True)
    if args.repeat_phase125:
        require(pin(BASE125)['sha256'] == BASE125_HASH, 'Qualified Phase125 timing manifest changed')
        prior = read(BASE125)
        for record in pins(prior):
            verify(record)
        require(prior['cases'] == manifest['cases'] and prior['nativeAssets'] == manifest['nativeAssets'] and
                prior['tools'] == manifest['tools'] and prior['roles']['upstream'] == manifest['roles']['upstream'] and prior['timer'] == manifest['timer'] and prior['limits'] == manifest['limits'],
                'Historical image repeat changes matched cases/assets/tools/clocks/limits')
        selected = read(ROOT/'implementation/phase125/candidate.json')
        require(selected['complete'] and selected['nativeQualified'] and prior['runtime'] == selected['runtime'], 'Phase125 selected runtime mismatch')
        require(prior['roles']['phase111']['binary'] == selected['nativeCheckpoint']['n1'] and prior['roles']['phase112']['binary'] == selected['nativeCheckpoint']['n2'], 'Phase125 selected images mismatch')
        require(prior['roles']['phase111']['source'] == prior['roles']['phase112']['source'] == selected['source'], 'Phase125 selected source mismatch')
        require(prior['assemblerOption'] == manifest['assemblerOption'] and prior['buildPolicy'] == manifest['buildPolicy'], 'Matched assembler/build policy mismatch')
        prior['assemblerOption'] = manifest['assemblerOption']
        prior['buildPolicy'] = manifest['buildPolicy']
        prior['inputs'] = [*prior['inputs'], pin(ROOT/'implementation/phase125/candidate.json'), pin(SMALL_GUARD), pin(BASE125), pin(__file__), pin(RUNNER), pin(PARENT / 'derivation01.json'), pin(PARENT / 'timing-plan.py'), pin(HERE/'plan-v2.py'), pin(HERE/'comparison-staged.py')]
        prior['derivation'] = dict(kind='phase126-aligned-qualified-phase125-repeat',
            scope='Original qualified Phase125 images/runtime, frozen cases/clocks; newly emitted programs receive identical Phase123 assembler alignment. Separate sequential timing block, not interleaved across compiler generations. Original compiler image acquisition policy remains unchanged.')
        repeat_manifest = out.with_name(out.stem + '-phase125.json')
        old_target = target.with_name(args.tag + '-phase125')
        require(not repeat_manifest.exists() and not old_target.exists(), 'Fresh Phase125 repeat outputs required')
        with repeat_manifest.open('x') as stream:
            json.dump(prior, stream, indent=2); stream.write('\n')
        timing_inputs.append(pin(repeat_manifest))
        jobs.append(dict(name='phase125-contemporaneous-aligned-repeat', seconds=180,
            command=[sys.executable, '-B', str(RUNNER), '--manifest', str(repeat_manifest), '--out', str(old_target), '--rounds', '3', '--modes', 'cache']))
    out.parent.mkdir(parents=True, exist_ok=True)
    with out.open('x') as stream:
        json.dump(manifest, stream, indent=2); stream.write('\n')
    with jobs_path.open('x') as stream:
        json.dump(dict(kind='phase126-native-timing-jobs', targetsRun=False, inputs=[pin(out), *timing_inputs], jobs=jobs), stream, indent=2); stream.write('\n')
    guard = [sys.executable, '-B', str(HERE.parent/'guard-small-files.py'), '--out',
        str(ROOT/'selfhost/build/phase126'/(args.tag+'-guard')), '--seconds', str(180*len(jobs)+60),
        '--rss-mib','2048','--available-mib','4096','--file-mib','8','--cpu','3','--',
        sys.executable,'-B',str(ROOT/'selfhost/tools/performance/phase113/run-jobs.py'),
        '--plan',str(jobs_path),'--out',str(ROOT/'selfhost/build/phase113'/(args.tag+'-jobs'))]
    print(json.dumps(dict(complete=True, targetsRun=False, manifest=pin(out), jobPlan=pin(jobs_path),
        jobs=jobs, rootGuardCommand=guard, diskNotes='Unchanged runner refuses below256MiB before every request; historical block27.3MB, maxfile1.0MB. Separate optional Phase125 repeat adds another block.')))



if __name__ == '__main__':
    main()
