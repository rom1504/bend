#!/usr/bin/env python3
"""Freeze source and independent ordered U32 callback fixture points."""
import argparse,hashlib,json
from pathlib import Path
HERE=Path(__file__).resolve().parent
p=argparse.ArgumentParser();p.add_argument('--out',required=True,type=Path);a=p.parse_args();assert a.out.resolve().parent==HERE and not a.out.exists()
source_file=HERE/'noncommutative-fixture.bend';raw=source_file.read_bytes();source=dict(path=source_file.name,sha256=hashlib.sha256(raw).hexdigest(),bytes=len(raw),provenance=dict(kind='phase43-independent-noncommutative-known-callback-source',design='design/phase43/callbacks.md'))
def values(n,seed):
 affine=reverse=seed
 for k in range(n,0,-1):affine=(affine*k+3)&0xffffffff;reverse=(k-reverse)&0xffffffff
 seeded=seed;changing=seed
 for left in range(n-1,-1,-1):seeded=((changing+left)-seeded)&0xffffffff;changing=(changing+1)&0xffffffff
 return dict(affine_result=affine,reverse_result=reverse,live_result=(seed+n*(n+1)//2)&0xffffffff,seeded_result=seeded)
cases=[]
for n in [0,1,2,3,7,64,256]:
 for seed in [0,17,4294967295]:
  for name,expected in values(n,seed).items():
   fast=name in ['affine_result','reverse_result'] and n in [64,256] and seed==17
   cases.append(dict(id='callback-'+name.replace('_','-')+f'-{n}-{seed}',family='known-callback-order',category='diagnostic',partition='development',description='Known noncommutative captured functions with complete materialized composition and explicit refusal roots',source=source,point=dict(exportName=name,args=[n,seed],expected=expected),sets=['core','broad','full']+(['fast'] if fast else []),oracle='Independent ordered Python U32 integer recurrence; no generated expression evaluator'))
sets={name:[c['id'] for c in cases if name in c['sets']] for name in ['fast','core','broad','full']}
a.out.write_text(json.dumps(dict(schemaVersion=1,upstreamCommit='018751270e800bc222a93dad7f257083ee53a5f7',scope='Phase43 authored source fixture; actual checked emission and refusal coverage, not representative prevalence.',cases=cases,sets=sets,oracleProducer=dict(path=Path(__file__).name,sha256=hashlib.sha256(Path(__file__).read_bytes()).hexdigest())),indent=2)+'\n');print(json.dumps(dict(complete=True,out=str(a.out),cases=len(cases),fast=len(sets['fast']))))
