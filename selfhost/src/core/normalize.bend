
# Module: src/core/normalize.bend:367
type KNormFrame is Data:
  KNormFrame{+parent: KTerm, +done: List<&2, KTerm>, +todo: List<&2, KTerm>}

# Module: src/core/normalize.bend:474
type KNormCmp is Data:
  KNormCmp{+a: KTerm, +b: KTerm, +le: Bool, +fresh: U32}
  KNormShare{+left: U32, +right: U32}

# Module: src/core/normalize.bend:478
type KNormAlt is Data:
  KNormAlt{+todo: List<&2, KNormCmp>}

# Module: src/core/normalize.bend:23
law norm_eval:
  for +book: List<&2, KDef>
  for +t: KTerm
  for +args: List<&2, KTerm>
  for +left: U32
  for +fallback: KTerm
  KTerm

# Module: src/core/normalize.bend:131
law norm_ref:
  for +book: List<&2, KDef>
  for +t: KTerm
  for +args: List<&2, KTerm>
  for +d: KDef
  KTerm

# Module: src/core/normalize.bend:141
law norm_args:
  for +book: List<&2, KDef>
  for +t: KTerm
  for +args: List<&2, KTerm>
  for +left: U32
  for +fallback: KTerm
  KTerm

# Module: src/core/normalize.bend:156
law norm_dec:
  for +n: U32
  U32

# Module: src/core/normalize.bend:163
law norm_match:
  for +book: List<&2, KDef>
  for +arm: KTerm
  for +original: KTerm
  for +raw: KTerm
  for +x: KTerm
  for +args: List<&2, KTerm>
  for +left: U32
  for +fallback: KTerm
  KTerm

# Module: src/core/normalize.bend:178
law norm_stuck:
  for +t: KTerm
  for +x: KTerm
  for +args: List<&2, KTerm>
  for +left: U32
  for +fallback: KTerm
  KTerm

# Module: src/core/normalize.bend:189
law norm_min:
  for +book: List<&2, KDef>
  for +a: KTerm
  for +b: KTerm
  KTerm

# Module: src/core/normalize.bend:199
law norm_min_left:
  for +book: List<&2, KDef>
  for +a: KTerm
  for +b: KTerm
  KTerm

# Module: src/core/normalize.bend:208
law norm_min_right:
  for +a: KTerm
  for +b: KTerm
  KTerm

# Module: src/core/normalize.bend:235
law norm_max_book:
  for +book: List<&2, KDef>
  U32

# Module: src/core/normalize.bend:252
law norm_compare:
  for +book: List<&2, KDef>
  for +a: KTerm
  for +b: KTerm
  for +le: Bool
  for +fresh: U32
  Bool

# Module: src/core/normalize.bend:282
law norm_let:
  for +ts: List<&2, KTerm>
  KTerm

# Module: src/core/normalize.bend:294
law norm_let_tail:
  for +h: KTerm
  for +rest: List<&2, KTerm>
  KTerm

# Module: src/core/normalize.bend:312
law norm_var:
  for +book: List<&2, KDef>
  for +t: KTerm
  for +values: List<&2, KTerm>
  for +args: List<&2, KTerm>
  for +left: U32
  for +fallback: KTerm
  KTerm

# Module: src/core/normalize.bend:329
law norm_names_len:
  for +names: List<&2, String>
  U32

# Module: src/core/normalize.bend:343
law norm_book_bound:
  for +book: List<&2, KDef>
  U32

# Module: src/core/normalize.bend:347
law norm_bound_found:
  for +book: List<&2, KDef>
  for +stamp: KDef
  U32

# Module: src/core/normalize.bend:370
law norm_max_walk:
  for +todo: List<&2, KTerm>
  for +bound: U32
  U32

# Module: src/core/normalize.bend:375
law norm_max_defs:
  for +todo: List<&2, KDef>
  for +bound: U32
  U32

# Module: src/core/normalize.bend:405
law norm_exact:
  for +a: KTerm
  for +b: KTerm
  Bool

# Module: src/core/normalize.bend:410
law norm_exact_lists:
  for +as: List<&2, KTerm>
  for +bs: List<&2, KTerm>
  Bool

# Module: src/core/normalize.bend:415
law norm_exact_head:
  for +a: KTerm
  for +b: KTerm
  Bool

# Module: src/core/normalize.bend:420
law norm_exact_names:
  for +as: List<&2, String>
  for +bs: List<&2, String>
  Bool

