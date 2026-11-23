"""Relink Phase205 x86 objects and compare native45 runtimes on one guarded CPU."""
import hashlib
import json
import os
from pathlib import Path
import statistics
import subprocess
import sys

HERE = Path(__file__).resolve().parent
ROOT = HERE.parents[2]
BROAD = ROOT / 'selfhost/build/phase205/final-broad06'
RUNTIME = ROOT / 'selfhost/src/runtime/qbe'
CC = '/usr/bin/x86_64-linux-gnu-gcc-10'
FLAGS = ['-no-pie']
LIBS = ['-pthread', '-lm']
sys.path.insert(0, str(ROOT / 'research/phase198/runtime-broad'))
import prepare


def read(path):
    return json.loads(path.read_text())


def digest(path):
    return hashlib.sha256(path.read_bytes()).hexdigest()


def checked(pin):
    path = Path(pin['file'])
    assert digest(path) == pin['sha256'], path
    return path


def execute(args):
    return subprocess.run(args, check=True, capture_output=True, timeout=60)


def timed(exe, reps, point):
    warmups = point['warmups']
    p = execute([exe, '+RTS', '--threads', '1', '--gpu', 'off', '-RTS', '--RTS',
                 str(reps), str(warmups), *map(str, point['runtimeArgs'])])
    lines = p.stdout.decode().splitlines()
    assert not p.stderr and lines[:-3] == point['expectedStdout'].splitlines(), (exe, p)
    assert lines[-3:-1] == [str(warmups), str(reps)] and int(lines[-1]) >= 0, lines
    return int(lines[-1])


def main(out):
    assert len(os.sched_getaffinity(0)) == 1
    out.mkdir(parents=True)
    src = RUNTIME / 'runtime.c'
    assert digest(src) == '27e2baff91b03252d66062235208cd2a17ab0038b17003ac76fbb7c8a7e30dca'
    generated = out / 'runtime-opt.c'
    execute(['patch', '--fuzz=0', '-s', '-o', generated, src, HERE / 'runtime.patch'])
    core = out / 'runtime-opt.core.o'
    execute([CC, '-O2', '-std=gnu11', '-ffp-contract=off', '-DP144_SINGLE_MUTATOR_RFC=1',
             '-I', RUNTIME, '-c', generated, '-o', core])
    scan = out / 'scan.o'
    execute([CC, '-O3', '-std=c11', '-msse2', '-mno-avx', '-c',
             ROOT / 'research/phase199/scan-runtime/scan.c', '-o', scan])
    candidate = out / 'runtime-opt.o'
    execute(['/usr/bin/x86_64-linux-gnu-ld.bfd', '-m', 'elf_x86_64', '-r', core, scan, '-o', candidate])
    baseline = checked(read(BROAD / 'summary.json')['runtime'])
    assert prepare.exported(baseline) == prepare.exported(candidate)
    toolchain = dict(linkerFlags=FLAGS, libraries=LIBS)
    probes = prepare.probes(out, CC, {'live': candidate}, toolchain)
    (out / 'probes.json').write_text(json.dumps(probes))
    runtime10 = prepare.runtime_controls(out / 'runtime10', CC, {'live': candidate}, toolchain)
    (out / 'runtime10.json').write_text(json.dumps(runtime10))
    programs = {r['id']: r['products'] for r in read(BROAD / 'recipe.json')['cases']}
    data = dict(cpu=list(os.sched_getaffinity(0)), parentRuntime=digest(baseline),
                candidateRuntime=digest(candidate), candidateSource=digest(generated),
                probes=len(probes['live']['rows']), runtime10=len(runtime10['rows']), cases=[])
    for case in read(BROAD / 'timing/report.json')['cases']:
        name, point = case['id'], case['point']
        build = read(BROAD / 'cases' / name / 'candidate/build.json')
        obj = checked(build['object'])
        assert build['runtime']['sha256'] == data['parentRuntime']
        elf = out / name
        execute([CC, *FLAGS, obj, candidate, *LIBS, '-o', elf])
        paths = dict(parent=checked(build['binary']), port=elf, c=checked(programs[name]['c']['artifact']))
        runs = {role: [] for role in paths}
        reps = dict(parent=case['calibration']['candidate'], port=case['calibration']['candidate'],
                    c=case['calibration']['c'])
        for role, path in paths.items():
            timed(path, 1, point)
        if point['ratioEligible']:
            # Each executable occupies each position twice, with both pair orders represented.
            for order in ('parent port c', 'c port parent', 'port c parent',
                          'parent c port', 'c parent port', 'port parent c'):
                for role in order.split():
                    runs[role].append(timed(paths[role], reps[role], point))
        row = dict(id=name, object=digest(obj), elf={k: digest(v) for k,v in paths.items()},
                   reps=reps, fixedReps=point['repetitions'], runsMs=runs)
        data['cases'].append(row)
        (out / 'results.json').write_text(json.dumps(data, indent=2) + '\n')
        print(name, {k: statistics.median(v) for k,v in runs.items() if v}, flush=True)


if __name__ == '__main__':
    main(Path(sys.argv[1]).resolve())
