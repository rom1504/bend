
# Module: src/core/graph.bend:6
type GHeap is Data:
  GEmpty{}
  GNode{+value: KTerm, +left: GHeap, +right: GHeap}

# Equality classes are separate from evaluation values. Absent entries are
# singleton roots; stored roots name themselves and carry union-by-rank height.
type GClassEntry is Data:
  GClassEntry{+parent: U32, +rank: U32}

type GClasses is Data:
  GClassesEmpty{}
  GClassesNode{+entry: Maybe<&2,GClassEntry>, +left: GClasses, +right: GClasses}

# Module: src/core/graph.bend:10
type GState is Data:
  GState{+heap: GHeap, +next: U32}
  GCompared{+heap: GHeap, +next: U32, +classes: GClasses}

# Module: src/core/graph.bend:13
type GResult is Data:
  GResult{+state: GState, +term: KTerm}

# Module: src/core/graph.bend:16
type GTerms is Data:
  GTerms{+state: GState, +terms: List<&2, KTerm>}

# Module: src/core/graph.bend:19
type GFrame is Data:
  GFill{+id: U32, +args: List<&2, KTerm>, +pending: U32, +fallback: KTerm}
  GMatch{+arm: KTerm, +raw: KTerm, +args: List<&2, KTerm>, +pending: U32, +fallback: KTerm}
  GMinA{+other: KTerm, +args: List<&2, KTerm>}
  GMinB{+other: KTerm, +args: List<&2, KTerm>}
  GRewrite{+original: KTerm, +args: List<&2, KTerm>, +pending: U32, +fallback: KTerm}

# Module: src/core/graph.bend:26
law g_put_node:
  for +old: KTerm
  for +left: GHeap
  for +right: GHeap
  for +id: U32
  for +value: KTerm
  GHeap

# Module: src/core/graph.bend:34
law g_shared_term:
  for +rest: List<&2, KTerm>
  for +done: List<&2, KTerm>
  for +r: GResult
  GTerms

# Module: src/core/graph.bend:40
law g_shared_head:
  for +t: KTerm
  for +r: GTerms
  GResult

# Module: src/core/graph.bend:45
law g_eval:
  for +book: List<&2, KDef>
  for +st: GState
  for +t: KTerm
  for +args: List<&2, KTerm>
  for +pending: U32
  for +fallback: KTerm
  for +stack: List<&2, GFrame>
  GResult

# Module: src/core/graph.bend:55
law g_cell:
  for +book: List<&2, KDef>
  for +st: GState
  for +t: KTerm
  for +args: List<&2, KTerm>
  for +pending: U32
  for +fallback: KTerm
  for +stack: List<&2, GFrame>
  for +cell: KTerm
  GResult

# Module: src/core/graph.bend:66
law g_app:
  for +book: List<&2, KDef>
  for +fn: KTerm
  for +args: List<&2, KTerm>
  for +pending: U32
  for +fallback: KTerm
  for +stack: List<&2, GFrame>
  for +r: GResult
  GResult

# Module: src/core/graph.bend:76
law g_ref:
  for +book: List<&2, KDef>
  for +st: GState
  for +t: KTerm
  for +args: List<&2, KTerm>
  for +stack: List<&2, GFrame>
  for +d: KDef
  GResult

# Module: src/core/graph.bend:85
law g_args:
  for +book: List<&2, KDef>
  for +st: GState
  for +t: KTerm
  for +args: List<&2, KTerm>
  for +pending: U32
  for +fallback: KTerm
  for +stack: List<&2, GFrame>
  GResult

# Module: src/core/graph.bend:95
law g_return:
  for +book: List<&2, KDef>
  for +st: GState
  for +t: KTerm
  for +stack: List<&2, GFrame>
  GResult

# Module: src/core/graph.bend:102
law g_resume:
  for +book: List<&2, KDef>
  for +st: GState
  for +t: KTerm
  for +frame: GFrame
  for +stack: List<&2, GFrame>
  GResult

