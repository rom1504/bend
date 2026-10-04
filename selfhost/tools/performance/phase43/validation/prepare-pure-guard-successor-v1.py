#!/usr/bin/env python3
"""Derive exact reviewed purity-guard recipe/mapping successors; execute no target."""
import argparse,copy,hashlib,json
from pathlib import Path
ROOT=Path(__file__).resolve().parents[5]
def ident(p):
 p=Path(p).resolve();return dict(file=str(p),sha256=hashlib.sha256(p.read_bytes()).hexdigest(),bytes=p.stat().st_size)
def read(p):return json.loads(Path(p).read_text())
def write(p,d):
 assert not p.exists(),str(p);p.parent.mkdir(parents=True,exist_ok=True);p.write_text(json.dumps(d,indent=2)+'\n')
def main():
 ap=argparse.ArgumentParser(description=__doc__)
 for k in ['parent','review','tools','guard-out','recipe']:ap.add_argument('--'+k,type=Path,required=True)
 a=ap.parse_args();r=read(a.parent);review=read(a.review);assert review['complete'] and review['staticReviewPassed']
 controller=ident(review['controller']['file']);assert controller['sha256']==review['controller']['sha256']
 controller_derivation=ident(review['controllerDerivation']['file']);assert controller_derivation['sha256']==review['controllerDerivation']['sha256']
 cd=read(controller_derivation['file']);assert cd['complete'] and cd['controller']['sha256']==controller['sha256'] and Path(cd['controller']['file']).resolve()==Path(controller['file'])
 out=Path(r['bindings']['OUT']);plan=Path(r['bindings']['PLAN']);planfile=plan/'plan.json';p=read(planfile)
 assert p['attempt']['sha256']==r['candidateBinding']['attempt']['sha256'] and p['api']==r['candidateBinding']['api']
 row=next(x for x in p['commands'] if x['name']=='owner-pure-guards');argv=row['supervisedCommand'].copy()
 oldcontroller=str(ROOT/'selfhost/tools/performance/phase35/region-pure-guards.mjs');oldout=str(plan/'owner/pure-guards');oldrun=str(plan/'run-owner-pure-guards')
 assert argv.count(oldcontroller)==argv.count(oldout)==argv.count(oldrun)==1
 assert argv[argv.index('--seconds')+1]=='180' and argv[argv.index('--rss-mib')+1]=='2048' and argv[argv.index('--available-mib')+1]=='2048'
 assert not a.guard_out.exists() and a.guard_out.resolve().is_relative_to(out)
 argv=[controller['file'] if s==oldcontroller else str(a.guard_out.resolve()) if s==oldout else str(out/'run-pure-guards-successor01') if s==oldrun else s for s in argv]
 oldmapping=Path(next(x for x in r['steps'] if x['name']=='map-current-owners')['argv'][1]);text=oldmapping.read_text()
 insertion="""  oldPure=str(Path(b['PLAN'])/'owner/pure-guards/report.json')
  assert mapping['cases']['pure-graph']==[oldPure,str(Path(b['PLAN'])/'owner/colf/report.json')],'exact prior pure graph pair'
  replacement=[NEW_PURE,str(Path(b['PLAN'])/'owner/colf/report.json')]
  changes.append(dict(case='pure-graph',before=mapping['cases']['pure-graph'],after=replacement));mapping['cases']['pure-graph']=replacement
""".replace('NEW_PURE',repr(str(a.guard_out.resolve()/'report.json')))
 before="  target=out/'owner-reports.json'";assert text.count(before)==1;text=text.replace(before,insertion+before)
 tools=a.tools.resolve();tools.mkdir(parents=True,exist_ok=False);original=tools/'original-materialize-mapping-v2.py';original.write_bytes(oldmapping.read_bytes())
 mapper=tools/'materialize-mapping-v3.py';mapper.write_text(text)
 write(mapper.with_suffix('.json'),dict(kind='phase43-reviewed-purity-mapping-derivation',complete=True,executed=False,parent=ident(oldmapping),original=ident(original),derived=ident(mapper),producer=ident(__file__),review=ident(a.review),changes=[dict(before=before,after=insertion+before,count=1)]))
 recipe=copy.deepcopy(r);oldrecipe=str(a.parent.resolve());newrecipe=str(a.recipe.resolve());prior_owner_step=None
 for step in recipe['steps']:
  step['argv']=[newrecipe if s==oldrecipe else s for s in step.get('argv',[])]
  if step['name']=='map-current-owners':assert step['argv']==['python3',str(oldmapping),newrecipe,'current'];step['argv'][1]=str(mapper)
  if step['name']=='remaining-phase35-owners':
   prior_owner_step=copy.deepcopy(step)
   step['argv']=['python3',str(ROOT/'selfhost/tools/performance/phase40/selected-plan-run.py'),str(plan),'--stage','owner','--skip','owner-counters','--skip','owner-recursive-folds','--skip','owner-close','--start','owner-colf-cohort','--out',str(out/'owner-launch-continuation01')]
   step['note']='Resume only the two unrun groups; prior21 passed owner commands and failed pure guard launch remain immutable.'
 assert prior_owner_step
 newstep=dict(name='phase43-pure-guards-successor',argv=argv,lockOwner=True,note='Reviewed literal0-domain successor; all other prior purity/refusal controls retained.')
 index=next(i for i,s in enumerate(recipe['steps']) if s['name']=='map-current-owners');recipe['steps'].insert(index,newstep)
 index=recipe['stages']['semantic'].index('map-current-owners');recipe['stages']['semantic'].insert(index,newstep['name'])
 pins=[ident(__file__),ident(a.parent),ident(a.review),controller,ident(planfile),ident(oldmapping),ident(oldmapping.with_suffix('.json')),ident(original),ident(mapper),ident(mapper.with_suffix('.json'))]
 pins.append(controller_derivation)
 existing={row['path']:row for row in recipe['toolInputs']}
 for row in pins:existing[row['file']]=dict(path=row['file'],sha256=row['sha256'],bytes=row['bytes'])
 recipe['toolInputs']=list(existing.values())
 launch=read(out/'owner-launch/report.json');assert launch['error'] and launch['steps'][-1]['name']=='owner-pure-guards' and not launch['steps'][-1]['complete']
 completed=[x['name'] for x in launch['steps'] if x['complete']];assert len(completed)==21
 unrun=[x for x in launch['selectedNames'] if x not in [s['name'] for s in launch['steps']]];assert unrun==['owner-colf-cohort','owner-colf']
 recipe['pureGuardSuccessor']=dict(kind='phase43-frozen-purity-recipe-successor',complete=True,executed=False,parent=ident(a.parent),review=ident(a.review),producer=ident(__file__),controller=controller,controllerDerivation=controller_derivation,mapping=ident(mapper),failedLaunch=ident(out/'owner-launch/report.json'),completedOwnerCommands=completed,remainingOwnerCommands=unrun,priorOwnerStep=prior_owner_step,freshGuardOutput=str(a.guard_out.resolve()),policy='Preserve original21 successful groups, failed raw and frozen plan. Exact two-group continuation plus reviewed purity controller replaces only pure-graph guard report. Completed frontend/fold/counter outputs remain unchanged and must be skipped on resume; all closure obligations retained.')
 write(a.recipe,recipe);print(json.dumps(dict(complete=True,executed=False,recipe=ident(a.recipe),mapping=ident(mapper),newStep=newstep)))
if __name__=='__main__':main()
