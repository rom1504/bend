
# Module: src/back/native/product.bend:351
type NQ_Entry is Data:
  NQ_Entry{+params: List<&2, NC_Binding>, +args: List<&2, KTerm>, +fresh: U32}

# Module: src/back/native/product.bend:4
@unsafe
def nc_calls(+code: NC_Code) -> List<&2, String>:
  match code:
    case NC_Code{body, segs, fresh, error, edges}: edges

# Module: src/back/native/product.bend:9
@unsafe
def nq_note_call(code: NC_Code, name: String) -> NC_Code:
  match code:
    case NC_Code{body, segs, fresh, error, edges}: NC_Code{body, segs, fresh, error, Con{name, edges}}

# Module: src/back/native/product.bend:14
@unsafe
def nq_width(+shape: KTerm) -> U32:
  nt_choose(U32, p98_tag_eq(shape, "NQShape"), u => ix(shape), u => 1)

# Module: src/back/native/product.bend:18
@unsafe
def nq_same(+a: KTerm, +b: KTerm) -> Bool:
  p98_tag_eq(a, tg(b)) && p88_string_eq(nm(a), nm(b)) && U32.is_eq(ix(a), ix(b))

# Module: src/back/native/product.bend:22
@unsafe
def nq_words(+base: String, +count: U32, +i: U32) -> List<&2, String>:
  nt_choose(List<&2, String>, U32.is_eq(i, count), u => Nil{}, u => Con{base ++ "[" ++ U32.show(i) ++ "]", nq_words(base, count, U32.inc(i))})

# Module: src/back/native/product.bend:26
@unsafe
def nq_assign(dests: List<&2, String>, words: List<&2, String>) -> String:
  match dests, words:
    case Con{dest, rest}, Con{word, more}: dest ++ " = " ++ word ++ ";\n" ++ nq_assign(rest, more)
    case _, _: ""

# Module: src/back/native/product.bend:41
@unsafe
def nq_box_return(+shape: KTerm, +words: List<&2, String>, +n: U32, +target: NC_Target) -> NC_Code:
  nt_choose(NC_Code, p98_tag_eq(shape, "NQShape"),
    u => nf_emitted(nc_constructor_value(nm(shape), words, n), target),
    u => nt_choose(NC_Code, nf_scheduler(target), v => nc_return(nc_head(words), n), v => nc_fail("flat product: result width mismatch", n)))

# Module: src/back/native/product.bend:47
@unsafe
def nq_ctor(+name: String, +words: List<&2, String>, +n: U32, +target: NC_Target) -> NC_Code:
  match target:
    case NC_Scheduler{}: nf_emitted(nc_constructor_value(name, words, n), target)
    case NC_Destination{dests, +shape, join, owner, params, tail, signatures}:
      nt_choose(NC_Code, p98_tag_eq(shape, "NQShape") && p88_string_eq(nm(shape), name) && U32.is_eq(ix(shape), nt_count(String, words)),
        u => nq_transfer(shape, words, n, target), u => nf_emitted(nc_constructor_value(name, words, n), target))

# Module: src/back/native/product.bend:55
@unsafe
def nq_pair_primitive(+name: String) -> Bool:
  U32.is_ne(nc_atomic(name), 0) || p88_string_eq(name, "array_size") || p88_string_eq(name, "array_clone") || p88_string_eq(name, "array_get") || p88_string_eq(name, "array_swap")

# Module: src/back/native/product.bend:59
@unsafe
def nq_intrinsic(+name: String, +words: List<&2, String>, +n: U32, +target: NC_Target) -> NC_Code:
  match target:
    case NC_Scheduler{}: nf_emitted(nc_intrinsic_value(name, words, n), target)
    case NC_Destination{dests, +shape, join, owner, params, tail, signatures}:
      nt_choose(NC_Code, nq_pair_primitive(name) && p98_tag_eq(shape, "NQShape") && p88_string_eq(nm(shape), "Tuple") && U32.is_eq(ix(shape), 2),
        u => nq_array_pair(name, words, n, target), u => nf_emitted(nc_intrinsic_value(name, words, n), target))