# Module: src/core/normalize.bend:458
law norm_convert:
  for +book: List<&2, KDef>
  for +a: KTerm
  for +b: KTerm
  for +le: Bool
  for +fresh: U32
  Bool

# Module: src/core/normalize.bend:480
law norm_cmp_loop:
  for +book: List<&2, KDef>
  for +st: GState
  for +todo: List<&2, KNormCmp>
  for +alts: List<&2, KNormAlt>
  Bool

# Module: src/core/normalize.bend:487
law norm_cmp_quick:
  for +a: KTerm
  for +b: KTerm
  Bool

# Module: src/core/normalize.bend:492
law norm_cmp_heads:
  for +book: List<&2, KDef>
  for +st: GState
  for +a: KTerm
  for +b: KTerm
  for +le: Bool
  for +fresh: U32
  for +rest: List<&2, KNormCmp>
  for +alts: List<&2, KNormAlt>
  Bool

# Module: src/core/normalize.bend:503
law norm_cmp_same:
  for +book: List<&2, KDef>
  for +st: GState
  for +a: KTerm
  for +b: KTerm
  for +le: Bool
  for +fresh: U32
  for +rest: List<&2, KNormCmp>
  for +alts: List<&2, KNormAlt>
  Bool

# Module: src/core/normalize.bend:514
law norm_cmp_plain:
  for +book: List<&2, KDef>
  for +st: GState
  for +a: KTerm
  for +b: KTerm
  for +le: Bool
  for +fresh: U32
  for +rest: List<&2, KNormCmp>
  for +alts: List<&2, KNormAlt>
  Bool

# Module: src/core/normalize.bend:525
law norm_cmp_fields:
  for +book: List<&2, KDef>
  for +st: GState
  for +as: List<&2, KTerm>
  for +bs: List<&2, KTerm>
  for +fresh: U32
  for +rest: List<&2, KNormCmp>
  for +alts: List<&2, KNormAlt>
  Bool

# Module: src/core/normalize.bend:535
law norm_cmp_zip:
  for +as: List<&2, KTerm>
  for +bs: List<&2, KTerm>
  for +fresh: U32
  for +rest: List<&2, KNormCmp>
  List<&2, KNormCmp>

# Module: src/core/normalize.bend:542
law norm_cmp_kind:
  for +book: List<&2, KDef>
  for +st: GState
  for +a: KTerm
  for +b: KTerm
  for +g: KTerm
  for +h: KTerm
  for +fresh: U32
  for +rest: List<&2, KNormCmp>
  for +alts: List<&2, KNormAlt>
  Bool

# Module: src/core/normalize.bend:6
@unsafe
def norm_apply(
  +t: KTerm,
  +args: List<&2, KTerm>,
) -> KTerm:
  match args:
    case Nil{}:
      t
    case Con{h, rest}:
      norm_apply(app(t, h), rest)

# Module: src/core/normalize.bend:17
@unsafe
def wnf(
  +book: List<&2, KDef>,
  +t: KTerm,
) -> KTerm:
  norm_eval(book, t, Nil{}, 0, {KTerm{"Absent", "", 0, 0, Nil{}, Nil{}, 0, 0} : KTerm})

# Module: src/core/normalize.bend:32
@unsafe
def norm_eval_node(
  +book: List<&2, KDef>,
  +t: KTerm,
  +args: List<&2, KTerm>,
  +left: U32,
  +fallback: KTerm,
) -> KTerm:
  norm_node_app(book, t, args, left, fallback, p98_tag_eq(t, "App"))

# Module: src/core/normalize.bend:42
@unsafe
def norm_node_app(
  +book: List<&2, KDef>,
  +t: KTerm,
  +args: List<&2, KTerm>,
  +left: U32,
  +fallback: KTerm,
  +selected: Bool,
) -> KTerm:
  match selected:
    case True{}:
      norm_eval(book, kid(t, 0), Con{kid(t, 1), args}, left, fallback)
    case False{}:
      norm_node_ann(book, t, args, left, fallback, p98_tag_eq(t, "Ann"))

# Module: src/core/normalize.bend:57
@unsafe
def norm_node_ann(
  +book: List<&2, KDef>,
  +t: KTerm,
  +args: List<&2, KTerm>,
  +left: U32,
  +fallback: KTerm,
  +selected: Bool,
) -> KTerm:
  match selected:
    case True{}:
      norm_eval(book, kid(t, 0), args, left, fallback)
    case False{}:
      norm_node_let(book, t, args, left, fallback, p98_tag_eq(t, "Let"))

