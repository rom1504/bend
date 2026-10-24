#!/usr/bin/env python3
"""Derive compact query evidence from closed receipts; no target execution."""
import argparse
import hashlib
import json
from pathlib import Path
import shutil

ROOT=Path(__file__).resolve().parents[5]

def pin(path):
 path=Path(path).resolve();data=path.read_bytes()
 return dict(file=str(path),bytes=len(data),sha256=hashlib.sha256(data).hexdigest())

def read(path):return json.loads(Path(path).read_text())

def main():
 ap=argparse.ArgumentParser(description=__doc__);ap.add_argument('--out',type=Path,required=True);a=ap.parse_args();out=a.out.resolve()
 assert not out.exists() and out.is_relative_to(ROOT/'implementation/phase136/baseline')
 census_path=ROOT/'selfhost/build/phase136/query-census02/report.json';census=read(census_path)
 api_path=ROOT/'selfhost/build/phase111/p136-query-api02/report.json';api=read(api_path)
 api_guard=read(ROOT/'selfhost/build/phase136/query-api-guard02/process.json')
 guard_path=ROOT/'selfhost/build/phase136/query-census-guard02/process.json';guard=read(guard_path)
 assert census['complete'] and api['complete'] and api['checked'] and api['status']==0 and guard['complete'] and api_guard['complete']
 assert len(census['controls'])==14 and all(s.startswith('PASS ')for s in census['controls'])
 assert len(census['rows'])==30 and all(r['result']['exact']for r in census['rows'])
 cases=sorted({r['case']for r in census['rows']});assert len(cases)==3
 prefixes=[]
 for n in (16,64,256):
  rows=[r for r in census['rows']if r.get('prefixLimit')==n]
  assert len(rows)==6 and all(r['result']==rows[0]['result']for r in rows)
  v=rows[0]['result'];assert v['find_rows']==v['lookup_rows']==n*(n+1)//2
  prefixes.append(dict(prefixRows=n,queries=v['queries'],findRows=v['find_rows'],lookupRows=v['lookup_rows'],ownershipBookRows=v['owner_rows'],ownershipChildRows=v['child_rows']))
 constructors=[]
 for case in cases:
  rows={r['bookPolicy']:r for r in census['rows']if r['case']==case and r['book']=='source'and 'bookPolicy'in r}
  raw,actual=rows['raw']['result'],rows['actual']['result']
  assert raw['queries']==actual['queries']==16 and raw['delegations']==0 and actual['delegations']==actual['lookup_rows']==16
  assert actual['find_rows']==raw['find_rows']+16 and actual['owner_rows']==raw['owner_rows']+16 and actual['child_rows']==raw['child_rows']
  for policy in ('raw','actual'):
   duplicate=next(r for r in census['rows']if r['case']==case and r['book']=='book'and r.get('bookPolicy')==policy)
   assert duplicate['result']==rows[policy]['result'] and duplicate['names']==rows[policy]['names']
  constructors.append(dict(case=case,queries=16,rawFindRows=raw['find_rows'],rawLookupRows=raw['lookup_rows'],actualFindRows=actual['find_rows'],actualLookupRows=actual['lookup_rows'],actualIndexDelegations=actual['delegations'],rawOwnershipBookRows=raw['owner_rows'],actualOwnershipBookRows=actual['owner_rows'],ownershipChildRows=actual['child_rows']))
 paths=[census_path,api_path,ROOT/'selfhost/build/phase111/p136-query-api01/report.json',ROOT/'selfhost/build/phase111/p136-query-api01/stderr',guard_path,
  ROOT/'selfhost/build/phase136/query-api-guard01/process.json',ROOT/'selfhost/build/phase136/query-api-guard02/process.json',
  ROOT/'selfhost/build/phase136/query-source01/manifest.json',ROOT/'selfhost/build/phase136/query-source02/manifest.json',
  ROOT/'selfhost/build/phase136/cold-baseline-plan01/plan.json',ROOT/'selfhost/build/phase136/cold-baseline-plan01/command.sh',
  ROOT/'selfhost/build/phase136/cold-baseline-launch-audit01.json',ROOT/'selfhost/build/phase136/cold-baseline-guard01/process.json',
  ROOT/'selfhost/build/phase134/p136-cold-baseline01/report.json',ROOT/'selfhost/build/phase134/p136-cold-baseline01/method.py',
  ROOT/'selfhost/build/phase134/p136-cold-baseline01/compiler.stderr',ROOT/'selfhost/build/phase134/p136-cold-baseline01/qbe.stderr',
  ROOT/'selfhost/build/phase134/p136-cold-baseline01/assemble.stderr',ROOT/'selfhost/build/phase134/p136-cold-baseline01/link.stderr']
 out.mkdir(parents=True);copies=[]
 for source in paths:
  assert source.stat().st_size<2*1024**2
  rel=source.relative_to(ROOT);target=out/rel;target.parent.mkdir(parents=True,exist_ok=True);before=pin(source);shutil.copyfile(source,target);after=pin(target)
  assert all(before[k]==after[k]for k in ('bytes','sha256')) and pin(source)==before
  copies.append(dict(source=before,archive=dict(path=str(rel),bytes=after['bytes'],sha256=after['sha256'])))
 result=dict(kind='phase136-query-shape-summary',complete=True,targetsRun=False,method=pin(__file__),source=read(ROOT/'selfhost/build/phase136/query-source02/manifest.json')['source'],
  evidence=copies,controls=14,rows=30,allSelectedQueryResultsExact=True,prefixes=prefixes,constructorQueries=constructors,
  sharedPrefixWarning='All three cases and both source/native-book observations share these same Base prefixes. They are not six independent workload-generalization results.',
  indexWarning='16 delegated Patricia queries replace thousands of raw list visits; hash/tree/bucket and ownership work inside delegation is uncounted, not zero.',
  timing=dict(apiInternalSeconds=api['seconds'],apiGuardSeconds=api_guard['wallSeconds'],censusInternalSeconds=census['seconds'],censusGuardSeconds=guard['wallSeconds'],censusPeakRssBytes=guard['peakTreeRssBytes']),
  scope='Controlled logical query schedule and exact original-query result checks on actual KDef books. Does not measure real whole-compilation call frequency, CPU time saved, native allocations/refcounts, or speedup. No production override or native compiler acquisition.',
  archivedBytes=sum(r['archive']['bytes']for r in copies))
 (out/'summary.json').write_text(json.dumps(result,indent=2)+'\n');print(json.dumps(dict(complete=True,files=len(copies),bytes=result['archivedBytes'],summary=pin(out/'summary.json'))))
if __name__=='__main__':main()
