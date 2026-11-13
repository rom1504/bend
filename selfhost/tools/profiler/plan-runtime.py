#!/usr/bin/env python3
"""Freeze calibrated native benchmark profiles; print commands, execute no targets.

Consumes an explicit maintained program manifest and its completed adaptive
runtime report. Role-specific counts become distinct workloads, never a
cross-variant identical-work comparison. Sampling remains diagnostic.
"""
import argparse
import json
import math
from pathlib import Path
import shlex
import statistics
import sys

sys.dont_write_bytecode = True
HERE = Path(__file__).resolve().parent
ROOT = HERE.parents[2]
sys.path.insert(0, str(HERE.parent / 'bench'))
import bench as B
import freeze as F
import run as R


def selected(text):
    names = text.split(',')
    B.require(names and len(names) == len(set(names)) and all(B.NAME.fullmatch(n) for n in names),
              'Unique safe case/role names required')
    return names


def command(product, point, count):
    return [str(R.verify(product['artifact'])), *B.native_runtime_arguments(product),
            str(count), str(point['warmups']), *map(str, point['runtimeArgs'])]


def calibration(case, timed, role, inputs):
    point, product = case['point'], case['products'][role]
    B.require(timed['point'] == point and timed['summary']['complete'] and point['ratioEligible'],
              'Complete matching runtime-eligible case required')
    B.require(product['artifact'] in inputs, 'Calibration does not bind selected executable')
    samples = [row for row in timed['samples'] if row['role'] == role]
    B.require(samples, 'Missing role calibration')
    rates, pins = [], []
    for row in samples:
        process = row['process']
        count = row['repetitions']
        B.require(type(count) is int and count > 0 and row['warmups'] == point['warmups'],
                  'Invalid calibration repetition/warmup counts')
        B.require(row['correct'] and not row['lowResolution'] and not process['timedOut']
                  and process['exitCode'] == 0 and process['command'] == command(product, point, count),
                  'Usable exact-command calibration required')
        cpu = process['cpuSeconds']
        B.require(math.isfinite(cpu) and cpu > 0, 'Positive finite calibration CPU required')
        stdout, stderr = (R.verify(process[channel]) for channel in ('stdout', 'stderr'))
        B.observation(stdout.read_bytes(), stderr.read_bytes(), process['exitCode'],
                      dict(point, repetitions=count), process['seconds'])
        pins.extend([process['stdout'], process['stderr']])
        rates.append(cpu/count)
    return statistics.median(rates), pins


