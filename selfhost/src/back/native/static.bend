
# Module: src/back/native/static.bend:4
type NS_Image is Data:
  NS_Image{+size: U32, +words: List<&2, String>, +index: KDef}

# Module: src/back/native/static.bend:7
type NS_Term is Data:
  NS_Term{+term: KTerm, +image: NS_Image}

# Module: src/back/native/static.bend:10
type NS_Terms is Data:
  NS_Terms{+terms: List<&2, KTerm>, +image: NS_Image}

# Module: src/back/native/static.bend:13
type NS_Defs is Data:
  NS_Defs{+defs: List<&2, KDef>, +image: NS_Image}

# Module: src/back/native/static.bend:141
law ns_static_term:
  for +cs: KDef
  for +t: KTerm
  for +image: NS_Image
  NS_Term

# Module: src/back/native/static.bend:17
@unsafe
def ns_source(+book: List<&2, KDef>) -> List<&2, KDef>:
  match book:
    case Nil{}: book_cached(Nil{}, 0)
    case Con{+cache, +rest}:
      nt_choose(List<&2, KDef>, p88_string_eq(dk(cache), "BookCache"),
        u => Con{KDef{dn(cache), dk(cache), da(cache), dx(cache), dt(cache), dv(cache), [index_first(dc(cache))], db(cache), du(cache)}, rest},
        u => nt_choose(List<&2, KDef>, nc_context_has_cache(rest), v => Con{cache, rest}, v => book_cached(Con{cache, rest}, norm_max_book(Con{cache, rest}))))

# Module: src/back/native/static.bend:26
@unsafe
def ns_context(+book: List<&2, KDef>) -> KDef:
  match book:
    case Con{cache, rest}:
      nt_choose(KDef, p88_string_eq(dk(cache), "BookCache"), u => ns_payload(dc(cache)), u => missing())
    case _: missing()

# Module: src/back/native/static.bend:33
@unsafe
def ns_payload(children: List<&2, KDef>) -> KDef:
  match children:
    case Con{source, Con{+facts, rest}}:
      nt_choose(KDef, p88_string_eq(dk(facts), "NativeStaticContext") && p88_string_eq(dn(facts), "$native.static"), u => facts, u => missing())
    case _: missing()

# Module: src/back/native/static.bend:40
@unsafe
def ns_body(+book: List<&2, KDef>, +name: String) -> KDef:
  index_find(index_first(dc(ns_context(book))), name, index_hash(name, 2166136261), 32)

# Module: src/back/native/static.bend:44
@unsafe
def ns_image(+book: List<&2, KDef>) -> List<&2, String>:
  ns_image_words(ks(dt(ns_context(book))))

# Module: src/back/native/static.bend:48
@unsafe
def ns_image_words(ts: List<&2, KTerm>) -> List<&2, String>:
  ns_image_words_rev(ts, Nil{})

@unsafe
def ns_image_words_rev(ts: List<&2, KTerm>, words: List<&2, String>) -> List<&2, String>:
  match ts:
    case Nil{}: nt_reverse(String, words, Nil{})
    case Con{h, rest}: ns_image_words_rev(rest, Con{nm(h), words})

# Module: src/back/native/static.bend:54
@unsafe
def ns_image_terms(ws: List<&2, String>) -> List<&2, KTerm>:
  ns_image_terms_rev(ws, Nil{})

@unsafe
def ns_image_terms_rev(ws: List<&2, String>, terms: List<&2, KTerm>) -> List<&2, KTerm>:
  match ws:
    case Nil{}: nt_reverse(KTerm, terms, Nil{})
    case Con{h, rest}: ns_image_terms_rev(rest, Con{kt("StaticWord", h, 0, 0, Nil{}), terms})

# Exclude constructors with special runtime treatment, including all IO nodes.
# Scalar wrappers only become static after the existing literal pass proves
# them. Exact constructor arity rejects malformed raw graphs.

# Module: src/back/native/static.bend:63
@unsafe
def ns_ctor(+cs: KDef, +name: String, +arity: U32) -> Bool:
  nt_choose(Bool, nb_contains(["Zero", "Succ", "True", "False", "Chr", "U32", "F32", "ALeaf", "ANode", "Emit", "Halt", "Done", "Fail"], name),
    u => False{}, u => ns_ctor_known(cs, name, arity))

# Module: src/back/native/static.bend:68
@unsafe
def ns_ctor_known(+cs: KDef, +name: String, +arity: U32) -> Bool:
  +d = index_find(cs, name, index_hash(name, 2166136261), 32)
  p88_string_eq(dk(d), "NativeStaticCtor") && U32.is_eq(da(d), arity)

