#!/usr/bin/env python3
"""W14-B Step 2: Implement x86-iface v3 (OPT #1..#4) in m11, build native n6_v3,
benchmark vs baseline n6_w13 on m06 & m10, and verify downstream m07.o & m11.o SHA-256 parity!
Dedicated CPUs: 0 and 1 ONLY.
"""
from __future__ import annotations

import hashlib
import json
import subprocess
import time
from pathlib import Path

ROOT = Path("/home/ai/bend2_agy")
N5_O2 = ROOT / "selfhost/build/agy/wave13-native-mod/n5_o2"
BASE_FILE = ROOT / "selfhost/dist/base.bend"
K14_DIR = ROOT / "research/agy/w10_mod_bend/k14_wave13"
CACHE_IFACE = Path("/tmp/agy_k14_w13_cache/iface")
CACHE_OBJ = Path("/tmp/agy_k14_w13_cache/obj_o0")
RT = ROOT / "selfhost/build/agy/unified/runtime-agy.o"
CC = "/usr/bin/x86_64-linux-gnu-gcc-10"
W13_RESULTS = ROOT / "research/agy/w13_campaign/w13_int_n5_o2/results.json"

OUT_DIR = ROOT / "research/agy/w14_campaign/w14b_iface_v3"
TMP = Path("/tmp/agy_w14b")
MOD_NAMES = [
    "m00a", "m00b", "m01", "m02", "m03", "m04",
    "m05a", "m05b", "m06", "m07", "m08", "m09", "m10", "m11",
]

