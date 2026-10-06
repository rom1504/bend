#!/usr/bin/env python3
"""Data-only frozen Phase56 method successors; no compiler execution."""
import hashlib,json,sys
from pathlib import Path
sys.dont_write_bytecode=True
HERE=Path(__file__).resolve().parent;NEW=HERE.parent;OLD=NEW.parent/'phase56';rows=[]
def ident(p):return dict(file=str(p.resolve()),sha256=hashlib.sha256(p.read_bytes()).hexdigest())
def derive(relative,target,edits,marker=None):
 p=OLD/relative;t=NEW/target;s=p.read_text();before=s
 for old,new in edits:assert old in s,(relative,old);s=s.replace(old,new)
 assert not t.exists();t.parent.mkdir(parents=True,exist_ok=True);t.write_text(s)
 row=dict(parent=ident(p),output=ident(t),edits=[dict(old=x,new=y)for x,y in edits])
 if marker:assert before[before.index(marker):]==s[s.index(marker):];row['oracleTailByteIdentical']=True;row['oracleTailSha256']=hashlib.sha256(before[before.index(marker):].encode()).hexdigest()
 rows.append(row)
phase=[('selfhost/build/phase56','selfhost/build/phase58')]
derive('bootstrap/prepare-candidate.py','bootstrap/prepare-candidate.py',phase+[("'Phase56 candidate own-source generation", "'Phase58 candidate own-source generation")])
derive('bootstrap/setup-v2.mjs','bootstrap/setup.mjs',phase+[("Fresh output must be inside Phase56","Fresh output must be inside Phase58")])
derive('bootstrap/reproduce-v2.mjs','bootstrap/reproduce.mjs',phase+[("'./setup-v2.mjs'","'./setup.mjs'")])
setup=[("'../bootstrap/setup-v2.mjs'","'../bootstrap/setup.mjs'")]
derive('qualification/self-check-v2.mjs','qualification/self-check.mjs',setup+[
 ('assert.equal(definitions.length,3012);assert.equal(new Set(definitions).size,3012);','assert(definitions.length>0);assert.equal(new Set(definitions).size,definitions.length);'),
 ("method:'Every one of the exact checked assembly\\'s 3012 unique def declarations is explicitly annotated @unsafe.',definitions:3012,explicitlyUnsafe:3012", "method:'Every unique def in the exact selected checked assembly is explicitly annotated @unsafe; count is derived from that pinned source.',definitions:definitions.length,explicitlyUnsafe:explicitlyUnsafe.length")])
derive('qualification/acquire-v2.mjs','qualification/acquire.mjs',setup)
derive('qualification/benchmark-equality.mjs','qualification/benchmark-equality.mjs',setup)
derive('qualification/image-provenance-v2.mjs','qualification/image-provenance.mjs',[('../../../../build/phase56','../../../../build/phase58'),('Caches must stay in Phase56','Caches must stay in Phase58')])
for name in ['source','numeric','composition','overapplication']:
 derive('qualification/'+name+'-controls-v2.mjs','qualification/'+name+'-controls.mjs',[("'./image-provenance-v2.mjs'","'./image-provenance.mjs'")], '  for(const test of c.tests){'if name=='source'else ' function execute(')
derive('qualification/plan-v2.py','qualification/b2-plan.py',phase+[("here/'acquire-v2.mjs'","here/'acquire.mjs'"),("here/'image-provenance-v2.mjs'","here/'image-provenance.mjs'"),("here/'controls-derivation-v2.json'","here/'b2-methods-derivation.json'"),("here.parent/'bootstrap/setup-v2.mjs'","here.parent/'bootstrap/setup.mjs'"),("pin(here/'plan.py')","pin(tools/'phase56/qualification/plan-v2.py')"),("here/(name+'-controls-v2.mjs')","here/(name+'-controls.mjs')")])
result=dict(kind='phase58-inherited-b2-methods',complete=True,dataOnly=True,targetExecuted=False,producer=ident(Path(__file__)),rows=rows,scope='Frozen Phase56 generation/admission/reproduction and independent oracle methods. Fresh Phase58 private paths and setup imports only, except self-check derives the unique unsafe-def set/count from the exact selected checked source rather than hardcoding3012. All four semantic oracle tails remain byte-identical. Inherited phase labels identify method schemas, not historical execution.')
for row in rows:assert ident(Path(row['parent']['file']))==row['parent']and ident(Path(row['output']['file']))==row['output']
with(HERE/'b2-methods-derivation.json').open('x')as f:json.dump(result,f,indent=2);f.write('\n')
print(json.dumps(dict(targetExecuted=False,outputs=len(rows))))
