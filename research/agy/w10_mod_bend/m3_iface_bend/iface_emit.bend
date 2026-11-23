# === AGY-W10-M3-IFACE: Pure-Bend x86-iface (.p130 interface carrier emitter) ===
# Eliminates build_iface_carrier.mjs completely:
#   x86-iface ABS_PREFIX ABS_BASE live|cache ABS_BASE_CARRIER STAMP
#   - Loads Base via p88_cache_prepare (or p86_prepare in live mode)
#   - Checks PREFIX via p86_plan & extracts exact direct/CPS ABI from x198pw_plan
#   - Replaces non-Base Def bodies with ABI-matched self-recursive stubs (no nm!)
#   - Computes deterministic dual 32-bit FNV-1a interface stamp (types + sigs + ABI only)
#   - Streams exact .p130 word-pair carrier to stdout and prints stamp to stderr

type W10IfHash is Data:
  W10IfHash{+h1: U32, +h2: U32}

type W10IfBind is Data:
  W10IfBind{+name: String, +id: U32, +quant: U32}

type W10IfAbi is Data:
  W10IfAbi{+direct: KDef, +public: KDef}

type W10IfEnc is Data:
  W10IfEnc{+str_map: KDef, +str_rev: List<&2, String>, +str_n: U32, +rec_map: KDef, +rec_rev: List<&2, String>, +rec_n: U32}

type W10IfRes is Data:
  W10IfRes{+enc: W10IfEnc, +id: U32}

type W10IfLoad is Data:
  W10IfLoad{+ok: Bool, +error: String, +suffix: List<&2, KDef>}

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