# Module: src/core/graph.bend:110
law g_filled:
  for +book: List<&2, KDef>
  for +id: U32
  for +args: List<&2, KTerm>
  for +pending: U32
  for +fallback: KTerm
  for +stack: List<&2, GFrame>
  for +r: GResult
  GResult

# Module: src/core/graph.bend:120
law g_min_left:
  for +book: List<&2, KDef>
  for +st: GState
  for +a: KTerm
  for +b: KTerm
  for +args: List<&2, KTerm>
  for +stack: List<&2, GFrame>
  GResult

# Module: src/core/graph.bend:129
law g_match:
  for +book: List<&2, KDef>
  for +st: GState
  for +arm: KTerm
  for +original: KTerm
  for +raw: KTerm
  for +x: KTerm
  for +args: List<&2, KTerm>
  for +pending: U32
  for +fallback: KTerm
  for +stack: List<&2, GFrame>
  GResult

# Module: src/core/graph.bend:142
law g_let:
  for +book: List<&2, KDef>
  for +st: GState
  for +ts: List<&2, KTerm>
  for +bindings: List<&2, KTerm>
  for +args: List<&2, KTerm>
  for +pending: U32
  for +fallback: KTerm
  for +stack: List<&2, GFrame>
  GResult

# Module: src/core/graph.bend:153
law g_let_shared:
  for +book: List<&2, KDef>
  for +h: KTerm
  for +rest: List<&2, KTerm>
  for +bindings: List<&2, KTerm>
  for +args: List<&2, KTerm>
  for +pending: U32
  for +fallback: KTerm
  for +stack: List<&2, GFrame>
  for +r: GResult
  GResult

# Module: src/core/graph.bend:165
law g_let_sub:
  for +t: KTerm
  for +bindings: List<&2, KTerm>
  KTerm

# Module: src/core/graph.bend:170
law graph_strong:
  for +book: List<&2, KDef>
  for +t: KTerm
  KTerm

# Module: src/core/graph.bend:175
law g_snf_head:
  for +book: List<&2, KDef>
  for +stack: List<&2, KNormFrame>
  for +fresh: U32
  for +r: GResult
  KTerm

# Module: src/core/graph.bend:182
law g_snf_open:
  for +book: List<&2, KDef>
  for +st: GState
  for +t: KTerm
  for +stack: List<&2, KNormFrame>
  for +fresh: U32
  KTerm

# Module: src/core/graph.bend:190
law g_snf_children:
  for +book: List<&2, KDef>
  for +st: GState
  for +parent: KTerm
  for +done: List<&2, KTerm>
  for +todo: List<&2, KTerm>
  for +stack: List<&2, KNormFrame>
  for +fresh: U32
  KTerm

# Module: src/core/graph.bend:200
law g_snf_return:
  for +book: List<&2, KDef>
  for +st: GState
  for +t: KTerm
  for +stack: List<&2, KNormFrame>
  for +fresh: U32
  KTerm

# Module: src/core/graph.bend:469
law g_start:
  for +book: List<&2, KDef>
  for +t: KTerm
  for +bound: U32
  KTerm

# Module: src/core/graph.bend:209
@unsafe
def g_heap(
  +st: GState,
) -> GHeap:
  match st:
    case GState{heap, next}:
      heap
    case GCompared{heap, next, classes}:
      heap

# Module: src/core/graph.bend:217
@unsafe
def g_next(
  +st: GState,
) -> U32:
  match st:
    case GState{heap, next}:
      next
    case GCompared{heap, next, classes}:
      next

# Every evaluation update preserves the comparison facts of this heap identity.
# Fresh GState constructors still start an independent, empty class relation.
@unsafe
def g_with_heap(+st: GState, +heap: GHeap, +next: U32) -> GState:
  match st:
    case GState{oldHeap,oldNext}: GState{heap,next}
    case GCompared{oldHeap,oldNext,classes}: GCompared{heap,next,classes}

