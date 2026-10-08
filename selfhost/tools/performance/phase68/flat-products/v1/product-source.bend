# Private fixed-shell products. Fields keep the ordinary one-word Term ABI.
# NQShape carries native constructor identity and width; Absent is one word.
@unsafe
def nc_calls(+code: NC_Code) -> List<&2, String>:
  match code:
    case NC_Code{body, segs, fresh, error}: edges

@unsafe
def nq_note_call(code: NC_Code, name: String) -> NC_Code:
  match code:
    case NC_Code{body, segs, fresh, error}: NC_Code{body, segs, fresh, error}

@unsafe
def nq_width(+shape: KTerm) -> U32:
  nt_choose(U32, String.eq(tg(shape), "NQShape"), u => ix(shape), u => 1)

@unsafe
def nq_same(+a: KTerm, +b: KTerm) -> Bool:
  String.eq(tg(a), tg(b)) && String.eq(nm(a), nm(b)) && U32.is_eq(ix(a), ix(b))

@unsafe
def nq_words(+base: String, +count: U32, +i: U32) -> List<&2, String>:
  nt_choose(List<&2, String>, U32.is_eq(i, count), u => Nil{}, u => Con{base ++ "[" ++ U32.show(i) ++ "]", nq_words(base, count, U32.inc(i))})

@unsafe
def nq_assign(dests: List<&2, String>, words: List<&2, String>) -> String:
  match dests, words:
    case Con{dest, rest}, Con{word, more}: dest ++ " = " ++ word ++ ";\n" ++ nq_assign(rest, more)
    case _, _: ""

@unsafe
def nq_transfer(+shape: KTerm, +words: List<&2, String>, +n: U32, +target: NC_Target) -> NC_Code:
  match target:
    case NC_Scheduler{}: nq_box_return(shape, words, n, target)
    case NC_Destination{+dests, +wanted, +join, owner, params, tail, signatures}:
      nt_choose(NC_Code, nq_same(shape, wanted) && U32.is_eq(nt_count(String, words), nt_count(String, dests)),
        u => NC_Code{nq_assign(dests, words) ++ nt_choose(String, String.eq(join, ""), v => "return 1;\n", v => "goto " ++ join ++ ";\n"), Nil{}, n, ""},
        u => nt_choose(NC_Code, String.eq(tg(wanted), "NQShape"), v => nc_fail("flat product: opaque or mismatched result", n), v => nq_box_return(shape, words, n, target)))

@unsafe
def nq_box_return(+shape: KTerm, +words: List<&2, String>, +n: U32, +target: NC_Target) -> NC_Code:
  nt_choose(NC_Code, String.eq(tg(shape), "NQShape"),
    u => nf_emitted(nc_constructor_value(nm(shape), words, n), target),
    u => nt_choose(NC_Code, nf_scheduler(target), v => nc_return(nc_head(words), n), v => nc_fail("flat product: result width mismatch", n)))

@unsafe
def nq_ctor(+name: String, +words: List<&2, String>, +n: U32, +target: NC_Target) -> NC_Code:
  match target:
    case NC_Scheduler{}: nf_emitted(nc_constructor_value(name, words, n), target)
    case NC_Destination{dests, +shape, join, owner, params, tail, signatures}:
      nt_choose(NC_Code, String.eq(tg(shape), "NQShape") && String.eq(nm(shape), name) && U32.is_eq(ix(shape), nt_count(String, words)),
        u => nq_transfer(shape, words, n, target), u => nf_emitted(nc_constructor_value(name, words, n), target))

@unsafe
def nq_pair_primitive(+name: String) -> Bool:
  U32.is_ne(nc_atomic(name), 0) || String.eq(name, "array_size") || String.eq(name, "array_clone") || String.eq(name, "array_get") || String.eq(name, "array_swap")

