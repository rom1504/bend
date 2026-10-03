#!/usr/bin/env python3
"""Write the isolated self-reference-fact candidate and a reviewable source patch."""
import argparse
import difflib
import hashlib
import json
from pathlib import Path

p = argparse.ArgumentParser(description=__doc__)
p.add_argument('source', type=Path)
p.add_argument('out', type=Path)
a = p.parse_args()
source = a.source.resolve()
out = a.out.resolve()
before = source.read_text()
after = before
old = '''    kc(JPure, j_component_admit(book, d), u =>
    kc(JPure, j_region_capture_eligible(book, d) &&
      j_component_prefix(book, Nil{}, dv(d), dt(d), j_component_slots(0, da(d)), d, 0), u =>
        j_component_select(book, d, j_component_closed(d, j_pure_graph(book, d, JPure{Nil{}, 32768, True{}}))),
      u => JPure{Nil{}, 0, False{}}), u => JPure{Nil{}, 0, False{}}),
      u => JPure{Nil{}, 0, False{}}), u => JPure{Nil{}, 0, False{}}), u => JPure{Nil{}, 0, False{}})'''
new = '''      j_component_admit(book, d, j_component_refs([dv(d)], dn(d), 1024, 0)),
      u => JPure{Nil{}, 0, False{}}), u => JPure{Nil{}, 0, False{}}), u => JPure{Nil{}, 0, False{}})'''
assert after.count(old) == 1
after = after.replace(old, new)
old = '''def j_component_admit(+book: List<&2,KDef>, +d: KDef) -> Bool:
  kc(Bool, U32.is_gt(j_component_refs([dv(d)], dn(d), 1024, 0), 0), u => True{}, u =>
    j_component_wrapper_arg(book, wnf(book, kid(wnf(book, dt(d)), 0))))'''
new = '''def j_component_admit(+book: List<&2,KDef>, +d: KDef, +selfRefs: U32) -> JPure:
  kc(JPure, U32.is_gt(selfRefs, 0) || j_component_wrapper_arg(book, wnf(book, kid(wnf(book, dt(d)), 0))), u =>
    kc(JPure, j_region_capture_eligible(book, d) &&
      j_component_prefix(book, Nil{}, dv(d), dt(d), j_component_slots(0, da(d)), d, 0), u =>
        j_component_select(book, d, selfRefs, j_component_closed(d, j_pure_graph(book, d, JPure{Nil{}, 32768, True{}}))),
      u => JPure{Nil{}, 0, False{}}), u => JPure{Nil{}, 0, False{}})'''
assert after.count(old) == 1
after = after.replace(old, new)
old = 'def j_component_select(+book: List<&2,KDef>, +d: KDef, +pure: JPure) -> JPure:'
new = 'def j_component_select(+book: List<&2,KDef>, +d: KDef, +selfRefs: U32, +pure: JPure) -> JPure:'
assert after.count(old) == 1
after = after.replace(old, new)
old = '    kc(JPure, U32.is_gt(j_component_refs([dv(d)], dn(d), 1024, 0), 0), u => pure, u =>'
new = '    kc(JPure, U32.is_gt(selfRefs, 0), u => pure, u =>'
assert after.count(old) == 1
after = after.replace(old, new)
assert not out.exists(), 'Preserve every candidate'
out.mkdir(parents=True)
(out / 'tree.bend').write_text(after)
(out / 'candidate.patch').write_text(''.join(difflib.unified_diff(before.splitlines(True), after.splitlines(True), fromfile='a/selfhost/src/back/js/tree.bend', tofile='b/selfhost/src/back/js/tree.bend')))
(out / 'identity.json').write_text(json.dumps(dict(kind='phase42-request-local-self-refs', source=str(source), sourceSha256=hashlib.sha256(before.encode()).hexdigest(), candidateSha256=hashlib.sha256(after.encode()).hexdigest(), physicalLineDelta=len(after.splitlines())-len(before.splitlines()), productionEdited=False, expectedEmission='byte-identical for every admitted and refused request'), indent=2) + '\n')
print(out / 'candidate.patch')