# Module: src/back/native/product.bend:67
@unsafe
def nq_array_pair(+name: String, +words: List<&2, String>, +n: U32, +target: NC_Target) -> NC_Code:
  +a = nc_head(words)
  +i = nc_head(nc_tail(words))
  +v = nc_head(nc_tail(nc_tail(words)))
  +shape = kt("NQShape", "Tuple", 2, 0, Nil{})
  nt_choose(NC_Code, U32.is_ne(nc_atomic(name), 0),
    u => nq_transfer(shape, [a, "array_atomic(e, " ++ a ++ ", " ++ i ++ ", " ++ v ++ ", " ++ nt_choose(String, p88_string_eq(name, "array_atomic_cas"), v => nc_head(nc_tail(nc_tail(nc_tail(words)))), v => "0") ++ ", " ++ U32.show(nc_atomic(name)) ++ ")"], n, target), u =>
  nt_choose(NC_Code, p88_string_eq(name, "array_size"), u => nq_transfer(shape, [a, "(1ull << blk_cls(" ++ a ++ "))"], n, target), u =>
  nt_choose(NC_Code, p88_string_eq(name, "array_clone"), u => nq_transfer(shape, [a, "blk_copy(e, " ++ a ++ ")"], n, target), u =>
  nt_choose(NC_Code, p88_string_eq(name, "array_get"), u => nq_transfer(shape, [a, "native_array_get(e, " ++ a ++ ", " ++ i ++ ")"], n, target), u =>
    nc_prepend("Term old = native_array_swap(e, " ++ a ++ ", " ++ i ++ ", " ++ v ++ ");\n", nq_transfer(shape, [a, "old"], n, target))))))

# Module: src/back/native/product.bend:80
@unsafe
def nq_signature(+target: NC_Target, +name: String) -> KTerm:
  match target:
    case NC_Scheduler{}: {KTerm{"Absent", "", 0, 0, Nil{}, Nil{}, 0, 0} : KTerm}
    case NC_Destination{dests, shape, join, owner, params, tail, +signatures}:
      nt_choose(KTerm, String.starts_with(name, "$product."), u => dt(lookup(signatures, name)), u => {KTerm{"Absent", "", 0, 0, Nil{}, Nil{}, 0, 0} : KTerm})

# Module: src/back/native/product.bend:87
@unsafe
def nq_info(+target: NC_Target, +name: String) -> KDef:
  match target:
    case NC_Scheduler{}: missing()
    case NC_Destination{dests, shape, join, owner, params, tail, +signatures}: lookup(signatures, name)

# Module: src/back/native/product.bend:93
@unsafe
def nq_call_result(+name: String, +words: List<&2, String>, +n: U32, +target: NC_Target) -> NC_Code:
  +shape = nq_signature(target, name)
  +base = "nq_result_" ++ U32.show(n)
  nq_note_call(nc_prepend("Term " ++ base ++ "[" ++ U32.show(nq_width(shape)) ++ "];\nif (!" ++ nf_name(name) ++ "(e, seq, " ++ base ++ nf_arg_c(words) ++ ")) { return 0; }\n" ++ nt_choose(String, p98_tag_eq(shape, "NQShape"), u => nh_cast_words(nm(shape), nq_words(base, nq_width(shape), 0), 0), u => ""), nq_transfer(shape, nq_words(base, nq_width(shape), 0), U32.inc(n), target)), name)

# A virtual bundle has already evaluated fields, each represented by a Var.
# A single-use substitution keeps the existing scalar ownership environment.

# Module: src/back/native/product.bend:101
@unsafe
def nq_uses(+t: KTerm, +id: U32) -> U32:
  nt_choose(U32, p98_tag_eq(t, "Var"), u => nt_bool(U32.is_eq(ix(t), id)), u =>
    nt_choose(U32, p98_tag_eq(t, "Mat") && U32.is_eq(terms_len(ks(t)), 2), u => U32.max(nq_uses(kid(t, 0), id), nq_uses(kid(t, 1), id)), u => nt_choose(U32, p98_tag_eq(t, "NWPattern"), v => nw_uses(ks(t), id), v => nq_uses_list(ks(t), id))))

# Module: src/back/native/product.bend:106
@unsafe
def nq_uses_list(ts: List<&2, KTerm>, +id: U32) -> U32:
  match ts:
    case Nil{}: 0
    case Con{h, rest}: U32.min(2, U32.add(nq_uses(h, id), nq_uses_list(rest, id)))

# Module: src/back/native/product.bend:112
@unsafe
def nq_min_uses(+t: KTerm, +id: U32) -> U32:
  nt_choose(U32, p98_tag_eq(t, "Var"), u => nt_bool(U32.is_eq(ix(t), id)), u =>
    nt_choose(U32, p98_tag_eq(t, "Mat") && U32.is_eq(terms_len(ks(t)), 2), u => U32.min(nq_min_uses(kid(t, 0), id), nq_min_uses(kid(t, 1), id)), u => nt_choose(U32, p98_tag_eq(t, "NWPattern"), v => 0, v => nq_min_uses_list(ks(t), id))))

# Module: src/back/native/product.bend:117
@unsafe
def nq_min_uses_list(ts: List<&2, KTerm>, +id: U32) -> U32:
  match ts:
    case Nil{}: 0
    case Con{h, rest}: U32.min(2, U32.add(nq_min_uses(h, id), nq_min_uses_list(rest, id)))