@unsafe
def g_classes(+st: GState) -> GClasses:
  match st:
    case GState{heap,next}: GClassesEmpty{}
    case GCompared{heap,next,classes}: classes

@unsafe
def g_class_get(+classes: GClasses, +id: U32) -> Maybe<&2,GClassEntry>:
  match classes:
    case GClassesEmpty{}: None{}
    case GClassesNode{entry,left,right}:
      kc(Maybe<&2,GClassEntry>,U32.is_eq(id,0),u => entry,
        u => kc(Maybe<&2,GClassEntry>,U32.is_eq(U32.and(id,1),0),
          u => g_class_get(left,U32.shr(id)),u => g_class_get(right,U32.shr(id))))

@unsafe
def g_class_put(+classes: GClasses, +id: U32, +entry: GClassEntry) -> GClasses:
  match classes:
    case GClassesEmpty{}:
      g_class_put(GClassesNode{None{},GClassesEmpty{},GClassesEmpty{}},id,entry)
    case GClassesNode{old,left,right}:
      kc(GClasses,U32.is_eq(id,0),u => GClassesNode{Some{entry},left,right},
        u => kc(GClasses,U32.is_eq(U32.and(id,1),0),
          u => GClassesNode{old,g_class_put(left,U32.shr(id),entry),right},
          u => GClassesNode{old,left,g_class_put(right,U32.shr(id),entry)}))

law g_class_root:
  for +classes: GClasses
  for +id: U32
  U32

@unsafe
def g_class_root_entry(+classes: GClasses, +id: U32, +entry: Maybe<&2,GClassEntry>) -> U32:
  match entry:
    case None{}: id
    case Some{GClassEntry{parent,rank}}:
      kc(U32,U32.is_eq(parent,id),u => id,u => g_class_root(classes,parent))

@unsafe
def g_class_root(classes,id):
  g_class_root_entry(classes,id,g_class_get(classes,id))

@unsafe
def g_class_rank_entry(+entry: Maybe<&2,GClassEntry>) -> U32:
  match entry:
    case None{}: 0
    case Some{GClassEntry{parent,rank}}: rank

@unsafe
def g_class_raise(+classes: GClasses, +id: U32, +rank: U32, +raise: Bool) -> GClasses:
  kc(GClasses,raise,u => g_class_put(classes,id,GClassEntry{id,U32.add(rank,1)}),u => classes)

# Only distinct roots are linked. Rank strictly increases along every link,
# ruling out class cycles without inspecting or rewriting any term value.
@unsafe
def g_class_link(+classes: GClasses, +left: U32, +right: U32,
  +leftRank: U32, +rightRank: U32) -> GClasses:
  kc(GClasses,U32.is_eq(left,right),u => classes,
    u => kc(GClasses,U32.is_lt(leftRank,rightRank),
      u => g_class_put(classes,left,GClassEntry{right,leftRank}),
      u => g_class_put(g_class_raise(classes,left,leftRank,U32.is_eq(leftRank,rightRank)),
        right,GClassEntry{left,rightRank})))

@unsafe
def g_class_join_roots(+st: GState, +classes: GClasses, +left: U32, +right: U32) -> GState:
  kc(GState,U32.is_eq(left,right),u => st,
    u => GCompared{g_heap(st),g_next(st),g_class_link(classes,left,right,
      g_class_rank_entry(g_class_get(classes,left)),g_class_rank_entry(g_class_get(classes,right)))})

@unsafe
def g_class_join(+st: GState, +left: U32, +right: U32) -> GState:
  +classes = g_classes(st)
  g_class_join_roots(st,classes,g_class_root(classes,left),g_class_root(classes,right))

@unsafe
def g_class_same(+st: GState, +left: U32, +right: U32) -> Bool:
  +classes = g_classes(st)
  U32.is_eq(g_class_root(classes,left),g_class_root(classes,right))

# Module: src/core/graph.bend:225
@unsafe
def g_state(
  +r: GResult,
) -> GState:
  match r:
    case GResult{state, term}:
      state

