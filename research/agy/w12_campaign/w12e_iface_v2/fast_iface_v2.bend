# === AGY-W12E-FAST-IFACE-V2: Pure-Bend Fast x86-iface v2 ===
# Builds on Wave 11 (P5-D) with 3 major pure-Bend optimizations (0 new types, 0 C, 0 JS):
#   1. Zero-rm + Complete Multi-Cache .p130 encoder:
#      (a) Pre-allocates Nil{} at record 0 (O(1) w10_if_enc_nil) and emits all other records in
#          O(1) via w10_if_emit_rec (eliminates 425k-entry rm Patricia trie lookups/insertions).
#      (b) Complete KDef ID caching across all 6 world/ready views:
#          - unique_cache (non-dup s_book defs) seeds final_cache;
#          - final_cache (every def in world.final, incl. merged law+def) serves world.book;
#          - patch_cache (s_state.patches) + final_cache serves world.checked;
#          - last_cache (last-wins s_book defs) serves world.seen and ready.names.
#          Zero KDefs (neither 319 base.bend patches nor 889 law+def pairs) are re-encoded!
#      (c) Right-associated batch concatenation in w10_if_take_batch.
#   2. Incremental O(|suffix|) world & ready extension (w10_if_emit_extended + w10_if_book_put_fast):
#      When fresh_suffix contains only stubbed Defs (zero ADTs, as in m01..m10), extends
#      base_world and base_ready directly via book_put_many_cached without O(N) prefix validation,
#      base_prefix_resume_world, p86_checked_prefix, or base_prefix_world_prepare.
#   3. Upstream-stub fast-path in w10_if_fast_abi:
#      Strips Ann wrappers (w10_if_strip_ann) to classify already-stubbed upstream defs from
#      base_book in O(1) (direct stub -> insert into worker_sigs directly; CPS stub -> skip),
#      running p128br_scan and p113pl_candidates only on new suffix defs + non-stub Base defs.

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
  W10IfEnc{missing(), Nil{}, 0, missing(), Con{w10_if_w(0, w10_if_w(0, SNil{})), Nil{}}, 1}

@unsafe
def w10_if_intern_str(enc: W10IfEnc, +s: String) -> W10IfRes:
  match enc:
    case W10IfEnc{+sm, +sr, +sn, +rm, +rr, +rn}:
      +hit = p111v_get(sm, s)
      nt_choose(W10IfRes, agy_str_eq(dk(hit), "Absent"),
        u => W10IfRes{W10IfEnc{p111v_put(sm, s, "S", sn, 0), Con{w10_if_push_str(s), sr}, U32.inc(sn), rm, rr, rn}, sn},
        u => W10IfRes{W10IfEnc{sm, sr, sn, rm, rr, rn}, da(hit)})

@unsafe
def w10_if_emit_rec(enc: W10IfEnc, +wire: String) -> W10IfRes:
  match enc:
    case W10IfEnc{sm, sr, sn, rm, rr, +rn}:
      W10IfRes{W10IfEnc{sm, sr, sn, rm, Con{wire, rr}, U32.inc(rn)}, rn}

@unsafe
def w10_if_intern_rec(enc: W10IfEnc, +wire: String) -> W10IfRes:
  w10_if_emit_rec(enc, wire)

@unsafe
def w10_if_enc_nil(enc: W10IfEnc) -> W10IfRes:
  W10IfRes{enc, 0}