# Module: src/back/native/product.bend:123
@unsafe
def nq_value_shape(+book: List<&2, KDef>, +value: KTerm, +target: NC_Target) -> KTerm:
  +head = nd_head(value)
  nt_choose(KTerm, p98_tag_eq(value, "NQBundle"), u => kt("NQShape", nm(value), terms_len(ks(value)), 0, Nil{}), u =>
    nt_choose(KTerm, p98_tag_eq(value, "Ctr") || p98_tag_eq(value, "NCtr") || p98_tag_eq(value, "NStatic"), u => nq_ctor_shape(value, target), u =>
    nt_choose(KTerm, p98_tag_eq(head, "Ref") && Bool.not(U32.is_eq(qt(head), 3)) && U32.is_eq(nd_arity(book, nm(head)), terms_len(nd_args(value, Nil{}))), u => nq_call_shape(book, nm(head), nd_args(value, Nil{}), target), u =>
      nt_choose(KTerm, p98_tag_eq(value, "NFCall"), u => nq_call_shape(book, nm(value), ks(value), target), u =>
        nt_choose(KTerm, p98_tag_eq(value, "NOp") && nq_pair_primitive(nm(value)), u => kt("NQShape", "Tuple", 2, 0, Nil{}), u => {KTerm{"Absent", "", 0, 0, Nil{}, Nil{}, 0, 0} : KTerm})))))

# Module: src/back/native/product.bend:132
@unsafe
def nq_ctor_shape(+value: KTerm, +target: NC_Target) -> KTerm:
  +d = nq_info(target, "$constructor." ++ nm(value))
  nt_choose(KTerm, p88_string_eq(dk(d), "NQConstructor") && U32.is_eq(ix(dt(d)), terms_len(ks(value))), u => dt(d), u => {KTerm{"Absent", "", 0, 0, Nil{}, Nil{}, 0, 0} : KTerm})

# Module: src/back/native/product.bend:137
@unsafe
def nq_bundle_params(+count: U32, +n: U32) -> List<&2, NC_Binding>:
  nt_choose(List<&2, NC_Binding>, U32.is_eq(count, 0), u => Nil{}, u => Con{nc_binding(nc_id(n)), nq_bundle_params(U32.sub(count, 1), U32.inc(n))})

# Module: src/back/native/product.bend:141
@unsafe
def nq_declare(words: List<&2, String>) -> String:
  match words:
    case Nil{}: ""
    case Con{word, rest}: "Term " ++ word ++ ";\n" ++ nq_declare(rest)

# Module: src/back/native/product.bend:147
@unsafe
def nq_local(+target: NC_Target, +words: List<&2, String>, +shape: KTerm, +join: String) -> NC_Target:
  match target:
    case NC_Scheduler{}: NC_Scheduler{}
    case NC_Destination{dests, oldshape, label, owner, params, tail, signatures}: NC_Destination{words, shape, join, owner, params, False{}, signatures}

# Module: src/back/native/product.bend:153
@unsafe
def nq_bind(+book: List<&2, KDef>, +value: KTerm, +body: KTerm, +env: List<&2, NC_Binding>, +id: U32, +n: U32, +target: NC_Target, +shape: KTerm) -> NC_Code:
  +params = nq_bundle_params(ix(shape), n)
  +join = "nq_join_" ++ U32.show(n)
  +bundle = kt("NQBundle", nm(shape), 0, 0, nd_entry_args(params))
  +rest = nc_lower_to(book, subst(body, id, bundle), List.append(&2, NC_Binding, nc_live_env(env, body), params), U32.add(n, ix(shape)), target)
  +val = nc_lower_to(book, value, nc_live_env(env, value), nc_fresh(rest), nq_local(target, nc_words(params), shape, join))
  NC_Code{nct_cat(nct_leaf(nc_share_env(env, value, body) ++ nq_declare(nc_words(params)) ++ "{\n"), nct_cat(nc_text(val), nct_cat(nct_leaf("}\n" ++ join ++ ":;\nif (!seq && err_seen(e.mem)) { return 0; }\n"), nc_text(rest)))), nt_append(N_Segment, nc_segs(val), nc_segs(rest)), nc_fresh(val), nc_first_error(val, rest), List.append(&2, String, nc_calls(val), List.append(&2, String, nc_calls(rest), Nil{}))}

# Module: src/back/native/product.bend:162
@unsafe
def nq_bind_choose(+book: List<&2, KDef>, +value: KTerm, +body: KTerm, +env: List<&2, NC_Binding>, +id: U32, +n: U32, +target: NC_Target) -> NC_Code:
  +shape = nq_value_shape(book, value, target)
  nt_choose(NC_Code, p98_tag_eq(shape, "NQShape"),
    u => nt_choose(NC_Code, U32.is_eq(nq_uses(body, id), 1),
      v => nt_choose(NC_Code, U32.is_eq(nq_min_uses(body, id), 1), w => nq_bind(book, value, body, env, id, n, target, shape), w => nf_bind_boxed(book, value, body, env, id, n, target)),
      v => nf_bind_boxed(book, value, body, env, id, n, target)),
    u => nf_bind_boxed(book, value, body, env, id, n, target))