# Module: src/back/native/static.bend:73
@unsafe
def ns_ctor_index(cs: List<&2, N_Constructor>, +index: KDef) -> KDef:
  match cs:
    case Nil{}: index
    case Con{N_Constructor{+name, arity, hot}, rest}:
      ns_ctor_index(rest, index_set(index, KDef{name, "NativeStaticCtor", arity, 0, {KTerm{"Absent", "", 0, 0, Nil{}, Nil{}, 0, 0} : KTerm}, {KTerm{"Absent", "", 0, 0, Nil{}, Nil{}, 0, 0} : KTerm}, Nil{}, False{}, False{}}, index_hash(name, 2166136261), 32))

# Module: src/back/native/static.bend:80
@unsafe
def ns_constant(+t: KTerm) -> Bool:
  nt_choose(Bool, p98_tag_eq(t, "NStatic"), u => True{}, u =>
    nt_choose(Bool, p98_tag_eq(t, "NWord"), v => ns_canonical(nm(t), U32.read(nm(t))), v => False{}))

# Module: src/back/native/static.bend:85
@unsafe
def ns_canonical(+text: String, parsed: Maybe<&2, U32>) -> Bool:
  match parsed:
    case None{}: False{}
    case Some{value}: p88_string_eq(text, U32.show(value))

# Module: src/back/native/static.bend:91
@unsafe
def ns_constants(ts: List<&2, KTerm>) -> Bool:
  match ts:
    case Nil{}: True{}
    case Con{h, rest}: nt_choose(Bool, ns_constant(h), u => ns_constants(rest), u => False{})

# Module: src/back/native/static.bend:97
@unsafe
def ns_word(+t: KTerm) -> String:
  nt_choose(String, p98_tag_eq(t, "NWord"), u => nm(t) ++ "ull", u =>
    nt_choose(String, U32.is_eq(qt(t), 1),
      u => "term_pak(" ++ nt_cid(nm(t)) ++ ", " ++ nt_choose(String, List.is_empty(&2, KTerm, ks(t)), v => "0", v => ns_word(kid(t, 0))) ++ ")",
      u => "term_ctr(" ++ nt_cid(nm(t)) ++ ", STAT_OFF + " ++ U32.show(ix(t)) ++ ")"))

# Module: src/back/native/static.bend:104
@unsafe
def ns_words(ts: List<&2, KTerm>) -> List<&2, String>:
  match ts:
    case Nil{}: Nil{}
    case Con{h, rest}: Con{ns_word(h), ns_words(rest)}

# An immediate U32 payload is within LOC_MASK. Other one-field constructors
# retain a box; no type annotation or raw width promise licenses packing.

# Module: src/back/native/static.bend:112
@unsafe
def ns_packed(+t: KTerm) -> Bool:
  ns_packed_fields(t, ks(t))

# Module: src/back/native/static.bend:116
@unsafe
def ns_packed_fields(+t: KTerm, fields: List<&2, KTerm>) -> Bool:
  match fields:
    case Nil{}: True{}
    case Con{+h, Nil{}}:
      nt_choose(Bool, String.starts_with(nm(t), "$ctor.") && p98_tag_eq(h, "NWord"), u => ns_constant(h), u => False{})
    case _: False{}

# Module: src/back/native/static.bend:124
@unsafe
def ns_node(+t: KTerm, +image: NS_Image) -> NS_Term:
  nt_choose(NS_Term, ns_packed(t), u => NS_Term{kt("NStatic", nm(t), 0, 1, ks(t)), image},
    u => ns_intern(t, ns_words(ks(t)), image))

# Module: src/back/native/static.bend:129
@unsafe
def ns_intern(+t: KTerm, +words: List<&2, String>, image: NS_Image) -> NS_Term:
  match image:
    case NS_Image{+size, +stored, +index}:
      +key = nm(t) ++ "(" ++ nt_join(words, ",") ++ ")"
      +hash = index_hash(key, 2166136261)
      +old = index_find(index, key, hash, 32)
      nt_choose(NS_Term, p88_string_eq(dk(old), "NativeStaticNode"),
        u => NS_Term{kt("NStatic", nm(t), da(old), 0, ks(t)), NS_Image{size, stored, index}},
        u => nt_choose(NS_Term, U32.is_le(terms_len(ks(t)), U32.sub(65536, size)),
          v => NS_Term{kt("NStatic", nm(t), size, 0, ks(t)), NS_Image{U32.add(size, terms_len(ks(t))), nt_reverse(String, words, stored), index_set(index, KDef{key, "NativeStaticNode", size, 0, {KTerm{"Absent", "", 0, 0, Nil{}, Nil{}, 0, 0} : KTerm}, {KTerm{"Absent", "", 0, 0, Nil{}, Nil{}, 0, 0} : KTerm}, Nil{}, False{}, False{}}, hash, 32)}},
          v => NS_Term{t, NS_Image{size, stored, index}}))