@unsafe
def nq_intrinsic(+name: String, +words: List<&2, String>, +n: U32, +target: NC_Target) -> NC_Code:
  match target:
    case NC_Scheduler{}: nf_emitted(nc_intrinsic_value(name, words, n), target)
    case NC_Destination{dests, +shape, join, owner, params, tail, signatures}:
      nt_choose(NC_Code, nq_pair_primitive(name) && String.eq(tg(shape), "NQShape") && String.eq(nm(shape), "Tuple") && U32.is_eq(ix(shape), 2),
        u => nq_array_pair(name, words, n, target), u => nf_emitted(nc_intrinsic_value(name, words, n), target))

@unsafe
def nq_array_pair(+name: String, +words: List<&2, String>, +n: U32, +target: NC_Target) -> NC_Code:
  +a = nc_head(words)
  +i = nc_head(nc_tail(words))
  +v = nc_head(nc_tail(nc_tail(words)))
  +shape = kt("NQShape", "Tuple", 2, 0, Nil{})
  nt_choose(NC_Code, U32.is_ne(nc_atomic(name), 0),
    u => nq_transfer(shape, [a, "array_atomic(e, " ++ a ++ ", " ++ i ++ ", " ++ v ++ ", " ++ nt_choose(String, String.eq(name, "array_atomic_cas"), v => nc_head(nc_tail(nc_tail(nc_tail(words)))), v => "0") ++ ", " ++ U32.show(nc_atomic(name)) ++ ")"], n, target), u =>
  nt_choose(NC_Code, String.eq(name, "array_size"), u => nq_transfer(shape, [a, "(1ull << blk_cls(" ++ a ++ "))"], n, target), u =>
  nt_choose(NC_Code, String.eq(name, "array_clone"), u => nq_transfer(shape, [a, "blk_copy(e, " ++ a ++ ")"], n, target), u =>
  nt_choose(NC_Code, String.eq(name, "array_get"), u => nc_prepend("u32 at = blk_at(" ++ a ++ ", " ++ i ++ ", 0);\n", nq_transfer(shape, [a, "blk_keep(e, term_peek(e, " ++ a ++ ") + at)"], n, target)), u =>
    nc_prepend("u32 at = blk_at(" ++ a ++ ", " ++ i ++ ", 0);\nTerm old = blk_read(e.mem, 1, term_peek(e, " ++ a ++ "), at);\nblk_write(e.mem, 1, term_peek(e, " ++ a ++ "), at, rfc_seal(e, " ++ v ++ "));\n", nq_transfer(shape, [a, "old"], n, target))))))

@unsafe
def nq_signature(+target: NC_Target, +name: String) -> KTerm:
  match target:
    case NC_Scheduler{}: atom("Absent")
    case NC_Destination{dests, shape, join, owner, params, tail, +signatures}:
      nt_choose(KTerm, String.starts_with(name, "$product."), u => dt(lookup(signatures, name)), u => atom("Absent"))

@unsafe
def nq_info(+target: NC_Target, +name: String) -> KDef:
  match target:
    case NC_Scheduler{}: missing()
    case NC_Destination{dests, shape, join, owner, params, tail, +signatures}: lookup(signatures, name)

@unsafe
def nq_call_result(+name: String, +words: List<&2, String>, +n: U32, +target: NC_Target) -> NC_Code:
  +shape = nq_signature(target, name)
  +base = "nq_result_" ++ U32.show(n)
  nq_note_call(nc_prepend("Term " ++ base ++ "[" ++ U32.show(nq_width(shape)) ++ "];\nif (!" ++ nf_name(name) ++ "(e, seq, " ++ base ++ nf_arg_c(words) ++ ")) { return 0; }\n", nq_transfer(shape, nq_words(base, nq_width(shape), 0), U32.inc(n), target)), name)

# A virtual bundle has already evaluated fields, each represented by a Var.
# A single-use substitution keeps the existing scalar ownership environment.
@unsafe
def nq_uses(+t: KTerm, +id: U32) -> U32:
  nt_choose(U32, String.eq(tg(t), "Var"), u => nt_bool(U32.is_eq(ix(t), id)), u =>
    nt_choose(U32, String.eq(tg(t), "Mat") && U32.is_eq(terms_len(ks(t)), 2), u => U32.max(nq_uses(kid(t, 0), id), nq_uses(kid(t, 1), id)), u => nq_uses_list(ks(t), id)))

