#!/usr/bin/env python3
"""Prepare bounded leaf profiles of an already validated native unit harness."""
import argparse
import json
import math
from pathlib import Path
import sys

ROOT = Path(__file__).resolve().parents[2]
sys.dont_write_bytecode = True
sys.path.insert(0, str(ROOT / 'selfhost/tools/profiler'))
from freeze import freeze
from run import verify
sys.path.insert(0, str(Path(__file__).with_name('tools')))
from shared import guard


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--native', type=Path, required=True)
    parser.add_argument('--timing', type=Path, required=True)
    parser.add_argument('--out', type=Path, required=True)
    args = parser.parse_args()
    plan = json.loads(args.native.read_text())
    timing = json.loads(args.timing.read_text())
    if not (timing['complete'] and timing['passed'] and timing['performanceQualified']):
        raise ValueError('Qualified complete-region timing and output controls required')
    build = json.loads(Path(plan['buildReport']).read_text())
    if not build['complete'] or build.get('changedInputs'):
        raise ValueError('Successful authenticated native build required')
    binary = build['binary']
    verify(binary)
    if timing['family'] != plan['family'] or binary not in timing['inputs']:
        raise ValueError('Timing/image/family identity mismatch')
    out = args.out.resolve()
    out.mkdir(parents=True, exist_ok=False)
    (out / 'empty').write_bytes(b'')
    sampler = ROOT / 'selfhost/build/phase147/profile-build02/runtime/sampler.so'
    variants = []
    for mode in ['old', 'new']:
        # Different diagnostic counts give both variants enough samples without
        # making the slower one dominate the campaign. Compare shares, not their
        # unnormalized diagnostic elapsed times.
        count = min(65536, max(1, math.ceil(timing['repeats'] * 12 / timing['medianSeconds'][mode])))
        variants.append(dict(name=mode, command=[binary['file'], '--threads', '1', '--gpu', 'off', '--',
                             'compact-unit', mode, 'bench', str(count)], stdout=str(out / 'empty'),
                             stderr=str(out / 'empty'), inputs=[str(args.native.resolve()), str(args.timing.resolve())]))
    recipe = dict(cwd=str(ROOT), sampler=str(sampler),
        inputs=[str(Path(__file__).resolve()), str(Path(plan['buildReport']).resolve()),
                str(ROOT / 'selfhost/build/phase147/profile-build02/report.json'), plan['source']['file']],
        scope='Fresh-image physical leaf profiles of complete unit pipelines. Diagnostic repetition counts differ; compare sample shares, not raw elapsed times. Exact output controls are the independently pinned paired timing prerequisite.',
        workloads=[dict(name=plan['family'], timeoutSeconds=20, variants=variants)])
    recipe_path = out / 'recipe.json'
    recipe_path.write_text(json.dumps(recipe, indent=2) + '\n')
    manifest = freeze(recipe, recipe_path)
    (out / 'manifest.json').write_text(json.dumps(manifest, indent=2) + '\n')
    job = guard('phase148-unit-leaf-profile', out / 'capture', ['python3', '-B',
        ROOT / 'selfhost/tools/profiler/run.py', '--manifest', out / 'manifest.json',
        '--out', out / 'capture', '--modes', 'sample', '--rounds', '1', '--periods-us', '16000'], 60, 2048, 128)
    (out / 'job.json').write_text(json.dumps(job, indent=2) + '\n')
    print(json.dumps(dict(job=str(out / 'job.json'), counts=[v['command'][-1] for v in variants])))


if __name__ == '__main__':
    main()
