
# Module: src/back/native/observer-emitter.bend:5
type NO_Layout is Data:
  NO_Layout{+key: String, +ctor: String, +storage: String, +width: U32}

# Module: src/back/native/observer-emitter.bend:67
law no_emit:
  for +t: KTerm
  for +env: List<&2, NC_Binding>
  for +params: List<&2, NC_Binding>
  for +layouts: List<&2, NO_Layout>
  for +n: U32
  NC_Code

@unsafe
def no_atom(+t: KTerm, +env: List<&2, NC_Binding>) -> String:
  nt_choose(String, p98_tag_eq(t, "Var"), u => nc_word(ix(t), env), u =>
    nt_choose(String, p98_tag_eq(t, "NWord"), u => nm(t) ++ "ull", u =>
      nt_choose(String, (p98_tag_eq(t, "Ctr") || p98_tag_eq(t, "NCtr")) && List.is_empty(&2, KTerm, ks(t)) && Bool.not(nb_contains(["Succ", "Chr", "U32", "F32", "ALeaf", "ANode"], nm(t))), u => no_immediate_ctor(nc_constructor_value(nm(t), Nil{}, 0)), u => "NATIVE_UNBOUND_VARIABLE")))

# Module: src/back/native/observer-emitter.bend:15
@unsafe
def no_immediate_ctor(emitted: N_Emitted) -> String:
  match emitted:
    case N_Emitted{code, word, next}: nt_choose(String, p88_string_eq(code, ""), u => word, u => "NATIVE_UNBOUND_VARIABLE")

# Module: src/back/native/observer-emitter.bend:20
@unsafe
def no_atoms_valid(ts: List<&2, KTerm>, +env: List<&2, NC_Binding>) -> Bool:
  match ts:
    case Nil{}: True{}
    case Con{h, rest}: Bool.not(p88_string_eq(no_atom(h, env), "NATIVE_UNBOUND_VARIABLE")) && no_atoms_valid(rest, env)

# Module: src/back/native/observer-emitter.bend:26
@unsafe
def no_words(ts: List<&2, KTerm>, +env: List<&2, NC_Binding>) -> List<&2, String>:
  match ts:
    case Nil{}: Nil{}
    case Con{h, rest}: Con{no_atom(h, env), no_words(rest, env)}

# Module: src/back/native/observer-emitter.bend:32
@unsafe
def no_layout(+key: String, layouts: List<&2, NO_Layout>) -> Maybe<&2, NO_Layout>:
  match layouts:
    case Nil{}: None{}
    case Con{+layout, rest}:
      match layout:
        case NO_Layout{name, ctor, storage, width}: nt_choose(Maybe<&2, NO_Layout>, p88_string_eq(key, name), u => Some{layout}, u => no_layout(key, rest))

# Module: src/back/native/observer-emitter.bend:40
@unsafe
def no_layout_valid(+layout: NO_Layout) -> Bool:
  match layout:
    case NO_Layout{key, +ctor, +storage, +width}:
      nt_choose(Bool, p88_string_eq(storage, "Boxed"), u => U32.is_ge(width, 2) && Bool.not(nb_contains(["ALeaf", "ANode", "U32", "F32", "Chr", "Succ", "Zero", "True", "False"], ctor)), u =>
      nt_choose(Bool, p88_string_eq(storage, "Succ"), u => p88_string_eq(ctor, "Succ") && U32.is_eq(width, 1), u =>
      nt_choose(Bool, p88_string_eq(storage, "Char"), u => p88_string_eq(ctor, "Chr") && U32.is_eq(width, 1), u =>
        p88_string_eq(storage, "Nullary") && U32.is_eq(width, 0) && Bool.not(nb_contains(["Succ", "Chr", "U32", "F32", "ALeaf", "ANode"], ctor)))))