@unsafe
def nq_uses_list(ts: List<&2, KTerm>, +id: U32) -> U32:
  match ts:
    case Nil{}: 0
    case Con{h, rest}: U32.min(2, U32.add(nq_uses(h, id), nq_uses_list(rest, id)))

@unsafe
def nq_value_shape(+book: List<&2, KDef>, +value: KTerm, +target: NC_Target) -> KTerm:
  +head = nd_head(value)
  nt_choose(KTerm, String.eq(tg(value), "NQBundle"), u => kt("NQShape", nm(value), terms_len(ks(value)), 0, Nil{}), u =>
    nt_choose(KTerm, String.eq(tg(value), "Ctr") || String.eq(tg(value), "NCtr"), u => nq_ctor_shape(value, target), u =>
    nt_choose(KTerm, String.eq(tg(head), "Ref") && Bool.not(U32.is_eq(qt(head), 3)) && U32.is_eq(nd_arity(book, nm(head)), terms_len(nd_args(value, Nil{}))), u => nq_call_shape(book, nm(head), nd_args(value, Nil{}), target), u =>
      nt_choose(KTerm, String.eq(tg(value), "NFCall"), u => nq_call_shape(book, nm(value), ks(value), target), u =>
        nt_choose(KTerm, String.eq(tg(value), "NOp") && nq_pair_primitive(nm(value)), u => kt("NQShape", "Tuple", 2, 0, Nil{}), u => atom("Absent"))))))

@unsafe
def nq_ctor_shape(+value: KTerm, +target: NC_Target) -> KTerm:
  +d = nq_info(target, "$constructor." ++ nm(value))
  nt_choose(KTerm, String.eq(dk(d), "NQConstructor") && U32.is_eq(ix(dt(d)), terms_len(ks(value))), u => dt(d), u => atom("Absent"))

@unsafe
def nq_bundle_params(+count: U32, +n: U32) -> List<&2, NC_Binding>:
  nt_choose(List<&2, NC_Binding>, U32.is_eq(count, 0), u => Nil{}, u => Con{nc_binding(nc_id(n)), nq_bundle_params(U32.sub(count, 1), U32.inc(n))})

@unsafe
def nq_declare(words: List<&2, String>) -> String:
  match words:
    case Nil{}: ""
    case Con{word, rest}: "Term " ++ word ++ ";\n" ++ nq_declare(rest)

@unsafe
def nq_local(+target: NC_Target, +words: List<&2, String>, +shape: KTerm, +join: String) -> NC_Target:
  match target:
    case NC_Scheduler{}: NC_Scheduler{}
    case NC_Destination{dests, oldshape, label, owner, params, tail, signatures}: NC_Destination{words, shape, join, owner, params, False{}, signatures}

@unsafe
def nq_bind(+book: List<&2, KDef>, +value: KTerm, +body: KTerm, +env: List<&2, NC_Binding>, +id: U32, +n: U32, +target: NC_Target, +shape: KTerm) -> NC_Code:
  +params = nq_bundle_params(ix(shape), n)
  +join = "nq_join_" ++ U32.show(n)
  +bundle = kt("NQBundle", nm(shape), 0, 0, nd_entry_args(params))
  +rest = nc_lower_to(book, subst(body, id, bundle), List.append(&2, NC_Binding, nc_live_env(env, body), params), U32.add(n, ix(shape)), target)
  +val = nc_lower_to(book, value, nc_live_env(env, value), nc_fresh(rest), nq_local(target, nc_words(params), shape, join))
  NC_Code{nc_share_env(env, value, body) ++ nq_declare(nc_words(params)) ++ "{\n" ++ nc_body(val) ++ "}\n" ++ join ++ ":;\nif (!seq && err_seen(e.mem)) { return 0; }\n" ++ nc_body(rest), nt_append(N_Segment, nc_segs(val), nc_segs(rest)), nc_fresh(val), nc_first_error(val, rest)}

