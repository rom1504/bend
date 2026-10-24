#!/usr/bin/env python3
"""Three frozen compiler requests, independent aligned reference builds, execution."""
import argparse,filecmp,hashlib,json,pathlib,subprocess,sys,time
ROOT=pathlib.Path(__file__).resolve().parents[5]
def pin(p):
 p=pathlib.Path(p).resolve();h=hashlib.sha256();n=0
 with p.open('rb')as f:
  while b:=f.read(65536):h.update(b);n+=len(b)
 return dict(file=str(p),bytes=n,sha256=h.hexdigest())
p=argparse.ArgumentParser();p.add_argument('--out',type=pathlib.Path,required=True);a=p.parse_args();out=a.out.resolve();assert not out.exists();out.mkdir(parents=True)
ref=ROOT/'selfhost/build/phase134/reference03.json';r=json.loads(ref.read_text());image=ROOT/'selfhost/build/phase111/p134-no-copy-n1/program';runtime=ROOT/'selfhost/build/phase128/runtime-borrow01/runtime.o';carrier=ROOT/'selfhost/build/phase130/base-carrier01/receipt.json';pipe=ROOT/'selfhost/tools/performance/phase134/pipe/build.py';aligned=ROOT/'selfhost/tools/performance/phase123/build-aligned.py'
report=dict(complete=False,inputs=[pin(__file__),pin(ref),pin(image),pin(runtime),pin(carrier),pin(pipe),pin(aligned)],cases=[],jobs=[])
def save():(out/'report.json').write_text(json.dumps(report,indent=2)+'\n')
def run(label,cmd,ok=0):
 t=time.monotonic()
 with(out/(label+'.stdout')).open('xb')as so,(out/(label+'.stderr')).open('xb')as se:z=subprocess.run(list(map(str,cmd)),cwd=ROOT,stdout=so,stderr=se,timeout=60)
 report['jobs'].append(dict(label=label,command=list(map(str,cmd)),status=z.returncode,seconds=time.monotonic()-t,stdout=pin(out/(label+'.stdout')),stderr=pin(out/(label+'.stderr'))));save();assert z.returncode==ok,(label,z.returncode)
base=[sys.executable,'-B',pipe,'--image',image,'--carrier-receipt',carrier,'--runtime',runtime,'--seconds','45']
save()
try:
 for c in r['cases']:
  name=c['name'];dest=out/name;ordinary=ROOT/'selfhost/build/phase111'/('p134-pipe-reference-'+name+'-01')
  for x in (c['source'],c['expectedQbe']):assert pin(x['file'])==x;report['inputs'].append(x)
  run(name+'-pipe',base+['--source',c['source']['file'],'--out',dest,'--expected-qbe',c['expectedQbe']['file']])
  run(name+'-reference',[sys.executable,'-B',aligned,'--source',c['expectedQbe']['file'],'--runtime',runtime,'--out',ordinary,'--seconds','30'])
  pr=json.loads((dest/'report.json').read_text());rr=json.loads((ordinary/'report.json').read_text());assert pr['complete']and rr['complete']and pr['comparedToReference'];assert not(dest/'program.ssa').exists()
  same_object=filecmp.cmp(dest/'program.o',ordinary/'program.o',shallow=False);same_binary=filecmp.cmp(dest/'program',ordinary/'program',shallow=False)
  assert same_object and same_binary,(name,same_object,same_binary)
  run(name+'-expected-execute',[ordinary/'program','--threads','1','--gpu','off']);run(name+'-pipe-execute',[dest/'program','--threads','1','--gpu','off'])
  assert filecmp.cmp(out/(name+'-expected-execute.stdout'),out/(name+'-pipe-execute.stdout'),shallow=False)
  assert (out/(name+'-expected-execute.stderr')).stat().st_size==(out/(name+'-pipe-execute.stderr')).stat().st_size==0
  report['cases'].append(dict(name=name,complete=True,pipe=pin(dest/'report.json'),reference=pin(ordinary/'report.json'),irDigest=pr['irDigest'],maximumRelayBytes=pr['maximumRelayBytes'],assemblyExact=filecmp.cmp(dest/'program.s',ordinary/'program.s',shallow=False),objectExact=same_object,binaryExact=same_binary,executionExact=True,noTextIR=True));save()
 expected=out/'newline.expected';expected.write_bytes(b'\n');dest=out/'ordinary-new-source'
 run('ordinary-no-reference',base+['--source',ROOT/'selfhost/tools/performance/phase134/emission/writer/newline-failure.bend','--out',dest,'--expected-stdout',expected])
 pr=json.loads((dest/'report.json').read_text());assert pr['complete']and not pr['comparedToReference']and pr['outputExact']and not(dest/'program.ssa').exists();report['ordinaryUnreferenced']=pin(dest/'report.json')
 # A real correct stream with the wrong independent digest must not reach assembly.
 bad=out/'wrong-digest';run('reject-wrong-digest',base+['--source',r['cases'][1]['source']['file'],'--out',bad,'--expected-qbe',r['cases'][0]['expectedQbe']['file']],ok=1)
 pr=json.loads((bad/'report.json').read_text());assert not pr['complete']and pr['compilerExitCode']==pr['qbeExitCode']==0 and not(bad/'program.o').exists();report['wrongDigestRefusal']=pin(bad/'report.json')
 for x in report['inputs']:assert pin(x['file'])==x
 report['complete']=True
finally:save()
print(json.dumps(dict(complete=report['complete'],cases=len(report['cases']))))
