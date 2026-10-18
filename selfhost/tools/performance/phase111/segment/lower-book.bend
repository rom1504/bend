# Request source remains authoritative for validation and metadata. Cached
# NativeErasedBody facts are reused without adding optional optimizer forms.
@unsafe
def p111_entry_join(+base: P111Code, +body: P111Code, +name: String, +params: List<&2, NC_Binding>) -> P111Code:
  P111Code{p111_body(base), nt_append(N111Segment, p111_segments(base), Con{p111_segment(nd_name(name), params, 0, 0, p111_body(body)), p111_segments(body)}), p111_fresh(body), p111_first(p111_error(base), p111_error(body))}

@unsafe
def p111_extend(+book: List<&2, KDef>, +body: KTerm, +base: P111Code, +name: String, +arity: U32) -> P111Code:
  +params = nd_entry_params(arity, p111_fresh(base))
  nt_choose(P111Code, U32.is_eq(arity, 0), u => base,
    u => p111_entry_join(base, p111_lower(book, nd_reapply(body, nd_entry_args(params)), params, U32.add(p111_fresh(base), arity)), nc_ref_name(book, name), params))

@unsafe
def p111_entry(+book: List<&2, KDef>, +body: KTerm, +name: String, +n: U32, +bang: Bool) -> P111Code:
  +d = lookup(book, name)
  +arity = nd_arity(book, name)
  +typed = jd_live_arity(book, dt(d), jd_arity(book, d))
  +eta = Bool.not(bang || nc_native_def(d) || nc_foreign(d)) && U32.is_gt(typed, 0) && U32.is_eq(typed, arity)
  +params = nd_entry_params(arity, n)
  +factory = nt_choose(P111Code, eta,
    u => p111_lower(book, nd_eta_body(params, kt("NCall", nd_name(nc_ref_name(book, name)), 0, 0, nd_entry_args(params))), Nil{}, U32.add(n, arity)),
    u => p111_lower(book, body, Nil{}, n))
  p111_extend(book, body, factory, name, arity)

@unsafe
def p111_mark_segments(segments: List<&2, N111Segment>, +bang: Bool) -> List<&2, N111Segment>:
  match segments:
    case Nil{}: Nil{}
    case Con{N111Segment{name, arity, result, incoming, flags, body}, rest}:
      Con{N111Segment{name, arity, result, incoming, nt_bool(bang), body}, p111_mark_segments(rest, bang)}

@unsafe
def p111_compile_step(+book: List<&2, KDef>, +name: String, +rest: List<&2, String>, +bangs: List<&2, String>, +acc: List<&2, N111Segment>, code: P111Code) -> P111Book:
  match code:
    case P111Code{+body, +segments, +fresh, +error}:
      nt_choose(P111Book, String.eq(error, ""),
        u => p111_compile_defs(book, rest, bangs, fresh, nt_reverse(N111Segment, p111_mark_segments(Con{p111_segment(nc_ref_name(book, name), Nil{}, 0, 0, body), segments}, nb_contains(bangs, name)), acc)),
        u => P111Book{Nil{}, fresh, error})

@unsafe
def p111_compile_defs(+book: List<&2, KDef>, names: List<&2, String>, +bangs: List<&2, String>, +n: U32, +acc: List<&2, N111Segment>) -> P111Book:
  match names:
    case Nil{}: P111Book{nt_reverse(N111Segment, acc, Nil{}), n, ""}
    case Con{+name, +rest}:
      +d = lookup(book, name)
      nt_choose(P111Book, String.eq(dk(d), "Absent"), u => P111Book{Nil{}, n, "native definition not found: " ++ name_key(name)},
        u => p111_compile_step(book, name, rest, bangs, acc, p111_entry(book, nc_compact_definition(book, d, n), name, U32.add(n, 1024), nb_contains(bangs, name))))

@unsafe
def p111_effects(+source: List<&2, KDef>, names: List<&2, String>) -> List<&2, String>:
  match names:
    case Nil{}: Nil{}
    case Con{+name, +rest}:
      nt_choose(List<&2, String>, nc_foreign(lookup(source, name)), u => Con{name, p111_effects(source, rest)}, u => p111_effects(source, rest))

@unsafe
def p111_empty() -> P111Program:
  P111Program{Nil{}, Nil{}, Nil{}, Nil{}, Nil{}, False{}}

@unsafe
def p111_finish_show(+segments: List<&2, N111Segment>, +ctors: List<&2, N_Constructor>, +effects: List<&2, String>, +pure: Bool, show: P111Show) -> P111Result:
  match show:
    case P111Show{+words, +names, +error}: P111Result{P111Program{segments, ctors, words, names, effects, pure}, error}

@unsafe
def p111_finish(+source: List<&2, KDef>, +names: List<&2, String>, compiled: P111Book) -> P111Result:
  match compiled:
    case P111Book{+segments, +fresh, +error}:
      +ty = dt(lookup(source, "main"))
      +pure = Bool.not(nc_is_io(source, ty))
      +ctors = nc_add_ctors(nc_default_ctors(), nc_constructors(source, source))
      nt_choose(P111Result, String.eq(error, ""),
        u => p111_finish_show(segments, ctors, p111_effects(source, names), pure, nt_choose(P111Show, pure, u => p111_show(source, ty, ctors), u => P111Show{[0], Nil{}, ""})),
        u => P111Result{p111_empty(), error})

@unsafe
def p111_lower_request(request: NR_Request) -> P111Result:
  match request:
    case NR_Request{+source, +book, +names, +paths, +scope, +bound}:
      +error = nc_compile_error_known(source, bound)
      nt_choose(P111Result, String.eq(error, ""),
        u => p111_finish(source, names, p111_compile_defs(book, names, nc_bangs_names(book, names), 0, Nil{})),
        u => P111Result{p111_empty(), error})
