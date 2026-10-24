"""Freeze the bounded wide-extraction inlining policy; no target execution."""
import argparse
import importlib.util
import json
from pathlib import Path
HERE=Path(__file__).resolve().parent
ROOT=HERE.parents[4]
spec=importlib.util.spec_from_file_location('p137q',HERE/'prepare-v01.py')
P=importlib.util.module_from_spec(spec);spec.loader.exec_module(P)
p=argparse.ArgumentParser(description=__doc__)
p.add_argument('--parent',type=Path,required=True)
p.add_argument('--out',type=Path,required=True)
a=p.parse_args()
parent=a.parent.resolve();m=json.loads(parent.read_text());source=Path(m['source']['file'])
assert m['complete'] and P.C.pin(source)==m['source']
assert m['source']['sha256']=='863e28f8bba8a285332875ce99bf82a20d2ea3052c6f4b6aed3606b0d67485b5'
modules=[HERE/'retain-wide-v01.bend',HERE/'retain-controls-v01.bend']
before=source.read_text();text,added,protected=P.C.compose(before,[x.read_text()for x in modules],{'p113i_eligible'},set())
b=P.C.blocks(before);after=P.C.blocks(text)
expected=b['p113i_eligible'].replace('p113j_returns(body,result)','p137qi_returns(body,result)')
assert P.C.norm(after['p113i_eligible'])==P.C.norm(expected)
assert all(P.C.norm(b[n])==P.C.norm(after[n])for n in b if n!='p113i_eligible')
out=a.out.resolve();assert not out.exists() and out.is_relative_to(ROOT/'selfhost/build/phase137');out.mkdir()
(out/'compiler.bend').write_text(text)
(out/'prepare.py').write_bytes(Path(__file__).read_bytes())
for i,path in enumerate(modules):(out/f'module{i}.bend').write_bytes(path.read_bytes())
r=dict(kind='phase137-wide-owning-extraction-inline-policy',complete=True,checked=False,targetsRun=False,nativeQualified=False,selected=False,
    source=P.C.pin(out/'compiler.bend'),parent=m['source'],parentManifest=P.C.pin(parent),runtime=m['runtime'],
    overrides=['p113i_eligible'],added=added,protectedDeclarations=protected,controlEntry='p137qi_controls',controlCount=15,
    inputs=[P.C.pin(__file__),P.C.pin(HERE/'prepare-v01.py'),P.C.pin(P.C.__file__),P.C.pin(parent),m['source'],*[P.C.pin(x)for x in modules]],
    scope='One existing profitability walk replaced with same return-shape walk plus exact9..16-field consuming extraction refusal. No second whole-body analysis, borrowed eligibility change, runtime change, verifier change, late optimization or duplicate lowering. Existing source/statement evaluation and fallback stay intact; missed inlining is a performance risk. Original return-shape query remains available for truthful diagnostics.')
(out/'manifest.json').write_text(json.dumps(r,indent=2)+'\n')
print(json.dumps(dict(complete=True,source=r['source'],controls=15)))
