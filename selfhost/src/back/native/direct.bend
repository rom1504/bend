# Saturated calls to a known leading lambda telescope use one register entry.
# Partial applications retain the ordinary closure entry and its ownership ABI.
law nd_app:
  for +book: List<&2, KDef>
  for +t: KTerm
  for +env: List<&2, NC_Binding>
  for +n: U32
  NC_Code

@unsafe
def nd_name(name: String) -> String:
  "$direct." ++ name

@unsafe
def nd_head(+t: KTerm) -> KTerm:
  nt_choose(KTerm, String.eq(tg(t), "App"), u => nd_head(kid(t, 0)), u => t)

@unsafe
def nd_args(+t: KTerm, +acc: List<&2, KTerm>) -> List<&2, KTerm>:
  nt_choose(List<&2, KTerm>, String.eq(tg(t), "App"), u => nd_args(kid(t, 0), Con{kid(t, 1), acc}), u => acc)

@unsafe
def nd_leading(+t: KTerm, +n: U32) -> U32:
  nt_choose(U32, String.eq(tg(t), "Ann"), u => nd_leading(kid(t, 0), n), u =>
    nt_choose(U32, String.eq(tg(t), "Lam"), u => nd_leading(kid(t, 0), U32.add(n, nt_bool(Bool.not(U32.is_eq(qt(t), 0))))), u => n))

@unsafe
def nd_foreign_arity(+book: List<&2, KDef>, +ty: KTerm, +n: U32) -> U32:
  +tel = wnf(book, ty)
  nt_choose(U32, String.eq(tg(tel), "All"), u => nd_foreign_arity(book, kid(tel, 1), U32.add(n, nt_bool(Bool.not(U32.is_eq(qt(tel), 0))))), u => n)

@unsafe
def nd_arity(+book: List<&2, KDef>, +name: String) -> U32:
  +d = lookup(book, name)
  nt_choose(U32, nc_native_def(d), u => nc_primitive_arity(nc_primitive_name(name)), u =>
    nt_choose(U32, String.eq(tg(nc_unann(dv(d))), "Foreign"), u => nd_foreign_arity(book, dt(d), 0), u => nd_leading(dv(d), 0)))

@unsafe
def nd_reapply(+head: KTerm, args: List<&2, KTerm>) -> KTerm:
  match args:
    case Nil{}: head
    case Con{h, rest}: nd_reapply(app(head, h), rest)

@unsafe
def nd_beta(+head: KTerm, args: List<&2, KTerm>) -> KTerm:
  match args:
    case Nil{}: head
    case Con{+arg, +rest}:
      nt_choose(KTerm, String.eq(tg(head), "Lam"),
        u => nt_choose(KTerm, String.eq(tg(arg), "Var"),
          u => nd_beta(subst(kid(head, 0), ix(head), arg), rest),
          u => nc_mklet(ix(head), arg, nd_beta(kid(head, 0), rest))),
        u => nd_reapply(head, Con{arg, rest}))

@unsafe
def nd_match(+book: List<&2, KDef>, +head: KTerm, +arg: KTerm, +env: List<&2, NC_Binding>, +n: U32) -> NC_Code:
  nt_choose(NC_Code, String.eq(tg(arg), "Var"),
    u => nc_lower(book, kt("NMatch", "", 0, 0, [head, arg]), env, n),
    u => nc_lower(book, nc_mklet(nc_id(n), arg, kt("NMatch", "", 0, 0, [head, var("", nc_id(n))])), env, U32.inc(n)))

@unsafe
def nd_app(book, t, env, n):
  +head = nd_head(t)
  +args = nd_args(t, Nil{})
  nt_choose(NC_Code, String.eq(tg(head), "Lam"), u => nc_lower(book, nd_beta(head, args), env, n), u =>
    nt_choose(NC_Code, String.eq(tg(head), "Mat") && U32.is_eq(terms_len(args), 1), u => nd_match(book, head, kid(t, 1), env, n), u =>
    nt_choose(NC_Code, String.eq(tg(head), "Ref"), u =>
    nt_choose(NC_Code, Bool.not(U32.is_eq(qt(head), 3)) && U32.is_gt(terms_len(args), 0) && U32.is_eq(nd_arity(book, nm(head)), terms_len(args)),
      u => nc_lower(book, nc_sequence("NCall", nd_name(nc_ref_name(book, nm(head))), args, Nil{}, n), env, U32.add(n, terms_len(args))),
      u => nc_app_slow(book, t, env, n)), u => nc_app_slow(book, t, env, n))))

@unsafe
def nd_body(+t: KTerm) -> KTerm:
  nt_choose(KTerm, String.eq(tg(t), "Lam"), u => nd_body(kid(t, 0)), u => t)

@unsafe
def nd_bindings(+t: KTerm, +acc: List<&2, NC_Binding>) -> List<&2, NC_Binding>:
  nt_choose(List<&2, NC_Binding>, String.eq(tg(t), "Lam"), u => nd_bindings(kid(t, 0), Con{nc_binding(ix(t)), acc}), u => nt_reverse(NC_Binding, acc, Nil{}))

@unsafe
def nd_join(+base: NC_Code, +body: NC_Code, name: String, params: List<&2, NC_Binding>) -> NC_Code:
  NC_Code{nc_body(base), nt_append(N_Segment, nc_segs(base), Con{N_Segment{nd_name(name), nc_params(params), 1, N_Direct{}, nc_body(body), Nil{}, False{}, False{}, False{}, False{}}, nc_segs(body)}), nc_fresh(body), nc_first_error(base, body)}

@unsafe
def nd_extend(+book: List<&2, KDef>, +body: KTerm, +base: NC_Code, +name: String) -> NC_Code:
  +params = nd_bindings(body, Nil{})
  nt_choose(NC_Code, U32.is_eq(nt_count(NC_Binding, params), 0), u => base, u =>
    nd_join(base, nc_lower(book, nd_body(body), params, nc_fresh(base)), nc_ref_name(book, name), params))
