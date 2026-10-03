#!/usr/bin/env python3
"""Replace only unexecuted inherited-tree instruments, preserving a frozen executed prefix."""
import argparse,copy,hashlib,json
from pathlib import Path
ROOT=Path(__file__).resolve().parents[5]
def ident(p):
 p=Path(p).resolve();raw=p.read_bytes();return dict(file=str(p),sha256=hashlib.sha256(raw).hexdigest(),bytes=len(raw))
def main():
 p=argparse.ArgumentParser(description=__doc__)
 p.add_argument('parent',type=Path);p.add_argument('out',type=Path)
 for name in ['derive','controls','closure','review']:p.add_argument('--'+name,type=Path,required=True)
 a=p.parse_args();assert not a.out.exists();old=json.loads(a.parent.read_text());r=copy.deepcopy(old)
 assert r['kind']=='phase42-materialized-final-integration-recipe' and r['bound'] and r['complete'] and not r['executed']
 review=json.loads(a.review.read_text());assert review['complete'] and review['staticReviewPassed']
 if 'selectedAttemptSha256' in review:assert review['selectedAttemptSha256']==r['candidateBinding']['attempt']['sha256']
 names=r['stages']['semantic'];cut=names.index('phase41-tree-derive');assert cut==44 and names[cut-1]=='expanded-applications'
 replacements={
 'phase41-tree-derive':('selfhost/tools/performance/phase41/tree/actual-derive-v2.mjs',a.derive),
 'phase41-tree-control':('selfhost/tools/performance/phase41/tree/actual-controls.mjs',a.controls),
 'close-phase41':('selfhost/tools/performance/phase42/validation/close-phase41-v1.py',a.closure)}
 for step in r['steps']:
  if step['name'] in replacements:
   before,after=replacements[step['name']];assert step['argv'].count(before)==1;step['argv']=[str(after.resolve()) if x==before else x for x in step['argv']]
 changed=[x['name'] for x,y in zip(r['steps'],old['steps']) if x!=y];assert set(changed)==set(replacements)
 assert [x for x in r['steps'] if x['name'] in names[:cut]]==[x for x in old['steps'] if x['name'] in names[:cut]]
 pinned={x['path']:x for x in r['toolInputs']}
 for f in [a.derive,a.controls,a.closure,Path(__file__)]:
  row=ident(f);pinned[row['file']]=dict(path=row['file'],sha256=row['sha256'],bytes=row['bytes'])
 r['toolInputs']=list(pinned.values())
 r['inheritedTreeRebinding']=dict(kind='phase42-unexecuted-inherited-tree-instrumentation-successor',parent=ident(a.parent),producer=ident(__file__),review=ident(a.review),changedSteps=changed,preservedSemanticPrefix=names[:cut],resumeSteps=names[cut:],sameOutput=True,sameSelectedImage=True,scope='Only inherited tree derivation/controller/closure executables differ; all owner requirements, outputs, selected identities, original materialization and executed-prefix commands remain identical.')
 assert r['bindings']==old['bindings'] and r['candidateBinding']==old['candidateBinding'] and r['newOwnerRequirements']==old['newOwnerRequirements'] and r['materialization']==old['materialization']
 a.out.write_text(json.dumps(r,indent=2)+'\n');print(json.dumps(dict(complete=True,executed=False,recipe=ident(a.out),preservedPrefixSteps=cut,resumeSteps=names[cut:])))
if __name__=='__main__':main()
