#!/usr/bin/env python3
"""Freeze only the successful disjoint consumer, retaining independent originals."""
import importlib.util,json,sys
from pathlib import Path
ROOT=Path(__file__).resolve().parents[5];HERE=Path(__file__).resolve().parent
def main():
 spec=importlib.util.spec_from_file_location('C',ROOT/'selfhost/tools/performance/phase131/prepare.py');C=importlib.util.module_from_spec(spec);spec.loader.exec_module(C)
 parent=ROOT/'selfhost/build/phase144/predicate-canonical-source01/manifest.json';pm=json.loads(parent.read_text());assert pm['complete']and C.pin(pm['source']['file'])==pm['source']
 assert pm['source']['sha256']=='31e1b13a8584130c6a6be67ef6e1f2a6a373433c9c5cac9e880fa3fe403e3ea2'
 before=Path(pm['source']['file']).read_text();old=C.blocks(before,combine=True)
 reference=HERE/'disjoint-reference-v01.bend';ref=C.blocks(reference.read_text(),combine=True)['p144ce_original_disjoint']
 assert C.norm(ref.replace('p144ce_original_disjoint','base_prefix_ctor_disjoint'))==C.norm(old['base_prefix_ctor_disjoint'])
 evidence=ROOT/'selfhost/build/phase144/existence-screen01/report.json';er=json.loads(evidence.read_text());assert er['complete']and len(er['rows'])==2
 control=ROOT/'selfhost/build/phase144/existence-controls01/report.json';assert json.loads(control.read_text())['complete']
 modules=[HERE/'core-v01.bend',reference,HERE/'controls-v02.bend',HERE/'disjoint-override-v01.bend']
 text,added,protected=C.compose(before,[p.read_text()for p in modules],{'base_prefix_ctor_disjoint'},set())
 current=C.blocks(text,combine=True);changed=[n for n in old if C.norm(old[n])!=C.norm(current[n])]
 assert changed==['base_prefix_ctor_disjoint']
 for n in set(pm['protectedDeclarations'])|set(pm['unchangedProofDeclarations'])|{'constructor_exists','constructor_names','event_error'}:
  assert C.norm(old[n])==C.norm(current[n]),n
 out=ROOT/'selfhost/build/phase144/existence-disjoint-source01';assert not out.exists();out.mkdir()
 source=out/'compiler.bend';source.write_text(text)
 for i,p in enumerate(modules):(out/f'module{i}.bend').write_bytes(p.read_bytes())
 report=dict(kind='phase144-prefix-disjoint-only-candidate',complete=True,checked=False,targetsRun=False,selected=False,nativeQualified=False,
  source=C.pin(source),parent=pm['source'],parentManifest=C.pin(parent),added=added,overrides=changed,
  protectedDeclarations=pm['protectedDeclarations'],unchangedProofDeclarations=pm['unchangedProofDeclarations'],
  allOtherOriginalDeclarationsNormalizedExact=True,independentOriginalTraversalSourceBridge=True,
  controls=27,sourcePhysicalLineDelta=len(text.splitlines())-len(before.splitlines()),
  inputs=[C.pin(__file__),C.pin(C.__file__),C.pin(parent),pm['source'],C.pin(evidence),C.pin(control),*[C.pin(p)for p in modules]],
  scope='Only base_prefix_ctor_disjoint changes. Event/name guards and constructor_exists remain original. Independent renamed original traversal prevents post-override control tautology. Hosted consumer win is not a native/full-compiler claim.')
 (out/'manifest.json').write_text(json.dumps(report,indent=2)+'\n')
 api=ROOT/'selfhost/build/phase111/p144-existence-disjoint-api01';finite=ROOT/'selfhost/build/phase144/existence-disjoint-controls01'
 guard=ROOT/'selfhost/tools/performance/phase111/guard.py';checker=ROOT/'selfhost/tools/performance/phase111/check-api.py';bun=ROOT/'selfhost/.bootstrap/bun-1.4.3/bun'
 jobs=[]
 def job(name,command,seconds):jobs.append(dict(name=name,seconds=seconds+20,command=[sys.executable,'-B',str(guard),'--out',str(out/(name+'-guard')),'--seconds',str(seconds),'--cpu','3','--rss-mib','3072','--available-mib','16384','--file-mib','128','--',*map(str,command)]))
 exports=['p88_cache_prepare','p86_plan','p134e_plan','p134e_begin','p134e_next','p144ce_controls']
 job('checked-api',[sys.executable,'-B',checker,'--source',source,'--out',api,*exports],120)
 job('27-independent-controls',[bun,ROOT/'selfhost/tools/performance/phase143/controls-v01.mjs',api/'report.json',finite,'p144ce_controls:27:suffix'],30)
 oracle=ROOT/'selfhost/build/phase144/predicate-byte-candidate01/report.json';orr=json.loads(oracle.read_text());assert orr['complete']and pm['source']in orr['inputs']
 parentApi=ROOT/'selfhost/build/phase111/p144-integrated-api03/report.json';assert C.pin(parentApi)in orr['inputs']
 for case in orr['cases']:
  assert case['verified']and C.pin(case['source']['file'])==case['source']and C.pin(case['qbe']['file'])==case['qbe']
  job('hosted-'+case['name'],[sys.executable,'-B',ROOT/'selfhost/tools/performance/phase144/hosted-request-v01.py','--api-report',api/'report.json','--compiler-source',source,'--source',case['source']['file'],'--carrier-receipt',ROOT/'selfhost/build/phase130/base-carrier01/receipt.json','--expected-qbe',case['qbe']['file'],'--out',ROOT/'selfhost/build/phase144'/('existence-disjoint-hosted-'+case['name']),'--seconds','70'],85)
 (out/'jobs.json').write_text(json.dumps(dict(complete=True,targetsRun=False,inputs=[C.pin(out/'manifest.json'),C.pin(oracle),C.pin(parentApi)],jobs=jobs),indent=2)+'\n')
 print(json.dumps(dict(complete=True,targetsRun=False,source=C.pin(source),added=len(added),changes=changed,plan=str(out/'jobs.json'))))
if __name__=='__main__':main()