@unsafe
def nq_bind_choose(+book: List<&2, KDef>, +value: KTerm, +body: KTerm, +env: List<&2, NC_Binding>, +id: U32, +n: U32, +target: NC_Target) -> NC_Code:
  +shape = nq_value_shape(book, value, target)
  nt_choose(NC_Code, String.eq(tg(shape), "NQShape") && U32.is_eq(nq_uses(body, id), 1), u => nq_bind(book, value, body, env, id, n, target, shape), u => nf_bind_boxed(book, value, body, env, id, n, target))

@unsafe
def nq_bundle_return(+t: KTerm, +env: List<&2, NC_Binding>, +n: U32, +target: NC_Target) -> NC_Code:
  nq_transfer(kt("NQShape", nm(t), terms_len(ks(t)), 0, Nil{}), nc_values(ks(t), env), n, target)

@unsafe
def nq_match(+book: List<&2, KDef>, +t: KTerm, +env: List<&2, NC_Binding>, +n: U32, +target: NC_Target) -> NC_Code:
  nt_choose(NC_Code, nf_scheduler(target), u => nc_match_apply_to(book, t, env, n, target), u => nq_match_local(book, t, env, n, target))

@unsafe
def nq_match_local(+book: List<&2, KDef>, +t: KTerm, +env: List<&2, NC_Binding>, +n: U32, +target: NC_Target) -> NC_Code:
  +mat = kid(t, 0)
  +arg = kid(t, 1)
  nt_choose(NC_Code, String.eq(tg(arg), "NQBundle") && String.eq(nm(mat), nm(arg)) && U32.is_eq(ix(mat), U32.inc(terms_len(ks(arg)))),
    u => nc_lower_to(book, nd_reapply(kid(mat, 0), List.append(&2, KTerm, ks(arg), nd_match_rest(t))), env, n, target),
    u => nt_choose(NC_Code, String.eq(tg(arg), "NQBundle"), v => nq_match_boxed(book, t, env, n, target), v => nc_match_apply_to(book, t, env, n, target)))

@unsafe
def nq_match_boxed(+book: List<&2, KDef>, +t: KTerm, +env: List<&2, NC_Binding>, +n: U32, +target: NC_Target) -> NC_Code:
  +arg = kid(t, 1)
  +body = kt("NMatch", "", 0, 0, Con{kid(t, 0), Con{var("", nc_id(n)), nd_match_rest(t)}})
  nc_lower_to(book, nc_mklet(nc_id(n), kt("NQBox", nm(arg), 0, 0, ks(arg)), body), env, U32.inc(n), target)

@unsafe
def nq_match_args(args: List<&2, KTerm>) -> Bool:
  match args:
    case Nil{}: True{}
    case Con{+h, rest}: (String.eq(tg(h), "Var") || String.eq(tg(h), "NQBundle")) && nq_match_args(rest)

@unsafe
def nq_opaque_args(+tag: String, +name: String, args: List<&2, KTerm>, +done: List<&2, KTerm>, +n: U32) -> KTerm:
  match args:
    case Nil{}: kt(tag, name, 0, 0, List.reverse(&2, KTerm, done))
    case Con{+arg, +rest}:
      nt_choose(KTerm, String.eq(tg(arg), "NQBundle"),
        u => nc_mklet(nc_id(n), kt("NQBox", nm(arg), 0, 0, ks(arg)), nq_opaque_args(tag, name, rest, Con{var("", nc_id(n)), done}, U32.inc(n))),
        u => nq_opaque_args(tag, name, rest, Con{arg, done}, n))

@unsafe
def nq_has_bundle(args: List<&2, KTerm>) -> Bool:
  match args:
    case Nil{}: False{}
    case Con{h, rest}: String.eq(tg(h), "NQBundle") || nq_has_bundle(rest)