# Module: src/core/normalize.bend:72
@unsafe
def norm_node_let(
  +book: List<&2, KDef>,
  +t: KTerm,
  +args: List<&2, KTerm>,
  +left: U32,
  +fallback: KTerm,
  +selected: Bool,
) -> KTerm:
  match selected:
    case True{}:
      norm_eval(book, norm_let(ks(t)), args, left, fallback)
    case False{}:
      norm_node_ref(book, t, args, left, fallback, p98_tag_eq(t, "Ref"))

# Module: src/core/normalize.bend:87
@unsafe
def norm_node_ref(
  +book: List<&2, KDef>,
  +t: KTerm,
  +args: List<&2, KTerm>,
  +left: U32,
  +fallback: KTerm,
  +selected: Bool,
) -> KTerm:
  match selected:
    case True{}:
      norm_ref(book, t, args, lookup(book, nm(t)))
    case False{}:
      norm_node_min(book, t, args, left, fallback, p98_tag_eq(t, "Min"))

# Module: src/core/normalize.bend:102
@unsafe
def norm_node_min(
  +book: List<&2, KDef>,
  +t: KTerm,
  +args: List<&2, KTerm>,
  +left: U32,
  +fallback: KTerm,
  +selected: Bool,
) -> KTerm:
  match selected:
    case True{}:
      norm_apply(norm_min(book, kid(t, 0), kid(t, 1)), args)
    case False{}:
      norm_node_rwt(book, t, args, left, fallback, p98_tag_eq(t, "Rwt"))

# Module: src/core/normalize.bend:117
@unsafe
def norm_node_rwt(
  +book: List<&2, KDef>,
  +t: KTerm,
  +args: List<&2, KTerm>,
  +left: U32,
  +fallback: KTerm,
  +selected: Bool,
) -> KTerm:
  match selected:
    case True{}:
      kc(KTerm, p98_tag_eq(wnf(book, kid(t, 0)), "Rfl"), u => norm_eval(book, kid(t, 2), args, left, fallback), u => norm_apply(t, args))
    case False{}:
      norm_args(book, t, args, left, fallback)

# Module: src/core/normalize.bend:139
@unsafe
def norm_ref(book, t, args, d):
  kc(KTerm, p88_string_eq(dk(d), "ADT"), u => kc(KTerm, U32.is_eq(da(d), 0), u => norm_apply(kt_span("ADT", nm(t), 0, 0, Nil{}, kb(t), ke(t)), args), u => norm_apply(t, args)), u => kc(KTerm, Bool.and(Bool.not(p98_tag_eq(dv(d), "Absent") || p98_tag_eq(dv(d), "Foreign")), U32.is_le(da(d), terms_len(args))), u => norm_eval(book, dv(d), args, da(d), norm_apply(t, args)), u => norm_apply(t, args)))

# Module: src/core/normalize.bend:150
@unsafe
def norm_args(book, t, args, left, fallback):
  match args:
    case Nil{}:
      t
    case Con{x, rest}:
      kc(KTerm, p98_tag_eq(t, "Lam"), u => norm_eval(book, subst(kid(t, 0), ix(t), x), rest, norm_dec(left), fallback), u => kc(KTerm, p98_tag_eq(t, "Mat"), u => norm_match(book, t, t, x, wnf(book, x), rest, left, fallback), u => kc(KTerm, Bool.and(p98_tag_eq(t, "Efq"), Bool.not(U32.is_eq(left, 0))), u => fallback, u => norm_apply(t, args))))

# Module: src/core/normalize.bend:161
@unsafe
def norm_dec(n):
  kc(U32, U32.is_eq(n, 0), u => 0, u => U32.sub(n, 1))

# Module: src/core/normalize.bend:175
@unsafe
def norm_match(book, arm, original, raw, x, args, left, fallback):
  kc(KTerm, core_literal(x), u => norm_match(book, arm, original, raw, core_literal_step(x), args, left, fallback), u =>
  kc(KTerm, p98_tag_eq(x, "Ctr"), u => kc(KTerm, p98_tag_eq(arm, "Ann"), u => norm_match(book, kid(arm, 0), original, raw, x, args, left, fallback), u => kc(KTerm, p98_tag_eq(arm, "Mat"), u => kc(KTerm, p88_string_eq(nm(arm), nm(x)), u => kc(KTerm, U32.is_eq(left, 0), u => norm_eval(book, kid(arm, 0), norm_join(ks(x), args), 0, fallback), u => norm_eval(book, kid(arm, 0), norm_join(ks(x), args), U32.add(norm_dec(left), terms_len(ks(x))), fallback)), u => norm_match(book, kid(arm, 1), original, raw, x, args, left, fallback)), u => kc(KTerm, p98_tag_eq(arm, "Efq"), u => norm_stuck(original, raw, args, left, fallback), u => norm_eval(book, arm, Con{x, args}, left, fallback)))), u => norm_stuck(original, raw, args, left, fallback)))