W14_V3_BEND = r'''
# === AGY-W14B-IFACE-V3: Fast Direct-Dispatch Decoder + Fast ABI + Fast Leaf-Interned Encoder ===

# --- OPT #2: Direct-dispatch word-pair .p130 decoder (zero roles/values/reverse boxing) ---

@unsafe
def w14_w(+lo: U32, +hi: U32) -> U32:
  U32.or(U32.sub(lo, 65536), U32.shln(U32.sub(hi, 65536), 16n))

@unsafe
def w14_dec_str_arr(strings: Array<String>, +id: U32) -> Array<String> & String:
  Array.get(String, strings, id)

@unsafe
def w14_dec_node_arr(nodes: Array<P88Node>, +id: U32) -> Array<P88Node> & P88Node:
  Array.get(P88Node, nodes, id)

@unsafe
def w14_con_build(head: P88Node, tail: P88Node) -> P88Node:
  match head tail:
    case P88Term{h} P88Empty{}: P88Terms{[h]}
    case P88Def{h} P88Empty{}: P88Defs{[h]}
    case P88String{h} P88Empty{}: P88Strings{[h]}
    case P88Term{h} P88Terms{t}: P88Terms{Con{h, t}}
    case P88Def{h} P88Defs{t}: P88Defs{Con{h, t}}
    case P88String{h} P88Strings{t}: P88Strings{Con{h, t}}
    case _ _: P88Bad{}

@unsafe
def w14_unwrap_terms(n: P88Node) -> List<&2, KTerm>:
  match n:
    case P88Terms{xs}: xs
    case _: Nil{}

@unsafe
def w14_unwrap_strs(n: P88Node) -> List<&2, String>:
  match n:
    case P88Strings{xs}: xs
    case _: Nil{}

@unsafe
def w14_unwrap_defs(n: P88Node) -> List<&2, KDef>:
  match n:
    case P88Defs{xs}: xs
    case _: Nil{}

@unsafe
def w14_unwrap_term(n: P88Node) -> KTerm:
  match n:
    case P88Term{t}: t
    case _: {KTerm{"Absent", "", 0, 0, Nil{}, Nil{}, 0, 0} : KTerm}

@unsafe
def w14_unwrap_def(n: P88Node) -> KDef:
  match n:
    case P88Def{d}: d
    case _: missing()

law w14_dec_recs:
  for text: String
  for nodes: Array<P88Node>
  for strings: Array<String>
  for +made: U32
  for +sn: U32
  for +begin: U32
  for +end: U32
  for +left: U32
  P88Decoded

@unsafe
def w14_dec_put(text: String, nodes: Array<P88Node>, strings: Array<String>, +made: U32, +sn: U32, +begin: U32, +end: U32, +left: U32, node: P88Node) -> P88Decoded:
  match node:
    case P88Bad{}: P88DecodeError{"w14 cache record"}
    case n: w14_dec_recs(text, Array.set(P88Node, nodes, made, n), strings, U32.inc(made), sn, begin, end, U32.sub(left, 1))

@unsafe
def w14_dec_con_str_got(rest: String, nodes1: Array<P88Node>, +made: U32, +sn: U32, +begin: U32, +end: U32, +left: U32, nb: P88Node, pair: Array<String> & String) -> P88Decoded:
  (strings1, sa) = pair
  w14_dec_put(rest, nodes1, strings1, made, sn, begin, end, left, w14_con_build(P88String{sa}, nb))

@unsafe
def w14_dec_con_node_got(rest: String, strings: Array<String>, +made: U32, +sn: U32, +begin: U32, +end: U32, +left: U32, nb: P88Node, pair: Array<P88Node> & P88Node) -> P88Decoded:
  (nodes2, na) = pair
  w14_dec_put(rest, nodes2, strings, made, sn, begin, end, left, w14_con_build(na, nb))

@unsafe
def w14_dec_con_pick(is_str: Bool, rest: String, nodes1: Array<P88Node>, strings: Array<String>, +made: U32, +sn: U32, +begin: U32, +end: U32, +left: U32, +a: U32, nb: P88Node) -> P88Decoded:
  match is_str:
    case True{}: w14_dec_con_str_got(rest, nodes1, made, sn, begin, end, left, nb, Array.get(String, strings, U32.sub(a, 2147483648)))
    case False{}: w14_dec_con_node_got(rest, strings, made, sn, begin, end, left, nb, Array.get(P88Node, nodes1, a))

@unsafe
def w14_dec_con_got(rest: String, strings: Array<String>, +made: U32, +sn: U32, +begin: U32, +end: U32, +left: U32, +a: U32, pair: Array<P88Node> & P88Node) -> P88Decoded:
  (nodes1, nb) = pair
  w14_dec_con_pick(U32.is_ge(a, 2147483648), rest, nodes1, strings, made, sn, begin, end, left, a, nb)

@unsafe
def w14_dec_con(text: String, nodes: Array<P88Node>, strings: Array<String>, +made: U32, +sn: U32, +begin: U32, +end: U32, +left: U32) -> P88Decoded:
  match text:
    case SCon{Chr{a0}, SCon{Chr{a1}, SCon{Chr{b0}, SCon{Chr{b1}, rest}}}}:
      w14_dec_con_got(rest, strings, made, sn, begin, end, left, w14_w(a0, a1), Array.get(P88Node, nodes, w14_w(b0, b1)))
    case _: P88DecodeError{"w14 con eof"}

@unsafe
def w14_dec_kterm_f(rest: String, strings2: Array<String>, +made: U32, +sn: U32, +begin: U32, +end: U32, +left: U32, ta: String, tb: String, +c: U32, +d: U32, ne: P88Node, +g: U32, +h: U32, pf: Array<P88Node> & P88Node) -> P88Decoded:
  (nodes2, nf) = pf
  w14_dec_put(rest, nodes2, strings2, made, sn, begin, end, left,
    P88Term{KTerm{ta, tb, c, d, w14_unwrap_terms(ne), w14_unwrap_strs(nf), g, h}})

@unsafe
def w14_dec_kterm_e(rest: String, strings2: Array<String>, +made: U32, +sn: U32, +begin: U32, +end: U32, +left: U32, ta: String, tb: String, +c: U32, +d: U32, +f: U32, +g: U32, +h: U32, pe: Array<P88Node> & P88Node) -> P88Decoded:
  (nodes1, ne) = pe
  w14_dec_kterm_f(rest, strings2, made, sn, begin, end, left, ta, tb, c, d, ne, g, h, Array.get(P88Node, nodes1, f))

@unsafe
def w14_dec_kterm_s1(rest: String, nodes: Array<P88Node>, +made: U32, +sn: U32, +begin: U32, +end: U32, +left: U32, ta: String, +c: U32, +d: U32, +e: U32, +f: U32, +g: U32, +h: U32, p1: Array<String> & String) -> P88Decoded:
  (strings2, tb) = p1
  w14_dec_kterm_e(rest, strings2, made, sn, begin, end, left, ta, tb, c, d, f, g, h, Array.get(P88Node, nodes, e))

@unsafe
def w14_dec_kterm_s0(rest: String, nodes: Array<P88Node>, +made: U32, +sn: U32, +begin: U32, +end: U32, +left: U32, +s1: U32, +c: U32, +d: U32, +e: U32, +f: U32, +g: U32, +h: U32, p0: Array<String> & String) -> P88Decoded:
  (strings1, ta) = p0
  w14_dec_kterm_s1(rest, nodes, made, sn, begin, end, left, ta, c, d, e, f, g, h, Array.get(String, strings1, s1))

@unsafe
def w14_dec_kterm4(text: String, nodes: Array<P88Node>, strings: Array<String>, +made: U32, +sn: U32, +begin: U32, +end: U32, +left: U32, +s0: U32, +s1: U32, +c: U32, +d: U32, +e: U32, +f: U32) -> P88Decoded:
  match text:
    case SCon{Chr{g0}, SCon{Chr{g1}, SCon{Chr{h0}, SCon{Chr{h1}, rest}}}}:
      w14_dec_kterm_s0(rest, nodes, made, sn, begin, end, left, s1, c, d, e, f, w14_w(g0, g1), w14_w(h0, h1), Array.get(String, strings, s0))
    case _: P88DecodeError{"w14 kterm4 eof"}

@unsafe
def w14_dec_kterm3(text: String, nodes: Array<P88Node>, strings: Array<String>, +made: U32, +sn: U32, +begin: U32, +end: U32, +left: U32, +s0: U32, +s1: U32, +c: U32, +d: U32) -> P88Decoded:
  match text:
    case SCon{Chr{e0}, SCon{Chr{e1}, SCon{Chr{f0}, SCon{Chr{f1}, rest}}}}:
      w14_dec_kterm4(rest, nodes, strings, made, sn, begin, end, left, s0, s1, c, d, w14_w(e0, e1), w14_w(f0, f1))
    case _: P88DecodeError{"w14 kterm3 eof"}

@unsafe
def w14_dec_kterm2(text: String, nodes: Array<P88Node>, strings: Array<String>, +made: U32, +sn: U32, +begin: U32, +end: U32, +left: U32, +s0: U32, +s1: U32) -> P88Decoded:
  match text:
    case SCon{Chr{c0}, SCon{Chr{c1}, SCon{Chr{d0}, SCon{Chr{d1}, rest}}}}:
      w14_dec_kterm3(rest, nodes, strings, made, sn, begin, end, left, s0, s1, w14_w(c0, c1), w14_w(d0, d1))
    case _: P88DecodeError{"w14 kterm2 eof"}

@unsafe
def w14_dec_kterm(text: String, nodes: Array<P88Node>, strings: Array<String>, +made: U32, +sn: U32, +begin: U32, +end: U32, +left: U32) -> P88Decoded:
  match text:
    case SCon{Chr{a0}, SCon{Chr{a1}, SCon{Chr{b0}, SCon{Chr{b1}, rest}}}}:
      w14_dec_kterm2(rest, nodes, strings, made, sn, begin, end, left, w14_w(a0, a1), w14_w(b0, b1))
    case _: P88DecodeError{"w14 kterm eof"}

@unsafe
def w14_dec_dispatch(+tag: U32, text: String, nodes: Array<P88Node>, strings: Array<String>, +made: U32, +sn: U32, +begin: U32, +end: U32, +left: U32) -> P88Decoded:
  match tag:
    case 1: w14_dec_con(text, nodes, strings, made, sn, begin, end, left)
    case 2: w14_dec_kterm(text, nodes, strings, made, sn, begin, end, left)
    case 0: w14_dec_put(text, nodes, strings, made, sn, begin, end, left, P88Empty{})
    case other: p88_fields(P88State{P88Cursor{text, 2}, nodes, strings, made, sn, begin, end}, tag, p88_roles(tag), Nil{}, left)

@unsafe
def w14_dec_rec_one(text: String, nodes: Array<P88Node>, strings: Array<String>, +made: U32, +sn: U32, +begin: U32, +end: U32, +left: U32) -> P88Decoded:
  match text:
    case SCon{Chr{t0}, SCon{Chr{t1}, SCon{Chr{w0}, SCon{Chr{w1}, rest}}}}:
      w14_dec_dispatch(w14_w(t0, t1), rest, nodes, strings, made, sn, begin, end, left)
    case _: P88DecodeError{"w14 rec eof"}

@unsafe
def w14_dec_recs(text, nodes, strings, made, sn, begin, end, left):
  match left:
    case 0: p88_roots(P88State{P88Cursor{text, 2}, nodes, strings, made, sn, begin, end}, [7, 9, 10, 11, 12], Nil{})
    case n: w14_dec_rec_one(text, nodes, strings, made, sn, begin, end, n)

law w14_dec_strings:
  for text: String
  for nodes: Array<P88Node>
  for strings: Array<String>
  for +idx: U32
  for +sn: U32
  for +total: U32
  for +begin: U32
  for +end: U32
  P88Decoded

@unsafe
def w14_dec_str_gate(ok: Bool, rest: String, nodes: Array<P88Node>, strings: Array<String>, +idx: U32, +sn: U32, +total: U32, +begin: U32, +end: U32, val: String) -> P88Decoded:
  match ok:
    case True{}: w14_dec_strings(rest, nodes, Array.set(String, strings, idx, val), U32.inc(idx), sn, total, begin, end)
    case False{}: P88DecodeError{"w14 string"}

@unsafe
def w14_dec_str_step(nodes: Array<P88Node>, strings: Array<String>, +idx: U32, +sn: U32, +total: U32, +begin: U32, +end: U32, rd: P88TextRead) -> P88Decoded:
  match rd:
    case P88TextRead{P88Cursor{rest, mode}, val}:
      w14_dec_str_gate(p130m_valid(mode), rest, nodes, strings, idx, sn, total, begin, end, val)

@unsafe
def w14_dec_strings_gate(more: Bool, text: String, nodes: Array<P88Node>, strings: Array<String>, +idx: U32, +sn: U32, +total: U32, +begin: U32, +end: U32) -> P88Decoded:
  match more:
    case True{}: w14_dec_str_step(nodes, strings, idx, sn, total, begin, end, p88_text(P88Cursor{text, 2}))
    case False{}: w14_dec_recs(text, nodes, strings, 0, sn, begin, end, total)

@unsafe
def w14_dec_strings(text, nodes, strings, idx, sn, total, begin, end):
  w14_dec_strings_gate(U32.is_lt(idx, sn), text, nodes, strings, idx, sn, total, begin, end)

@unsafe
def w14_dec_hdr2_gate(ok: Bool, t2: String, +n: U32, +sn: U32, +begin: U32, +end: U32) -> P88Decoded:
  match ok:
    case True{}: w14_dec_strings(t2, Array.new(P88Node, p88_array_depth(n, 1, 0n), P88Bad{}), Array.new(String, p88_array_depth(sn, 1, 0n), ""), 0, sn, n, begin, end)
    case False{}: P88DecodeError{"w14 header bounds"}

@unsafe
def w14_dec_hdr2(t1: String, +begin: U32, +end: U32) -> P88Decoded:
  match t1:
    case SCon{Chr{n0}, SCon{Chr{n1}, SCon{Chr{s0}, SCon{Chr{s1}, t2}}}}:
      +n = w14_w(n0, n1)
      +sn = w14_w(s0, s1)
      w14_dec_hdr2_gate(U32.is_ge(n, 1) && U32.is_le(n, 1048576) && U32.is_le(sn, 65536), t2, n, sn, begin, end)
    case _: P88DecodeError{"w14 header eof"}

@unsafe
def w14_dec_hdr1_gate(ok: Bool, t1: String, +begin: U32, +end: U32) -> P88Decoded:
  match ok:
    case True{}: w14_dec_hdr2(t1, begin, end)
    case False{}: P88DecodeError{"cache stamp"}

@unsafe
def w14_dec_hdr1(rd: P88TextRead, +expected_stamp: String, +begin: U32, +end: U32) -> P88Decoded:
  match rd:
    case P88TextRead{P88Cursor{t1, m1}, stamp}:
      w14_dec_hdr1_gate(p130m_valid(m1) && agy_str_eq(stamp, expected_stamp), t1, begin, end)

@unsafe
def w14_p88_decode_fast(+text: String, +expected_stamp: String, +begin: U32, +end: U32) -> P88Decoded:
  nt_choose(P88Decoded, U32.is_eq(p130m_initial(text, expected_stamp), 2),
    u => w14_dec_hdr1(p88_text(P88Cursor{text, 2}), expected_stamp, begin, end),
    u => p88_decode_admitted(text, expected_stamp, begin, end))

@unsafe
def w14_p88_cache_prepare(+path: String, +text: String, carrier: String, stamp: String) -> P86Preparation:
  +end = U32.add(p86_width(text, 0), 2)
  p88_cache_result(f_source_located(FSource{"Base", path, text}, 1, end), w14_p88_decode_fast(carrier, stamp, 1, end))

# --- OPT #3: Fast .p130 encoder (pre-interned top-16 strings + pre-alloc Absent + ADT leaf interning) ---

@unsafe
def w14_enc_seed_sm(sm: KDef) -> KDef:
  +s0 = p111v_put(sm, "", "S", 0, 0)
  +s1 = p111v_put(s0, "Absent", "S", 1, 0)
  +s2 = p111v_put(s1, "Var", "S", 2, 0)
  +s3 = p111v_put(s2, "App", "S", 3, 0)
  +s4 = p111v_put(s3, "All", "S", 4, 0)
  +s5 = p111v_put(s4, "ADT", "S", 5, 0)
  +s6 = p111v_put(s5, "Ref", "S", 6, 0)
  +s7 = p111v_put(s6, "Ann", "S", 7, 0)
  +s8 = p111v_put(s7, "Src", "S", 8, 0)
  +s9 = p111v_put(s8, "Def", "S", 9, 0)
  +s10 = p111v_put(s9, "Let", "S", 10, 0)
  +s11 = p111v_put(s10, "Bind", "S", 11, 0)
  +s12 = p111v_put(s11, "Mat", "S", 12, 0)
  +s13 = p111v_put(s12, "Use", "S", 13, 0)
  +s14 = p111v_put(s13, "Set", "S", 14, 0)
  p111v_put(s14, "Typ", "S", 15, 0)

@unsafe
def w14_enc_empty() -> W10IfEnc:
  +sr : List<&2, String> = [
    w10_if_push_str("Typ"), w10_if_push_str("Set"), w10_if_push_str("Use"), w10_if_push_str("Mat"),
    w10_if_push_str("Bind"), w10_if_push_str("Let"), w10_if_push_str("Def"), w10_if_push_str("Src"),
    w10_if_push_str("Ann"), w10_if_push_str("Ref"), w10_if_push_str("ADT"), w10_if_push_str("All"),
    w10_if_push_str("App"), w10_if_push_str("Var"), w10_if_push_str("Absent"), w10_if_push_str("")]
  +rec0 = w10_if_w(0, w10_if_w(0, SNil{}))
  +rec1 = w10_if_w(2, w10_if_w(8, w10_if_w(1, w10_if_w(0, w10_if_w(0, w10_if_w(0, w10_if_w(0, w10_if_w(0, w10_if_w(0, w10_if_w(0, SNil{}))))))))))
  W10IfEnc{w14_enc_seed_sm(missing()), sr, 16, missing(), Con{rec1, Con{rec0, Nil{}}}, 2}

@unsafe
def w14_fast_str_id(+s: String) -> U32:
  match s:
    case SNil{}: 0
    case SCon{Chr{c0}, _}:
      match c0:
        case 86: nt_choose(U32, agy_str_eq(s, "Var"), u => 2, u => 999)
        case 65:
          nt_choose(U32, agy_str_eq(s, "App"), u => 3,
          u => nt_choose(U32, agy_str_eq(s, "All"), v => 4,
          v => nt_choose(U32, agy_str_eq(s, "ADT"), w => 5,
          w => nt_choose(U32, agy_str_eq(s, "Ann"), x => 7,
          x => nt_choose(U32, agy_str_eq(s, "Absent"), y => 1, y => 999)))))
        case 82: nt_choose(U32, agy_str_eq(s, "Ref"), u => 6, u => 999)
        case 83:
          nt_choose(U32, agy_str_eq(s, "Src"), u => 8,
          u => nt_choose(U32, agy_str_eq(s, "Set"), v => 14, v => 999))
        case 68: nt_choose(U32, agy_str_eq(s, "Def"), u => 9, u => 999)
        case 76: nt_choose(U32, agy_str_eq(s, "Let"), u => 10, u => 999)
        case 66: nt_choose(U32, agy_str_eq(s, "Bind"), u => 11, u => 999)
        case 77: nt_choose(U32, agy_str_eq(s, "Mat"), u => 12, u => 999)
        case 85: nt_choose(U32, agy_str_eq(s, "Use"), u => 13, u => 999)
        case 84: nt_choose(U32, agy_str_eq(s, "Typ"), u => 15, u => 999)
        case _: 999

@unsafe
def w14_intern_str(+enc: W10IfEnc, +s: String) -> W10IfRes:
  +fid = w14_fast_str_id(s)
  nt_choose(W10IfRes, U32.is_lt(fid, 16),
    u => W10IfRes{enc, fid},
    u => w10_if_intern_str(enc, s))

@unsafe
def w14_intern_adt_emit(enc2: W10IfEnc, +key: String, +wire: String) -> W10IfRes:
  match enc2:
    case W10IfEnc{sm2, sr2, sn2, rm2, rr2, +rn2}:
      W10IfRes{W10IfEnc{sm2, sr2, sn2, p111v_put(rm2, key, "T", rn2, 0), Con{wire, rr2}, U32.inc(rn2)}, rn2}

@unsafe
def w14_intern_adt(enc: W10IfEnc, +name: String, +quant: U32) -> W10IfRes:
  match enc:
    case W10IfEnc{+sm, +sr, +sn, +rm, +rr, +rn}:
      +key = nt_choose(String, U32.is_eq(quant, 1), u => name, u => "0" ++ name)
      +hit = p111v_get(rm, key)
      nt_choose(W10IfRes, agy_str_eq(dk(hit), "Absent"),
        u =>
          +r1 = w14_intern_str(W10IfEnc{sm, sr, sn, rm, rr, rn}, name)
          +wire = w10_if_w(2, w10_if_w(8,
            w10_if_w(5, w10_if_w(w10_if_res_id(r1), w10_if_w(0, w10_if_w(quant,
            w10_if_w(0, w10_if_w(0, w10_if_w(0, w10_if_w(0, SNil{}))))))))))
          w14_intern_adt_emit(w10_if_res_enc(r1), key, wire),
        u => W10IfRes{W10IfEnc{sm, sr, sn, rm, rr, rn}, da(hit)})

law w14_enc_term:
  for +enc: W10IfEnc
  for t: KTerm
  W10IfRes

@unsafe
def w14_enc_terms(enc: W10IfEnc, xs: List<&2, KTerm>) -> W10IfRes:
  match xs:
    case Nil{}: W10IfRes{enc, 0}
    case Con{h, t}:
      +r1 = w14_enc_term(enc, h)
      +r2 = w14_enc_terms(w10_if_res_enc(r1), t)
      w10_if_enc_con(w10_if_res_enc(r2), w10_if_res_id(r1), w10_if_res_id(r2))

@unsafe
def w14_enc_strs(enc: W10IfEnc, xs: List<&2, String>) -> W10IfRes:
  match xs:
    case Nil{}: W10IfRes{enc, 0}
    case Con{h, t}:
      +r1 = w14_intern_str(enc, h)
      +r2 = w14_enc_strs(w10_if_res_enc(r1), t)
      w10_if_enc_con(w10_if_res_enc(r2), U32.add(w10_if_res_id(r1), 2147483648), w10_if_res_id(r2))

@unsafe
def w14_enc_term_full(enc: W10IfEnc, +tag: String, +name: String, +id: U32, +quant: U32, kids: List<&2, KTerm>, removed: List<&2, String>, +ob: U32, +oe: U32) -> W10IfRes:
  +r0 = w14_intern_str(enc, tag)
  +r1 = w14_intern_str(w10_if_res_enc(r0), name)
  +r4 = w14_enc_terms(w10_if_res_enc(r1), kids)
  +r5 = w14_enc_strs(w10_if_res_enc(r4), removed)
  +wire = w10_if_w(2, w10_if_w(8,
    w10_if_w(w10_if_res_id(r0), w10_if_w(w10_if_res_id(r1), w10_if_w(id, w10_if_w(quant,
    w10_if_w(w10_if_res_id(r4), w10_if_w(w10_if_res_id(r5), w10_if_w(ob, w10_if_w(oe, SNil{}))))))))))
  w10_if_emit_rec(w10_if_res_enc(r5), wire)

@unsafe
def w14_enc_term(enc, t):
  match t:
    case KTerm{+tag, +name, +id, +quant, Nil{}, Nil{}, 0, 0}:
      nt_choose(W10IfRes, agy_str_eq(tag, "Absent") && U32.is_eq(id, 0) && U32.is_eq(quant, 0) && String.is_empty(name),
        u => W10IfRes{enc, 1},
        u => nt_choose(W10IfRes, agy_str_eq(tag, "ADT") && U32.is_eq(id, 0) && U32.is_le(quant, 1),
          v => w14_intern_adt(enc, name, quant),
          v => w14_enc_term_full(enc, tag, name, id, quant, Nil{}, Nil{}, 0, 0)))
    case KTerm{tag, name, id, quant, kids, removed, ob, oe}:
      w14_enc_term_full(enc, tag, name, id, quant, kids, removed, ob, oe)
    case KLambda{name, id, quant, kids, removed, ob, oe, qp}:
      +r0 = w14_intern_str(enc, name)
      +r3 = w14_enc_terms(w10_if_res_enc(r0), kids)
      +r4 = w14_enc_strs(w10_if_res_enc(r3), removed)
      +wire = w10_if_w(3, w10_if_w(8,
        w10_if_w(w10_if_res_id(r0), w10_if_w(id, w10_if_w(quant,
        w10_if_w(w10_if_res_id(r3), w10_if_w(w10_if_res_id(r4), w10_if_w(ob, w10_if_w(oe, w10_if_w(Bool.to_u32(qp), SNil{}))))))))))
      w10_if_emit_rec(w10_if_res_enc(r4), wire)
    case KLiteral{kind, number, text, ob, oe}:
      +r0 = w14_intern_str(enc, kind)
      +r2 = w14_intern_str(w10_if_res_enc(r0), text)
      +wire = w10_if_w(4, w10_if_w(5,
        w10_if_w(w10_if_res_id(r0), w10_if_w(number, w10_if_w(w10_if_res_id(r2), w10_if_w(ob, w10_if_w(oe, SNil{})))))))
      w10_if_emit_rec(w10_if_res_enc(r2), wire)

law w14_enc_def:
  for enc: W10IfEnc
  for d: KDef
  W10IfRes

@unsafe
def w14_enc_defs(enc: W10IfEnc, xs: List<&2, KDef>) -> W10IfRes:
  match xs:
    case Nil{}: W10IfRes{enc, 0}
    case Con{h, t}:
      +r1 = w14_enc_def(enc, h)
      +r2 = w14_enc_defs(w10_if_res_enc(r1), t)
      w10_if_enc_con(w10_if_res_enc(r2), w10_if_res_id(r1), w10_if_res_id(r2))

@unsafe
def w14_enc_def(enc, d):
  match d:
    case KDef{name, kind, arity, templates, typ, value, ctors, native, unsafe}:
      +r0 = w14_intern_str(enc, name)
      +r1 = w14_intern_str(w10_if_res_enc(r0), kind)
      +r4 = w14_enc_term(w10_if_res_enc(r1), typ)
      +r5 = w14_enc_term(w10_if_res_enc(r4), value)
      +r6 = w14_enc_defs(w10_if_res_enc(r5), ctors)
      +wire = w10_if_w(5, w10_if_w(9,
        w10_if_w(w10_if_res_id(r0), w10_if_w(w10_if_res_id(r1), w10_if_w(arity, w10_if_w(templates,
        w10_if_w(w10_if_res_id(r4), w10_if_w(w10_if_res_id(r5), w10_if_w(w10_if_res_id(r6),
        w10_if_w(Bool.to_u32(native), w10_if_w(Bool.to_u32(unsafe), SNil{})))))))))))
      w10_if_emit_rec(w10_if_res_enc(r6), wire)
    case KIndexLeaf{hash, bucket}:
      +r1 = w14_enc_defs(enc, bucket)
      +wire = w10_if_w(6, w10_if_w(2, w10_if_w(hash, w10_if_w(w10_if_res_id(r1), SNil{}))))
      w10_if_emit_rec(w10_if_res_enc(r1), wire)
    case KIndexNode{hash, mask, left, right}:
      +r2 = w14_enc_def(enc, left)
      +r3 = w14_enc_def(w10_if_res_enc(r2), right)
      +wire = w10_if_w(7, w10_if_w(4,
        w10_if_w(hash, w10_if_w(mask, w10_if_w(w10_if_res_id(r2), w10_if_w(w10_if_res_id(r3), SNil{}))))))
      w10_if_emit_rec(w10_if_res_enc(r3), wire)

@unsafe
def w14_enc_book_defs2(enc: W10IfEnc, xs: List<&2, KDef>, +bad: KDef, +ucache: KDef, +lcache: KDef) -> W10IfRes & W10IfAbi:
  match xs:
    case Nil{}: (W10IfRes{enc, 0}, W10IfAbi{ucache, lcache})
    case Con{+h, t}:
      +r1 = w14_enc_def(enc, h)
      +id1 = w10_if_res_id(r1)
      +u1 = w10_if_cache_put(h, id1, bad, ucache)
      +l1 = w10_if_cache_put_any(h, id1, lcache)
      w10_if_enc_book_join(id1, w14_enc_book_defs2(w10_if_res_enc(r1), t, bad, u1, l1))

@unsafe
def w14_emit_checked(+stamp: String, +s_book: List<&2, KDef>, +s_fresh: FFreshPrefixState, +s_ready: FReadyPrefixState, +s_state: KBasePrefixState, +s_world: KBasePreparedWorld) -> IO(U32):
  match s_ready s_state:
    case FReadyPrefixState{_, _, _, True{}} KBasePrefixState{_, _, _, _, True{}}:
      +bad = w10_if_mark_dups(s_book, missing(), missing())
      w10_if_emit_checked_go(stamp, s_fresh, s_ready, s_state, s_world, w14_enc_book_defs2(w14_enc_empty(), s_book, bad, missing(), missing()))
    case _ _: IO.die(U32, 1, "x86-iface: prepared interface state was not ready")

@unsafe
def w14_emit_extended(+stamp: String, +s_book: List<&2, KDef>, +s_fresh: FFreshPrefixState, +s_ready: FReadyPrefixState, +base_world: KBasePreparedWorld, +fresh_suffix: List<&2, KDef>) -> IO(U32):
  match base_world:
    case KBasePreparedWorld{KBasePrefixState{+b_bound, +b_delta, +b_stamp, +b_patches, _}, b_prefix, +b_final, +b_book, +b_checked, +b_seen, +b_todos, +b_cbound}:
      +final_suffix = base_prefix_final(fresh_suffix)
      +s_bound = norm_max(b_bound, norm_max_book(fresh_suffix))
      +s_state : KBasePrefixState = KBasePrefixState{s_bound, b_delta, b_stamp, b_patches, True{}}
      +s_final = List.append(&2, KDef, b_final, final_suffix)
      +s_wbook = kw_bound_book(w10_if_book_put_fast(b_book, final_suffix), U32.add(s_bound, b_stamp))
      +s_wchecked = book_final_reverse(final_suffix, b_checked)
      +s_wseen = kw_bound_book(w10_if_book_put_fast(b_seen, fresh_suffix), s_bound)
      +s_cbound = norm_max(b_cbound, norm_max_book(final_suffix))
      +s_world : KBasePreparedWorld = KBasePreparedWorld{s_state, s_book, s_final, s_wbook, s_wchecked, s_wseen, b_todos, s_cbound}
      w14_emit_checked(stamp, s_book, s_fresh, s_ready, s_state, s_world)

# --- OPT #1 + #4: Fast p86_plan (skip driver_report_data + owned on native) & lightweight p112s + w13d_p113pl_candidates_fast ---

@unsafe
def w14_p112s_light_book(+book: List<&2, KDef>, +constructors: List<&2, N_Constructor>) -> P112SPrepared:
  match book:
    case Con{+cache, +rest}:
      nt_choose(P112SPrepared, agy_str_eq(dk(cache), "BookCache"),
        v => P112SPrepared{Con{KDef{dn(cache), dk(cache), da(cache), dx(cache), dt(cache), dv(cache),
          [index_first(dc(cache)), KDef{"$native.static", "NativeStaticContext", 0, 0, kt("P112StaticImage", "", 0, 0, []), {KTerm{"Absent", "", 0, 0, Nil{}, Nil{}, 0, 0} : KTerm}, [missing(), nc_ctor_prepare(Con{cache, rest}), p112s_ctors(constructors, 0, missing()), missing()], False{}, False{}}], db(cache), du(cache)}, rest}, [], ""},
        v => P112SPrepared{book, [], "static preparation requires a fresh cached request"})
    case _: P112SPrepared{book, [], "static preparation requires a fresh cached request"}

@unsafe
def w14_p112s_light(+book: List<&2, KDef>, +constructors: List<&2, N_Constructor>) -> P112SPrepared:
  nt_choose(P112SPrepared, nc_pack_foreign(book), u => P112SPrepared{book, [], ""},
    u => w14_p112s_light_book(book, constructors))

@unsafe
def w14_plan_checked(+load: FPrefixLoad, +world: KBasePreparedWorld, +suffix: List<&2, KDef>, result: DResult) -> P86Plan:
  match result:
    case DResult{+error, +book, diagnostic}:
      kc(P86Plan, String.is_empty(error),
        u =>
          +oerr = driver_emit_owned(suffix)
          kc(P86Plan, String.is_empty(oerr),
            v =>
              +jerr = j_compile_error(book)
              kc(P86Plan, String.is_empty(jerr),
                w => p86_plan_context(book_context_world(book, load, world), ""),
                w => P86PlanError{"compile: " ++ jerr}),
            v => P86PlanError{"compile: " ++ oerr}),
        u => P86PlanError{"check: " ++ error})

@unsafe
def w14_plan_loaded(+seed: P86Seed, +load: FPrefixLoad) -> P86Plan:
  match seed load:
    case P86Seed{base, book, fresh, ready, +world} FPrefixLoad{FLoadTrace{FResult{original, +error, imports}, done, sources}, prefix, +suffix, eligible}:
      kc(P86Plan, String.is_empty(error),
        u => w14_plan_checked(load, world, suffix, nt_choose(DResult, p143cg_enough(suffix, 256),
          v => p143cb_program(load, Nil{}, world, True{}),
          v => check_program_diagnostic_world(load, Nil{}, world))),
        u => P86PlanError{"parse: " ++ error})
'''


