# Closed immutable constructor graphs share the existing runtime static image.
# Facts live only in a fresh native request's BookCache payload; source lookup
# and all original definitions stay exact. Arrays/effects/foreign stay dynamic.
type NS_Image is Data:
  NS_Image{+size: U32, +words: List<&2, String>, +index: KDef}

type NS_Term is Data:
  NS_Term{+term: KTerm, +image: NS_Image}

type NS_Terms is Data:
  NS_Terms{+terms: List<&2, KTerm>, +image: NS_Image}

type NS_Defs is Data:
  NS_Defs{+defs: List<&2, KDef>, +image: NS_Image}

@unsafe
def ns_source(+book: List<&2, KDef>) -> List<&2, KDef>:
  match book:
    case Nil{}: book_cached(Nil{}, 0)
    case Con{+cache, +rest}:
      nt_choose(List<&2, KDef>, String.eq(dk(cache), "BookCache"),
        u => Con{KDef{dn(cache), dk(cache), da(cache), dx(cache), dt(cache), dv(cache), [index_first(dc(cache))], db(cache), du(cache)}, rest},
        u => nt_choose(List<&2, KDef>, nc_context_has_cache(rest), v => Con{cache, rest}, v => book_cached(Con{cache, rest}, norm_max_book(Con{cache, rest}))))

@unsafe
def ns_context(+book: List<&2, KDef>) -> KDef:
  match book:
    case Con{cache, rest}:
      nt_choose(KDef, String.eq(dk(cache), "BookCache"), u => ns_payload(dc(cache)), u => missing())
    case _: missing()

@unsafe
def ns_payload(children: List<&2, KDef>) -> KDef:
  match children:
    case Con{source, Con{+facts, rest}}:
      nt_choose(KDef, String.eq(dk(facts), "NativeStaticContext") && String.eq(dn(facts), "$native.static"), u => facts, u => missing())
    case _: missing()

@unsafe
def ns_body(+book: List<&2, KDef>, +name: String) -> KDef:
  index_find(index_first(dc(ns_context(book))), name, index_hash(name, 2166136261), 32)

@unsafe
def ns_image(+book: List<&2, KDef>) -> List<&2, String>:
  ns_image_words(ks(dt(ns_context(book))))

@unsafe
def ns_image_words(ts: List<&2, KTerm>) -> List<&2, String>:
  match ts:
    case Nil{}: Nil{}
    case Con{h, rest}: Con{nm(h), ns_image_words(rest)}

@unsafe
def ns_image_terms(ws: List<&2, String>) -> List<&2, KTerm>:
  match ws:
    case Nil{}: Nil{}
    case Con{h, rest}: Con{kt("StaticWord", h, 0, 0, Nil{}), ns_image_terms(rest)}

# Exclude constructors with special runtime treatment, including all IO nodes.
# Scalar wrappers only become static after the existing literal pass proves
# them. Exact constructor arity rejects malformed raw graphs.
@unsafe
def ns_ctor(+cs: KDef, +name: String, +arity: U32) -> Bool:
  nt_choose(Bool, nb_contains(["Zero", "Succ", "True", "False", "Chr", "U32", "F32", "ALeaf", "ANode", "Emit", "Halt", "Done", "Fail"], name),
    u => False{}, u => ns_ctor_known(cs, name, arity))

@unsafe
def ns_ctor_known(+cs: KDef, +name: String, +arity: U32) -> Bool:
  +d = index_find(cs, name, index_hash(name, 2166136261), 32)
  String.eq(dk(d), "NativeStaticCtor") && U32.is_eq(da(d), arity)

@unsafe
def ns_ctor_index(cs: List<&2, N_Constructor>, +index: KDef) -> KDef:
  match cs:
    case Nil{}: index
    case Con{N_Constructor{+name, arity, hot}, rest}:
      ns_ctor_index(rest, index_set(index, KDef{name, "NativeStaticCtor", arity, 0, atom("Absent"), atom("Absent"), Nil{}, False{}, False{}}, index_hash(name, 2166136261), 32))

@unsafe
def ns_constant(+t: KTerm) -> Bool:
  nt_choose(Bool, String.eq(tg(t), "NStatic"), u => True{}, u =>
    nt_choose(Bool, String.eq(tg(t), "NWord"), v => ns_canonical(nm(t), U32.read(nm(t))), v => False{}))

@unsafe
def ns_canonical(+text: String, parsed: Maybe<&2, U32>) -> Bool:
  match parsed:
    case None{}: False{}
    case Some{value}: String.eq(text, U32.show(value))

@unsafe
def ns_constants(ts: List<&2, KTerm>) -> Bool:
  match ts:
    case Nil{}: True{}
    case Con{h, rest}: nt_choose(Bool, ns_constant(h), u => ns_constants(rest), u => False{})

@unsafe
def ns_word(+t: KTerm) -> String:
  nt_choose(String, String.eq(tg(t), "NWord"), u => nm(t) ++ "ull", u =>
    nt_choose(String, U32.is_eq(qt(t), 1),
      u => "term_pak(" ++ nt_cid(nm(t)) ++ ", " ++ nt_choose(String, List.is_empty(&2, KTerm, ks(t)), v => "0", v => ns_word(kid(t, 0))) ++ ")",
      u => "term_ctr(" ++ nt_cid(nm(t)) ++ ", STAT_OFF + " ++ U32.show(ix(t)) ++ ")"))

