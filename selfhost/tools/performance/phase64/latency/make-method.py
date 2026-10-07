#!/usr/bin/env python3
"""Freeze the existing Phase63 method in Phase64, with immutable State09 audit tools."""
import argparse, ast, hashlib, json
from pathlib import Path
ROOT=Path(__file__).resolve().parents[5]
RAW=ROOT/'selfhost/build/phase64'
PARENT=ROOT/'selfhost/build/phase63/latency-method02'
AUDIT=ROOT/'selfhost/build/phase63/checked-state09/snapshot'

def identity(file):
    file=Path(file).resolve(strict=True)
    return dict(file=str(file),sha256=hashlib.sha256(file.read_bytes()).hexdigest())

p=argparse.ArgumentParser(description=__doc__);p.add_argument('out',type=Path);a=p.parse_args()
out=a.out.resolve();assert out.is_relative_to(RAW) and not out.exists()
parent=identity(PARENT/'derivation.json')
assert parent['sha256']=='5f8945ae9ad80327b356ace20e1811640956a06c4ac915ac0dc7a29ec8a00dc6'
manifest=json.loads((PARENT/'derivation.json').read_text())
parents={Path(r['output']['file']).name:r['output'] for r in manifest['derivations']}
texts={};rows=[]
for name in ['profile.mjs','setup.mjs','worker.mjs','run.py']:
    before=identity(PARENT/name);assert before==parents[name]
    text=(PARENT/name).read_text();edits=[]
    def edit(old,new,count=1):
        global text
        assert text.count(old)==count,(name,old,text.count(old),count)
        text=text.replace(old,new);edits.append(dict(old=old,new=new,count=count))
    if str(PARENT) in text:edit(str(PARENT),str(out),text.count(str(PARENT)))
    if name=='profile.mjs':edit(str(ROOT/'selfhost/build/phase63'),str(RAW))
    if name=='run.py':
        edit("ROOT/'selfhost/build/phase63'","ROOT/'selfhost/build/phase64'",3)
        edit("'213870c36e050ff2824cd8f7662463b849d777bea43cb7b53a771526b6dce6fc'",repr(hashlib.sha256(texts['profile.mjs'].encode()).hexdigest()))
        for rel in ['tools/development/workflow.mjs','tools/development/process.mjs','tools/conformance/inventory.mjs']:
            edit("ROOT/'selfhost/"+rel+"'","Path("+repr(str(AUDIT/rel))+")",2)
        edit("ROOT/'selfhost/tools'/f'{n}.mjs'","Path("+repr(str(AUDIT/'tools'))+")/f'{n}.mjs'",2)
        ast.parse(text)
    if name=='setup.mjs':
        edit("boundary=path.join(root,'selfhost/build/phase63')","boundary=path.join(root,'selfhost/build/phase64')")
        for rel,count in [('tools/development/workflow.mjs',2),('tools/development/process.mjs',1),('tools/conformance/inventory.mjs',1)]:
            edit(str(ROOT/'selfhost'/rel),str(AUDIT/rel),count)
        edit(".map(n=>path.join(root,'selfhost/tools',n+'.mjs'))", ".map(n=>path.join("+json.dumps(str(AUDIT/'tools'))+",n+'.mjs'))")
        old="      } else pin(x);"
        new="""      } else if(id.file===path.join(root,'selfhost/build/phase63/final-state09/bootstrap/full/report.json')&&
                id.sha256==='287ca58f72272c98e8ceec057b886c7f4d5cbb3927a2231225837c45affdaefb'&&x.file===logical) {
        assert.equal(generator.attemptId.sha256,'82379c94f3eec0bea44afb8a3c2ae8323de731dfa34c85da775d199ce4fb87cf');
        const frozenPath=path.join(generator.attempt.snapshot.root,'tools/development/workflow.mjs');
        const matches=generator.attempt.snapshot.sources.filter(row=>row.original.file===logical&&
          row.original.canonicalPath===logical&&row.original.sha256===x.sha256&&
          row.frozen.file===frozenPath&&row.frozen.canonicalPath===frozenPath&&row.frozen.sha256===x.sha256);
        assert.equal(matches.length,1,'Missing exact State09 historical source mapping');
        const actual=pin(matches[0].frozen);
        historicalMappings.push({emission:id,logical:x,actual,scope:'Exact State09 historical audit dependency; immutable executed audit workflow pinned separately'});
      } else pin(x);"""
        edit(old,new)
    texts[name]=text;rows.append(dict(parent=before,output=dict(file=str(out/name),sha256=hashlib.sha256(text.encode()).hexdigest()),edits=edits))
out.mkdir(parents=True)
for name,text in texts.items():(out/name).write_text(text)
report=dict(kind='phase61-candidate-fast-loop-method',complete=True,**{'pass':True},dataOnly=True,targetExecuted=False,
    producer=identity(__file__),parentDerivation=parent,derivations=rows,explicitCacheAdmission=manifest['explicitCacheAdmission'],
    immutableAuditSnapshot=str(AUDIT),scope='Only writable boundary/method paths and metadata-verifier import closure rebound. Exact selected State09 workflow audit input maps to byte-identical checked snapshot. Compiler images, clocks, raw output oracles, profile sampling and serial guards unchanged. No current working source is frozen.')
(out/'derivation.json').write_text(json.dumps(report,indent=2)+'\n')
print(json.dumps(dict(method=identity(out/'derivation.json'))))