def patch_m11_v3(src: str) -> str:
    # Insert W14_V3_BEND right before w10_if_emit_freshened
    anchor = "@unsafe\ndef w10_if_emit_freshened("
    assert anchor in src, "anchor not found"
    src = src.replace(anchor, W14_V3_BEND + "\n" + anchor, 1)

    # Wire w14_emit_extended in w10_if_emit_freshened
    src = src.replace(
        "w10_if_emit_extended(stamp, s_book, s_fresh, s_ready, base_world, fresh_suffix),",
        "w14_emit_extended(stamp, s_book, s_fresh, s_ready, base_world, fresh_suffix),",
        1,
    ) if "w10_if_emit_extended(" in src else src.replace(
        "w10_if_emit_extended(",
        "w14_emit_extended(",
        1,
    )
    assert "w14_emit_extended(" in src, "w14_emit_extended wire failed"

    # Wire w14_emit_checked in fallback branch of w10_if_emit_freshened
    src = src.replace(
        "w10_if_emit_checked(stamp, s_book, s_fresh, s_ready, s_state, s_world),",
        "w14_emit_checked(stamp, s_book, s_fresh, s_ready, s_state, s_world),",
        1,
    )

    # Wire OPT #1: w13d_p113pl_candidates_fast + skip nq_signatures + lightweight p112s_light + skip p128br_scan
    old_abi = """@unsafe
def w10_if_fast_abi_run(+seed: P86Seed, +suffix: List<&2, KDef>, +book: List<&2, KDef>, +names: List<&2, String>, +bangs: List<&2, String>, +workers: List<&2, P113DFunction>, split: KDef & List<&2, String>) -> IO(U32):
  (+seeded_sigs, +active_filtered) = split
  +sigs = book_cached(nq_signatures(book, names), 0)
  +raw = p113pl_candidates(book, active_filtered, bangs, sigs)
  +fns0 = p113d_passes(p126sc_candidates(raw), seeded_sigs, nt_reverse(P113DFunction, workers, Nil{}), 32)
  +abi : W10IfAbi = W10IfAbi{w10_if_add_direct(fns0, missing()), w10_if_add_public_names(book, names, missing())}
  w10_if_emit_seed(seed, suffix, abi)

@unsafe
def w10_if_fast_abi_scan(+seed: P86Seed, +suffix: List<&2, KDef>, +suf_set: KDef, +book: List<&2, KDef>, +names: List<&2, String>, +bangs: List<&2, String>, scan: P128BROpen) -> IO(U32):
  match scan:
    case P128BROpen{+workers, helpers, retry, +serr}:
      nt_choose(IO(U32), String.is_empty(serr),
        u =>
          +worker_sigs = p113e_signatures(workers, missing())
          +remaining = p167ob_remaining(book, names, bangs, worker_sigs)
          +filtered = w7_filter_remaining(book, remaining, bangs)
          w10_if_fast_abi_run(seed, suffix, book, names, bangs, workers, w10_if_split_upstream(book, suf_set, filtered, worker_sigs, Nil{})),
        u => IO.die(U32, 1, "x86-iface: early scalar scan: " ++ serr))

@unsafe
def w10_if_fast_abi_prep(+seed: P86Seed, +suffix: List<&2, KDef>, +names: List<&2, String>, prep: P112SPrepared) -> IO(U32):
  match prep:
    case P112SPrepared{+sbook, nodes, +perr}:
      nt_choose(IO(U32), String.is_empty(perr),
        u =>
          +suf_set = w10_if_suffix_set(suffix, missing())
          +bangs = nc_bangs_names(sbook, names)
          +scan_names = w10_if_drop_upstream_stubs(sbook, suf_set, no_candidate_names(sbook, names, bangs))
          w10_if_fast_abi_scan(seed, suffix, suf_set, sbook, names, bangs,
            p128br_scan(sbook, scan_names, Nil{}, Nil{}, Nil{}, Nil{})),
        u => IO.die(U32, 1, "x86-iface: static prepare: " ++ perr))

@unsafe
def w10_if_fast_abi_req(+seed: P86Seed, +suffix: List<&2, KDef>, request: NR_Request) -> IO(U32):
  match request:
    case NR_Request{+source, +book, +names, paths, scope, +bound}:
      +err = nc_compile_error_known(source, bound)
      nt_choose(IO(U32), String.is_empty(err),
        u =>
          +ctors = nc_add_ctors(nc_default_ctors(), p144o_constructors(source, source, p144o_payload(nc_ctor_context(book))))
          w10_if_fast_abi_prep(seed, suffix, names, p112s_prepare(book, names, ctors)),
        u => IO.die(U32, 1, "x86-iface: " ++ err))"""

    new_abi = """@unsafe
def w10_if_fast_abi_run(+seed: P86Seed, +suffix: List<&2, KDef>, +book: List<&2, KDef>, +names: List<&2, String>, +bangs: List<&2, String>, +workers: List<&2, P113DFunction>, split: KDef & List<&2, String>) -> IO(U32):
  (+seeded_sigs, +active_filtered) = split
  +raw = w13d_p113pl_candidates_fast(book, active_filtered, bangs)
  +fns0 = p113d_passes(p126sc_candidates(raw), seeded_sigs, nt_reverse(P113DFunction, workers, Nil{}), 32)
  +abi : W10IfAbi = W10IfAbi{w10_if_add_direct(fns0, missing()), w10_if_add_public_names(book, names, missing())}
  w10_if_emit_seed(seed, suffix, abi)

@unsafe
def w10_if_fast_abi_prep(+seed: P86Seed, +suffix: List<&2, KDef>, +names: List<&2, String>, prep: P112SPrepared) -> IO(U32):
  match prep:
    case P112SPrepared{+sbook, nodes, +perr}:
      nt_choose(IO(U32), String.is_empty(perr),
        u =>
          +suf_set = w10_if_suffix_set(suffix, missing())
          +bangs = nc_bangs_names(sbook, names)
          +filtered = w7_filter_remaining(sbook, names, bangs)
          w10_if_fast_abi_run(seed, suffix, sbook, names, bangs, Nil{}, w10_if_split_upstream(sbook, suf_set, filtered, missing(), Nil{})),
        u => IO.die(U32, 1, "x86-iface: static prepare: " ++ perr))

@unsafe
def w10_if_fast_abi_req(+seed: P86Seed, +suffix: List<&2, KDef>, request: NR_Request) -> IO(U32):
  match request:
    case NR_Request{+source, +book, +names, paths, scope, +bound}:
      +err = nc_compile_error_known(source, bound)
      nt_choose(IO(U32), String.is_empty(err),
        u =>
          +ctors = nc_add_ctors(nc_default_ctors(), p144o_constructors(source, source, p144o_payload(nc_ctor_context(book))))
          w10_if_fast_abi_prep(seed, suffix, names, w14_p112s_light(book, ctors)),
        u => IO.die(U32, 1, "x86-iface: " ++ err))"""
    assert old_abi in src, "old_abi not found"
    src = src.replace(old_abi, new_abi, 1)

    # Wire OPT #4: w14_plan_loaded in w10_if_run_trace
    src = src.replace(
        "p86_plan_loaded(seed, load)",
        "w14_plan_loaded(seed, load)",
        1,
    )
    assert "w14_plan_loaded(seed, load)" in src

    # Wire OPT #2: w14_p88_cache_prepare in w10_iface_request
    src = src.replace(
        "w10_if_run_prepared(path, source, p88_cache_prepare(base_path, base, carrier, stamp)),",
        "w10_if_run_prepared(path, source, w14_p88_cache_prepare(base_path, base, carrier, stamp)),",
        1,
    )
    assert "w14_p88_cache_prepare(" in src
    return src