# Module: src/core/normalize.bend:187
@unsafe
def norm_stuck(t, x, args, left, fallback):
  kc(KTerm, U32.is_eq(left, 0), u => norm_apply(app(t, x), args), u => fallback)

# Module: src/core/normalize.bend:196
@unsafe
def norm_min(book, a, b):
  norm_min_left(book, wnf(book, a), b)

# Module: src/core/normalize.bend:206
@unsafe
def norm_min_left(book, a, b):
  kc(KTerm, Bool.and(p98_tag_eq(a, "Qua"), U32.is_eq(qt(a), 2)), u => wnf(book, b), u => kc(KTerm, Bool.and(p98_tag_eq(a, "Qua"), U32.is_eq(qt(a), 0)), u => a, u => norm_min_right(a, wnf(book, b))))

# Module: src/core/normalize.bend:214
@unsafe
def norm_min_right(a, b):
  kc(KTerm, p98_tag_eq(b, "Qua"), u => kc(KTerm, U32.is_eq(qt(b), 2), u => a, u => kc(KTerm, Bool.and(U32.is_eq(qt(b), 1), Bool.not(p98_tag_eq(a, "Qua"))), u => kt("Min", "", 0, 0, Con{a, Con{b, Nil{}}}), u => b)), u => kt("Min", "", 0, 0, Con{a, Con{b, Nil{}}}))

# Module: src/core/normalize.bend:217
@unsafe
def strong(
  +book: List<&2, KDef>,
  +t: KTerm,
) -> KTerm:
  graph_strong(book, t)

# Module: src/core/normalize.bend:224
@unsafe
def norm_max(
  +a: U32,
  +b: U32,
) -> U32:
  kc(U32, U32.is_le(a, b), u => b, u => a)

# Module: src/core/normalize.bend:230
@unsafe
def norm_max_term(
  +t: KTerm,
) -> U32:
  norm_max_walk(Con{t, Nil{}}, 0)

# Module: src/core/normalize.bend:240
@unsafe
def norm_max_book(book):
  norm_max_defs(book, 0)

# Module: src/core/normalize.bend:244
@unsafe
def compare(
  +book: List<&2, KDef>,
  +a: KTerm,
  +b: KTerm,
  +le: Bool,
) -> Bool:
  kc(Bool, norm_exact(a, b), u => True{}, u => norm_convert(book, a, b, le, U32.add(1, norm_max(norm_book_bound(book), norm_max(norm_max_term(a), norm_max_term(b))))))

# Module: src/core/normalize.bend:261
@unsafe
def norm_compare(book, a, b, le, fresh):
  kc(Bool, norm_exact(a, b), u => True{}, u => norm_convert(book, a, b, le, fresh))

# Module: src/core/normalize.bend:265
@unsafe
def norm_subset(
  +as: List<&2, String>,
  +bs: List<&2, String>,
) -> Bool:
  match bs:
    case Nil{}:
      True{}
    case Con{h, t}:
      Bool.and(has_name(as, h), norm_subset(as, t))

# Module: src/core/normalize.bend:276
@unsafe
def norm_removed(
  +as: List<&2, String>,
  +bs: List<&2, String>,
  +le: Bool,
) -> Bool:
  kc(Bool, le, u => norm_subset(as, bs), u => Bool.and(U32.is_eq(norm_names_len(as), norm_names_len(bs)), norm_subset(as, bs)))

# Module: src/core/normalize.bend:287
@unsafe
def norm_let(ts):
  match ts:
    case Nil{}:
      {KTerm{"Absent", "", 0, 0, Nil{}, Nil{}, 0, 0} : KTerm}
    case Con{h, rest}:
      norm_let_tail(h, rest)

# Module: src/core/normalize.bend:300
@unsafe
def norm_let_tail(h, rest):
  match rest:
    case Nil{}:
      h
    case Con{x, xs}:
      subst(norm_let(rest), ix(h), kid(h, 0))

# Module: src/core/normalize.bend:309
@unsafe
def norm_eval(book, t, args, left, fallback):
  kc(KTerm, p98_tag_eq(t, "Var"), u => norm_var(book, t, ks(t), args, left, fallback), u => norm_eval_node(book, t, args, left, fallback))