@unsafe
def ns_words(ts: List<&2, KTerm>) -> List<&2, String>:
  match ts:
    case Nil{}: Nil{}
    case Con{h, rest}: Con{ns_word(h), ns_words(rest)}

# An immediate U32 payload is within LOC_MASK. Other one-field constructors
# retain a box; no type annotation or raw width promise licenses packing.
@unsafe
def ns_packed(+t: KTerm) -> Bool:
  ns_packed_fields(t, ks(t))

@unsafe
def ns_packed_fields(+t: KTerm, fields: List<&2, KTerm>) -> Bool:
  match fields:
    case Nil{}: True{}
    case Con{+h, Nil{}}:
      nt_choose(Bool, String.starts_with(nm(t), "$ctor.") && String.eq(tg(h), "NWord"), u => ns_constant(h), u => False{})
    case _: False{}

@unsafe
def ns_node(+t: KTerm, +image: NS_Image) -> NS_Term:
  nt_choose(NS_Term, ns_packed(t), u => NS_Term{kt("NStatic", nm(t), 0, 1, ks(t)), image},
    u => ns_intern(t, ns_words(ks(t)), image))

@unsafe
def ns_intern(+t: KTerm, +words: List<&2, String>, image: NS_Image) -> NS_Term:
  match image:
    case NS_Image{+size, +stored, +index}:
      +key = nm(t) ++ "(" ++ nt_join(words, ",") ++ ")"
      +hash = index_hash(key, 2166136261)
      +old = index_find(index, key, hash, 32)
      nt_choose(NS_Term, String.eq(dk(old), "NativeStaticNode"),
        u => NS_Term{kt("NStatic", nm(t), da(old), 0, ks(t)), NS_Image{size, stored, index}},
        u => nt_choose(NS_Term, U32.is_le(terms_len(ks(t)), U32.sub(65536, size)),
          v => NS_Term{kt("NStatic", nm(t), size, 0, ks(t)), NS_Image{U32.add(size, terms_len(ks(t))), nt_reverse(String, words, stored), index_set(index, KDef{key, "NativeStaticNode", size, 0, atom("Absent"), atom("Absent"), Nil{}, False{}, False{}}, hash, 32)}},
          v => NS_Term{t, NS_Image{size, stored, index}}))

law ns_static_term:
  for +cs: KDef
  for +t: KTerm
  for +image: NS_Image
  NS_Term

@unsafe
def ns_static_terms(+cs: KDef, ts: List<&2, KTerm>, +image: NS_Image) -> NS_Terms:
  match ts:
    case Nil{}: NS_Terms{Nil{}, image}
    case Con{h, rest}: ns_terms_step(cs, rest, ns_static_term(cs, h, image))

@unsafe
def ns_terms_step(+cs: KDef, +rest: List<&2, KTerm>, first: NS_Term) -> NS_Terms:
  match first:
    case NS_Term{head, image}: ns_terms_cons(head, ns_static_terms(cs, rest, image))

@unsafe
def ns_terms_cons(head: KTerm, tail: NS_Terms) -> NS_Terms:
  match tail:
    case NS_Terms{rest, image}: NS_Terms{Con{head, rest}, image}

@unsafe
def ns_static_term(cs, t, image):
  # Input cannot import a stale or forged image offset into this request.
  nt_choose(NS_Term, String.eq(tg(t), "NStatic"), u => NS_Term{atom("NativeStaticInput"), image},
    u => nt_choose(NS_Term, String.eq(tg(t), "NWord") || String.eq(tg(t), "Var") || String.eq(tg(t), "Ref"),
      v => NS_Term{t, image}, v => ns_rebuild(cs, t, ns_static_terms(cs, ks(t), image))))

@unsafe
def ns_rebuild(+cs: KDef, +original: KTerm, children: NS_Terms) -> NS_Term:
  match children:
    case NS_Terms{+kids, image}:
      +t = k_rebuild(original, nm(original), ix(original), qt(original), kids, rm(original), kb(original), ke(original))
      nt_choose(NS_Term, String.eq(tg(t), "Ctr"),
        u => ns_constructor(cs, ns_static_scalar(t), image), u => NS_Term{t, image})

@unsafe
def ns_constructor(+cs: KDef, +t: KTerm, +image: NS_Image) -> NS_Term:
  nt_choose(NS_Term, String.eq(tg(t), "NWord"), u => NS_Term{t, image}, u =>
    nt_choose(NS_Term, ns_ctor(cs, nm(t), terms_len(ks(t))),
      v => nt_choose(NS_Term, ns_constants(ks(t)), w => ns_node(t, image), w => NS_Term{t, image}),
      v => NS_Term{t, image}))

# Native Bool and Char constructors have immediate runtime representations.
# Exact syntax/arity preserves malformed wrappers' original fallback.
@unsafe
def ns_static_scalar(+t: KTerm) -> KTerm:
  ns_static_scalar_fields(t, ks(t))