def sha256(p: Path) -> str:
    h = hashlib.sha256()
    with p.open("rb") as f:
        for blk in iter(lambda: f.read(1 << 20), b""):
            h.update(blk)
    return h.hexdigest()


def run_native(binary: Path, args: list[str], out_f: Path, err_f: Path, cpu: int) -> tuple[float, str]:
    cmd = [
        "timeout", "120",
        "bash", "-c", 'ulimit -s 262144 && exec taskset -c "$1" "$2" "${@:3}"',
        "_", str(cpu), str(binary), *args,
    ]
    t0 = time.perf_counter()
    with out_f.open("wb") as of, err_f.open("wb") as ef:
        r = subprocess.run(cmd, stdout=of, stderr=ef, cwd=ROOT)
    ms = round((time.perf_counter() - t0) * 1000.0, 1)
    err = err_f.read_text(encoding="utf-8", errors="replace").strip()
    if r.returncode != 0:
        raise RuntimeError(f"native failed rc={r.returncode}: {err[-800:]}")
    return ms, err


def link_bin(m11_o: Path, out_bin: Path, cpu: int) -> None:
    objs = [CACHE_OBJ / f"{m}.o" for m in MOD_NAMES[:-1]] + [m11_o]
    subprocess.run(
        ["timeout", "60", "taskset", "-c", str(cpu), CC, "-O2", "-no-pie",
         str(CACHE_OBJ / "merge_n6_w13.o"), *[str(o) for o in objs], str(RT), "-o", str(out_bin), "-lm", "-lpthread"],
        check=True,
    )


