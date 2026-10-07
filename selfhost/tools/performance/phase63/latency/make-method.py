#!/usr/bin/env python3
"""Derive a Phase63 writable method; no compiler is imported or executed."""
import argparse
import ast
import hashlib
import json
from pathlib import Path

ROOT = Path(__file__).resolve().parents[5]
RAW = ROOT / 'selfhost/build/phase63'
PARENT = ROOT / 'selfhost/build/phase61/latency-method06'
PINS = {
    'run.py': '89cfb11703db68afa2e7ace2818b684b9196406cd947b7350a80a95453478abc',
    'worker.mjs': '71106a64873d5001a19af8c47e6eb85592d93f07efc578b1cf31781941a953b8',
    'setup.mjs': '171b36cc8ceb283f22990751bd15587e3f525f0f46d1acf04cfcde08b2b6f5a6',
    'profile.mjs': 'f71444b4ab44ee49036d1cb70f06b6da9e28e71500619dbb378183ad3e26407b',
}


def identity(value):
    file = Path(value).resolve(strict=True)
    return dict(file=str(file), sha256=hashlib.sha256(file.read_bytes()).hexdigest())


p = argparse.ArgumentParser(description=__doc__)
p.add_argument('out', type=Path)
p.add_argument('--cache-version', type=int, action='append', default=[],
               help='Additional version explicitly admitted by this method; snapshot driver still decodes/validates it')
p.add_argument('--frame-version', type=int, action='append', default=[],
               help='Additional -frameN.json suffix explicitly admitted by this method')
a = p.parse_args()
out = a.out.resolve()
assert out.is_relative_to(RAW.resolve()) and not out.exists()
assert all(1 <= n <= 99 for n in a.cache_version + a.frame_version)
cache_versions = sorted({4, 6, *a.cache_version})
frame_versions = sorted({1, 2, *a.frame_version})
texts, rows = {}, []
for name in ['profile.mjs', 'run.py', 'worker.mjs', 'setup.mjs']:
    before = identity(PARENT / name)
    assert before['sha256'] == PINS[name], name
    text = (PARENT / name).read_text()
    edits = []

    def edit(old, new, count=1):
        global text
        assert text.count(old) == count, (name, old, count, text.count(old))
        text = text.replace(old, new)
        edits.append(dict(old=old, new=new, count=count))

    if name == 'profile.mjs':
        edit(f'const rawRoot=path.resolve("{ROOT}/selfhost/build/phase61");',
             f'const rawRoot=path.resolve("{RAW}");')
    if name == 'run.py':
        edit(str(PARENT), str(out), 4)
        edit("ROOT/'selfhost/build/phase61'", "ROOT/'selfhost/build/phase63'", 3)
        edit(PINS['profile.mjs'], hashlib.sha256(texts['profile.mjs'].encode()).hexdigest())
        ast.parse(text)
    if name == 'worker.mjs':
        edit(str(PARENT), str(out), 2)
    if name == 'setup.mjs':
        edit("boundary=path.join(root,'selfhost/build/phase61')",
             "boundary=path.join(root,'selfhost/build/phase63')")
        # One additional *historical audit input*, never executed compiler bytes.
        # The receipt and exact original -> frozen snapshot mapping remain pinned.
        old = """      } else pin(x);
    }
    pin(e.producer);pin(e.config);pin(e.progress);"""
        new = """      } else if(id.file===path.join(root,'selfhost/build/phase61/final-state08/bootstrap/full/report.json')&&
                id.sha256==='56eb860d154fcf1bdec1e6ecab43262a073b3bdfeaa2dd9fa6781901aee52b74'&&
                x.file===logical) {
        assert.equal(generator.attemptId.file,path.join(root,'selfhost/build/phase61/checked-state08/attempt.json'));
        assert.equal(generator.attemptId.sha256,'bf671a4e092f238879756b4c076f39733825b4390e6593795e8beea4c8561f13');
        const frozenPath=path.join(root,'selfhost/build/phase61/checked-state08/snapshot/tools/development/workflow.mjs');
        const matches=generator.attempt.snapshot.sources.filter(row=>row.original.file===logical&&
          row.original.canonicalPath===logical&&row.original.sha256===x.sha256&&
          row.frozen.file===frozenPath&&row.frozen.canonicalPath===frozenPath&&row.frozen.sha256===x.sha256);
        assert.equal(matches.length,1,'Missing exact State08 historical source mapping');
        const actual=pin(matches[0].frozen);
        historicalMappings.push({emission:id,logical:x,actual,scope:'Historical State08 workflow audit dependency only; current executed workflow is pinned independently'});
      } else pin(x);
    }
    pin(e.producer);pin(e.config);pin(e.progress);"""
        edit(old, new)
        if frame_versions != [1, 2]:
            suffix = '|'.join(str(n) for n in frame_versions)
            edit(r'/-frame[12]\.json$/', rf'/-frame(?:{suffix})\.json$/')
        if cache_versions != [4, 6]:
            edit('[4,6].includes(c.version)', json.dumps(cache_versions) + '.includes(c.version)')
    texts[name] = text
    rows.append(dict(parent=before, output=dict(file=str(out/name),
        sha256=hashlib.sha256(text.encode()).hexdigest()), edits=edits))

out.mkdir(parents=True)
for name, text in texts.items():
    (out/name).write_text(text)
report = dict(kind='phase61-candidate-fast-loop-method', complete=True, **{'pass': True},
    dataOnly=True, targetExecuted=False, producer=identity(__file__),
    parentDerivation=identity(PARENT/'derivation.json'), derivations=rows,
    explicitCacheAdmission=dict(frameVersions=frame_versions, decodedVersions=cache_versions),
    scope='Phase63 writable relocation plus exact immutable State08 historical workflow audit mapping. '
          'Additional frame/cache versions, if requested, are explicit and use each frozen driver decoder. '
          'All clocks, request lifecycle, honest lineage, raw-output oracles and resource limits unchanged.')
(out/'derivation.json').write_text(json.dumps(report, indent=2)+'\n')
print(json.dumps(dict(method=identity(out/'derivation.json'))))