# Module: src/back/native/observer-emitter.bend:49
@unsafe
def no_binders_valid(fields: List<&2, KTerm>, +env: List<&2, NC_Binding>) -> Bool:
  match fields:
    case Nil{}: True{}
    case Con{+field, rest}: p98_tag_eq(field, "Var") && p88_string_eq(nc_word(ix(field), env), "NATIVE_UNBOUND_VARIABLE") && no_binders_valid(rest, Con{nc_binding(ix(field)), env})

# Module: src/back/native/observer-emitter.bend:55
@unsafe
def no_bind_fields(fields: List<&2, KTerm>, env: List<&2, NC_Binding>) -> List<&2, NC_Binding>:
  match fields:
    case Nil{}: env
    case Con{field, rest}: no_bind_fields(rest, Con{nc_binding(ix(field)), env})

# Module: src/back/native/observer-emitter.bend:61
@unsafe
def no_field_decls(fields: List<&2, KTerm>, +storage: String, +word: String, +loc: String, +i: U32) -> String:
  match fields:
    case Nil{}: ""
    case Con{field, rest}:
      "Term v_" ++ U32.show(ix(field)) ++ " = " ++ nt_choose(String, p88_string_eq(storage, "Boxed"), u => "e.mem[" ++ loc ++ " + " ++ U32.show(i) ++ "]", u => nt_choose(String, p88_string_eq(storage, "Succ"), v => "(" ++ word ++ " - 1)", v => word)) ++ ";\n" ++ no_field_decls(rest, storage, word, loc, U32.inc(i))

# Module: src/back/native/observer-emitter.bend:76
@unsafe
def no_emit_return(+t: KTerm, +env: List<&2, NC_Binding>, +n: U32) -> NC_Code:
  nt_choose(NC_Code, U32.is_eq(terms_len(ks(t)), 1) && no_atoms_valid(ks(t), env),
    u => NC_Code{nct_leaf("if (!seq && err_seen(e.mem)) { return 0; }\nnf_out[0] = " ++ no_atom(kid(t, 0), env) ++ ";\nreturn 1;\n"), Nil{}, n, "", Nil{}},
    u => nc_fail("observer: invalid immediate return", n))

# Module: src/back/native/observer-emitter.bend:82
@unsafe
def no_emit_loop(+t: KTerm, +env: List<&2, NC_Binding>, +params: List<&2, NC_Binding>, +n: U32) -> NC_Code:
  +words = no_words(ks(t), env)
  nt_choose(NC_Code, U32.is_eq(terms_len(ks(t)), nt_count(NC_Binding, params)) && no_atoms_valid(ks(t), env),
    u => NC_Code{nct_leaf("{\n" ++ nf_self_temps(words, 0) ++ nf_self_moves(params, words, 0) ++ "goto nf_again;\n}\n"), Nil{}, n, "", Nil{}},
    u => nc_fail("observer: invalid self-tail transition", n))

# Module: src/back/native/observer-emitter.bend:89
@unsafe
def no_scalar_value(+value: KTerm, +env: List<&2, NC_Binding>) -> String:
  nt_choose(String, p98_tag_eq(value, "NOp") && nd_scalar_known(nm(value)) && U32.is_eq(terms_len(ks(value)), nc_primitive_arity(nm(value))) && no_atoms_valid(ks(value), env),
    u => nd_scalar_word(nm(value), no_words(ks(value), env)), u => no_atom(value, env))

# Module: src/back/native/observer-emitter.bend:94
@unsafe
def no_emit_let(+t: KTerm, +env: List<&2, NC_Binding>, +params: List<&2, NC_Binding>, +layouts: List<&2, NO_Layout>, +n: U32) -> NC_Code:
  +word = no_scalar_value(kid(t, 0), env)
  nt_choose(NC_Code, U32.is_eq(terms_len(ks(t)), 2) && p88_string_eq(nc_word(ix(t), env), "NATIVE_UNBOUND_VARIABLE") && Bool.not(p88_string_eq(word, "NATIVE_UNBOUND_VARIABLE")),
    u => nc_prepend("Term v_" ++ U32.show(ix(t)) ++ " = " ++ word ++ ";\nif (!seq && err_seen(e.mem)) { return 0; }\n", no_emit(kid(t, 1), Con{nc_binding(ix(t)), env}, params, layouts, n)),
    u => nc_fail("observer: invalid scalar let or unsupported call", n))

