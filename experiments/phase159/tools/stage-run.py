#!/usr/bin/env python3
"""Execute the private stage observer against the original complete self-C oracle."""
import argparse,json,os,sys
from pathlib import Path
ROOT=Path(__file__).resolve().parents[3]
sys.path.insert(0,str(ROOT/'selfhost/tools/build'))
from common import pin,verify,run,require,write_json,same_bytes
p=argparse.ArgumentParser();p.add_argument('--out',type=Path,required=True);a=p.parse_args();out=a.out.resolve();out.mkdir(parents=True,exist_ok=False)
b=ROOT/'selfhost/build/phase159';old=ROOT/'selfhost/build/phase158';binary=b/'stage-build01/bendc';oracle=old/'historical/seed/bendc.c'
inputs=[pin(binary),pin(oracle),pin(__file__),pin(b/'stage-build01/report.json')]
inputs +=[pin(x)for x in (b/'stage-prepare01').iterdir()if x.is_file()]
inputs +=[pin(x)for base in [old/'historical',old/'upstream-2.0.32']for x in sorted(base.rglob('*'))if x.is_file()and x.suffix in ['.bend','.c','.h','.js']]
r={'complete':False,'inputs':inputs,'calls':[],'scope':'Private diagnostic C seed: same emitted C required. Stage intervals and allocation counts are observations, not clean speed measurements.'}
write_json(out/'report.json',r)
try:
 for flag in ['0','1']:
  d=out/flag;d.mkdir();env={k:v for k,v in os.environ.items()if not k.startswith('BEND_')and k not in ['LD_PRELOAD','LD_AUDIT','P159_COUNT_ALLOCS']};env.update(BEND_NO_FREE='1',P159_COUNT_ALLOCS=flag)
  result=run([binary,'--threads','1','--gpu','off','--','--no-check',old/'upstream-2.0.32/bend2/base.bend','bendc.bend'],cwd=old/'historical',stdout=d/'stdout',stderr=d/'stderr',seconds=25,env=env)
  row={'allocationFlag':flag,'process':result,'passed':False};r['calls'].append(row);write_json(out/'report.json',r)
  require(result['complete']and same_bytes(d/'stdout',oracle),'Diagnostic changed self-output')
  diag=json.loads((d/'stderr').read_text());require(diag['kind']=='phase159-bendc-stages'and diag['diagnostic_errors']==0,'Invalid diagnostic')
  require(diag['count_allocations']==(flag=='1'),'Counter flag not respected');require(sum(v['allocation_calls']for v in diag['rows'])>0 if flag=='1'else sum(v['allocation_calls']for v in diag['rows'])==0,'Allocation count inconsistent')
  row.update(passed=True,diagnostic=diag);write_json(out/'report.json',r)
 for x in inputs:verify(x)
 counts=lambda d:[(v['stage'],v['calls'],v['input_items'],v['output_items'],v['output_core'],v['output_keep'])for v in d['rows']]
 require(counts(r['calls'][0]['diagnostic'])==counts(r['calls'][1]['diagnostic']),'Stage structure changed between diagnostics')
 r['complete']=True
except Exception as e:r['error']=repr(e)
write_json(out/'report.json',r);print(json.dumps({'complete':r['complete'],'calls':len(r['calls']),'error':r.get('error')}));sys.exit(0 if r['complete']else 1)
