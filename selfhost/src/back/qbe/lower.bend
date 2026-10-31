
law p111_show_nodes:
  for +book: List<&2, KDef>
  for +types: List<&2, KTerm>
  for +i: U32
  for +offset: U32
  for +offsets: List<&2, U32>
  for +cells: List<&2, P111ShowCell>
  P111ShowGraph

law p111_show_field:
  for +book: List<&2, KDef>
  for +tel: KTerm
  for +left: U32
  for +i: U32
  for +d: P111ShowDesc
  P111ShowDesc

law p111_show_arm:
  for +book: List<&2, KDef>
  for +c: KDef
  for +rest: List<&2, KDef>
  for +args: List<&2, KTerm>
  for +d: P111ShowDesc
  P111ShowDesc

@unsafe
def p111_show_ref(+book: List<&2, KDef>, +ty: KTerm, +types: List<&2, KTerm>) -> P111ShowDesc:
  +id = nc_show_find(book, ty, types, 0)
  nt_choose(P111ShowDesc, U32.is_eq(id, 4294967295),
    u => P111ShowDesc{[P111ShowRef{terms_len(types)}], List.append(&2, KTerm, types, [ty]), ""},
    u => P111ShowDesc{[P111ShowRef{id}], types, ""})

@unsafe
def p111_show_cells(d: P111ShowDesc) -> List<&2, P111ShowCell>:
  match d:
    case P111ShowDesc{cells, types, error}: cells

@unsafe
def p111_show_types(d: P111ShowDesc) -> List<&2, KTerm>:
  match d:
    case P111ShowDesc{cells, types, error}: types

@unsafe
def p111_show_error(d: P111ShowDesc) -> String:
  match d:
    case P111ShowDesc{cells, types, error}: error

@unsafe
def p111_show_join(+a: P111ShowDesc, +b: P111ShowDesc) -> P111ShowDesc:
  P111ShowDesc{List.append(&2, P111ShowCell, p111_show_cells(a), p111_show_cells(b)), p111_show_types(b),
    nt_choose(String, String.eq(p111_show_error(a), ""), u => p111_show_error(b), u => p111_show_error(a))}

@unsafe
def p111_show_fields(+book: List<&2, KDef>, +tel: KTerm, +left: U32, +i: U32, +types: List<&2, KTerm>) -> P111ShowDesc:
  nt_choose(P111ShowDesc, U32.is_eq(left, 0), u => P111ShowDesc{Nil{}, types, ""}, u =>
    nt_choose(P111ShowDesc, U32.is_eq(qt(wnf(book, tel)), 0), u => P111ShowDesc{Nil{}, types, "native readback cannot print an erased field"}, u =>
      p111_show_field(book, wnf(book, tel), left, i, p111_show_ref(book, kid(wnf(book, tel), 0), types))))

@unsafe
def p111_show_field(book, tel, left, i, d):
  p111_show_join(P111ShowDesc{Con{P111ShowWord{i}, p111_show_cells(d)}, p111_show_types(d), p111_show_error(d)},
    p111_show_fields(book, kid(tel, 1), U32.sub(left, 1), U32.inc(i), p111_show_types(d)))

@unsafe
def p111_show_arms(+book: List<&2, KDef>, +cs: List<&2, KDef>, +args: List<&2, KTerm>, +types: List<&2, KTerm>) -> P111ShowDesc:
  match cs:
    case Nil{}: P111ShowDesc{Nil{}, types, ""}
    case Con{+c, rest}: p111_show_arm(book, c, rest, args, p111_show_fields(book, nc_tele_fill(book, dt(c), args), da(c), 0, types))

@unsafe
def p111_show_arm(book, c, rest, args, d):
  p111_show_join(P111ShowDesc{Con{P111ShowCtor{nc_ctor_identity(book, dn(c))},
    Con{P111ShowCtor{nc_ctor_identity(book, dn(c))}, Con{P111ShowWord{da(c)}, p111_show_cells(d)}}},
    p111_show_types(d), p111_show_error(d)}, p111_show_arms(book, rest, args, p111_show_types(d)))

@unsafe
def p111_show_data(+book: List<&2, KDef>, +ty: KTerm, +types: List<&2, KTerm>) -> P111ShowDesc:
  +cs = dc(lookup(book, nm(ty)))
  +d = p111_show_arms(book, cs, ks(ty), types)
  P111ShowDesc{Con{P111ShowWord{7}, Con{P111ShowWord{1}, Con{P111ShowWord{nt_count(KDef, cs)}, p111_show_cells(d)}}}, p111_show_types(d), p111_show_error(d)}

@unsafe
def p111_show_array(+d: P111ShowDesc) -> P111ShowDesc:
  P111ShowDesc{Con{P111ShowWord{6}, List.append(&2, P111ShowCell, p111_show_cells(d), [P111ShowWord{0}])}, p111_show_types(d), p111_show_error(d)}

@unsafe
def p111_show_node(+book: List<&2, KDef>, +ty: KTerm, +types: List<&2, KTerm>) -> P111ShowDesc:
  +k = nt_choose(String, db(lookup(book, nm(ty))), u => nm(ty), u => "")
  nt_choose(P111ShowDesc, String.eq(k, "U32"), u => P111ShowDesc{[P111ShowWord{0}], types, ""}, u =>
  nt_choose(P111ShowDesc, String.eq(k, "F32"), u => P111ShowDesc{[P111ShowWord{1}], types, ""}, u =>
  nt_choose(P111ShowDesc, String.eq(k, "Nat"), u => P111ShowDesc{[P111ShowWord{2}], types, ""}, u =>
  nt_choose(P111ShowDesc, String.eq(k, "Char"), u => P111ShowDesc{[P111ShowWord{3}, P111ShowWord{0}], types, ""}, u =>
  nt_choose(P111ShowDesc, String.eq(k, "String"), u => P111ShowDesc{[P111ShowWord{4}], types, ""}, u =>
  nt_choose(P111ShowDesc, String.eq(k, "Bool"), u => P111ShowDesc{[P111ShowWord{7}, P111ShowWord{0}, P111ShowWord{2}, P111ShowCtor{"False"}, P111ShowCtor{"False"}, P111ShowWord{0}, P111ShowCtor{"True"}, P111ShowCtor{"True"}, P111ShowWord{0}], types, ""}, u =>
  nt_choose(P111ShowDesc, String.eq(tg(ty), "Eql"), u => P111ShowDesc{[P111ShowWord{5}], types, ""}, u =>
  nt_choose(P111ShowDesc, String.eq(k, "Array"), u => p111_show_array(p111_show_ref(book, kid(ty, 0), types)), u =>
  nt_choose(P111ShowDesc, String.eq(tg(ty), "ADT") && String.eq(dk(lookup(book, nm(ty))), "ADT") && Bool.not(String.eq(k, "IO.OP")), u => p111_show_data(book, ty, types), u =>
    P111ShowDesc{Nil{}, types, "native readback cannot print a function, type, or dependent field"})))))))))