@unsafe
def w10_if_enc_con(enc: W10IfEnc, +a: U32, +b: U32) -> W10IfRes:
  w10_if_emit_rec(enc, w10_if_w(1, w10_if_w(2, w10_if_w(a, w10_if_w(b, SNil{})))))

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
      w10_if_emit_rec(w10_if_res_enc(r5), wire)
    case KLambda{name, id, quant, kids, removed, ob, oe, qp}:
      +r0 = w10_if_intern_str(enc, name)
      +r3 = w10_if_enc_terms(w10_if_res_enc(r0), kids)
      +r4 = w10_if_enc_strs(w10_if_res_enc(r3), removed)
      +wire = w10_if_w(3, w10_if_w(8,
        w10_if_w(w10_if_res_id(r0), w10_if_w(id, w10_if_w(quant,
        w10_if_w(w10_if_res_id(r3), w10_if_w(w10_if_res_id(r4), w10_if_w(ob, w10_if_w(oe, w10_if_w(Bool.to_u32(qp), SNil{}))))))))))
      w10_if_emit_rec(w10_if_res_enc(r4), wire)
    case KLiteral{kind, number, text, ob, oe}:
      +r0 = w10_if_intern_str(enc, kind)
      +r2 = w10_if_intern_str(w10_if_res_enc(r0), text)
      +wire = w10_if_w(4, w10_if_w(5,
        w10_if_w(w10_if_res_id(r0), w10_if_w(number, w10_if_w(w10_if_res_id(r2), w10_if_w(ob, w10_if_w(oe, SNil{})))))))
      w10_if_emit_rec(w10_if_res_enc(r2), wire)

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
      w10_if_emit_rec(w10_if_res_enc(r6), wire)
    case KIndexLeaf{hash, bucket}:
      +r1 = w10_if_enc_defs(enc, bucket)
      +wire = w10_if_w(6, w10_if_w(2, w10_if_w(hash, w10_if_w(w10_if_res_id(r1), SNil{}))))
      w10_if_emit_rec(w10_if_res_enc(r1), wire)
    case KIndexNode{hash, mask, left, right}:
      +r2 = w10_if_enc_def(enc, left)
      +r3 = w10_if_enc_def(w10_if_res_enc(r2), right)
      +wire = w10_if_w(7, w10_if_w(4,
        w10_if_w(hash, w10_if_w(mask, w10_if_w(w10_if_res_id(r2), w10_if_w(w10_if_res_id(r3), SNil{}))))))
      w10_if_emit_rec(w10_if_res_enc(r3), wire)

# --- Complete O(1) KDef caches (unique_cache, last_cache, final_cache, patch_cache) ---

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
def w10_if_cache_put_any(h: KDef, +id: U32, +cache: KDef) -> KDef:
  match h:
    case KDef{+name, _, _, _, _, _, _, _, _}:
      p111v_put(cache, name, "C", id, 0)
    case _: cache

@unsafe
def w10_if_enc_book_join(+id1: U32, pair: W10IfRes & W10IfAbi) -> W10IfRes & W10IfAbi:
  (+r2, caches) = pair
  (w10_if_enc_con(w10_if_res_enc(r2), id1, w10_if_res_id(r2)), caches)

@unsafe
def w10_if_enc_book_defs2(enc: W10IfEnc, xs: List<&2, KDef>, +bad: KDef, +ucache: KDef, +lcache: KDef) -> W10IfRes & W10IfAbi:
  match xs:
    case Nil{}: (w10_if_enc_nil(enc), W10IfAbi{ucache, lcache})
    case Con{+h, t}:
      +r1 = w10_if_enc_def(enc, h)
      +id1 = w10_if_res_id(r1)
      +u1 = w10_if_cache_put(h, id1, bad, ucache)
      +l1 = w10_if_cache_put_any(h, id1, lcache)
      w10_if_enc_book_join(id1, w10_if_enc_book_defs2(w10_if_res_enc(r1), t, bad, u1, l1))

@unsafe
def w10_if_enc_book_join1(+id1: U32, pair: W10IfRes & KDef) -> W10IfRes & KDef:
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
      w10_if_enc_book_join1(id1, w10_if_enc_book_defs(w10_if_res_enc(r1), t, bad, cache1))

law w10_if_enc_final_defs:
  for +enc: W10IfEnc
  for xs: List<&2, KDef>
  for +fcache: KDef
  W10IfRes & KDef

@unsafe
def w10_if_enc_final_one(+enc: W10IfEnc, +h: KDef, +t: List<&2, KDef>, +fcache: KDef) -> W10IfRes & KDef:
  match h:
    case KDef{+name, _, _, _, _, _, _, _, _}:
      +hit = p111v_get(fcache, name)
      nt_choose(W10IfRes & KDef, agy_str_eq(dk(hit), "Absent"),
        u =>
          +r1 = w10_if_enc_def(enc, h)
          +id1 = w10_if_res_id(r1)
          +fc1 = p111v_put(fcache, name, "C", id1, 0)
          w10_if_enc_book_join1(id1, w10_if_enc_final_defs(w10_if_res_enc(r1), t, fc1)),
        u =>
          w10_if_enc_book_join1(da(hit), w10_if_enc_final_defs(enc, t, fcache)))
    case _:
      +r1 = w10_if_enc_def(enc, h)
      w10_if_enc_book_join1(w10_if_res_id(r1), w10_if_enc_final_defs(w10_if_res_enc(r1), t, fcache))

