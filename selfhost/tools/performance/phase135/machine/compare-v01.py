#!/usr/bin/env python3
"""Cached/current-cold partition equality, independent of semantic output gates."""
import argparse,hashlib,importlib.util,json,pathlib
ROOT=pathlib.Path(__file__).resolve().parents[5]
def load(n,p):
 s=importlib.util.spec_from_file_location(n,p);m=importlib.util.module_from_spec(s);s.loader.exec_module(m);return m
M=load('machine',ROOT/'selfhost/tools/performance/phase132/incremental/objects.py');A=load('machine_audit',ROOT/'selfhost/tools/performance/phase132/incremental/audits.py')
p=argparse.ArgumentParser();p.add_argument('--cached',type=pathlib.Path,required=True);p.add_argument('--fresh',type=pathlib.Path,required=True);p.add_argument('--out',type=pathlib.Path,required=True);a=p.parse_args();assert not a.out.exists();l=json.loads(a.cached.read_text());r=json.loads(a.fresh.read_text());assert l['complete']and r['complete']and l['context']==r['context']and l['source']==r['source']and l['payloadDigest']==r['payloadDigest'];assert not l['cold']and r['cold']and l['cache']!=r['cache']and r['reusedUnits']==0
assert [(u['index'],u['kind'],u['key'],u['payload'])for u in l['units']]==[(u['index'],u['kind'],u['key'],u['payload'])for u in r['units']]
for build in(l,r):
 M.verify(build['binary'])
 for u in build['units']:M.verify(u['object']);M.verify(u['receipt'])
lp=pathlib.Path(l['binary']['file']);rp=pathlib.Path(r['binary']['file']);ls,rs=M.allocated(lp),M.allocated(rp);lh,rh=A.elf_headers(lp),A.elf_headers(rp);assert ls==rs and lh==rh
result=dict(complete=True,targetsRun=False,inputs=[M.pin(__file__),M.pin(a.cached),M.pin(a.fresh),M.pin(ROOT/'selfhost/tools/performance/phase132/incremental/objects.py'),M.pin(ROOT/'selfhost/tools/performance/phase132/incremental/audits.py')],cached=l['binary'],fresh=r['binary'],reusedUnits=l['reusedUnits'],positiveHits=l['reusedUnits']>0,allocatedSectionsExact=True,headersExact=True,sections=ls,headers=lh,scope='Exact machine image against independently cold current partition; separate monolithic ordinary/compiler gates and producer-status proof still required.')
a.out.parent.mkdir(parents=True,exist_ok=True);a.out.write_text(json.dumps(result,indent=2)+'\n');print(json.dumps(dict(complete=True,reusedUnits=l['reusedUnits'])))
