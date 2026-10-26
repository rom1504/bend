"""Root-only interleaved real compiler requests with unchanged complete-QBE oracle."""
import argparse,hashlib,json,os,statistics,subprocess,sys,time
from pathlib import Path
ROOT=Path(__file__).resolve().parents[6]
METHOD=ROOT/'selfhost/tools/performance/phase130/native-request.py'
def pin(p):
 p=Path(p).resolve();b=p.read_bytes();return dict(file=str(p),bytes=len(b),sha256=hashlib.sha256(b).hexdigest())
def verify(p):assert pin(p['file'])==p,p['file']
def read(p):return json.loads(Path(p).read_text())
p=argparse.ArgumentParser(description=__doc__);p.add_argument('--build',type=Path,required=True);p.add_argument('--out',type=Path,required=True);a=p.parse_args();out=a.out.resolve()
assert os.sched_getaffinity(0)=={3} and not out.exists() and out.is_relative_to(ROOT/'selfhost/build/phase144')
assert not any(k in os.environ for k in ['LD_PRELOAD','BEND_SAMPLE_OUT','BEND_PROFILE_COUNTERS'])
b=read(a.build);assert b['complete'] and b['baselineObjectByteIdenticalToParent'] and len(b['jobs'])==16 and all(j['exactExpected'] for j in b['jobs'])
ref=ROOT/'selfhost/build/phase144/predicate-byte-candidate01/report.json';e=read(ref);assert e['complete'];c=next(x for x in e['cases'] if x['name']=='lexer');assert c['verified']
carrier=ROOT/'selfhost/build/phase130/base-carrier01/receipt.json'
inputs=[pin(__file__),pin(METHOD),pin(a.build),*b['inputs'],pin(ref),*e['inputs'],c['source'],c['qbe'],pin(carrier)]
for v in b['variants'].values():inputs.extend(v.values())
for x in inputs:verify(x)
out.mkdir();r=dict(kind='phase144-small-transfer-real-request-screen',complete=False,inputs=inputs,source=c['source'],expected=c['qbe'],rows=[],scope='Three alternating pairs of the same final03 N2 compiler object with mode0/1 serial-runtime objects. Native cold Lexer requests, complete independently emitted QBE oracle. No full-source speed claim, no compiler regeneration or selection.');save=lambda:(out/'report.json').write_text(json.dumps(r,indent=2)+'\n');save();start=time.monotonic()
try:
 for rnd in range(3):
  for label in (['baseline','candidate'] if rnd%2==0 else ['candidate','baseline']):
   dest=ROOT/'selfhost/build/phase130'/('p144-small-transfer-lexer-'+str(rnd)+'-'+label);assert not dest.exists()
   image=b['variants'][label]['binary'];cmd=[sys.executable,'-B',str(METHOD),'--image',image['file'],'--source',c['source']['file'],'--carrier-receipt',str(carrier),'--expected-qbe',c['qbe']['file'],'--out',str(dest),'--seconds','40']
   t=time.monotonic();p=subprocess.run(cmd,cwd=ROOT,capture_output=True,timeout=45);elapsed=time.monotonic()-t;so=out/(str(rnd)+'-'+label+'.stdout');se=out/(str(rnd)+'-'+label+'.stderr');so.write_bytes(p.stdout);se.write_bytes(p.stderr)
   row=dict(label=label,round=rnd,image=image,linkedRuntime=b['variants'][label]['object'],command=cmd,exitCode=p.returncode,supervisedSeconds=elapsed,stdout=pin(so),stderr=pin(se));r['rows'].append(row);save();assert p.returncode==0 and not p.stderr
   q=read(dest/'report.json');assert q['complete'] and q['byteExact'] and q['exitCode']==0 and not q['changedInputs'] and q['image']==image and q['source']==c['source'] and q['expectedQbe']==c['qbe']
   row.update(request=pin(dest/'report.json'),nativeSeconds=q['nativeSeconds'],peakRssKiB=q['peakRssKiB']);save()
 old=[x['nativeSeconds'] for x in r['rows'] if x['label']=='baseline'];new=[x['nativeSeconds'] for x in r['rows'] if x['label']=='candidate'];r['summary']=dict(baselineSeconds=old,candidateSeconds=new,medianRatio=statistics.median(new)/statistics.median(old),pairedRatios=[y/x for x,y in zip(old,new)])
 for x in inputs:verify(x)
 r['complete']=True
except BaseException as e:r['error']=repr(e);raise
finally:r['seconds']=time.monotonic()-start;save()
print(json.dumps(dict(complete=True,summary=r['summary'],seconds=r['seconds'])))