@unsafe
def w10_if_enc_final_defs(enc, xs, fcache):
  match xs:
    case Nil{}: (w10_if_enc_nil(enc), fcache)
    case Con{h, t}: w10_if_enc_final_one(enc, h, t, fcache)

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
    case KDef{+name, +kind, arity, templates, typ, value, ctors, native, unsafe}:
      nt_choose(W10IfRes, agy_str_eq(kind, "BookCache"),
        u =>
          +r0 = w10_if_intern_str(enc, name)
          +r1 = w10_if_intern_str(w10_if_res_enc(r0), kind)
          +r4 = w10_if_enc_term(w10_if_res_enc(r1), typ)
          +r5 = w10_if_enc_term(w10_if_res_enc(r4), value)
          +r6 = w10_if_enc_defs_c(w10_if_res_enc(r5), ctors, cache)
          +wire = w10_if_w(5, w10_if_w(9,
            w10_if_w(w10_if_res_id(r0), w10_if_w(w10_if_res_id(r1), w10_if_w(arity, w10_if_w(templates,
            w10_if_w(w10_if_res_id(r4), w10_if_w(w10_if_res_id(r5), w10_if_w(w10_if_res_id(r6),
            w10_if_w(Bool.to_u32(native), w10_if_w(Bool.to_u32(unsafe), SNil{})))))))))))
          w10_if_emit_rec(w10_if_res_enc(r6), wire),
        u =>
          +hit = p111v_get(cache, name)
          nt_choose(W10IfRes, agy_str_eq(dk(hit), "Absent"),
            v => w10_if_enc_def(enc, d),
            v => W10IfRes{enc, da(hit)}))
    case KIndexLeaf{hash, bucket}:
      +r1 = w10_if_enc_defs_c(enc, bucket, cache)
      +wire = w10_if_w(6, w10_if_w(2, w10_if_w(hash, w10_if_w(w10_if_res_id(r1), SNil{}))))
      w10_if_emit_rec(w10_if_res_enc(r1), wire)
    case KIndexNode{hash, mask, left, right}:
      +r2 = w10_if_enc_def_c(enc, left, cache)
      +r3 = w10_if_enc_def_c(w10_if_res_enc(r2), right, cache)
      +wire = w10_if_w(7, w10_if_w(4,
        w10_if_w(hash, w10_if_w(mask, w10_if_w(w10_if_res_id(r2), w10_if_w(w10_if_res_id(r3), SNil{}))))))
      w10_if_emit_rec(w10_if_res_enc(r3), wire)

@unsafe
def w10_if_enc_def_c2(+enc: W10IfEnc, +h: KDef, +pcache: KDef, +fcache: KDef) -> W10IfRes:
  match h:
    case KDef{+name, _, _, _, _, _, _, _, _}:
      +phit = p111v_get(pcache, name)
      nt_choose(W10IfRes, agy_str_eq(dk(phit), "Absent"),
        u =>
          +fhit = p111v_get(fcache, name)
          nt_choose(W10IfRes, agy_str_eq(dk(fhit), "Absent"),
            v => w10_if_enc_def(enc, h),
            v => W10IfRes{enc, da(fhit)}),
        u => W10IfRes{enc, da(phit)})
    case _: w10_if_enc_def(enc, h)

@unsafe
def w10_if_enc_defs_c2(enc: W10IfEnc, xs: List<&2, KDef>, +pcache: KDef, +fcache: KDef) -> W10IfRes:
  match xs:
    case Nil{}: w10_if_enc_nil(enc)
    case Con{h, t}:
      +r1 = w10_if_enc_def_c2(enc, h, pcache, fcache)
      +r2 = w10_if_enc_defs_c2(w10_if_res_enc(r1), t, pcache, fcache)
      w10_if_enc_con(w10_if_res_enc(r2), w10_if_res_id(r1), w10_if_res_id(r2))

