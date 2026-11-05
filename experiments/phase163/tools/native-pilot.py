#!/usr/bin/env python3
"""Build exact emitted products and compare native results; no Bend semantics."""
import argparse,json,sys,time
from pathlib import Path
ROOT=Path(__file__).resolve().parents[3];sys.dont_write_bytecode=True
sys.path.insert(0,str(ROOT/'selfhost/tools/build'))
from common import pin,verify,write_json,fresh_output,run,require
p=argparse.ArgumentParser();p.add_argument('--emission',type=Path,required=True);p.add_argument('--out',type=Path,required=True);a=p.parse_args()
data=json.loads(a.emission.read_text());require(data['complete'],'Incomplete emission');out=fresh_output(a.out,ROOT)
r=dict(complete=False,inputs=[pin(__file__),pin(a.emission)],rows=[],scope='Same runtime/toolchain, complete stdout equality; qualified frontend/lowering reference and independently tested source fixtures. No native compiler promotion.')
def save():write_json(out/'report.json',r)
try:
 for row in data['rows']:
  if not row.get('direct'):continue
  result=dict(name=row['name'],complete=False,products={});r['rows'].append(result);save()
  for mode in ['baseline','direct']:
   ir=row[mode];verify(ir);r['inputs'].append(ir);dest=out/(row['name']+'-'+mode)
   command=[sys.executable,'-B','selfhost/tools/build/native.py','--assets','selfhost/manifests/assets-native.json','--ir',ir['file'],'--target','qbe','--out',str(dest),'--seconds','45']
   job=run(command,cwd=ROOT,stdout=out/(dest.name+'.stdout'),stderr=out/(dest.name+'.stderr'),seconds=50)
   require(job['complete'],'Machine construction failed '+dest.name)
   receipt=json.loads((dest/'report.json').read_text());require(receipt['complete'],'Machine receipt failed')
   program=receipt['binary'];verify(program)
   execution=run([program['file'],'--threads','1','--gpu','off'],cwd=ROOT,stdout=out/(dest.name+'.result'),stderr=out/(dest.name+'.diagnostic'),seconds=15)
   require(execution['complete'] and execution['stderr']['bytes']==0,'Native execution failed '+dest.name)
   result['products'][mode]=dict(build=pin(dest/'report.json'),buildSeconds=receipt['wallSeconds'],binary=program,execution=execution)
   save()
  left=result['products']['baseline']['execution']['stdout'];right=result['products']['direct']['execution']['stdout']
  require(left['sha256']==right['sha256'] and left['bytes']==right['bytes'],'Native output mismatch '+row['name'])
  result['complete']=True;save()
 r['inputs'].append(pin(ROOT/'selfhost/tools/build/native.py'));r['complete']=True
except Exception as e:r['error']=str(e);raise
finally:save();print(json.dumps(dict(complete=r['complete'],rows=len(r['rows']),error=r.get('error'))))
