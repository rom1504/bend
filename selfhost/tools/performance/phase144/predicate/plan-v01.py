#!/usr/bin/env python3
"""Prepare explicit serial checks/builds/timing for the predicate source ceiling."""
import hashlib,json
from pathlib import Path
ROOT=Path(__file__).resolve().parents[5];HERE=Path(__file__).resolve().parent
SOURCE=ROOT/'selfhost/build/phase144/predicate-proxy-source01';OUT=ROOT/'selfhost/build/phase144/predicate-proxy-plan01'
GUARD=ROOT/'selfhost/tools/performance/phase111/guard.py';API=ROOT/'selfhost/tools/performance/phase111/check-api.py'
PIPE=ROOT/'selfhost/tools/performance/phase134/pipe/build-v02.py';IDENTITY=ROOT/'selfhost/tools/performance/phase131/identity'
PRODUCER=ROOT/'selfhost/build/phase134/p144-integrated-n1-01/program';RUNTIME=ROOT/'selfhost/build/phase128/runtime-borrow01/runtime.o';CARRIER=ROOT/'selfhost/build/phase130/base-carrier01/receipt.json'
def pin(p):
 p=Path(p).resolve();b=p.read_bytes();return dict(file=str(p),bytes=len(b),sha256=hashlib.sha256(b).hexdigest())
def main():
 assert not OUT.exists();m=json.loads((SOURCE/'manifest.json').read_text());assert m['complete']
 OUT.mkdir(parents=True)
 expected=json.loads((IDENTITY/'proxy-v02-expected.json').read_text());assert expected['status']==0 and expected['stderr']==''
 (OUT/'expected.stdout').write_text(expected['stdout'])
 jobs=[];variants={}
 def job(name,cmd,seconds):
  jobs.append(dict(name=name,seconds=seconds+15,command=['/usr/bin/python3','-B',str(GUARD),'--out',str(OUT/(name+'-guard')),'--seconds',str(seconds),'--rss-mib','3072','--available-mib','16384','--file-mib','128','--cpu','3','--',*map(str,cmd)]))
 for mode in ['original','positive']:
  source=SOURCE/(mode+'.bend');api=ROOT/'selfhost/build/phase111'/('p144-predicate-'+mode+'-api01');control=ROOT/'selfhost/build/phase144'/('predicate-'+mode+'-controls01');build=ROOT/'selfhost/build/phase134'/('p144-predicate-'+mode+'-native01')
  assert all(not x.exists() for x in [api,control,build])
  variants[mode]=dict(source=pin(source),api=str(api/'report.json'),controls=str(control/'report.json'),build=str(build/'report.json'),binary=str(build/'program'),qbe=str(build/'program.ssa'))
  job(mode+'-check',['/usr/bin/python3','-B',API,'--source',source,'--out',api,*m['checkedApiExports']],45)
  job(mode+'-controls',[ROOT/'selfhost/.bootstrap/bun-1.4.3/bun',IDENTITY/'check.mjs','--api-report',api/'report.json','--out',control],45)
 # Keep all semantic checks before either machine build.
 for mode in ['original','positive']:
  v=variants[mode];build=Path(v['binary']).parent
  job(mode+'-build',['/usr/bin/python3','-B',PIPE,'--image',PRODUCER,'--source',v['source']['file'],'--carrier-receipt',CARRIER,'--runtime',RUNTIME,'--out',build,'--retain-ir','--expected-stdout',OUT/'expected.stdout','--seconds','90'],100)
 manifest=dict(kind='phase144-predicate-proxy-plan-v1',complete=True,targetsRun=False,inputs=[pin(__file__),pin(SOURCE/'manifest.json'),pin(IDENTITY/'proxy-v02-expected.json'),pin(IDENTITY/'timing-oracle.py'),pin(PRODUCER),pin(PRODUCER.with_name('report.json')),pin(RUNTIME),pin(CARRIER)],variants=variants,expected=pin(OUT/'expected.stdout'),scope='Current compiler Patricia algorithms; sole source delta one predicate inversion. Independent original controls and output arithmetic retained; no full compiler speed claim.')
 (OUT/'manifest.json').write_text(json.dumps(manifest,indent=2)+'\n')
 job('timing',['/usr/bin/python3','-B',HERE/'time-v01.py','--plan',OUT/'manifest.json','--out',ROOT/'selfhost/build/phase144/predicate-proxy-timing01'],80)
 (OUT/'jobs.json').write_text(json.dumps(dict(complete=True,targetsRun=False,inputs=[pin(OUT/'manifest.json')],jobs=jobs),indent=2)+'\n')
 print(json.dumps(dict(complete=True,targetsRun=False,jobs=len(jobs),plan=str(OUT/'jobs.json'))))
if __name__=='__main__':main()
