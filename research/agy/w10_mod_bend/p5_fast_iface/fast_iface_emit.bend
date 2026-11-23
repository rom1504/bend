# === AGY-W10-P5D-FAST-IFACE: Pure-Bend Fast x86-iface (.p130 interface carrier emitter) ===
# Eliminates 4 major bottlenecks while preserving 100% bit-for-bit identical .p130 output:
#   1. Single-parse: parse source ONCE via f_prefix_graph_trace, feeding FPrefixLoad directly
#      to p86_plan_loaded and reusing load.suffix (eliminates duplicate w10_if_load_suffix parse).
#   2. Direct-ABI-only lowering: extract W10IfAbi directly from p112s_prepare + p128br_scan +
#      p113pl_candidates + p113d_passes + req.names (skips w4p, p168_closed/inlining/retry,
#      p111_program CPS lowering, p169s_lowered IR verification/tables/registry, x198pw_after).
#   3. World-resumed stub check: use base_prefix_resume_world(base_world, fresh_suffix, bound)
#      instead of re-replaying base_state from scratch via base_prefix_resume_saved.
#   4. Zero-redundancy .p130 encoding:
#      (a) right-consing w10_if_w(n, tail) eliminates O(k^2) ++ chains in record encoding;
#      (b) reuse e1 (s_state) and e0 (s_book) IDs for world.state and world.prefix;
#      (c) cache unique, non-patched s_book KDef node IDs in def_cache for O(1) encoding
#          across world.{final,book,checked,seen} and s_ready.names.

# --- Dual 32-bit FNV-1a interface hasher (alpha-invariant, ignores spans & bodies) ---

@unsafe
def w10_if_h_init() -> W10IfHash:
  W10IfHash{2166136261, 3759247821}

@unsafe
def w10_if_h_byte(h: W10IfHash, +b: U32) -> W10IfHash:
  match h:
    case W10IfHash{h1, h2}:
      W10IfHash{
        U32.mul(U32.xor(h1, b), 16777619),
        U32.mul(U32.xor(h2, U32.xor(b, 165)), 16777619)
      }

@unsafe
def w10_if_h_u32(h: W10IfHash, +v: U32) -> W10IfHash:
  +h1 = w10_if_h_byte(h, U32.and(v, 255))
  +h2 = w10_if_h_byte(h1, U32.and(U32.shrn(v, 8n), 255))
  +h3 = w10_if_h_byte(h2, U32.and(U32.shrn(v, 16n), 255))
  w10_if_h_byte(h3, U32.shrn(v, 24n))

@unsafe
def w10_if_h_str(+h: W10IfHash, +s: String) -> W10IfHash:
  match s:
    case SNil{}: w10_if_h_byte(h, 255)
    case SCon{c, +rest}:
      +u = Char.to_u32(c)
      nt_choose(W10IfHash, U32.is_lt(u, 256),
        k => w10_if_h_str(w10_if_h_byte(h, u), rest),
        k => w10_if_h_str(w10_if_h_u32(h, u), rest))

@unsafe
def w10_if_hex_nibble(+d: U32) -> Char:
  Chr{nt_choose(U32, U32.is_lt(d, 10), u => U32.add(48, d), u => U32.add(87, d))}

@unsafe
def w10_if_hex8(+v: U32) -> String:
  +c0 = w10_if_hex_nibble(U32.and(U32.shrn(v, 28n), 15))
  +c1 = w10_if_hex_nibble(U32.and(U32.shrn(v, 24n), 15))
  +c2 = w10_if_hex_nibble(U32.and(U32.shrn(v, 20n), 15))
  +c3 = w10_if_hex_nibble(U32.and(U32.shrn(v, 16n), 15))
  +c4 = w10_if_hex_nibble(U32.and(U32.shrn(v, 12n), 15))
  +c5 = w10_if_hex_nibble(U32.and(U32.shrn(v, 8n), 15))
  +c6 = w10_if_hex_nibble(U32.and(U32.shrn(v, 4n), 15))
  +c7 = w10_if_hex_nibble(U32.and(v, 15))
  SCon{c0, SCon{c1, SCon{c2, SCon{c3, SCon{c4, SCon{c5, SCon{c6, SCon{c7, SNil{}}}}}}}}}

@unsafe
def w10_if_stamp_str(h: W10IfHash) -> String:
  match h:
    case W10IfHash{h1, h2}:
      "p130-word-pair-v1:w10-iface-v1:" ++ w10_if_hex8(h1) ++ w10_if_hex8(h2)

@unsafe
def w10_if_env_find(env: List<&2, U32>, +id: U32, +idx: U32) -> U32:
  match env:
    case Nil{}: 4294967295
    case Con{x, +rest}:
      nt_choose(U32, U32.is_eq(x, id), u => idx, u => w10_if_env_find(rest, id, U32.inc(idx)))

law w10_if_h_term:
  for +h: W10IfHash
  for +t: KTerm
  for +env: List<&2, U32>
  W10IfHash

@unsafe
def w10_if_h_terms(h: W10IfHash, ts: List<&2, KTerm>, +env: List<&2, U32>) -> W10IfHash:
  match ts:
    case Nil{}: w10_if_h_byte(h, 0)
    case Con{x, rest}: w10_if_h_terms(w10_if_h_term(w10_if_h_byte(h, 1), x, env), rest, env)

@unsafe
def w10_if_h_bind2(h: W10IfHash, kids: List<&2, KTerm>, +id: U32, +env: List<&2, U32>) -> W10IfHash:
  match kids:
    case Con{k0, Con{k1, Nil{}}}:
      w10_if_h_term(w10_if_h_term(h, k0, env), k1, Con{id, env})
    case other: w10_if_h_terms(h, other, env)

@unsafe
def w10_if_h_term(h, t, env):
  match t:
    case KTerm{+tag, +name, +id, +quant, +kids, removed, ob, oe}:
      +h1 = w10_if_h_u32(w10_if_h_str(w10_if_h_byte(h, 2), tag), quant)
      nt_choose(W10IfHash, agy_str_eq(tag, "Var"),
        u =>
          +db = w10_if_env_find(env, id, 0)
          nt_choose(W10IfHash, U32.is_eq(db, 4294967295),
            v => w10_if_h_str(w10_if_h_u32(h1, db), name),
            v => w10_if_h_u32(h1, db)),
        u => nt_choose(W10IfHash, agy_str_eq(tag, "All") || agy_str_eq(tag, "Let"),
          v => w10_if_h_bind2(h1, kids, id, env),
          v => nt_choose(W10IfHash, agy_str_eq(tag, "Slf"),
            w => w10_if_h_terms(h1, kids, Con{id, env}),
            w => w10_if_h_terms(w10_if_h_str(h1, name), kids, env))))
    case KLambda{name, +id, +quant, +kids, removed, ob, oe, +qp}:
      +h1 = w10_if_h_byte(w10_if_h_u32(w10_if_h_byte(h, 3), quant), Bool.to_u32(qp))
      w10_if_h_terms(h1, kids, Con{id, env})
    case KLiteral{+kind, +number, +text, ob, oe}:
      w10_if_h_str(w10_if_h_u32(w10_if_h_str(w10_if_h_byte(h, 4), kind), number), text)