@unsafe
def ns_static_scalar_fields(+t: KTerm, fields: List<&2, KTerm>) -> KTerm:
  match fields:
    case Nil{}:
      nt_choose(KTerm, String.eq(nm(t), "True") || String.eq(nm(t), "False"),
        u => kt("NWord", nt_choose(String, String.eq(nm(t), "True"), v => "1", v => "0"), 0, 0, Nil{}), u => t)
    case Con{+h, Nil{}}:
      nt_choose(KTerm, String.eq(nm(t), "Chr") && String.eq(tg(h), "NWord"), u => h, u => t)
    case _: t

@unsafe
def ns_defs(+book: List<&2, KDef>, +cs: KDef, names: List<&2, String>, +image: NS_Image, +facts: List<&2, KDef>) -> NS_Defs:
  match names:
    case Nil{}: NS_Defs{facts, image}
    case Con{+name, +rest}:
      +d = lookup(book, name)
      nt_choose(NS_Defs, String.eq(dk(d), "Def"),
        u => nt_choose(NS_Defs, nc_native_def(d) || nc_foreign(d),
          v => ns_defs(book, cs, rest, image, facts),
          v => ns_def_step(book, cs, rest, name, facts, ns_static_term(cs, nc_compact(nc_definition_plain(book, d, 0)), image))),
        u => ns_defs(book, cs, rest, image, facts))

@unsafe
def ns_def_step(+book: List<&2, KDef>, +cs: KDef, +rest: List<&2, String>, +name: String, +facts: List<&2, KDef>, transformed: NS_Term) -> NS_Defs:
  match transformed:
    case NS_Term{body, image}: ns_defs(book, cs, rest, image, Con{KDef{name, "NativeStaticBody", 0, 0, atom("Absent"), body, Nil{}, False{}, False{}}, facts})

@unsafe
def ns_attach(+book: List<&2, KDef>, built: NS_Defs) -> List<&2, KDef>:
  match built:
    case NS_Defs{facts, NS_Image{size, words, index}}:
      ns_attach_book(book, facts, size, words)

@unsafe
def ns_attach_book(+book: List<&2, KDef>, +facts: List<&2, KDef>, +size: U32, +words: List<&2, String>) -> List<&2, KDef>:
  match book:
    case Con{cache, rest}:
      Con{KDef{dn(cache), dk(cache), da(cache), dx(cache), dt(cache), dv(cache),
        [index_first(dc(cache)), KDef{"$native.static", "NativeStaticContext", 0, 0, kt("NativeImage", "", size, 0, ns_image_terms(nt_reverse(String, words, Nil{}))), atom("Absent"), [index_build(facts)], False{}, False{}}], db(cache), du(cache)}, rest}
    case _: book

@unsafe
def ns_prepare(+book: List<&2, KDef>, +names: List<&2, String>) -> List<&2, KDef>:
  nt_choose(List<&2, KDef>, String.eq(dk(index_first(book)), "BookCache"),
    u => ns_prepare_cached(book, names), u => book)

@unsafe
def ns_prepare_cached(+book: List<&2, KDef>, +names: List<&2, String>) -> List<&2, KDef>:
  nt_choose(List<&2, KDef>, nc_pack_foreign(book), u => book,
    u => ns_attach(book, ns_defs(book, ns_ctor_index(nc_add_ctors(nc_default_ctors(), nc_constructors(book, book)), missing()), names, NS_Image{0, Nil{}, missing()}, Nil{})))

# Retain product facts: a static fixed-shell result can still return its fields
# directly. Only opaque destinations receive the immortal constructor word.
@unsafe
def ns_return(+book: List<&2, KDef>, +t: KTerm, +n: U32, +target: NC_Target) -> NC_Code:
  nt_choose(NC_Code, String.eq(dk(ns_context(book)), "NativeStaticContext"), u => ns_return_known(t, n, target), u => nc_fail("native static word outside its request", n))

@unsafe
def ns_return_known(+t: KTerm, +n: U32, +target: NC_Target) -> NC_Code:
  match target:
    case NC_Scheduler{}: nc_return(ns_word(t), n)
    case NC_Destination{dests, +shape, join, owner, params, tail, signatures}:
      nt_choose(NC_Code, String.eq(tg(shape), "NQShape") && String.eq(nm(shape), nm(t)) && U32.is_eq(ix(shape), terms_len(ks(t))),
        u => nq_transfer(shape, ns_words(ks(t)), n, target), u => nf_return(ns_word(t), n, target))

# Called only after nc_compile validates main, source ownership and binder IDs.
@unsafe
def ns_compile(+book: List<&2, KDef>, +runtime: String, +requests: String, +observers: Bool) -> NC_Result:
  +source = ns_source(book)
  +names = nc_live_names(source, ["main"], Nil{})
  +prepared = ns_prepare(source, names)
  nc_finish(prepared, runtime, requests, nc_compile_defs(prepared, ["main"], Nil{}, 0, nc_bangs_names(prepared, names)), observers)
