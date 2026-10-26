#!/usr/bin/env python3
"""Prepare, then root-guarded relink of the exact integrated N1 object.

No source emission occurs here. The fixed-source request is a separate command.
"""
import argparse
import hashlib
import json
import os
from pathlib import Path
import subprocess
import time

ROOT = Path(__file__).resolve().parents[5]
RAW = ROOT / 'selfhost/build/phase144'
SELF = Path(__file__).resolve()


def require(ok, message):
    if not ok:
        raise ValueError(message)


def pin(path):
    path = Path(path).resolve()
    h = hashlib.sha256()
    with path.open('rb') as f:
        for block in iter(lambda: f.read(1048576), b''):
            h.update(block)
    return dict(file=str(path), bytes=path.stat().st_size, sha256=h.hexdigest())


def verify(item):
    actual = pin(item['file'])
    require(all(actual[k] == item[k] for k in ('bytes', 'sha256')), 'Changed input: ' + item['file'])
    return Path(actual['file'])


def same(a, b):
    return all(a[k] == b[k] for k in ('bytes', 'sha256')) and Path(a['file']).resolve() == Path(b['file']).resolve()


def read(path):
    return json.loads(Path(path).read_text())


def save(path, data):
    Path(path).write_text(json.dumps(data, indent=2) + '\n')


def prepare(out):
    require(not out.exists() and out.is_relative_to(RAW), 'Fresh Phase144 plan directory required')
    inputs = {}
    def keep(value):
        path = verify(value) if isinstance(value, dict) else Path(value)
        p = pin(path); inputs[p['file']] = p
        return p
    build_pin = keep(ROOT / 'selfhost/build/phase134/p144-integrated-n1-01/report.json')
    build = read(build_pin['file'])
    require(build['complete'] and build['compilerExitCode'] == build['qbeExitCode'] == 0 and
            all(j['exitCode'] == 0 for j in build['jobs']), 'Integrated build incomplete')
    for i in build['inputs']: keep(i)
    source, obj, original = [keep(build[k]) for k in ('source', 'object', 'binary')]
    keep(build['retainedIR']); keep(build['assembly'])
    require(obj['sha256'] == 'f08bda546c00a7671634d66eb19ac4778b132701fe49589c66da3030218f3269', 'Unexpected integrated object')
    source_manifest = keep(RAW / 'integrated-source01/manifest.json')
    sm = read(source_manifest['file'])
    require(sm['complete'] and same(sm['source'], source), 'Source composition differs')
    check_pin = keep(ROOT / 'selfhost/build/phase111/p144-integrated-api01/report.json')
    check = read(check_pin['file'])
    require(check['complete'] and check['checked'] and check['status'] == 0 and
            any(same(source, i) for i in check['inputs']), 'Independent source check missing')
    for i in check['inputs']: keep(i)
    runtime_build = keep(RAW / 'serial-rfc01/build.json'); rb = read(runtime_build['file'])
    require(rb['complete'] and len(rb['jobs']) == 4 and all(j['exitCode'] == 0 for j in rb['jobs']), 'Runtime build incomplete')
    for i in rb['inputs']: keep(i)
    runtime = keep(rb['variants']['serial-rfc']['object'])
    require(runtime['sha256'] == '2d07832382a11d7e993124ecc70452e4e1a3b7f753cf429343e1183cd8e493a3', 'Unexpected runtime')
    semantic_pin = keep(RAW / 'relink-full01/report.json'); sem = read(semantic_pin['file'])
    require(sem['complete'] and sem['passed'] and sem['group'] == 'full' and len(sem['cases']) == 61 and len(sem['refusals']) == 3, 'Runtime semantic prerequisite incomplete')
    semantic_plan = keep(sem['plan']); sp = read(semantic_plan['file'])
    require(same(sp['runtimes']['serial'], runtime), 'Semantic runtime identity differs')
    controls_pin = keep(RAW / 'serial-word-controls01/report.json'); controls = read(controls_pin['file'])
    require(controls['complete'] and len(controls['jobs']) == 9 and
            all(j['expectedExact'] for j in controls['jobs']), 'Runtime word controls incomplete')
    for i in controls['inputs']: keep(i)
    runtime_source = next(i for i in rb['inputs'] if i['file'].endswith('/serial-rfc01/runtime.c'))
    require(any(same(runtime_source, i) for i in controls['inputs']), 'Word-control runtime source differs')
    cc = keep('/usr/bin/x86_64-linux-gnu-gcc-10')
    require(any(same(cc, i) for i in rb['inputs']) and any(same(cc, i) for i in build['inputs']), 'Linker driver differs')
    keep(Path('/usr/bin/ld').resolve())
    original_links = [j['command'] for j in build['jobs'] if j['label'] == 'link']
    require(len(original_links) == 1 and Path(original_links[0][0]).resolve() == Path(cc['file']) and
            original_links[0][1:] == ['-no-pie', obj['file'], build['runtime']['file'], '-pthread', '-lm', '-o', original['file']], 'Original link recipe differs')
    baseline_pin = keep(ROOT / 'selfhost/build/phase130/p144-integrated-fixed-cold01/report.json')
    baseline = read(baseline_pin['file'])
    require(baseline['complete'] and baseline['byteExact'] and baseline['exitCode'] == 0 and
            not baseline['changedInputs'] and same(baseline['image'], original), 'Fixed-source baseline incomplete')
    fixed_source = keep(baseline['source']); oracle = keep(baseline['expectedQbe'])
    require(all(baseline['product'][k] == oracle[k] for k in ('bytes', 'sha256')) and
            fixed_source['sha256'] == '15f5cada2710119cce19a0cfe961c21f61edc5f0b048f90359090a0c1817dac1', 'Fixed source/oracle differs')
    # The product has a different path; compare its pinned bytes independently.
    keep(baseline['product'])
    request_method = keep(ROOT / 'selfhost/tools/performance/phase130/native-request.py')
    carrier = keep(ROOT / 'selfhost/build/phase130/base-carrier01/receipt.json')
    require(any(same(carrier, i) for i in baseline['inputs']) and any(same(request_method, i) for i in baseline['inputs']), 'Request method/carrier differs')
    for i in baseline['inputs']: keep(i)
    keep(SELF)
    target = RAW / 'integrated-serial-n1-01'
    require(not target.exists(), 'Integrated serial target already exists')
    request_out = ROOT / 'selfhost/build/phase130/p144-integrated-serial-fixed-cold01'
    require(not request_out.exists(), 'Fixed-source request output exists')
    out.mkdir()
    plan = dict(kind='phase144-integrated-serial-relink-plan-v01', complete=True, preparedOnly=True,
        inputs=list(inputs.values()), method=pin(SELF), acquisitionBuild=build_pin,
        source=source, sourceManifest=source_manifest, independentSourceCheck=check_pin,
        object=obj, originalBinary=original, originalRuntime=build['runtime'], runtime=runtime,
        runtimeBuild=runtime_build, runtimeSemantics=semantic_pin, runtimeWordControls=controls_pin,
        cc=cc, output=str(target), fixedSourceBaseline=baseline_pin, fixedSource=fixed_source,
        expectedQbe=oracle,
        linkCommand=[cc['file'], '-no-pie', obj['file'], runtime['file'], '-pthread', '-lm', '-o', str(target/'program')],
        requestCommand=['python3', request_method['file'], '--image', str(target/'program'),
            '--source', fixed_source['file'], '--carrier-receipt', carrier['file'], '--out', str(request_out),
            '--expected-qbe', oracle['file'], '--seconds', '600'],
        requestGuard=dict(cpu=3, seconds=650, memoryMiB=4096, minimumAvailableMiB=16384, fileBytes=268435456),
        scope='Exact integrated N1 object, serial runtime relink only; experimental composition, not native self-reproduction qualification or installed selection.')
    save(out/'plan.json', plan)
    print(json.dumps(dict(plan=str(out/'plan.json'), output=str(target), requestCommand=plan['requestCommand'])))


