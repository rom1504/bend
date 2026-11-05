#!/usr/bin/env python3
"""Offline, exact-artifact view comparison; counts are static, not execution events."""
import argparse,importlib.util,json,re,sys
from pathlib import Path
sys.dont_write_bytecode=True
ROOT=Path(__file__).resolve().parents[3]
spec=importlib.util.spec_from_file_location('census167',ROOT/'experiments/phase167/tools/static-census.py')
old=importlib.util.module_from_spec(spec);spec.loader.exec_module(old)
p=argparse.ArgumentParser();p.add_argument('--stock',type=Path,required=True);p.add_argument('--seeded',type=Path,required=True);p.add_argument('--out',type=Path,required=True);a=p.parse_args()
def inspect(path):
 row,entries=old.inspect(path/'emit/report.json')
 row['calls']={}
 for entry in entries.values():
  for target in re.findall(r'\bcall \$([A-Za-z0-9_]+)',entry['body']):
   row['calls'][target]=row['calls'].get(target,0)+1
 return row,entries
left,ll=inspect(a.stock);right,rr=inspect(a.seeded)
# Each request authenticates the same semantic inputs; binding-file locations differ.
def identities(row): return [(x['bytes'],x['sha256']) for x in row['inputs']]
assert identities(left)==identities(right),'Different semantic/tool identities'
ld={k:v['body'] for k,v in ll.items() if v['family']=='p113d'}
rd={k:v['body'] for k,v in rr.items() if v['family']=='p113d'}
assert ld==rd,'Direct bodies changed in the callable-view control'
result=dict(complete=True,method=old.pin(Path(__file__)),stock=left,seeded=right,
 directBodiesIdentical=len(ld),
 callSiteChanges={k:[left['calls'].get(k,0),right['calls'].get(k,0)]
  for k in sorted(left['calls'].keys()|right['calls'].keys())
  if left['calls'].get(k,0)!=right['calls'].get(k,0)},
 limits=['Static call sites are not dynamic call counts or time attribution.',
         'Identical direct bodies do not mean all caller code or layout is identical.'])
assert not a.out.exists();a.out.parent.mkdir(parents=True,exist_ok=True)
a.out.write_text(json.dumps(result,indent=2)+'\n')
print(json.dumps(dict(directBodiesIdentical=len(ld),stockFunctions=left['functions'],seededFunctions=right['functions'],runtimeCallChanges={k:v for k,v in result['callSiteChanges'].items() if k.startswith(('p111_rt_','p113_rt_','p125_rt_'))})))
