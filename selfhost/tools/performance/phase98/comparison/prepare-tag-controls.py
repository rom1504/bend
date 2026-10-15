#!/usr/bin/env python3
"""Extract exact term representation/reference and prepare finite fused-tag controls."""
import hashlib,json
from pathlib import Path
HERE=Path(__file__).resolve().parent;ROOT=HERE.parents[4]
source=ROOT/'selfhost/tools/performance/phase90/observation/noindent01/compiler-noindent.bend'
production=ROOT/'selfhost/src/core/term.bend'
s=source.read_text();t=production.read_text()
types=t[t.index('type KTerm is Data:'):t.index('type KDef is Data:')]
assert types in s
tg=t[t.index('def tg('):t.index('\n@unsafe\ndef nm(')]
assert tg in s
reference=tg.replace('def tg(','def p98_tag_reference(',1)
walker=s[s.index('def p88_string_eq_go('):s.index('\ndef p88_string_order_go(')]
helpers=(HERE/'tag-helpers01.bend').read_text();tail=(HERE/'tag-controls.tail.bend').read_text()
control='import Base\n\n'+types+walker+'\n\n'+reference+'\n\n'+helpers+'\n'+tail
old='p98_tag_eq(term, key)';new='p88_string_eq(p98_tag_reference(term), key)'
assert tail.count(old)==1
baseline=control[:-len(tail)]+tail.replace(old,new)
out=HERE/'tag-controls01';assert not out.exists();out.mkdir()
(out/'candidate.bend').write_text(control);(out/'baseline.bend').write_text(baseline)
def pin(p):
 p=p.resolve();b=p.read_bytes();return dict(file=str(p),bytes=len(b),sha256=hashlib.sha256(b).hexdigest())
receipt=dict(kind='phase98-fused-tag-controls',complete=True,targetsRun=False,
 inputs=[pin(source),pin(production),pin(HERE/'tag-helpers01.bend'),pin(HERE/'tag-controls.tail.bend'),pin(Path(__file__))],
 outputs=[pin(out/'candidate.bend'),pin(out/'baseline.bend')],cases=96,reference='Exact production tg body renamed; exact D04 safe equality. Native full products include originalterm/key and bothBoolean observations.',
 scopes='All3termconstructors,completechildren/removals/spans/quantityflag/literalpayload,empty/arbitrarytags,Unicode,prefix/longsuffixcases. No unboundedproof or native lifetime proof.',
 extraction=dict(termTypesExact=True,tagBodyExactExceptName=True,d04EqualityExact=True),
 oracle='Baseline emits reference twice; candidate emits reference and newfusedobserver. Require whole stdout equality across actual native baseline/candidate, then inspect all96Boolresults and complete preservedvalues. No target run by preparer.')
(out/'receipt.json').write_text(json.dumps(receipt,indent=2)+'\n')
print(json.dumps(dict(out=str(out),cases=96,targetsRun=False)))