@unsafe
def w10_if_abi_has(+idx: KDef, +key: String) -> Bool:
  Bool.not(agy_str_eq(dk(p111v_get(idx, key)), "Absent"))

@unsafe
def w10_if_force_cps(+abi: W10IfAbi, +name: String) -> Bool:
  match abi:
    case W10IfAbi{+direct, +public}:
      +key = "$direct." ++ name
      w10_if_abi_has(public, key) && Bool.not(w10_if_abi_has(direct, key))

@unsafe
def w10_if_h_ctors(h: W10IfHash, cs: List<&2, KDef>) -> W10IfHash:
  match cs:
    case Nil{}: w10_if_h_byte(h, 0)
    case Con{KDef{+name, +kind, +arity, +templates, +typ, value, ctors, native, unsafe}, rest}:
      +h1 = w10_if_h_u32(w10_if_h_u32(w10_if_h_str(w10_if_h_str(w10_if_h_byte(h, 5), name), kind), arity), templates)
      w10_if_h_ctors(w10_if_h_term(h1, typ, Nil{}), rest)
    case Con{_, rest}: w10_if_h_ctors(h, rest)

@unsafe
def w10_if_h_defs(+h: W10IfHash, ds: List<&2, KDef>, +abi: W10IfAbi) -> W10IfHash:
  match ds:
    case Nil{}: h
    case Con{KDef{+name, +kind, +arity, +templates, +typ, value, +ctors, native, unsafe}, +rest}:
      nt_choose(W10IfHash, agy_str_eq(name, "main"),
        u => w10_if_h_defs(h, rest, abi),
        u =>
          +h1 = w10_if_h_u32(w10_if_h_u32(w10_if_h_str(w10_if_h_str(w10_if_h_byte(h, 6), name), kind), arity), templates)
          +h2 = w10_if_h_term(h1, typ, Nil{})
          +h3 = nt_choose(W10IfHash, agy_str_eq(kind, "ADT"),
            v => w10_if_h_ctors(h2, ctors),
            v => nt_choose(W10IfHash, agy_str_eq(kind, "Def"),
              w => w10_if_h_byte(h2, nt_choose(U32, w10_if_force_cps(abi, name), z => 2, z => 1)),
              w => h2))
          w10_if_h_defs(h3, rest, abi))
    case Con{_, rest}: w10_if_h_defs(h, rest, abi)

# --- Fast direct-only ABI extraction (zero CPS lowering, zero IR verification, zero x86 pass) ---

@unsafe
def w10_if_add_direct(fns: List<&2, P113DFunction>, acc: KDef) -> KDef:
  match fns:
    case Nil{}: acc
    case Con{P113DFunction{+name, params, result, public, body}, rest}:
      w10_if_add_direct(rest, p111v_put(acc, name, "D", 1, 0))

@unsafe
def w10_if_add_public(segs: List<&2, N111Segment>, acc: KDef) -> KDef:
  match segs:
    case Nil{}: acc
    case Con{N111Segment{+name, arity, result, incoming, flags, body}, rest}:
      w10_if_add_public(rest, p111v_put(acc, name, "P", 1, 0))

@unsafe
def w10_if_add_public_names(+book: List<&2, KDef>, names: List<&2, String>, acc: KDef) -> KDef:
  match names:
    case Nil{}: acc
    case Con{+name, rest}:
      w10_if_add_public_names(book, rest, p111v_put(acc, p113d_public(book, name), "P", 1, 0))

@unsafe
def w10_if_collect_abi(cursor: P134Cursor, +direct: KDef, +public: KDef) -> W10IfAbi:
  match cursor:
    case P134Private{fns, ctx, next}:
      w10_if_collect_abi(next, w10_if_add_direct(fns, direct), public)
    case P134Legacy{entries, ctx, next}:
      w10_if_collect_abi(next, direct, public)
    case P134Public{segs, ctx, next}:
      w10_if_collect_abi(next, direct, w10_if_add_public(segs, public))
    case _: W10IfAbi{direct, public}

# --- ABI-matched self-recursive stub builder & span zeroing ---

law w10_if_zero_term:
  for +t: KTerm
  KTerm

@unsafe
def w10_if_zero_terms(ts: List<&2, KTerm>) -> List<&2, KTerm>:
  match ts:
    case Nil{}: Nil{}
    case Con{x, rest}: Con{w10_if_zero_term(x), w10_if_zero_terms(rest)}

@unsafe
def w10_if_zero_term(t):
  match t:
    case KTerm{tag, name, id, quant, kids, removed, ob, oe}:
      KTerm{tag, name, id, quant, w10_if_zero_terms(kids), removed, 0, 0}
    case KLambda{name, id, quant, kids, removed, ob, oe, qp}:
      KLambda{name, id, quant, w10_if_zero_terms(kids), removed, 0, 0, qp}
    case KLiteral{kind, number, text, ob, oe}:
      KLiteral{kind, number, text, 0, 0}

law w10_if_strip_ann:
  for +t: KTerm
  KTerm

@unsafe
def w10_if_strip_ann_kids(+fallback: KTerm, kids: List<&2, KTerm>) -> KTerm:
  match kids:
    case Con{k0, _}: w10_if_strip_ann(k0)
    case Nil{}: fallback

@unsafe
def w10_if_strip_ann(t):
  match t:
    case KTerm{+tag, name, id, quant, +kids, removed, ob, oe}:
      nt_choose(KTerm, agy_str_eq(tag, "Ann") || agy_str_eq(tag, "Src") || agy_str_eq(tag, "Use"),
        u => w10_if_strip_ann_kids(t, kids),
        u => t)
    case _: t

law w10_if_collect_binders:
  for +t: KTerm
  for +acc: List<&2, W10IfBind>
  List<&2, W10IfBind>