# Module: src/core/normalize.bend:322
@unsafe
def norm_var(book, t, values, args, left, fallback):
  match values:
    case Nil{}:
      norm_apply(t, args)
    case Con{h, rest}:
      norm_eval(book, h, args, left, fallback)

# Module: src/core/normalize.bend:334
@unsafe
def norm_names_len(names):
  match names:
    case Nil{}:
      0
    case Con{h, rest}:
      U32.add(1, norm_names_len(rest))

# The book checker computes this immutable bound once per source book. Public
# callers without a stamp retain the complete scan, so fresh IDs stay sound.

# Module: src/core/normalize.bend:353
@unsafe
def norm_book_bound(book):
  match book:
    case Nil{}:
      0
    case Con{h, rest}:
      kc(U32, p88_string_eq(dk(h), "BookCache"), u => da(h), u => norm_bound_found(book, lookup(book, "$kernel.max-id")))

# Module: src/core/normalize.bend:361
@unsafe
def norm_bound_found(book, stamp):
  kc(U32, p88_string_eq(dk(stamp), "BookBound"), u => da(stamp), u => norm_max_book(book))

# Strong normalization uses an explicit traversal stack. Each opened binder
# receives a fresh identity even when the same recursive definition unfolds
# repeatedly underneath another copy of its binder.

# Module: src/core/normalize.bend:381
@unsafe
def norm_max_walk(todo, bound):
  match todo:
    case Nil{}:
      bound
    case Con{h, rest}:
      norm_max_walk(norm_join(ks(h), rest), norm_max(bound, ix(h)))

# Module: src/core/normalize.bend:389
@unsafe
def norm_max_defs(todo, bound):
  match todo:
    case Nil{}:
      bound
    case Con{h, rest}:
      norm_max_defs(norm_defs_join(dc(h), rest), norm_max(bound, norm_max(norm_max_term(dt(h)), norm_max_term(dv(h)))))

# Module: src/core/normalize.bend:397
@unsafe
def norm_rebind(
  +t: KTerm,
  +fresh: U32,
) -> KTerm:
  k_rebuild(t, nm(t), fresh, qt(t), kc(List<&2, KTerm>, p98_tag_eq(t, "Lam"), u => Con{subst(kid(t, 0), ix(t), var(nm(t), fresh)), Nil{}}, u => Con{kid(t, 0), Con{subst(kid(t, 1), ix(t), var(nm(t), fresh)), Nil{}}}), rm(t), kb(t), ke(t))

# Syntactic reflexivity precedes evaluation, as pointer reflexivity does in
# upstream. Cell contents are included; different stored values never match.

# Module: src/core/normalize.bend:426
@unsafe
def norm_exact(a, b):
  norm_exact_lists(Con{a, Nil{}}, Con{b, Nil{}})

# Module: src/core/normalize.bend:430
@unsafe
def norm_exact_lists(as, bs):
  match as bs:
    case Nil{} Nil{}:
      True{}
    case Con{a, ar} Con{b, br}:
      kc(Bool, norm_exact_head(a, b), u => norm_exact_lists(norm_join(ks(a), ar), norm_join(ks(b), br)), u => False{})
    case other_a other_b:
      False{}

# Module: src/core/normalize.bend:440
@unsafe
def norm_exact_head(a, b):
  p98_tag_eq(a, tg(b)) && kc(Bool, core_literal(a), u => core_literal_same(a, b), u => True{}) && p88_string_eq(nm(a), nm(b)) && U32.is_eq(ix(a), ix(b)) && U32.is_eq(qt(a), qt(b)) && U32.is_eq(terms_len(ks(a)), terms_len(ks(b))) && norm_exact_names(rm(a), rm(b))

# Module: src/core/normalize.bend:444
@unsafe
def norm_exact_names(as, bs):
  match as bs:
    case Nil{} Nil{}:
      True{}
    case Con{a, ar} Con{b, br}:
      kc(Bool, p88_string_eq(a, b), u => norm_exact_names(ar, br), u => False{})
    case other_a other_b:
      False{}

# Comparison is a worklist of conjunctions with explicit alternatives for
# the right-hand kind meet. Deep constructor equality does not grow the host stack.
# The empty-book pass proves symbolic copies before unfolding definitions.
# Each policy owns its heap. A failed rigid comparison cannot cache an opaque
# head in the full-book pass, or share cells across independent conversions.

