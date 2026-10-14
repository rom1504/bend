#!/usr/bin/env python3
"""Serial tiny native self-hosting falsifiers, before any full compiler build."""
import argparse
import json
import subprocess
import sys
from pathlib import Path

HERE = Path(__file__).resolve().parent
ROOT = HERE.parents[4]
P = ROOT / 'selfhost/tools/performance'
sys.path.insert(0, str(P / 'phase88'))
from broad import guard, pin, save, NODE, CLANG, INCLUDE
from native_support import authenticate, native_args, DEFAULT_CACHE

p = argparse.ArgumentParser(description=__doc__)
p.add_argument('manifest', type=Path)
p.add_argument('out', type=Path)
a = p.parse_args()
m = json.loads(a.manifest.read_text())
out = a.out.resolve()
out.mkdir(parents=True, exist_ok=False)
auth = authenticate(ROOT / 'selfhost/build/phase88/compiler-native02', DEFAULT_CACHE)
report = dict(complete=False, passed=False, method=pin(__file__), manifest=pin(a.manifest),
              native=auth, emissions=[], executions=[])
save(out / 'report.json', report)
for name in ['argv', 'decoder', 'file-io']:
    source = m['sources'][name]
    assert pin(source['file']) == source
    dst = out / f'{name}-b2'
    job = guard(out / f'{name}-b2-guard', [NODE, '--max-old-space-size=1024', '--stack-size=4096',
                HERE / 'emit-b2.mjs', a.manifest.resolve(), name, dst], 90)
    row = dict(case=name, source=source, b2=job)
    report['emissions'].append(row)
    save(out / 'report.json', report)
    assert job['pass_'], 'B2 emission failed'
    row['c'] = pin(dst / 'program.c')
    if name != 'file-io':
        prefix = out / f'{name}-native'
        row['native'] = guard(out / f'{name}-native-guard', native_args(auth, source['file'], prefix), 90)
        candidate = Path(str(prefix) + '.1.c')
        row['exactC'] = candidate.exists() and pin(candidate)['sha256'] == row['c']['sha256']
        save(out / 'report.json', report)
        assert row['native']['pass_'] and row['exactC'], 'Native emission differs'
    program = out / f'{name}-program'
    row['build'] = guard(out / f'{name}-build-guard', [CLANG, '-isystem', INCLUDE, '-O2', dst / 'program.c', '-o', program, '-lm', '-pthread'], 90)
    save(out / 'report.json', report)
    assert row['build']['pass_'], 'Small program build failed'
    row['program'] = pin(program)
    cases = ([dict(id=str(i), args=xs, verify=['argv', '--convention', 'retained', '--case-index', str(i)])
              for i, xs in enumerate(m['argvCases'])] if name == 'argv' else
             [dict(id='decoder', args=[], verify=['decoder'])] if name == 'decoder' else
             [dict(id=c['id'], args=['phase89-file-control', c['mode'], c['input'], c['output']],
                   verify=['file', '--id', c['id']]) for c in m['fileCases']])
    for c in cases:
        directory = out / f'{name}-{c["id"]}-guard'
        job = guard(directory, ['env', 'LC_ALL=C', program, '--threads', '1', '--gpu', 'off', '--', *c['args']], 15)
        check = subprocess.run([sys.executable, '-B', str(HERE / 'verify-run.py'), str(a.manifest.resolve()), str(directory), *c['verify']], capture_output=True, text=True)
        result = dict(case=name, id=c['id'], job=job, verification=dict(returncode=check.returncode, stdout=check.stdout, stderr=check.stderr), passed=check.returncode == 0)
        report['executions'].append(result)
        save(out / 'report.json', report)
        print(json.dumps(dict(case=name, id=c['id'], passed=result['passed'])), flush=True)
        assert result['passed'], 'Observed program result failed verification'
assert authenticate(ROOT / 'selfhost/build/phase88/compiler-native02', DEFAULT_CACHE) == auth
report.update(complete=True, passed=True)
save(out / 'report.json', report)
