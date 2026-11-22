#!/usr/bin/env python3
"""AGY-W2-BASEPIN: Bind Base-library x86 fast paths (Map.{set,del,get}, Array.to_list.go)
to exact 64-bit dual-seed structural AST fingerprints of the validated Base definitions.

Any modification to any Map.*, String.{eq,cmp*}, or Array.to_list* body in a caller-supplied
or updated Base immediately declines the corresponding fast path and falls back to ordinary lowering.
"""
import sys
from pathlib import Path

MAP_CLOSURE = [
    "Map.bit.u", "Map.bit.chr", "Map.bit.go.chr", "Map.bit.go.rec", "Map.bit.go", "Map.bit.at", "Map.bit",
    "Map.msb.u.if", "Map.msb.u", "Map.diff.chr", "Map.diff.step", "Map.diff.fin", "Map.diff",
    "Map.put.go", "Map.put", "Map.ins.splice.bit", "Map.ins.splice", "Map.ins.go", "Map.ins",
    "Map.lo", "Map.hi", "Map.seek.go", "Map.seek", "Map.set.fin.go", "Map.set.fin", "Map.set.go", "Map.set",
    "Map.get.leaf", "Map.get.go", "Map.get",
    "Map.pop.lo", "Map.pop.hi", "Map.pop.leaf", "Map.pop.go", "Map.pop", "Map.del.fin", "Map.del",
    "String.eq", "String.cmp", "String.cmp.rec", "String.cmp.fin",
]

ARR_CLOSURE = [
    "Array.to_list.go", "Array.to_list",
]

# Filled from stock selfhost/dist/base.bend (verified identical in live p86_prepare and cache base.p130 across fixtures)
PIN_MAP_H1 = 1678702329
PIN_MAP_H2 = 992788723
PIN_ARR_H1 = 707040475
PIN_ARR_H2 = 668870049


def mk_bend_list(names):
    return "[" + ",".join(f'"{n}"' for n in names) + "]"


def build_basepin_code():
    return f'''
# === AGY-W2-BASEPIN ===
@unsafe
def agy_bp_mix(+h: U32, +v: U32) -> U32:
  U32.mul(U32.xor(h,v),16777619)

@unsafe
def agy_bp_str(s: String, +h: U32) -> U32:
  match s:
    case SNil{{}}: agy_bp_mix(h,255)
    case SCon{{c,rest}}: agy_bp_str(rest,agy_bp_mix(h,Char.to_u32(c)))

law agy_bp_term:
  for +t: KTerm
  for +h: U32
  U32

@unsafe
def agy_bp_terms(xs: List<&2,KTerm>, +h: U32) -> U32:
  match xs:
    case Nil{{}}: agy_bp_mix(h,254)
    case Con{{x,rest}}: agy_bp_terms(rest,agy_bp_term(x,h))

@unsafe
def agy_bp_term(t, h):
  +s = j_strip(t)
  +h1 = agy_bp_str(tg(s),h)
  +h2 = agy_bp_str(nm(s),h1)
  +h3 = nt_choose(U32,core_literal(s),
    u => agy_bp_str(kl_text(s),agy_bp_mix(h2,kl_number(s))),
    u => h2)
  agy_bp_terms(ks(s),h3)

@unsafe
def agy_bp_def(+book: List<&2,KDef>, +name: String, +h: U32) -> U32:
  +d = lookup(book,name)
  nt_choose(U32,String.eq(dk(d),"Def") && db(d),
    u =>
      +h1 = agy_bp_str(name,h)
      +h2 = agy_bp_mix(agy_bp_mix(h1,da(d)),dx(d))
      agy_bp_term(dv(d),h2),
    u => 0)

@unsafe
def agy_bp_list(+book: List<&2,KDef>, names: List<&2,String>, +h: U32) -> U32:
  match names:
    case Nil{{}}: h
    case Con{{n,rest}}:
      +h1 = agy_bp_def(book,n,h)
      nt_choose(U32,U32.is_eq(h1,0),u => 0,u => agy_bp_list(book,rest,h1))

@unsafe
def agy_bp_map_hash(+book: List<&2,KDef>, +seed: U32) -> U32:
  agy_bp_list(book,{mk_bend_list(MAP_CLOSURE)},seed)

@unsafe
def agy_bp_arr_hash(+book: List<&2,KDef>, +seed: U32) -> U32:
  agy_bp_list(book,{mk_bend_list(ARR_CLOSURE)},seed)

@unsafe
def agy_bp_map_pinned(+book: List<&2,KDef>) -> Bool:
  U32.is_eq(agy_bp_map_hash(book,2166136261),{PIN_MAP_H1}) &&
  U32.is_eq(agy_bp_map_hash(book,33554467),{PIN_MAP_H2})

@unsafe
def agy_bp_arr_pinned(+book: List<&2,KDef>) -> Bool:
  U32.is_eq(agy_bp_arr_hash(book,2166136261),{PIN_ARR_H1}) &&
  U32.is_eq(agy_bp_arr_hash(book,33554467),{PIN_ARR_H2})

@unsafe
def agy_bp_mark_ids(ids: N111Ids, +key: String) -> N111Ids:
  match ids:
    case N111Ids{{+fs,cs}}:
      +entry : KDef = KDef{{key,"AgyBasePinned",0,0,atom("Absent"),atom("Absent"),[],False{{}},False{{}}}}
      N111Ids{{nt_choose(KDef,String.eq(dk(p111v_get(fs,key)),"Absent"),
        u => index_set(fs,entry,index_hash(key,2166136261),32),u => fs),cs}}

@unsafe
def agy_bp_has_mark(+ids: N111Ids, +key: String) -> Bool:
  match ids:
    case N111Ids{{fs,_}}: String.eq(dk(p111v_get(fs,key)),"AgyBasePinned")

@unsafe
def agy_bp_ctx(ctx: P134Context, +map_ok: Bool, +arr_ok: Bool) -> P134Context:
  match ctx:
    case P134Context{{ids,idx,direct,ready,view,lookups,heap,mode}}:
      +ids1 = nt_choose(N111Ids,map_ok,u => agy_bp_mark_ids(ids,"$agy.bp/map"),u => ids)
      +ids2 = nt_choose(N111Ids,arr_ok,u => agy_bp_mark_ids(ids1,"$agy.bp/arr"),u => ids1)
      P134Context{{ids2,idx,direct,ready,view,lookups,heap,mode}}

@unsafe
def agy_bp_cursor(cursor: P134Cursor, +map_ok: Bool, +arr_ok: Bool) -> P134Cursor:
  match cursor:
    case P134Private{{fs,c,next}}: P134Private{{fs,agy_bp_ctx(c,map_ok,arr_ok),agy_bp_cursor(next,map_ok,arr_ok)}}
    case P134Public{{ss,c,next}}: P134Public{{ss,agy_bp_ctx(c,map_ok,arr_ok),agy_bp_cursor(next,map_ok,arr_ok)}}
    case P134Legacy{{es,c,next}}: P134Legacy{{es,agy_bp_ctx(c,map_ok,arr_ok),agy_bp_cursor(next,map_ok,arr_ok)}}
    case p: p

@unsafe
def agy_bp_apply(prepared: P169Prepared, +map_ok: Bool, +arr_ok: Bool) -> P169Prepared:
  match prepared:
    case P169Prepared{{forwards,+cursor,+error}}:
      P169Prepared{{forwards,nt_choose(P134Cursor,(map_ok || arr_ok) && String.is_empty(error),
        u => agy_bp_cursor(cursor,map_ok,arr_ok),u => cursor),error}}

@unsafe
def agy_bp_annotate(r: NR_Request, +prepared: P169Prepared) -> P169Prepared:
  match r:
    case NR_Request{{source,+book,names,paths,scope,bound}}:
      agy_bp_apply(prepared,agy_bp_map_pinned(book),agy_bp_arr_pinned(book))
'''


