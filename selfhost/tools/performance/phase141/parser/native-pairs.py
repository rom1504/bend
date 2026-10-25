"""Serial ABBA native request comparison against immutable complete QBE oracles."""
import argparse
import importlib.util
import json
import os
from pathlib import Path
import statistics
import subprocess
import time

ROOT=Path(__file__).resolve().parents[5]
spec=importlib.util.spec_from_file_location('native',ROOT/'selfhost/tools/performance/phase130/native-request.py')
N=importlib.util.module_from_spec(spec);spec.loader.exec_module(N)
p=argparse.ArgumentParser(description=__doc__)
p.add_argument('--candidate',type=Path,required=True)
p.add_argument('--out',type=Path,required=True)
p.add_argument('--rounds',type=int,default=4)
a=p.parse_args();out=a.out.resolve()
assert not out.exists() and out.is_relative_to(ROOT/'selfhost/build/phase141')
assert sorted(os.sched_getaffinity(0))==[3] and 1<=a.rounds<=8
baseline=ROOT/'selfhost/build/phase111/p140-n1d/program'
refpath=ROOT/'selfhost/build/phase134/reference03.json';refs=json.loads(refpath.read_text());assert refs['complete']
carrier,base,inputs=N.carrier_inputs(ROOT/'selfhost/build/phase130/base-carrier01/receipt.json')
images={'baseline':N.pin(baseline),'candidate':N.pin(a.candidate)}
inputs += [N.pin(__file__),N.pin(N.__file__),N.pin(refpath),*images.values()]
for c in refs['cases']:inputs += [c['source'],c['expectedQbe']]
for x in inputs:N.verify(x)
out.mkdir(parents=True);(out/'method.py').write_bytes(Path(__file__).read_bytes())
report=dict(kind='phase141-native-request-ABBA',complete=False,inputs=inputs,rows=[],
 scope='Same sources, authenticated Base, toolchain/runtime and complete output oracles. Four alternating rounds by default; no instrumentation or parallel target work. Child wall time includes process startup and writing QBE.')
def save():(out/'report.json').write_text(json.dumps(report,indent=2)+'\n')
save();started=time.monotonic()
try:
 for rnd in range(a.rounds):
  for c in refs['cases']:
   for role in (['baseline','candidate'] if rnd%2==0 else ['candidate','baseline']):
    prefix=out/f'{rnd}-{c["name"]}-{role}';product=prefix.with_suffix('.ssa');error=prefix.with_suffix('.stderr')
    command=[images[role]['file'],'--threads','1','--gpu','off','--','phase111',c['source']['file'],base['file'],'cache',carrier['carrier']['file'],carrier['stamp']]
    before=time.monotonic()
    with product.open('xb')as so,error.open('xb')as se:child=subprocess.run(command,cwd=ROOT,stdout=so,stderr=se,timeout=30)
    seconds=time.monotonic()-before
    row=dict(round=rnd,name=c['name'],role=role,seconds=seconds,exitCode=child.returncode,command=command,
             product=N.pin(product),stderr=N.pin(error),exact=N.same_bytes(product,Path(c['expectedQbe']['file'])))
    report['rows'].append(row);save()
    assert child.returncode==0 and row['stderr']['bytes']==0 and row['exact'],row
 report['summary']=[]
 for c in refs['cases']:
  medians={role:statistics.median(r['seconds'] for r in report['rows'] if r['name']==c['name'] and r['role']==role)for role in images}
  report['summary'].append(dict(name=c['name'],medians=medians,candidateOverBaseline=medians['candidate']/medians['baseline']))
 for x in inputs:N.verify(x)
 report['complete']=True
except BaseException as e:report['error']=repr(e)
finally:report['seconds']=time.monotonic()-started;save()
print(json.dumps({k:report.get(k) for k in ['complete','seconds','summary','error']}))
raise SystemExit(0 if report['complete'] else 1)