def prepare(a):
    cases, roles = selected(a.cases), selected(a.roles)
    periods = [int(value) for value in a.periods_us.split(',')]
    B.require(len(set(periods)) >= 2 and all(4000 <= p <= 100000 for p in periods),
              'Use at least two distinct sample periods between 4000 and 100000 us')
    B.require(math.isfinite(a.seconds_per_run) and 2.6 <= a.seconds_per_run <= 10
              and 1 <= a.clean_rounds <= 10, 'Bounded positive capture duration/rounds required')
    outputs = [p.resolve() for p in (a.out, a.capture_out, a.guard_out)]
    B.require(not any(p.exists() for p in outputs) and len(set(outputs)) == 3
              and not any(x in y.parents for x in outputs for y in outputs if x != y),
              'Fresh distinct nonnested output directories required')
    document, timing, sampler = map(B.read, (a.manifest, a.timing, a.sampler_receipt))
    B.require(document.get('schema') == 'bend-benchmark-manifest-v1' and document.get('kind') == 'programs',
              'Frozen maintained program manifest required')
    B.require(timing.get('complete') and not timing.get('changedInputs')
              and R.pin(a.manifest) in timing['inputs'], 'Complete unchanged exact-manifest timing report required')
    B.require(sampler.get('complete') and sampler.get('returncode') == 0
              and sampler.get('sampler') == R.pin(a.sampler)
              and sampler.get('samplerScope') == 'all_created_threads',
              'Authenticated all-created-thread sampler build required')
    pins = B.unique_inputs([R.pin(a.manifest), R.pin(a.timing), R.pin(a.sampler_receipt),
                           *document['inputs'], *timing['inputs'], *R.all_pins(sampler)])
    for pin in pins:
        R.verify(pin)
    known = {c['id']: c for c in document['cases']}
    measured = {c['id']: c for c in timing['cases']}
    B.require(len(known) == len(document['cases']) and len(measured) == len(timing['cases']),
              'Duplicate input case IDs')
    B.require(all(c in known and c in measured for c in cases), 'Unknown case selection')
    B.require(all(r in document['roles'] and document['roles'][r]['target'] in ('c', 'qbe', 'x86')
                  and timing['roles'].get(r) == document['roles'][r] for r in roles),
              'Matching native roles required')
    timeout = math.ceil(2*a.seconds_per_run + 2)
    workloads, estimates = [], []
    empty = outputs[0]/'empty.stderr'
    for case_id in cases:
        case = known[case_id]
        source, oracle = R.verify(case['source']), R.verify(case['expectedFile'])
        B.require(oracle.read_bytes() == case['point']['expectedStdout'].encode(), 'Independent oracle mismatch')
        pins.extend([case['source'], case['expectedFile']])
        for role in roles:
            B.require(role in case['products'], 'Selected product missing')
            rate, observations = calibration(case, measured[case_id], role, timing['inputs'])
            pins.extend(observations)
            count = math.ceil(a.seconds_per_run/rate)
            B.require(0 < count <= 2000000, 'Profile repetition count exceeds bounded adapter scope')
            product, point = case['products'][role], case['point']
            # Length prefix makes the case/role pair unambiguous and path-safe.
            name = str(len(case_id))+'-'+case_id+'-'+role
            variant = dict(name=role, command=command(product, point, count),
                runtimeArgumentConvention=R.runtime_argument_convention(product),
                inputs=[str(a.manifest.resolve()), str(source)],
                stdout=dict(kind='prefix-integer-line', evidence=str(oracle),
                    prefix=point['expectedStdout']+str(point['warmups'])+'\n'+str(count)+'\n'),
                stderr=str(empty))
            workloads.append(dict(name=name, timeoutSeconds=timeout, variants=[variant]))
            estimates.append(dict(workload=name, case=case_id, role=role, binary=product['artifact'],
                repetitions=count, warmups=point['warmups'], runtimeArgs=point['runtimeArgs'],
                calibratedCpuSecondsPerRepetition=rate, estimatedCpuSecondsPerRun=count*rate,
                estimatedPooledSamples=count*rate*sum(1000000/p for p in periods)))
    pins = B.unique_inputs(pins)
    for pin in pins:
        R.verify(pin)
    outputs[0].mkdir(parents=True)
    empty.write_bytes(b'')
    recipe = dict(cwd=document['cwd'], sampler=str(a.sampler.resolve()),
        inputs=[*[pin['file'] for pin in pins], str(Path(__file__).resolve()), str(B.__file__),
                *[str(HERE/name) for name in ('freeze.py', 'run.py', 'analyze.py', 'compare.py', 'render.py')]],
        scope='Calibrated physical native runtime profiles. Distinct case/role workloads; unequal repetition counts prohibit direct total-CPU ratios. Normalize only with explicit plan denominators.',
        workloads=workloads)
    recipe_path, manifest_path = outputs[0]/'recipe.json', outputs[0]/'manifest.json'
    R.save(recipe_path, recipe)
    R.save(manifest_path, F.freeze(recipe, recipe_path))
    py = str(Path(sys.executable).resolve())
    capture = [py, '-B', str(HERE/'run.py'), '--manifest', str(manifest_path), '--out', str(outputs[1]),
               '--modes', 'clean,sample', '--rounds', str(a.clean_rounds), '--periods-us', a.periods_us]
    guard = [py, '-B', str(HERE.parent/'build-retention/guard.py'), '--out', str(outputs[2]),
             '--run-root', str(outputs[1]), '--seconds', str(30+timeout*len(workloads)*(a.clean_rounds+len(periods))),
             '--disk-mib', '128', '--rss-mib', '2048', '--available-mib', '16384', '--cpu', str(a.cpu), '--', *capture]
    compare = [py, '-B', str(HERE/'compare.py'), '--report', str(outputs[1]/'report.json'),
               '--out', str(outputs[0]/'comparison.json')]
    render = [py, '-B', str(HERE/'render.py'), '--comparison', str(outputs[0]/'comparison.json'),
              '--out', str(outputs[0]/'summary.md')]
    plan = dict(schema='bend-native-runtime-profile-plan-v1', targetsRun=False, manifest=R.pin(manifest_path),
        programManifest=R.pin(a.manifest), calibrationReport=R.pin(a.timing), estimates=estimates,
        samplePeriodsUs=periods, cleanRounds=a.clean_rounds,
        estimatedTargetCpuSeconds=(a.clean_rounds+len(periods))*sum(r['estimatedCpuSecondsPerRun'] for r in estimates),
        captureCommand=guard, offlineCommands=[compare, render],
        acceptance='Require complete unchanged exact-output captures and existing >=500 pooled sample, multiple period, coverage, unknown-symbol and zero-loss/overrun gates. Estimates do not guarantee admission.',
        interpretation='Pool only identical role commands. No cross-role total-CPU ratio: counts differ. Divide each role clean CPU or admitted estimated owner CPU by its own repetitions for descriptive per-repetition attribution. Startup/warmups remain included; this is not paired runtime qualification or source-owner proof.')
    R.save(outputs[0]/'plan.json', plan)
    return plan


def main():
    p = argparse.ArgumentParser(description=__doc__)
    for name in ('manifest', 'timing', 'sampler', 'sampler-receipt', 'out', 'capture-out', 'guard-out'):
        p.add_argument('--'+name, required=True, type=Path)
    p.add_argument('--cases', required=True)
    p.add_argument('--roles', required=True)
    p.add_argument('--seconds-per-run', type=float, default=2.9)
    p.add_argument('--periods-us', default='8000,13000')
    p.add_argument('--clean-rounds', type=int, default=1)
    p.add_argument('--cpu', type=int, default=3)
    plan = prepare(p.parse_args())
    print(json.dumps(plan['estimates'], indent=2))
    for argv in [plan['captureCommand'], *plan['offlineCommands']]:
        print(shlex.join(argv))


if __name__ == '__main__':
    main()
