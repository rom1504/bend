#!/usr/bin/env python3
"""Authenticate all45 checked-hosted/N1 objects and linked sections, offline."""
import argparse
import importlib.util
import sys
from pathlib import Path
sys.dont_write_bytecode=True
method=Path(__file__).resolve().parents[1]/'phase190/compare-products.py'
spec=importlib.util.spec_from_file_location('p192_products',method)
P=importlib.util.module_from_spec(spec);spec.loader.exec_module(P)
p=argparse.ArgumentParser(description=__doc__)
p.add_argument('--left',type=Path,required=True);p.add_argument('--right',type=Path,required=True)
p.add_argument('--out',type=Path,required=True);a=p.parse_args()
e=P.Evidence()
for file in (__file__,method,P.CATALOG,P.bench.__file__,P.common.__file__,P.product_compare.__file__,P.request.__file__):e.verify(P.common.pin(file))
out=P.common.fresh_output(a.out,P.ROOT)
r=dict(kind='phase192-hosted-native-products',complete=False,targetsRun=False,rows=[])
try:
 left=P.load_side(a.left,'candidate',e);right=P.load_side(a.right,'candidate',e)
 P.common.require(left['role']['host']=='js' and left['role']['stage']=='B1' and right['role']['host']=='native' and right['role']['stage']=='N1','Actual checked B1/native N1 required')
 cases=P.bench.catalog(P.CATALOG)['cases'];names={c['id'] for c in cases}
 P.common.require(len(names)==45 and set(left['rows'])==names and set(right['rows'])==names,'Exact complete45 catalogs')
 P.common.require(left['role']['runtime']==right['role']['runtime'],'Runtime identity differs')
 # Hosted preparation must originate in the exact native-selected compiler source.
 emission=left['emission']
 P.common.require(emission['sourcePreparation']['snapshot']==right['producer']['source'],'Hosted parent differs from selected native compiler source')
 for c in cases:
  x=P.authenticate_product(left,c,e);y=P.authenticate_product(right,c,e)
  same={s:x['sections'][s]==y['sections'][s] for s in x['sections']}
  row=dict(id=c['id'],left=x,right=y,objectIdentical=P.product_compare.same(x['object'],y['object']),linkedSectionsIdentical=same)
  r['rows'].append(row)
  P.common.require(row['objectIdentical'] and all(same.values()),'Product mismatch: '+c['id'])
 r['complete']=True
except BaseException as error:r['error']=repr(error)
r['inputs']=list(e.inputs.values());r['changedInputs']=P.common.changed_inputs(r['inputs'])
if r['changedInputs']:r['complete']=False
P.common.write_json(out/'report.json',r)
print({k:r.get(k) for k in ('complete','error')})
sys.exit(0 if r['complete'] else 1)
