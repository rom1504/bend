#!/usr/bin/env python3
"""Serial isolated check of a discovered deep error-page discrepancy; no compiler edits."""
import hashlib,json,pathlib,subprocess,sys
ROOT=pathlib.Path(__file__).resolve().parents[5]
base=ROOT/'selfhost/build/phase91/deep-diagnostic01';base.mkdir(parents=True,exist_ok=False)
p=json.loads((ROOT/'implementation/phase91/conformance-plan01.json').read_text())
roles={'b1':ROOT/'selfhost/build/phase90/compiler07/equality/api.mjs','b2':ROOT/'selfhost/dist/typed-api.mjs',
       'old-b2':ROOT/'selfhost/build/phase82/compiler04-b2/full/compiler.mjs','typescript':None}
commands=[]
for role,api in roles.items():
 c=p['jobs'][0]['command'][:];out=base/role
 for flag,value in [('--out',str(out/'guard')),('--seconds','30'),('--output',str(out/'report.json')),('--worker-mode','isolated'),('--lanes','check'),('--retain','all')]:c[c.index(flag)+1]=value
 c[c.index('BEND_TYPED_TRACE=')]='BEND_TYPED_TRACE=1'
 if api:
  assert api.is_file();i=next(i for i,x in enumerate(c) if x.startswith('BEND_TYPED_API='));c[i]='BEND_TYPED_API='+str(api)
 else:c[c.index('--adapter')+1]=str(ROOT/'selfhost/tools/conformance/adapters/upstream.mjs')
 c.extend(['--filter',r'^page/deep_list_walk\.bend$'])
 commands.append(dict(role=role,command=c,api=None if api is None else dict(file=str(api),sha256=hashlib.sha256(api.read_bytes()).hexdigest())))
(base/'plan.json').write_text(json.dumps(dict(kind='phase91-deep-diagnostic-controls',jobs=commands),indent=2)+'\n')
for job in commands:
 r=subprocess.run(job['command'],cwd=ROOT,check=False);assert r.returncode in [0,1]
 report=json.loads((base/job['role']/'report.json').read_text());assert len(report['results'])==1
 row=report['results'][0];diagnostic=row.get('result',{}).get('diagnostic','')
 print(json.dumps(dict(role=job['role'],status=row['status'],diagnosticBytes=len(diagnostic.encode()),diagnosticPrefix=diagnostic[:150])),flush=True)