def run(path):
    plan_pin = pin(path); plan = read(path)
    require(plan['complete'] and same(plan['method'], pin(SELF)) and os.sched_getaffinity(0) == {3}, 'Pinned plan and root-owned CPU3 guard required')
    for i in plan['inputs']: verify(i)
    out = Path(plan['output']); require(not out.exists() and out.is_relative_to(RAW), 'Fresh Phase144 output required')
    out.mkdir(); started = time.monotonic()
    report = dict(kind='phase144-integrated-serial-relink-v01', complete=False, experimental=True,
        plan=plan_pin, inputs=plan['inputs'], source=plan['source'], object=plan['object'], runtime=plan['runtime'],
        acquisitionBuild=plan['acquisitionBuild'], originalBinary=plan['originalBinary'],
        runtimeSemantics=plan['runtimeSemantics'], sameCompilerObject=True, emitted=False, nativeQualified=False,
        selected=False, jobs=[], scope=plan['scope'])
    try:
        before = time.monotonic()
        with (out/'link.stdout').open('xb') as so, (out/'link.stderr').open('xb') as se:
            child = subprocess.run(plan['linkCommand'], cwd=ROOT, stdin=subprocess.DEVNULL, stdout=so, stderr=se,
                                   env={'PATH':'/usr/bin:/bin','LANG':'C','LC_ALL':'C','TZ':'UTC'}, timeout=30, check=False)
        report['jobs'].append(dict(label='link', command=plan['linkCommand'], exitCode=child.returncode,
            seconds=time.monotonic()-before, stdout=pin(out/'link.stdout'), stderr=pin(out/'link.stderr')))
        require(child.returncode == 0 and not (out/'link.stdout').stat().st_size and not (out/'link.stderr').stat().st_size, 'Link failed or unexpected diagnostics')
        for i in plan['inputs']: verify(i)
        require(same(plan_pin, pin(path)), 'Plan changed')
        report['binary'] = pin(out/'program'); report['complete'] = True
    except Exception as error:
        report['error'] = str(error); raise
    finally:
        report['seconds'] = time.monotonic()-started; save(out/'report.json', report)
    print(json.dumps(dict(report=str(out/'report.json'), binary=report['binary'])))


if __name__ == '__main__':
    ap = argparse.ArgumentParser(description=__doc__); sub = ap.add_subparsers(dest='mode', required=True)
    p = sub.add_parser('prepare'); p.add_argument('--out', type=Path, required=True)
    p = sub.add_parser('run'); p.add_argument('--plan', type=Path, required=True)
    args = ap.parse_args()
    if args.mode == 'prepare': prepare(args.out.resolve())
    else: run(args.plan.resolve())