# Module: src/back/native/product.bend:171
@unsafe
def nq_bundle_return(+t: KTerm, +env: List<&2, NC_Binding>, +n: U32, +target: NC_Target) -> NC_Code:
  nq_transfer(kt("NQShape", nm(t), terms_len(ks(t)), 0, Nil{}), nc_values(ks(t), env), n, target)

# Module: src/back/native/product.bend:175
@unsafe
def nq_match(+book: List<&2, KDef>, +t: KTerm, +env: List<&2, NC_Binding>, +n: U32, +target: NC_Target) -> NC_Code:
  nt_choose(NC_Code, nf_scheduler(target), u => nc_match_apply_to(book, t, env, n, target), u => nq_match_local(book, t, env, n, target))

# Module: src/back/native/product.bend:179
@unsafe
def nq_match_local(+book: List<&2, KDef>, +t: KTerm, +env: List<&2, NC_Binding>, +n: U32, +target: NC_Target) -> NC_Code:
  +mat = kid(t, 0)
  +arg = kid(t, 1)
  nt_choose(NC_Code, p98_tag_eq(arg, "NQBundle") && p88_string_eq(nm(mat), nm(arg)) && U32.is_eq(ix(mat), U32.inc(terms_len(ks(arg)))),
    u => nc_lower_to(book, nd_reapply(kid(mat, 0), List.append(&2, KTerm, ks(arg), nd_match_rest(t))), List.append(&2, NC_Binding, nq_remove_fields(env, ks(arg)), nq_field_bindings(ks(arg), env)), n, target),
    u => nt_choose(NC_Code, p98_tag_eq(arg, "NQBundle"), v => nq_match_boxed(book, t, env, n, target), v => nc_match_apply_to(book, t, env, n, target)))

# Module: src/back/native/product.bend:187
@unsafe
def nq_match_boxed(+book: List<&2, KDef>, +t: KTerm, +env: List<&2, NC_Binding>, +n: U32, +target: NC_Target) -> NC_Code:
  +arg = kid(t, 1)
  +body = kt("NMatch", "", 0, 0, Con{kid(t, 0), Con{var("", nc_id(n)), nd_match_rest(t)}})
  nc_lower_to(book, nc_mklet(nc_id(n), kt("NQBox", nm(arg), 0, 0, ks(arg)), body), env, U32.inc(n), target)

# Module: src/back/native/product.bend:193
@unsafe
def nq_remove_fields(env: List<&2, NC_Binding>, fields: List<&2, KTerm>) -> List<&2, NC_Binding>:
  match fields:
    case Nil{}: env
    case Con{field, rest}: nq_remove_fields(nc_remove_env(env, ix(field)), rest)

# Module: src/back/native/product.bend:199
@unsafe
def nq_field_bindings(fields: List<&2, KTerm>, +env: List<&2, NC_Binding>) -> List<&2, NC_Binding>:
  match fields:
    case Nil{}: Nil{}
    case Con{+field, rest}: Con{NC_Binding{ix(field), nc_word(ix(field), env), nk_kind(ix(field), env)}, nq_field_bindings(rest, env)}

# Module: src/back/native/product.bend:205
@unsafe
def nq_match_args(args: List<&2, KTerm>) -> Bool:
  match args:
    case Nil{}: True{}
    case Con{+h, rest}: (p98_tag_eq(h, "Var") || p98_tag_eq(h, "NQBundle")) && nq_match_args(rest)

# Module: src/back/native/product.bend:211
@unsafe
def nq_opaque_args(+tag: String, +name: String, args: List<&2, KTerm>, +done: List<&2, KTerm>, +n: U32) -> KTerm:
  match args:
    case Nil{}: kt(tag, name, 0, 0, List.reverse(&2, KTerm, done))
    case Con{+arg, +rest}:
      nt_choose(KTerm, p98_tag_eq(arg, "NQBundle"),
        u => nc_mklet(nc_id(n), kt("NQBox", nm(arg), 0, 0, ks(arg)), nq_opaque_args(tag, name, rest, Con{var("", nc_id(n)), done}, U32.inc(n))),
        u => nq_opaque_args(tag, name, rest, Con{arg, done}, n))

# Module: src/back/native/product.bend:220
@unsafe
def nq_has_bundle(args: List<&2, KTerm>) -> Bool:
  match args:
    case Nil{}: False{}
    case Con{h, rest}: p98_tag_eq(h, "NQBundle") || nq_has_bundle(rest)

