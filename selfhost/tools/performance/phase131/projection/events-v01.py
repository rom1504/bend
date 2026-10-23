"""Prepare diagnostic-only relinks and event requests from retained objects."""
import argparse
import copy
import json
from pathlib import Path
import sys

HERE = Path(__file__).resolve().parent
ROOT = HERE.parents[4]
sys.path.insert(0, str(ROOT / 'selfhost/tools/profiler'))
from run import pin, save, verify, all_pins


def read(path):
    return json.loads(Path(path).read_text())


def main():
    ap = argparse.ArgumentParser(description=__doc__)
    ap.add_argument('--out', type=Path, required=True)
    ap.add_argument('--seal', action='store_true')
    args = ap.parse_args(); out = args.out.resolve()
    assert out.is_relative_to(ROOT / 'selfhost/build/phase131')
    pilot = ROOT / 'selfhost/build/phase131/projection-timing-pilot01/manifest.json'
    manifest = copy.deepcopy(read(pilot))
    manifest['workloads'] = [w for w in manifest['workloads'] if w['name'].endswith('size8')]
    if not args.seal:
        assert not out.exists(); out.mkdir(parents=True)
        runtime_plan = ROOT / 'selfhost/build/phase131/context01/runtime/plan.json'
        runtime_build = ROOT / 'selfhost/build/phase131/context01/build/report.json'
        plan, build = read(runtime_plan), read(runtime_build)
        assert plan['complete'] and plan['reverseExact'] and build['complete']
        runtime = next(p for p in build['products'] if Path(p['file']).name == 'runtime.o')
        for item in plan['inputs'] + plan['outputs'] + [runtime]: verify(item)
        plan['inputs'] += [pin(__file__), pin(runtime_plan), pin(runtime_build), runtime, pin(pilot)]
        plan['jobs'] = []
        for work in manifest['workloads']:
            case = work['name'].removesuffix('-size8')
            for variant in work['variants']:
                stem = (f'p131-projection-loop04-baseline-{case}-build' if variant['name'] == 'baseline'
                    else f'p131-projection06-{variant["name"]}-{case}-build')
                report_path = ROOT / 'selfhost/build/phase111' / stem / 'report.json'
                report = read(report_path)
                assert report['complete'] and report['outputExact'] and report['binary'] == variant['binary']
                for item in report['inputs'] + [report['object']]: verify(item)
                plan['inputs'] += [pin(report_path), *report['inputs'], report['object']]
                target = out / f'{case}-{variant["name"]}'
                plan['jobs'].append(dict(label=target.name, command=['/usr/bin/gcc', '-no-pie',
                    report['object']['file'], runtime['file'], '-pthread', '-lm', '-o', str(target)]))
        plan['scope'] = 'Relink only: exact cached diagnostic runtime and retained program objects. No runtime recompilation or clean-performance use; original reversible instrumentation receipt is pinned.'
        save(out / 'plan.json', plan)
    else:
        build = read(out / 'build/report.json'); assert build['complete']
        manifest['inputs'] += [pin(__file__), pin(out / 'plan.json'), pin(out / 'build/report.json')]
        for work in manifest['workloads']:
            case = work['name'].removesuffix('-size8')
            for variant in work['variants']:
                binary = next(p for p in build['products'] if Path(p['file']).name == f'{case}-{variant["name"]}')
                variant['binary'] = binary; variant['command'][0] = binary['file']
                variant['dispatchInstrumentation'] = True
        manifest['scope'] = 'Diagnostic event totals only, size8/2048repetitions, same exact output oracle. Counter cost and timings cannot be used as a clean-speed estimate.'
        for item in all_pins(manifest): verify(item)
        save(out / 'manifest.json', manifest)
    print(json.dumps(dict(complete=True, targetsRun=False, out=str(out), sealed=args.seal)))


if __name__ == '__main__': main()
