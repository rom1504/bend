#!/usr/bin/env python3
"""Verify a checked attempt and derive fresh Phase42 commands; execute no campaign."""
import argparse
import copy
import hashlib
import json
from pathlib import Path
import subprocess

ROOT = Path(__file__).resolve().parents[5]
PIN = '018751270e800bc222a93dad7f257083ee53a5f7'
PARENT = ROOT/'selfhost/build/phase41/integration01/recipe03.json'
PARENT_SHA = '62f2862307598580bd9f16e215da38d44e4b4d7e2e27cc6cdce05f3210ee2267'
PINS = {
 'selfhost/tools/performance/phase41/validation/derive-frontend.py': '64013139992ad747b7cc1f88324c57bf02d0b9ce7f3f7fa3c9a040968ab317f7',
 'selfhost/tools/performance/phase41/validation/derive-integration.py': '636b1d71953c57bb53d4d6de3c03f1ddc7f941eaab78b7fdf555c3f61f64c557',
}

def ident(file):
 file=Path(file).resolve()
 return dict(path=str(file),sha256=hashlib.sha256(file.read_bytes()).hexdigest(),bytes=file.stat().st_size)

def main():
 p=argparse.ArgumentParser(description=__doc__)
 p.add_argument('--attempt',type=Path,required=True)
 p.add_argument('--out',type=Path,required=True,help='Fresh campaign directory, created by root later')
 p.add_argument('--recipe',type=Path,required=True,help='Fresh recipe file outside campaign directory')
 a=p.parse_args(); attempt=a.attempt.resolve(); out=a.out.resolve(); dest=a.recipe.resolve()
 assert not out.exists() and not dest.exists()
 assert ident(PARENT)['sha256']==PARENT_SHA
 parent=json.loads(PARENT.read_text()); assert parent['bound'] and parent['complete'] and not parent['executed']
 manifest=json.loads((attempt/'attempt.json').read_text())
 assert manifest['checked'] and manifest['kind']=='bend-development-attempt'
 node=manifest['node']['file']; upstream=Path(manifest['config']['upstream']).resolve()
 assert upstream==ROOT/'selfhost/.bootstrap/upstream-phase23'
 assert subprocess.check_output(['git','-C',str(upstream),'rev-parse','HEAD'],text=True).strip()==PIN
 assert ident(node)['sha256']==manifest['node']['sha256'] and manifest['node']['version']=='v24.18.0'
 # The maintained verifier checks frozen sources, bootstrap, equality lineage,
 # Base, runtime, artifacts and host. No candidate target/compiler is run here.
 code="const w=await import(process.argv[1]); const m=await w.verifyAttempt(process.argv[2]); console.log(JSON.stringify({checked:m.checked,api:m.api}));"
 verified=json.loads(subprocess.check_output([node,'--input-type=module','-e',code,(ROOT/'selfhost/tools/development/workflow.mjs').as_uri(),str(attempt)],text=True))
 assert verified['checked'] and verified['api']==manifest['api']
 tool_inputs=[]
 for file,sha in PINS.items():
  row=ident(ROOT/file); assert row['sha256']==sha; tool_inputs.append(row)
 bindings=dict(ATTEMPT=str(attempt),OUT=str(out),NODE=node,UPSTREAM=str(upstream),DERIVED=str(out/'current-tools'),PLAN=str(out/'final-plan'),FULL=str(out/'full-preparation/manifest.json'),FULLDIR=str(out/'full-preparation'),HIST=str(out/'historical-preparation/manifest.json'))
 # Longest first handles nested bindings without rebinding an already rewritten path.
 replacements=sorted([(v,bindings[k]) for k,v in parent['bindings'].items() if v!=bindings[k]],key=lambda x:len(x[0]),reverse=True)
 changes=[]
 recipe=copy.deepcopy(parent)
 for step in recipe['steps']:
  if 'argv' not in step: continue
  for i,old in enumerate(step['argv']):
   new=old
   for before,after in replacements:
    if before in new: new=new.replace(before,after); break
   if step['name'] in ['prepare-cost-baseline','freeze-cost-plan'] and new=='selfhost/build/phase40/checked06': new='selfhost/build/phase41/checked01'
   if old!=new: changes.append(dict(step=step['name'],index=i,before=old,after=new))
   step['argv'][i]=new
 recipe.update(kind='phase42-bound-integration-command-recipe',bindings=bindings,parent=ident(PARENT),producer=ident(__file__),bound=True,complete=True,executed=False)
 recipe.pop('retryReason',None)
 recipe['candidateBinding']=dict(attempt=ident(attempt/'attempt.json'),api=manifest['api'],runtime=manifest['runtime'],base=manifest['base'],node=manifest['node'],upstreamCommit=PIN)
 recipe['changes']=changes
 recipe['toolInputs']=tool_inputs
 recipe['policy']['broadOnceOnFrozenRelease']=True
 def bounded(name,args):
  return dict(name=name,lockOwner=True,argv=['python3','selfhost/tools/performance/phase32/bounded-run.py','--seconds','120','--rss-mib','2048','--available-mib','2048',str(out/('run-'+name)),'--','taskset','-c','3',node,'--stack-size=4096','--max-old-space-size=1024',*args])
 extras=[
  bounded('phase41-tree-derive',['selfhost/tools/performance/phase41/tree/actual-derive-v2.mjs','selfhost/build/phase40/final-candidate02/modules/tree-bitonic.mjs',str(out/'full-preparation/modules/tree-bitonic.mjs'),'selfhost/build/phase37/typescript01/modules/tree-bitonic.mjs',str(attempt),str(out/'phase41-tree-derived')]),
  bounded('phase41-tree-control',['selfhost/tools/performance/phase41/tree/actual-controls.mjs',str(out/'phase41-tree-derived'),str(out/'phase41-tree-controls')]),
  bounded('phase41-wrapper-emit',['selfhost/tools/performance/programs/emit-worker.mjs',str(attempt),'selfhost/tools/performance/phase41/tree/wrapper-fixture-v2.bend',str(out/'phase41-wrapper.mjs')]),
  bounded('phase41-wrapper-control',['selfhost/tools/performance/phase41/tree/fixture-controls-v3.mjs','selfhost/build/phase41/wrapper-fixture02/baseline.mjs',str(out/'phase41-wrapper.mjs'),str(attempt),str(out/'phase41-wrapper-controls')]),
  dict(name='close-phase41',argv=['python3','selfhost/tools/performance/phase42/validation/close-phase41-v1.py',str(attempt),str(out),str(out/'phase41-close/report.json')]),
  dict(name='phase42-owner-admission',required='Root must add fresh checked-image controls and exact closure for each selected new mechanism; Phase41 saved-JS next-tuples ablation is not evidence of actual Phase42 emitter correctness.'),
 ]
 idx=next(i for i,s in enumerate(recipe['steps']) if s['name']=='audit-preinstall')
 recipe['steps'][idx:idx]=extras
 recipe['focusedSteps']=['actual-list-emit','actual-tree-emit','actual-list-derive','actual-list-control','actual-list-typescript','actual-tree-derive','actual-tree-control','actual-linear-acquire','actual-linear-control','phase41-wrapper-emit','phase41-wrapper-control']
 recipe['focusedPreparation']=dict(name='prepare-focused',lockOwner=True,argv=['python3','selfhost/tools/performance/programs/prepare.py','--catalog','selfhost/tools/performance/phase37/catalog.json','--attempt',str(attempt),'--cases','tree-bitonic,coverage-list-pipeline-128,coverage-list-pipeline-512','--out',str(out/'focused-preparation'),'--node',node,'--cpu','3','--heap-mib','1024','--rss-mib','2048','--available-mib','2048'])
 recipe['focusedTreeSteps']=[copy.deepcopy(s) for s in extras[:2]]
 for step in recipe['focusedTreeSteps']:
  step['argv']=[v.replace(str(out/'full-preparation'),str(out/'focused-preparation')) for v in step['argv']]
 # Collect identities of every available executable/fixture argument. Generated
 # tools are pinned by the historical derivation receipts when root derives them.
 pinned={row['path']:row for row in tool_inputs}
 for step in recipe['steps']:
  for arg in step.get('argv',[]):
   candidate=Path(arg); candidate=candidate if candidate.is_absolute() else ROOT/candidate
   if candidate.is_file() and candidate.suffix in ['.py','.mjs','.bend','.json']: pinned[str(candidate.resolve())]=ident(candidate)
 recipe['toolInputs']=list(pinned.values())
 dest.parent.mkdir(parents=True,exist_ok=True)
 dest.write_text(json.dumps(recipe,indent=2)+'\n')
 print(json.dumps(dict(complete=True,executed=False,recipe=ident(dest),attempt=recipe['candidateBinding']['attempt'],api=manifest['api'],steps=len(recipe['steps']))))

if __name__=='__main__': main()
