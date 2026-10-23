#!/usr/bin/env python3
"""Prepare ordinary-program profiler transfer; never compile or execute a target."""
import argparse
import copy
import importlib.util
import json
from pathlib import Path
import subprocess
import sys

sys.dont_write_bytecode = True
ROOT = Path(__file__).resolve().parents[4]
PROFILER = ROOT / 'selfhost/tools/profiler'
NAMES = ['mandelbrot', 'tree-bitonic']


def load_module(name, path):
    spec = importlib.util.spec_from_file_location(name, path)
    module = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(module)
    return module


R = load_module('p127_program_profile_run', PROFILER / 'run.py')
O = load_module('p127_program_profile_owners', PROFILER / 'owners.py')


def read(path):
    return json.loads(Path(path).read_text())


def require(ok, message):
    if not ok:
        raise ValueError(message)


def fresh(path):
    path = Path(path).resolve()
    require(path.is_relative_to(ROOT / 'selfhost/build/phase127') and not path.exists(),
            'Fresh Phase127 output required: ' + str(path))
    return path


def unique(pins):
    rows = {}
    for item in pins:
        item = {key: item[key] for key in ['file', 'bytes', 'sha256']}
        require(item['file'] not in rows or rows[item['file']] == item, 'Conflicting input pin')
        rows[item['file']] = item
    for item in rows.values():
        R.verify(item)
    return list(rows.values())


