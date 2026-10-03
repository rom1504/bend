#!/usr/bin/env python3
"""Produce an isolated proposal against the current tree; never modify source."""
from pathlib import Path
import difflib, json, hashlib, sys
root=Path(__file__).resolve().parents[6]
p=root/'selfhost/src/back/js/tree.bend'
a=p.read_text()
helpers='''
# A sequential structural tail call contains one descendant result in an inert
# scalar context. Both calls have independently proved proper-child origins.
@unsafe
def j_sequence_leaf(+book: List<&2,KDef>, +env: List<&2,KTerm>, +t: KTerm, +d: KDef) -> Bool:
  j_component_self(env, t, d) && U32.is_eq(j_component_refs([t], dn(d), 1024, 0), 2) &&
    j_sequence_args(book, env, ks(j_call_spine(j_strip(t), Nil{})), d, 32)

@unsafe
def j_sequence_args(+book: List<&2,KDef>, +env: List<&2,KTerm>, +xs: List<&2,KTerm>, +d: KDef, +fuel: U32) -> Bool:
  match xs:
    case Nil{}: True{}
    case Con{h, rest}: j_sequence_context(book, env, j_strip(h), d, fuel) && j_sequence_args(book, env, rest, d, fuel)

@unsafe
def j_sequence_atoms(+xs: List<&2,KTerm>) -> Bool:
  match xs:
    case Nil{}: True{}
    case Con{h, rest}: j_region_field_atom(j_strip(h)) && j_sequence_atoms(rest)

@unsafe
def j_sequence_context(+book: List<&2,KDef>, +env: List<&2,KTerm>, +t: KTerm, +d: KDef, +fuel: U32) -> Bool:
  +spine = j_call_spine(t, Nil{})
  kc(Bool, U32.is_gt(fuel, 0), u =>
    kc(Bool, j_region_field_atom(t), u => True{}, u =>
    kc(Bool, j_component_self(env, t, d), u =>
      U32.is_eq(j_component_refs([t], dn(d), 1024, 0), 1) && j_sequence_atoms(ks(spine)), u =>
      j_primitive_call(book, spine) &&
        String.contains("|U32.add|U32.sub|U32.mul|U32.and|U32.or|U32.xor|", "|" ++ nm(spine) ++ "|") &&
        j_sequence_args(book, env, ks(spine), d, U32.sub(fuel, 1)))), u => False{})

# The original source proof establishes the unique descendant hole. The
# annotated existing slot preserves typing for the unchanged argument emitter.
@unsafe
def j_sequence_hole(+book: List<&2,KDef>, +t: KTerm, +d: KDef) -> KTerm:
  kc(KTerm, j_linear_emit_self(t, d), u =>
    j_region_annotate(kt("JSlot", "", 0, 0, Nil{}), j_fold_root_result(book, dt(d), da(d))), u =>
    k_with_children(t, j_sequence_holes(book, ks(t), d)))

@unsafe
def j_sequence_holes(+book: List<&2,KDef>, +xs: List<&2,KTerm>, +d: KDef) -> List<&2,KTerm>:
  match xs:
    case Nil{}: Nil{}
    case Con{h, rest}: Con{j_sequence_hole(book, h, d), j_sequence_holes(book, rest, d)}

@unsafe
def j_sequence_find(+todo: List<&2,KTerm>, +d: KDef) -> KTerm:
  match todo:
    case Nil{}: atom("Absent")
    case Con{h, rest}: kc(KTerm, j_linear_emit_self(h, d), u => j_strip(h),
      u => j_sequence_find(List.append(&2, KTerm, ks(h), rest), d))

@unsafe
def j_sequence_finish(+book: List<&2,KDef>, +env: List<&2,KTerm>, +t: KTerm, +d: KDef, +phase: U32) -> String:
  +args = ks(j_call_spine(t, Nil{}))
  kc(String, U32.is_eq(phase, 3), u =>
    "const $p0=$value;const $next=[" ++ j_apply_args(book, env, j_sequence_holes(book, args, d), dt(d)) ++
    "];--$top;" ++ j_component_assign(0, da(d)) ++ "continue $visit;", u =>
    "const $next=[" ++ j_apply_args(book, env, ks(j_call_spine(j_sequence_find(args, d), Nil{})), dt(d)) ++ "];" ++
    "let $saved=$top<$frames.length?$frames[$top]:null;if(!$saved)$saved=$frames[$top]={args:null,left:null,phase:2};" ++
    "$saved.args=[" ++ j_component_save(0, da(d)) ++ "];$saved.phase=2;++$top;" ++
    j_component_assign(0, da(d)) ++ "continue $visit;")
'''
# Existing prefix, pure closure, graph/descriptor guards and coverage stay intact.
x='u => j_linear_leaf(book, env, t, d)))'
y='u => j_sequence_leaf(book, env, t, d) || j_linear_leaf(book, env, t, d)))'
assert a.count(x)==1
b=a.replace(x,y)
x='''    kc(String, U32.is_eq(phase, 2), u =>
      "const " ++ j_local(ix(kid(t, 0)))'''
y='''    kc(String, j_linear_emit_self(t, d), u => j_sequence_finish(book, env, t, d, phase), u =>
    kc(String, U32.is_eq(phase, 2), u =>
      "const " ++ j_local(ix(kid(t, 0)))'''
assert b.count(x)==1
b=b.replace(x,y)
x='j_component_enter(book, env, j_call_spine(kid(kid(t, phase), 0), Nil{}), d, phase))))'
y='j_component_enter(book, env, j_call_spine(kid(kid(t, phase), 0), Nil{}), d, phase)))))'
assert b.count(x)==1
b=b.replace(x,y)+helpers
out=Path(sys.argv[1]);out.mkdir()
(out/'tree.bend').write_text(b)
(out/'candidate.patch').write_text(''.join(difflib.unified_diff(a.splitlines(True),b.splitlines(True),fromfile='a/selfhost/src/back/js/tree.bend',tofile='b/selfhost/src/back/js/tree.bend')))
(out/'identity.json').write_text(json.dumps({'kind':'unexecuted-sequential-component-proposal','sourceSha256':hashlib.sha256(a.encode()).hexdigest(),'candidateSha256':hashlib.sha256(b.encode()).hexdigest(),'addedLines':len(b.splitlines())-len(a.splitlines()),'noProductionEdits':True},indent=2)+'\n')
