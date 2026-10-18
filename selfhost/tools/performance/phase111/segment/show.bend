# Structured counterpart of the mature native/show.bend descriptor builder.
# References remain typed until the breadth-first offsets and constructor IDs
# are known. No NC_Desc string cells, C declarations or macros are parsed.
type P111Show is Data:
  P111Show{+words: List<&2, U32>, +names: List<&2, String>, +error: String}

type P111ShowCell is Data:
  P111ShowWord{+value: U32}
  P111ShowRef{+index: U32}
  P111ShowCtor{+name: String}

type P111ShowDesc is Data:
  P111ShowDesc{+cells: List<&2, P111ShowCell>, +types: List<&2, KTerm>, +error: String}

type P111ShowGraph is Data:
  P111ShowGraph{+cells: List<&2, P111ShowCell>, +offsets: List<&2, U32>, +error: String}

type P111ShowWords is Data:
  P111ShowWords{+words: List<&2, U32>, +error: String}

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
  nt_choose(P111ShowGraph, Bool.not(String.eq(p111_show_error(d), "")),
    u => P111ShowGraph{Nil{}, Nil{}, p111_show_error(d)}, u =>
    nt_choose(P111ShowGraph, U32.is_lt(next, offset), u => P111ShowGraph{Nil{}, Nil{}, "native readback descriptor offset overflow"}, u =>
      p111_show_nodes(book, p111_show_types(d), U32.inc(i), next, List.append(&2, U32, offsets, [offset]), List.append(&2, P111ShowCell, cells, p111_show_cells(d)))))

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
