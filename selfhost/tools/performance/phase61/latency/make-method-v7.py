#!/usr/bin/env python3
"""Data-only method06: one exact historical workflow input resolved to verified frozen bytes."""
import argparse,ast,hashlib,json
from pathlib import Path
HERE=Path(__file__).resolve().parent;ROOT=HERE.parents[4];RAW=ROOT/'selfhost/build/phase61'
p=argparse.ArgumentParser(description=__doc__);p.add_argument('out',type=Path);a=p.parse_args()
out=a.out.resolve();assert out.is_relative_to(RAW.resolve()) and not out.exists()
parent=RAW/'latency-method05'
pins={'run.py':'cf24d54c211331f270610c27d4e0a145a17a725f9e0099d0690a664e90fdb696',
'worker.mjs':'f81f4df0cddcfa0e362f5d2b7b482c8fe9024db1759eadb3439ed2497d361ad7',
'setup.mjs':'a2aa8c42eef576aaba85c978a777f6b5dd1907a8990e918646797e50adbbdfc8',
'profile.mjs':'f71444b4ab44ee49036d1cb70f06b6da9e28e71500619dbb378183ad3e26407b'}
def identity(p):
 p=Path(p).resolve(strict=True);return dict(file=str(p),sha256=hashlib.sha256(p.read_bytes()).hexdigest())
emission=identity(ROOT/'selfhost/build/phase58/final-last01/bootstrap/full/report.json')
assert emission['sha256']=='d952025b0cacfa72b56f074b53df0e2a5fa3e8bbd3c844108f335f1704c3a99a'
frozen=identity(ROOT/'selfhost/build/phase58/checked-last01/snapshot/tools/development/workflow.mjs')
assert frozen['sha256']=='1158d3e7fb28ebcf37caba0d32f34cbcb762d0987bff472c385a375bbeb793ff'
outputs={};rows=[]
for name,sha in pins.items():
 before=identity(parent/name);assert before['sha256']==sha;text=(parent/name).read_text();edits=[]
 def edit(old,new,count=1):
  global text
  assert text.count(old)==count,(name,old[:100],text.count(old),count)
  text=text.replace(old,new);edits.append(dict(old=old,new=new,count=count))
 count=text.count(str(parent))
 if count:edit(str(parent),str(out),count)
 if name=='setup.mjs':
  edit('const inputs=[],copies=[],seen=new Map(),attempts=new Map();','const inputs=[],copies=[],historicalMappings=[],seen=new Map(),attempts=new Map();')
  edit('    for(const x of e.inputs)pin(x);pin(e.producer);pin(e.config);pin(e.progress);', '''    for(const x of e.inputs) {
      // Exactly one historical audit dependency, never executed compiler bytes.
      const logical=path.join(root,'selfhost/tools/development/workflow.mjs');
      const oldSha='1158d3e7fb28ebcf37caba0d32f34cbcb762d0987bff472c385a375bbeb793ff';
      if(id.file===path.join(root,'selfhost/build/phase58/final-last01/bootstrap/full/report.json')&&
         id.sha256==='d952025b0cacfa72b56f074b53df0e2a5fa3e8bbd3c844108f335f1704c3a99a'&&
         x.file===logical&&x.sha256===oldSha) {
        assert.equal(generator.attemptId.file,path.join(root,'selfhost/build/phase58/checked-last01/attempt.json'));
        const frozenPath=path.join(root,'selfhost/build/phase58/checked-last01/snapshot/tools/development/workflow.mjs');
        const matches=generator.attempt.snapshot.sources.filter(row=>row.original.file===logical&&
          row.original.canonicalPath===logical&&row.original.sha256===oldSha&&
          row.frozen.file===frozenPath&&row.frozen.canonicalPath===frozenPath&&row.frozen.sha256===oldSha);
        assert.equal(matches.length,1,'Missing exact verified historical source mapping');
        const actual=pin(matches[0].frozen);
        historicalMappings.push({emission:id,logical:x,actual,scope:'Historical audit dependency only; current executed workflow is pinned independently'});
      } else pin(x);
    }
    pin(e.producer);pin(e.config);pin(e.progress);''')
  edit('return {api,D,subject:selected.subject,inputs,copies,image,project,verifyFinal};','return {api,D,subject:selected.subject,inputs,copies,historicalMappings,image,project,verifyFinal};')
 if name=='worker.mjs':
  edit('report.inputs=staged.inputs;report.copies=staged.copies;','report.inputs=staged.inputs;report.copies=staged.copies;report.historicalMappings=staged.historicalMappings;')
  edit('report.preparation=request.preparation;report.image=prep.image;report.sample=request.sample;','report.preparation=request.preparation;report.image=prep.image;report.sample=request.sample;report.historicalMappings=prep.historicalMappings??[];')
 if name=='run.py':ast.parse(text)
 outputs[name]=text;rows.append(dict(parent=before,output=dict(file=str(out/name),sha256=hashlib.sha256(text.encode()).hexdigest()),edits=edits))
out.mkdir(parents=True)
for name,text in outputs.items():(out/name).write_text(text)
report=dict(kind='phase61-candidate-fast-loop-method',complete=True,dataOnly=True,targetExecuted=False,producer=identity(__file__),
 parentDerivation=identity(parent/'derivation.json'),derivations=rows,historicalRelocation=dict(emission=emission,
 logical=dict(file=str(ROOT/'selfhost/tools/development/workflow.mjs'),sha256=frozen['sha256']),actual=frozen),
 scope='Only exact Phase58 baseline emission/path/SHA historical workflow input maps to already-verified attempt snapshot row; original receipt retained and mapping reported. No executed API/runtime/source/cache relocation. Current execution tools pinned normally. All method05 gates/clocks/request counts retained.')
report['pass']=True;(out/'derivation.json').write_text(json.dumps(report,indent=2)+'\n')
print(json.dumps({n:identity(out/n) for n in [*outputs,'derivation.json']}))
