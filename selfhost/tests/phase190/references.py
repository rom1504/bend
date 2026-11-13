#!/usr/bin/env python3
"""Freeze retained executable identities for fresh runtime comparisons, not builds.

Historical build inputs may have moved or been archived. This intentionally binds
execution inputs: exact executable, acquisition receipt, source and independent
catalog oracle. It does not relabel old build products as freshly compiled.
"""
import argparse,json,sys
from pathlib import Path
ROOT=Path(__file__).resolve().parents[3]
sys.path[:0]=[str(ROOT/'selfhost/tools/bench'),str(ROOT/'selfhost/tools/build')]
import bench as B
import common as C
CATALOG=ROOT/'selfhost/tools/bench/catalogs/native45/catalog.json'
p=argparse.ArgumentParser(description=__doc__);p.add_argument('--out',type=Path,required=True);a=p.parse_args()
known={c['id']:c for c in B.catalog(CATALOG)['cases']}
paths={'c':ROOT/'selfhost/build/phase184/bend-products01/programs.manifest.json',
       'qbe':ROOT/'selfhost/build/phase186/release-native45-acquire01/programs.manifest.json',
       'baseline':ROOT/'selfhost/build/phase188/native45-final06/report.json'}
roles={}; products={name:{} for name in known}; receipts=[]
for alias,path in paths.items():
 doc=json.loads(path.read_text());receipt=C.pin(path);receipts.append(receipt)
 if alias=='baseline':
  C.require(doc.get('complete') and not doc.get('changedInputs') and not doc.get('error'),'Incomplete baseline acquisition')
  rows={r['id']:r for r in doc['rows']}
 else:rows={r['id']:r for r in doc['cases']}
 roles[alias]=dict(host='native',stage='N1' if alias=='c' else 'N2',target='x86' if alias=='baseline' else alias,
   policy='ordinary-single-cpu',preparation='cache',status='retained-executable-for-fresh-runtime',emitter='selfhost',
   inputs=[receipt,C.pin(__file__)])
 for name,case in known.items():
  row=rows[name]
  C.require(row['source']==case['source'] and row['expectedFile']==case['expectedFile'] and
    all(row['point'][k]==case['point'][k] for k in ['expectedStdout','runtimeArgs','ratioEligible']), 'Source/oracle mismatch')
  extra=[]
  if alias=='baseline':
   product=row['products']['object'];C.require(product.get('complete') and product.get('status')=='executed-independent-oracle-pass','Baseline oracle missing')
   built=json.loads(C.verify(product['buildReceipt']).read_text());image=product['binary'];extra=[product['buildReceipt'],product['oracleReceipt']]
   C.require(built['binary']==image and built.get('emissionFormat')=='elf64-le-amd64-relocatable','Baseline product mismatch')
   convention=built['runtimeArgumentConvention']
  else:
   product=row['products']['bend-c' if alias=='c' else 'phase186-qbe-n2'];image=product['artifact'];convention=product['runtimeArgumentConvention']
  C.verify(image)
  for item in extra:C.verify(item)
  products[name][alias]=dict(artifact=image,runtimeArgumentConvention=convention,inputs=[receipt,*extra])
out=C.fresh_output(a.out,ROOT)
recipe=dict(kind='programs',cwd=str(ROOT),catalog=str(CATALOG),reference='c',roles=roles,
 cases=[dict(id=name,products=products[name]) for name in known],
 scope='Retained exact C, QBE and installed-equivalent x86 object executables. Fresh independent output/runtime measurements only; historical build inputs are provenance, not current compiler/build qualification.')
C.write_json(out/'recipe.json',recipe);B.freeze(out/'recipe.json',out/'manifest.json')
C.write_json(out/'report.json',dict(kind='phase190-executable-references',complete=True,targetsRun=False,
 inputs=receipts,manifest=C.pin(out/'manifest.json'),cases=list(known),scope=recipe['scope']))
print('Reference runtime manifest:',out/'manifest.json')