# Module: src/back/native/static.bend:148
@unsafe
def ns_static_terms(+cs: KDef, ts: List<&2, KTerm>, +image: NS_Image) -> NS_Terms:
  match ts:
    case Nil{}: NS_Terms{Nil{}, image}
    case Con{h, rest}: ns_terms_step(cs, rest, ns_static_term(cs, h, image))

# Module: src/back/native/static.bend:154
@unsafe
def ns_terms_step(+cs: KDef, +rest: List<&2, KTerm>, first: NS_Term) -> NS_Terms:
  match first:
    case NS_Term{head, image}: ns_terms_cons(head, ns_static_terms(cs, rest, image))

# Module: src/back/native/static.bend:159
@unsafe
def ns_terms_cons(head: KTerm, tail: NS_Terms) -> NS_Terms:
  match tail:
    case NS_Terms{rest, image}: NS_Terms{Con{head, rest}, image}

# Module: src/back/native/static.bend:164
@unsafe
def ns_static_term(cs, t, image):
  # Input cannot import a stale or forged image offset into this request.
  nt_choose(NS_Term, (p98_tag_eq(t, "NStatic") || p98_tag_eq(t, "NWPattern")), u => NS_Term{{KTerm{"NativeStaticInput", "", 0, 0, Nil{}, Nil{}, 0, 0} : KTerm}, image},
    u => nt_choose(NS_Term, p98_tag_eq(t, "NWord") || p98_tag_eq(t, "Var") || p98_tag_eq(t, "Ref"),
      v => NS_Term{t, image}, v => ns_rebuild(cs, t, ns_static_terms(cs, ks(t), image))))

# Module: src/back/native/static.bend:171
@unsafe
def ns_rebuild(+cs: KDef, +original: KTerm, children: NS_Terms) -> NS_Term:
  match children:
    case NS_Terms{+kids, image}:
      +t = k_rebuild(original, nm(original), ix(original), qt(original), kids, rm(original), kb(original), ke(original))
      nt_choose(NS_Term, p98_tag_eq(t, "Ctr"),
        u => ns_constructor(cs, ns_static_scalar(t), image), u => NS_Term{nw_prepare(t), image})

# Module: src/back/native/static.bend:179
@unsafe
def ns_constructor(+cs: KDef, +t: KTerm, +image: NS_Image) -> NS_Term:
  nt_choose(NS_Term, p98_tag_eq(t, "NWord"), u => NS_Term{t, image}, u =>
    nt_choose(NS_Term, ns_ctor(cs, nm(t), terms_len(ks(t))),
      v => nt_choose(NS_Term, ns_constants(ks(t)), w => ns_node(t, image), w => NS_Term{t, image}),
      v => NS_Term{t, image}))

# Native Bool and Char constructors have immediate runtime representations.
# Exact syntax/arity preserves malformed wrappers' original fallback.

# Module: src/back/native/static.bend:188
@unsafe
def ns_static_scalar(+t: KTerm) -> KTerm:
  ns_static_scalar_fields(t, ks(t))

# Module: src/back/native/static.bend:192
@unsafe
def ns_static_scalar_fields(+t: KTerm, fields: List<&2, KTerm>) -> KTerm:
  match fields:
    case Nil{}:
      nt_choose(KTerm, p88_string_eq(nm(t), "True") || p88_string_eq(nm(t), "False"),
        u => kt("NWord", nt_choose(String, p88_string_eq(nm(t), "True"), v => "1", v => "0"), 0, 0, Nil{}), u => t)
    case Con{+h, Nil{}}:
      nt_choose(KTerm, p88_string_eq(nm(t), "Chr") && p98_tag_eq(h, "NWord"), u => h, u => t)
    case _: t

# Module: src/back/native/static.bend:202
@unsafe
def ns_defs(+book: List<&2, KDef>, +cs: KDef, names: List<&2, String>, +image: NS_Image, +facts: List<&2, KDef>) -> NS_Defs:
  match names:
    case Nil{}: NS_Defs{facts, image}
    case Con{+name, +rest}:
      +d = lookup(book, name)
      nt_choose(NS_Defs, p88_string_eq(dk(d), "Def"),
        u => nt_choose(NS_Defs, nc_native_def(d) || nc_foreign(d),
          v => ns_defs(book, cs, rest, image, facts),
          v => ns_def_step(book, cs, rest, name, facts, ns_static_term(cs, nc_compact(nc_definition(book, d, 0)), image))),
        u => ns_defs(book, cs, rest, image, facts))

# Module: src/back/native/static.bend:214
@unsafe
def ns_def_step(+book: List<&2, KDef>, +cs: KDef, +rest: List<&2, String>, +name: String, +facts: List<&2, KDef>, transformed: NS_Term) -> NS_Defs:
  match transformed:
    case NS_Term{body, image}:
      +prior = ns_body(book, name)
      ns_defs(book, cs, rest, image, Con{KDef{name, "NativeStaticBody", da(prior), dx(prior), {KTerm{"Absent", "", 0, 0, Nil{}, Nil{}, 0, 0} : KTerm}, body, [prior], False{}, False{}}, facts})