# Module: src/core/graph.bend:233
@unsafe
def g_term(
  +r: GResult,
) -> KTerm:
  match r:
    case GResult{state, term}:
      term

# Module: src/core/graph.bend:241
@unsafe
def g_states(
  +r: GTerms,
) -> GState:
  match r:
    case GTerms{state, terms}:
      state

# Module: src/core/graph.bend:249
@unsafe
def g_terms(
  +r: GTerms,
) -> List<&2, KTerm>:
  match r:
    case GTerms{state, terms}:
      terms

# Module: src/core/graph.bend:257
@unsafe
def g_get(
  +heap: GHeap,
  +id: U32,
) -> KTerm:
  match heap:
    case GEmpty{}:
      {KTerm{"Absent", "", 0, 0, Nil{}, Nil{}, 0, 0} : KTerm}
    case GNode{value, left, right}:
      kc(KTerm, U32.is_eq(id, 0), u => value, u => kc(KTerm, U32.is_eq(U32.and(id, 1), 0), u => g_get(left, U32.shr(id)), u => g_get(right, U32.shr(id))))

# Module: src/core/graph.bend:268
@unsafe
def g_put(
  +heap: GHeap,
  +id: U32,
  +value: KTerm,
) -> GHeap:
  match heap:
    case GEmpty{}:
      g_put_node({KTerm{"Absent", "", 0, 0, Nil{}, Nil{}, 0, 0} : KTerm}, GEmpty{}, GEmpty{}, id, value)
    case GNode{old, left, right}:
      g_put_node(old, left, right, id, value)

# Module: src/core/graph.bend:280
@unsafe
def g_put_node(old, left, right, id, value):
  kc(GHeap, U32.is_eq(id, 0), u => GNode{value, left, right}, u => kc(GHeap, U32.is_eq(U32.and(id, 1), 0), u => GNode{old, g_put(left, U32.shr(id), value), right}, u => GNode{old, left, g_put(right, U32.shr(id), value)}))

# Module: src/core/graph.bend:284
@unsafe
def g_share(
  +st: GState,
  +t: KTerm,
) -> GResult:
  kc(GResult, p98_tag_eq(t, "GCell"), u => GResult{st, t}, u => GResult{g_with_heap(st, g_put(g_heap(st), g_next(st), kt("GThunk", "", 0, 0, Con{t, Nil{}})), U32.add(g_next(st), 1)), kt("GCell", "", g_next(st), 0, Nil{})})

# Module: src/core/graph.bend:291
@unsafe
def g_share_terms(
  +st: GState,
  +ts: List<&2, KTerm>,
  +done: List<&2, KTerm>,
) -> GTerms:
  match ts:
    case Nil{}:
      GTerms{st, List.reverse(&2, KTerm, done)}
    case Con{h, rest}:
      g_shared_term(rest, done, g_share(st, h))

# Module: src/core/graph.bend:303
@unsafe
def g_shared_term(rest, done, r):
  g_share_terms(g_state(r), rest, Con{g_term(r), done})

# Module: src/core/graph.bend:307
@unsafe
def g_share_head(
  +st: GState,
  +t: KTerm,
) -> GResult:
  kc(GResult, p98_tag_eq(t, "All"), u => g_shared_domain(t, g_share(st, kid(t, 0))),
    u => kc(GResult, p98_tag_eq(t, "Ctr") || p98_tag_eq(t, "ADT") || p98_tag_eq(t, "Mat") || p98_tag_eq(t, "Eql") || p98_tag_eq(t, "Min") || p98_tag_eq(t, "Typ"), u => g_shared_head(t, g_share_terms(st, ks(t), Nil{})), u => GResult{st, t}))

# Module: src/core/graph.bend:315
@unsafe
def g_shared_head(t, r):
  GResult{g_states(r), k_with_children(t, g_terms(r))}