# Module: src/back/native/product.bend:226
@unsafe
def nq_call(+book: List<&2, KDef>, +t: KTerm, +env: List<&2, NC_Binding>, +n: U32, +target: NC_Target) -> NC_Code:
  +info = nq_info(target, nm(t))
  nt_choose(NC_Code, Bool.not(nc_native_def(lookup(book, nm(t)))) && p98_tag_eq(dv(info), "NQSig") && nq_args_fit(ks(dv(info)), ks(t)),
    u => nf_call_local(book, nm(dv(info)), nq_arg_words(ks(dv(info)), ks(t), env), n, target),
    u => nt_choose(NC_Code, nq_has_bundle(ks(t)),
      v => nc_lower_to(book, nq_opaque_args("NFCall", nm(t), ks(t), Nil{}, n), env, U32.add(n, terms_len(ks(t))), target),
      v => nf_call(book, nm(t), nc_values(ks(t), env), n, target)))

# Module: src/back/native/product.bend:235
@unsafe
def nq_operation(+book: List<&2, KDef>, +t: KTerm, +env: List<&2, NC_Binding>, +n: U32, +target: NC_Target) -> NC_Code:
  nt_choose(NC_Code, Bool.not(nf_scheduler(target)) && nq_has_bundle(ks(t)),
    u => nc_lower_to(book, nq_opaque_args(tg(t), nm(t), ks(t), Nil{}, n), env, U32.add(n, terms_len(ks(t))), target),
    u => nt_choose(NC_Code, p98_tag_eq(t, "NCtr"), v => nq_ctor(nm(t), nc_values(ks(t), env), n, target), v => nq_intrinsic(nm(t), nc_values(ks(t), env), n, target)))

# Module: src/back/native/product.bend:241
@unsafe
def nq_wrap_segment(+d: KDef, +params: List<&2, N_Param>, +original: String) -> String:
  +shape = dt(d)
  +result = nq_transfer(shape, nq_words("nq_result", nq_width(shape), 0), 0, NC_Scheduler{})
  "#if !DEVICE\n{\nTerm nq_result[" ++ U32.show(nq_width(shape)) ++ "];\nif (!" ++ nf_name(nm(dv(d))) ++ "(e, seq, nq_result" ++ nf_arg_c(nf_segment_args(params)) ++ ")) { return 0; }\n" ++ nc_body(result) ++ "}\n#else\n" ++ original ++ "#endif\n"

# Module: src/back/native/product.bend:247
@unsafe
def nq_args_fit(shapes: List<&2, KTerm>, args: List<&2, KTerm>) -> Bool:
  match shapes, args:
    case Nil{}, Nil{}: True{}
    case Con{+shape, rest}, Con{+arg, more}:
      nt_choose(Bool, p98_tag_eq(shape, "NQShape"),
        u => p98_tag_eq(arg, "NQBundle") && p88_string_eq(nm(shape), nm(arg)) && U32.is_eq(ix(shape), terms_len(ks(arg))),
        u => p98_tag_eq(arg, "Var")) && nq_args_fit(rest, more)
    case _, _: False{}

# Module: src/back/native/product.bend:257
@unsafe
def nq_arg_words(shapes: List<&2, KTerm>, args: List<&2, KTerm>, +env: List<&2, NC_Binding>) -> List<&2, String>:
  match shapes, args:
    case Con{+shape, rest}, Con{+arg, more}:
      List.append(&2, String, nt_choose(List<&2, String>, p98_tag_eq(shape, "NQShape"), u => nc_values(ks(arg), env), u => [nc_word(ix(arg), env)]), nq_arg_words(rest, more, env))
    case _, _: Nil{}

# Module: src/back/native/product.bend:264
@unsafe
def nq_call_shape(+book: List<&2, KDef>, +name: String, +args: List<&2, KTerm>, +target: NC_Target) -> KTerm:
  +d = lookup(book, name)
  +info = nq_info(target, name)
  nt_choose(KTerm, nc_native_def(d) && nq_pair_primitive(nc_primitive_name(name)), u => kt("NQShape", "Tuple", 2, 0, Nil{}), u =>
    nt_choose(KTerm, p98_tag_eq(dv(info), "NQSig") && nq_args_known(ks(dv(info)), args), u => dt(info), u => {KTerm{"Absent", "", 0, 0, Nil{}, Nil{}, 0, 0} : KTerm}))

# Module: src/back/native/product.bend:271
@unsafe
def nq_args_known(shapes: List<&2, KTerm>, args: List<&2, KTerm>) -> Bool:
  match shapes, args:
    case Nil{}, Nil{}: True{}
    case Con{+shape, rest}, Con{+arg, more}:
      nt_choose(Bool, p98_tag_eq(shape, "NQShape"),
        u => (p98_tag_eq(arg, "NQBundle") || p98_tag_eq(arg, "Ctr") || p98_tag_eq(arg, "NCtr")) && p88_string_eq(nm(shape), nm(arg)) && U32.is_eq(ix(shape), terms_len(ks(arg))),
        u => True{}) && nq_args_known(rest, more)
    case _, _: False{}

# A neutral source telescope fixes all live parameter and result shapes once.

