#!/usr/bin/env python3
"""Three small exact-output partition/cache falsifiers; root runs under guard."""
import argparse,hashlib,json,pathlib,subprocess,sys,time
ROOT=pathlib.Path(__file__).resolve().parents[5];HERE=pathlib.Path(__file__).resolve().parent
sys.dont_write_bytecode=True

def pin(p):p=pathlib.Path(p).resolve();b=p.read_bytes();return dict(file=str(p),bytes=len(b),sha256=hashlib.sha256(b).hexdigest())
def verify(p):assert pin(p['file'])==p
p=argparse.ArgumentParser();p.add_argument('--bridge',type=pathlib.Path,required=True);p.add_argument('--out',type=pathlib.Path,required=True);a=p.parse_args();out=a.out.resolve();assert not out.exists()and out.is_relative_to(ROOT/'selfhost/build/phase135');br=json.loads(a.bridge.read_text());assert br['complete']and len(br['rows'])==3
oracle_path=ROOT/'selfhost/build/phase134/pipe-test02/report.json';oracle=json.loads(oracle_path.read_text());assert oracle['complete'];api=next(x for x in br['inputs']if x['file'].endswith('/api.mjs'));runtime=ROOT/'selfhost/build/phase128/runtime-borrow01/runtime.o';inputs=[pin(__file__),pin(a.bridge),pin(oracle_path),api,pin(runtime),*[pin(HERE/n)for n in ['objects-v01.py','protocol-v01.py','elf-v01.py','compare-v01.py']],*br['inputs']];out.mkdir(parents=True);r=dict(complete=False,inputs=inputs,rows=[],jobs=[],scope='Host-framed checked Bend small payloads only; machine partition/globalization/cache equivalence and independent ordinary output. No native frame-writer/full compiler edit claim.')
def save():(out/'report.json').write_text(json.dumps(r,indent=2)+'\n')
def run(label,cmd):
 t=time.monotonic()
 with(out/(label+'.stdout')).open('xb')as so,(out/(label+'.stderr')).open('xb')as se:z=subprocess.run(list(map(str,cmd)),cwd=ROOT,stdout=so,stderr=se,timeout=60)
 r['jobs'].append(dict(label=label,command=list(map(str,cmd)),exitCode=z.returncode,seconds=time.monotonic()-t,stdout=pin(out/(label+'.stdout')),stderr=pin(out/(label+'.stderr'))));save();assert z.returncode==0,label
save()
try:
 for c in br['rows']:
  for x in [c['source'],c['expectedQbe'],c['framed']]:verify(x)
  name=c['name'];base=[sys.executable,'-B',HERE/'objects-v01.py','--stream',c['framed']['file'],'--producer',api['file'],'--source',c['source']['file'],'--runtime',runtime,'--expected-qbe',c['expectedQbe']['file'],'--seconds','40'];cache=out/(name+'-cache');reference=out/(name+'-fresh-cache');products={}
  for role in ['acquire','cached','fresh']:
   dest=out/(name+'-'+role);cmd=base+['--out',dest,'--cache',reference if role=='fresh'else cache]
   if role!='cached':cmd+=['--cold']
   run(name+'-'+role,cmd);receipt=json.loads((dest/'report.json').read_text());assert receipt['complete']and receipt['expectedPayloadExact'];products[role]=pin(dest/'report.json')
   if role=='cached':assert receipt['reusedUnits']==c['units']and receipt['builtUnits']==0
  comparison=out/(name+'-compare.json');run(name+'-compare',[sys.executable,'-B',HERE/'compare-v01.py','--cached',products['cached']['file'],'--fresh',products['fresh']['file'],'--out',comparison])
  expected=ROOT/'selfhost/build/phase134/pipe-test02'/(name+'-expected-execute.stdout');old=next(x for x in oracle['cases']if x['name']==name);assert old['irDigest']==c['payload'];job=next(x for x in oracle['jobs']if x['label']==name+'-expected-execute');assert job['status']==0 and job['stdout']==pin(expected);r['inputs'].append(pin(expected));image=json.loads(pathlib.Path(products['cached']['file']).read_text())['binary'];run(name+'-execute',[image['file'],'--threads','1','--gpu','off']);assert(out/(name+'-execute.stdout')).read_bytes()==expected.read_bytes();assert not(out/(name+'-execute.stderr')).stat().st_size
  r['rows'].append(dict(name=name,builds=products,comparison=pin(comparison),independentExpected=pin(expected),executionExact=True));save()
 for x in inputs:verify(x)
 r['complete']=True
finally:save()
print(json.dumps(dict(complete=r['complete'],cases=len(r['rows']))))
