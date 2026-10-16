#!/usr/bin/env python3
"""Apply only the retained Phase99 selector delta to the Phase102 typed source."""
import argparse
import hashlib
import json
from pathlib import Path
ROOT=Path(__file__).resolve().parents[5]
TYPED=ROOT/'selfhost/build/phase102/typed-bend-source01/changes.json'
BRANCH=ROOT/'selfhost/build/phase99/branch-closures-source02/changes.json'
TYPED_SHA='52ba3d7e9ab4dc73125e558f3243581e9d0e48f379dcad7a363263ce1728951c'
BRANCH_SHA='be01c872a55b7eb024894ea013817c4f4eec9423a1ceda398ba44519bb68082c'


def pin(p):
 p=Path(p).resolve();b=p.read_bytes();return dict(file=str(p),bytes=len(b),sha256=hashlib.sha256(b).hexdigest())


def main():
 p=argparse.ArgumentParser(description=__doc__);p.add_argument('--out',type=Path,required=True);a=p.parse_args()
 out=a.out.resolve();assert out.is_relative_to(ROOT/'selfhost/build/phase102') and not out.exists()
 typed=json.loads(TYPED.read_text());branch=json.loads(BRANCH.read_text())
 assert typed['candidate']['sha256']==TYPED_SHA and branch['candidate']['sha256']==BRANCH_SHA
 for v in [typed['source'],typed['candidate'],branch['source'],branch['candidate'],branch['helper']]:assert pin(v['file'])==v
 assert typed['source']==branch['source']
 original=Path(typed['candidate']['file']).read_text();candidate=original;added=[]
 delta=branch['changes'][-2:]
 assert delta[0]['new']=='u => nbc_saturated(book, head, args, env, n, target, count),'
 assert delta[1]['old']=='' and delta[1]['new']=='\n'+Path(branch['helper']['file']).read_text()
 assert candidate.count(delta[0]['old'])==1 and 'def nbc_saturated(' not in candidate
 for row in delta:
  at=candidate.index(row['old']) if row['old'] else len(candidate)
  added.append(dict(offset=at,old=row['old'],new=row['new']))
  candidate=candidate[:at]+row['new']+candidate[at+len(row['old']):]
 inverse=candidate
 for row in reversed(added):
  at=row['offset'];assert inverse[at:at+len(row['new'])]==row['new'];inverse=inverse[:at]+row['old']+inverse[at+len(row['new']):]
 assert inverse==original
 changes=typed['changes']+added
 for row in reversed(typed['changes']):
  at=row['offset'];assert inverse[at:at+len(row['new'])]==row['new'];inverse=inverse[:at]+row['old']+inverse[at+len(row['new']):]
 assert inverse==Path(typed['source']['file']).read_text()
 out.mkdir(parents=True);(out/'compiler.bend').write_text(candidate)
 report=dict(kind='phase102-typed-plus-existing-branch-source',complete=True,targetsRun=False,releaseQualified=False,
  source=typed['source'],parentCandidate=typed['candidate'],parentRecipe=pin(TYPED),
  originalBranchCandidate=branch['candidate'],originalBranchRecipe=pin(BRANCH),originalBranchHelper=branch['helper'],
  method=pin(__file__),candidate=pin(out/'compiler.bend'),changes=changes,addedChanges=added,
  inverseExact=True,inverseToParentExact=True,physicalLineDelta=len(candidate.splitlines())-len(original.splitlines()),
  byteDelta=len(candidate.encode())-len(original.encode()),
  scope='Only last two Phase99 branch-source02 edits: saturated call selector hook plus exact helpers-v2 bytes, on the Phase102 typed-call parent. No Phase99 borrowed calls/projections/tag permission or interval changes. Original strict/literal shape gates and all ordinary fallbacks preserved. Experimental assembled source only; root owns checked emission and application validation.')
 (out/'changes.json').write_text(json.dumps(report,indent=2)+'\n');print(json.dumps(dict(candidate=report['candidate'],physicalLineDelta=report['physicalLineDelta'],byteDelta=report['byteDelta'])))


if __name__=='__main__':main()