# Module: src/back/native/product.bend:282
@unsafe
def nq_tele(+book: List<&2, KDef>, +ty: KTerm, +left: U32, +fuel: U32, +shapes: List<&2, KTerm>) -> KTerm:
  nt_choose(KTerm, U32.is_eq(left, 0), u => kt("NQTele", "", 0, 0, Con{nq_layout(book, ty), List.reverse(&2, KTerm, shapes)}), u =>
    nt_choose(KTerm, U32.is_eq(fuel, 0), u => {KTerm{"Absent", "", 0, 0, Nil{}, Nil{}, 0, 0} : KTerm}, u => nq_tele_head(book, nq_layout_reduce(ty, 64), left, fuel, shapes)))

# Module: src/back/native/product.bend:287
@unsafe
def nq_tele_head(+book: List<&2, KDef>, +head: KTerm, +left: U32, +fuel: U32, +shapes: List<&2, KTerm>) -> KTerm:
  nt_choose(KTerm, p98_tag_eq(head, "All"),
    u => nt_choose(KTerm, U32.is_eq(qt(head), 0), v => nq_tele(book, kid(head, 1), left, U32.sub(fuel, 1), shapes), v => nq_tele(book, kid(head, 1), U32.sub(left, 1), U32.sub(fuel, 1), Con{nq_layout(book, kid(head, 0)), shapes})),
    u => {KTerm{"Absent", "", 0, 0, Nil{}, Nil{}, 0, 0} : KTerm})

# Module: src/back/native/product.bend:293
@unsafe
def nq_has_shape(shapes: List<&2, KTerm>) -> Bool:
  match shapes:
    case Nil{}: False{}
    case Con{h, rest}: p98_tag_eq(h, "NQShape") || nq_has_shape(rest)

# Module: src/back/native/product.bend:299
@unsafe
def nq_shape_words(shapes: List<&2, KTerm>) -> U32:
  match shapes:
    case Nil{}: 0
    case Con{h, rest}: U32.add(nq_width(h), nq_shape_words(rest))

# Module: src/back/native/product.bend:305
@unsafe
def nq_signature_def(+book: List<&2, KDef>, +name: String) -> KDef:
  +d = lookup(book, name)
  nt_choose(KDef, p88_string_eq(dk(d), "Def") && Bool.not(nc_foreign(d) || nc_native_def(d)),
    u => nq_signature_user(book, name, d), u => nq_signature_opaque(name))

# Module: src/back/native/product.bend:311
@unsafe
def nq_signature_opaque(name: String) -> KDef:
  KDef{name, "NQSignature", 0, 0, {KTerm{"Absent", "", 0, 0, Nil{}, Nil{}, 0, 0} : KTerm}, {KTerm{"Absent", "", 0, 0, Nil{}, Nil{}, 0, 0} : KTerm}, Nil{}, False{}, False{}}

# Module: src/back/native/product.bend:315
@unsafe
def nq_signature_user(+book: List<&2, KDef>, +name: String, +d: KDef) -> KDef:
  +arity = nd_arity(book, name)
  nt_choose(KDef, U32.is_eq(arity, jd_live_arity(book, dt(d), jd_arity(book, d))),
    u => nq_signature_tele(name, arity, nq_tele(book, dt(d), arity, 256, Nil{})), u => nq_signature_opaque(name))

# Module: src/back/native/product.bend:321
@unsafe
def nq_signature_tele(+name: String, +arity: U32, +tele: KTerm) -> KDef:
  +ok = p98_tag_eq(tele, "NQTele") && nq_has_shape(ks(tele)) && U32.is_le(nq_shape_words(nc_tail_terms(ks(tele))), 32)
  KDef{name, "NQSignature", arity, 0, nt_choose(KTerm, ok, u => kid(tele, 0), u => {KTerm{"Absent", "", 0, 0, Nil{}, Nil{}, 0, 0} : KTerm}), nt_choose(KTerm, ok, u => kt("NQSig", "$product." ++ name, 0, 0, nc_tail_terms(ks(tele))), u => {KTerm{"Absent", "", 0, 0, Nil{}, Nil{}, 0, 0} : KTerm}), Nil{}, False{}, False{}}

# Module: src/back/native/product.bend:326
@unsafe
def nc_tail_terms(ts: List<&2, KTerm>) -> List<&2, KTerm>:
  match ts:
    case Nil{}: Nil{}
    case Con{h, rest}: rest

# Module: src/back/native/product.bend:332
@unsafe
def nq_signatures(+book: List<&2, KDef>, names: List<&2, String>) -> List<&2, KDef>:
  match names:
    case Nil{}: Nil{}
    case Con{name, rest}: nq_signature_cons(nq_signature_def(book, name), nq_signatures(book, rest))

# Module: src/back/native/product.bend:338
@unsafe
def nq_signature_cons(+d: KDef, +rest: List<&2, KDef>) -> List<&2, KDef>:
  nt_choose(List<&2, KDef>, p98_tag_eq(dv(d), "NQSig"),
    u => Con{d, Con{KDef{nm(dv(d)), "NQSignature", da(d), 0, dt(d), dv(d), Nil{}, False{}, False{}}, List.append(&2, KDef, nq_constructor_shapes(Con{dt(d), ks(dv(d))}), rest)}}, u => Con{d, rest})