def prepare(args):
    out = fresh(args.out)
    screen_path = ROOT / 'selfhost/build/phase126/final32-screen/report.json'
    emission_path = ROOT / 'selfhost/build/phase126/final32-emission.json'
    cases_path = ROOT / 'selfhost/tools/performance/phase112/benchmark45/manifest01.json'
    runtime_path = ROOT / 'selfhost/build/phase126/runtime-divmod01/report.json'
    screen, emission, cases, runtime = map(read, [screen_path, emission_path, cases_path, runtime_path])
    require(screen['complete'] and emission['complete'] and runtime['complete'], 'Incomplete retained evidence')
    require(R.pin(emission_path) in screen['inputs'], 'Screen does not bind this emission')
    require(R.pin(cases_path) in screen['inputs'], 'Screen does not bind frozen benchmark definitions')
    require(emission['runtime'] == runtime['object'], 'Emission/runtime identity mismatch')
    sampler = read(args.sampler_report)
    require(sampler['complete'], 'Complete sampler build required')
    sampler_sources = [p for p in sampler['snapshots'] if Path(p['file']).name == 'sample.c']
    require(len(sampler_sources) == 1, 'Pinned sampler source snapshot required')
    tables = [p for p in sampler['inputs'] if Path(p['file']).name == 'table.json']
    require(len(tables) <= 1, 'Ambiguous sampler unwind table')
    inputs = unique([R.pin(__file__), R.pin(PROFILER / 'run.py'), R.pin(PROFILER / 'owners.py'),
        R.pin(PROFILER / 'runtime.py'), R.pin(PROFILER / 'runtime-support.inc.c'),
        *[R.pin(p) for p in [screen_path, emission_path, cases_path, runtime_path, args.sampler_report]],
        runtime['source'], runtime['object'], sampler['sampler'], *sampler['snapshots'], *tables])
    prepared = []
    for name in NAMES:
        case = next(c for c in cases['cases'] if c['name'] == name)
        emitted = next(c for c in emission['cases'] if c['name'] == name)
        build = next(c for c in screen['builds'] if c['name'] == name)
        require(build['status'] == 0, 'Retained machine build failed')
        R.verify(build['report']); built = read(build['report']['file'])
        require(built['complete'] and emitted['qbe'] in built['inputs'] and runtime['object'] in built['inputs'],
                'Retained object does not bind exact QBE/runtime')
        require(case['source'] == emitted['source'], 'Benchmark/emission source mismatch')
        observations = [r for r in screen['rows'] if r['name'] == name and r['round'] == 0]
        selected = next(r for r in observations if r['role'] == 'candidate')
        independent = next(r for r in observations if r['role'] == 'upstream')
        require(selected['binary'] == built['binary'], 'Retained execution/build mismatch')
        command = selected['command']
        require(command[0] == built['binary']['file'] and command[1:6] == ['--threads', '1', '--gpu', 'off', '--'],
                'Expected original single-thread native command')
        require(len(command) == 10 and all(value.isdecimal() for value in command[6:]), 'Unexpected benchmark argv')
        require(command[8:] == list(map(str, case['runtimeArgs'])), 'Runtime arguments changed')
        require(command[1:] == independent['command'][1:], 'Independent oracle ran different workload')
        require(int(command[6]) > 0, 'Zero-work transfer fixture')
        R.verify(case['expectedStdoutEvidence'])
        require(Path(case['expectedStdoutEvidence']['file']).read_text() == case['expectedStdout'], 'Frozen checksum evidence mismatch')
        prefix = case['expectedStdout'] + command[7] + '\n' + command[6] + '\n'
        expected = dict(exitCode=0, stdout=dict(kind='prefix-integer-line', prefix=prefix),
                        stderr=dict(kind='exact', **selected['stderr']))
        for row in observations:
            require(row['correct'] and row['status'] == 0, 'Failed retained semantic observation')
            R.verify(row['stdout']); R.verify(row['stderr'])
            require(row['command'][1:] == command[1:] and R.output_matches(row['stdout']['file'], expected['stdout']),
                    'Retained output does not satisfy independent prefix/time contract')
            require(row['stderr']['bytes'] == 0, 'Expected exact empty stderr')
        pins = unique([case['source'], case['expectedStdoutEvidence'], emitted['qbe'], build['report'],
            built['binary'], built['object'], *[p for row in observations for p in [row['stdout'], row['stderr']]]])
        inputs.extend(pins)
        prepared.append(dict(name=name, command=command, expected=expected, source=case['source'],
            qbe=emitted['qbe'], binary=built['binary'], programObject=built['object'], buildReceipt=build['report'],
            oracleEvidence=case['expectedStdoutEvidence'], independentOracle=dict(binary=independent['binary'],
                stdout=independent['stdout'], command=independent['command']), inputs=pins))
    inputs = unique(inputs)
    out.mkdir(parents=True)
    (out / 'method.py').write_bytes(Path(__file__).read_bytes())
    baseline = dict(schema='bend-native-profile-workloads-v1', cwd=str(ROOT), inputs=inputs,
        sampler=sampler['sampler'], samplerSource=sampler_sources[0], workloads=[],
        scope='Ordinary Bend numerical and allocation/control transfer. Frozen Phase126 batch sizes and independent checksum outputs; only the final elapsed integer varies. Clean process time and diagnostic sampling remain separate; no compiler request or performance promotion.')
    if tables:
        baseline['unwindTable'] = tables[0]
    records, build_commands = [], []
    for item in prepared:
        name = item['name']
        directory = out / name; directory.mkdir()
        owner_path = directory / 'owners.json'
        R.save(owner_path, O.parse_qbe_owners(item['qbe']['file']))
        runtime_dir = Path(runtime['source']['file']).parent
        runtime_input = dict(runtime=runtime['source'], headers=[R.pin(runtime_dir / n) for n in ['runtime.h', 'primitives.h']],
            programObject=item['programObject'], compileFlags=['-O2', '-std=gnu11', '-ffp-contract=off'])
        input_path = directory / 'runtime-input.json'; R.save(input_path, runtime_input)
        # runtime.py only materializes sources and argv; it performs no builds/runs.
        result = subprocess.run([sys.executable, '-B', str(PROFILER / 'runtime.py'), '--manifest', str(input_path),
            '--out', str(directory / 'runtime')], check=True, capture_output=True, text=True)
        runtime_plan = directory / 'runtime/plan.json'
        plan = read(runtime_plan)
        require(plan['complete'] and plan['reverseExact'] and not plan['compiled'] and not plan['executed'], 'Unexpected runtime plan')
        require(plan['jobs'][1]['command'][2] == item['programObject']['file'], 'Relink uses a different program object')
        baseline['workloads'].append(dict(name=name, timeoutSeconds=30, variants=[dict(name='phase126',
            binary=item['binary'], command=item['command'], inputs=item['inputs'], expected=item['expected'])]))
        build_report = directory / 'build/report.json'
        build_command = [sys.executable, '-B', str(ROOT / 'selfhost/tools/performance/phase111/guard.py'),
            '--out', str(directory / 'build-guard'), '--seconds', '150', '--rss-mib', '2048',
            '--available-mib', '16384', '--file-mib', '64', '--cpu', '3', '--', sys.executable, '-B',
            str(PROFILER / 'build-runtime.py'), '--plan', str(runtime_plan), '--out', str(build_report.parent)]
        records.append(dict(**item, ownerMap=R.pin(owner_path), runtimeInput=R.pin(input_path), runtimePlan=R.pin(runtime_plan),
            diagnosticBinary=str(directory / 'runtime/program'), runtimeBuildReport=str(build_report), guardedBuildCommand=build_command))
        build_commands.append(build_command)
    baseline_path = out / 'baseline-manifest.json'; R.save(baseline_path, baseline)
    report = dict(schema='phase127-program-profiler-transfer-plan-v1', complete=True, targetsExecuted=False,
        inputs=unique(inputs), baselineManifest=R.pin(baseline_path), programs=records,
        guardedBuildCommands=build_commands,
        sealCommand=[sys.executable, '-B', str(Path(__file__).resolve()), 'seal', '--plan', str(out / 'plan.json'),
                     '--out', str(out / 'diagnostic-manifest.json')],
        scope='Preparation only: frozen binaries/argv/oracles and diagnostic runtime relink plans. No target execution, program recompilation, default changes or inferred performance result.')
    R.save(out / 'plan.json', report)
    print(json.dumps(dict(complete=True, targetsExecuted=False, plan=str(out / 'plan.json'),
                         baselineManifest=str(baseline_path), programs=NAMES)))