def once(s: str, old: str, new: str, label: str) -> str:
    n = s.count(old)
    assert n == 1, f"{label}: expected 1 match, got {n}"
    return s.replace(old, new, 1)


def patch(src: str) -> str:
    if "# === AGY-W2-BASEPIN ===" in src:
        return src
    code = build_basepin_code()
    # 1. Insert BASEPIN code right before agy_map_has_ctor (from wave2c_map)
    anchor = "@unsafe\ndef agy_map_has_ctor("
    if anchor not in src:
        anchor = "def agy_map_has_ctor("
    src = once(src, anchor, code + "\n\n" + anchor, "insert BASEPIN")

    # 2. Gate wave2c_map's agy_map_book_ok with agy_bp_map_pinned(book)
    old_mok = 'def agy_map_book_ok(+book: List<&2,KDef>) -> Bool:\n  agy_map_has_ctor(book,"Map","MTip",0) &&'
    new_mok = 'def agy_map_book_ok(+book: List<&2,KDef>) -> Bool:\n  agy_bp_map_pinned(book) &&\n  agy_map_has_ctor(book,"Map","MTip",0) &&'
    src = once(src, old_mok, new_mok, "gate agy_map_book_ok")

    # 3. Gate wave2c_recagg's agy_map_kind with agy_bp_has_mark(ids,"$agy.bp/map")
    old_mkind = 'nt_choose(U32,U32.is_eq(arity,3) && U32.is_eq(result,1) && agy_map_has_ctors(ids),u =>'
    new_mkind = 'nt_choose(U32,agy_bp_has_mark(ids,"$agy.bp/map") && U32.is_eq(arity,3) && U32.is_eq(result,1) && agy_map_has_ctors(ids),u =>'
    src = once(src, old_mkind, new_mkind, "gate agy_map_kind")

    # 4. Gate AGY-W2C-ARRLIST's agy_al_is_match with agy_bp_has_mark(ids,"$agy.bp/arr")
    old_al = 'def agy_al_is_match(+name: String, +params: List<&2,String>, +ids: N111Ids) -> Bool:\n  (String.eq(name,"$direct.Array.to_list.go~0") || String.eq(name,"Array.to_list.go~0")) &&'
    new_al = 'def agy_al_is_match(+name: String, +params: List<&2,String>, +ids: N111Ids) -> Bool:\n  agy_bp_has_mark(ids,"$agy.bp/arr") &&\n  (String.eq(name,"$direct.Array.to_list.go~0") || String.eq(name,"Array.to_list.go~0")) &&'
    src = once(src, old_al, new_al, "gate agy_al_is_match")

    # 5. Hook agy_bp_annotate into x198pw_plan right after agy_map_annotate
    old_hook = "agy_map_annotate(r,agy_da_annotate(agy_fl_annotate(r,agy_zip_annotate(r,x198pw_annotate(r,prepared)))))"
    new_hook = "agy_bp_annotate(r,agy_map_annotate(r,agy_da_annotate(agy_fl_annotate(r,agy_zip_annotate(r,x198pw_annotate(r,prepared))))))"
    src = once(src, old_hook, new_hook, "hook agy_bp_annotate")
    return src


if __name__ == "__main__":
    inp, outp = Path(sys.argv[1]), Path(sys.argv[2])
    outp.write_text(patch(inp.read_text()))
    print(f"Patched {inp} -> {outp} (AGY-W2-BASEPIN)")
