#!/usr/bin/env python3
"""Prepare exact bounded qualification argv from Phase191 receipts; execute nothing."""
import argparse
import hashlib
import json
from pathlib import Path
import shlex
import shutil

ROOT = Path(__file__).resolve().parents[3]
OLD = ROOT/'selfhost/build/phase191'
NEW = ROOT/'selfhost/build/phase192'


def pin(path):
    path = Path(path).resolve(strict=True)
    data = path.read_bytes()
    return dict(file=str(path), bytes=len(data), sha256=hashlib.sha256(data).hexdigest())


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--out', type=Path, required=True, help='Fresh JSON plan, not an execution directory')
    args = parser.parse_args()
    assert not args.out.exists() and args.out.suffix == '.json', 'Fresh JSON plan required'
    # name, outer seconds, disk MiB, RSS MiB, per-file MiB, dependencies
    schedule = [
        ('native-image01', 520, 192, 3072, 192, ['selected-source01']),
        ('native45-01', 450, 128, 2048, 128, ['native-image01']),
        ('native-self01', 650, 192, 3072, 192, ['native-image01', 'native45-01']),
        ('native64-01', 600, 160, 2048, 128, ['native-self01']),
        ('runtime10-01', 180, 64, 2048, 128, ['native-self01', 'native64-01']),
        ('native-reproduction01', 700, 192, 3072, 192, ['native-self01', 'runtime10-01']),
        ('native45-02', 450, 128, 2048, 128, ['native-self01', 'native-reproduction01']),
    ]
    steps = []
    evidence = []
    historical_allocated = historical_wall = 0
    for name, seconds, disk, rss, file_limit, dependencies in schedule:
        receipt_path = OLD/(name+'-guard/process.json')
        receipt = json.loads(receipt_path.read_text())
        assert receipt['complete'] and receipt['returncode'] == 0
        evidence.append(pin(receipt_path))
        original = receipt['command']
        command = [word.replace('selfhost/build/phase191/', 'selfhost/build/phase192/')
                   for word in original[original.index('python3'):]]
        if name == 'native64-01':
            command += ['--catalog', 'selfhost/tests/phase182/qualification-catalog.json']
        argv = ['python3', '-B', 'selfhost/tests/phase192/job.py', '--rss-mib', str(rss),
                '--file-mib', str(file_limit), name, str(seconds), str(disk), *command]
        steps.append(dict(name=name, dependsOn=dependencies, argv=argv, shell=shlex.join(argv),
            targetRuns=True, guardSeconds=seconds, diskMiB=disk, rssMiB=rss, fileMiB=file_limit,
            output=str(NEW/name), guard=str(NEW/(name+'-guard')),
            closure=str(ROOT/'selfhost/build-retention/phase192'/(name+'-close')),
            historical=dict(process=pin(receipt_path), wallSeconds=receipt['wallSeconds'],
                            peakAllocatedBytes=receipt['peakRunAllocatedBytes'],
                            peakRssBytes=receipt['peakTreeRssBytes'])))
        historical_allocated += receipt['peakRunAllocatedBytes']
        historical_wall += receipt['wallSeconds']
    compare = ['python3', '-B', 'selfhost/tests/phase190/compare-native-products.py',
        '--left', 'selfhost/build/phase192/native45-01/programs.manifest.json',
        '--right', 'selfhost/build/phase192/native45-02/programs.manifest.json',
        '--seconds', '120', '--out', 'selfhost/build/phase192/native-generations-compare01']
    argv = ['python3', '-B', 'selfhost/tests/phase192/job.py', 'native-generations-compare01',
            '180', '16', *compare]
    steps.append(dict(name='native-generations-compare01', dependsOn=['native45-01', 'native45-02'],
        argv=argv, shell=shlex.join(argv), targetRuns=False, guardSeconds=180, diskMiB=16,
        rssMiB=2048, fileMiB=128, output=str(NEW/'native-generations-compare01')))
    files = [
        'selfhost/build/phase192/assets.json',
        'selfhost/build/phase186/release-qbe-chain01/n2/program',
        'selfhost/build/phase186/release-qbe-chain01/n2/report.json',
        'selfhost/tools/build/native.py', 'selfhost/tools/build/request.py',
        'selfhost/tools/build/assets.py', 'selfhost/tools/build/common.py',
        'selfhost/tools/build/qualification.py', 'selfhost/tools/build-retention/guard.py',
        'selfhost/tools/build-retention/close.py', 'selfhost/tests/phase192/job.py',
        'selfhost/tests/phase190/native-programs.py',
        'selfhost/tests/phase190/compare-native-products.py',
        'selfhost/tests/phase190/compare-products.py', 'selfhost/tests/phase188/product_compare.py', 'selfhost/tools/bench/bench.py',
        'selfhost/tests/phase183/runtime-controls.py',
        'selfhost/tests/phase182/qualification-catalog.json',
        'selfhost/tools/bench/catalogs/native45/catalog.json', 'selfhost/tests/phase190/cases.json']
    inputs = [pin(ROOT/file) for file in files]
    assets = json.loads((NEW/'assets.json').read_text())
    catalog = json.loads((ROOT/'selfhost/tests/phase182/qualification-catalog.json').read_text())
    assert assets['upstream'] == catalog['upstream']
    selected = NEW/'selected-source01/compiler.bend'
    free = shutil.disk_usage(ROOT).free
    result = dict(kind='phase192-native-qualification-execution-plan', complete=True, executed=False,
        targetsRun=False, method=pin(__file__), inputs=inputs, phase191Evidence=evidence,
        selectedSource=pin(selected) if selected.exists() else None,
        selectedSourceRequired=str(selected), readyToStart=selected.exists(),
        prerequisites=[
            'Freeze the final integrated x86 source at selected-source01/compiler.bend and its source-map.json; bind its exact hash before execution and keep it unchanged through every generation.',
            'Retain the checked source/API control evidence for this exact final selection; do not infer source checking from assembly alone.',
            'Authenticate listed seed/asset/tool/catalog identities; retain assets.json. Native tools do not accept --manifest; the explicit source and assets already isolate them from live compiler.json.',
            'Each listed output, guard and closure directory must be fresh. Execute serially on the shared CPU3 lane using one outer disk guard; no nested guards.',
            'Continue only after each producer report is complete, clean and has no changed inputs; native64 and runtime10 additionally require passed:true.',
        ], steps=steps,
        requiredResults=dict(native45N1=45, native45N2=45, native64=64, runtimeControls=10,
            selfReproduction='native-reproduction01/report.json must have comparedToReference:true and the exact expectedObject pin for native-self01/program.o',
            productComparison='native-generations-compare01/report.json: complete:true, objectsIdentical:45, linkedSectionsIdentical:135'),
        storage=dict(reserveBytes=5*1024**3, freeAtPlanningBytes=free,
            currentHeadroomBytes=free-5*1024**3, historicalSevenJobPeakAllocatedSumBytes=historical_allocated,
            historicalSevenJobWallSeconds=historical_wall, planningAllowanceMiB=512,
            note='The prior seven routes retained about280MiB combined;512MiB is a planning allowance, not a new or nested guard. Per-job budgets remain explicit and are not summed as consumption. External writers and larger products may force admission refusal.',
            policy='Stream QBE acquisition without --retain-ir. N2/N3 use direct objects and avoid SSA/assembly copies. Preserve every image, program.o, runtime dependency, acquisition/oracle receipt, native45 manifest and linked product needed by comparison. The catalog adapter deliberately retains per-case objects. Do not prune active qualification products or reduce the5GiB reserve; stop between jobs if headroom refuses admission.'),
        qualificationBoundary='Finite selected-source native qualification and exact reproduction only; no production install/promotion, complete-language proof, broad upstream conformance or benchmark timing is implied.')
    args.out.parent.mkdir(parents=True, exist_ok=True)
    with args.out.open('x') as stream:
        json.dump(result, stream, indent=2)
        stream.write('\n')
    print(json.dumps(dict(plan=str(args.out), steps=len(steps), targetsRun=False,
                         readyToStart=result['readyToStart'], historicalAllocatedMiB=historical_allocated/1024**2,
                         historicalWallSeconds=historical_wall)))


if __name__ == '__main__':
    main()
