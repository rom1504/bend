from pathlib import Path
import difflib
import sys
p='selfhost/src/back/js/tree.bend';input_path=Path(sys.argv[1]) if len(sys.argv)>1 else Path(p);old=input_path.read_text();new=old
needle='j_covered_term(book, j_pure_remove(j_pure_defs(pure), dn(d)), dv(d))'
replacement='j_covered_term(book, j_pure_remove(j_pure_defs(pure), dn(d)), dn(d), dv(d))'
assert new.count(needle)==1;new=new.replace(needle,replacement)
start=new.index('@unsafe\ndef j_covered_term(');end=new.index('\n@unsafe\ndef j_covered_app(',start)
chunk=new[start:end]
chunk=chunk.replace('+context: List<&2,KDef>, +t: KTerm)', '+context: List<&2,KDef>, +owner: String, +t: KTerm)')
chunk=chunk.replace('+context: List<&2,KDef>, +ts: List<&2,KTerm>)', '+context: List<&2,KDef>, +owner: String, +ts: List<&2,KTerm>)')
chunk=chunk.replace('j_covered_term(book, context, ', 'j_covered_term(book, context, owner, ')
chunk=chunk.replace('j_covered_terms(book, context, ', 'j_covered_terms(book, context, owner, ')
chunk=chunk.replace('j_covered_app(book, context, t,', 'j_covered_shape_app(book, context, owner, t,')
chunk='''# Preserve the original saturated App/Call shell around a structural self call.
# Unary classification needs that shell to discover its continuation child;
# inherited proof lowering may still transform independent argument expressions.
'''+chunk
chunk+='''

@unsafe
def j_covered_shape_app(+book: List<&2,KDef>, +context: List<&2,KDef>, +owner: String, +original: KTerm, +rebuilt: KTerm) -> KTerm:
  kc(KTerm, String.eq(owner, "") || U32.is_eq(j_component_refs([original], owner, 8192, 0), 0),
    u => j_covered_app(book, context, original, rebuilt), u => rebuilt)
'''
assert 'def j_covered_terms(+book: List<&2,KDef>, +context: List<&2,KDef>, +owner: String, +ts: List<&2,KTerm>)' in chunk
assert 'def j_covered_term(+book: List<&2,KDef>, +context: List<&2,KDef>, +owner: String, +t: KTerm)' in chunk
new=new[:start]+chunk+new[end:]
patch=''.join(difflib.unified_diff(old.splitlines(True),new.splitlines(True),fromfile='a/'+p,tofile='b/'+p))
Path('selfhost/tools/performance/phase42/frames/owner-thread-source-v2.patch').write_text(patch)
