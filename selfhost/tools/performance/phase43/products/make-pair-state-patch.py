"""Held pair-state lane patch; no production mutation."""
from pathlib import Path
import difflib,re
root=Path(__file__).resolve().parents[5]
p=root/'selfhost/src/back/js/tree.bend';s=p.read_text();proposal=Path(__file__).with_name('pair-state-proposal.bend').read_text()
old='''def j_component_covered_declaration(+book: List<&2,KDef>, +d: KDef, +body: KTerm) -> String:
  kc(String, j_flat_active(book)'''
new='''def j_component_covered_declaration(+book: List<&2,KDef>, +d: KDef, +body: KTerm) -> String:
  kc(String, kc(Bool, j_flat_active(book), u => False{}, u => j_pair_loop_shape(book, d)), u => j_pair_loop_declaration(book, d), u =>
  kc(String, j_flat_active(book)'''
assert s.count(old)==1
patched=s.replace(old,new)
old='    u => j_component_stack_declaration(book, d, body, "$tree"))\n'
assert patched.count(old)==1
patched=patched.replace(old,'    u => j_component_stack_declaration(book, d, body, "$tree")))\n')
patched+='\n'+proposal
names=set(re.findall(r'^def\s+([\w.]+)',patched,re.M))
refs=set(re.findall(r'\b(j_pair_[\w]+)\(',proposal))
assert refs<=names,refs-names
out=Path(__file__).with_name('pair-state-prototype.patch')
out.write_text(''.join(difflib.unified_diff(s.splitlines(True),patched.splitlines(True),fromfile='a/selfhost/src/back/js/tree.bend',tofile='b/selfhost/src/back/js/tree.bend')))
print(out)
