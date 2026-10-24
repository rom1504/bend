"""Seal checked selector ceiling products for root-owned timing; no target execution."""
import argparse,hashlib,json,math
from pathlib import Path
H=Path(__file__).resolve().parent;R=H.parents[5]
def pin(p):
 p=Path(p).resolve();b=p.read_bytes();return dict(file=str(p),bytes=len(b),sha256=hashlib.sha256(b).hexdigest())
def read(p):return json.loads(Path(p).read_text())
p=argparse.ArgumentParser();p.add_argument('--out',type=Path,required=True);p.add_argument('--pilot-report',type=Path);a=p.parse_args();out=a.out.resolve();assert not out.exists()
counts={1:1024,64:1024};inputs=[pin(__file__),pin(H/'oracle.json'),pin(H/'short-oracle.json'),pin(H/'cases-v03.json'),pin(H/'repair-v03.json')]
if a.pilot_report:
 d=read(a.pilot_report);assert d['complete']and d['passed'];inputs.append(pin(a.pilot_report))
 for size in counts:
  rows=[r for r in d['rows']if r['workload']==f'selector-bucket{size}'and r['mode']=='clean'];assert len(rows)==2 and all(r['correct']for r in rows)
  counts[size]=min(1000000,max(1024,math.ceil(1024*.5/min(r['wallSeconds']for r in rows))))
workloads=[]
for size in [1,64]:
 variants=[]
 for role in ['original','fused']:
  name='selector-'+role+('-short'if size==1 else'');path=R/f'selfhost/build/phase111/p131-selector-ceiling03-{name}-build/report.json';b=read(path);assert b['complete']and b['outputExact']
  for item in b['inputs']+[b['binary']]:assert pin(item['file'])==item
  inputs.extend([pin(path),*b['inputs'],b['binary']]);binary=b['binary'];count=counts[size]
  variants.append(dict(name=role,binary=binary,command=[binary['file'],'--threads','1','--gpu','off','--',str(count)],expected=dict(exitCode=0,stdout=dict(kind='prefix-integer-line',prefix=f'1\n{count}\n'),stderr=dict(kind='exact',bytes=0,sha256=hashlib.sha256(b'').hexdigest()))))
 workloads.append(dict(name=f'selector-bucket{size}',timeoutSeconds=30,variants=variants))
out.mkdir(parents=True);(out/'manifest.json').write_text(json.dumps(dict(schema='bend-native-profile-workloads-v1',cwd=str(R),inputs=inputs,workloads=workloads,repetitions=counts,scope='Same final checked compiler/runtime; source owning lookup+dx vs explicit scalar continuation fusion.1-entry ordinary leaf and64-entry forced-collision stress reported separately. Hash is supplied identically, so no hashing cost or whole-compiler gain claim. Both nativebinaries pass34-line independent ordinary controls before timing. Clean timing owned by coordinatorCPU3.'),indent=2)+'\n');print(json.dumps(dict(complete=True,targetsRun=False,manifest=str(out/'manifest.json'),repetitions=counts)))