@unsafe
def p111_show_step(+book: List<&2, KDef>, +i: U32, +offset: U32, +offsets: List<&2, U32>, +cells: List<&2, P111ShowCell>, +d: P111ShowDesc) -> P111ShowGraph:
  +next = U32.add(offset, nt_count(P111ShowCell, p111_show_cells(d)))
  nt_choose(P111ShowGraph, String.eq(p111_show_error(d), ""),
    u =>
    nt_choose(P111ShowGraph, U32.is_lt(next, offset), u => P111ShowGraph{Nil{}, Nil{}, "native readback descriptor offset overflow"}, u =>
      p111_show_nodes(book, p111_show_types(d), U32.inc(i), next, List.append(&2, U32, offsets, [offset]), List.append(&2, P111ShowCell, cells, p111_show_cells(d)))), u => P111ShowGraph{Nil{}, Nil{}, p111_show_error(d)})

@unsafe
def p111_show_nodes(book, types, i, offset, offsets, cells):
  nt_choose(P111ShowGraph, U32.is_eq(i, terms_len(types)), u => P111ShowGraph{cells, offsets, ""}, u =>
    nt_choose(P111ShowGraph, U32.is_gt(i, 4096), u => P111ShowGraph{Nil{}, Nil{}, "native readback type graph exceeds 4096 nodes"}, u =>
      p111_show_step(book, i, offset, offsets, cells, p111_show_node(book, wnf(book, terms_at(types, i)), types))))

@unsafe
def p111_show_ctor_id(+name: String, constructors: List<&2, N_Constructor>, +i: U32) -> U32:
  match constructors:
    case Nil{}: 4294967295
    case Con{N_Constructor{key, arity, hot}, +rest}:
      nt_choose(U32, String.eq(name, key), u => i, u => p111_show_ctor_id(name, rest, U32.inc(i)))

@unsafe
def p111_show_offset(offsets: List<&2, U32>, +i: U32) -> U32:
  match offsets:
    case Nil{}: 4294967295
    case Con{+head, +rest}: nt_choose(U32, U32.is_eq(i, 0), u => head, u => p111_show_offset(rest, U32.sub(i, 1)))

@unsafe
def p111_show_resolved(+value: U32, +error: String) -> P111ShowWords:
  nt_choose(P111ShowWords, U32.is_eq(value, 4294967295), u => P111ShowWords{Nil{}, error}, u => P111ShowWords{[value], ""})

@unsafe
def p111_show_resolve(cell: P111ShowCell, +offsets: List<&2, U32>, +constructors: List<&2, N_Constructor>) -> P111ShowWords:
  match cell:
    case P111ShowWord{value}: P111ShowWords{[value], ""}
    case P111ShowRef{index}: p111_show_resolved(p111_show_offset(offsets, index), "native readback unresolved type reference")
    case P111ShowCtor{name}: p111_show_resolved(p111_show_ctor_id(name, constructors, 0), "native readback unresolved constructor identity")

@unsafe
def p111_show_words_join(a: P111ShowWords, b: P111ShowWords) -> P111ShowWords:
  match a b:
    case P111ShowWords{first, +error_a} P111ShowWords{second, +error_b}:
      P111ShowWords{List.append(&2, U32, first, second), nt_choose(String, String.eq(error_a, ""), u => error_b, u => error_a)}

@unsafe
def p111_show_resolve_all(cells: List<&2, P111ShowCell>, +offsets: List<&2, U32>, +constructors: List<&2, N_Constructor>) -> P111ShowWords:
  match cells:
    case Nil{}: P111ShowWords{Nil{}, ""}
    case Con{head, rest}: p111_show_words_join(p111_show_resolve(head, offsets, constructors), p111_show_resolve_all(rest, offsets, constructors))

@unsafe
def p111_show_names(constructors: List<&2, N_Constructor>) -> List<&2, String>:
  match constructors:
    case Nil{}: Nil{}
    case Con{N_Constructor{name, arity, hot}, rest}: Con{name_key(nc_ctor_display(name)), p111_show_names(rest)}

@unsafe
def p111_show_finish_words(names: List<&2, String>, words: P111ShowWords) -> P111Show:
  match words:
    case P111ShowWords{values, error}: P111Show{values, names, error}

@unsafe
def p111_show_finish(+constructors: List<&2, N_Constructor>, graph: P111ShowGraph) -> P111Show:
  match graph:
    case P111ShowGraph{+cells, +offsets, +error}:
      nt_choose(P111Show, String.eq(error, ""),
        u => p111_show_finish_words(p111_show_names(constructors), p111_show_resolve_all(cells, offsets, constructors)),
        u => P111Show{Nil{}, Nil{}, error})

@unsafe
def p111_show(+book: List<&2, KDef>, ty: KTerm, constructors: List<&2, N_Constructor>) -> P111Show:
  p111_show_finish(constructors, p111_show_nodes(book, [ty], 0, 0, Nil{}, Nil{}))


