"""Prepare/seal a diagnostic runtime relink for the selected Phase128 object.

Only existing generic tools supply instrumentation, build execution and sampling.
The original compiler object and whole-QBE oracles remain exact.
"""
import argparse
import importlib.util
import json
from pathlib import Path
import re
import subprocess

ROOT = Path(__file__).resolve().parents[4]
PROF = ROOT/'selfhost/tools/profiler'
spec = importlib.util.spec_from_file_location('profile_run', PROF/'run.py')
R = importlib.util.module_from_spec(spec)
spec.loader.exec_module(R)
p = argparse.ArgumentParser(description=__doc__)
p.add_argument('action', choices=['prepare','seal'])
p.add_argument('--out', type=Path, required=True)
a = p.parse_args(); out = a.out.resolve()
assert out.is_relative_to(ROOT/'selfhost/build/phase129')
candidate = ROOT/'implementation/phase128/candidate.json'
c = json.loads(candidate.read_text())
build = ROOT/'selfhost/build/phase111/p128-native02-n1/report.json'
b = json.loads(build.read_text())
assert b['complete'] and c['nativeQualified'] and b['binary'] == c['n1']
assert c['qbe'] in b['inputs'] and c['runtime'] in b['inputs']
for item in [b['binary'],b['object'],c['qbe'],c['runtime']]: R.verify(item)
if a.action == 'prepare':
    assert not out.exists(); out.mkdir(parents=True)
    rt = Path(c['runtime']['file']).parent
    headers = re.findall(r'^#include "([^"\n]+)"', (rt/'runtime.c').read_text(), re.M)
    inp = dict(runtime=R.pin(rt/'runtime.c'), headers=[R.pin(rt/x) for x in headers],
        programObject=b['object'], compiler='/usr/bin/gcc', linker='/usr/bin/gcc',
        compileFlags=['-O2','-std=gnu11','-ffp-contract=off'],
        evidence=[R.pin(candidate),R.pin(build),R.pin(__file__)])
    R.save(out/'runtime-input.json',inp)
    subprocess.run(['python3','-B',str(PROF/'runtime.py'),'--manifest',str(out/'runtime-input.json'),
                    '--out',str(out/'runtime')],check=True)
    subprocess.run(['python3','-B',str(PROF/'owners.py'),'--qbe',c['qbe']['file'],
                    '--output',str(out/'owners.json')],check=True)
else:
    report = out/'build/report.json'; r = json.loads(report.read_text())
    assert r['complete']
    original = ROOT/'selfhost/build/phase129/profile01/manifest.json'
    manifest = json.loads(original.read_text())
    diagnostic = next(x for x in r['products'] if Path(x['file']).name == 'program')
    R.verify(diagnostic)
    manifest['inputs'] += [R.pin(original),R.pin(report),R.pin(out/'runtime/plan.json'),R.pin(__file__)]
    manifest['scope'] = 'Context-only/event diagnostic relink of the exact qualified Phase128 N1 object; original output oracles. Not a clean performance variant.'
    for w in manifest['workloads']:
        v=w['variants'][0];v['name']='phase128-context';v['binary']=diagnostic
        v['command'][0]=diagnostic['file'];v['dispatchInstrumentation']=True
    target=out/'manifest.json';assert not target.exists();R.save(target,manifest)
    jobs=json.loads((ROOT/'selfhost/build/phase129/profile01/jobs.json').read_text())
    for j in jobs['jobs']:
        cmd=j['command'];cmd[cmd.index('--manifest')+1]=str(target)
        cmd[cmd.index('--out')+1]=str(out/j['name'])
        cmd[cmd.index('--modes')+1]='clean,sample,events'
        cmd[cmd.index('--rounds')+1]='1'
    R.save(out/'jobs.json',jobs)
print(json.dumps(dict(complete=True,targetsRun=False,action=a.action,out=str(out))))