# --- ABI extraction from P134Cursor (zero nm, zero .o required) ---

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
          v => nt_choose(List<&2, KDef>, agy_str_eq(kind, "Def") && U32.is_eq(templates, 0),
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

# --- Pure-Bend .p130 word-pair encoder with structural interning ---

@unsafe
def w10_if_word(+n: U32) -> String:
  SCon{Chr{U32.add(65536, U32.and(n, 65535))}, SCon{Chr{U32.add(65536, U32.shrn(n, 16n))}, SNil{}}}

@unsafe
def w10_if_str_len(s: String, acc: U32) -> U32:
  match s:
    case SNil{}: acc
    case SCon{_, rest}: w10_if_str_len(rest, U32.inc(acc))

@unsafe
def w10_if_push_str(+s: String) -> String:
  w10_if_word(w10_if_str_len(s, 0)) ++ s ++ "\n"

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
  w10_if_intern_rec(enc, w10_if_word(0) ++ w10_if_word(0))

@unsafe
def w10_if_enc_con(enc: W10IfEnc, +a: U32, +b: U32) -> W10IfRes:
  w10_if_intern_rec(enc, w10_if_word(1) ++ w10_if_word(2) ++ w10_if_word(a) ++ w10_if_word(b))

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
      +wire = w10_if_word(2) ++ w10_if_word(8) ++
        w10_if_word(w10_if_res_id(r0)) ++ w10_if_word(w10_if_res_id(r1)) ++ w10_if_word(id) ++ w10_if_word(quant) ++
        w10_if_word(w10_if_res_id(r4)) ++ w10_if_word(w10_if_res_id(r5)) ++ w10_if_word(ob) ++ w10_if_word(oe)
      w10_if_intern_rec(w10_if_res_enc(r5), wire)
    case KLambda{name, id, quant, kids, removed, ob, oe, qp}:
      +r0 = w10_if_intern_str(enc, name)
      +r3 = w10_if_enc_terms(w10_if_res_enc(r0), kids)
      +r4 = w10_if_enc_strs(w10_if_res_enc(r3), removed)
      +wire = w10_if_word(3) ++ w10_if_word(8) ++
        w10_if_word(w10_if_res_id(r0)) ++ w10_if_word(id) ++ w10_if_word(quant) ++
        w10_if_word(w10_if_res_id(r3)) ++ w10_if_word(w10_if_res_id(r4)) ++ w10_if_word(ob) ++ w10_if_word(oe) ++ w10_if_word(Bool.to_u32(qp))
      w10_if_intern_rec(w10_if_res_enc(r4), wire)
    case KLiteral{kind, number, text, ob, oe}:
      +r0 = w10_if_intern_str(enc, kind)
      +r2 = w10_if_intern_str(w10_if_res_enc(r0), text)
      +wire = w10_if_word(4) ++ w10_if_word(5) ++
        w10_if_word(w10_if_res_id(r0)) ++ w10_if_word(number) ++ w10_if_word(w10_if_res_id(r2)) ++ w10_if_word(ob) ++ w10_if_word(oe)
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
      +wire = w10_if_word(5) ++ w10_if_word(9) ++
        w10_if_word(w10_if_res_id(r0)) ++ w10_if_word(w10_if_res_id(r1)) ++ w10_if_word(arity) ++ w10_if_word(templates) ++
        w10_if_word(w10_if_res_id(r4)) ++ w10_if_word(w10_if_res_id(r5)) ++ w10_if_word(w10_if_res_id(r6)) ++
        w10_if_word(Bool.to_u32(native)) ++ w10_if_word(Bool.to_u32(unsafe))
      w10_if_intern_rec(w10_if_res_enc(r6), wire)
    case KIndexLeaf{hash, bucket}:
      +r1 = w10_if_enc_defs(enc, bucket)
      +wire = w10_if_word(6) ++ w10_if_word(2) ++ w10_if_word(hash) ++ w10_if_word(w10_if_res_id(r1))
      w10_if_intern_rec(w10_if_res_enc(r1), wire)
    case KIndexNode{hash, mask, left, right}:
      +r2 = w10_if_enc_def(enc, left)
      +r3 = w10_if_enc_def(w10_if_res_enc(r2), right)
      +wire = w10_if_word(7) ++ w10_if_word(4) ++
        w10_if_word(hash) ++ w10_if_word(mask) ++ w10_if_word(w10_if_res_id(r2)) ++ w10_if_word(w10_if_res_id(r3))
      w10_if_intern_rec(w10_if_res_enc(r3), wire)

@unsafe
def w10_if_enc_state(enc: W10IfEnc, st: KBasePrefixState) -> W10IfRes:
  match st:
    case KBasePrefixState{bound, delta, stamp, patches, ready}:
      +r3 = w10_if_enc_defs(enc, patches)
      +wire = w10_if_word(8) ++ w10_if_word(5) ++
        w10_if_word(bound) ++ w10_if_word(delta) ++ w10_if_word(stamp) ++ w10_if_word(w10_if_res_id(r3)) ++ w10_if_word(Bool.to_u32(ready))
      w10_if_intern_rec(w10_if_res_enc(r3), wire)

@unsafe
def w10_if_enc_fresh(enc: W10IfEnc, fr: FFreshPrefixState) -> W10IfRes:
  match fr:
    case FFreshPrefixState{next, ready}:
      +wire = w10_if_word(9) ++ w10_if_word(2) ++ w10_if_word(next) ++ w10_if_word(Bool.to_u32(ready))
      w10_if_intern_rec(enc, wire)

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
      +wire = w10_if_word(10) ++ w10_if_word(8) ++
        w10_if_word(w10_if_res_id(r0)) ++ w10_if_word(w10_if_res_id(r1)) ++ w10_if_word(w10_if_res_id(r2)) ++ w10_if_word(w10_if_res_id(r3)) ++
        w10_if_word(w10_if_res_id(r4)) ++ w10_if_word(w10_if_res_id(r5)) ++ w10_if_word(todos) ++ w10_if_word(cbound)
      w10_if_intern_rec(w10_if_res_enc(r5), wire)

@unsafe
def w10_if_enc_ready(enc: W10IfEnc, rd: FReadyPrefixState) -> W10IfRes:
  match rd:
    case FReadyPrefixState{names, ctors, count, ready}:
      +r0 = w10_if_enc_def(enc, names)
      +r1 = w10_if_enc_def(w10_if_res_enc(r0), ctors)
      +wire = w10_if_word(11) ++ w10_if_word(4) ++
        w10_if_word(w10_if_res_id(r0)) ++ w10_if_word(w10_if_res_id(r1)) ++ w10_if_word(count) ++ w10_if_word(Bool.to_u32(ready))
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
      +header = w10_if_push_str(stamp) ++ w10_if_word(rn) ++ w10_if_word(sn)
      +trailer = w10_if_word(r0) ++ w10_if_word(r1) ++ w10_if_word(r2) ++ w10_if_word(r3) ++ w10_if_word(r4)
      do IO<U32>:
        file : File <- IO.try(File, File.open("/dev/stdout", "w"))
        p0 : File & Result<&1, &1, U32 & String, Unit> <- File.write(file, header)
        w10_if_stream_s1(p0, List.reverse(&2, String, str_rev), List.reverse(&2, String, rec_rev), trailer, stamp)

# --- Parse PREFIX suffix against loaded Base seed ---

@unsafe
def w10_if_load_trace(load: FPrefixLoad) -> W10IfLoad:
  match load:
    case FPrefixLoad{FLoadTrace{FResult{_, +lerr, _}, _, _}, _, +suffix, _}:
      nt_choose(W10IfLoad, String.is_empty(lerr),
        z => W10IfLoad{True{}, "", suffix},
        z => W10IfLoad{False{}, "x86-iface parse: " ++ lerr, Nil{}})

@unsafe
def w10_if_load_comp2(+source: FSource, +base: FSource, +fresh: FFreshPrefixState, comp2: FPrefixCompletion) -> W10IfLoad:
  match comp2:
    case FPrefixCompletion{carrier2, _}:
      w10_if_load_trace(f_prefix_graph_trace(carrier2, [source, base], fresh))

@unsafe
def w10_if_load_comp1(+source: FSource, +base: FSource, +fresh: FFreshPrefixState, +header: FHeader, comp1: FPrefixCompletion) -> W10IfLoad:
  match comp1:
    case FPrefixCompletion{+carrier, FResult{_, +perr, _}}:
      nt_choose(W10IfLoad, String.is_empty(perr),
        w => w10_if_load_comp2(source, base, fresh, f_prefix_complete_source(source, "", header, [source, base], carrier, f_path_dir(f_source_path(source)))),
        w => W10IfLoad{False{}, "x86-iface base seed: " ++ perr, Nil{}})

@unsafe
def w10_if_load_hdr(+base: FSource, +book: List<&2, KDef>, +fresh: FFreshPrefixState, +ready: FReadyPrefixState, +source: FSource, +header: FHeader) -> W10IfLoad:
  match header:
    case FHeader{+imports, +herr, body, line, offset}:
      nt_choose(W10IfLoad, String.is_empty(herr),
        u =>
          +ierr = p86_import_error(imports, False{})
          nt_choose(W10IfLoad, String.is_empty(ierr),
            v => w10_if_load_comp1(source, base, fresh, header, f_prefix_complete_ready_seed(base, "", f_prefix_graph_empty(), f_source_path(base), f_source_text(base), book, ready)),
            v => W10IfLoad{False{}, "x86-iface import: " ++ ierr, Nil{}}),
        u => W10IfLoad{False{}, "x86-iface header: " ++ herr, Nil{}})

@unsafe
def w10_if_load_suffix(+seed: P86Seed, +path: String, +text: String) -> W10IfLoad:
  match seed:
    case P86Seed{+base, +book, +fresh, +ready, world}:
      +begin = f_source_end(base)
      +source = f_source_located(FSource{path, path, text}, begin, U32.add(U32.add(begin, p86_width(text, 0)), 1))
      w10_if_load_hdr(base, book, fresh, ready, source, f_source_header(source))

# --- End-to-end x86-iface driver ---

@unsafe
def w10_if_emit_checked(+stamp: String, +s_book: List<&2, KDef>, +s_fresh: FFreshPrefixState, +s_ready: FReadyPrefixState, +s_state: KBasePrefixState, +s_world: KBasePreparedWorld) -> IO(U32):
  match s_ready s_state:
    case FReadyPrefixState{_, _, _, True{}} KBasePrefixState{_, _, _, _, True{}}:
      +e0 = w10_if_enc_defs(w10_if_enc_empty(), s_book)
      +e1 = w10_if_enc_state(w10_if_res_enc(e0), s_state)
      +e2 = w10_if_enc_fresh(w10_if_res_enc(e1), s_fresh)
      +e3 = w10_if_enc_world(w10_if_res_enc(e2), s_world)
      +e4 = w10_if_enc_ready(w10_if_res_enc(e3), s_ready)
      w10_if_stream_carrier(stamp, w10_if_res_enc(e4), w10_if_res_id(e0), w10_if_res_id(e1), w10_if_res_id(e2), w10_if_res_id(e3), w10_if_res_id(e4))
    case _ _: IO.die(U32, 1, "x86-iface: prepared interface state was not ready")

@unsafe
def w10_if_mark_ready(st: KBasePrefixState) -> KBasePrefixState:
  match st:
    case KBasePrefixState{bound, delta, stamp, patches, _}:
      KBasePrefixState{bound, delta, stamp, patches, True{}}

@unsafe
def w10_if_emit_freshened(+stamp: String, +base_book: List<&2, KDef>, +base_state: KBasePrefixState, +base_final: List<&2, KDef>, fdefs: FFreshDefs) -> IO(U32):
  match fdefs:
    case FFreshDefs{+fresh_suffix, +next_id}:
      +s_book = List.append(&2, KDef, base_book, fresh_suffix)
      +s_fresh : FFreshPrefixState = FFreshPrefixState{next_id, True{}}
      +s_ready : FReadyPrefixState = f_ready_prefix_prepare(s_book)
      +checked : DChecking = base_prefix_resume_saved(base_state, base_book, fresh_suffix, norm_max_book(s_book), base_final)
      nt_choose(IO(U32), good(dg_checking_result(checked)),
        u =>
          +s_state : KBasePrefixState = w10_if_mark_ready(p86_checked_prefix(s_book, checked))
          +s_world : KBasePreparedWorld = base_prefix_world_prepare(s_book, s_state)
          w10_if_emit_checked(stamp, s_book, s_fresh, s_ready, s_state, s_world),
        u => IO.die(U32, 1, "x86-iface: stub check failed: " ++ ce(dg_checking_result(checked))))

@unsafe
def w10_if_emit_seed(+base_seed: P86Seed, +suffix: List<&2, KDef>, +abi: W10IfAbi) -> IO(U32):
  match base_seed:
    case P86Seed{base_src, +base_book, FFreshPrefixState{+base_next, _}, base_ready, KBasePreparedWorld{+base_state, base_pfx, +base_final, _, _, _, _, _}}:
      +stamp = w10_if_stamp_str(w10_if_h_defs(w10_if_h_init(), suffix, abi))
      +stripped = w10_if_strip_suffix(suffix, abi, missing())
      w10_if_emit_freshened(stamp, base_book, base_state, base_final, f_fresh_defs(stripped, base_next))

@unsafe
def w10_if_run_loaded(+seed: P86Seed, +abi: W10IfAbi, loaded: W10IfLoad) -> IO(U32):
  match loaded:
    case W10IfLoad{True{}, _, suffix}: w10_if_emit_seed(seed, suffix, abi)
    case W10IfLoad{False{}, lerr, _}: IO.die(U32, 1, lerr)

@unsafe
def w10_if_run_plan(+seed: P86Seed, +path: String, +source: String, prepared: P169Prepared) -> IO(U32):
  match prepared:
    case P169Prepared{_, +cursor, +error}:
      nt_choose(IO(U32), String.is_empty(error),
        u => w10_if_run_loaded(seed, w10_if_collect_abi(cursor, missing(), missing()), w10_if_load_suffix(seed, path, source)),
        u => IO.die(U32, 1, "x86-iface: " ++ error))

@unsafe
def w10_if_run_prepared(+path: String, +source: String, prep: P86Preparation) -> IO(U32):
  match prep:
    case P86PreparationError{error}: IO.die(U32, 1, error)
    case P86PreparationReady{+seed}:
      w10_if_run_plan(seed, path, source, x198pw_plan(p86_plan(seed, path, source)))

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