def main():
    d = json.loads(W13_RESULTS.read_text())
    recs = {r["module"]: r for r in d["stage2b_true_cold_pipelined_7core_native"]["iface_records"]}

    m11_src = "import Base\n" + (K14_DIR / "m11.bend").read_text(encoding="utf-8")
    m11_v3_path = TMP / "m11_v3.bend"
    m11_v3_path.write_text(patch_m11_v3(m11_src), encoding="utf-8")

    m11_v3_o = TMP / "m11_v3.o"
    m11_v3_err = TMP / "m11_v3.err"
    print("=== 1. Building native m11_v3.o on CPU 1 ===", flush=True)
    cmp_ms, _ = run_native(
        N5_O2,
        ["x86-module-fast", str(m11_v3_path), str(BASE_FILE), "cache", str(CACHE_IFACE / "m10.p130"), recs["m10"]["stamp"], "61935", "m11"],
        m11_v3_o, m11_v3_err, cpu=1,
    )
    print(f"  m11_v3.o built in {cmp_ms} ms ({m11_v3_o.stat().st_size:,} B)", flush=True)

    # Link both n6_base and n6_v3 (both -O0, exact apples-to-apples native comparison!)
    n6_base = TMP / "n6_base"
    n6_v3 = TMP / "n6_v3"
    link_bin(CACHE_OBJ / "m11.o", n6_base, cpu=1)
    link_bin(m11_v3_o, n6_v3, cpu=1)

    bench = {}
    for mod, prev, down_mod, down_fb in (
        ("m06", "m05b", "m07", 39837),
        ("m10", "m09", "m11", 61935),
    ):
        print(f"\n=== 2. Benchmarking {mod} on CPU 0 (n6_base vs n6_v3) ===", flush=True)
        out_base = TMP / f"b_{mod}.p130"
        out_v3 = TMP / f"v3_{mod}.p130"
        base_ms, base_stamp = run_native(
            n6_base,
            ["x86-iface", str(TMP / f"src/{mod}_exp.bend"), str(BASE_FILE), "cache", str(CACHE_IFACE / f"{prev}.p130"), recs[prev]["stamp"]],
            out_base, TMP / f"b_{mod}.err", cpu=0,
        )
        base_bytes = out_base.stat().st_size
        out_base.unlink()

        v3_ms, v3_stamp = run_native(
            n6_v3,
            ["x86-iface", str(TMP / f"src/{mod}_exp.bend"), str(BASE_FILE), "cache", str(CACHE_IFACE / f"{prev}.p130"), recs[prev]["stamp"]],
            out_v3, TMP / f"v3_{mod}.err", cpu=0,
        )
        v3_bytes = out_v3.stat().st_size
        speedup = round(base_ms / v3_ms, 3)
        stamp_ok = (base_stamp == v3_stamp)
        print(f"  {mod}: base={base_ms} ms ({base_bytes/1e6:.2f} MB) -> v3={v3_ms} ms ({v3_bytes/1e6:.2f} MB) | speedup={speedup}x | stamp_exact={stamp_ok}", flush=True)
        assert stamp_ok, f"STAMP MISMATCH on {mod}: {base_stamp} != {v3_stamp}"

        # Downstream parity: compile down_mod with n5_o2 x86-module-fast using v3_{mod}.p130!
        print(f"  Verifying downstream {down_mod}.o SHA-256 parity using v3_{mod}.p130...", flush=True)
        down_o = TMP / f"parity_{down_mod}.o"
        d_ms, _ = run_native(
            N5_O2,
            ["x86-module-fast", str(TMP / f"src/{down_mod}_exp.bend"), str(BASE_FILE), "cache", str(out_v3), v3_stamp, str(down_fb), down_mod],
            down_o, TMP / f"parity_{down_mod}.err", cpu=0,
        )
        got_sha = sha256(down_o)
        exp_sha = sha256(CACHE_OBJ / f"{down_mod}.o")
        parity_ok = (got_sha == exp_sha)
        print(f"  {down_mod}.o parity={parity_ok} ({d_ms} ms) sha={got_sha[:16]}...", flush=True)
        down_o.unlink()
        out_v3.unlink()
        assert parity_ok, f"DOWNSTREAM PARITY MISMATCH on {down_mod}.o: {got_sha} != {exp_sha}"

        bench[mod] = {
            "base_ms": base_ms, "v3_ms": v3_ms, "speedup": speedup,
            "base_bytes": base_bytes, "v3_bytes": v3_bytes,
            "size_reduction_pct": round(100.0 * (1.0 - v3_bytes / base_bytes), 2),
            "stamp_exact": stamp_ok,
            "downstream_mod": down_mod,
            "downstream_o_sha256": got_sha,
            "downstream_o_bit_identical": parity_ok,
        }

    n6_base.unlink()
    n6_v3.unlink()
    m11_v3_o.unlink()
    (OUT_DIR / "bench_v3_iter1.json").write_text(json.dumps(bench, indent=2))
    print("\nALL CHECKS PASSED! Saved bench_v3_iter1.json", flush=True)


if __name__ == "__main__":
    main()