@unsafe
def w10_if_collect_binders_all(+name: String, +id: U32, +quant: U32, kids: List<&2, KTerm>, +acc: List<&2, W10IfBind>) -> List<&2, W10IfBind>:
  match kids:
    case Con{k0, Con{k1, Nil{}}}:
      +bname = nt_choose(String, String.is_empty(name), v => "x", v => name)
      w10_if_collect_binders(k1, Con{W10IfBind{bname, id, quant}, acc})
    case _: List.reverse(&2, W10IfBind, acc)

@unsafe
def w10_if_collect_binders_cur(cur: KTerm, +acc: List<&2, W10IfBind>) -> List<&2, W10IfBind>:
  match cur:
    case KTerm{+tag, +name, +id, +quant, +kids, removed, ob, oe}:
      nt_choose(List<&2, W10IfBind>, agy_str_eq(tag, "All"),
        u => w10_if_collect_binders_all(name, id, quant, kids, acc),
        u => List.reverse(&2, W10IfBind, acc))
    case _: List.reverse(&2, W10IfBind, acc)

@unsafe
def w10_if_collect_binders(t, acc):
  w10_if_collect_binders_cur(w10_if_strip_ann(t), acc)

@unsafe
def w10_if_bind_len(bs: List<&2, W10IfBind>, acc: U32) -> U32:
  match bs:
    case Nil{}: acc
    case Con{_, rest}: w10_if_bind_len(rest, U32.inc(acc))

@unsafe
def w10_if_build_call(acc: KTerm, bs: List<&2, W10IfBind>) -> KTerm:
  match bs:
    case Nil{}: acc
    case Con{W10IfBind{name, id, quant}, rest}:
      +v : KTerm = KTerm{"Var", name, id, 0, Nil{}, Nil{}, 0, 0}
      w10_if_build_call(KTerm{"App", "", 0, 0, Con{acc, Con{v, Nil{}}}, Nil{}, 0, 0}, rest)

@unsafe
def w10_if_wrap_lams(rev_bs: List<&2, W10IfBind>, body: KTerm) -> KTerm:
  match rev_bs:
    case Nil{}: body
    case Con{W10IfBind{name, id, quant}, rest}:
      w10_if_wrap_lams(rest, KLambda{name, id, quant, Con{body, Nil{}}, Nil{}, 0, 0, False{}})

@unsafe
def w10_if_build_stub(+d: KDef, +sig_typ: KTerm, +force_cps: Bool) -> KTerm:
  +bs = w10_if_collect_binders(sig_typ, Nil{})
  nt_choose(KTerm, U32.is_eq(w10_if_bind_len(bs, 0), da(d)),
    u =>
      +call = w10_if_build_call(KTerm{"Ref", dn(d), 0, 0, Nil{}, Nil{}, 0, 0}, bs)
      +inner = nt_choose(KTerm, force_cps,
        v =>
          +u32r : KTerm = KTerm{"ADT", "U32", 0, 1, Nil{}, Nil{}, 0, 0}
          +u32fn : KTerm = KTerm{"All", "_cps", 999993, 1, Con{u32r, Con{u32r, Nil{}}}, Nil{}, 0, 0}
          +lam : KTerm = KLambda{"_cps", 999992, 1, Con{KTerm{"Var", "_cps", 999992, 0, Nil{}, Nil{}, 0, 0}, Nil{}}, Nil{}, 0, 0, False{}}
          +ann : KTerm = KTerm{"Ann", "", 0, 1, Con{lam, Con{u32fn, Nil{}}}, Nil{}, 0, 0}
          +bnd : KTerm = KTerm{"Bind", "_f", 999991, 1, Con{ann, Nil{}}, Nil{}, 0, 0}
          KTerm{"Let", "", 0, 1, Con{bnd, Con{call, Nil{}}}, Nil{}, 0, 0},
        v => call)
      w10_if_wrap_lams(List.reverse(&2, W10IfBind, bs), inner),
    u => w10_if_zero_term(dv(d)))

@unsafe
def w10_if_strip_ctors(cs: List<&2, KDef>) -> List<&2, KDef>:
  match cs:
    case Nil{}: Nil{}
    case Con{KDef{name, kind, arity, templates, typ, value, sub, native, unsafe}, rest}:
      Con{KDef{name, kind, arity, templates, w10_if_zero_term(typ), w10_if_zero_term(value), w10_if_strip_ctors(sub), True{}, unsafe}, w10_if_strip_ctors(rest)}
    case Con{other, rest}: Con{other, w10_if_strip_ctors(rest)}

law w10_if_strip_suffix:
  for ds: List<&2, KDef>
  for +abi: W10IfAbi
  for +laws: KDef
  List<&2, KDef>

@unsafe
def w10_if_strip_one(+d: KDef, +rest: List<&2, KDef>, +abi: W10IfAbi, +laws: KDef) -> List<&2, KDef>:
  match d:
    case KDef{+name, +kind, +arity, +templates, +typ, +value, +ctors, +native, +unsafe}:
      nt_choose(List<&2, KDef>, agy_str_eq(name, "main"),
        u => w10_if_strip_suffix(rest, abi, laws),
        u => nt_choose(List<&2, KDef>, agy_str_eq(kind, "Def") && U32.is_eq(templates, 0) && p98_tag_eq(value, "Absent"),
          v =>
            +laws2 = p131i_insert(laws, d, index_hash(name, 2166136261))
            Con{KDef{name, kind, arity, templates, w10_if_zero_term(typ), w10_if_zero_term(value), Nil{}, True{}, unsafe}, w10_if_strip_suffix(rest, abi, laws2)},
          v => nt_choose(List<&2, KDef>, agy_str_eq(kind, "Def") && U32.is_eq(templates, 0) &&
              Bool.not(agy_str_eq(name, "kc") || agy_str_eq(name, "f_choose") || agy_str_eq(name, "nt_choose") || agy_str_eq(name, "p151_choose")),
            w =>
              +sig = nt_choose(KTerm, p98_tag_eq(typ, "Absent"), z => dt(p111v_get(laws, name)), z => typ)
              Con{KDef{name, kind, arity, templates, w10_if_zero_term(typ), w10_if_build_stub(d, sig, w10_if_force_cps(abi, name)), Nil{}, True{}, True{}}, w10_if_strip_suffix(rest, abi, laws)},
            w => Con{KDef{name, kind, arity, templates, w10_if_zero_term(typ), w10_if_zero_term(value), w10_if_strip_ctors(ctors), True{}, unsafe}, w10_if_strip_suffix(rest, abi, laws)})))
    case _: w10_if_strip_suffix(rest, abi, laws)