# Module: src/back/native/product.bend:343
@unsafe
def nq_constructor_shapes(shapes: List<&2, KTerm>) -> List<&2, KDef>:
  match shapes:
    case Nil{}: Nil{}
    case Con{+shape, +rest}:
      nt_choose(List<&2, KDef>, p98_tag_eq(shape, "NQShape"),
        u => Con{KDef{"$constructor." ++ nm(shape), "NQConstructor", ix(shape), 0, shape, {KTerm{"Absent", "", 0, 0, Nil{}, Nil{}, 0, 0} : KTerm}, Nil{}, False{}, False{}}, nq_constructor_shapes(rest)},
        u => nq_constructor_shapes(rest))

# Module: src/back/native/product.bend:355
@unsafe
def nq_entry(shapes: List<&2, KTerm>, +i: U32, +n: U32) -> NQ_Entry:
  match shapes:
    case Nil{}: NQ_Entry{Nil{}, Nil{}, n}
    case Con{+shape, rest}:
      +params = nt_choose(List<&2, NC_Binding>, p98_tag_eq(shape, "NQShape"), u => nq_bundle_params(ix(shape), n), u => [nc_binding(nc_id(i))])
      +arg = nt_choose(KTerm, p98_tag_eq(shape, "NQShape"), u => kt("NQBundle", nm(shape), 0, 0, nd_entry_args(params)), u => var("", nc_id(i)))
      nq_entry_cons(params, arg, nq_entry(rest, U32.inc(i), U32.add(n, nt_choose(U32, p98_tag_eq(shape, "NQShape"), u => ix(shape), u => 0))))

# Module: src/back/native/product.bend:364
@unsafe
def nq_entry_cons(params: List<&2, NC_Binding>, arg: KTerm, tail: NQ_Entry) -> NQ_Entry:
  match tail:
    case NQ_Entry{more, args, fresh}: NQ_Entry{List.append(&2, NC_Binding, params, more), Con{arg, args}, fresh}

# Module: src/back/native/product.bend:369
@unsafe
def nq_candidate(+book: List<&2, KDef>, +name: String, +signatures: List<&2, KDef>, entry: NQ_Entry) -> NF_Worker:
  nq_candidate_mode(book, name, signatures, entry, False{})

# Checked private calls enter only with flow-proven, already evaluated bundles.
# No adapter unpacks an unknown boxed parameter. A dropped/shared/opaque bundle
# still materializes through ordinary lowering at its original demand point.
# This permits a flat loop backedge even when its exit drops the product.
# Raw compilation retains the stronger historical prefix-demand admission.

# Module: src/back/native/product.bend:378
@unsafe
def nq_candidate_mode(+book: List<&2, KDef>, +name: String, +signatures: List<&2, KDef>, entry: NQ_Entry, +checked: Bool) -> NF_Worker:
  match entry:
    case NQ_Entry{+params, +args, +fresh}:
      +info = lookup(signatures, name)
      +body = nc_compact_definition(book, lookup(book, name), fresh)
      +route = nm(dv(info))
      +shape = dt(info)
      +code = nt_choose(NC_Code, nt_choose(Bool, checked, u => True{}, u => nq_entry_demand(body, ks(dv(info)), nd_entry_args(nd_entry_params(da(info), 0)), 0)),
        u => nc_lower_to(book, nd_reapply(body, args), params, fresh, NC_Destination{nq_words("nf_out", nq_width(shape), 0), shape, "", route, params, True{}, signatures}),
        u => nc_fail("flat product: parameter may be dropped before matching", fresh))
      NF_Worker{route, nf_typed_params(params, nf_expand_kinds(ks(dv(info)), nf_worker_kinds(book, name, da(info)))), nc_prepend(nh_param_facts(args, params), code), nc_calls(code), shape}

# Every flattened parameter must reach exactly one source use per prefix path.
# All symbolic actuals below are already evaluated values, so beta substitution
# models only the demand of binders, including matcher-raised residual args.

# Module: src/back/native/product.bend:394
@unsafe
def nq_entry_demand(+body: KTerm, shapes: List<&2, KTerm>, +args: List<&2, KTerm>, +i: U32) -> Bool:
  match shapes:
    case Nil{}: True{}
    case Con{shape, rest}:
      nt_choose(Bool, p98_tag_eq(shape, "NQShape"), u => nq_demand(nd_reapply(body, args), nc_id(i), 64), u => True{}) && nq_entry_demand(body, rest, args, U32.inc(i))