@unsafe
def nq_call(+book: List<&2, KDef>, +t: KTerm, +env: List<&2, NC_Binding>, +n: U32, +target: NC_Target) -> NC_Code:
  +info = nq_info(target, nm(t))
  nt_choose(NC_Code, Bool.not(nc_native_def(lookup(book, nm(t)))) && String.eq(tg(dv(info)), "NQSig") && nq_args_fit(ks(dv(info)), ks(t)),
    u => nf_call_local(book, nm(dv(info)), nq_arg_words(ks(dv(info)), ks(t), env), n, target),
    u => nt_choose(NC_Code, nq_has_bundle(ks(t)),
      v => nc_lower_to(book, nq_opaque_args("NFCall", nm(t), ks(t), Nil{}, n), env, U32.add(n, terms_len(ks(t))), target),
      v => nf_call(book, nm(t), nc_values(ks(t), env), n, target)))

@unsafe
def nq_operation(+book: List<&2, KDef>, +t: KTerm, +env: List<&2, NC_Binding>, +n: U32, +target: NC_Target) -> NC_Code:
  nt_choose(NC_Code, Bool.not(nf_scheduler(target)) && nq_has_bundle(ks(t)),
    u => nc_lower_to(book, nq_opaque_args(tg(t), nm(t), ks(t), Nil{}, n), env, U32.add(n, terms_len(ks(t))), target),
    u => nt_choose(NC_Code, String.eq(tg(t), "NCtr"), v => nq_ctor(nm(t), nc_values(ks(t), env), n, target), v => nq_intrinsic(nm(t), nc_values(ks(t), env), n, target)))

@unsafe
def nq_wrap_segment(+d: KDef, +params: List<&2, N_Param>, +original: String) -> String:
  +shape = dt(d)
  +result = nq_transfer(shape, nq_words("nq_result", nq_width(shape), 0), 0, NC_Scheduler{})
  "#if !DEVICE\n{\nTerm nq_result[" ++ U32.show(nq_width(shape)) ++ "];\nif (!" ++ nf_name(nm(dv(d))) ++ "(e, seq, nq_result" ++ nf_arg_c(nf_segment_args(params)) ++ ")) { return 0; }\n" ++ nc_body(result) ++ "}\n#else\n" ++ original ++ "#endif\n"

@unsafe
def nq_args_fit(shapes: List<&2, KTerm>, args: List<&2, KTerm>) -> Bool:
  match shapes, args:
    case Nil{}, Nil{}: True{}
    case Con{+shape, rest}, Con{+arg, more}:
      nt_choose(Bool, String.eq(tg(shape), "NQShape"),
        u => String.eq(tg(arg), "NQBundle") && String.eq(nm(shape), nm(arg)) && U32.is_eq(ix(shape), terms_len(ks(arg))),
        u => String.eq(tg(arg), "Var")) && nq_args_fit(rest, more)
    case _, _: False{}

@unsafe
def nq_arg_words(shapes: List<&2, KTerm>, args: List<&2, KTerm>, +env: List<&2, NC_Binding>) -> List<&2, String>:
  match shapes, args:
    case Con{+shape, rest}, Con{+arg, more}:
      List.append(&2, String, nt_choose(List<&2, String>, String.eq(tg(shape), "NQShape"), u => nc_values(ks(arg), env), u => [nc_word(ix(arg), env)]), nq_arg_words(rest, more, env))
    case _, _: Nil{}

@unsafe
def nq_call_shape(+book: List<&2, KDef>, +name: String, +args: List<&2, KTerm>, +target: NC_Target) -> KTerm:
  +d = lookup(book, name)
  +info = nq_info(target, name)
  nt_choose(KTerm, nc_native_def(d) && nq_pair_primitive(nc_primitive_name(name)), u => kt("NQShape", "Tuple", 2, 0, Nil{}), u =>
    nt_choose(KTerm, String.eq(tg(dv(info)), "NQSig") && nq_args_known(ks(dv(info)), args), u => dt(info), u => atom("Absent")))