# Module: src/core/normalize.bend:467
@unsafe
def norm_convert(book, a, b, le, fresh):
  kc(Bool, norm_cmp_loop(Nil{}, GState{GEmpty{}, 1}, Con{KNormCmp{a, b, le, fresh}, Nil{}}, Nil{}),
    u => True{}, u => norm_cmp_loop(book, GState{GEmpty{}, 1}, Con{KNormCmp{a, b, le, fresh}, Nil{}}, Nil{}))

# Endpoints exposed by graph evaluation belong to its heap. Both policies start
# from that same immutable input; failed rigid evaluation cannot enter the retry.
@unsafe
def norm_convert_state(+book: List<&2,KDef>, +st: GState, +a: KTerm,
  +b: KTerm, +le: Bool, +fresh: U32) -> Bool:
  kc(Bool, norm_cmp_loop(Nil{}, st, Con{KNormCmp{a, b, le, fresh}, Nil{}}, Nil{}),
    u => True{}, u => norm_cmp_loop(book, st, Con{KNormCmp{a, b, le, fresh}, Nil{}}, Nil{}))

# A sharing item runs only after its EQ obligations succeed. It joins separate
# equivalence classes; moving either value could make a cell name itself.
# Proven EQ classes discharge both EQ and LE comparisons. Directional LE alone
# never joins classes. Alternatives retain their continuation while proven
# equality and evaluation may persist inside this one heap identity.

@unsafe
def norm_cmp_shared(+st: GState, +a: KTerm, +b: KTerm) -> Bool:
  p98_tag_eq(a,"GCell") && p98_tag_eq(b,"GCell") && g_class_same(st,ix(a),ix(b))

# Module: src/core/normalize.bend:555
@unsafe
def norm_cmp_loop(book, st, todo, alts):
  match todo:
    case Nil{}:
      True{}
    case Con{KNormShare{left, right}, rest}:
      norm_cmp_loop(book, g_class_join(st,left,right), rest, alts)
    case Con{KNormCmp{a, b, le, fresh}, rest}:
      kc(Bool, norm_cmp_quick(a, b) || norm_cmp_shared(st,a,b), u => norm_cmp_loop(book, st, rest, alts),
        u => norm_cmp_left(book, b, le, fresh,
          kc(List<&2, KNormCmp>, Bool.not(le) && p98_tag_eq(a, "GCell") && p98_tag_eq(b, "GCell"),
            u => Con{KNormShare{ix(a), ix(b)}, rest}, u => rest), alts, g_wnf(book, st, a)))

# Module: src/core/normalize.bend:568
@unsafe
def norm_cmp_quick(a, b):
  kc(Bool, p98_tag_eq(a, "App") || p98_tag_eq(a, "Ref") || p98_tag_eq(a, "Var") || p98_tag_eq(a, "GCell"), u => norm_exact(a, b), u => False{})

# Module: src/core/normalize.bend:572
@unsafe
def norm_cmp_fail(
  +book: List<&2, KDef>,
  +st: GState,
  +alts: List<&2, KNormAlt>,
) -> Bool:
  match alts:
    case Nil{}:
      False{}
    case Con{KNormAlt{todo}, rest}:
      norm_cmp_loop(book, st, todo, rest)

# Module: src/core/normalize.bend:584
@unsafe
def norm_cmp_test(
  +book: List<&2, KDef>,
  +st: GState,
  +yes: Bool,
  +rest: List<&2, KNormCmp>,
  +alts: List<&2, KNormAlt>,
) -> Bool:
  kc(Bool, yes, u => norm_cmp_loop(book, st, rest, alts), u => norm_cmp_fail(book, st, alts))

# Module: src/core/normalize.bend:594
@unsafe
def norm_cmp_heads(book, st, a, b, le, fresh, rest, alts):
  kc(Bool, p98_tag_eq(a, "Lam") || p98_tag_eq(b, "Lam"),
   u => norm_cmp_loop(book, st, Con{KNormCmp{app(a, var("_", fresh)), app(b, var("_", fresh)), le, U32.add(fresh, 1)}, rest}, alts),
   u => kc(Bool, core_literal(a) && p98_tag_eq(b, "Ctr"), u => norm_cmp_heads(book, st, core_literal_step(a), b, le, fresh, rest, alts),
   u => kc(Bool, core_literal(b) && p98_tag_eq(a, "Ctr"), u => norm_cmp_heads(book, st, a, core_literal_step(b), le, fresh, rest, alts),
   u => kc(Bool, p98_tag_eq(a, tg(b)), u => norm_cmp_same(book, st, a, b, le, fresh, rest, alts), u => norm_cmp_fail(book, st, alts)))))