@unsafe
def w10_if_enc_state(enc: W10IfEnc, st: KBasePrefixState) -> W10IfRes:
  match st:
    case KBasePrefixState{bound, delta, stamp, patches, ready}:
      +r3 = w10_if_enc_defs(enc, patches)
      +wire = w10_if_w(8, w10_if_w(5,
        w10_if_w(bound, w10_if_w(delta, w10_if_w(stamp, w10_if_w(w10_if_res_id(r3), w10_if_w(Bool.to_u32(ready), SNil{})))))))
      w10_if_emit_rec(w10_if_res_enc(r3), wire)

@unsafe
def w10_if_enc_state_join(+bound: U32, +delta: U32, +stamp: U32, +ready: Bool, pair: W10IfRes & KDef) -> W10IfRes & KDef:
  (+r3, patch_cache) = pair
  +wire = w10_if_w(8, w10_if_w(5,
    w10_if_w(bound, w10_if_w(delta, w10_if_w(stamp, w10_if_w(w10_if_res_id(r3), w10_if_w(Bool.to_u32(ready), SNil{})))))))
  (w10_if_emit_rec(w10_if_res_enc(r3), wire), patch_cache)

@unsafe
def w10_if_enc_state_c(enc: W10IfEnc, st: KBasePrefixState) -> W10IfRes & KDef:
  match st:
    case KBasePrefixState{+bound, +delta, +stamp, patches, +ready}:
      w10_if_enc_state_join(bound, delta, stamp, ready, w10_if_enc_book_defs(enc, patches, missing(), missing()))

@unsafe
def w10_if_enc_fresh(enc: W10IfEnc, fr: FFreshPrefixState) -> W10IfRes:
  match fr:
    case FFreshPrefixState{next, ready}:
      +wire = w10_if_w(9, w10_if_w(2, w10_if_w(next, w10_if_w(Bool.to_u32(ready), SNil{}))))
      w10_if_emit_rec(enc, wire)

@unsafe
def w10_if_enc_world_v2_rest(+state_id: U32, +book_id: U32, book: List<&2, KDef>, checked: List<&2, KDef>, seen: List<&2, KDef>, +todos: U32, +cbound: U32, +lcache: KDef, +pcache: KDef, fpair: W10IfRes & KDef) -> W10IfRes:
  (+r2, +fcache) = fpair
  +r3 = w10_if_enc_defs_c(w10_if_res_enc(r2), book, fcache)
  +r4 = w10_if_enc_defs_c2(w10_if_res_enc(r3), checked, pcache, fcache)
  +r5 = w10_if_enc_defs_c(w10_if_res_enc(r4), seen, lcache)
  +wire = w10_if_w(10, w10_if_w(8,
    w10_if_w(state_id, w10_if_w(book_id, w10_if_w(w10_if_res_id(r2), w10_if_w(w10_if_res_id(r3),
    w10_if_w(w10_if_res_id(r4), w10_if_w(w10_if_res_id(r5), w10_if_w(todos, w10_if_w(cbound, SNil{}))))))))))
  w10_if_emit_rec(w10_if_res_enc(r5), wire)

@unsafe
def w10_if_enc_world_v2(enc: W10IfEnc, w: KBasePreparedWorld, +state_id: U32, +book_id: U32, +ucache: KDef, +lcache: KDef, +pcache: KDef) -> W10IfRes:
  match w:
    case KBasePreparedWorld{state, prefix, final, book, checked, seen, todos, cbound}:
      w10_if_enc_world_v2_rest(state_id, book_id, book, checked, seen, todos, cbound, lcache, pcache,
        w10_if_enc_final_defs(enc, final, ucache))

@unsafe
def w10_if_enc_world_fast(enc: W10IfEnc, w: KBasePreparedWorld, +state_id: U32, +book_id: U32, +cache: KDef) -> W10IfRes:
  w10_if_enc_world_v2(enc, w, state_id, book_id, cache, cache, missing())

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
      w10_if_emit_rec(w10_if_res_enc(r5), wire)

@unsafe
def w10_if_enc_ready_fast(enc: W10IfEnc, rd: FReadyPrefixState, +cache: KDef) -> W10IfRes:
  match rd:
    case FReadyPrefixState{names, ctors, count, ready}:
      +r0 = w10_if_enc_def_c(enc, names, cache)
      +r1 = w10_if_enc_def(w10_if_res_enc(r0), ctors)
      +wire = w10_if_w(11, w10_if_w(4,
        w10_if_w(w10_if_res_id(r0), w10_if_w(w10_if_res_id(r1), w10_if_w(count, w10_if_w(Bool.to_u32(ready), SNil{}))))))
      w10_if_emit_rec(w10_if_res_enc(r1), wire)

