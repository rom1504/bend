#!/usr/bin/env python3
"""Compare already qualified JS/C products; no compiler or program execution."""
import json,sys
from pathlib import Path
sys.dont_write_bytecode=True
ROOT=Path(__file__).resolve().parents[3];sys.path.insert(0,str(ROOT/'selfhost/tools/build'))
from common import pin,verify,require,changed_inputs,write_json,same_bytes
inputs=[pin(__file__)];rows=[]
def read(file):
 p=pin(file);inputs.append(p);j=json.loads(Path(p['file']).read_text());require(j.get('complete') is True and not j.get('error') and not j.get('changedInputs'),'Incomplete evidence');return j,p
for target,old,new in [('js','js45-final-retry','js45'),('c','c45-final','c45')]:
 a,ap=read(ROOT/'selfhost/build/phase170'/old/'report.json');b,bp=read(ROOT/'selfhost/build/phase174'/new/'report.json')
 for x in [a,b]:require(x.get('passed') is True and x['target']==target and x['counts']=={'pass':45,'fail':0,'unsupported':0},'45 qualified cases required')
 oldrows={(x['source']['bytes'],x['source']['sha256']):x for x in a['rows']};require(len(oldrows)==45,'Duplicate baseline source')
 for x in b['rows']:
  y=oldrows[(x['source']['bytes'],x['source']['sha256'])];require(x['expected']==y['expected'] and x['status']==y['status']=='pass','Oracle mismatch')
  ea,eap=read(y['emission']['file']);eb,ebp=read(x['emission']['file']);verify(y['emission']);verify(x['emission'])
  for e in [ea,eb]:verify(e['product']);verify(e['source']);inputs.extend([e['product'],e['source']]);require(e['target']==target and e['mode']==a['mode']==b['mode'],'Different product mode')
  exact=same_bytes(ea['product']['file'],eb['product']['file'])
  keys=['programEngine'] if target=='js' else ['compiler','toolchain']
  policy=all(x[k]==y[k] for k in keys)
  rows.append(dict(target=target,id=x['id'],source=x['source'],baseline=ea['product'],candidate=eb['product'],byteExact=exact,executionPolicyExact=policy,baselineReport=eap,candidateReport=ebp))
require(len(rows)==90 and not changed_inputs(inputs),'Changed/incomplete evidence')
report=dict(kind='phase174-public-product-comparison',version=1,complete=True,targetsRun=False,allExact=all(x['byteExact'] and x['executionPolicyExact'] for x in rows),counts={t:sum(x['target']==t and x['byteExact'] and x['executionPolicyExact'] for x in rows) for t in ['js','c']},rows=rows,inputs=inputs,changedInputs=[],scope='Exact emitted JS/C products and execution policies; no fresh runtime benchmark.')
p=ROOT/'selfhost/build/phase174/public-products.json';require(not p.exists(),'Fresh output required');write_json(p,report);print(json.dumps({k:report[k] for k in ['complete','allExact','counts']}))