# Module: src/core/normalize.bend:602
@unsafe
def norm_cmp_same(book, st, a, b, le, fresh, rest, alts):
  kc(Bool, p98_tag_eq(a, "Var"), u => norm_cmp_test(book, st, U32.is_eq(ix(a), ix(b)), rest, alts),
   u => kc(Bool, p98_tag_eq(a, "Typ"), u => kc(Bool, le,
     u => norm_cmp_kind_left(book, a, b, fresh, rest, alts, g_wnf(book, st, kid(a, 0))),
     u => norm_cmp_loop(book, st, Con{KNormCmp{kid(a, 0), kid(b, 0), False{}, fresh}, rest}, alts)),
   u => kc(Bool, p98_tag_eq(a, "All"), u => kc(Bool, U32.is_eq(qt(a), qt(b)),
     u => norm_cmp_loop(book, st, Con{KNormCmp{kid(b, 0), kid(a, 0), le, fresh}, Con{KNormCmp{subst(kid(a, 1), ix(a), var("_", fresh)), subst(kid(b, 1), ix(b), var("_", fresh)), le, U32.add(fresh, 1)}, rest}}, alts), u => norm_cmp_fail(book, st, alts)),
   u => kc(Bool, p98_tag_eq(a, "ADT"), u => kc(Bool, p88_string_eq(nm(a), nm(b)) && norm_removed(rm(a), rm(b), le), u => norm_cmp_fields(book, st, ks(a), ks(b), fresh, rest, alts), u => norm_cmp_fail(book, st, alts)),
   u => kc(Bool, p98_tag_eq(a, "Qua"), u => norm_cmp_test(book, st, U32.is_eq(qt(a), qt(b)), rest, alts),
   u => norm_cmp_plain(book, st, a, b, le, fresh, rest, alts))))))

# Module: src/core/normalize.bend:614
@unsafe
def norm_cmp_plain(book, st, a, b, le, fresh, rest, alts):
  kc(Bool, core_literal(a) && core_literal(b), u => norm_cmp_test(book, st, core_literal_same(a, b), rest, alts), u =>
  kc(Bool, p98_tag_eq(a, "Ref"), u => kc(Bool, p88_string_eq(nm(a), nm(b)), u => norm_cmp_loop(book, st, rest, alts), u => norm_cmp_ref(book, st, a, b, le, norm_max(da(lookup(book, nm(a))), da(lookup(book, nm(b)))), fresh, rest, alts)),
   u => kc(Bool, p98_tag_eq(a, "Hol"), u => norm_cmp_test(book, st, p88_string_eq(nm(a), nm(b)), rest, alts),
   u => kc(Bool, p98_tag_eq(a, "Ctr") || p98_tag_eq(a, "Mat"), u => kc(Bool, p88_string_eq(nm(a), nm(b)), u => norm_cmp_fields(book, st, ks(a), ks(b), fresh, rest, alts), u => norm_cmp_fail(book, st, alts)),
   u => kc(Bool, p98_tag_eq(a, "App") && p98_tag_eq(kid(a, 0), "Ref") && p98_tag_eq(kid(b, 0), "Ref"), u => kc(Bool, p88_string_eq(nm(kid(a, 0)), nm(kid(b, 0))), u => norm_cmp_loop(book, st, Con{KNormCmp{kid(a, 1), kid(b, 1), False{}, fresh}, rest}, alts), u => norm_cmp_fail(book, st, alts)),
   u => kc(Bool, p98_tag_eq(a, "App") || p98_tag_eq(a, "Min") || p98_tag_eq(a, "Eql") || p98_tag_eq(a, "Rwt"), u => norm_cmp_fields(book, st, ks(a), ks(b), fresh, rest, alts),
   u => norm_cmp_test(book, st, p98_tag_eq(a, "Qnt") || p98_tag_eq(a, "Rfl") || p98_tag_eq(a, "Efq"), rest, alts)))))))

# Only bare, under-applied definitions compare extensionally. Stuck App heads
# above stay nominal, avoiding repeated eta expansion of an opaque application.

