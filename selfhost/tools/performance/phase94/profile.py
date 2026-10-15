#!/usr/bin/env python3
"""Profile an authenticated native compiler without rebuilding it."""
import argparse, importlib.util, json, os, pathlib, subprocess, sys, time
sys.dont_write_bytecode = True
ROOT = pathlib.Path(__file__).resolve().parents[4]
sys.path.insert(0, str(ROOT/'selfhost/tools/performance/phase92/comparison'))
from support import authenticate, native_args, unchanged, pin
spec = importlib.util.spec_from_file_location('program_support', ROOT/'selfhost/tools/performance/programs/support.py')
S = importlib.util.module_from_spec(spec); spec.loader.exec_module(S)
p = argparse.ArgumentParser(); p.add_argument('--case', choices=['map_closed','lexer_original','self'], required=True)
p.add_argument('--role', choices=['b1','b2'], default='b1'); p.add_argument('--out', type=pathlib.Path, required=True)
a = p.parse_args(); out = a.out.resolve(); assert not out.exists(); out.mkdir(parents=True)
ctx = authenticate(ROOT/'selfhost/build/phase92/upstream-b1/build.json')
screen = json.loads((ROOT/'selfhost/build/phase90/final-screen01/report.json').read_text())
if a.case == 'self':
    source, oracle, calls = ctx['source'], ctx['roles']['b2']['admission']['c'], 1
else:
    row = screen['oracles'][a.case]; source, oracle, calls = row['input'], row['b2Oracle'], 5
for item in [source, oracle]: assert pin(item['file']) == item
sampler = ROOT/'selfhost/build/phase87/sample.so'; samples = out/'samples.txt'
args = native_args(ctx, a.role, source['file'], out/'program', calls)
command = ['taskset','-c','3','env', 'LD_PRELOAD='+str(sampler),
           'BEND_SAMPLE_OUT='+str(samples),'BEND_SAMPLE_PERIOD_US=4000',*args]
report = dict(complete=False, case=a.case, role=a.role, context=ctx, source=source, oracle=oracle,
              method=pin(__file__), sampler=pin(sampler), command=command)
S.save(out/'report.json', report)
with S.ExecutionGuard(rss_mib=2048, available_mib=4096) as guard:
    report['process'] = guard.run(['bash','-c','ulimit -f 65536; ulimit -c 0; exec "$@"','phase94',*command],out/'guard',time.monotonic()+240)
report['outputs'] = []
for i in range(1,calls+1):
    f = out/f'program.{i}.c'
    if f.exists(): report['outputs'].append(dict(output=pin(f),exact=f.read_bytes()==pathlib.Path(oracle['file']).read_bytes()))
unchanged(ctx)
report['complete'] = bool(report['process']['complete'] and len(report['outputs'])==calls and all(r['exact'] for r in report['outputs']))
if samples.exists(): report['samples'] = pin(samples)
S.save(out/'report.json', report)
print(json.dumps(dict(complete=report['complete'],wallSeconds=report['process']['wallSeconds'],outputs=len(report['outputs']))))
sys.exit(0 if report['complete'] else 1)
