#!/usr/bin/env python3
"""Authenticate two consecutive assembly generations; no correctness theorem."""
import argparse,json,sys
from pathlib import Path
ROOT=Path(__file__).resolve().parents[3]
sys.dont_write_bytecode=True
sys.path.insert(0,str(ROOT/'selfhost/tools/build'))
from common import pin,verify,require,fresh_output,write_json
p=argparse.ArgumentParser();p.add_argument('--first',type=Path,required=True);p.add_argument('--second',type=Path,required=True);p.add_argument('--out',type=Path,required=True);a=p.parse_args()
out=fresh_output(a.out,ROOT);rows=[json.loads(f.read_text())for f in [a.first,a.second]]
inputs=[pin(__file__),pin(a.first),pin(a.second)]
report=dict(kind='phase181-native-assembly-reproduction',complete=False,inputs=inputs,scope='Consecutive native assembly generations on the same source, binding, runtime and machine toolchain. Byte equality is bootstrap consistency, not semantic equivalence to an independent implementation or proof.')
try:
 for row in rows:
    require(row['complete']and row['kind']=='phase181-native-assembly-build'and not row['changedInputs'],'successful build required')
    inputs.extend(row[k]for k in ['source','image','binding','assembly','object','binary','runtime'])
 for item in inputs:verify(item)
 b,c=rows
 same=lambda x,y:x['bytes']==y['bytes']and x['sha256']==y['sha256']
 require(same(b['binary'],c['image']),'not consecutive generations')
 for key in ['source','binding','runtime']:require(same(b[key],c[key]),'changed '+key)
 require(b['toolchain']==c['toolchain'],'machine policy differs')
 report['identical']={key:same(b[key],c[key])for key in ['assembly','object','binary']}
 require(report['identical']['assembly'],'assembly differs')
 report['complete']=True
except Exception as e:report['error']=repr(e)
write_json(out/'report.json',report);print(json.dumps({k:report[k]for k in ['complete','identical','error']if k in report}))
if not report['complete']:raise SystemExit(1)
