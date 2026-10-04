#!/usr/bin/env python3
"""Correct the single-file hybrid execution binding without changing its execution."""
import argparse,copy,hashlib,json
from pathlib import Path
ROOT=Path(__file__).resolve().parents[5]
def ident(p):
 p=Path(p).resolve();return dict(file=str(p),sha256=hashlib.sha256(p.read_bytes()).hexdigest(),bytes=p.stat().st_size)
def read(p):return json.loads(Path(p).read_text())
def main():
 ap=argparse.ArgumentParser(description=__doc__)
 for name in ['parent','review','preflight','recipe']:ap.add_argument('--'+name,type=Path,required=True)
 a=ap.parse_args();assert not a.recipe.exists();r=read(a.parent);review=read(a.review);scan=read(a.preflight);out=Path(r['bindings']['OUT'])
 assert review['complete'] and review['staticReviewPassed'] and review['producer']==ident(__file__)
 assert review['preflight']==ident(a.preflight) and scan['complete'] and not scan['executedTargets']
 assert len(scan['checks'])==643 and scan['issues']==[{'owner':'actual-hybrid','invariant':'exact execution output','pass':False}]
 assert Path(scan['recipe']).resolve()==a.parent.resolve()
 spec=next(s for s in r['newOwnerRequirements'] if s['name']=='actual-hybrid');assert 'executionOutput' not in spec
 report=Path(spec['report']);execution=Path(spec['execution']);e=read(execution)
 assert report==out/'hybrid-controls-successor01.json' and e['complete'] and e['returncode']==0 and not e.get('stoppedFor')
 assert str(report) in e['command'] and str(report.parent) not in e['command']
 assert review['report']==ident(report) and review['execution']==ident(execution)
 failed=out.parent/'final-jobs01/final-semantic11-close-phase42/run.json';job=read(failed);stderr=failed.parent/'stderr.log'
 oldClose=next(s for s in r['steps'] if s['name']=='close-phase42')
 assert job['command']==oldClose['argv'] and job['returncode']==1 and job['complete'] is False
 assert job['stderr']==ident(stderr) and 'Execution must consume exact report output path' in stderr.read_text()
 assert review['failedJob']==ident(failed) and review['failedStderr']==ident(stderr)
 assert not (out/'phase42-close-successor01/report.json').exists() and not (out/'phase42-close-successor02').exists()
 recipe=copy.deepcopy(r);next(s for s in recipe['newOwnerRequirements'] if s['name']=='actual-hybrid')['executionOutput']='file'
 for s in recipe['steps']:
  s['argv']=[str(a.recipe.resolve()) if x==str(a.parent.resolve()) else x for x in s.get('argv',[])]
  if s['name']=='close-phase42':
   before=str(out/'phase42-close-successor01/report.json');assert s['argv'].count(before)==1;s['argv'][s['argv'].index(before)]=str(out/'phase42-close-successor02/report.json')
 pins=[ident(p) for p in [__file__,a.parent,a.review,a.preflight,report,execution,failed,stderr]]
 inputs={x['path']:x for x in recipe['toolInputs']}
 for row in pins:inputs[row['file']]=dict(path=row['file'],sha256=row['sha256'],bytes=row['bytes'])
 recipe['toolInputs']=list(inputs.values());assert recipe['selectedOwners']==r['selectedOwners'] and len(recipe['selectedOwners'])==34
 recipe['executionOutputSuccessor']=dict(kind='phase43-exact-file-execution-binding-successor',complete=True,executed=False,parent=ident(a.parent),producer=ident(__file__),review=ident(a.review),preflight=ident(a.preflight),report=ident(report),execution=ident(execution),failedJob=ident(failed),failedStderr=ident(stderr),changes=[dict(owner='actual-hybrid',field='executionOutput',before='directory default',after='file')],scope='Exact file output already consumed by the successful unchanged hybrid controller. All semantic/assertion/producer/resource/image bindings remain unchanged; failed aggregation evidence retained. Remaining audit stages must still run.')
 a.recipe.parent.mkdir(parents=True,exist_ok=True);a.recipe.write_text(json.dumps(recipe,indent=2)+'\n');print(json.dumps(dict(complete=True,executed=False,recipe=ident(a.recipe))))
if __name__=='__main__':main()