# Module: src/core/graph.bend:319
@unsafe
def g_cache(
  +st: GState,
  +id: U32,
  +t: KTerm,
) -> GState:
  g_with_heap(st, g_put(g_heap(st), id, kt("GValue", "", 0, 0, Con{t, Nil{}})), g_next(st))

# Module: src/core/graph.bend:327
@unsafe
def g_wnf(
  +book: List<&2, KDef>,
  +st: GState,
  +t: KTerm,
) -> GResult:
  g_eval(book, st, t, Nil{}, 0, {KTerm{"Absent", "", 0, 0, Nil{}, Nil{}, 0, 0} : KTerm}, Nil{})

# Module: src/core/graph.bend:335
@unsafe
def g_eval(book, st, t, args, pending, fallback, stack):
  kc(GResult, p98_tag_eq(t, "GCell"), u => g_cell(book, st, t, args, pending, fallback, stack, g_get(g_heap(st), ix(t))),
   u => kc(GResult, p98_tag_eq(t, "App"), u => g_app(book, kid(t, 0), args, pending, fallback, stack, g_share(st, kid(t, 1))),
   u => kc(GResult, p98_tag_eq(t, "Ann"), u => g_eval(book, st, kid(t, 0), args, pending, fallback, stack),
   u => kc(GResult, p98_tag_eq(t, "Var") && U32.is_gt(terms_len(ks(t)), 0), u => g_eval(book, st, kid(t, 0), args, pending, fallback, stack),
   u => kc(GResult, p98_tag_eq(t, "Let"), u => g_let(book, st, ks(t), Nil{}, args, pending, fallback, stack),
   u => kc(GResult, p98_tag_eq(t, "Ref"), u => g_ref(book, st, t, args, stack, lookup(book, nm(t))),
   u => kc(GResult, p98_tag_eq(t, "Min"), u => g_eval(book, st, kid(t, 0), Nil{}, 0, {KTerm{"Absent", "", 0, 0, Nil{}, Nil{}, 0, 0} : KTerm}, Con{GMinA{kid(t, 1), args}, stack}),
   u => kc(GResult, p98_tag_eq(t, "Rwt"), u => g_eval(book, st, kid(t, 0), Nil{}, 0, {KTerm{"Absent", "", 0, 0, Nil{}, Nil{}, 0, 0} : KTerm}, Con{GRewrite{t, args, pending, fallback}, stack}),
   u => g_args(book, st, t, args, pending, fallback, stack)))))))))

# Module: src/core/graph.bend:347
@unsafe
def g_cell(book, st, t, args, pending, fallback, stack, cell):
  kc(GResult, p98_tag_eq(cell, "GValue"), u => g_eval(book, st, kid(cell, 0), args, pending, fallback, stack), u => g_eval(book, st, kid(cell, 0), Nil{}, 0, {KTerm{"Absent", "", 0, 0, Nil{}, Nil{}, 0, 0} : KTerm}, Con{GFill{ix(t), args, pending, fallback}, stack}))

# Module: src/core/graph.bend:351
@unsafe
def g_app(book, fn, args, pending, fallback, stack, r):
  g_eval(book, g_state(r), fn, Con{g_term(r), args}, pending, fallback, stack)

# Module: src/core/graph.bend:355
@unsafe
def g_ref(book, st, t, args, stack, d):
  kc(GResult, p88_string_eq(dk(d), "ADT"), u => g_return(book, st, norm_apply(kc(KTerm, U32.is_eq(da(d), 0), u => kt("ADT", nm(t), 0, 0, Nil{}), u => t), args), stack),
   u => kc(GResult, Bool.not(p98_tag_eq(dv(d), "Absent") || p98_tag_eq(dv(d), "Foreign")) && U32.is_le(da(d), terms_len(args)), u => g_eval(book, st, dv(d), args, da(d), norm_apply(t, args), stack), u => g_return(book, st, norm_apply(t, args), stack)))

