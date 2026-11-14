#!/usr/bin/env python3
"""Prepare a serial Phase194 qualification plan from retained Phase193 argv; no targets."""
import argparse
import json
from pathlib import Path
import shlex
import shutil
import sys

sys.dont_write_bytecode = True
ROOT = Path(__file__).resolve().parents[3]
sys.path.insert(0, str(ROOT/'selfhost/tools/build'))
import common as C


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--source', type=Path, required=True, help='Final frozen compiler.bend; may be absent for a draft plan')
    parser.add_argument('--assets', type=Path, default=ROOT/'selfhost/build/phase194/assets.json')
    parser.add_argument('--prefix', default='', help='Fresh simple job-name prefix, e.g. selected-')
    parser.add_argument('--out', type=Path, required=True, help='Fresh JSON plan; not a target output directory')
    args = parser.parse_args()
    C.require(not args.out.exists() and args.out.suffix == '.json', 'Fresh JSON plan required')
    C.require(all(c.isalnum() or c in '-_' for c in args.prefix), 'Simple job prefix required')
    source = args.source.resolve()
    assets = args.assets.resolve()
    base = ROOT/'selfhost/build/phase194'
    C.require(source.is_relative_to(base), 'Freeze the selected compiler source inside Phase194')
    steps, evidence = [], []
    # Established generous per-job limits; elapsed campaign estimate is separate.
    schedule = [
        ('native-image01', 520, 192, 3072, 192),
        ('native45-01', 450, 128, 2048, 128),
        ('native-self01', 650, 192, 3072, 192),
        ('native64-01', 600, 160, 2048, 128),
        ('runtime10-01', 180, 64, 2048, 128),
        ('native-reproduction01', 700, 192, 3072, 192),
        ('native45-02', 450, 128, 2048, 128),
        ('native-generations-compare01', 180, 16, 2048, 128),
    ]
    historical_seconds = 0
    historical_allocated = 0

    def add(name, command, seconds, disk, rss=2048, file_limit=128, targets=True, history=None):
        name = args.prefix+name
        output, guard = base/name, base/(name+'-guard')
        closure = ROOT/'selfhost/build-retention/phase194'/(name+'-close')
        C.require(not any(p.exists() for p in (output, guard, closure)), 'Fresh output/guard/closure required: '+name)
        argv = ['python3', '-B', 'selfhost/tests/phase194/job.py', '--cpu', '3',
            '--rss-mib', str(rss), '--file-mib', str(file_limit), name, str(seconds), str(disk), *command]
        steps.append(dict(name=name, dependsOn=[steps[-1]['name']] if steps else [], argv=argv,
            shell=shlex.join(argv), targetRuns=targets, guardSeconds=seconds, diskMiB=disk, rssMiB=rss,
            fileMiB=file_limit, reserveMiB=5120, output=str(output), guard=str(guard), closure=str(closure),
            historical=history))

    def compiler_cost(stage):
        suffix = stage.lower()
        acquisition = 'native45-01' if stage == 'N1' else 'native45-02'
        plan_name, run_name = 'compiler-cost-'+suffix+'-plan01', 'compiler-cost-'+suffix+'-01'
        plan_dir = base/(args.prefix+plan_name)
        command = ['python3', '-B', 'selfhost/tests/phase194/compiler-cost-plan.py', '--stage', stage,
            '--source', str(source), '--assets', str(assets), '--candidate-build', str(base/(args.prefix+acquisition)),
            '--out', str(plan_dir)]
        add(plan_name, command, 60, 16, targets=False)
        command = ['python3', '-B', 'selfhost/tools/bench/bench.py', 'run', '--manifest', str(plan_dir/'manifest.json'),
            '--set', 'full', '--rounds', '2', '--budget', '60', '--guarded', '--out', str(base/(args.prefix+run_name))]
        receipt = ROOT/'selfhost/build/phase193'/('budget-'+run_name+'-guard/process.json')
        prior = json.loads(receipt.read_text())
        C.require(prior['complete'] and prior['returncode'] == 0, 'Successful historical cost screen required')
        evidence.append(C.pin(receipt))
        add(run_name, command, 75, 128, history=dict(receipt=evidence[-1], wallSeconds=prior['wallSeconds']))
        return prior['wallSeconds']

    for name, seconds, disk, rss, file_limit in schedule:
        receipt = ROOT/'selfhost/build/phase193'/('budget-'+name+'-guard/process.json')
        prior = json.loads(receipt.read_text())
        C.require(prior['complete'] and prior['returncode'] == 0, 'Successful historical qualification required')
        evidence.append(C.pin(receipt))
        original = prior['command'][prior['command'].index('python3'):]
        command = []
        for word in original:
            if word == 'selfhost/build/phase193/selected-source02/compiler.bend': word = str(source)
            elif word == 'selfhost/build/phase193/assets.json': word = str(assets)
            else: word = word.replace('selfhost/build/phase193/budget-', 'selfhost/build/phase194/'+args.prefix)
            command.append(word)
        add(name, command, seconds, disk, rss, file_limit, name != 'native-generations-compare01',
            dict(receipt=evidence[-1], wallSeconds=prior['wallSeconds'], peakAllocatedBytes=prior['peakRunAllocatedBytes'],
                 peakRssBytes=prior['peakTreeRssBytes']))
        historical_seconds += prior['wallSeconds']
        historical_allocated += prior['peakRunAllocatedBytes']
        if name == 'native45-01': historical_seconds += compiler_cost('N1')
        if name == 'native-generations-compare01': historical_seconds += compiler_cost('N2')
    files = {str(assets), __file__, str(ROOT/'selfhost/tests/phase194/compiler-cost-plan.py'),
        str(ROOT/'selfhost/tests/phase193/compiler-cost-plan-v2.py'), str(ROOT/'selfhost/tests/phase192/compiler-cost-plan.py'),
        str(ROOT/'selfhost/tests/phase193/compiler-cost-plan.py'), str(ROOT/'selfhost/tools/build-retention/guard.py'),
        str(ROOT/'selfhost/tools/build-retention/close.py'), str(ROOT/'selfhost/tools/build/request.py'),
        str(ROOT/'selfhost/tools/build/assets.py'), str(ROOT/'selfhost/tools/build/common.py'),
        str(ROOT/'selfhost/tests/phase190/compare-products.py'), str(ROOT/'selfhost/tests/phase188/product_compare.py'),
        str(ROOT/'selfhost/tools/bench/catalogs/native45/catalog.json'), str(ROOT/'selfhost/tests/phase190/cases.json'),
        str(ROOT/'selfhost/tests/phase194/cases.json'), str(ROOT/'implementation/phase193/evidence.json')}
    for step in steps:
        for word in step['argv']:
            p = ROOT/word
            if p.is_file(): files.add(str(p))
    inputs = [C.pin(p) for p in sorted(files)]
    asset_doc = json.loads(assets.read_text())
    catalog = json.loads((ROOT/'selfhost/tests/phase182/qualification-catalog.json').read_text())
    C.require(asset_doc['upstream'] == catalog['upstream'], 'Pinned native64 upstream differs')
    free = shutil.disk_usage(ROOT).free
    result = dict(kind='phase194-native-qualification-plan', complete=True, executed=False, targetsRun=False,
        selectedSource=C.pin(source) if source.is_file() else None, selectedSourceRequired=str(source),
        readyToStart=source.is_file(), method=C.pin(__file__), inputs=inputs, historicalEvidence=evidence, steps=steps,
        estimatedHistoricalSeconds=historical_seconds, estimateScope='Prior guarded work, about20min; excludes new preparation, orchestration and analysis. Not a deadline or performance prediction.',
        storage=dict(reserveBytes=5*1024**3, freeAtPlanningBytes=free, historicalNativePeakAllocatedSumBytes=historical_allocated,
            planningAllowanceMiB=512, note='Planning allowance is not consumption. Existing job.py retains the guard default 5120MiB reserve. Never lower reserve, nest guards or prune active products.'),
        prerequisites=['Freeze and independently source-check the exact --source; retain selected API/control/runtime evidence before full qualification.',
            'Authenticate plan input/source pins before starting and before subsequent jobs; regenerate the plan if a frozen source or tool changes.',
            'Root executes exactly one step at a time on CPU3 and checks complete/unchanged producer reports before proceeding. No installed promotion.',
            'Review the N1 compiler-cost guardrail before the N1-to-N2 self-build. Review N2 net request cost before accepting the candidate. No automatic performance threshold is imposed.',
            'Pause between jobs if the remaining campaign time or disk admission cannot cover the next job; never relax correctness or truncate catalogs to meet the estimate.'],
        requiredResults=dict(native45N1=45, native45N2=45, native64='complete:true, passed:true, 64 cases', runtime10='complete:true, passed:true, 10 controls',
            reproduction='N3 complete/unchanged; comparedToReference:true and expectedObject exactly N2/program.o',
            products='45 identical objects and 135 identical linked sections across N1/N2',
            compilerCost='Each stage: two balanced rounds, four requests, 16 exact own-role objects; preserve all per-request medians/regressions. Same request input does not mean same compiler source.'),
        boundary='Finite native qualification and exact object reproduction. Source checking, measured runtime transfer and installation remain separate decisions.')
    args.out.parent.mkdir(parents=True, exist_ok=True)
    with args.out.open('x') as stream: json.dump(result, stream, indent=2); stream.write('\n')
    print(json.dumps(dict(plan=str(args.out), steps=len(steps), readyToStart=result['readyToStart'],
        estimatedHistoricalSeconds=historical_seconds, targetsRun=False)))


if __name__ == '__main__':
    main()
