#!/usr/bin/env python3
"""Data-only bounded own-source diagnostic extension of the reviewed final matrix."""
import argparse, hashlib, json, shlex
from pathlib import Path
HERE=Path(__file__).resolve().parent; ROOT=HERE.parents[4]; RAW=ROOT/'selfhost/build/phase58'
p=argparse.ArgumentParser(description=__doc__)
p.add_argument('matrix',type=Path);p.add_argument('out',type=Path)
a=p.parse_args();out=a.out.resolve()
assert out.is_relative_to(RAW.resolve()) and not out.exists() and not out.with_suffix('.txt').exists()
inputs={}
def pin(value):
 file=Path(value['file'] if isinstance(value,dict) else value).resolve(strict=True);h=hashlib.sha256()
 with file.open('rb') as stream:
  for block in iter(lambda:stream.read(2**20),b''):h.update(block)
 row=dict(file=str(file),sha256=h.hexdigest())
 if isinstance(value,dict):assert row['sha256']==value['sha256']
 inputs[str(file)]=row;return row
def read(value):return json.loads(Path(pin(value)['file']).read_text())
matrix=read(a.matrix)
assert matrix['kind']=='phase58-final-compiler-measurement-matrix' and matrix['complete'] and not matrix['executed']
assert pin(matrix['producer'])['sha256']=='89ad4d0be9d8dc220e7be3c97ce911b3841267449312cee635b45c2ee0694465'
parents={x['name']:x for x in matrix['commands']};commands=[]
for role,mode in [('baseline','allocation'),('candidate','allocation'),('candidate','cpu')]:
 old=parents['own-source-'+role]['command'];cmd=list(old)
 assert cmd[:3]==['python3','-B',str(ROOT/'selfhost/tools/performance/phase32/bounded-run.py')]
 assert cmd[3:9]==['--seconds','420','--rss-mib','2048','--available-mib','4096']
 assert cmd[10:14]==['--','taskset','-c','3']
 assert cmd[15:17]==['--stack-size=4096','--max-old-space-size=1024']
 assert cmd[-3]==role and cmd[-1]=='clean'
 assert cmd[17]==str(RAW/'emission-method02/emission.mjs')
 emitter=pin(next(x for x in matrix['inputs'] if x['file']==cmd[17]))
 assert emitter['sha256']=='1f65e04939c7dd3d90232e1c18848fb88415b92fce8ac8446fb2a27bfe8e63d6'
 for file in [cmd[2],cmd[18],str(Path(cmd[17]).with_name('derivation.json')),str(Path(cmd[17]).with_name('profile.mjs'))]:
  pin(next(x for x in matrix['inputs'] if x['file']==file))
 text=Path(emitter['file']).read_text()
 assert 'samplingIntervalUs:25000,samplingIntervalBytes:1048576,targetMs:100,maxRequests:1' in text
 assert "!['emitted-reachability','unsplit-library'].includes(name)" in text
 helper=Path(cmd[17]).with_name('profile.mjs').read_text()
 assert 'includeObjectsCollectedByMajorGC:true' in helper and 'includeObjectsCollectedByMinorGC:true' in helper
 target=Path(cmd[-2]).with_name('own-source-'+role+'-'+mode)
 supervisor=Path(str(target)+'-supervisor')
 assert target.is_relative_to(RAW.resolve()) and not target.exists() and not supervisor.exists()
 cmd[9]=str(supervisor);cmd[-2]=str(target);cmd[-1]=mode
 changed=[i for i,(x,y) in enumerate(zip(old,cmd)) if x!=y]
 assert changed==[9,len(cmd)-2,len(cmd)-1]
 commands.append(dict(name=target.name,command=cmd,parentName='own-source-'+role,
  replacements=[dict(index=i,before=old[i],after=cmd[i]) for i in changed],
  guard='One external bounded-run guard; emitter has none. Do not nest another guard.',
  sampling=dict(mode=mode,cpuIntervalUs=25000 if mode=='cpu' else None,
   allocationIntervalBytes=1048576 if mode=='allocation' else None,
   includeObjectsCollectedByMajorGC=mode=='allocation',includeObjectsCollectedByMinorGC=mode=='allocation',
   phases=['emitted-reachability','unsplit-library'],callsPerPhase=1)))
producer=pin(__file__)
for item in list(inputs.values()):assert pin(item)==item
result=dict(kind='phase58-own-source-diagnostic-plan',complete=True,executed=False,producer=producer,
 parent=pin(a.matrix),commands=commands,inputs=list(inputs.values()),
 scope='Fresh baseline/candidate allocation and candidate CPU only. Exactly the reviewed clean command with output paths and mode changed. '
 'Each image compiles its own source; complete B2/B3 equality is required. Profiles are not clean timings or isolated lookup causality. '
 'Sampling includes collected objects but estimates allocation, not retained memory. The external 420-second/2-GiB guard bounds each process tree; '
 '1-GiB JS heap and low sample rates reduce instrumentation cost but do not guarantee completion. Preserve timeout/RSS failures without retrying at a higher rate.')
out.parent.mkdir(parents=True,exist_ok=True);out.write_text(json.dumps(result,indent=2)+'\n')
out.with_suffix('.txt').write_text('\n\n'.join('# '+x['name']+'\n'+shlex.join(x['command']) for x in commands)+'\n')
print(json.dumps(dict(plan=pin(out),commands=len(commands),executed=False)))