# Module: src/core/graph.bend:360
@unsafe
def g_args(book, st, t, args, pending, fallback, stack):
  match args:
    case Nil{}:
      g_return(book, st, t, stack)
    case Con{x, rest}:
      kc(GResult, p98_tag_eq(t, "Lam"), u => g_eval(book, st, subst(kid(t, 0), ix(t), x), rest, norm_dec(pending), fallback, stack),
       u => kc(GResult, p98_tag_eq(t, "Mat"), u => g_eval(book, st, x, Nil{}, 0, {KTerm{"Absent", "", 0, 0, Nil{}, Nil{}, 0, 0} : KTerm}, Con{GMatch{t, x, rest, pending, fallback}, stack}),
       u => g_return(book, st, kc(KTerm, p98_tag_eq(t, "Efq") && U32.is_gt(pending, 0), u => fallback, u => norm_apply(t, args)), stack)))

# Module: src/core/graph.bend:370
@unsafe
def g_return(book, st, t, stack):
  match stack:
    case Nil{}:
      GResult{st, t}
    case Con{frame, rest}:
      g_resume(book, st, t, frame, rest)

# Module: src/core/graph.bend:378
@unsafe
def g_resume(book, st, t, frame, stack):
  match frame:
    case GFill{id, args, pending, fallback}:
      g_filled(book, id, args, pending, fallback, stack, g_share_head(st, t))
    case GMatch{arm, raw, args, pending, fallback}:
      g_match(book, st, arm, arm, raw, t, args, pending, fallback, stack)
    case GMinA{other, args}:
      g_min_left(book, st, t, other, args, stack)
    case GMinB{other, args}:
      g_return(book, st, norm_apply(norm_min_right(other, t), args), stack)
    case GRewrite{original, args, pending, fallback}:
      kc(GResult, p98_tag_eq(t, "Rfl"), u => g_eval(book, st, kid(original, 2), args, pending, fallback, stack), u => g_return(book, st, norm_apply(original, args), stack))

# Module: src/core/graph.bend:392
@unsafe
def g_filled(book, id, args, pending, fallback, stack, r):
  g_eval(book, g_cache(g_state(r), id, g_term(r)), g_term(r), args, pending, fallback, stack)

# Module: src/core/graph.bend:396
@unsafe
def g_min_left(book, st, a, b, args, stack):
  kc(GResult, p98_tag_eq(a, "Qua") && U32.is_eq(qt(a), 2), u => g_eval(book, st, b, args, 0, {KTerm{"Absent", "", 0, 0, Nil{}, Nil{}, 0, 0} : KTerm}, stack),
   u => kc(GResult, p98_tag_eq(a, "Qua") && U32.is_eq(qt(a), 0), u => g_return(book, st, norm_apply(a, args), stack), u => g_eval(book, st, b, Nil{}, 0, {KTerm{"Absent", "", 0, 0, Nil{}, Nil{}, 0, 0} : KTerm}, Con{GMinB{a, args}, stack})))

# Module: src/core/graph.bend:401
@unsafe
def g_match(book, st, arm, original, raw, x, args, pending, fallback, stack):
  kc(GResult, core_literal(x), u => g_match(book, st, arm, original, raw, core_literal_step(x), args, pending, fallback, stack), u =>
  kc(GResult, Bool.not(p98_tag_eq(x, "Ctr")), u => g_return(book, st, norm_stuck(original, raw, args, pending, fallback), stack),
   u => kc(GResult, p98_tag_eq(arm, "Ann"), u => g_match(book, st, kid(arm, 0), original, raw, x, args, pending, fallback, stack),
   u => kc(GResult, p98_tag_eq(arm, "Mat"), u => kc(GResult, p88_string_eq(nm(arm), nm(x)),
     u => g_eval(book, st, kid(arm, 0), norm_join(ks(x), args), kc(U32, U32.is_eq(pending, 0), u => 0, u => U32.add(norm_dec(pending), terms_len(ks(x)))), fallback, stack),
     u => g_match(book, st, kid(arm, 1), original, raw, x, args, pending, fallback, stack)),
   u => kc(GResult, p98_tag_eq(arm, "Efq"), u => g_return(book, st, norm_stuck(original, raw, args, pending, fallback), stack), u => g_eval(book, st, arm, Con{x, args}, pending, fallback, stack))))))

