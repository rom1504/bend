"""Append parser checkpoint prototype to frozen Phase137; metadata only."""
import importlib.util,json
from pathlib import Path
HERE=Path(__file__).resolve().parent;ROOT=HERE.parents[4]
s=importlib.util.spec_from_file_location('C',ROOT/'selfhost/tools/performance/phase131/prepare.py');C=importlib.util.module_from_spec(s);s.loader.exec_module(C)
source=ROOT/'selfhost/build/phase137/integrated-source03/compiler.bend'
assert C.pin(source)['sha256']=='2620d59a3a20fa5d5d27bbf3b12ceb7304439b27093fff1c0f383da03e4ecf38'
modules=[HERE/x for x in ['types-v01.bend','top-parser-v01.bend','checkpoint-v01.bend','controls-v01.bend']]
out=ROOT/'selfhost/build/phase140/parser-source01';assert not out.exists()
before=source.read_text();text,added,protected=C.compose(before,[p.read_text() for p in modules],set(),set())
old,new=C.blocks(before),C.blocks(text)
assert all(C.norm(old[n])==C.norm(new[n]) for n in old)
assert all(old[n]==new[n] for n in protected)
out.mkdir(parents=True);(out/'compiler.bend').write_text(text);(out/'prepare.py').write_bytes(Path(__file__).read_bytes())
for i,p in enumerate(modules):(out/f'module{i}.bend').write_bytes(p.read_bytes())
r=dict(kind='phase140-parser-prefix-checkpoint-prototype',complete=True,checked=False,targetsRun=False,source=C.pin(out/'compiler.bend'),parent=C.pin(source),overrides=[],added=added,protectedDeclarations=protected,controlEntries={'p140p_controls':14},inputs=[C.pin(__file__),C.pin(C.__file__),C.pin(source),*[C.pin(p) for p in modules],C.pin(HERE/'clone-v01.json'),C.pin(HERE/'clone-v01.py')],scope='Append-only parser transport derivative. Original declarations, ordinary route, freshener, checker and verifier unchanged. Actual top-parser state, exact prefix/spans and initial scope; original suffix lexer/parser; ordinary fallback. No performance/qualification claim.')
(out/'manifest.json').write_text(json.dumps(r,indent=2)+'\n');print(json.dumps({'source':r['source'],'added':len(added),'controls':14}))