@unsafe
def w10_if_strip_suffix(ds, abi, laws):
  match ds:
    case Nil{}: Nil{}
    case Con{d, rest}: w10_if_strip_one(d, rest, abi, laws)

# --- Pure-Bend .p130 word-pair encoder (zero-copy right-cons + O(1) KDef cache) ---

@unsafe
def w10_if_w(+n: U32, tail: String) -> String:
  SCon{Chr{U32.add(65536, U32.and(n, 65535))}, SCon{Chr{U32.add(65536, U32.shrn(n, 16n))}, tail}}

@unsafe
def w10_if_word(+n: U32) -> String:
  w10_if_w(n, SNil{})

@unsafe
def w10_if_str_len(s: String, acc: U32) -> U32:
  match s:
    case SNil{}: acc
    case SCon{_, rest}: w10_if_str_len(rest, U32.inc(acc))

@unsafe
def w10_if_push_str(+s: String) -> String:
  w10_if_w(w10_if_str_len(s, 0), s ++ "\n")

@unsafe
def w10_if_enc_empty() -> W10IfEnc:
  W10IfEnc{missing(), Nil{}, 0, missing(), Nil{}, 0}

@unsafe
def w10_if_intern_str(enc: W10IfEnc, +s: String) -> W10IfRes:
  match enc:
    case W10IfEnc{+sm, +sr, +sn, +rm, +rr, +rn}:
      +hit = p111v_get(sm, s)
      nt_choose(W10IfRes, agy_str_eq(dk(hit), "Absent"),
        u => W10IfRes{W10IfEnc{p111v_put(sm, s, "S", sn, 0), Con{w10_if_push_str(s), sr}, U32.inc(sn), rm, rr, rn}, sn},
        u => W10IfRes{W10IfEnc{sm, sr, sn, rm, rr, rn}, da(hit)})

@unsafe
def w10_if_intern_rec(enc: W10IfEnc, +wire: String) -> W10IfRes:
  match enc:
    case W10IfEnc{+sm, +sr, +sn, +rm, +rr, +rn}:
      +hit = p111v_get(rm, wire)
      nt_choose(W10IfRes, agy_str_eq(dk(hit), "Absent"),
        u => W10IfRes{W10IfEnc{sm, sr, sn, p111v_put(rm, wire, "R", rn, 0), Con{wire, rr}, U32.inc(rn)}, rn},
        u => W10IfRes{W10IfEnc{sm, sr, sn, rm, rr, rn}, da(hit)})

@unsafe
def w10_if_enc_nil(enc: W10IfEnc) -> W10IfRes:
  w10_if_intern_rec(enc, w10_if_w(0, w10_if_w(0, SNil{})))

@unsafe
def w10_if_enc_con(enc: W10IfEnc, +a: U32, +b: U32) -> W10IfRes:
  w10_if_intern_rec(enc, w10_if_w(1, w10_if_w(2, w10_if_w(a, w10_if_w(b, SNil{})))))

@unsafe
def w10_if_res_enc(r: W10IfRes) -> W10IfEnc:
  match r:
    case W10IfRes{enc, _}: enc

@unsafe
def w10_if_res_id(r: W10IfRes) -> U32:
  match r:
    case W10IfRes{_, id}: id

@unsafe
def w10_if_enc_strs(enc: W10IfEnc, xs: List<&2, String>) -> W10IfRes:
  match xs:
    case Nil{}: w10_if_enc_nil(enc)
    case Con{h, t}:
      +r1 = w10_if_intern_str(enc, h)
      +r2 = w10_if_enc_strs(w10_if_res_enc(r1), t)
      w10_if_enc_con(w10_if_res_enc(r2), U32.add(w10_if_res_id(r1), 2147483648), w10_if_res_id(r2))

law w10_if_enc_term:
  for enc: W10IfEnc
  for t: KTerm
  W10IfRes

@unsafe
def w10_if_enc_terms(enc: W10IfEnc, xs: List<&2, KTerm>) -> W10IfRes:
  match xs:
    case Nil{}: w10_if_enc_nil(enc)
    case Con{h, t}:
      +r1 = w10_if_enc_term(enc, h)
      +r2 = w10_if_enc_terms(w10_if_res_enc(r1), t)
      w10_if_enc_con(w10_if_res_enc(r2), w10_if_res_id(r1), w10_if_res_id(r2))

@unsafe
def w10_if_enc_term(enc, t):
  match t:
    case KTerm{tag, name, id, quant, kids, removed, ob, oe}:
      +r0 = w10_if_intern_str(enc, tag)
      +r1 = w10_if_intern_str(w10_if_res_enc(r0), name)
      +r4 = w10_if_enc_terms(w10_if_res_enc(r1), kids)
      +r5 = w10_if_enc_strs(w10_if_res_enc(r4), removed)
      +wire = w10_if_w(2, w10_if_w(8,
        w10_if_w(w10_if_res_id(r0), w10_if_w(w10_if_res_id(r1), w10_if_w(id, w10_if_w(quant,
        w10_if_w(w10_if_res_id(r4), w10_if_w(w10_if_res_id(r5), w10_if_w(ob, w10_if_w(oe, SNil{}))))))))))
      w10_if_intern_rec(w10_if_res_enc(r5), wire)
    case KLambda{name, id, quant, kids, removed, ob, oe, qp}:
      +r0 = w10_if_intern_str(enc, name)
      +r3 = w10_if_enc_terms(w10_if_res_enc(r0), kids)
      +r4 = w10_if_enc_strs(w10_if_res_enc(r3), removed)
      +wire = w10_if_w(3, w10_if_w(8,
        w10_if_w(w10_if_res_id(r0), w10_if_w(id, w10_if_w(quant,
        w10_if_w(w10_if_res_id(r3), w10_if_w(w10_if_res_id(r4), w10_if_w(ob, w10_if_w(oe, w10_if_w(Bool.to_u32(qp), SNil{}))))))))))
      w10_if_intern_rec(w10_if_res_enc(r4), wire)
    case KLiteral{kind, number, text, ob, oe}:
      +r0 = w10_if_intern_str(enc, kind)
      +r2 = w10_if_intern_str(w10_if_res_enc(r0), text)
      +wire = w10_if_w(4, w10_if_w(5,
        w10_if_w(w10_if_res_id(r0), w10_if_w(number, w10_if_w(w10_if_res_id(r2), w10_if_w(ob, w10_if_w(oe, SNil{})))))))
      w10_if_intern_rec(w10_if_res_enc(r2), wire)

