#!/usr/bin/env python3
"""Exact-source upstream C diagnostic; IO orchestration only, root guard required."""
import argparse
import importlib.util
import json
import os
from pathlib import Path
import re
import sys
import time

sys.dont_write_bytecode = True
ROOT = Path(__file__).resolve().parents[2]
sys.path.insert(0, str(ROOT / 'selfhost/tools/build'))
import assets
from common import pin, verify, require, run, fresh_output, write_json

p = argparse.ArgumentParser(description=__doc__)
p.add_argument('--spec', type=Path, default=ROOT/'experiments/phase175/parser-c-ceiling-upstream.json')
p.add_argument('--baseline', type=Path, default=ROOT/'selfhost/build/phase175/frontend-full-baseline01/report.json')
p.add_argument('--baseline-build', type=Path, default=ROOT/'selfhost/build/phase175/baseline-native01/report.json')
p.add_argument('--seconds', type=float, default=175)
p.add_argument('--emit-only', action='store_true')
p.add_argument('--out', type=Path, required=True)
a = p.parse_args()
require(0 < a.seconds <= 180, 'Diagnostic total deadline must be <=180s')
spec = json.loads(a.spec.read_text())
baseline = json.loads(a.baseline.read_text())
built = json.loads(a.baseline_build.read_text())
require(spec['kind'] == 'bend-benchmark-reference-request-v1' and spec['target'] == 'c', 'Pinned upstream C spec required')
require(baseline['complete'] and baseline['mode'] == 'request' and len(baseline['runs']) == 1, 'One exact request baseline required')
old = baseline['runs'][0]
require(old['outputExact'] and built['complete'] and not built['changedInputs'], 'Qualified diagnostic baseline required')
require(built['request']['source'] == spec['source'], 'C and QBE image source bytes differ')
require(old['command'][0] == built['binary']['file'], 'Baseline image command differs')
require(old['command'][1:8] == ['--threads','1','--gpu','off','--','phase175-frontend','request'], 'Unknown frontend argument contract')
document = assets.load_assets(ROOT/'selfhost/manifests/assets-native.json', ROOT)
policy = document['toolchains']['c']
require(policy['flags'] == ['-std=c11','-O3'] and policy['libraries'] == ['-lpthread','-lm'], 'Pinned C policy changed')
cc = assets.asset(document, policy['compiler'])
require(spec['engine'] == assets.asset(document, 'bun') and spec['bend'] == assets.asset(document,'upstream-bend') and spec['comp'] == assets.asset(document,'upstream-comp'), 'Reference source/tool pins differ')
profiler_path = ROOT/'selfhost/tools/profiler/run.py'
module = importlib.util.spec_from_file_location('p175_ceiling_profiler',profiler_path)
profiler = importlib.util.module_from_spec(module)
module.loader.exec_module(profiler)
inputs = [pin(__file__), pin(a.spec), pin(a.baseline), pin(a.baseline_build),
          pin(ROOT/'selfhost/tools/build/common.py'), pin(ROOT/'selfhost/tools/build/assets.py'),
          pin(profiler_path), pin(sys.executable), document['_manifest'], cc,
          pin(Path(policy['includeFlags'][1])/'stdbool.h'), old['stdout'],
          *spec['inputs'], *baseline['inputs']]
for item in inputs: verify(item)
out = fresh_output(a.out, ROOT)
env = {k:v for k,v in os.environ.items() if not k.startswith('BEND_') and k not in ['LD_PRELOAD','LD_AUDIT','NODE_OPTIONS','NODE_PATH']}
report = dict(kind='phase175-exact-source-upstream-c-diagnostic',complete=False,inputs=inputs,
              source=spec['source'],toolchain=policy,compiler=cc,jobs=[],
              scope='Same checked Bend frontend source; independent pinned upstream C code generation/runtime versus QBE. One diagnostic observation, not parity, production qualification, or isolation of Clang from representation/runtime.',
              runtime='Unmodified runtime embedded by pinned upstream comp.ts and its exact effect sources.',
              argvPolicy='Upstream retains argv0=phase175-frontend; QBE passes positional sentinel. Both Bend lists contain the same six strings.')