@unsafe
def nq_args_known(shapes: List<&2, KTerm>, args: List<&2, KTerm>) -> Bool:
  match shapes, args:
    case Nil{}, Nil{}: True{}
    case Con{+shape, rest}, Con{+arg, more}:
      nt_choose(Bool, String.eq(tg(shape), "NQShape"),
        u => String.eq(tg(arg), "NQBundle") && String.eq(nm(shape), nm(arg)) && U32.is_eq(ix(shape), terms_len(ks(arg))),
        u => True{}) && nq_args_known(rest, more)
    case _, _: False{}

# A neutral source telescope fixes all live parameter and result shapes once.
@unsafe
def nq_tele(+book: List<&2, KDef>, +ty: KTerm, +left: U32, +fuel: U32, +shapes: List<&2, KTerm>) -> KTerm:
  nt_choose(KTerm, U32.is_eq(left, 0), u => kt("NQTele", "", 0, 0, Con{nq_layout(book, ty), List.reverse(&2, KTerm, shapes)}), u =>
    nt_choose(KTerm, U32.is_eq(fuel, 0), u => atom("Absent"), u => nq_tele_head(book, wnf(book, ty), left, fuel, shapes)))

@unsafe
def nq_tele_head(+book: List<&2, KDef>, +head: KTerm, +left: U32, +fuel: U32, +shapes: List<&2, KTerm>) -> KTerm:
  nt_choose(KTerm, String.eq(tg(head), "All"),
    u => nt_choose(KTerm, U32.is_eq(qt(head), 0), v => nq_tele(book, kid(head, 1), left, U32.sub(fuel, 1), shapes), v => nq_tele(book, kid(head, 1), U32.sub(left, 1), U32.sub(fuel, 1), Con{nq_layout(book, kid(head, 0)), shapes})),
    u => atom("Absent"))

@unsafe
def nq_has_shape(shapes: List<&2, KTerm>) -> Bool:
  match shapes:
    case Nil{}: False{}
    case Con{h, rest}: String.eq(tg(h), "NQShape") || nq_has_shape(rest)

@unsafe
def nq_shape_words(shapes: List<&2, KTerm>) -> U32:
  match shapes:
    case Nil{}: 0
    case Con{h, rest}: U32.add(nq_width(h), nq_shape_words(rest))

@unsafe
def nq_signature_def(+book: List<&2, KDef>, +name: String) -> KDef:
  +d = lookup(book, name)
  nt_choose(KDef, String.eq(dk(d), "Def") && Bool.not(nc_foreign(d) || nc_native_def(d)),
    u => nq_signature_user(book, name, d), u => nq_signature_opaque(name))

@unsafe
def nq_signature_opaque(name: String) -> KDef:
  KDef{name, "NQSignature", 0, 0, atom("Absent"), atom("Absent"), Nil{}, False{}, False{}}

@unsafe
def nq_signature_user(+book: List<&2, KDef>, +name: String, +d: KDef) -> KDef:
  +arity = nd_arity(book, name)
  nt_choose(KDef, U32.is_eq(arity, jd_live_arity(book, dt(d), jd_arity(book, d))),
    u => nq_signature_tele(name, arity, nq_tele(book, dt(d), arity, 256, Nil{})), u => nq_signature_opaque(name))

@unsafe
def nq_signature_tele(+name: String, +arity: U32, +tele: KTerm) -> KDef:
  +ok = String.eq(tg(tele), "NQTele") && nq_has_shape(ks(tele)) && U32.is_le(nq_shape_words(nc_tail_terms(ks(tele))), 32)
  KDef{name, "NQSignature", arity, 0, nt_choose(KTerm, ok, u => kid(tele, 0), u => atom("Absent")), nt_choose(KTerm, ok, u => kt("NQSig", "$product." ++ name, 0, 0, nc_tail_terms(ks(tele))), u => atom("Absent")), Nil{}, False{}, False{}}

@unsafe
def nc_tail_terms(ts: List<&2, KTerm>) -> List<&2, KTerm>:
  match ts:
    case Nil{}: Nil{}
    case Con{h, rest}: rest