law w10_if_enc_def:
  for enc: W10IfEnc
  for d: KDef
  W10IfRes

@unsafe
def w10_if_enc_defs(enc: W10IfEnc, xs: List<&2, KDef>) -> W10IfRes:
  match xs:
    case Nil{}: w10_if_enc_nil(enc)
    case Con{h, t}:
      +r1 = w10_if_enc_def(enc, h)
      +r2 = w10_if_enc_defs(w10_if_res_enc(r1), t)
      w10_if_enc_con(w10_if_res_enc(r2), w10_if_res_id(r1), w10_if_res_id(r2))

@unsafe
def w10_if_enc_def(enc, d):
  match d:
    case KDef{name, kind, arity, templates, typ, value, ctors, native, unsafe}:
      +r0 = w10_if_intern_str(enc, name)
      +r1 = w10_if_intern_str(w10_if_res_enc(r0), kind)
      +r4 = w10_if_enc_term(w10_if_res_enc(r1), typ)
      +r5 = w10_if_enc_term(w10_if_res_enc(r4), value)
      +r6 = w10_if_enc_defs(w10_if_res_enc(r5), ctors)
      +wire = w10_if_w(5, w10_if_w(9,
        w10_if_w(w10_if_res_id(r0), w10_if_w(w10_if_res_id(r1), w10_if_w(arity, w10_if_w(templates,
        w10_if_w(w10_if_res_id(r4), w10_if_w(w10_if_res_id(r5), w10_if_w(w10_if_res_id(r6),
        w10_if_w(Bool.to_u32(native), w10_if_w(Bool.to_u32(unsafe), SNil{})))))))))))
      w10_if_intern_rec(w10_if_res_enc(r6), wire)
    case KIndexLeaf{hash, bucket}:
      +r1 = w10_if_enc_defs(enc, bucket)
      +wire = w10_if_w(6, w10_if_w(2, w10_if_w(hash, w10_if_w(w10_if_res_id(r1), SNil{}))))
      w10_if_intern_rec(w10_if_res_enc(r1), wire)
    case KIndexNode{hash, mask, left, right}:
      +r2 = w10_if_enc_def(enc, left)
      +r3 = w10_if_enc_def(w10_if_res_enc(r2), right)
      +wire = w10_if_w(7, w10_if_w(4,
        w10_if_w(hash, w10_if_w(mask, w10_if_w(w10_if_res_id(r2), w10_if_w(w10_if_res_id(r3), SNil{}))))))
      w10_if_intern_rec(w10_if_res_enc(r3), wire)

# --- O(1) KDef cache for unchanged s_book defs across world & ready ---

@unsafe
def w10_if_mark_patches(ps: List<&2, KDef>, bad: KDef) -> KDef:
  match ps:
    case Nil{}: bad
    case Con{p, rest}:
      w10_if_mark_patches(rest, p111v_put(bad, dn(p), "B", 1, 0))

@unsafe
def w10_if_mark_dups(ds: List<&2, KDef>, +seen: KDef, +bad: KDef) -> KDef:
  match ds:
    case Nil{}: bad
    case Con{KDef{+name, _, _, _, _, _, _, _, _}, +rest}:
      nt_choose(KDef, w10_if_abi_has(seen, name),
        u => w10_if_mark_dups(rest, seen, p111v_put(bad, name, "B", 1, 0)),
        u => w10_if_mark_dups(rest, p111v_put(seen, name, "S", 1, 0), bad))
    case Con{_, rest}: w10_if_mark_dups(rest, seen, bad)

@unsafe
def w10_if_cache_put(h: KDef, +id: U32, +bad: KDef, +cache: KDef) -> KDef:
  match h:
    case KDef{+name, _, _, _, _, _, _, _, _}:
      nt_choose(KDef, w10_if_abi_has(bad, name),
        u => cache,
        u => p111v_put(cache, name, "C", id, 0))
    case _: cache

@unsafe
def w10_if_enc_book_join(+id1: U32, pair: W10IfRes & KDef) -> W10IfRes & KDef:
  (+r2, cache2) = pair
  (w10_if_enc_con(w10_if_res_enc(r2), id1, w10_if_res_id(r2)), cache2)

@unsafe
def w10_if_enc_book_defs(enc: W10IfEnc, xs: List<&2, KDef>, +bad: KDef, +cache: KDef) -> W10IfRes & KDef:
  match xs:
    case Nil{}: (w10_if_enc_nil(enc), cache)
    case Con{+h, t}:
      +r1 = w10_if_enc_def(enc, h)
      +id1 = w10_if_res_id(r1)
      +cache1 = w10_if_cache_put(h, id1, bad, cache)
      w10_if_enc_book_join(id1, w10_if_enc_book_defs(w10_if_res_enc(r1), t, bad, cache1))

law w10_if_enc_def_c:
  for +enc: W10IfEnc
  for +d: KDef
  for +cache: KDef
  W10IfRes

@unsafe
def w10_if_enc_defs_c(enc: W10IfEnc, xs: List<&2, KDef>, +cache: KDef) -> W10IfRes:
  match xs:
    case Nil{}: w10_if_enc_nil(enc)
    case Con{h, t}:
      +r1 = w10_if_enc_def_c(enc, h, cache)
      +r2 = w10_if_enc_defs_c(w10_if_res_enc(r1), t, cache)
      w10_if_enc_con(w10_if_res_enc(r2), w10_if_res_id(r1), w10_if_res_id(r2))

@unsafe
def w10_if_enc_def_c(enc, d, cache):
  match d:
    case KDef{+name, _, _, _, _, _, _, _, _}:
      +hit = p111v_get(cache, name)
      nt_choose(W10IfRes, agy_str_eq(dk(hit), "Absent"),
        u => w10_if_enc_def(enc, d),
        u => W10IfRes{enc, da(hit)})
    case KIndexLeaf{hash, bucket}:
      +r1 = w10_if_enc_defs_c(enc, bucket, cache)
      +wire = w10_if_w(6, w10_if_w(2, w10_if_w(hash, w10_if_w(w10_if_res_id(r1), SNil{}))))
      w10_if_intern_rec(w10_if_res_enc(r1), wire)
    case KIndexNode{hash, mask, left, right}:
      +r2 = w10_if_enc_def_c(enc, left, cache)
      +r3 = w10_if_enc_def_c(w10_if_res_enc(r2), right, cache)
      +wire = w10_if_w(7, w10_if_w(4,
        w10_if_w(hash, w10_if_w(mask, w10_if_w(w10_if_res_id(r2), w10_if_w(w10_if_res_id(r3), SNil{}))))))
      w10_if_intern_rec(w10_if_res_enc(r3), wire)

