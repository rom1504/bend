#!/usr/bin/env python3
"""Measure relinked native compiler requests against complete frozen QBE bytes."""
import argparse, hashlib, json, statistics, subprocess, sys, time
from pathlib import Path
ROOT = Path(__file__).resolve().parents[3]
sys.dont_write_bytecode = True
sys.path.insert(0, str(ROOT / 'selfhost/tools/build'))
from common import fresh_output, pin, verify, require, write_json, clean_environment

p = argparse.ArgumentParser(description=__doc__)
p.add_argument('--build', type=Path, required=True)
p.add_argument('--case', choices=['verifier','checker','full'], required=True)
p.add_argument('--roles', default='baseline,warm,shared,both')
p.add_argument('--rounds', type=int, default=1)
p.add_argument('--out', type=Path, required=True)
a = p.parse_args()
spec = {
 'verifier': ('selfhost/build/phase167/verifier-source03/compiler.bend',
              'selfhost/build/phase168/baseline03/emit/program.ssa'),
 'checker': ('selfhost/build/phase156/inputs01/checker.bend',
             'selfhost/build/phase156/pilot01/oracle-compiler-checker/program.ssa'),
 'full': ('selfhost/build/phase152/composite01/compiler.bend',
          'selfhost/build/phase152/native-n2/program.ssa'),
}[a.case]
build = json.loads(a.build.read_text()); require(build['complete'], 'Incomplete runtime build')
images = {r['label']: r['binary'] for r in build['variants']}
roles = a.roles.split(','); require(len(set(roles))==len(roles) and all(r in images for r in roles), 'Bad roles')
require(0 < a.rounds <= 4, 'Bounded rounds required')
request_path = ROOT / 'selfhost/build/phase152/native-n2/request.json'
request = json.loads(request_path.read_text())
source, oracle = [pin(ROOT / value) for value in spec]
base, carrier, stamp = [request[k] for k in ['base','carrier','stamp']]
inputs = [pin(__file__), pin(a.build), pin(request_path), source, oracle, base, carrier,
          *[images[r] for r in roles]]
for item in inputs: verify(item)
out = fresh_output(a.out, ROOT)
report = dict(complete=False, inputs=inputs, case=a.case, samples=[], rows=[],
 scope='Native compiler execution with only linked runtime changed; fresh prepared-Base requests, complete exact QBE hash, no machine construction or generated-program timing.')
save = lambda: write_json(out / 'report.json', report)
try:
 for pair in range(a.rounds):
  for role in (roles if pair % 2 == 0 else list(reversed(roles))):
   command = [images[role]['file'], '--threads','1','--gpu','off','--','phase111',
              source['file'],base['file'],'cache',carrier['file'],stamp]
   row = dict(role=role, pair=pair, command=command, complete=False)
   report['samples'].append(row); save()
   start = time.monotonic(); size = 0; digest = hashlib.sha256(); first = None
   error_path = out / f'{pair}-{role}.stderr'
   with error_path.open('xb') as error:
    process = subprocess.Popen(command, cwd=ROOT, env=clean_environment(), stdout=subprocess.PIPE, stderr=error)
    with process.stdout:
     while block := process.stdout.read(65536):
      if first is None: first = time.monotonic()-start
      digest.update(block); size += len(block)
    code = process.wait()
   row.update(seconds=time.monotonic()-start, firstBlockSeconds=first, exitCode=code,
              output=dict(bytes=size,sha256=digest.hexdigest()),stderr=pin(error_path))
   save()
   require(code==0 and row['stderr']['bytes']==0, 'Compiler request failed: '+role)
   require(size==oracle['bytes'] and digest.hexdigest()==oracle['sha256'], 'Complete QBE differs: '+role)
   row['complete']=True;save()
 for role in roles:
  values=[r['seconds'] for r in report['samples'] if r['role']==role]
  report['rows'].append(dict(role=role,seconds=values,median=statistics.median(values)))
 baseline=next((r['median'] for r in report['rows'] if r['role']=='baseline'),None)
 for row in report['rows']: row['ratio']=row['median']/baseline if baseline else None
 for item in inputs: verify(item)
 report['complete']=True
finally:
 save(); print(json.dumps(dict(complete=report['complete'],rows=report['rows'])))