# Module: src/core/normalize.bend:626
@unsafe
def norm_cmp_ref(
  +book: List<&2, KDef>,
  +st: GState,
  +a: KTerm,
  +b: KTerm,
  +le: Bool,
  +n: U32,
  +fresh: U32,
  +rest: List<&2, KNormCmp>,
  +alts: List<&2, KNormAlt>,
) -> Bool:
  kc(Bool, U32.is_eq(n, 0), u => norm_cmp_fail(book, st, alts),
   u => kc(Bool, U32.is_eq(n, 1),
     u => norm_cmp_loop(book, st, Con{KNormCmp{app(a, var("_", fresh)), app(b, var("_", fresh)), le, U32.add(fresh, 1)}, rest}, alts),
     u => norm_cmp_ref(book, st, app(a, var("_", fresh)), app(b, var("_", fresh)), le, U32.sub(n, 1), U32.add(fresh, 1), rest, alts)))

# Module: src/core/normalize.bend:643
@unsafe
def norm_cmp_fields(book, st, as, bs, fresh, rest, alts):
  kc(Bool, U32.is_eq(terms_len(as), terms_len(bs)), u => norm_cmp_loop(book, st, norm_cmp_zip(as, bs, fresh, rest), alts), u => norm_cmp_fail(book, st, alts))

# Module: src/core/normalize.bend:647
@unsafe
def norm_cmp_zip(as, bs, fresh, rest):
  match as bs:
    case Con{a, ar} Con{b, br}:
      Con{KNormCmp{a, b, False{}, fresh}, norm_cmp_zip(ar, br, fresh, rest)}
    case other_a other_b:
      rest

# Module: src/core/normalize.bend:655
@unsafe
def norm_cmp_kind(book, st, a, b, g, h, fresh, rest, alts):
  kc(Bool, (p98_tag_eq(g, "Qua") && U32.is_eq(qt(g), 2)) || (p98_tag_eq(h, "Qua") && Bool.not(U32.is_eq(qt(h), 2))), u => norm_cmp_loop(book, st, rest, alts),
   u => kc(Bool, p98_tag_eq(g, "Min"),
     u => norm_cmp_loop(book, st, Con{KNormCmp{kt("Typ", "", 0, 0, Con{kid(g, 0), Nil{}}), b, True{}, fresh}, Con{KNormCmp{kt("Typ", "", 0, 0, Con{kid(g, 1), Nil{}}), b, True{}, fresh}, rest}}, alts),
   u => kc(Bool, p98_tag_eq(h, "Min"),
     u => norm_cmp_loop(book, st, Con{KNormCmp{a, kt("Typ", "", 0, 0, Con{kid(h, 0), Nil{}}), True{}, fresh}, rest}, Con{KNormAlt{Con{KNormCmp{a, kt("Typ", "", 0, 0, Con{kid(h, 1), Nil{}}), True{}, fresh}, rest}}, alts}),
     u => norm_cmp_loop(book, st, Con{KNormCmp{g, h, True{}, fresh}, rest}, alts))))

# Module: src/core/normalize.bend:665
@unsafe
def norm_cmp_left(
  +book: List<&2, KDef>,
  +b: KTerm,
  +le: Bool,
  +fresh: U32,
  +rest: List<&2, KNormCmp>,
  +alts: List<&2, KNormAlt>,
  +r: GResult,
) -> Bool:
  match r:
    case GResult{st, a}:
      norm_cmp_right(book, a, le, fresh, rest, alts, g_wnf(book, st, b))

# Module: src/core/normalize.bend:679
@unsafe
def norm_cmp_right(
  +book: List<&2, KDef>,
  +a: KTerm,
  +le: Bool,
  +fresh: U32,
  +rest: List<&2, KNormCmp>,
  +alts: List<&2, KNormAlt>,
  +r: GResult,
) -> Bool:
  match r:
    case GResult{st, b}:
      norm_cmp_heads(book, st, a, b, le, fresh, rest, alts)

# Module: src/core/normalize.bend:693
@unsafe
def norm_cmp_kind_left(
  +book: List<&2, KDef>,
  +a: KTerm,
  +b: KTerm,
  +fresh: U32,
  +rest: List<&2, KNormCmp>,
  +alts: List<&2, KNormAlt>,
  +r: GResult,
) -> Bool:
  match r:
    case GResult{st, g}:
      norm_cmp_kind_right(book, a, b, g, fresh, rest, alts, g_wnf(book, st, kid(b, 0)))

# Module: src/core/normalize.bend:707
@unsafe
def norm_cmp_kind_right(
  +book: List<&2, KDef>,
  +a: KTerm,
  +b: KTerm,
  +g: KTerm,
  +fresh: U32,
  +rest: List<&2, KNormCmp>,
  +alts: List<&2, KNormAlt>,
  +r: GResult,
) -> Bool:
  match r:
    case GResult{st, h}:
      norm_cmp_kind(book, st, a, b, g, h, fresh, rest, alts)
