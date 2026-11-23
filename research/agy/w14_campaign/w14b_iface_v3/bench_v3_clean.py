#!/usr/bin/env python3
"""W14-B Step 2c: Clean strictly-linear x86-iface v3 (FIX A + FIX B + FIX C + OPT #4) in m11.
Benchmarks n6_base vs n6_v3c on m06 & m10 (CPU 0) with stage timings + downstream m07.o/m11.o SHA-256 parity.
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

W14_V3C_BEND = r'''
# === AGY-W14B-IFACE-V3C: Strictly-Linear Zero-Fallback Decoder + CPS-Pruned ABI + Strictly-Linear Fast Encoder ===

# --- FIX B: Zero-fallback direct-dispatch word-pair .p130 decoder (Con+KTerm+Leaf+Node inline = 92.5% of all recs) ---

@unsafe
def w14_w(+lo: U32, +hi: U32) -> U32:
  U32.or(U32.sub(lo, 65536), U32.shln(U32.sub(hi, 65536), 16n))

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
def w14_dec_leaf_got(rest: String, strings: Array<String>, +made: U32, +sn: U32, +begin: U32, +end: U32, +left: U32, +a: U32, pb: Array<P88Node> & P88Node) -> P88Decoded:
  (nodes1, nb) = pb
  w14_dec_put(rest, nodes1, strings, made, sn, begin, end, left, P88Def{KIndexLeaf{a, w14_unwrap_defs(nb)}})

@unsafe
def w14_dec_leaf(text: String, nodes: Array<P88Node>, strings: Array<String>, +made: U32, +sn: U32, +begin: U32, +end: U32, +left: U32) -> P88Decoded:
  match text:
    case SCon{Chr{a0}, SCon{Chr{a1}, SCon{Chr{b0}, SCon{Chr{b1}, rest}}}}:
      w14_dec_leaf_got(rest, strings, made, sn, begin, end, left, w14_w(a0, a1), Array.get(P88Node, nodes, w14_w(b0, b1)))
    case _: P88DecodeError{"w14 leaf eof"}

@unsafe
def w14_dec_node_d(rest: String, strings: Array<String>, +made: U32, +sn: U32, +begin: U32, +end: U32, +left: U32, +a: U32, +b: U32, nc: P88Node, pd: Array<P88Node> & P88Node) -> P88Decoded:
  (nodes2, nd) = pd
  w14_dec_put(rest, nodes2, strings, made, sn, begin, end, left, P88Def{KIndexNode{a, b, w14_unwrap_def(nc), w14_unwrap_def(nd)}})

@unsafe
def w14_dec_node_c(rest: String, strings: Array<String>, +made: U32, +sn: U32, +begin: U32, +end: U32, +left: U32, +a: U32, +b: U32, +d: U32, pc: Array<P88Node> & P88Node) -> P88Decoded:
  (nodes1, nc) = pc
  w14_dec_node_d(rest, strings, made, sn, begin, end, left, a, b, nc, Array.get(P88Node, nodes1, d))

@unsafe
def w14_dec_node2(text: String, nodes: Array<P88Node>, strings: Array<String>, +made: U32, +sn: U32, +begin: U32, +end: U32, +left: U32, +a: U32, +b: U32) -> P88Decoded:
  match text:
    case SCon{Chr{c0}, SCon{Chr{c1}, SCon{Chr{d0}, SCon{Chr{d1}, rest}}}}:
      w14_dec_node_c(rest, strings, made, sn, begin, end, left, a, b, w14_w(d0, d1), Array.get(P88Node, nodes, w14_w(c0, c1)))
    case _: P88DecodeError{"w14 node2 eof"}

@unsafe
def w14_dec_node(text: String, nodes: Array<P88Node>, strings: Array<String>, +made: U32, +sn: U32, +begin: U32, +end: U32, +left: U32) -> P88Decoded:
  match text:
    case SCon{Chr{a0}, SCon{Chr{a1}, SCon{Chr{b0}, SCon{Chr{b1}, rest}}}}:
      w14_dec_node2(rest, nodes, strings, made, sn, begin, end, left, w14_w(a0, a1), w14_w(b0, b1))
    case _: P88DecodeError{"w14 node eof"}

@unsafe
def w14_dec_rare_done(state: P88State, +tag: U32, values: List<&2, P88Node>, +left: U32) -> P88Decoded:
  match state:
    case P88State{P88Cursor{text, _}, nodes, strings, made, sn, +begin, +end}:
      w14_dec_put(text, nodes, strings, made, sn, begin, end, left, p88_build(tag, List.reverse(&2, P88Node, values), begin, end))

law w14_dec_rare_fields:
  for state: P88State
  for +tag: U32
  for roles: List<&2, U32>
  for values: List<&2, P88Node>
  for +left: U32
  P88Decoded

@unsafe
def w14_dec_rare_next(step: P88Step, +tag: U32, roles: List<&2, U32>, values: List<&2, P88Node>, +left: U32) -> P88Decoded:
  match step:
    case P88Step{state, P88Bad{}}: P88DecodeError{"w14 rare field"}
    case P88Step{state, val}: w14_dec_rare_fields(state, tag, roles, Con{val, values}, left)

@unsafe
def w14_dec_rare_fields(state, tag, roles, values, left):
  match roles:
    case Nil{}: w14_dec_rare_done(state, tag, values, left)
    case Con{role, rest}: w14_dec_rare_next(p88_field(state, role), tag, rest, values, left)

@unsafe
def w14_dec_dispatch(+tag: U32, text: String, nodes: Array<P88Node>, strings: Array<String>, +made: U32, +sn: U32, +begin: U32, +end: U32, +left: U32) -> P88Decoded:
  match tag:
    case 1: w14_dec_con(text, nodes, strings, made, sn, begin, end, left)
    case 2: w14_dec_kterm(text, nodes, strings, made, sn, begin, end, left)
    case 6: w14_dec_leaf(text, nodes, strings, made, sn, begin, end, left)
    case 7: w14_dec_node(text, nodes, strings, made, sn, begin, end, left)
    case 0: w14_dec_put(text, nodes, strings, made, sn, begin, end, left, P88Empty{})
    case other: w14_dec_rare_fields(P88State{P88Cursor{text, 2}, nodes, strings, made, sn, begin, end}, tag, p88_roles(tag), Nil{}, left)

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

# --- FIX C: STRICTLY LINEAR fast .p130 encoder (ZERO +enc! Pre-interned top strings + Absent + ADT leaf interning) ---

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
  p111v_put(s8, "Def", "S", 9, 0)

@unsafe
def w14_enc_empty() -> W10IfEnc:
  +sr : List<&2, String> = [
    w10_if_push_str("Def"), w10_if_push_str("Src"), w10_if_push_str("Ann"), w10_if_push_str("Ref"),
    w10_if_push_str("ADT"), w10_if_push_str("All"), w10_if_push_str("App"), w10_if_push_str("Var"),
    w10_if_push_str("Absent"), w10_if_push_str("")]
  +rec0 = w10_if_w(0, w10_if_w(0, SNil{}))
  +rec1 = w10_if_w(2, w10_if_w(8, w10_if_w(1, w10_if_w(0, w10_if_w(0, w10_if_w(0, w10_if_w(0, w10_if_w(0, w10_if_w(0, w10_if_w(0, SNil{}))))))))))
  W10IfEnc{w14_enc_seed_sm(missing()), sr, 10, missing(), Con{rec1, Con{rec0, Nil{}}}, 2}

@unsafe
def w14_fast_str_id(+s: String) -> U32:
  match s:
    case SNil{}: 0
    case SCon{Chr{c0}, _}:
      match c0:
        case 86: nt_choose(U32, agy_str_eq(s, "Var"), u => 2, u => 99)
        case 65:
          nt_choose(U32, agy_str_eq(s, "App"), u => 3,
          u => nt_choose(U32, agy_str_eq(s, "All"), v => 4,
          v => nt_choose(U32, agy_str_eq(s, "ADT"), w => 5,
          w => nt_choose(U32, agy_str_eq(s, "Ann"), x => 7,
          x => nt_choose(U32, agy_str_eq(s, "Absent"), y => 1, y => 99)))))
        case 82: nt_choose(U32, agy_str_eq(s, "Ref"), u => 6, u => 99)
        case 83: nt_choose(U32, agy_str_eq(s, "Src"), u => 8, u => 99)
        case 68: nt_choose(U32, agy_str_eq(s, "Def"), u => 9, u => 99)
        case _: 99

@unsafe
def w14_intern_str_pick(fast: Bool, +fid: U32, enc: W10IfEnc, +s: String) -> W10IfRes:
  match fast:
    case True{}: W10IfRes{enc, fid}
    case False{}: w10_if_intern_str(enc, s)

@unsafe
def w14_intern_str(enc: W10IfEnc, +s: String) -> W10IfRes:
  +fid = w14_fast_str_id(s)
  w14_intern_str_pick(U32.is_lt(fid, 10), fid, enc, s)

@unsafe
def w14_intern_adt_emit(enc2: W10IfEnc, +key: String, +wire: String) -> W10IfRes:
  match enc2:
    case W10IfEnc{sm2, sr2, sn2, rm2, rr2, +rn2}:
      W10IfRes{W10IfEnc{sm2, sr2, sn2, p111v_put(rm2, key, "T", rn2, 0), Con{wire, rr2}, U32.inc(rn2)}, rn2}

@unsafe
def w14_intern_adt_pick(miss: Bool, enc: W10IfEnc, +name: String, +quant: U32, +key: String, +hid: U32) -> W10IfRes:
  match miss:
    case True{}:
      +r1 = w14_intern_str(enc, name)
      +wire = w10_if_w(2, w10_if_w(8,
        w10_if_w(5, w10_if_w(w10_if_res_id(r1), w10_if_w(0, w10_if_w(quant,
        w10_if_w(0, w10_if_w(0, w10_if_w(0, w10_if_w(0, SNil{}))))))))))
      w14_intern_adt_emit(w10_if_res_enc(r1), key, wire)
    case False{}: W10IfRes{enc, hid}

@unsafe
def w14_intern_adt(enc: W10IfEnc, +name: String, +quant: U32) -> W10IfRes:
  match enc:
    case W10IfEnc{sm, sr, sn, +rm, rr, rn}:
      +key = nt_choose(String, U32.is_eq(quant, 1), u => name, u => "0" ++ name)
      +hit = p111v_get(rm, key)
      w14_intern_adt_pick(agy_str_eq(dk(hit), "Absent"), W10IfEnc{sm, sr, sn, rm, rr, rn}, name, quant, key, da(hit))

law w14_enc_term:
  for enc: W10IfEnc
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
def w14_enc_leaf_adt(is_adt: Bool, enc: W10IfEnc, +tag: String, +name: String, +id: U32, +quant: U32) -> W10IfRes:
  match is_adt:
    case True{}: w14_intern_adt(enc, name, quant)
    case False{}: w14_enc_term_full(enc, tag, name, id, quant, Nil{}, Nil{}, 0, 0)

@unsafe
def w14_enc_leaf_abs(is_abs: Bool, enc: W10IfEnc, +tag: String, +name: String, +id: U32, +quant: U32) -> W10IfRes:
  match is_abs:
    case True{}: W10IfRes{enc, 1}
    case False{}: w14_enc_leaf_adt(agy_str_eq(tag, "ADT") && U32.is_eq(id, 0) && U32.is_le(quant, 1), enc, tag, name, id, quant)

@unsafe
def w14_enc_term(enc, t):
  match t:
    case KTerm{+tag, +name, +id, +quant, Nil{}, Nil{}, 0, 0}:
      w14_enc_leaf_abs(agy_str_eq(tag, "Absent") && U32.is_eq(id, 0) && U32.is_eq(quant, 0) && String.is_empty(name), enc, tag, name, id, quant)
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

# --- FIX A + OPT #4: CPS-aware transitive pruning + fast plan ---

@unsafe
def w14a_collect_cps(+book: List<&2, KDef>, +suf_set: KDef, names: List<&2, String>, +sigs: KDef, +cps: KDef, +active: List<&2, String>) -> W10IfAbi & List<&2, String>:
  match names:
    case Nil{}: (W10IfAbi{sigs, cps}, nt_reverse(String, active, Nil{}))
    case Con{+name, +rest}:
      nt_choose(W10IfAbi & List<&2, String>, w10_if_abi_has(suf_set, name),
        u => w14a_collect_cps(book, suf_set, rest, sigs, cps, Con{name, active}),
        u =>
          +sk = w10_if_stub_kind(book, name)
          nt_choose(W10IfAbi & List<&2, String>, U32.is_ge(sk, 1000),
            v => w14a_collect_cps(book, suf_set, rest, p111v_put(sigs, p113d_public(book, name), "P113Direct", U32.sub(sk, 1000), 0), cps, active),
            v => nt_choose(W10IfAbi & List<&2, String>, U32.is_eq(sk, 2),
              w => w14a_collect_cps(book, suf_set, rest, sigs, p111v_put(cps, name, "W7Rem", 1, 0), active),
              w => w14a_collect_cps(book, suf_set, rest, sigs, cps, Con{name, active}))))

@unsafe
def w14a_prune_active(+book: List<&2, KDef>, +active: List<&2, String>, +bangs: List<&2, String>, +cps: KDef) -> List<&2, String>:
  +remSet = w7_pre_build_set(book, active, bangs, cps)
  w7_pre_peel(w7_pre_nodes(book, active, remSet, []), missing(), [], 32)

@unsafe
def w14a_fast_abi_go2(+seed: P86Seed, +suffix: List<&2, KDef>, +book: List<&2, KDef>, +names: List<&2, String>, +bangs: List<&2, String>, +workers: List<&2, P113DFunction>, pair: W10IfAbi, +active0: List<&2, String>) -> IO(U32):
  match pair:
    case W10IfAbi{+seeded_sigs, +cps}:
      +pruned = w14a_prune_active(book, active0, bangs, cps)
      +raw = w13d_p113pl_candidates_fast(book, pruned, bangs)
      +fns0 = p113d_passes(p126sc_candidates(raw), seeded_sigs, nt_reverse(P113DFunction, workers, Nil{}), 32)
      +abi : W10IfAbi = W10IfAbi{w10_if_add_direct(fns0, missing()), w10_if_add_public_names(book, names, missing())}
      w10_if_emit_seed(seed, suffix, abi)

@unsafe
def w14a_fast_abi_go(+seed: P86Seed, +suffix: List<&2, KDef>, +book: List<&2, KDef>, +names: List<&2, String>, +bangs: List<&2, String>, +workers: List<&2, P113DFunction>, res: W10IfAbi & List<&2, String>) -> IO(U32):
  (pair, +active0) = res
  w14a_fast_abi_go2(seed, suffix, book, names, bangs, workers, pair, active0)

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


def patch_m11_v3c(src: str) -> str:
    anchor = "@unsafe\ndef w10_if_emit_freshened("
    assert anchor in src
    src = src.replace(anchor, W14_V3C_BEND + "\n" + anchor, 1)

    src = src.replace(
        "w10_if_emit_extended(stamp, s_book, s_fresh, s_ready, base_world, fresh_suffix),",
        "w14_emit_extended(stamp, s_book, s_fresh, s_ready, base_world, fresh_suffix),",
        1,
    )
    src = src.replace(
        "w10_if_emit_checked(stamp, s_book, s_fresh, s_ready, s_state, s_world),",
        "w14_emit_checked(stamp, s_book, s_fresh, s_ready, s_state, s_world),",
        1,
    )

    old_scan = """@unsafe
