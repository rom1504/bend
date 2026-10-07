#!/usr/bin/env python3
"""Narrow successor: bounded relevant preflight and optional first-only clean screens."""
import argparse,ast,hashlib,json
from pathlib import Path
HERE=Path(__file__).resolve().parent;ROOT=HERE.parents[4]
p=argparse.ArgumentParser(description=__doc__);p.add_argument('out',type=Path);a=p.parse_args()
out=a.out.resolve();parent=ROOT/'selfhost/build/phase60/method01'
assert out.is_relative_to(ROOT/'selfhost/build/phase60') and not out.exists()
def identity(p):
 p=Path(p).resolve();b=p.read_bytes();return dict(file=str(p),sha256=hashlib.sha256(b).hexdigest(),bytes=len(b))
pins={'setup.mjs':'2f80b30229c9d189e5e1765aa3c1085e91c6249a039953e20b401fc5be257399',
 'profile.mjs':'5df8aed83fdd2e573a3989ffa4d8ebf1e26d995b0dbabea9031d28e59ead5313',
 'worker.mjs':'e1f4c4c839ed04a6de3865900f6a8e0d19cedfafbf3e12a226eacedec21c6f33',
 'worker-stages.mjs':'4292a3a27b742c1052401f54ba3a907f28abd8018d37e7cef953f6347b2c5e03',
 'run.py':'3cc0c42d31a8508c4cb6ef404ad4ad8b2feaa55d6d44917cc70fdcc680f4cef3',
 'bindings.json':'74d57e8e0f0605565679fbc0aa9357dc280ddfac1bea2a6353c48dc63da844d2'}
derivations=[];outputs={}
for name,sha in pins.items():
 before=identity(parent/name);assert before['sha256']==sha;text=(parent/name).read_text();edits=[]
 def edit(old,new,count=1):
  global text
  assert text.count(old)==count,(name,old[:100],text.count(old));text=text.replace(old,new);edits.append(dict(old=old,new=new,count=count))
 if str(parent) in text:edit(str(parent),str(out),text.count(str(parent)))
 if name.startswith('worker'):
  edit("    const bindings=[...(prep.inputs??[]),...(prep.copies??[]).map(x=>x.after),...(prep.verification?.cacheFiles??[])];", "    // The exact preparation receipt binds the once-audited historical lineage.\n    // Revalidate active staged bytes/cache, not unrelated historical compiler images.\n    const bindings=[...(prep.copies??[]).map(x=>x.after),...(prep.verification?.cacheFiles??[]),\n      ...(prep.image?[prep.image.api,prep.image.base,prep.image.runtime,prep.image.directRuntime,prep.image.driver]:[])];")
  edit("    const row=config.cases.find(x=>x.id===request.case);assert.ok(row);", "    const row=config.cases.find(x=>x.id===request.case);assert.ok(row);\n    const caseInputs=[row.source,...row.files,...row.emissionInputs,row.references[request.role]];check(caseInputs);")
  edit('    check(bindings);check(oldConfig.inputs);verify(prep.config);verify(request.preparation);verify(expected.output);', '    check(bindings);check(caseInputs);check(oldConfig.inputs);verify(prep.config);verify(request.preparation);verify(expected.output);')
  edit('    report.preflightMs=performance.now()-preflight;\n    let first;', "    report.preflightScope='Catalog and actual method hashes plus current source/imports/runtime/raw oracle, staged API/helpers/cache. Full historical qualification was joined once during preparation; preflight differs from Phase59 and remains excluded.';\n    report.preflightMs=performance.now()-preflight;\n    let first;")
 elif name=='run.py':
  edit('1<=a.warm_requests<=3','0<=a.warm_requests<=3')
  edit("cat=read(catalog);assert cat['kind']", "assert identity(catalog)['sha256']=='d5903c18804afa14b9ca4fc51196d1d419148989a9496e768822f6637004c9ba'\ncat=read(catalog);assert cat['kind']")
  edit("verify(cat['inputs'])", "if not a.preparations:verify(cat['inputs'])")
  old="]]+[x['source'] for x in cases]+[i for x in cases for i in [*x['files'],*x['emissionInputs'],*x['references'].values()]]"
  edit(old,"]]\ncase_inputs=[i for x in cases for i in [x['source'],*x['files'],*x['emissionInputs'],*x['references'].values()]]")
  edit(" prepareOnly=a.prepare_only,catalog=identity(catalog),", " prepareOnly=a.prepare_only,catalog=identity(catalog),catalogQualificationAuditedHere=not bool(a.preparations),")
  edit("values.update(warmRequestMedianMs=stats([statistics.median(x) for x in warm]),", "values.update(warmRequestMedianMs=stats([statistics.median(x) for x in warm]) if a.warm_requests else None,")
  # Avoid the generic replacement of the final inline conditional: make final checks explicit.
  edit("  verify(inputs);if not a.preparations:verify(cat['inputs']);report['complete']=True;report['pass']=not report['failures']", "  verify(inputs);verify(case_inputs)\n  if not a.preparations:verify(cat['inputs'])\n  report['complete']=True;report['pass']=not report['failures']")
  ast.parse(text)
 outputs[name]=text;derivations.append(dict(parent=before,output=dict(file=str(out/name),sha256=hashlib.sha256(text.encode()).hexdigest()),edits=edits))
result=dict(kind='phase60-survey-method-preflight-successor',complete=True,dataOnly=True,targetExecuted=False,producer=identity(__file__),
 parentDerivation=identity(parent/'derivation.json'),derivations=derivations,
 scope='Measured first/later and profile windows unchanged. Full retained qualification audit at preparation, then per-request relevant artifacts; excludes unrelated raw oracles/history. Optional warmRequests0 gives no later statistic. Failures remain visible and prevent PASS.')
out.mkdir(parents=True)
for name,text in outputs.items():(out/name).write_text(text)
(out/'derivation.json').write_text(json.dumps(result,indent=2)+'\n')
print(json.dumps({n:identity(out/n) for n in [*outputs,'derivation.json']}))
