#!/usr/bin/env python3
"""Prepare a bounded TRMC derivative; offline source edits, no targets."""
import argparse
import hashlib
import json
from pathlib import Path
ROOT=Path(__file__).resolve().parents[5]
HERE=Path(__file__).resolve().parent


def pin(p):
 p=Path(p).resolve();b=p.read_bytes();return dict(file=str(p),bytes=len(b),sha256=hashlib.sha256(b).hexdigest())


def main():
 p=argparse.ArgumentParser(description=__doc__)
 p.add_argument('--parent',type=Path,required=True);p.add_argument('--out',type=Path,required=True);a=p.parse_args()
 out=a.out.resolve();assert out.is_relative_to(ROOT/'selfhost/build/phase102') and not out.exists()
 parent=json.loads(a.parent.read_text());assert parent['complete'] and parent['inverseExact']
 for v in [parent['source'],parent['candidate']]:assert pin(v['file'])==v
 original=Path(parent['candidate']['file']).read_text();candidate=original;added=[]
 def replace(old,new):
  nonlocal candidate
  assert candidate.count(old)==1,(old[:100],candidate.count(old))
  at=candidate.index(old);added.append(dict(offset=at,old=old,new=new));candidate=candidate[:at]+new+candidate[at+len(old):]
 replace('def nf_candidate(', 'def ntr_plain_candidate(')
 replace('def nf_bodies(', 'def ntr_plain_bodies(')
 replace('def nq_transfer(', 'def ntr_plain_transfer(')
 replace('def nc_lower_live_to(book, t, env, n, target):', 'def ntr_plain_lower_live_to(+book: List<&2, KDef>, +t: KTerm, +env: List<&2, NC_Binding>, +n: U32, +target: NC_Target) -> NC_Code:')
 replace('u => nc_lower_to(book, nc_sequence("NCtr", nm(t), ks(t), Nil{}, n), env, U32.add(n, terms_len(ks(t))), target))', 'u => ntr_ctor(book, t, env, n, target))')
 helper='\n'+(HERE/'trmc_helpers.bend').read_text();added.append(dict(offset=len(candidate),old='',new=helper));candidate+=helper
 inverse=candidate
 for row in reversed(added):
  at=row['offset'];assert inverse[at:at+len(row['new'])]==row['new'];inverse=inverse[:at]+row['old']+inverse[at+len(row['new']):]
 assert inverse==original
 for row in reversed(parent['changes']):
  at=row['offset'];assert inverse[at:at+len(row['new'])]==row['new'];inverse=inverse[:at]+row['old']+inverse[at+len(row['new']):]
 assert inverse==Path(parent['source']['file']).read_text()
 out.mkdir(parents=True);(out/'compiler.bend').write_text(candidate)
 report=dict(kind='phase102-generic-boxed-final-field-trmc-source',complete=True,targetsRun=False,releaseQualified=False,
  source=parent['source'],parentCandidate=parent['candidate'],parentRecipe=pin(a.parent),method=pin(__file__),helper=pin(HERE/'trmc_helpers.bend'),
  candidate=pin(out/'compiler.bend'),changes=parent['changes']+added,addedChanges=added,inverseExact=True,inverseToParentExact=True,
  physicalLineDelta=len(candidate.splitlines())-len(original.splitlines()),byteDelta=len(candidate.encode())-len(original.encode()),
  scope='Retry only NF rejection non-tail-self, 1..8 args and <=512 body nodes. Final-field direct self call under boxed Con/SCon/user constructor with2..8 fields; prefix and recursive arguments evaluated in original ordered lets. Existing NF readiness rejects dynamic/foreign/parallel/mutual calls. Private two-word root/hole state never escapes; wrapper cleans failed partial root and returns unchanged one-Term ABI. Original scheduler/device fallback retained. No production source edits or targets.')
 (out/'changes.json').write_text(json.dumps(report,indent=2)+'\n');print(json.dumps(dict(candidate=report['candidate'],physicalLineDelta=report['physicalLineDelta'],byteDelta=report['byteDelta'])))


if __name__=='__main__':main()
