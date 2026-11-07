#!/usr/bin/env python3
"""Aggregate the unchanged finite control runners; never execute compiler code."""
import json,sys
from pathlib import Path
sys.dont_write_bytecode=True
ROOT=Path(__file__).resolve().parents[3]
sys.path.insert(0,str(ROOT/'selfhost/tools/build'))
from common import pin,verify,require,changed_inputs,fresh_output,write_json
inputs=[pin(__file__)]
def read(file):
 p=pin(ROOT/file);inputs.append(p);j=json.loads(Path(p['file']).read_text());require(j.get('complete') is True and not j.get('error'),'Incomplete control: '+file);return j,p
api,ap=read('selfhost/build/phase174/controls-api/report.json')
require(api.get('checked') is True,'Checked controls required')
inputs.extend([api['api'],api['source']]);[verify(x) for x in inputs]
receipts={};counts={}
for name,folder,n in [('failFast','controls-failfast',22),('planners','controls-lazy-retry',32),('catalogue','controls-scalar',12),('history','controls-history',5)]:
 j,p=read('selfhost/build/phase174/'+folder+'/report.json');receipts[name]=p
 require(len(j['rows'])==n,'Wrong finite count')
 for x in j['inputs']:verify(x);inputs.append(x)
 if name in ['failFast','planners']:
  require(j.get('passed') is True and all(x.get('passed') is True for x in j['rows']),'Failed finite comparison')
  require(j['authorities']['candidate']['image']==api['api'],'Different candidate')
 else:
  require(j['expected']==n and all(x is True or isinstance(x,str) and x.endswith(':pass') for x in j['rows']),'Failed value control')
 if name=='failFast':
  require(j['scc']['baseline']==j['scc']['candidate'] and len(j['scc']['candidate'])==6 and all(x.endswith(':pass') for x in j['scc']['candidate']),'SCC control failed');counts['scc']=6
 counts[name]=n
require(sum(counts.values())==77 and not changed_inputs(inputs),'Control inputs changed')
source=pin(ROOT/'selfhost/build/phase174/source01/compiler.bend');inputs.append(source)
require(Path(api['source']['file']).read_bytes().startswith(Path(source['file']).read_bytes()),'Control source lost canonical prefix')
out=fresh_output(ROOT/'selfhost/build/phase174/controls',ROOT)
write_json(out/'report.json',dict(kind='phase174-integrated-controls',version=1,complete=True,passed=True,total=77,counts=counts,canonicalSource=source,candidateApi=api['api'],receipts=receipts,inputs=inputs,changedInputs=[],scope='Finite controls through independently checked API; not BendTT proofs.'))
print('77 integrated controls passed')
