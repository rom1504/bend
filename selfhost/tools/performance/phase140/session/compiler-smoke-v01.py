"""Execute a rebuilt compiler on frozen independent program requests."""
import argparse, hashlib, json, subprocess, sys, time
from pathlib import Path
ROOT=Path(__file__).resolve().parents[5]
def pin(path):
 p=Path(path).resolve();b=p.read_bytes();return dict(file=str(p),bytes=len(b),sha256=hashlib.sha256(b).hexdigest())
def main():
 ap=argparse.ArgumentParser(description=__doc__);ap.add_argument('--image',type=Path,required=True);ap.add_argument('--out',type=Path,required=True);a=ap.parse_args();out=a.out.resolve()
 assert not out.exists() and out.is_relative_to(ROOT/'selfhost/build/phase140')
 ref=ROOT/'selfhost/build/phase134/reference03.json';refs=json.loads(ref.read_text());assert refs['complete'];out.mkdir();(out/'method.py').write_bytes(Path(__file__).read_bytes())
 r=dict(complete=False,inputs=[pin(__file__),pin(ref),pin(a.image)],rows=[],scope='Focused rebuilt-compiler requests; exact QBE against independent frozen references, not full native qualification.')
 start=time.monotonic()
 try:
  for name in ['lexer','coverage-map-churn-128','coverage-closures-256']:
   c=next(x for x in refs['cases'] if x['name']==name)
   for p in [c['source'],c['expectedQbe']]:assert pin(p['file'])==p;r['inputs'].append(p)
   child=ROOT/'selfhost/build/phase130'/('p140-'+out.name+'-'+name)
   guard=ROOT/'selfhost/build/phase111'/('p140-'+out.name+'-'+name+'-guard')
   cmd=[sys.executable,'-B',str(ROOT/'selfhost/tools/performance/phase111/guard.py'),'--out',str(guard),'--seconds','35','--rss-mib','1024','--available-mib','16384','--file-mib','128','--cpu','3','--',sys.executable,'-B',str(ROOT/'selfhost/tools/performance/phase130/native-request.py'),'--image',str(a.image.resolve()),'--source',c['source']['file'],'--carrier-receipt',str(ROOT/'selfhost/build/phase130/base-carrier01/receipt.json'),'--out',str(child),'--seconds','30','--expected-qbe',c['expectedQbe']['file']]
   subprocess.run(cmd,cwd=ROOT,check=True,stdout=subprocess.DEVNULL);result=json.loads((child/'report.json').read_text());assert result['complete'] and result['byteExact'];r['rows'].append(dict(name=name,request=pin(child/'report.json'),guard=pin(guard/'process.json'),seconds=result['nativeSeconds'],product=result['product']))
  for p in r['inputs']:assert pin(p['file'])==p
  r['complete']=True
 except BaseException as e:r['error']=repr(e)
 r['seconds']=time.monotonic()-start;(out/'report.json').write_text(json.dumps(r,indent=2)+'\n');print(json.dumps({k:r.get(k) for k in ['complete','seconds','error']}));return 0 if r['complete'] else 1
if __name__=='__main__':sys.exit(main())
