#!/usr/bin/env python3
"""Prepare exact-product physical profiles with the maintained general profiler.

Offline only: no target execution, compiler, sampler build, or new profiler.
Prints a guarded capture argv and separate offline comparison/render argv.
"""
import argparse
import json
import math
from pathlib import Path
import shlex
import statistics
import sys

sys.dont_write_bytecode = True
ROOT = Path(__file__).resolve().parents[3]
PROF = ROOT / 'selfhost/tools/profiler'
sys.path[:0] = [str(PROF), str(ROOT / 'selfhost/tools/bench')]
import freeze as F
import run as R
import bench as B


def require(condition, message):
    if not condition:
        raise ValueError(message)


def read(path):
    return json.loads(Path(path).read_text())


def main():
    p = argparse.ArgumentParser(description=__doc__)
    p.add_argument('--references', type=Path, default=ROOT/'selfhost/build/phase190/references01/manifest.json')
    p.add_argument('--candidate', type=Path, default=ROOT/'selfhost/build/phase190/operand-build01/programs.manifest.json')
    p.add_argument('--timing', type=Path, default=ROOT/'selfhost/build/phase190/runtime02/report.json')
    p.add_argument('--case', default='local-fold')
    p.add_argument('--roles', default='baseline,operands,c')
    p.add_argument('--seconds-per-run', type=float, default=2.9)
    p.add_argument('--sampler', type=Path, default=ROOT/'selfhost/build/phase159/thread-sampler01/sampler.so')
    p.add_argument('--out', type=Path, required=True)
    p.add_argument('--capture-out', type=Path, required=True)
    p.add_argument('--guard-out', type=Path, required=True)
    a = p.parse_args()
    roles = a.roles.split(',')
    require(set(roles) <= {'baseline', 'operands', 'c'} and len(set(roles)) == len(roles) and roles,
            'Choose unique baseline,operands,c roles')
    require(2.6 <= a.seconds_per_run <= 3.0, 'Bound per-run estimate to2.6–3.0 seconds')
    require(not any(path.exists() for path in (a.out, a.capture_out, a.guard_out)), 'Fresh output paths required')
    refs, candidate, timing = map(read, (a.references, a.candidate, a.timing))
    require(timing.get('complete') and not timing.get('changedInputs'), 'Complete unchanged calibration receipt required')
    calibrations = next(row for row in timing['cases'] if row['id'] == a.case)
    require(calibrations['summary']['complete'], 'Complete case calibration required')
    reference = next(row for row in refs['cases'] if row['id'] == a.case)
    current = next(row for row in candidate['cases'] if row['id'] == a.case)
    require(all(reference[k] == current[k] for k in ('source', 'expectedFile', 'point')), 'Source/point/oracle mismatch')
    require(reference['point'] == calibrations['point'], 'Calibration point mismatch')
    for pin in (reference['source'], reference['expectedFile']):
        R.verify(pin)
    point = reference['point']
    require(Path(reference['expectedFile']['file']).read_text() == point['expectedStdout'], 'Independent oracle mismatch')
    sampler_receipt = a.sampler.parent/'report.json'
    sampler = read(sampler_receipt)
    require(sampler.get('complete') and sampler['sampler'] == R.pin(a.sampler)
            and sampler['samplerScope'] == 'all_created_threads', 'Authenticated all-thread sampler required')
    a.out.mkdir(parents=True)
    empty = a.out/'empty.stderr'; empty.write_bytes(b'')
    variants, estimates = [], {}
    for role in roles:
        case, manifest = (current, a.candidate) if role == 'operands' else (reference, a.references)
        product = case['products'][role]
        binary = R.verify(product['artifact'])
        require(product['artifact'] in timing['inputs'], 'Calibration does not authenticate selected executable')
        samples = [row for row in calibrations['samples'] if row['role'] == role]
        require(samples and all(row['correct'] and not row['lowResolution'] and
                row['process']['command'][0] == str(binary) for row in samples), 'Usable matched calibration required')
        seconds_each = statistics.median(row['process']['cpuSeconds']/row['repetitions'] for row in samples)
        count = math.ceil(a.seconds_per_run/seconds_each)
        require(0 < count <= 2000000, 'Bounded profile repetition count required')
        expected_cpu = count*seconds_each
        estimates[role] = dict(repetitions=count, warmups=point['warmups'],
            calibratedCpuSecondsPerIteration=seconds_each, estimatedCpuSecondsPerRun=expected_cpu,
            estimatedPooledSamples=expected_cpu*(1/.008+1/.013), binary=product['artifact'])
        variants.append(dict(name=role, command=[str(binary), *B.native_runtime_arguments(product),
            str(count), str(point['warmups']), *map(str, point['runtimeArgs'])],
            runtimeArgumentConvention=product['runtimeArgumentConvention'],
            inputs=[str(manifest.resolve()), reference['source']['file']],
            stdout=dict(kind='prefix-integer-line', evidence=reference['expectedFile']['file'],
                prefix=point['expectedStdout']+str(point['warmups'])+'\n'+str(count)+'\n'), stderr=str(empty.resolve())))
    recipe = dict(cwd=str(ROOT), sampler=str(a.sampler.resolve()),
        inputs=[str(a.timing.resolve()), str(sampler_receipt.resolve()), str(Path(__file__).resolve()),
                *[str(PROF/name) for name in ('freeze.py','run.py','analyze.py','compare.py','render.py')]],
        scope='Physical ELF leaf profiles of retained exact programs. One clean plus8/13ms captures; independent stdout/count oracle. Role-specific repetition counts require per-iteration normalization; no direct total-CPU ratio claim.',
        workloads=[dict(name=a.case, timeoutSeconds=5, variants=variants)])
    recipe_path = a.out/'recipe.json'; R.save(recipe_path, recipe)
    manifest_path = a.out/'manifest.json'; R.save(manifest_path, F.freeze(recipe, recipe_path))
    py = str(Path(sys.executable).resolve())
    capture = [py,'-B',str(PROF/'run.py'),'--manifest',str(manifest_path.resolve()),'--out',str(a.capture_out.resolve()),
               '--modes','clean,sample','--rounds','1','--periods-us','8000,13000']
    guard = [py,'-B',str(ROOT/'selfhost/tools/build-retention/guard.py'),'--out',str(a.guard_out.resolve()),
             '--run-root',str(a.capture_out.resolve()),'--seconds','60','--disk-mib','64',
             '--rss-mib','2048','--available-mib','16384','--cpu','3','--',*capture]
    compare = [py,'-B',str(PROF/'compare.py'),'--report',str(a.capture_out.resolve()/'report.json'),
               '--out',str(a.out.resolve()/'comparison.json')]
    render = [py,'-B',str(PROF/'render.py'),'--comparison',str(a.out.resolve()/'comparison.json'),
              '--out',str(a.out.resolve()/'summary.md')]
    R.save(a.out/'plan.json', dict(kind='phase190-physical-profile-plan',targetsRun=False,
        manifest=R.pin(manifest_path), estimates=estimates,
        estimatedTargetCpuSeconds=3*sum(row['estimatedCpuSecondsPerRun'] for row in estimates.values()),
        captureCommand=guard, offlineCommands=[compare,render],
        acceptance='Complete unchanged exact-output captures; compare.py pooled adequate with>=500 samples, both periods, zero loss/overruns, CPU coverage and unknown-symbol gates. Reject inadequate profiles; do not lower thresholds.',
        interpretation='Physical symbol identity only. C inlining can move loop work into a caller. Normalize clean CPU and estimated owner CPU by each role repetition count before comparing. No source-owner proof or timing-ratio qualification.'))
    print(json.dumps(estimates,indent=2))
    for argv in (guard, compare, render):
        print(shlex.join(argv))


if __name__ == '__main__':
    main()
