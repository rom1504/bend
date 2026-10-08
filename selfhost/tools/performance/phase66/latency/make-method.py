#!/usr/bin/env python3
"""Rebind the frozen Phase65 method to Phase66, retaining exact historical audits."""
import argparse, ast, hashlib, json
from pathlib import Path
ROOT = Path(__file__).resolve().parents[5]
RAW = ROOT / 'selfhost/build/phase66'
PARENT = ROOT / 'selfhost/build/phase65/latency-method02'
PARENT_SHA = 'b94a251c003a773d1ad56e6f4a8137ea7cf49fb04af7f15ca6c546d674231044'

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
        edit(str(ROOT/'selfhost/build/phase65'), str(RAW))
    if name == 'run.py':
        edit("ROOT/'selfhost/build/phase65'", "ROOT/'selfhost/build/phase66'", 3)
        edit("'7729d127869d5dbf0211b3f62dc683b0e86800b0b896f4897056daee98bc4205'",
             repr(hashlib.sha256(texts['profile.mjs'].encode()).hexdigest()))
        ast.parse(text)
    if name == 'setup.mjs':
        edit("boundary=path.join(root,'selfhost/build/phase65')", "boundary=path.join(root,'selfhost/build/phase66')")
        edit("      } else pin(x);", """      } else if(id.file===path.join(root,'selfhost/build/phase65/bootstrap-state10/full/report.json')&&
                id.sha256==='89f5ac6c9c312e98c5f5079e19adbd4474f6f9251a3e12e5a8f3556d8743fe87'&&x.file===logical) {
        assert.equal(generator.attemptId.sha256,'34490671b8b88cc87617a9943f9892c1b209b77ca61ee0b6b2e0a13ad62852bf');
        const frozenPath=path.join(generator.attempt.snapshot.root,'tools/development/workflow.mjs');
        const matches=generator.attempt.snapshot.sources.filter(row=>row.original.file===logical&&
          row.original.canonicalPath===logical&&row.original.sha256===x.sha256&&
          row.frozen.file===frozenPath&&row.frozen.canonicalPath===frozenPath&&row.frozen.sha256===x.sha256);
        assert.equal(matches.length,1,'Missing exact Phase65 State10 historical source mapping');
        const actual=pin(matches[0].frozen);
        historicalMappings.push({emission:id,logical:x,actual,scope:'Exact Phase65 State10 historical audit input mapped to byte-identical checked snapshot; independent verifier remains pinned'});
      } else pin(x);""")
    texts[name] = text
    rows.append(dict(parent=before,output=dict(file=str(out/name),sha256=hashlib.sha256(text.encode()).hexdigest()),edits=edits))
out.mkdir(parents=True)
for name,text in texts.items(): (out/name).write_text(text)
result = dict(kind='phase61-candidate-fast-loop-method',complete=True,**{'pass':True},dataOnly=True,targetExecuted=False,
    producer=identity(__file__),parentDerivation=parent,derivations=rows,
    explicitCacheAdmission=manifest['explicitCacheAdmission'],immutableAuditSnapshot=manifest['immutableAuditSnapshot'],
    baseAnnotationProducts=manifest.get('baseAnnotationProducts'),
    scope='Only Phase66 writable boundary/method relocation, corresponding profile hash, and exact Phase65 State10 historical workflow mapping. '
          'Independent immutable audit modules, clocks, decoder-authoritative frame1/2/3/4 admission, raw oracles, profile sampling and guards unchanged.')
(out/'derivation.json').write_text(json.dumps(result,indent=2)+'\n')
print(json.dumps(dict(method=identity(out/'derivation.json'))))
