#!/usr/bin/env python3
"""Successor to consumed method01: bind/stage the private graph codec dependency."""
import argparse
import ast
import hashlib
import json
from pathlib import Path

ROOT = Path(__file__).resolve().parents[5]
RAW = ROOT/'selfhost/build/phase63'
PARENT = RAW/'latency-method01'


def identity(file):
    file = Path(file).resolve(strict=True)
    return dict(file=str(file), sha256=hashlib.sha256(file.read_bytes()).hexdigest())


p = argparse.ArgumentParser(description=__doc__)
p.add_argument('out', type=Path)
a = p.parse_args()
out = a.out.resolve()
assert out.is_relative_to(RAW.resolve()) and not out.exists()
parent_derivation = identity(PARENT/'derivation.json')
assert parent_derivation['sha256'] == '17d78d99d8e4873c359420e88b3f425bf7d0c0af625c0f1e3ccb627259a4f0e1'
parent = json.loads((PARENT/'derivation.json').read_text())
pins = {Path(row['output']['file']).name: row['output'] for row in parent['derivations']}
texts, rows = {}, []
for name in ['profile.mjs', 'run.py', 'worker.mjs', 'setup.mjs']:
    before = identity(PARENT/name)
    assert before == pins[name]
    text = (PARENT/name).read_text()
    edits = []

    def edit(old, new, count=1):
        global text
        assert text.count(old) == count, (name, old, count, text.count(old))
        text = text.replace(old, new)
        edits.append(dict(old=old, new=new, count=count))

    if name == 'run.py':
        edit(str(PARENT), str(out), 4)
        # Current workflow imports the current driver solely for cache admission;
        # pin its complete non-builtin static import closure independently of the
        # actual baseline/candidate snapshot driver staged below.
        helper_list = "*[ROOT/'selfhost/tools'/f'{n}.mjs' for n in ['typed-driver','base-cache-graph','assemble','native-build','node-resource-args','compiler-abi']]"
        edit(" PROGRAMS/'support.py',PROGRAMS/'profile.mjs']}",
             " PROGRAMS/'support.py',PROGRAMS/'profile.mjs',"+helper_list+"]}")
        edit(" PROGRAMS/'support.py',PROGRAMS/'profile.mjs',catalog,node,a.bindings,",
             " PROGRAMS/'support.py',PROGRAMS/'profile.mjs',"+helper_list+",catalog,node,a.bindings,")
        ast.parse(text)
    if name == 'worker.mjs':
        edit(str(PARENT), str(out), 2)
    if name == 'setup.mjs':
        edit("  copy(path.join(snapshot,'src/compiler.json'),'src/compiler.json');", """  const graphHelper=path.join(snapshot,'tools/base-cache-graph.mjs');
  const hasGraphHelper=fs.existsSync(graphHelper);
  if(hasGraphHelper)copy(graphHelper,'tools/base-cache-graph.mjs');
  copy(path.join(snapshot,'src/compiler.json'),'src/compiler.json');""")
        edit("  const api=await D.loadApi(),mod=await import(pathToFileURL(apiFile.file));assert.equal(api,mod.default);", """  if(hasGraphHelper)assert.equal(D.baseCacheGraphPath,path.join(project,'tools/base-cache-graph.mjs'));
  else assert.equal(D.baseCacheGraphPath,undefined,'Snapshot omits declared graph helper');
  const api=await D.loadApi(),mod=await import(pathToFileURL(apiFile.file));assert.equal(api,mod.default);""")
        edit("new URL(\"file:///home/ai/bend2/build/publish/bend/selfhost/tools/conformance/inventory.mjs\",import.meta.url),process.execPath])pin(file);",
             "new URL(\"file:///home/ai/bend2/build/publish/bend/selfhost/tools/conformance/inventory.mjs\",import.meta.url),process.execPath,\n    ...['typed-driver','base-cache-graph','assemble','native-build','node-resource-args','compiler-abi'].map(n=>path.join(root,'selfhost/tools',n+'.mjs'))])pin(file);")
    texts[name] = text
    rows.append(dict(parent=before, output=dict(file=str(out/name),
        sha256=hashlib.sha256(text.encode()).hexdigest()), edits=edits))
out.mkdir(parents=True)
for name,text in texts.items():
    (out/name).write_text(text)
report = dict(kind='phase61-candidate-fast-loop-method', complete=True, **{'pass':True},
    dataOnly=True, targetExecuted=False, producer=identity(__file__),
    parentDerivation=parent_derivation, derivations=rows,
    explicitCacheAdmission=parent['explicitCacheAdmission'],
    scope='Method01 successor; unchanged clocks/oracles/lineage/guard. Stage and verify the optional '
          'frozen snapshot graph helper, require its exported staged identity, and independently pin '
          'current workflow driver/graph/static helper audit dependencies. Historical State08 lacks '
          'the helper and remains on its original frozen cache implementation.')
(out/'derivation.json').write_text(json.dumps(report,indent=2)+'\n')
print(json.dumps(dict(method=identity(out/'derivation.json'))))