# Module: src/back/native/observer-emitter.bend:101
@unsafe
def no_emit_match_layout(+t: KTerm, +env: List<&2, NC_Binding>, +params: List<&2, NC_Binding>, +layouts: List<&2, NO_Layout>, +n: U32, layout: NO_Layout) -> NC_Code:
  match layout:
    case NO_Layout{key, +ctor, +storage, +width}:
      +fields = ks(kid(t, 1))
      +word = no_atom(kid(t, 0), env)
      +loc = "no_loc_" ++ U32.show(n)
      +hit = no_emit(kid(t, 2), no_bind_fields(fields, env), params, layouts, U32.inc(n))
      +miss = no_emit(kid(t, 3), env, params, layouts, nc_fresh(hit))
      +reads = nt_choose(String, p88_string_eq(storage, "Boxed"), u => "Loc " ++ loc ++ " = term_peek(e, " ++ word ++ ");\n", u => "") ++ no_field_decls(fields, storage, word, loc, 0)
      NC_Code{nct_cat(nct_leaf("if (" ++ nc_condition(ctor, word) ++ ") {\n" ++ reads), nct_cat(nc_text(hit), nct_cat(nct_leaf("} else {\n"), nct_cat(nc_text(miss), nct_leaf("}\n"))))), Nil{}, nc_fresh(miss), nc_first_error(hit, miss), List.append(&2, String, nc_calls(hit), nc_calls(miss))}

# Module: src/back/native/observer-emitter.bend:113
@unsafe
def no_emit_match_found(+t: KTerm, +env: List<&2, NC_Binding>, +params: List<&2, NC_Binding>, +layouts: List<&2, NO_Layout>, +n: U32, found: Maybe<&2, NO_Layout>) -> NC_Code:
  match found:
    case None{}: nc_fail("observer: absent read descriptor", n)
    case Some{+layout}:
      match layout:
        case NO_Layout{key, ctor, storage, width}:
          nt_choose(NC_Code, no_layout_valid(layout) && U32.is_eq(terms_len(ks(t)), 4) && p98_tag_eq(kid(t, 0), "Var") && Bool.not(p88_string_eq(no_atom(kid(t, 0), env), "NATIVE_UNBOUND_VARIABLE")) && p98_tag_eq(kid(t, 1), "NO_Fields") && U32.is_eq(terms_len(ks(kid(t, 1))), width) && no_binders_valid(ks(kid(t, 1)), env),
            u => no_emit_match_layout(t, env, params, layouts, n, layout), u => nc_fail("observer: invalid borrowed match", n))

# Module: src/back/native/observer-emitter.bend:123
@unsafe
def no_emit(t, env, params, layouts, n):
  nt_choose(NC_Code, p98_tag_eq(t, "NO_Return"), u => no_emit_return(t, env, n), u =>
  nt_choose(NC_Code, p98_tag_eq(t, "NO_Loop"), u => no_emit_loop(t, env, params, n), u =>
  nt_choose(NC_Code, p98_tag_eq(t, "NO_Let"), u => no_emit_let(t, env, params, layouts, n), u =>
  nt_choose(NC_Code, p98_tag_eq(t, "NO_Match"), u => no_emit_match_found(t, env, params, layouts, n, no_layout(nm(t), layouts)), u =>
    nt_choose(NC_Code, p98_tag_eq(t, "NO_Error") && p88_string_eq(nm(t), "ERR_FIDS") && List.is_empty(&2, KTerm, ks(t)),
      u => NC_Code{nct_leaf("err_post(e.mem, ERR_FIDS); return 0;\n"), Nil{}, n, "", Nil{}}, u => nc_fail("observer: unsupported residual syntax", n))))))