start = time.monotonic()
def save():
    report['seconds'] = time.monotonic()-start
    write_json(out/'report.json',report)
def remaining(cap):
    left = a.seconds-(time.monotonic()-start)
    require(left > 0,'Total diagnostic deadline exhausted')
    return min(cap,left)
save()
try:
    command = [spec['engine']['file'],str(ROOT/'selfhost/tools/bench/upstream.mjs'),str(a.spec.resolve()),str(out/'emission.json')]
    emission = run(command,cwd=ROOT,stdout=out/'program.c',stderr=out/'emission.stderr',seconds=remaining(45),env=env)
    report['jobs'].append(dict(name='emission',**emission)); save()
    require(emission['complete'] and emission['stderr']['bytes']==0,'Upstream C emission failed')
    receipt = json.loads((out/'emission.json').read_text())
    require(receipt['complete'] and receipt['checked'],'Independent source checking/emission failed')
    report['emissionReceipt'] = pin(out/'emission.json')
    report['c'] = pin(out/'program.c')
    require(all(report['c'][k] == receipt['product'][k] for k in ['bytes','sha256']),'Emitted C differs from receipt')
    signature = ''; segments = 0
    with (out/'program.c').open() as stream:
        for line in stream:
            if line.startswith('#define WL_SIG '): signature=line.strip()
            if line.startswith('WL_CASE('): segments+=1
    report['abiCensus'] = dict(wlSignature=signature,termFormalNames=len(re.findall(r'\bTerm\s+w\d+',signature)),wlCaseLines=segments,scope='Textual acquisition diagnostic, not dynamic hotness or machine instruction counts.')
    save()
    if not a.emit_only:
        command = [cc['file'],*policy['flags'],*policy['includeFlags'],str(out/'program.c'),'-o',str(out/'program'),*policy['libraries']]
        machine = run(command,cwd=ROOT,stdout=out/'build.stdout',stderr=out/'build.stderr',seconds=remaining(80),env=env)
        report['jobs'].append(dict(name='clang',**machine)); save()
        require(machine['complete'],'Clang construction failed')
        report['binary'] = pin(out/'program')
        # argv0 supplies the sentinel in upstream. All other Bend arguments and
        # serial runtime flags remain byte-identical to the existing QBE run.
        command = [report['binary']['file'],*old['command'][1:6],*old['command'][7:]]
        result = profiler.execute(command,out/'execute',ROOT,remaining(100),env,argv0='phase175-frontend')
        report['execution'] = result; save()
        match = re.fullmatch(rb'phase175 base_ms=(\d+) frontend_ms=(\d+) observation_ms=(\d+)\n',Path(result['stderr']['file']).read_bytes())
        require(result['returncode']==0 and not result['timedOut'] and match is not None,'Frontend execution/telemetry failed')
        require(Path(result['stdout']['file']).read_bytes()==Path(old['stdout']['file']).read_bytes(),'Complete diagnostic output differs')
        report['observation'] = dict(exactStdout=True,baseSeconds=int(match[1])/1000,frontendSeconds=int(match[2])/1000,observationSeconds=int(match[3])/1000,
            baselineFrontendSeconds=old['frontendSeconds'],frontendRatio=(int(match[2])/1000)/old['frontendSeconds'],baselineWholeSeconds=old['seconds'],wholeProcessRatio=result['wallSeconds']/old['seconds'])
    for item in inputs: verify(item)
    report['complete']=True
except Exception as error:
    report['error']=repr(error)
finally:
    save()
    print(json.dumps({k:report[k] for k in ['complete','seconds','abiCensus','observation','error'] if k in report}))
if not report['complete']: raise SystemExit(1)
