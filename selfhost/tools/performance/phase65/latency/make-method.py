#!/usr/bin/env python3
"""Rebind the frozen Phase64 method to Phase65, retaining exact historical audits."""
import argparse, ast, hashlib, json
from pathlib import Path
ROOT = Path(__file__).resolve().parents[5]
RAW = ROOT / 'selfhost/build/phase65'
PARENT = ROOT / 'selfhost/build/phase64/latency-method02'
PARENT_SHA = 'ae09809fdd723c77d60580e6fefece8ab9509a1f915d7b045a947374ad25843c'

def identity(file):
    file = Path(file).resolve(strict=True)
    return dict(file=str(file), sha256=hashlib.sha256(file.read_bytes()).hexdigest())

p = argparse.ArgumentParser(description=__doc__)
p.add_argument('out', type=Path)
a = p.parse_args()
out = a.out.resolve()
assert out.is_relative_to(RAW) and not out.exists()
parent = identity(PARENT/'derivation.json')
assert parent['sha256'] == PARENT_SHA
manifest = json.loads((PARENT/'derivation.json').read_text())
assert manifest['explicitCacheAdmission'] == dict(frameVersions=[1,2,3,4], decodedVersions=[4,6])
parents = {Path(r['output']['file']).name:r['output'] for r in manifest['derivations']}
texts, rows = {}, []
for name in ['profile.mjs','setup.mjs','worker.mjs','run.py']:
    before = identity(PARENT/name)
    assert before == parents[name]
    text = (PARENT/name).read_text()
    edits = []
    def edit(old, new, count=1):
        global text
        assert text.count(old) == count, (name,old,text.count(old),count)
        text = text.replace(old,new)
        edits.append(dict(old=old,new=new,count=count))
    count = text.count(str(PARENT))
    if count: edit(str(PARENT), str(out), count)
    if name == 'profile.mjs':
        edit(str(ROOT/'selfhost/build/phase64'), str(RAW))
    if name == 'run.py':
        edit("ROOT/'selfhost/build/phase64'", "ROOT/'selfhost/build/phase65'", 3)
        edit("'18263eefe79578ad15a70655740c587e5eb3ede99c1fa0c9cb9d585d8279f787'",
             repr(hashlib.sha256(texts['profile.mjs'].encode()).hexdigest()))
        ast.parse(text)
    if name == 'setup.mjs':
        edit("boundary=path.join(root,'selfhost/build/phase64')", "boundary=path.join(root,'selfhost/build/phase65')")
        edit("      } else pin(x);", """      } else if(id.file===path.join(root,'selfhost/build/phase64/bootstrap-state09/full/report.json')&&
                id.sha256==='291412c685835bdf02c843a754b57760f3b2d1363ef39a7571800157fe8983d0'&&x.file===logical) {
        assert.equal(generator.attemptId.sha256,'a2038c2223a20aa7b03130bc70727671dff5482f11f9fb0613069ccfa530868b');
        const frozenPath=path.join(generator.attempt.snapshot.root,'tools/development/workflow.mjs');
        const matches=generator.attempt.snapshot.sources.filter(row=>row.original.file===logical&&
          row.original.canonicalPath===logical&&row.original.sha256===x.sha256&&
          row.frozen.file===frozenPath&&row.frozen.canonicalPath===frozenPath&&row.frozen.sha256===x.sha256);
        assert.equal(matches.length,1,'Missing exact Phase64 State09 historical source mapping');
        const actual=pin(matches[0].frozen);
        historicalMappings.push({emission:id,logical:x,actual,scope:'Exact Phase64 State09 historical audit input mapped to byte-identical checked snapshot; independent verifier remains pinned'});
      } else pin(x);""")
    texts[name] = text
    rows.append(dict(parent=before,output=dict(file=str(out/name),sha256=hashlib.sha256(text.encode()).hexdigest()),edits=edits))
out.mkdir(parents=True)
for name,text in texts.items(): (out/name).write_text(text)
result = dict(kind='phase61-candidate-fast-loop-method',complete=True,**{'pass':True},dataOnly=True,targetExecuted=False,
    producer=identity(__file__),parentDerivation=parent,derivations=rows,
    explicitCacheAdmission=manifest['explicitCacheAdmission'],immutableAuditSnapshot=manifest['immutableAuditSnapshot'],
    scope='Only Phase65 writable boundary/method relocation, corresponding profile hash, and exact Phase64 State09 historical workflow mapping. '
          'Independent immutable audit modules, clocks, decoder-authoritative frame1/2/3/4 admission, raw oracles, profile sampling and guards unchanged.')
(out/'derivation.json').write_text(json.dumps(result,indent=2)+'\n')
print(json.dumps(dict(method=identity(out/'derivation.json'))))
