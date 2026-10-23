"""Paired native Base decoding including read, reconstruction and reclamation."""
import argparse
import hashlib
import json
import os
from pathlib import Path
import statistics
import subprocess
import time
ROOT=Path(__file__).resolve().parents[4]
def pin(p):
 p=Path(p).resolve(); b=p.read_bytes();return dict(file=str(p),bytes=len(b),sha256=hashlib.sha256(b).hexdigest())
def verify(p):
 assert pin(p['file'])==p;return Path(p['file'])
def main():
 ap=argparse.ArgumentParser(description=__doc__);ap.add_argument('--out',type=Path,required=True);ap.add_argument('--rounds',type=int,default=9);a=ap.parse_args()
 out=a.out.resolve();assert not out.exists() and out.is_relative_to(ROOT/'selfhost/build/phase130');assert list(os.sched_getaffinity(0))==[3]
 modepath=ROOT/'selfhost/build/phase130/mode-equivalence01/report.json';assert json.loads(modepath.read_text())['complete']
 eqpath=ROOT/'selfhost/build/phase130/base-equivalence01/report.json';eq=json.loads(eqpath.read_text());assert eq['complete'] and len(eq['rows'])==3
 oldpath=ROOT/'selfhost/tools/performance/phase88/base/carrier01/receipt.json';newpath=ROOT/'selfhost/build/phase130/base-carrier01/receipt.json';old=json.loads(oldpath.read_text());new=json.loads(newpath.read_text())
 g=json.loads(verify({k:v for k,v in eq['preparationOutputs']['old'].items() if k!='nodes'}).read_text())
 def fields(ref):return dict(g['nodes'][ref['node']]['fields'])
 node=fields(fields(g['root'])['seed'])['book'];count=0
 while fields(node)['$']['value']=='Con':count+=1;node=fields(node)['tail']
 assert fields(node)['$']['value']=='Nil';expected=str(count)+'\n'
 out.mkdir(parents=True);r=dict(complete=False,inputs=[pin(__file__),pin(modepath),pin(eqpath),pin(oldpath),pin(newpath)],expectedStdout=expected,rounds=a.rounds,runs=[],scope='Extracted exact native decoder process wall time, including file read and reclamation. Full preparation and request equivalence separately established. Not whole compiler timing.')
 save=lambda:(out/'report.json').write_text(json.dumps(r,indent=2)+'\n');save()
 variants={}
 for name,carrier,label in [('decimal',old,'p130-base-proxy02-decimal'),('mode-decimal',old,'p130-mode-proxy01'),('word',new,'p130-mode-proxy01')]:
  build=ROOT/'selfhost/build/phase111'/label/'build/report.json';b=json.loads(build.read_text());assert b['complete'];binary=verify(b['binary']);verify(carrier['carrier'])
  variants[name]=[str(binary),'--threads','1','--gpu','off','--','p130',carrier['carrier']['file'],carrier['stamp']]
  r['inputs'] += [pin(build),b['binary'],carrier['carrier']]
 try:
  for n in range(a.rounds):
   for name in list(variants) if n%2==0 else list(variants)[::-1]:
    command=variants[name];t=time.monotonic();p=subprocess.run(command,cwd=ROOT,capture_output=True,timeout=10);seconds=time.monotonic()-t
    row=dict(name=name,round=n,command=command,seconds=seconds,status=p.returncode,stdout=p.stdout.decode(),stderr=p.stderr.decode());r['runs'].append(row);save()
    assert p.returncode==0 and p.stdout.decode()==expected and not p.stderr
  r['medians']={name:statistics.median(x['seconds'] for x in r['runs'] if x['name']==name) for name in variants}
  r['candidateOverBaseline']=r['medians']['word']/r['medians']['decimal']
  for row in r['inputs']:verify(row)
  r['complete']=True
 except BaseException as error:r['error']=repr(error);raise
 finally:save()
 print(json.dumps({k:r[k] for k in ['complete','medians','candidateOverBaseline']}))
if __name__=='__main__':main()