@unsafe
def nq_signatures(+book: List<&2, KDef>, names: List<&2, String>) -> List<&2, KDef>:
  match names:
    case Nil{}: Nil{}
    case Con{name, rest}: nq_signature_cons(nq_signature_def(book, name), nq_signatures(book, rest))

@unsafe
def nq_signature_cons(+d: KDef, +rest: List<&2, KDef>) -> List<&2, KDef>:
  nt_choose(List<&2, KDef>, String.eq(tg(dv(d)), "NQSig"),
    u => Con{d, Con{KDef{nm(dv(d)), "NQSignature", da(d), 0, dt(d), dv(d), Nil{}, False{}, False{}}, List.append(&2, KDef, nq_constructor_shapes(Con{dt(d), ks(dv(d))}), rest)}}, u => Con{d, rest})

@unsafe
def nq_constructor_shapes(shapes: List<&2, KTerm>) -> List<&2, KDef>:
  match shapes:
    case Nil{}: Nil{}
    case Con{+shape, +rest}:
      nt_choose(List<&2, KDef>, String.eq(tg(shape), "NQShape"),
        u => Con{KDef{"$constructor." ++ nm(shape), "NQConstructor", ix(shape), 0, shape, atom("Absent"), Nil{}, False{}, False{}}, nq_constructor_shapes(rest)},
        u => nq_constructor_shapes(rest))

type NQ_Entry is Data:
  NQ_Entry{+params: List<&2, NC_Binding>, +args: List<&2, KTerm>, +fresh: U32}

@unsafe
def nq_entry(shapes: List<&2, KTerm>, +i: U32, +n: U32) -> NQ_Entry:
  match shapes:
    case Nil{}: NQ_Entry{Nil{}, Nil{}, n}
    case Con{+shape, rest}:
      +params = nt_choose(List<&2, NC_Binding>, String.eq(tg(shape), "NQShape"), u => nq_bundle_params(ix(shape), n), u => [nc_binding(nc_id(i))])
      +arg = nt_choose(KTerm, String.eq(tg(shape), "NQShape"), u => kt("NQBundle", nm(shape), 0, 0, nd_entry_args(params)), u => var("", nc_id(i)))
      nq_entry_cons(params, arg, nq_entry(rest, U32.inc(i), U32.add(n, nt_choose(U32, String.eq(tg(shape), "NQShape"), u => ix(shape), u => 0))))

@unsafe
def nq_entry_cons(params: List<&2, NC_Binding>, arg: KTerm, tail: NQ_Entry) -> NQ_Entry:
  match tail:
    case NQ_Entry{more, args, fresh}: NQ_Entry{List.append(&2, NC_Binding, params, more), Con{arg, args}, fresh}

@unsafe
def nq_candidate(+book: List<&2, KDef>, +name: String, +signatures: List<&2, KDef>, entry: NQ_Entry) -> NF_Worker:
  match entry:
    case NQ_Entry{+params, +args, +fresh}:
      +info = lookup(signatures, name)
      +body = nc_compact(nc_definition(book, lookup(book, name), fresh))
      +route = nm(dv(info))
      +shape = dt(info)
      +code = nc_lower_to(book, nd_reapply(body, args), params, fresh, NC_Destination{nq_words("nf_out", nq_width(shape), 0), shape, "", route, params, True{}, signatures})
      NF_Worker{route, params, code, nc_calls(code), shape}

@unsafe
def nq_candidates(+book: List<&2, KDef>, names: List<&2, String>, +bangs: List<&2, String>, +signatures: List<&2, KDef>) -> List<&2, NF_Worker>:
  match names:
    case Nil{}: Nil{}
    case Con{+name, +rest}:
      +info = lookup(signatures, name)
      nt_choose(List<&2, NF_Worker>, String.eq(tg(dv(info)), "NQSig") && Bool.not(nb_contains(bangs, name)),
        u => Con{nq_candidate(book, name, signatures, nq_entry(ks(dv(info)), 0, da(info))), nq_candidates(book, rest, bangs, signatures)},
        u => nq_candidates(book, rest, bangs, signatures))