# Phase111 module: selfhost/tools/performance/phase111/segment/lower-catalogue.bend
# Finite authenticated runtime primitive catalogue. No C templates are read.
@unsafe
def p111_op_id(+name: String) -> U32:
  nt_choose(U32, String.eq(name, "u32_add"), u => 1, u =>
  nt_choose(U32, String.eq(name, "u32_sub"), u => 2, u =>
  nt_choose(U32, String.eq(name, "u32_and"), u => 3, u =>
  nt_choose(U32, String.eq(name, "u32_or"), u => 4, u =>
  nt_choose(U32, String.eq(name, "u32_xor"), u => 5, u =>
  nt_choose(U32, String.eq(name, "u32_mul"), u => 6, u =>
  nt_choose(U32, String.eq(name, "u32_is_eq"), u => 7, u =>
  nt_choose(U32, String.eq(name, "u32_is_ne"), u => 8, u =>
  nt_choose(U32, String.eq(name, "u32_is_lt"), u => 9, u =>
  nt_choose(U32, String.eq(name, "u32_is_le"), u => 10, u =>
  nt_choose(U32, String.eq(name, "u32_is_gt"), u => 11, u =>
  nt_choose(U32, String.eq(name, "u32_is_ge"), u => 12, u =>
  nt_choose(U32, String.eq(name, "u32_inc"), u => 13, u =>
  nt_choose(U32, String.eq(name, "u32_shl"), u => 14, u =>
  nt_choose(U32, String.eq(name, "u32_shr"), u => 15, u =>
  nt_choose(U32, String.eq(name, "u32_shln"), u => 16, u =>
  nt_choose(U32, String.eq(name, "u32_shrn"), u => 17, u =>
  nt_choose(U32, String.eq(name, "u32_div"), u => 18, u =>
  nt_choose(U32, String.eq(name, "u32_mod"), u => 19, u =>
  nt_choose(U32, String.eq(name, "u32_not"), u => 20, u =>
  nt_choose(U32, String.eq(name, "u32_is_zero"), u => 21, u =>
  nt_choose(U32, String.eq(name, "u32_cmp"), u => 22, u =>
  nt_choose(U32, String.eq(name, "u32_to_f32"), u => 23, u =>
  nt_choose(U32, String.eq(name, "u32_to_nat"), u => 24, u =>
  nt_choose(U32, String.eq(name, "u32_from_nat"), u => 25, u =>
  nt_choose(U32, String.eq(name, "f32_add"), u => 26, u =>
  nt_choose(U32, String.eq(name, "f32_sub"), u => 27, u =>
  nt_choose(U32, String.eq(name, "f32_mul"), u => 28, u =>
  nt_choose(U32, String.eq(name, "f32_div"), u => 29, u =>
  nt_choose(U32, String.eq(name, "f32_is_eq"), u => 30, u =>
  nt_choose(U32, String.eq(name, "f32_is_ne"), u => 31, u =>
  nt_choose(U32, String.eq(name, "f32_is_lt"), u => 32, u =>
  nt_choose(U32, String.eq(name, "f32_is_le"), u => 33, u =>
  nt_choose(U32, String.eq(name, "f32_is_gt"), u => 34, u =>
  nt_choose(U32, String.eq(name, "f32_is_ge"), u => 35, u =>
  nt_choose(U32, String.eq(name, "f32_sqrt"), u => 36, u =>
  nt_choose(U32, String.eq(name, "f32_exp"), u => 37, u =>
  nt_choose(U32, String.eq(name, "f32_log"), u => 38, u =>
  nt_choose(U32, String.eq(name, "f32_log2"), u => 39, u =>
  nt_choose(U32, String.eq(name, "f32_log10"), u => 40, u =>
  nt_choose(U32, String.eq(name, "f32_sin"), u => 41, u =>
  nt_choose(U32, String.eq(name, "f32_cos"), u => 42, u =>
  nt_choose(U32, String.eq(name, "f32_tan"), u => 43, u =>
  nt_choose(U32, String.eq(name, "f32_asin"), u => 44, u =>
  nt_choose(U32, String.eq(name, "f32_acos"), u => 45, u =>
  nt_choose(U32, String.eq(name, "f32_atan"), u => 46, u =>
  nt_choose(U32, String.eq(name, "f32_sinh"), u => 47, u =>
  nt_choose(U32, String.eq(name, "f32_cosh"), u => 48, u =>
  nt_choose(U32, String.eq(name, "f32_tanh"), u => 49, u =>
  nt_choose(U32, String.eq(name, "f32_floor"), u => 50, u =>
  nt_choose(U32, String.eq(name, "f32_ceil"), u => 51, u =>
  nt_choose(U32, String.eq(name, "f32_trunc"), u => 52, u =>
  nt_choose(U32, String.eq(name, "f32_abs"), u => 53, u =>
  nt_choose(U32, String.eq(name, "f32_pow"), u => 54, u =>
  nt_choose(U32, String.eq(name, "f32_atan2"), u => 55, u =>
  nt_choose(U32, String.eq(name, "f32_mod"), u => 56, u =>
  nt_choose(U32, String.eq(name, "f32_neg"), u => 57, u =>
  nt_choose(U32, String.eq(name, "f32_to_u32"), u => 58, u =>
  nt_choose(U32, String.eq(name, "f32_bits"), u => 59, u =>
  nt_choose(U32, String.eq(name, "f32_show"), u => 60, u =>
  nt_choose(U32, String.eq(name, "f32_read"), u => 61, u =>
  nt_choose(U32, String.eq(name, "nat_add"), u => 62, u =>
  nt_choose(U32, String.eq(name, "nat_sub"), u => 63, u =>
  nt_choose(U32, String.eq(name, "nat_mul"), u => 64, u =>
  nt_choose(U32, String.eq(name, "nat_double"), u => 65, u =>
  nt_choose(U32, String.eq(name, "nat_cmp"), u => 66, u =>
  nt_choose(U32, String.eq(name, "nat_is_lt"), u => 67, u =>
  nt_choose(U32, String.eq(name, "bool_or"), u => 68, u =>
  nt_choose(U32, String.eq(name, "bool_xor"), u => 69, u =>
  nt_choose(U32, String.eq(name, "nat_divmod"), u => 70, u =>
  nt_choose(U32, String.eq(name, "array_new"), u => 71, u =>
  nt_choose(U32, String.eq(name, "array_get"), u => 72, u =>
  nt_choose(U32, String.eq(name, "array_set"), u => 73, u =>
  nt_choose(U32, String.eq(name, "array_swap"), u => 74, u =>
  nt_choose(U32, String.eq(name, "array_size"), u => 75, u =>
  nt_choose(U32, String.eq(name, "array_clone"), u => 76, u =>
  nt_choose(U32, String.eq(name, "array_atomic_add"), u => 77, u =>
  nt_choose(U32, String.eq(name, "array_atomic_min"), u => 78, u =>
  nt_choose(U32, String.eq(name, "array_atomic_max"), u => 79, u =>
  nt_choose(U32, String.eq(name, "array_atomic_and"), u => 80, u =>
  nt_choose(U32, String.eq(name, "array_atomic_or"), u => 81, u =>
  nt_choose(U32, String.eq(name, "array_atomic_xor"), u => 82, u =>
  nt_choose(U32, String.eq(name, "array_atomic_exch"), u => 83, u =>
  nt_choose(U32, String.eq(name, "array_atomic_cas"), u => 84, u =>
  nt_choose(U32, String.eq(name, "array_atomic_fadd"), u => 85, u =>
    0)))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))

@unsafe
def p111_special(+name: String) -> U32:
  nt_choose(U32, String.eq(name, "False"), u => 1, u =>
  nt_choose(U32, String.eq(name, "True"), u => 2, u =>
  nt_choose(U32, String.eq(name, "Zero"), u => 3, u =>
  nt_choose(U32, String.eq(name, "Succ"), u => 4, u =>
  nt_choose(U32, String.eq(name, "Chr"), u => 5, u =>
  nt_choose(U32, String.eq(name, "U32"), u => 6, u =>
  nt_choose(U32, String.eq(name, "F32"), u => 7, u =>
  nt_choose(U32, String.eq(name, "ALeaf"), u => 8, u =>
  nt_choose(U32, String.eq(name, "ANode"), u => 9, u =>
    0)))))))))


# Phase111 module: selfhost/tools/performance/phase111/segment/lower-helpers.bend
# Structured counterparts of the mature generic bridge utilities.
@unsafe
def p111_body(+code: P111Code) -> List<&2, N111Stmt>:
  match code:
    case P111Code{+body, +segments, +fresh, +error}: body

@unsafe
def p111_segments(+code: P111Code) -> List<&2, N111Segment>:
  match code:
    case P111Code{+body, +segments, +fresh, +error}: segments

@unsafe
def p111_fresh(+code: P111Code) -> U32:
  match code:
    case P111Code{+body, +segments, +fresh, +error}: fresh

@unsafe
def p111_error(+code: P111Code) -> String:
  match code:
    case P111Code{+body, +segments, +fresh, +error}: error

@unsafe
def p111_first(+a: String, +b: String) -> String:
  nt_choose(String, String.eq(a, ""), u => b, u => a)

@unsafe
def p111_prepend(prefix: List<&2, N111Stmt>, code: P111Code) -> P111Code:
  match code:
    case P111Code{+body, +segments, +fresh, +error}: P111Code{nt_append(N111Stmt, prefix, body), segments, fresh, error}

@unsafe
def p111_fail(+error: String, +n: U32) -> P111Code:
  P111Code{Nil{}, Nil{}, n, error}

@unsafe
def p111_state() -> N111Arg:
  N111Arg{N111Ptr{}, N111Local{"state"}}

@unsafe
def p111_u32(+value: U32) -> N111Arg:
  N111Arg{N111U32{}, N111Const{value, 0}}

@unsafe
def p111_word(+value: N111Value) -> N111Arg:
  N111Arg{N111U64{}, value}

@unsafe
def p111_scratch() -> N111Arg:
  N111Arg{N111Ptr{}, N111Local{"scratch"}}

@unsafe
def p111_env_words(env: List<&2, NC_Binding>) -> List<&2, N111Value>:
  match env:
    case Nil{}: Nil{}
    case Con{NC_Binding{+id, +word, +kind}, +rest}: Con{N111Local{word}, p111_env_words(rest)}

@unsafe
def p111_values(args: List<&2, KTerm>, +env: List<&2, NC_Binding>) -> List<&2, N111Value>:
  match args:
    case Nil{}: Nil{}
    case Con{+h, +rest}: Con{N111Local{nc_word(ix(h), env)}, p111_values(rest, env)}

@unsafe
def p111_head(values: List<&2, N111Value>) -> N111Value:
  match values:
    case Nil{}: N111Const{0, 0}
    case Con{+head, +rest}: head

@unsafe
def p111_tail(values: List<&2, N111Value>) -> List<&2, N111Value>:
  match values:
    case Nil{}: Nil{}
    case Con{+head, +rest}: rest

@unsafe
def p111_store(values: List<&2, N111Value>, +index: U32) -> List<&2, N111Stmt>:
  match values:
    case Nil{}: Nil{}
    case Con{+head, +rest}: Con{N111Store{N111U64{}, N111Local{"scratch"}, U32.mul(index, 8), head}, p111_store(rest, U32.inc(index))}

@unsafe
def p111_return(+value: N111Value, +n: U32) -> P111Code:
  P111Code{[N111Store{N111U64{}, N111Local{"scratch"}, 0, value}, N111Call{"reply", N111U64{}, "p111_rt_return", [p111_state(), p111_scratch(), p111_u32(1)]}, N111Return{N111Local{"reply"}}], Nil{}, n, ""}

@unsafe
def p111_jump(+name: String, +values: List<&2, N111Value>, +n: U32) -> P111Code:
  P111Code{nt_append(N111Stmt, p111_store(values, 0), [N111Call{"reply", N111U64{}, "p111_rt_jump", [p111_state(), N111Arg{N111U32{}, N111FuncId{name}}, p111_scratch(), p111_u32(nt_count(N111Value, values))]}, N111Return{N111Local{"reply"}}]), Nil{}, n, ""}

@unsafe
def p111_partition_step(+id: U32, +word: String, +kind: N_WordKind, +used: Bool, parts: P111Partition) -> P111Partition:
  match parts:
    case P111Partition{+live, +drop}:
      nt_choose(P111Partition, used, u => P111Partition{Con{NC_Binding{id, word, kind}, live}, drop}, u => nt_choose(P111Partition, p112to_nonowning(kind), v => P111Partition{live, drop}, v => P111Partition{live, Con{N111Call{"ignored", N111U64{}, "p111_rt_sink", [p111_state(), p111_word(N111Local{word})]}, drop}}))

@unsafe
def p111_partition(env: List<&2, NC_Binding>, +uses: NU_Set) -> P111Partition:
  match env:
    case Nil{}: P111Partition{Nil{}, Nil{}}
    case Con{NC_Binding{+id, +word, +kind}, +rest}: p111_partition_step(id, word, kind, nc_uses_has(uses, id), p111_partition(rest, uses))

@unsafe
def p111_keep(env: List<&2, NC_Binding>, +uses: NU_Set) -> List<&2, N111Stmt>:
  match env:
    case Nil{}: Nil{}
    case Con{NC_Binding{+id, +word, +kind}, +rest}:
      nt_choose(List<&2, N111Stmt>, nc_uses_has(uses, id) && Bool.not(p112to_nonowning(kind)), u => Con{N111Call{word, N111U64{}, "p111_rt_keep", [p111_state(), p111_word(N111Local{word})]}, p111_keep(rest, uses)}, u => p111_keep(rest, uses))

@unsafe
def p111_name(+n: U32) -> String:
  "$p111.k." ++ U32.show(n)

@unsafe
def p111_params(params: List<&2, NC_Binding>, +held: U32, +capture: U32, +reg: U32) -> List<&2, N111Stmt>:
  match params:
    case Nil{}: Nil{}
    case Con{NC_Binding{+id, +word, +kind}, +rest}:
      nt_choose(List<&2, N111Stmt>, U32.is_lt(capture, held),
        u => Con{N111Call{word, N111U64{}, "p111_rt_stack_get", [p111_state(), p111_u32(capture)]}, p111_params(rest, held, U32.inc(capture), reg)},
        u => Con{N111Call{word, N111U64{}, "p111_rt_reg_get", [p111_state(), p111_u32(reg)]}, p111_params(rest, held, capture, U32.inc(reg))})

@unsafe
def p111_segment(+name: String, +params: List<&2, NC_Binding>, +held: U32, +incoming: U32, +body: List<&2, N111Stmt>) -> N111Segment:
  +start = nt_choose(List<&2, N111Stmt>, U32.is_eq(held, 0), u => Nil{}, u => [N111Call{"ignored", N111U64{}, "p111_rt_stack_pop", [p111_state(), p111_u32(held)]}])
  N111Segment{name, nt_count(NC_Binding, params), 1, incoming, 0, Con{N111Alloca{"scratch", 2048, 8}, nt_append(N111Stmt, start, nt_append(N111Stmt, p111_params(params, held, 0, 0), body))}}

@unsafe
def p111_frame(+held: List<&2, NC_Binding>, +next: String) -> List<&2, N111Stmt>:
  nt_append(N111Stmt, p111_store(p111_env_words(held), 0), [N111Call{"ignored", N111U64{}, "p111_rt_frame", [p111_state(), N111Arg{N111U32{}, N111FuncId{next}}, p111_scratch(), p111_u32(nt_count(NC_Binding, held))]}])

@unsafe
def p111_uint(parsed: Maybe<&2, U32>) -> P111ValueCode:
  match parsed:
    case None{}: P111ValueCode{Nil{}, N111Const{0, 0}, "invalid native U32 literal"}
    case Some{+value}: P111ValueCode{Nil{}, N111Const{value, 0}, ""}

@unsafe
def p111_value_return(value: P111ValueCode, +n: U32) -> P111Code:
  match value:
    case P111ValueCode{+body, +word, +error}:
      nt_choose(P111Code, String.eq(error, ""), u => p111_prepend(body, p111_return(word, n)), u => p111_fail(error, n))


# Phase111 module: selfhost/tools/performance/phase111/segment/lower-value.bend
# Native special constructors and primitive calls remain ordered operations.
@unsafe
def p111_constructor(name: String, values: List<&2,N111Value>) -> P111ValueCode:
  p114p_constructor(name,values)

@unsafe
def p111_intrinsic(+name: String, +values: List<&2, N111Value>) -> P111ValueCode:
  p112_intrinsic(name, values)

@unsafe
def p111_value(+t: KTerm, +env: List<&2, NC_Binding>) -> P111ValueCode:
  nt_choose(P111ValueCode, String.eq(tg(t), "Var"), u => P111ValueCode{Nil{}, N111Local{nc_word(ix(t), env)}, ""}, u =>
  nt_choose(P111ValueCode, String.eq(tg(t), "NWord"), u => p111_uint(U32.read(nm(t))), u =>
  nt_choose(P111ValueCode, String.eq(tg(t), "NCtr"), u => p111_constructor(nm(t), p111_values(ks(t), env)), u =>
  nt_choose(P111ValueCode, String.eq(tg(t), "NOp"), u => p111_intrinsic(nm(t), p111_values(ks(t), env)), u =>
    P111ValueCode{Nil{}, N111Const{0, 0}, "not a native evaluated value"}))))

@unsafe
def p111_load_fields(+count: U32, +i: U32, +n: U32) -> List<&2, N111Stmt>:
  nt_choose(List<&2, N111Stmt>, U32.is_eq(count, i), u => Nil{},
    u => Con{N111Load{"v_" ++ U32.show(nc_id(U32.add(n, i))), N111U64{}, N111Local{"scratch"}, U32.mul(i, 8)}, p111_load_fields(count, U32.inc(i), n)})

@unsafe
def p111_field_env(+count: U32, +i: U32, +n: U32) -> List<&2, NC_Binding>:
  nt_choose(List<&2, NC_Binding>, U32.is_eq(count, i), u => Nil{}, u => Con{nc_binding(nc_id(U32.add(n, i))), p111_field_env(count, U32.inc(i), n)})

@unsafe
def p111_take(+name: String, +word: N111Value, +count: U32, +n: U32) -> List<&2, N111Stmt>:
  +kind = p111_special(name)
  nt_choose(List<&2, N111Stmt>, U32.is_eq(count, 0), u => Nil{},
    u => Con{nt_choose(N111Stmt, U32.is_eq(kind, 0),
      v => N111Call{"ignored", N111U64{}, "p111_rt_take", [p111_state(), p111_word(word), p111_scratch(), p111_u32(count)]},
      v => N111Call{"ignored", N111U64{}, "p111_rt_special_take", [p111_state(), p111_u32(kind), p111_word(word), p111_scratch(), p111_u32(count)]}), p111_load_fields(count, 0, n)})

@unsafe
def p111_test(+name: String, +word: N111Value) -> List<&2, N111Stmt>:
  p112_special_test(name, word)

law p111_lower:
  for +book: List<&2, KDef>
  for +t: KTerm
  for +env: List<&2, NC_Binding>
  for +n: U32
  P111Code

law p111_live:
  for +book: List<&2, KDef>
  for +t: KTerm
  for +env: List<&2, NC_Binding>
  for +n: U32
  P111Code

@unsafe
def p111_lower_partition(+book: List<&2, KDef>, +t: KTerm, +n: U32, parts: P111Partition) -> P111Code:
  match parts:
    case P111Partition{+live, +drop}: p111_prepend(drop, p111_live(book, t, live, n))

@unsafe
def p111_lower(book, t, env, n):
  nt_choose(P111Code, p98_tag_eq(t, "Let") || p98_tag_eq(t, "NSeqLet"),
    u => p112_liveness_lower(book, p112_liveness_terms(ks(t)), env, n),
    u => p112_liveness_other(book, t, env, n))

@unsafe
def p111_bind_value(+book: List<&2, KDef>, +value: KTerm, +body: KTerm, +env: List<&2, NC_Binding>, +id: U32, +n: U32, emitted: P111ValueCode) -> P111Code:
  match emitted:
    case P111ValueCode{+prefix, +word, +error}:
      +uses = nc_uses(body)
      +held = nc_live_uses(env, uses)
      +rest = p111_lower(book, body, nt_append(NC_Binding, held, [p113_binding(book, id, value, env)]), n)
      nt_choose(P111Code, String.eq(error, ""),
        u => p111_prepend(nt_append(N111Stmt, p111_keep(nc_live_env(env, value), uses), nt_append(N111Stmt, prefix, [N111Set{"v_" ++ U32.show(id), N111U64{}, word}])), rest),
        u => p111_fail(error, n))

@unsafe
def p111_let_cut(+book: List<&2, KDef>, +value: KTerm, +body: KTerm, +env: List<&2, NC_Binding>, +id: U32, +n: U32) -> P111Code:
  +next = p111_name(n)
  +uses = nc_uses(body)
  +held = nc_live_uses(env, uses)
  +params = nt_append(NC_Binding, held, [p113_binding(book, id, value, env)])
  +rest = p111_lower(book, body, params, U32.inc(n))
  +value_env = nc_live_env(env, value)
  +val = p111_live(book, value, value_env, p111_fresh(rest))
  +seg : N111Segment = p111_segment(next, params, nt_count(NC_Binding, held), 1, p111_body(rest))
  P111Code{nt_append(N111Stmt, p111_keep(value_env, uses), nt_append(N111Stmt, p111_frame(held, next), p111_body(val))), Con{seg, nt_append(N111Segment, p111_segments(rest), p111_segments(val))}, p111_fresh(val), p111_first(p111_error(rest), p111_error(val))}

@unsafe
def p111_let_ctor(+book: List<&2, KDef>, +value: KTerm, +body: KTerm, +env: List<&2, NC_Binding>, +id: U32, +n: U32, literal: NC_Literal) -> P111Code:
  match literal:
    case NC_Literal{+valid, +word}:
      nt_choose(P111Code, valid,
        u => p111_bind_value(book, value, body, env, id, n, P111ValueCode{Nil{}, N111Const{word, 0}, ""}),
        u => p111_lower(book, nd_bind_value("NCtr", nm(value), ks(value), Nil{}, n, id, body), env, U32.add(n, terms_len(ks(value)))))

@unsafe
def p111_let(+book: List<&2,KDef>, +value: KTerm, +body: KTerm, +env: List<&2,NC_Binding>, +id: U32, +n: U32) -> P111Code:
  nt_choose(P111Code,String.eq(tg(value),"NStatic"),u => p111_bind_value(book,value,body,env,id,n,p112s_value(book,value)),
    u => p112s_let_fallback(book,value,body,env,id,n))

@unsafe
def p111_lets(+book: List<&2, KDef>, terms: List<&2, KTerm>, +env: List<&2, NC_Binding>, +n: U32) -> P111Code:
  p112_liveness_live(book, p112_liveness_terms(terms), env, n)

@unsafe
def p111_lambda(+book: List<&2, KDef>, +t: KTerm, +env: List<&2, NC_Binding>, +n: U32) -> P111Code:
  +name = p111_name(n)
  +params = nt_append(NC_Binding, env, [nc_binding(ix(t))])
  +body = p111_lower(book, kid(t, 0), params, U32.inc(n))
  +seg : N111Segment = p111_segment(name, params, 0, 0, p111_body(body))
  +result = p111_prepend(nt_append(N111Stmt, p111_store(p111_env_words(env), 0), [N111Call{"value", N111U64{}, "p111_rt_closure", [p111_state(), N111Arg{N111U32{}, N111FuncId{name}}, p111_scratch(), p111_u32(nt_count(NC_Binding, env))]}]), p111_return(N111Local{"value"}, p111_fresh(body)))
  P111Code{p111_body(result), Con{seg, p111_segments(body)}, p111_fresh(body), p111_error(body)}

@unsafe
def p111_slow_app(+book: List<&2, KDef>, +t: KTerm, +env: List<&2, NC_Binding>, +n: U32) -> P111Code:
  +f = nc_id(n)
  +a = nc_id(U32.inc(n))
  p111_lower(book, nc_mklet(f, kid(t, 0), nc_mklet(a, kid(t, 1), kt("NApply", "", 0, 0, [var("", f), var("", a)]))), env, U32.add(n, 2))

@unsafe
def p111_app(+book: List<&2, KDef>, +t: KTerm, +env: List<&2, NC_Binding>, +n: U32) -> P111Code:
  +head = nd_head(t)
  +args = nd_args(t, Nil{})
  +prim = nd_native_call(book, t)
  nt_choose(P111Code, String.eq(prim, ""),
    u =>
  nt_choose(P111Code, String.eq(tg(head), "Lam"), u => p111_lower(book, nd_beta(head, args), env, n), u =>
  nt_choose(P111Code, String.eq(tg(head), "Mat"),
    u => nt_choose(P111Code, U32.is_eq(terms_len(args), 1) || nd_match_vars(args),
      v => p111_lower(book, nd_match_sequence(head, args, Nil{}, n), env, U32.add(n, terms_len(args))),
      v => p111_slow_app(book, t, env, n)), u =>
  nt_choose(P111Code, String.eq(tg(head), "Ref"),
    u => p111_ref_app(book, t, head, args, env, n),
    u => p111_slow_app(book, t, env, n)))), u => p111_lower(book, nc_sequence("NOp", prim, args, Nil{}, n), env, U32.add(n, terms_len(args))))

@unsafe
def p111_ref_app(+book: List<&2,KDef>, +t: KTerm, +head: KTerm, +args: List<&2,KTerm>, +env: List<&2,NC_Binding>, +n: U32) -> P111Code:
  p113dc_generic(book,t,head,args,env,n)

@unsafe
def p111_apply(+values: List<&2, N111Value>, +n: U32) -> P111Code:
  P111Code{[N111Call{"reply", N111U64{}, "p111_rt_apply", [p111_state(), p111_word(p111_head(values)), p111_word(p111_head(p111_tail(values)))]}, N111Return{N111Local{"reply"}}], Nil{}, n, ""}

@unsafe
def p111_guard_io(+name: String, +word: N111Value, +body: List<&2, N111Stmt>) -> List<&2, N111Stmt>:
  nt_choose(List<&2, N111Stmt>, String.eq(name, "Emit") || String.eq(name, "Halt"),
    u => [N111Call{"tag", N111U64{}, "p111_rt_tag", [p111_state(), p111_word(word)]}, N111Bin{"tag_hit", N111U64{}, "eq", N111Local{"tag"}, N111CtorId{"Emit"}}, N111Bin{"tag_other", N111U64{}, "eq", N111Local{"tag"}, N111CtorId{"Halt"}}, N111Bin{"valid_tag", N111U32{}, "or", N111Local{"tag_hit"}, N111Local{"tag_other"}}, N111If{N111Local{"valid_tag"}, body, [N111Call{"reply", N111U64{}, "p111_rt_fail", [p111_state(), p111_u32(2)]}, N111Return{N111Local{"reply"}}]}],
    u => body)

@unsafe
def p111_match_apply(+book: List<&2,KDef>, +t: KTerm, +env: List<&2,NC_Binding>, +n: U32) -> P111Code:
  p112m_match_apply(book,t,env,n)

@unsafe
def p111_match_value(+book: List<&2, KDef>, +t: KTerm, +env: List<&2, NC_Binding>, +n: U32) -> P111Code:
  p111_lambda(book, k_lam("", nc_id(n), 1, [kt("NMatch", "", 0, 0, [t, var("", nc_id(n))])], 0, 0, False{}), env, U32.inc(n))


# Phase111 module: selfhost/tools/performance/phase111/segment/lower-dispatch.bend
@unsafe
def p111_lower_ctor(+book: List<&2, KDef>, +t: KTerm, +env: List<&2, NC_Binding>, +n: U32, literal: NC_Literal) -> P111Code:
  match literal:
    case NC_Literal{+valid, +value}:
      nt_choose(P111Code, valid, u => p111_return(N111Const{value, 0}, n),
        u => p111_lower(book, nc_sequence("NCtr", nm(t), ks(t), Nil{}, n), env, U32.add(n, terms_len(ks(t)))))

@unsafe
def p111_nat_sum_finish(+values: List<&2, N111Value>, +n: U32, offset: Maybe<&2, U32>) -> P111Code:
  match offset:
    case None{}: p111_fail("invalid native Nat offset", n)
    case Some{+value}:
      +first = p111_constructor("Succ", values)
      p111_nat_sum_join(first, value, n)

@unsafe
def p111_nat_sum_join(first: P111ValueCode, +offset: U32, +n: U32) -> P111Code:
  match first:
    case P111ValueCode{+body, +word, +error}:
      p111_prepend(body, p111_value_return(p111_intrinsic("nat_add", [word, N111Const{offset, 0}]), n))

@unsafe
def p111_live(book,t,env,n):
  nt_choose(P111Code,String.eq(tg(t),"NStatic"),u => p111_value_return(p112s_value(book,t),n),
    u => p112s_live_fallback(book,t,env,n))

@unsafe
def p111_entry_join(+base: P111Code, +body: P111Code, +name: String, +params: List<&2, NC_Binding>) -> P111Code:
  P111Code{p111_body(base), nt_append(N111Segment, p111_segments(base), Con{p111_segment(nd_name(name), params, 0, 0, p111_body(body)), p111_segments(body)}), p111_fresh(body), p111_first(p111_error(base), p111_error(body))}

@unsafe
def p111_extend(+book: List<&2, KDef>, +body: KTerm, +base: P111Code, +name: String, +arity: U32) -> P111Code:
  +params = nk_typed_bindings(nd_entry_params(arity, p111_fresh(base)), nf_worker_kinds(book, name, arity))
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

# Native primitives win before Foreign/Absent, exactly as nc_definition_plain.
@unsafe
def p111_is_foreign(+definition: KDef) -> Bool:
  nt_choose(Bool, nc_native_def(definition), u => False{}, u => nc_foreign(definition))

@unsafe
def p111_effects(+source: List<&2, KDef>, names: List<&2, String>) -> List<&2, String>:
  match names:
    case Nil{}: Nil{}
    case Con{+name, +rest}:
      nt_choose(List<&2, String>, p111_is_foreign(lookup(source, name)), u => Con{name, p111_effects(source, rest)}, u => p111_effects(source, rest))

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

# Frozen capability set of runtime/effects/prepared01/catalogue.json.
# Adding a foreign provider requires a new runtime capsule and this admission
# catalogue together. This is an internal checked-request backend boundary.
@unsafe
def p111_runtime_names() -> List<&2, String>:
  ["IO.args", "IO.print", "IO.now", "IO.print_err", "File.open", "File.read", "File.read_bytes", "File.read_at", "File.size", "File.write", "File.write_bytes", "File.close", "NativeHost.read", "NativeHost.path", "NativeHost.publish"]

@unsafe
def p111_runtime_effects(effects: List<&2, String>, +available: List<&2, String>) -> String:
  match effects:
    case Nil{}: ""
    case Con{+name, +rest}:
      nt_choose(String, nb_contains(available, name),
        u => p111_runtime_effects(rest, available),
        u => "foreign provider unavailable in fixed runtime: " ++ name)

@unsafe
def p111_runtime_admission(request: NR_Request) -> String:
  match request:
    case NR_Request{source, book, names, paths, scope, bound}:
      p111_runtime_effects(p111_effects(source, names), p111_runtime_names())

# Validate before emission. Show/effect descriptors retain the mature backend's
# formats and are checked by the runtime adapter; this gate checks segment IR.
@unsafe
def p111_verify_program(+program: P111Program) -> String:
  match program:
    case P111Program{segments,constructors,show,show_names,effects,pure}:
      p111v_program_indexed(program,p111v_functions(segments,P111VScan{missing(),"",0}),p111v_constructors(constructors,P111VScan{missing(),"",0}))

@unsafe
def p111_emit_verified(+program: P111Program, +error: String) -> P111Emission:
  nt_choose(P111Emission,String.is_empty(error),u => P134Planned{P134Raw{program}},
    u => P111Emission{[],"structured IR: " ++ error})

@unsafe
def p111_emit_lowered(result: P111Result) -> P111Emission:
  match result:
    case P111Result{+program,+error}:
      nt_choose(P111Emission,String.is_empty(error),u => p111_emit_verified(program,p111_verify_program(program)),
        u => P111Emission{[],"native lowering: " ++ error})

@unsafe
def p111_emit_admitted(+request: NR_Request, +error: String) -> P111Emission:
  p134e_collect(p128raw_emit_admitted(request,error))

@unsafe
def p111_emit_plan(plan: P86Plan) -> P111Emission:
  match plan:
    case P86PlanError{error}: P111Emission{[],error}
    case P86PlanReady{+request,verdict}: p111_emit_admitted(request,p111_runtime_admission(request))

@unsafe
def p111_compile_prepared(+path: String, +source: String, prepared: P86Preparation) -> P111Emission:
  match prepared:
    case P86PreparationError{error}: P111Emission{[],error}
    case P86PreparationReady{seed}: p111_emit_plan(p86_plan(seed,path,source))

@unsafe
def p111_compile_source(+path: String, +source: String, +base_path: String, +base: String,
  +carrier: String, +stamp: String, +cached: Bool) -> P111Emission:
  p111_compile_prepared(path,source,nt_choose(P86Preparation,cached,
    u => p88_cache_prepare(base_path,base,carrier,stamp),u => p86_prepare(base_path,base)))

@unsafe
def p111_print_chunks(chunks: List<&2,String>) -> IO(U32):
  match chunks:
    case Nil{}: IO.pure(U32,0)
    case Con{head,rest}:
      do IO<U32>:
        Unit <- IO.print(head)
        p111_print_chunks(rest)

@unsafe
def p111_print_emission(result: P111Emission) -> IO(U32):
  match result:
    case P111Emission{chunks,+error}:
      nt_choose(IO(U32),String.is_empty(error),u => p111_print_chunks(chunks),
        u => IO.die(U32,1,error))
    case P134Planned{plan}: p134w_plan(plan)

@unsafe
def p111_native_request(+path: String, +base_path: String, +cache_path: String,
  +stamp: String, +cached: Bool) -> IO(U32):
  do IO<U32>:
    +source : String <- p86_read_file(path)
    +base : String <- p86_read_file(base_path)
    nt_choose(IO(U32),cached,
      u => do IO<U32>:
        carrier : String <- p86_read_file(cache_path)
        p111_print_emission(p134e_compile_source(path,source,base_path,base,carrier,stamp,True{})),
      u => p111_print_emission(p134e_compile_source(path,source,base_path,base,"","",False{})))

@unsafe
def p111_native_args(args: List<&1,String>) -> IO(U32):
  match args:
    case Con{program,Con{+logical,Con{+base,Con{+carrier,Con{+stamp,Con{+jobfile,Con{version,Nil{}}}}}}}}:
      nt_choose(IO(U32),String.eq(program,"phase140-batch") && String.eq(version,"v1") &&
        String.starts_with(logical,"/") && String.starts_with(base,"/") && String.starts_with(carrier,"/") && String.starts_with(jobfile,"/"),
        u => p140nb_start(logical,base,carrier,stamp,jobfile),
        u => IO.die(U32,2,"batch expects absolute logical/Base/carrier/jobfile paths and v1"))
    case Con{program,Con{+a,Con{+b,Con{+base,Con{+carrier,Con{+stamp,Con{+out_a,Con{+out_b,Con{+mode,Con{+hint,Con{+owner,Nil{}}}}}}}}}}}}:
      nt_choose(IO(U32),String.eq(program,"phase140-session") && p140n_paths(a,b,base,carrier,out_a,out_b,mode,owner),
        u => p140n_args(a,b,base,carrier,stamp,out_a,out_b,String.eq(mode,"warm"),hint,owner,U32.read(hint)),
        u => IO.die(U32,2,"session expects absolute distinct paths, warm|cold, hint and owner"))
    case Con{program,Con{+path,Con{+base,Con{+mode,Con{+cache,Con{+stamp,Nil{}}}}}}}:
      nt_choose(IO(U32),String.starts_with(path,"/") && String.starts_with(base,"/") &&
        (String.eq(mode,"live") || (String.eq(mode,"cache") && String.starts_with(cache,"/"))),
        u => p111_native_request(path,base,cache,stamp,String.eq(mode,"cache")),
        u => IO.die(U32,2,"expected absolute input/Base paths and live|cache mode"))
    case _: IO.die(U32,2,"usage: phase111 ABS_INPUT ABS_BASE live|cache ABS_CARRIER STAMP")
