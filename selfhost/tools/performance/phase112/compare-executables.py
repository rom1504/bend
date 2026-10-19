#!/usr/bin/env python3
"""Alternating whole-process kernel timings, supervised by the root outer guard."""
import argparse,hashlib,json,os,statistics,subprocess,time
from pathlib import Path
ROOT=Path(__file__).resolve().parents[4]
def pin(p):
 p=Path(p).resolve();return dict(file=str(p),bytes=p.stat().st_size,sha256=hashlib.sha256(p.read_bytes()).hexdigest())
p=argparse.ArgumentParser(description=__doc__)
p.add_argument('--plan',type=Path,required=True);p.add_argument('--out',type=Path,required=True);p.add_argument('--rounds',type=int,default=7)
a=p.parse_args();plan=json.loads(a.plan.read_text());out=a.out.resolve()
assert sorted(os.sched_getaffinity(0))==[3] and not out.exists() and out.is_relative_to(ROOT/'selfhost/build/phase112')
assert a.rounds>=3
expected=Path(plan['expected']).read_bytes();out.mkdir(parents=True)
(out/'plan.json').write_bytes(a.plan.read_bytes());(out/'method.py').write_bytes(Path(__file__).read_bytes())
r=dict(kind='phase112-alternating-whole-process-kernel',complete=False,scope='Whole process including startup/readback; kernel only, not representative-suite or compiler-request ratio.',inputs=[pin(a.plan),pin(__file__),pin(plan['expected'])],binaries={k:pin(v) for k,v in plan['binaries'].items()},samples=[])
def save():(out/'report.json').write_text(json.dumps(r,indent=2)+'\n')
save()
try:
 for round in range(a.rounds+1):
  order=list(plan['binaries']);order=order if round%2==0 else list(reversed(order))
  for label in order:
   cmd=[str(Path(plan['binaries'][label]).resolve()),'--threads','1','--gpu','off']
   start=time.perf_counter();child=subprocess.run(cmd,stdout=subprocess.PIPE,stderr=subprocess.PIPE);seconds=time.perf_counter()-start
   assert child.returncode==0 and not child.stderr and child.stdout==expected,(label,child.returncode,child.stderr,child.stdout)
   r['samples'].append(dict(round=round,warmup=round==0,label=label,seconds=seconds,outputExact=True));save()
 r['medians']={label:statistics.median(x['seconds'] for x in r['samples'] if x['label']==label and not x['warmup']) for label in plan['binaries']}
 reference=plan.get('reference','baseline');r['ratios']={k:v/r['medians'][reference] for k,v in r['medians'].items()}
 for row in [*r['inputs'],*r['binaries'].values()]:assert pin(row['file'])==row
 r['complete']=True;save();print(json.dumps(dict(complete=True,medians=r['medians'],ratios=r['ratios'])))
except BaseException as e:r['error']=repr(e);save();raise