@unsafe
def w10_if_enc_ready(enc: W10IfEnc, rd: FReadyPrefixState) -> W10IfRes:
  match rd:
    case FReadyPrefixState{names, ctors, count, ready}:
      +r0 = w10_if_enc_def(enc, names)
      +r1 = w10_if_enc_def(w10_if_res_enc(r0), ctors)
      +wire = w10_if_w(11, w10_if_w(4,
        w10_if_w(w10_if_res_id(r0), w10_if_w(w10_if_res_id(r1), w10_if_w(count, w10_if_w(Bool.to_u32(ready), SNil{}))))))
      w10_if_emit_rec(w10_if_res_enc(r1), wire)

# --- Batched streaming writer to /dev/stdout (right-associated) ---

@unsafe
def w10_if_take_batch_join(+h: String, pair: String & List<&2, String>) -> String & List<&2, String>:
  (rest_str, rest_xs) = pair
  (h ++ rest_str, rest_xs)

@unsafe
def w10_if_take_batch(xs: List<&2, String>, +n: U32, +acc: String) -> String & List<&2, String>:
  match xs:
    case Nil{}: (acc, Nil{})
    case Con{+h, +t}:
      nt_choose(String & List<&2, String>, U32.is_eq(n, 0),
        u => (acc, Con{h, t}),
        u => w10_if_take_batch_join(h, w10_if_take_batch(t, U32.sub(n, 1), acc)))

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
    case Con{h, t}: w10_if_write_batch(file, w10_if_take_batch(Con{h, t}, 128, ""))

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

# --- End-to-end fast x86-iface v2 driver ---

@unsafe
def w10_if_emit_checked_st(+stamp: String, +s_fresh: FFreshPrefixState, +s_ready: FReadyPrefixState, +s_world: KBasePreparedWorld, +book_id: U32, +ucache: KDef, +lcache: KDef, st_pair: W10IfRes & KDef) -> IO(U32):
  (+e1, +pcache) = st_pair
  +e2 = w10_if_enc_fresh(w10_if_res_enc(e1), s_fresh)
  +e3 = w10_if_enc_world_v2(w10_if_res_enc(e2), s_world, w10_if_res_id(e1), book_id, ucache, lcache, pcache)
  +e4 = w10_if_enc_ready_fast(w10_if_res_enc(e3), s_ready, lcache)
  w10_if_stream_carrier(stamp, w10_if_res_enc(e4), book_id, w10_if_res_id(e1), w10_if_res_id(e2), w10_if_res_id(e3), w10_if_res_id(e4))

@unsafe
def w10_if_emit_checked_go2(+stamp: String, +s_fresh: FFreshPrefixState, +s_ready: FReadyPrefixState, +s_state: KBasePrefixState, +s_world: KBasePreparedWorld, +e0: W10IfRes, caches: W10IfAbi) -> IO(U32):
  match caches:
    case W10IfAbi{+ucache, +lcache}:
      w10_if_emit_checked_st(stamp, s_fresh, s_ready, s_world, w10_if_res_id(e0), ucache, lcache, w10_if_enc_state_c(w10_if_res_enc(e0), s_state))

@unsafe
def w10_if_emit_checked_go(+stamp: String, +s_fresh: FFreshPrefixState, +s_ready: FReadyPrefixState, +s_state: KBasePrefixState, +s_world: KBasePreparedWorld, book_pair: W10IfRes & W10IfAbi) -> IO(U32):
  (+e0, caches) = book_pair
  w10_if_emit_checked_go2(stamp, s_fresh, s_ready, s_state, s_world, e0, caches)

@unsafe
def w10_if_emit_checked(+stamp: String, +s_book: List<&2, KDef>, +s_fresh: FFreshPrefixState, +s_ready: FReadyPrefixState, +s_state: KBasePrefixState, +s_world: KBasePreparedWorld) -> IO(U32):
  match s_ready s_state:
    case FReadyPrefixState{_, _, _, True{}} KBasePrefixState{_, _, _, _, True{}}:
      +bad = w10_if_mark_dups(s_book, missing(), missing())
      w10_if_emit_checked_go(stamp, s_fresh, s_ready, s_state, s_world, w10_if_enc_book_defs2(w10_if_enc_empty(), s_book, bad, missing(), missing()))
    case _ _: IO.die(U32, 1, "x86-iface: prepared interface state was not ready")

