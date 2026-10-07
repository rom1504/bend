#!/usr/bin/env python3
"""Data-only method05: actual frame1/frame2 decoder and explicit optional export admission."""
import argparse, ast, hashlib, json
from pathlib import Path
HERE=Path(__file__).resolve().parent;ROOT=HERE.parents[4];RAW=ROOT/'selfhost/build/phase61'
p=argparse.ArgumentParser(description=__doc__);p.add_argument('out',type=Path);a=p.parse_args()
out=a.out.resolve();assert out.is_relative_to(RAW.resolve()) and not out.exists()
parent=RAW/'latency-method04-v2'
pins={'run.py':'51c830d111e6f8542c0606f3fbc49c0931ef7f0de6a0332e61b3c0489f239ba9',
'worker.mjs':'84d09d4ff531584d72645ce92cd5d7ecbe9716adfdb86b81b1b8cafef1ef50c9',
'setup.mjs':'71997aa4ffcf9d4d6a10a53c410e9d772734ba9e97bc4a1b598afc6822eac0df',
'profile.mjs':'f71444b4ab44ee49036d1cb70f06b6da9e28e71500619dbb378183ad3e26407b'}
def identity(file):
 file=Path(file).resolve(strict=True);return dict(file=str(file),sha256=hashlib.sha256(file.read_bytes()).hexdigest())
reference=identity(HERE.parent/'validation/setup-frame03.mjs')
assert reference['sha256']=='20e4207025f4081e28ebb84c33c461159fb7a8c686f8c3cb7a76094c9c8ce9f8'
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
  edit("const generator=await checked(spec.attempt);", """const generator=await checked(spec.attempt);
    // Optional explicit admission for supplementary exports. Old checked worlds
    // keep their genuine bootstrap roots; no fixed root count is imposed.
    assert.equal(Boolean(spec.admission),Boolean(spec.rootsReference));
    if(spec.admission) {
      const admission=read(spec.admission),reference=read(spec.rootsReference);
      assert.equal(admission.kind,'phase61-bootstrap-export-admission');assert.equal(admission.version,1);
      const driver=pin(admission.driver);
      assert.equal(pin(path.join(generator.attempt.snapshot.root,'tools/typed-driver.mjs')).sha256,driver.sha256);
      assert.equal(reference.kind,'phase61-checked-bootstrap-export-reference');
      assert.deepEqual(reference.admission,pin(spec.admission));
      assert.deepEqual(reference.attempt,generator.subject.attempt);
      assert.deepEqual(pin(reference.bootstrap),pin(generator.attempt.bootstrapReport));
      assert.deepEqual(reference.roots,generator.roots);
      const previous=read(reference.historical).roots;
      const baseAdded=['base_prefix_prepare','check_program_diagnostic_seed','f_fresh_prefix_prepare','f_graph_trace_from_prefix'];
      assert.ok(Array.isArray(previous)&&new Set(previous).size===previous.length);
      assert.ok(Array.isArray(admission.addedRoots)&&admission.addedRoots.every(x=>typeof x==='string'&&x));
      const added=[...baseAdded,...admission.addedRoots];
      assert.equal(new Set(added).size,added.length);assert.ok(added.every(x=>!previous.includes(x)));
      assert.deepEqual(reference.baseAddedRoots,[...baseAdded].sort());
      assert.deepEqual(reference.addedRoots,[...added].sort());
      assert.deepEqual(generator.roots.filter(x=>!added.includes(x)),previous);
      assert.deepEqual([...generator.roots].sort(),[...previous,...added].sort());
    }""")
  edit("const config=read(e.config);assert.deepEqual(config.subjectSource,subject.subject.source);", """const config=read(e.config);assert.deepEqual(config.subjectSource,subject.subject.source);
    if(spec.admission)assert.equal(pin(config.driver).sha256,read(spec.admission).driver.sha256);""")
  edit("path.basename(item.file).endsWith('-frame1.json')", "/-frame[12]\\.json$/.test(item.file)")
  edit("      assert.ok(c&&typeof c==='object'&&!Array.isArray(c));", "      assert.ok(c&&typeof c==='object'&&!Array.isArray(c));\n      if(framed)assert.ok([4,6].includes(c.version));")
 if name=='run.py':ast.parse(text)
 outputs[name]=text;rows.append(dict(parent=before,output=dict(file=str(out/name),sha256=hashlib.sha256(text.encode()).hexdigest()),edits=edits))
out.mkdir(parents=True)
for name,text in outputs.items():(out/name).write_text(text)
report=dict(kind='phase61-candidate-fast-loop-method',complete=True,pass_=True,dataOnly=True,targetExecuted=False,
 producer=identity(__file__),parentDerivation=identity(parent/'derivation.json'),reviewedAdmissionSetup=reference,derivations=rows,
 scope='Same reviewed method04-v2 stable-hash and first/later/profile protocol. Setup uses actual selected driver decoder for frame1/frame2; canonical JSON SHA is not substituted for framed raw bytes. Optional role admission/reference joins exact checked roots, historical order, supplementary roots and driver identity. No fixed root count or synthetic bootstrap metadata; old roles remain supported.')
report['pass']=report.pop('pass_');(out/'derivation.json').write_text(json.dumps(report,indent=2)+'\n')
print(json.dumps({name:identity(out/name) for name in [*outputs,'derivation.json']}))