@unsafe
def w10_if_enc_state(enc: W10IfEnc, st: KBasePrefixState) -> W10IfRes:
  match st:
    case KBasePrefixState{bound, delta, stamp, patches, ready}:
      +r3 = w10_if_enc_defs(enc, patches)
      +wire = w10_if_w(8, w10_if_w(5,
        w10_if_w(bound, w10_if_w(delta, w10_if_w(stamp, w10_if_w(w10_if_res_id(r3), w10_if_w(Bool.to_u32(ready), SNil{})))))))
      w10_if_intern_rec(w10_if_res_enc(r3), wire)

@unsafe
def w10_if_enc_fresh(enc: W10IfEnc, fr: FFreshPrefixState) -> W10IfRes:
  match fr:
    case FFreshPrefixState{next, ready}:
      +wire = w10_if_w(9, w10_if_w(2, w10_if_w(next, w10_if_w(Bool.to_u32(ready), SNil{}))))
      w10_if_intern_rec(enc, wire)

@unsafe
def w10_if_enc_world_fast(enc: W10IfEnc, w: KBasePreparedWorld, +state_id: U32, +book_id: U32, +cache: KDef) -> W10IfRes:
  match w:
    case KBasePreparedWorld{state, prefix, final, book, checked, seen, todos, cbound}:
      +r2 = w10_if_enc_defs_c(enc, final, cache)
      +r3 = w10_if_enc_defs_c(w10_if_res_enc(r2), book, cache)
      +r4 = w10_if_enc_defs_c(w10_if_res_enc(r3), checked, cache)
      +r5 = w10_if_enc_defs_c(w10_if_res_enc(r4), seen, cache)
      +wire = w10_if_w(10, w10_if_w(8,
        w10_if_w(state_id, w10_if_w(book_id, w10_if_w(w10_if_res_id(r2), w10_if_w(w10_if_res_id(r3),
        w10_if_w(w10_if_res_id(r4), w10_if_w(w10_if_res_id(r5), w10_if_w(todos, w10_if_w(cbound, SNil{}))))))))))
      w10_if_intern_rec(w10_if_res_enc(r5), wire)

@unsafe
def w10_if_enc_world(enc: W10IfEnc, w: KBasePreparedWorld) -> W10IfRes:
  match w:
    case KBasePreparedWorld{state, prefix, final, book, checked, seen, todos, cbound}:
      +r0 = w10_if_enc_state(enc, state)
      +r1 = w10_if_enc_defs(w10_if_res_enc(r0), prefix)
      +r2 = w10_if_enc_defs(w10_if_res_enc(r1), final)
      +r3 = w10_if_enc_defs(w10_if_res_enc(r2), book)
      +r4 = w10_if_enc_defs(w10_if_res_enc(r3), checked)
      +r5 = w10_if_enc_defs(w10_if_res_enc(r4), seen)
      +wire = w10_if_w(10, w10_if_w(8,
        w10_if_w(w10_if_res_id(r0), w10_if_w(w10_if_res_id(r1), w10_if_w(w10_if_res_id(r2), w10_if_w(w10_if_res_id(r3),
        w10_if_w(w10_if_res_id(r4), w10_if_w(w10_if_res_id(r5), w10_if_w(todos, w10_if_w(cbound, SNil{}))))))))))
      w10_if_intern_rec(w10_if_res_enc(r5), wire)

@unsafe
def w10_if_enc_ready_fast(enc: W10IfEnc, rd: FReadyPrefixState, +cache: KDef) -> W10IfRes:
  match rd:
    case FReadyPrefixState{names, ctors, count, ready}:
      +r0 = w10_if_enc_def_c(enc, names, cache)
      +r1 = w10_if_enc_def(w10_if_res_enc(r0), ctors)
      +wire = w10_if_w(11, w10_if_w(4,
        w10_if_w(w10_if_res_id(r0), w10_if_w(w10_if_res_id(r1), w10_if_w(count, w10_if_w(Bool.to_u32(ready), SNil{}))))))
      w10_if_intern_rec(w10_if_res_enc(r1), wire)

@unsafe
def w10_if_enc_ready(enc: W10IfEnc, rd: FReadyPrefixState) -> W10IfRes:
  match rd:
    case FReadyPrefixState{names, ctors, count, ready}:
      +r0 = w10_if_enc_def(enc, names)
      +r1 = w10_if_enc_def(w10_if_res_enc(r0), ctors)
      +wire = w10_if_w(11, w10_if_w(4,
        w10_if_w(w10_if_res_id(r0), w10_if_w(w10_if_res_id(r1), w10_if_w(count, w10_if_w(Bool.to_u32(ready), SNil{}))))))
      w10_if_intern_rec(w10_if_res_enc(r1), wire)

# --- Batched streaming writer to /dev/stdout ---

@unsafe
def w10_if_take_batch(xs: List<&2, String>, +n: U32, +acc: String) -> String & List<&2, String>:
  match xs:
    case Nil{}: (acc, Nil{})
    case Con{+h, +t}:
      nt_choose(String & List<&2, String>, U32.is_eq(n, 0),
        u => (acc, Con{h, t}),
        u => w10_if_take_batch(t, U32.sub(n, 1), acc ++ h))

law w10_if_write_list:
  for file: File
  for xs: List<&2, String>
  IO(File & Result<&1, &1, U32 & String, Unit>)

@unsafe
def w10_if_write_list_next(pair: File & Result<&1, &1, U32 & String, Unit>, rest: List<&2, String>) -> IO(File & Result<&1, &1, U32 & String, Unit>):
  (file2, res) = pair
  match res:
    case Done{_}: w10_if_write_list(file2, rest)
    case Fail{err}: IO.pure(File & Result<&1, &1, U32 & String, Unit>, (file2, Fail{err}))

@unsafe
def w10_if_write_batch(file: File, batch: String & List<&2, String>) -> IO(File & Result<&1, &1, U32 & String, Unit>):
  (chunk, rest) = batch
  do IO<File & Result<&1, &1, U32 & String, Unit>>:
    pair : File & Result<&1, &1, U32 & String, Unit> <- File.write(file, chunk)
    w10_if_write_list_next(pair, rest)

@unsafe
def w10_if_write_list(file, xs):
  match xs:
    case Nil{}: IO.pure(File & Result<&1, &1, U32 & String, Unit>, (file, Done{Unit{}}))
    case Con{h, t}: w10_if_write_batch(file, w10_if_take_batch(Con{h, t}, 64, ""))