@unsafe
def w10_if_mark_ready(st: KBasePrefixState) -> KBasePrefixState:
  match st:
    case KBasePrefixState{bound, delta, stamp, patches, _}:
      KBasePrefixState{bound, delta, stamp, patches, True{}}

# --- Incremental O(|suffix|) world & ready extension for stub-only suffixes ---

@unsafe
def w10_if_all_stub_defs(ds: List<&2, KDef>) -> Bool:
  match ds:
    case Nil{}: True{}
    case Con{KDef{_, +kind, _, _, _, _, +ctors, +native, +unsafe}, rest}:
      nt_choose(Bool, agy_str_eq(kind, "Def") && native && List.is_empty(&2, KDef, ctors),
        u => w10_if_all_stub_defs(rest),
        u => False{})
    case Con{_, _}: False{}

@unsafe
def w10_if_book_put_fast(+book: List<&2, KDef>, +defs: List<&2, KDef>) -> List<&2, KDef>:
  match book:
    case Con{+cache, +rest}:
      nt_choose(List<&2, KDef>, agy_str_eq(dk(cache), "BookCache"),
        u => book_put_many_cached(cache, rest, defs),
        u => base_prefix_put(book, defs))
    case Nil{}: base_prefix_put(book, defs)

@unsafe
def w10_if_ready_extend(+base_ready: FReadyPrefixState, +s_book: List<&2, KDef>, +fresh_suffix: List<&2, KDef>) -> FReadyPrefixState:
  match base_ready:
    case FReadyPrefixState{+b_names, +b_ctors, +b_count, True{}}:
      FReadyPrefixState{index_set_many(b_names, List.reverse(&2, KDef, fresh_suffix)), b_ctors, U32.add(b_count, f_graph_count_defs(fresh_suffix, 0)), True{}}
    case _: f_ready_prefix_prepare(s_book)

@unsafe
def w10_if_emit_extended(+stamp: String, +s_book: List<&2, KDef>, +s_fresh: FFreshPrefixState, +s_ready: FReadyPrefixState, +base_world: KBasePreparedWorld, +fresh_suffix: List<&2, KDef>) -> IO(U32):
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
      w10_if_emit_checked(stamp, s_book, s_fresh, s_ready, s_state, s_world)

@unsafe
def w10_if_emit_freshened(+stamp: String, +base_book: List<&2, KDef>, +base_ready: FReadyPrefixState, +base_world: KBasePreparedWorld, fdefs: FFreshDefs) -> IO(U32):
  match fdefs:
    case FFreshDefs{+fresh_suffix, +next_id}:
      +s_book = List.append(&2, KDef, base_book, fresh_suffix)
      +s_fresh : FFreshPrefixState = FFreshPrefixState{next_id, True{}}
      nt_choose(IO(U32), w10_if_all_stub_defs(fresh_suffix),
        u =>
          +s_ready : FReadyPrefixState = w10_if_ready_extend(base_ready, s_book, fresh_suffix)
          w10_if_emit_extended(stamp, s_book, s_fresh, s_ready, base_world, fresh_suffix),
        u =>
          +s_ready : FReadyPrefixState = f_ready_prefix_prepare(s_book)
          +checked : DChecking = base_prefix_resume_world(base_world, fresh_suffix, norm_max_book(s_book))
          nt_choose(IO(U32), good(dg_checking_result(checked)),
            v =>
              +s_state : KBasePrefixState = w10_if_mark_ready(p86_checked_prefix(s_book, checked))
              +s_world : KBasePreparedWorld = base_prefix_world_prepare(s_book, s_state)
              w10_if_emit_checked(stamp, s_book, s_fresh, s_ready, s_state, s_world),
            v => IO.die(U32, 1, "x86-iface: stub check failed: " ++ ce(dg_checking_result(checked)))))

@unsafe
def w10_if_emit_seed(+base_seed: P86Seed, +suffix: List<&2, KDef>, +abi: W10IfAbi) -> IO(U32):
  match base_seed:
    case P86Seed{base_src, +base_book, FFreshPrefixState{+base_next, _}, +base_ready, +base_world}:
      +stamp = w10_if_stamp_str(w10_if_h_defs(w10_if_h_init(), suffix, abi))
      +stripped = w10_if_strip_suffix(suffix, abi, missing())
      w10_if_emit_freshened(stamp, base_book, base_ready, base_world, f_fresh_defs(stripped, base_next))