# Module: src/back/native/product.bend:401
@unsafe
def nq_demand(+t: KTerm, +id: U32, +fuel: U32) -> Bool:
  nt_choose(Bool, U32.is_eq(fuel, 0), u => False{}, u => nq_demand_head(t, nd_head(t), nd_args(t, Nil{}), id, U32.sub(fuel, 1)))

# Module: src/back/native/product.bend:405
@unsafe
def nq_demand_head(+t: KTerm, +head: KTerm, args: List<&2, KTerm>, +id: U32, +fuel: U32) -> Bool:
  nt_choose(Bool, p98_tag_eq(head, "Efq"), u => False{}, u => nq_demand_args(t, head, args, id, fuel))

# Module: src/back/native/product.bend:409
@unsafe
def nq_demand_args(+t: KTerm, +head: KTerm, args: List<&2, KTerm>, +id: U32, +fuel: U32) -> Bool:
  match args:
    case Con{+arg, +rest}:
      nt_choose(Bool, p98_tag_eq(head, "Lam"), u => nq_demand(nd_reapply(nq_layout_subst(kid(head, 0), ix(head), arg), rest), id, fuel), u =>
        nt_choose(Bool, p98_tag_eq(head, "Mat"), u =>
          nt_choose(Bool, p98_tag_eq(arg, "Var") && U32.is_eq(ix(arg), id), v => U32.is_eq(nq_uses(t, id), 1), v =>
            nt_choose(Bool, U32.is_gt(ix(head), 0) && U32.is_le(ix(head), 33), w =>
              nq_demand(nd_reapply(kid(head, 0), List.append(&2, KTerm, nq_neutral_fields(U32.sub(ix(head), 1)), rest)), id, fuel) && nt_choose(Bool, nq_demand_exhaustive(nm(head), arg), v => True{}, v => nq_demand(nd_reapply(app(kid(head, 1), kt("NQExcluded", nm(head), 0, 0, [arg])), rest), id, fuel)), w => False{})),
          u => U32.is_eq(nq_min_uses(t, id), 1) && U32.is_eq(nq_uses(t, id), 1)))
    case Nil{}: U32.is_eq(nq_min_uses(t, id), 1) && U32.is_eq(nq_uses(t, id), 1)

# Only runtime-unconditional guards and exact complements suppress a miss path.
# This analysis marker never reaches lowering; arbitrary ADT tags stay unknown.

# Module: src/back/native/product.bend:423
@unsafe
def nq_demand_exhaustive(+name: String, +arg: KTerm) -> Bool:
  p88_string_eq(name, "U32") || p88_string_eq(name, "F32") || p88_string_eq(name, "Chr") || (p98_tag_eq(arg, "NQExcluded") && nq_demand_complement(name, nm(arg)))

# Module: src/back/native/product.bend:427
@unsafe
def nq_demand_complement(+a: String, +b: String) -> Bool:
  (p88_string_eq(a, "Zero") && p88_string_eq(b, "Succ")) || (p88_string_eq(a, "Succ") && p88_string_eq(b, "Zero")) || (p88_string_eq(a, "False") && p88_string_eq(b, "True")) || (p88_string_eq(a, "True") && p88_string_eq(b, "False"))

# Module: src/back/native/product.bend:431
@unsafe
def nq_neutral_fields(+count: U32) -> List<&2, KTerm>:
  nt_choose(List<&2, KTerm>, U32.is_eq(count, 0), u => Nil{}, u => Con{{KTerm{"NQNeutral", "", 0, 0, Nil{}, Nil{}, 0, 0} : KTerm}, nq_neutral_fields(U32.sub(count, 1))})

# Module: src/back/native/product.bend:435
@unsafe
def nq_candidates(+book: List<&2, KDef>, names: List<&2, String>, +bangs: List<&2, String>, +signatures: List<&2, KDef>) -> List<&2, NF_Worker>:
  nq_candidates_mode(book, names, bangs, signatures, False{})

# Module: src/back/native/product.bend:439
@unsafe
def nq_candidates_mode(+book: List<&2, KDef>, names: List<&2, String>, +bangs: List<&2, String>, +signatures: List<&2, KDef>, +checked: Bool) -> List<&2, NF_Worker>:
  match names:
    case Nil{}: Nil{}
    case Con{+name, +rest}:
      +info = lookup(signatures, name)
      nt_choose(List<&2, NF_Worker>, p98_tag_eq(dv(info), "NQSig") && Bool.not(nb_contains(bangs, name)),
        u => Con{nq_candidate_mode(book, name, signatures, nq_entry(ks(dv(info)), 0, da(info)), checked), nq_candidates_mode(book, rest, bangs, signatures, checked)},
        u => nq_candidates_mode(book, rest, bangs, signatures, checked))

@unsafe
def nq_transfer(+shape: KTerm, +words: List<&2, String>, +n: U32, +target: NC_Target) -> NC_Code:
  nt_choose(NC_Code, ntr_target(target), u => ntr_transfer(shape, words, n, target), u => ntr_plain_transfer(shape, words, n, target))
