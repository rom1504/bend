#!/usr/bin/env python3
"""Native selected-library qualification, exact cross-host products and one fresh executable.
Run serially under an external process-tree guard. No language transformations.
"""
import argparse,importlib.util,json,sys,time
from pathlib import Path
sys.dont_write_bytecode=True
HERE=Path(__file__).resolve().parent;ROOT=HERE.parents[4];PHASE=HERE.parent
s=importlib.util.spec_from_file_location('r',PHASE.parent/'phase108/run.py');R=importlib.util.module_from_spec(s);s.loader.exec_module(R)
p=argparse.ArgumentParser(description=__doc__)
for name in ['source','image','suite','out']:p.add_argument('--'+name,type=Path,required=True)
a=p.parse_args();out=a.out.resolve();assert out.is_relative_to(ROOT/'selfhost/build/phase109') and not out.exists();out.mkdir(parents=True)
source=a.source.resolve();image=a.image.resolve();suite=a.suite.resolve();m=json.loads((source/'manifest.json').read_text());build=json.loads((image/'report.json').read_text());assert m['complete'] and build['complete'];binary=Path(build['binary']['file']);assert binary.parent==image
inputs=[R.pin(Path(__file__)),R.pin(source/'manifest.json'),R.pin(image/'report.json'),build['binary'],m['source'],m['assets']['base'],m['assets']['cache']['carrier'],*m['contracts'].values(),R.pin(suite/'report.json')]
report=dict(kind='phase109-native-selected-library-qualification',complete=False,inputs=inputs,jobs=[],rows=[],scope='Frozen selected source contracts only; exact mature checked frontend and erasure. Not full-language direct-IR self-hosting.')
save=lambda:R.save(out/'report.json',report);save()
def run(label,command,status=0):
 for item in inputs:R.N.verify(item)
 job=dict(label=label,command=list(map(str,command)));report['jobs'].append(job);save();start=time.monotonic()
 with (out/(label+'.stdout')).open('xb') as so,(out/(label+'.stderr')).open('xb') as se:child=R.P.run(job['command'],cwd=ROOT,stdout=so,stderr=se,timeout=30)
 job.update(status=child.returncode,seconds=time.monotonic()-start,stdout=R.pin(out/(label+'.stdout')),stderr=R.pin(out/(label+'.stderr')));save();assert child.returncode==status,label
 return (out/(label+'.stdout')).read_bytes(),(out/(label+'.stderr')).read_bytes()
def request(label,contract,policy='fused',fmt='qbe',mode='cache',input=None,status=0):
 return run(label,[binary,'--threads','1','--gpu','off','--','phase109',input or m['contracts'][contract]['file'],contract,fmt,policy,mode],status)
try:
 for contract in ['reverse','discard','duplicate']:
  for policy in ['raw','trusted','fused']:
   emitted=suite/(policy+'-'+contract+'-emitted');e=json.loads((emitted/'report.json').read_text());assert e['complete']
   expected=emitted/'program.ssa';inputs.extend([R.pin(emitted/'report.json'),R.pin(expected)]);save()
   label=contract+'-'+policy;actual,stderr=request(label,contract,policy);assert stderr==b'' and actual==expected.read_bytes()+b'\n',label+' QBE differs (IO.print adds one newline)'
   report['rows'].append(dict(label=label,sourceContract=contract,policy=policy,exactQbePlusPrintNewline=True));save()
 actual,stderr=request('reverse-fused-live','reverse',mode='live');assert stderr==b'' and actual==(out/'reverse-fused.stdout').read_bytes();report['liveBaseExact']=True;save()
 actual,stderr=request('reverse-fused-ir','reverse',fmt='ir');assert not stderr
 expected=[json.loads((suite/'fused-reverse-emitted'/(name+'.nx.json')).read_text()) for name in ['list_reverse','string_reverse']]
 assert json.loads(actual)==dict(kind='phase109-selected-owned-library',contract='reverse',policy='fused',functions=expected);report['irExact']=True;save()
 changed=out/'changed.bend';changed.write_bytes(Path(m['contracts']['reverse']['file']).read_bytes()+b'\n')
 for label,kwargs,message in [
  ('changed-source',dict(input=changed),'source does not match frozen selected-library contract'),
  ('wrong-contract',dict(input=m['contracts']['discard']['file']),'source does not match frozen selected-library contract'),
  ('unknown-policy',dict(policy='invalid'),'invalid selected-library arguments'),
  ('unknown-format',dict(fmt='invalid'),'invalid selected-library arguments')]:
   actual,stderr=request(label,'reverse',status=2,**kwargs);assert not actual and message.encode() in stderr,label
 report['negativeCases']=4;save()
 # The actual native-produced QBE text is compiled, not a copied hosted output.
 qbe=ROOT/'selfhost/build/phase108/toolchain/qbe-1.3/qbe';runtime=suite/'fused-reverse-kernel/runtime.o';harness=suite/'fused-reverse-kernel/harness.o';oracle=PHASE/'controls/expected.jsonl'
 inputs.extend([R.pin(x) for x in [qbe,runtime,harness,oracle]]);save()
 run('qbe',[qbe,'-t','amd64_sysv','-o',out/'worker.s',out/'reverse-fused.stdout'])
 run('assemble',['as','-o',out/'worker.o',out/'worker.s'])
 run('link',['gcc','-no-pie',out/'worker.o',runtime,harness,'-pthread','-lm','-o',out/'worker'])
 actual,stderr=run('execute',[out/'worker']);assert actual==oracle.read_bytes();report['runtimeCases']=len(actual.splitlines());report['workerBinary']=R.pin(out/'worker')
 for item in inputs:R.N.verify(item)
 report['complete']=True;save();print(json.dumps(dict(complete=True,sourceProducts=len(report['rows']),runtimeCases=report['runtimeCases'],negativeCases=4)))
except BaseException as e:report['error']=repr(e);save();raise