def w10_if_fast_abi_scan(+seed: P86Seed, +suffix: List<&2, KDef>, +suf_set: KDef, +book: List<&2, KDef>, +names: List<&2, String>, +bangs: List<&2, String>, scan: P128BROpen) -> IO(U32):
  match scan:
    case P128BROpen{+workers, helpers, retry, +serr}:
      nt_choose(IO(U32), String.is_empty(serr),
        u =>
          +worker_sigs = p113e_signatures(workers, missing())
          +remaining = p167ob_remaining(book, names, bangs, worker_sigs)
          +filtered = w7_filter_remaining(book, remaining, bangs)
          w10_if_fast_abi_run(seed, suffix, book, names, bangs, workers, w10_if_split_upstream(book, suf_set, filtered, worker_sigs, Nil{})),
        u => IO.die(U32, 1, "x86-iface: early scalar scan: " ++ serr))"""

    new_scan = """@unsafe
def w10_if_fast_abi_scan(+seed: P86Seed, +suffix: List<&2, KDef>, +suf_set: KDef, +book: List<&2, KDef>, +names: List<&2, String>, +bangs: List<&2, String>, scan: P128BROpen) -> IO(U32):
  match scan:
    case P128BROpen{+workers, helpers, retry, +serr}:
      nt_choose(IO(U32), String.is_empty(serr),
        u =>
          +worker_sigs = p113e_signatures(workers, missing())
          +remaining = p167ob_remaining(book, names, bangs, worker_sigs)
          w14a_fast_abi_go(seed, suffix, book, names, bangs, workers, w14a_collect_cps(book, suf_set, remaining, worker_sigs, missing(), Nil{})),
        u => IO.die(U32, 1, "x86-iface: early scalar scan: " ++ serr))"""
    assert old_scan in src
    src = src.replace(old_scan, new_scan, 1)

    src = src.replace("p86_plan_loaded(seed, load)", "w14_plan_loaded(seed, load)", 1)
    src = src.replace(
        "w10_if_run_prepared(path, source, p88_cache_prepare(base_path, base, carrier, stamp)),",
        "w10_if_run_prepared(path, source, w14_p88_cache_prepare(base_path, base, carrier, stamp)),",
        1,
    )
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
    p = TMP / "m11_v3c.bend"
    p.write_text(patch_m11_v3c(m11_src), encoding="utf-8")
    o = TMP / "m11_v3c.o"
    print("=== 1. Compiling m11_v3c.o on CPU 1 ===", flush=True)
    cmp_ms, _ = run_native(N5_O2, ["x86-module-fast", str(p), str(BASE_FILE), "cache", str(CACHE_IFACE / "m10.p130"), recs["m10"]["stamp"], "61935", "m11"], o, TMP / "m11_v3c.err", 1)
    print(f"  m11_v3c.o built in {cmp_ms} ms ({o.stat().st_size:,} B)", flush=True)

    n6_base = TMP / "n6_base"
    n6_v3c = TMP / "n6_v3c"
    link_bin(CACHE_OBJ / "m11.o", n6_base, 1)
    link_bin(o, n6_v3c, 1)

    res = {}
    for mod, prev, down_mod, down_fb in (("m06", "m05b", "m07", 39837), ("m10", "m09", "m11", 61935)):
        print(f"\n=== 2. Benchmarking {mod} on CPU 0 (n6_base vs n6_v3c) ===", flush=True)
        out_b = TMP / f"b_{mod}.p130"
        out_v = TMP / f"v3c_{mod}.p130"
        b_ms, b_st = run_native(n6_base, ["x86-iface", str(TMP / f"src/{mod}_exp.bend"), str(BASE_FILE), "cache", str(CACHE_IFACE / f"{prev}.p130"), recs[prev]["stamp"]], out_b, TMP / f"b_{mod}.err", 0)
        b_sz = out_b.stat().st_size

        v_ms, v_st = run_native(n6_v3c, ["x86-iface", str(TMP / f"src/{mod}_exp.bend"), str(BASE_FILE), "cache", str(CACHE_IFACE / f"{prev}.p130"), recs[prev]["stamp"]], out_v, TMP / f"v3c_{mod}.err", 0)
        v_sz = out_v.stat().st_size
        sp = round(b_ms / v_ms, 3)
        print(f"  {mod}: base={b_ms} ms ({b_sz/1e6:.2f} MB) -> v3c={v_ms} ms ({v_sz/1e6:.2f} MB) | speedup={sp}x | stamp_exact={b_st == v_st}", flush=True)
        assert b_st == v_st

        # Downstream parity: compile down_mod with n5_o2 from BOTH out_b and out_v!
        o_b = TMP / f"par_b_{down_mod}.o"
        o_v = TMP / f"par_v_{down_mod}.o"
        run_native(N5_O2, ["x86-module-fast", str(TMP / f"src/{down_mod}_exp.bend"), str(BASE_FILE), "cache", str(out_b), b_st, str(down_fb), down_mod], o_b, TMP / f"par_b_{down_mod}.err", 0)
        run_native(N5_O2, ["x86-module-fast", str(TMP / f"src/{down_mod}_exp.bend"), str(BASE_FILE), "cache", str(out_v), v_st, str(down_fb), down_mod], o_v, TMP / f"par_v_{down_mod}.err", 0)
        sh_b, sh_v = sha256(o_b), sha256(o_v)
        print(f"  {down_mod}.o SHA-256 parity={sh_b == sh_v} ({sh_v[:16]}...)", flush=True)
        assert sh_b == sh_v
        for f in (out_b, out_v, o_b, o_v):
            f.unlink()
        res[mod] = {"base_ms": b_ms, "v3c_ms": v_ms, "speedup": sp, "base_bytes": b_sz, "v3c_bytes": v_sz, "stamp_exact": True, "downstream_o_sha256": sh_v, "downstream_o_bit_identical": True}

    n6_base.unlink()
    n6_v3c.unlink()
    o.unlink()
    (OUT_DIR / "bench_v3c.json").write_text(json.dumps(res, indent=2))
    print("\nALL PASSED! Saved bench_v3c.json", flush=True)


if __name__ == "__main__":
    main()
