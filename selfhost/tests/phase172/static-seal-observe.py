#!/usr/bin/env python3
"""Build and run a baseline-only sealing census on two fixed correct compiler workloads."""
import argparse,json,sys
from pathlib import Path
ROOT=Path(__file__).resolve().parents[3];sys.path.insert(0,str(ROOT/'selfhost/tools/build'))
from common import pin,verify,require,run,fresh_output,write_json,clean_environment
p=argparse.ArgumentParser(description=__doc__);p.add_argument('--plan',type=Path,required=True);p.add_argument('--out',type=Path,required=True);a=p.parse_args()
clean_environment();plan=json.loads(a.plan.read_text());require(plan['kind']=='phase172-static-seal-counter-plan' and plan['complete'],'Counter plan required')
inputs=[pin(__file__),pin(a.plan),*plan['inputs'],plan['source'],*plan['headers']]
cases=[]
for name,build,expected in [('verifier','selfhost/build/phase171/descendant-verifier-baseline-machine01/report.json','experiments/phase169/verifier.expected'),('lookup','selfhost/build/phase171/descendant-lookup-machine-baseline11/report.json','selfhost/tests/phase172/lookup.expected')]:
 d=json.loads((ROOT/build).read_text());require(d['kind']=='bend-native-build' and d['complete'],'Original build required');require(d['runtime']==plan['referenceRuntime'],'Different baseline runtime')
 cases.append((name,d['object'],pin(ROOT/expected)));inputs.extend([pin(ROOT/build),d['object'],d['sourceIR'],pin(ROOT/expected)])
for x in inputs:verify(x)
out=fresh_output(a.out,ROOT);report=dict(kind='phase172-static-seal-census',complete=False,inputs=inputs,jobs=[],rows=[],scope='Instrumented baseline rfc_seal requests on fixed valid programs; no clean timing, direct rfc_wrap calls elsewhere or whole-build inference.')
def save():write_json(out/'report.json',report)
def job(name,cmd):
 r=run(cmd,cwd=ROOT,stdout=out/(name+'.stdout'),stderr=out/(name+'.stderr'),seconds=45);report['jobs'].append(dict(name=name,**r));save();require(r['complete'],name+' failed');return r
save()
try:
 obj=out/'runtime.o';job('compile',[plan['compiler']['file'],*plan['flags'],'-c',plan['source']['file'],'-o',str(obj)]);report['runtime']=pin(obj)
 for name,program,expected in cases:
  binary=out/name;job(name+'-link',[plan['compiler']['file'],'-no-pie',program['file'],str(obj),'-pthread','-lm','-o',str(binary)])
  r=job(name+'-run',[str(binary),'--threads','1','--gpu','off']);require(Path(r['stdout']['file']).read_bytes()==Path(expected['file']).read_bytes(),'Independent output differs')
  text=Path(r['stderr']['file']).read_text();prefix=plan['stderrPrefix'];require(text.startswith(prefix) and text.count('\n')==1,'Unexpected diagnostic stderr')
  counts=json.loads(text[len(prefix):]);require(counts['kind']=='phase172-rfc-seal-counts','Unknown counter schema')
  require(counts['totalCalls']==sum(counts[k] for k in ['earlyIdentity','rawStaticWrap','rawDynamicWrap']),'Counter partition differs')
  require(all(type(counts[k]) is int and 0<=counts[k]<2**64 for k in ['totalCalls','earlyIdentity','rawStaticWrap','rawDynamicWrap']),'Invalid counts')
  report['rows'].append(dict(name=name,programObject=program,binary=pin(binary),expected=expected,outputExact=True,counts=counts));save()
 for x in inputs:verify(x)
 report['complete']=True
except Exception as e:report['error']=repr(e);raise
finally:save();print(json.dumps({k:report[k] for k in ['complete','rows']}))