@unsafe
def w10_if_stream_done(res3: Result<&1, &1, U32 & String, Unit>, +stamp: String) -> IO(U32):
  match res3:
    case Fail{e3}: IO.pass(U32, Fail{e3})
    case Done{_}:
      do IO<U32>:
        _ : Unit <- IO.print_err(stamp ++ "\n")
        IO.pure(U32, 0)

@unsafe
def w10_if_stream_finish(pair: File & Result<&1, &1, U32 & String, Unit>, +stamp: String) -> IO(U32):
  (f4, res3) = pair
  do IO<U32>:
    Unit <- File.close(f4)
    w10_if_stream_done(res3, stamp)

@unsafe
def w10_if_stream_s3(pair: File & Result<&1, &1, U32 & String, Unit>, +trailer: String, +stamp: String) -> IO(U32):
  (f3, res2) = pair
  match res2:
    case Fail{e2}:
      do IO<U32>:
        Unit <- File.close(f3)
        IO.pass(U32, Fail{e2})
    case Done{_}:
      do IO<U32>:
        p3 : File & Result<&1, &1, U32 & String, Unit> <- File.write(f3, trailer)
        w10_if_stream_finish(p3, stamp)

@unsafe
def w10_if_stream_s2(pair: File & Result<&1, &1, U32 & String, Unit>, recs: List<&2, String>, +trailer: String, +stamp: String) -> IO(U32):
  (f2, res1) = pair
  match res1:
    case Fail{e1}:
      do IO<U32>:
        Unit <- File.close(f2)
        IO.pass(U32, Fail{e1})
    case Done{_}:
      do IO<U32>:
        p2 : File & Result<&1, &1, U32 & String, Unit> <- w10_if_write_list(f2, recs)
        w10_if_stream_s3(p2, trailer, stamp)

@unsafe
def w10_if_stream_s1(pair: File & Result<&1, &1, U32 & String, Unit>, strs: List<&2, String>, recs: List<&2, String>, +trailer: String, +stamp: String) -> IO(U32):
  (f1, res0) = pair
  match res0:
    case Fail{e0}:
      do IO<U32>:
        Unit <- File.close(f1)
        IO.pass(U32, Fail{e0})
    case Done{_}:
      do IO<U32>:
        p1 : File & Result<&1, &1, U32 & String, Unit> <- w10_if_write_list(f1, strs)
        w10_if_stream_s2(p1, recs, trailer, stamp)

@unsafe
def w10_if_stream_carrier(+stamp: String, enc: W10IfEnc, +r0: U32, +r1: U32, +r2: U32, +r3: U32, +r4: U32) -> IO(U32):
  match enc:
    case W10IfEnc{sm, str_rev, +sn, rm, rec_rev, +rn}:
      +header = w10_if_push_str(stamp) ++ w10_if_w(rn, w10_if_w(sn, SNil{}))
      +trailer = w10_if_w(r0, w10_if_w(r1, w10_if_w(r2, w10_if_w(r3, w10_if_w(r4, SNil{})))))
      do IO<U32>:
        file : File <- IO.try(File, File.open("/dev/stdout", "w"))
        p0 : File & Result<&1, &1, U32 & String, Unit> <- File.write(file, header)
        w10_if_stream_s1(p0, List.reverse(&2, String, str_rev), List.reverse(&2, String, rec_rev), trailer, stamp)

# --- End-to-end fast x86-iface driver ---

@unsafe
def w10_if_emit_checked_go(+stamp: String, +s_fresh: FFreshPrefixState, +s_ready: FReadyPrefixState, +s_state: KBasePrefixState, +s_world: KBasePreparedWorld, book_pair: W10IfRes & KDef) -> IO(U32):
  (+e0, +def_cache) = book_pair
  +e1 = w10_if_enc_state(w10_if_res_enc(e0), s_state)
  +e2 = w10_if_enc_fresh(w10_if_res_enc(e1), s_fresh)
  +e3 = w10_if_enc_world_fast(w10_if_res_enc(e2), s_world, w10_if_res_id(e1), w10_if_res_id(e0), def_cache)
  +e4 = w10_if_enc_ready_fast(w10_if_res_enc(e3), s_ready, def_cache)
  w10_if_stream_carrier(stamp, w10_if_res_enc(e4), w10_if_res_id(e0), w10_if_res_id(e1), w10_if_res_id(e2), w10_if_res_id(e3), w10_if_res_id(e4))

@unsafe
def w10_if_emit_checked(+stamp: String, +s_book: List<&2, KDef>, +s_fresh: FFreshPrefixState, +s_ready: FReadyPrefixState, +s_state: KBasePrefixState, +s_world: KBasePreparedWorld) -> IO(U32):
  match s_ready s_state:
    case FReadyPrefixState{_, _, _, True{}} KBasePrefixState{_, _, _, +patches, True{}}:
      +bad = w10_if_mark_dups(s_book, missing(), w10_if_mark_patches(patches, missing()))
      w10_if_emit_checked_go(stamp, s_fresh, s_ready, s_state, s_world, w10_if_enc_book_defs(w10_if_enc_empty(), s_book, bad, missing()))
    case _ _: IO.die(U32, 1, "x86-iface: prepared interface state was not ready")

@unsafe
def w10_if_mark_ready(st: KBasePrefixState) -> KBasePrefixState:
  match st:
    case KBasePrefixState{bound, delta, stamp, patches, _}:
      KBasePrefixState{bound, delta, stamp, patches, True{}}

@unsafe
def w10_if_emit_freshened(+stamp: String, +base_book: List<&2, KDef>, +base_world: KBasePreparedWorld, fdefs: FFreshDefs) -> IO(U32):
  match fdefs:
    case FFreshDefs{+fresh_suffix, +next_id}:
      +s_book = List.append(&2, KDef, base_book, fresh_suffix)
      +s_fresh : FFreshPrefixState = FFreshPrefixState{next_id, True{}}
      +s_ready : FReadyPrefixState = f_ready_prefix_prepare(s_book)
      +checked : DChecking = base_prefix_resume_world(base_world, fresh_suffix, norm_max_book(s_book))
      nt_choose(IO(U32), good(dg_checking_result(checked)),
        u =>
          +s_state : KBasePrefixState = w10_if_mark_ready(p86_checked_prefix(s_book, checked))
          +s_world : KBasePreparedWorld = base_prefix_world_prepare(s_book, s_state)
          w10_if_emit_checked(stamp, s_book, s_fresh, s_ready, s_state, s_world),
        u => IO.die(U32, 1, "x86-iface: stub check failed: " ++ ce(dg_checking_result(checked))))

