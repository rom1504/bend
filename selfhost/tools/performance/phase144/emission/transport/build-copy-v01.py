"""Root-only low-level controls and same-object runtime relink; no compiler build."""
import argparse,hashlib,json,os,subprocess,time
from pathlib import Path
ROOT=Path(__file__).resolve().parents[6]
def pin(p):
 p=Path(p).resolve();b=p.read_bytes();return dict(file=str(p),bytes=len(b),sha256=hashlib.sha256(b).hexdigest())
def verify(p):assert pin(p['file'])==p,p['file']
p=argparse.ArgumentParser(description=__doc__);p.add_argument('--plan',type=Path,required=True);a=p.parse_args();m=json.loads(a.plan.read_text());out=a.plan.resolve().parent
assert os.sched_getaffinity(0)=={3} and m['complete'] and m['kind']=='phase144-small-transfer-source-plan'
assert not (out/'build.json').exists() and out.is_relative_to(ROOT/'selfhost/build/phase144')
inputs=[pin(__file__),pin(a.plan),*m['inputs'],*m['outputs']]
for x in inputs:verify(x)
r=dict(kind='phase144-small-transfer-build',complete=False,plan=pin(a.plan),inputs=inputs,compilerObject=m['compilerObject'],parentRuntime=m['parentRuntime'],jobs=[],variants={},selected=False,nativeQualified=False);save=lambda:(out/'build.json').write_text(json.dumps(r,indent=2)+'\n');save();started=time.monotonic()
try:
 for j in m['commands']:
  for key in ['product']:
   if key in j:assert not Path(j[key]).exists()
  t=time.monotonic();p=subprocess.run(j['argv'],cwd=ROOT,capture_output=True,timeout=45)
  so=out/(j['label']+'.stdout');se=out/(j['label']+'.stderr');so.write_bytes(p.stdout);se.write_bytes(p.stderr)
  row=dict(label=j['label'],command=j['argv'],seconds=time.monotonic()-t,exitCode=p.returncode,stdout=pin(so),stderr=pin(se));r['jobs'].append(row);save()
  assert p.returncode==j['exit'] and p.stdout==j['stdout'].encode() and p.stderr==j['stderr'].encode(),row
  row['exactExpected']=True
  if 'product' in j:row['product']=pin(j['product'])
  save()
 for label,products in m['variants'].items():r['variants'][label]={k:pin(v) for k,v in products.items()}
 old=m['parentRuntime'];zero=r['variants']['baseline']['object'];r['baselineObjectByteIdenticalToParent']=(old['bytes'],old['sha256'])==(zero['bytes'],zero['sha256']);assert r['baselineObjectByteIdenticalToParent'],'Mode0 did not reproduce parent runtime object'
 for x in inputs:verify(x)
 r['complete']=True
except BaseException as e:r['error']=repr(e);raise
finally:r['seconds']=time.monotonic()-started;save()
print(json.dumps(dict(complete=True,seconds=r['seconds'],variants=r['variants'],baselineObjectByteIdenticalToParent=True)))