# Module: src/back/native/static.bend:221
@unsafe
def ns_attach(+book: List<&2, KDef>, built: NS_Defs) -> List<&2, KDef>:
  match built:
    case NS_Defs{facts, NS_Image{size, words, index}}:
      ns_attach_book(book, facts, size, words)

# Module: src/back/native/static.bend:227
@unsafe
def ns_attach_book(+book: List<&2, KDef>, +facts: List<&2, KDef>, +size: U32, +words: List<&2, String>) -> List<&2, KDef>:
  match book:
    case Con{cache, rest}:
      Con{KDef{dn(cache), dk(cache), da(cache), dx(cache), dt(cache), dv(cache),
        [index_first(dc(cache)), KDef{"$native.static", "NativeStaticContext", 0, 0, kt("NativeImage", "", size, 0, ns_image_terms(nt_reverse(String, words, Nil{}))), {KTerm{"Absent", "", 0, 0, Nil{}, Nil{}, 0, 0} : KTerm}, [index_build(facts), nc_ctor_prepare(book)], False{}, False{}}], db(cache), du(cache)}, rest}
    case _: book

# Module: src/back/native/static.bend:235
@unsafe
def ns_prepare(+book: List<&2, KDef>, +names: List<&2, String>) -> List<&2, KDef>:
  nt_choose(List<&2, KDef>, p88_string_eq(dk(index_first(book)), "BookCache"),
    u => ns_prepare_cached(book, names), u => book)

# Module: src/back/native/static.bend:240
@unsafe
def ns_prepare_cached(+book: List<&2, KDef>, +names: List<&2, String>) -> List<&2, KDef>:
  nt_choose(List<&2, KDef>, nc_pack_foreign(book), u => book,
    u => ns_attach(book, ns_defs(book, ns_ctor_index(nc_add_ctors(nc_default_ctors(), nc_constructors(book, book)), missing()), names, NS_Image{0, Nil{}, missing()}, Nil{})))

# Retain product facts: a static fixed-shell result can still return its fields
# directly. Only opaque destinations receive the immortal constructor word.

# Module: src/back/native/static.bend:247
@unsafe
def ns_return(+book: List<&2, KDef>, +t: KTerm, +n: U32, +target: NC_Target) -> NC_Code:
  nt_choose(NC_Code, p88_string_eq(dk(ns_context(book)), "NativeStaticContext"), u => ns_return_known(t, n, target), u => nc_fail("native static word outside its request", n))

# Module: src/back/native/static.bend:251
@unsafe
def ns_return_known(+t: KTerm, +n: U32, +target: NC_Target) -> NC_Code:
  match target:
    case NC_Scheduler{}: nc_return(ns_word(t), n)
    case NC_Destination{dests, +shape, join, owner, params, tail, signatures}:
      nt_choose(NC_Code, p98_tag_eq(shape, "NQShape") && p88_string_eq(nm(shape), nm(t)) && U32.is_eq(ix(shape), terms_len(ks(t))),
        u => nq_transfer(shape, ns_words(ks(t)), n, target), u => nf_return(ns_word(t), n, target))

# Called only after nc_compile validates main, source ownership and binder IDs.

# Module: src/back/native/static.bend:260
@unsafe
def ns_compile(+book: List<&2, KDef>, +runtime: NE_Runtime, +requests: String, +observers: Bool) -> NC_Result:
  ns_compile_scoped(book, runtime, requests, observers, observers)

# Module: src/back/native/static.bend:266
@unsafe
def ns_compile_named(+source: List<&2, KDef>, +names: List<&2, String>, +runtime: NE_Runtime, +requests: String, +observers: Bool) -> NC_Result:
  ns_compile_named_scoped(source, names, runtime, requests, observers, observers)

# Module: src/back/native/static.bend:274
@unsafe
def ns_compile_planned(+book: List<&2, KDef>, +names: List<&2, String>, +bangs: List<&2, String>, +runtime: NE_Runtime, +requests: String, +observers: Bool) -> NC_Result:
  ns_compile_planned_scoped(book, names, bangs, runtime, requests, observers, observers)

# Preserve the original raw/bang error order: failed generic lowering never
# asks optional worker planning to inspect an unsupported or malformed body.

# Module: src/back/native/static.bend:282
@unsafe
def ns_compile_fallback(+book: List<&2, KDef>, +names: List<&2, String>, +bangs: List<&2, String>, +runtime: NE_Runtime, +requests: String, +observers: Bool, compiled: NC_Book) -> NC_Result:
  ns_compile_fallback_scoped(book, names, bangs, runtime, requests, observers, observers, compiled)