# --- Upstream stub fast-path for direct-ABI scan (strips Ann wrappers!) ---

@unsafe
def w10_if_suffix_set(ds: List<&2, KDef>, acc: KDef) -> KDef:
  match ds:
    case Nil{}: acc
    case Con{d, rest}: w10_if_suffix_set(rest, p111v_put(acc, dn(d), "S", 1, 0))

@unsafe
def w10_if_is_direct_call(+name: String, +t0: KTerm, +k: U32) -> Bool:
  +t = w10_if_strip_ann(t0)
  nt_choose(Bool, U32.is_eq(k, 0),
    u => p98_tag_eq(t, "Ref") && agy_str_eq(nm(t), name),
    u => p98_tag_eq(t, "App") && p98_tag_eq(w10_if_strip_ann(kid(t, 1)), "Var") && w10_if_is_direct_call(name, kid(t, 0), U32.sub(k, 1)))

law w10_if_peel_stub:
  for +name: String
  for +t0: KTerm
  for +k: U32
  U32

@unsafe
def w10_if_peel_stub_cur(+name: String, +t: KTerm, +k: U32) -> U32:
  match t:
    case KLambda{_, _, _, Con{body, _}, _, _, _, _}:
      w10_if_peel_stub(name, body, U32.inc(k))
    case _:
      nt_choose(U32, w10_if_is_direct_call(name, t, k),
        u => U32.add(1000, k),
        u =>
          +b0 = w10_if_strip_ann(kid(t, 0))
          nt_choose(U32, p98_tag_eq(t, "Let") && p98_tag_eq(b0, "Bind") && agy_str_eq(nm(b0), "_f") && w10_if_is_direct_call(name, kid(t, 1), k),
            v => 2,
            v => 0))

@unsafe
def w10_if_peel_stub(name, t0, k):
  w10_if_peel_stub_cur(name, w10_if_strip_ann(t0), k)

@unsafe
def w10_if_stub_kind(+book: List<&2, KDef>, +name: String) -> U32:
  +d = lookup(book, name)
  nt_choose(U32, db(d) && du(d) && agy_str_eq(dk(d), "Def") && U32.is_eq(dx(d), 0),
    u => w10_if_peel_stub(name, dv(d), 0),
    u => 0)

@unsafe
def w10_if_drop_upstream_stubs(+book: List<&2, KDef>, +suf_set: KDef, names: List<&2, String>) -> List<&2, String>:
  match names:
    case Nil{}: Nil{}
    case Con{+name, +rest}:
      nt_choose(List<&2, String>, w10_if_abi_has(suf_set, name),
        u => Con{name, w10_if_drop_upstream_stubs(book, suf_set, rest)},
        u => nt_choose(List<&2, String>, U32.is_eq(w10_if_stub_kind(book, name), 0),
          v => Con{name, w10_if_drop_upstream_stubs(book, suf_set, rest)},
          v => w10_if_drop_upstream_stubs(book, suf_set, rest)))

@unsafe
def w10_if_split_upstream(+book: List<&2, KDef>, +suf_set: KDef, names: List<&2, String>, +sigs: KDef, +active: List<&2, String>) -> KDef & List<&2, String>:
  match names:
    case Nil{}: (sigs, nt_reverse(String, active, Nil{}))
    case Con{+name, +rest}:
      nt_choose(KDef & List<&2, String>, w10_if_abi_has(suf_set, name),
        u => w10_if_split_upstream(book, suf_set, rest, sigs, Con{name, active}),
        u =>
          +sk = w10_if_stub_kind(book, name)
          nt_choose(KDef & List<&2, String>, U32.is_ge(sk, 1000),
            v => w10_if_split_upstream(book, suf_set, rest, p111v_put(sigs, p113d_public(book, name), "P113Direct", U32.sub(sk, 1000), 0), active),
            v => nt_choose(KDef & List<&2, String>, U32.is_eq(sk, 2),
              w => w10_if_split_upstream(book, suf_set, rest, sigs, active),
              w => w10_if_split_upstream(book, suf_set, rest, sigs, Con{name, active}))))

@unsafe
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
