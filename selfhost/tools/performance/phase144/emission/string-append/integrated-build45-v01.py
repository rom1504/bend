"""Build independently checked ordinary products; unchanged Phase123 builder/oracles."""
import argparse,hashlib,json,os,subprocess,sys,time
from pathlib import Path
ROOT=Path(__file__).resolve().parents[6];HERE=Path(__file__).resolve().parent
BUILDER=ROOT/'selfhost/tools/performance/phase123/build-aligned.py'
def pin(p):
 p=Path(p).resolve();h=hashlib.sha256();n=0
 with p.open('rb') as f:
  for b in iter(lambda:f.read(1048576),b''):h.update(b);n+=len(b)
 return dict(file=str(p),bytes=n,sha256=h.hexdigest())
def verify(p):assert pin(p['file'])==p,p['file']
def read(p):return json.loads(Path(p).read_text())
def save(p,x):
 tmp=p.with_suffix('.tmp');tmp.write_text(json.dumps(x,indent=2)+'\n');tmp.replace(p)
p=argparse.ArgumentParser(description=__doc__);p.add_argument('--manifest',type=Path,required=True);p.add_argument('--out',type=Path,required=True)
a=p.parse_args();out=a.out.resolve();assert not out.exists() and out.is_relative_to(ROOT/'selfhost/build/phase144')
assert sorted(os.sched_getaffinity(0))==[3]
m=read(a.manifest);assert len(m['cases'])==45 and len({c['name'] for c in m['cases']})==45
api=read(m['apiReport']);assert api['complete'] and api['checked'] and api['status']==0 and m['compilerSource'] in api['inputs']
inputs=[pin(__file__),pin(BUILDER),pin(a.manifest),pin(m['apiReport']),api['api'],*api['inputs'],*m['inputs']]
products={}
for f in m['emissionReports']:
 e=read(f);assert e['complete'] and e['runtime']==m['runtime'] and pin(m['apiReport']) in e['inputs'] and api['api'] in e['inputs']
 inputs.extend([pin(f),*e['inputs']])
 for c in e['cases']:
  assert c['name'] not in products and c['verified'];products[c['name']]=c
assert set(products)=={c['name'] for c in m['cases']}
for x in inputs:verify(x)
for c in m['cases']:
 x=products[c['name']];assert x['source']==c['source'] and x['expected']==c['stdoutEvidence']
 for i in [c['source'],c['stdoutEvidence'],x['qbe']]:verify(i)
 assert Path(c['stdoutEvidence']['file']).read_text()==c['expectedStdout']
out.mkdir();r=dict(kind='phase144-integrated-hosted-full45-ordinary',complete=False,compilerSource=m['compilerSource'],apiReport=pin(m['apiReport']),runtime=m['runtime'],inputs=inputs,cases=[],scope='Checked hosted ordinary45 emission and independent native output gates. Changed QBE is allowed; frozen complete semantic stdout is not changed. No native compiler chain, runtime timing or production selection claim.');save(out/'report.json',r);start=time.monotonic()
try:
 for c in m['cases']:
  x=products[c['name']];dest=ROOT/'selfhost/build/phase111'/('p144-integrated02-full45-'+c['name']);assert not dest.exists()
  cmd=[sys.executable,'-B',str(BUILDER),'--source',x['qbe']['file'],'--runtime',m['runtime']['file'],'--out',str(dest),'--expected',c['stdoutEvidence']['file'],'--seconds','30']
  with (out/(c['name']+'.log')).open('xb') as log:
   t=time.monotonic();proc=subprocess.run(cmd,cwd=ROOT,stdout=log,stderr=subprocess.STDOUT,timeout=45);elapsed=time.monotonic()-t
  row=dict(name=c['name'],source=c['source'],qbe=x['qbe'],expected=c['stdoutEvidence'],command=cmd,exitCode=proc.returncode,seconds=elapsed,log=pin(out/(c['name']+'.log')));r['cases'].append(row);save(out/'report.json',r)
  assert proc.returncode==0
  build=read(dest/'report.json');assert build['complete'] and build['outputExact'] and all(j['exitCode']==0 for j in build['jobs'])
  for i in build['inputs']+[build['binary'],build['object']]:verify(i)
  assert x['qbe'] in build['inputs'] and c['stdoutEvidence'] in build['inputs'] and m['runtime'] in build['inputs']
  row.update(build=pin(dest/'report.json'),binary=build['binary'],object=build['object'],outputExact=True);save(out/'report.json',r)
 for x in inputs:verify(x)
 for row in r['cases']:
  for k in ['source','qbe','expected','build','binary','object']:verify(row[k])
 r['complete']=True
except BaseException as error:r['error']=repr(error);raise
finally:r['seconds']=time.monotonic()-start;save(out/'report.json',r)
print(json.dumps(dict(complete=True,cases=len(r['cases']),seconds=r['seconds'])))