# Module: src/core/graph.bend:411
@unsafe
def g_let(book, st, ts, bindings, args, pending, fallback, stack):
  match ts:
    case Nil{}:
      g_return(book, st, {KTerm{"Absent", "", 0, 0, Nil{}, Nil{}, 0, 0} : KTerm}, stack)
    case Con{h, rest}:
      kc(GResult, p98_tag_eq(h, "Bind"), u => g_let_shared(book, h, rest, bindings, args, pending, fallback, stack, g_share(st, kid(h, 0))), u => g_eval(book, st, g_let_sub(h, bindings), args, pending, fallback, stack))

# Module: src/core/graph.bend:419
@unsafe
def g_let_shared(book, h, rest, bindings, args, pending, fallback, stack, r):
  g_let(book, g_state(r), rest, Con{kt("Bind", nm(h), ix(h), qt(h), Con{g_term(r), Nil{}}), bindings}, args, pending, fallback, stack)

# Module: src/core/graph.bend:423
@unsafe
def g_let_sub(t, bindings):
  match bindings:
    case Nil{}:
      t
    case Con{h, rest}:
      g_let_sub(subst(t, ix(h), kid(h, 0)), rest)

# Module: src/core/graph.bend:431
@unsafe
def graph_strong(book, t):
  g_start(book, t, norm_max(norm_book_bound(book), norm_max_term(t)))

# Module: src/core/graph.bend:435
@unsafe
def g_snf_go(
  +book: List<&2, KDef>,
  +st: GState,
  +t: KTerm,
  +stack: List<&2, KNormFrame>,
  +fresh: U32,
) -> KTerm:
  g_snf_head(book, stack, fresh, g_wnf(book, st, t))

# Module: src/core/graph.bend:445
@unsafe
def g_snf_head(book, stack, fresh, r):
  kc(KTerm, p98_tag_eq(g_term(r), "Lam") || p98_tag_eq(g_term(r), "All"), u => g_snf_open(book, g_state(r), norm_rebind(g_term(r), fresh), stack, U32.add(fresh, 1)), u => g_snf_open(book, g_state(r), g_term(r), stack, fresh))

# Module: src/core/graph.bend:449
@unsafe
def g_snf_open(book, st, t, stack, fresh):
  g_snf_children(book, st, t, Nil{}, ks(t), stack, fresh)

# Module: src/core/graph.bend:453
@unsafe
def g_snf_children(book, st, parent, done, todo, stack, fresh):
  match todo:
    case Nil{}:
      g_snf_return(book, st, k_snf_children(parent, List.reverse(&2, KTerm, done)), stack, fresh)
    case Con{h, rest}:
      g_snf_go(book, st, h, Con{KNormFrame{parent, done, rest}, stack}, fresh)

# Module: src/core/graph.bend:461
@unsafe
def g_snf_return(book, st, t, stack, fresh):
  match stack:
    case Nil{}:
      t
    case Con{KNormFrame{parent, done, todo}, rest}:
      g_snf_children(book, st, parent, Con{t, done}, todo, rest, fresh)

# Module: src/core/graph.bend:476
@unsafe
def g_start(book, t, bound):
  g_snf_go(book_cached(book, bound), GState{GEmpty{}, 1}, t, Nil{}, U32.add(bound, 1))

# A telescope domain is independent of its own binder; its deferred codomain
# stays outside the cell so opening that binder still substitutes the body.

# Module: src/core/graph.bend:482
@unsafe
def g_shared_domain(+t: KTerm, +r: GResult) -> GResult:
  match r:
    case GResult{state, term}:
      GResult{state, k_with_children(t, Con{term, Con{kid(t, 1), Nil{}}})}