@unsafe
def w10_if_emit_seed(+base_seed: P86Seed, +suffix: List<&2, KDef>, +abi: W10IfAbi) -> IO(U32):
  match base_seed:
    case P86Seed{base_src, +base_book, FFreshPrefixState{+base_next, _}, base_ready, +base_world}:
      +stamp = w10_if_stamp_str(w10_if_h_defs(w10_if_h_init(), suffix, abi))
      +stripped = w10_if_strip_suffix(suffix, abi, missing())
      w10_if_emit_freshened(stamp, base_book, base_world, f_fresh_defs(stripped, base_next))

@unsafe
def w10_if_fast_abi_scan(+seed: P86Seed, +suffix: List<&2, KDef>, +book: List<&2, KDef>, +names: List<&2, String>, +bangs: List<&2, String>, scan: P128BROpen) -> IO(U32):
  match scan:
    case P128BROpen{+workers, helpers, retry, +serr}:
      nt_choose(IO(U32), String.is_empty(serr),
        u =>
          +worker_sigs = p113e_signatures(workers, missing())
          +remaining = p167ob_remaining(book, names, bangs, worker_sigs)
          +sigs = book_cached(nq_signatures(book, names), 0)
          +filtered = w7_filter_remaining(book, remaining, bangs)
          +raw = p113pl_candidates(book, filtered, bangs, sigs)
          +fns0 = p113d_passes(p126sc_candidates(raw), worker_sigs, nt_reverse(P113DFunction, workers, Nil{}), 32)
          +abi : W10IfAbi = W10IfAbi{w10_if_add_direct(fns0, missing()), w10_if_add_public_names(book, names, missing())}
          w10_if_emit_seed(seed, suffix, abi),
        u => IO.die(U32, 1, "x86-iface: early scalar scan: " ++ serr))

@unsafe
def w10_if_fast_abi_prep(+seed: P86Seed, +suffix: List<&2, KDef>, +names: List<&2, String>, prep: P112SPrepared) -> IO(U32):
  match prep:
    case P112SPrepared{+sbook, nodes, +perr}:
      nt_choose(IO(U32), String.is_empty(perr),
        u =>
          +bangs = nc_bangs_names(sbook, names)
          w10_if_fast_abi_scan(seed, suffix, sbook, names, bangs,
            p128br_scan(sbook, no_candidate_names(sbook, names, bangs), Nil{}, Nil{}, Nil{}, Nil{})),
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
        u => IO.die(U32, 1, "x86-iface: " ++ err))

@unsafe
def w10_if_run_fast_plan(+seed: P86Seed, +suffix: List<&2, KDef>, plan: P86Plan) -> IO(U32):
  match plan:
    case P86PlanError{err}: IO.die(U32, 1, "x86-iface: " ++ err)
    case P86PlanReady{request, verdict}:
      w10_if_fast_abi_req(seed, suffix, request)

@unsafe
def w10_if_run_trace(+seed: P86Seed, +load: FPrefixLoad) -> IO(U32):
  match load:
    case FPrefixLoad{FLoadTrace{FResult{_, +lerr, _}, _, _}, _, +suffix, _}:
      nt_choose(IO(U32), String.is_empty(lerr),
        z => w10_if_run_fast_plan(seed, suffix, p86_plan_loaded(seed, load)),
        z => IO.die(U32, 1, "x86-iface parse: " ++ lerr))

@unsafe
def w10_if_run_comp2(+seed: P86Seed, +source: FSource, +base: FSource, +fresh: FFreshPrefixState, comp2: FPrefixCompletion) -> IO(U32):
  match comp2:
    case FPrefixCompletion{carrier2, _}:
      w10_if_run_trace(seed, f_prefix_graph_trace(carrier2, [source, base], fresh))

@unsafe
def w10_if_run_comp1(+seed: P86Seed, +source: FSource, +base: FSource, +fresh: FFreshPrefixState, +header: FHeader, comp1: FPrefixCompletion) -> IO(U32):
  match comp1:
    case FPrefixCompletion{+carrier, FResult{_, +perr, _}}:
      nt_choose(IO(U32), String.is_empty(perr),
        w => w10_if_run_comp2(seed, source, base, fresh, f_prefix_complete_source(source, "", header, [source, base], carrier, f_path_dir(f_source_path(source)))),
        w => IO.die(U32, 1, "x86-iface base seed: " ++ perr))

@unsafe
def w10_if_run_hdr(+seed: P86Seed, +base: FSource, +book: List<&2, KDef>, +fresh: FFreshPrefixState, +ready: FReadyPrefixState, +source: FSource, +header: FHeader) -> IO(U32):
  match header:
    case FHeader{+imports, +herr, body, line, offset}:
      nt_choose(IO(U32), String.is_empty(herr),
        u =>
          +ierr = p86_import_error(imports, False{})
          nt_choose(IO(U32), String.is_empty(ierr),
            v => w10_if_run_comp1(seed, source, base, fresh, header, f_prefix_complete_ready_seed(base, "", f_prefix_graph_empty(), f_source_path(base), f_source_text(base), book, ready)),
            v => IO.die(U32, 1, "x86-iface import: " ++ ierr)),
        u => IO.die(U32, 1, "x86-iface header: " ++ herr))

@unsafe
def w10_if_run_prepared(+path: String, +text: String, prep: P86Preparation) -> IO(U32):
  match prep:
    case P86PreparationError{error}: IO.die(U32, 1, error)
    case P86PreparationReady{+seed}:
      match seed:
        case P86Seed{+base, +book, +fresh, +ready, world}:
          +begin = f_source_end(base)
          +source = f_source_located(FSource{path, path, text}, begin, U32.add(U32.add(begin, p86_width(text, 0)), 1))
          w10_if_run_hdr(seed, base, book, fresh, ready, source, f_source_header(source))

@unsafe
def w10_iface_request(+path: String, +base_path: String, +carrier_path: String,
    +stamp: String, +cached: Bool) -> IO(U32):
  do IO<U32>:
    +source : String <- p86_read_file(path)
    +base : String <- p86_read_file(base_path)
    nt_choose(IO(U32), cached,
      u => do IO<U32>:
        carrier : String <- p86_read_file(carrier_path)
        w10_if_run_prepared(path, source, p88_cache_prepare(base_path, base, carrier, stamp)),
      u => w10_if_run_prepared(path, source, p86_prepare(base_path, base)))