def seal(args):
    out = fresh(args.out)
    plan = read(args.plan)
    require(plan['complete'] and plan['schema'] == 'phase127-program-profiler-transfer-plan-v1', 'Complete transfer plan required')
    unique(R.all_pins(plan))
    manifest = copy.deepcopy(read(plan['baselineManifest']['file']))
    manifest['inputs'].extend([R.pin(args.plan), R.pin(__file__)])
    for item, workload in zip(plan['programs'], manifest['workloads']):
        require(item['name'] == workload['name'], 'Program ordering changed')
        built = read(item['runtimeBuildReport'])
        require(built['complete'] and built['plan'] == item['runtimePlan'], 'Incomplete or mismatched diagnostic build')
        products = [p for p in built['products'] if p['file'] == item['diagnosticBinary']]
        require(len(products) == 1, 'Expected exactly one diagnostic binary')
        binary = products[0]; R.verify(binary)
        original = workload['variants'][0]
        original['ownerMap'] = item['ownerMap']
        variant = copy.deepcopy(original)
        variant.update(name='phase126-diagnostic', binary=binary,
            command=[binary['file'], *original['command'][1:]], dispatchInstrumentation=True,
            runtimeBuild=R.pin(item['runtimeBuildReport']))
        variant['inputs'].extend([item['runtimePlan'], item['runtimeInput'], R.pin(item['runtimeBuildReport']), binary])
        workload['variants'].append(variant)
    manifest['scope'] += ' Paired diagnostic relinks reuse exact program.o. Instrumented rows are diagnostics, never replacement baseline timings; dispatch IDs are outer active segments, not logical stack ancestry.'
    unique(R.all_pins(manifest))
    R.save(out, manifest)
    print(json.dumps(dict(complete=True, targetsExecuted=False, manifest=R.pin(out))))


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    sub = parser.add_subparsers(dest='command', required=True)
    prep = sub.add_parser('prepare'); prep.add_argument('--out', type=Path, required=True)
    prep.add_argument('--sampler-report', type=Path, default=ROOT / 'selfhost/build/phase127/sampler-cfi03/report.json')
    sealed = sub.add_parser('seal'); sealed.add_argument('--plan', type=Path, required=True)
    sealed.add_argument('--out', type=Path, required=True)
    args = parser.parse_args()
    (prepare if args.command == 'prepare' else seal)(args)


if __name__ == '__main__':
    main()
