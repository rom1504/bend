
# Module: src/back/js/direct/program.bend:4
type JDShowDesc is Data:
  JDShowDesc{+cells: List<&2,String>, +types: List<&2,KTerm>, +names: List<&2,String>, +error: String}

# Module: src/back/js/direct/program.bend:8
@unsafe
def jd_show_cells(d: JDShowDesc) -> List<&2,String>:
  match d:
    case JDShowDesc{cells, types, names, error}: cells

# Module: src/back/js/direct/program.bend:13
@unsafe
def jd_show_types(d: JDShowDesc) -> List<&2,KTerm>:
  match d:
    case JDShowDesc{cells, types, names, error}: types

# Module: src/back/js/direct/program.bend:18
@unsafe
def jd_show_names(d: JDShowDesc) -> List<&2,String>:
  match d:
    case JDShowDesc{cells, types, names, error}: names

# Module: src/back/js/direct/program.bend:23
@unsafe
def jd_show_error(d: JDShowDesc) -> String:
  match d:
    case JDShowDesc{cells, types, names, error}: error

# Module: src/back/js/direct/program.bend:28
@unsafe
def jd_show_find(+key: String, +types: List<&2,KTerm>, +i: U32) -> U32:
  match types:
    case Nil{}: 4294967295
    case Con{t, rest}: kc(U32, p88_string_eq(key, term_key(t)), u => i, u => jd_show_find(key, rest, U32.inc(i)))

# Module: src/back/js/direct/program.bend:34
@unsafe
def jd_show_ref(+book: List<&2,KDef>, +ty: KTerm, +types: List<&2,KTerm>, +names: List<&2,String>) -> JDShowDesc:
  jd_show_ref_on(wnf(book, ty), types, names)

# Module: src/back/js/direct/program.bend:38
@unsafe
def jd_show_ref_on(+t: KTerm, +types: List<&2,KTerm>, +names: List<&2,String>) -> JDShowDesc:
  jd_show_ref_id(t, types, names, jd_show_find(term_key(t), types, 0))

# Module: src/back/js/direct/program.bend:42
@unsafe
def jd_show_ref_id(+t: KTerm, +types: List<&2,KTerm>, +names: List<&2,String>, +id: U32) -> JDShowDesc:
  kc(JDShowDesc, U32.is_eq(id, 4294967295), u =>
    JDShowDesc{["$jdSD" ++ U32.show(terms_len(types))], List.append(&2,KTerm, types, [t]), names, ""}, u =>
    JDShowDesc{["$jdSD" ++ U32.show(id)], types, names, ""})

# Module: src/back/js/direct/program.bend:48
@unsafe
def jd_show_join(+a: JDShowDesc, +b: JDShowDesc) -> JDShowDesc:
  JDShowDesc{List.append(&2,String, jd_show_cells(a), jd_show_cells(b)), jd_show_types(b), jd_show_names(b),
    kc(String, p88_string_eq(jd_show_error(a), ""), u => jd_show_error(b), u => jd_show_error(a))}

# Module: src/back/js/direct/program.bend:53
@unsafe
def jd_show_fields(+book: List<&2,KDef>, +tel: KTerm, +left: U32,
  +types: List<&2,KTerm>, +names: List<&2,String>) -> JDShowDesc:
  kc(JDShowDesc, U32.is_eq(left, 0), u => JDShowDesc{Nil{}, types, names, ""}, u =>
    jd_show_fields_on(book, wnf(book, tel), left, types, names))

# Module: src/back/js/direct/program.bend:59
@unsafe
def jd_show_fields_on(+book: List<&2,KDef>, +t: KTerm, +left: U32,
  +types: List<&2,KTerm>, +names: List<&2,String>) -> JDShowDesc:
  kc(JDShowDesc, p98_tag_eq(t, "All"), u =>
    kc(JDShowDesc, U32.is_eq(qt(t), 0), u => JDShowDesc{Nil{}, types, names, "cannot print an erased field"}, u =>
      jd_show_field_more(book, t, left, jd_show_ref(book, kid(t, 0), types, names))),
    u => JDShowDesc{Nil{}, types, names, "cannot print a dependent field telescope"})

# Module: src/back/js/direct/program.bend:67
@unsafe
def jd_show_field_more(+book: List<&2,KDef>, +t: KTerm, +left: U32, +d: JDShowDesc) -> JDShowDesc:
  jd_show_join(JDShowDesc{Con{"0", jd_show_cells(d)}, jd_show_types(d), jd_show_names(d), jd_show_error(d)},
    jd_show_fields(book, j_app_type(t, {KTerm{"Absent", "", 0, 0, Nil{}, Nil{}, 0, 0} : KTerm}), U32.sub(left, 1), jd_show_types(d), jd_show_names(d)))

# Module: src/back/js/direct/program.bend:72
@unsafe
def jd_show_arms(+book: List<&2,KDef>, +ctors: List<&2,KDef>, +args: List<&2,KTerm>,
  +types: List<&2,KTerm>, +names: List<&2,String>) -> JDShowDesc:
  match ctors:
    case Nil{}: JDShowDesc{Nil{}, types, names, ""}
    case Con{c, rest}: jd_show_arm(book, c, rest, args, names,
      jd_show_fields(book, j_specialize(book, dt(c), args), da(c), types,
        List.append(&2,String, names, [j_quote(name_key(dn(c)))])))

# Module: src/back/js/direct/program.bend:81
@unsafe
def jd_show_arm(+book: List<&2,KDef>, +c: KDef, +rest: List<&2,KDef>, +args: List<&2,KTerm>,
  +oldNames: List<&2,String>, +d: JDShowDesc) -> JDShowDesc:
  jd_show_join(JDShowDesc{List.append(&2,String,
    [U32.show(jd_string_len(oldNames)), j_quote(name_key(dn(c))), U32.show(da(c)),
      kc(String, p88_string_eq(dn(c), "Tuple"), u => "2", u =>
        kc(String, p88_string_eq(dn(c), "Con") || p88_string_eq(dn(c), "Nil"), u => "1", u => "0"))], jd_show_cells(d)),
    jd_show_types(d), jd_show_names(d), jd_show_error(d)},
    jd_show_arms(book, rest, args, jd_show_types(d), jd_show_names(d)))

# Module: src/back/js/direct/program.bend:91
@unsafe
def jd_show_data(+book: List<&2,KDef>, +ty: KTerm, +types: List<&2,KTerm>, +names: List<&2,String>) -> JDShowDesc:
  jd_show_data_on(dc(lookup(book, nm(ty))), jd_show_arms(book, dc(lookup(book, nm(ty))), ks(ty), types, names))

# Module: src/back/js/direct/program.bend:95
@unsafe
def jd_show_data_on(+ctors: List<&2,KDef>, +d: JDShowDesc) -> JDShowDesc:
  JDShowDesc{List.append(&2,String, ["7", "1", U32.show(jd_show_ctor_count(ctors))], jd_show_cells(d)),
    jd_show_types(d), jd_show_names(d), jd_show_error(d)}

# Module: src/back/js/direct/program.bend:100
@unsafe
def jd_show_ctor_count(+ctors: List<&2,KDef>) -> U32:
  match ctors:
    case Nil{}: 0
    case Con{c, rest}: U32.inc(jd_show_ctor_count(rest))

# Module: src/back/js/direct/program.bend:106
@unsafe
def jd_show_array(+d: JDShowDesc) -> JDShowDesc:
  JDShowDesc{Con{"6", List.append(&2,String, jd_show_cells(d), ["0"])}, jd_show_types(d), jd_show_names(d), jd_show_error(d)}

# Module: src/back/js/direct/program.bend:110
@unsafe
def jd_show_node(+book: List<&2,KDef>, +ty: KTerm, +types: List<&2,KTerm>, +names: List<&2,String>) -> JDShowDesc:
  jd_show_node_kind(book, ty, types, names, kc(String, db(lookup(book, nm(ty))), u => nm(ty), u => ""))

# Module: src/back/js/direct/program.bend:114
@unsafe
def jd_show_node_kind(+book: List<&2,KDef>, +ty: KTerm, +types: List<&2,KTerm>, +names: List<&2,String>, +kind: String) -> JDShowDesc:
  kc(JDShowDesc, p88_string_eq(kind, "U32"), u => JDShowDesc{["0"], types, names, ""}, u =>
  kc(JDShowDesc, p88_string_eq(kind, "F32"), u => JDShowDesc{["1"], types, names, ""}, u =>
  kc(JDShowDesc, p88_string_eq(kind, "Nat"), u => JDShowDesc{["2"], types, names, ""}, u =>
  kc(JDShowDesc, p88_string_eq(kind, "Char"), u => JDShowDesc{["3", "0"], types, names, ""}, u =>
  kc(JDShowDesc, p88_string_eq(kind, "String"), u => JDShowDesc{["4"], types, names, ""}, u =>
  kc(JDShowDesc, p98_tag_eq(ty, "Eql"), u => JDShowDesc{["5"], types, names, ""}, u =>
  kc(JDShowDesc, p88_string_eq(kind, "Array"), u => jd_show_array(jd_show_ref(book, kid(ty, 0), types, names)), u =>
  kc(JDShowDesc, p98_tag_eq(ty, "ADT") && p88_string_eq(dk(lookup(book, nm(ty))), "ADT") && Bool.not(p88_string_eq(nm(ty), "IO.OP")),
    u => jd_show_data(book, ty, types, names),
    u => JDShowDesc{Nil{}, types, names, "main cannot print a function, Type, or dependent field"}))))))))

# Module: src/back/js/direct/program.bend:127
@unsafe
def jd_show_nodes(+book: List<&2,KDef>, +types: List<&2,KTerm>, +names: List<&2,String>,
  +i: U32, +offset: U32, +defs: String, +cells: List<&2,String>) -> String:
  kc(String, U32.is_eq(i, terms_len(types)), u => defs ++
    "const $jdShowD=[" ++ jd_join(cells) ++ "];\n" ++
    "cli(process.argv.slice(1));io_exit(" ++ jd_name("main") ++ ",$jdShowD);\n", u =>
    kc(String, U32.is_lt(i, 4096), u => jd_show_step(book, i, offset, defs, cells,
      jd_show_node(book, terms_at(types, i), types, names)), u => jd_fail("readback type graph budget")))

# Module: src/back/js/direct/program.bend:136
@unsafe
def jd_show_step(+book: List<&2,KDef>, +i: U32, +offset: U32, +defs: String, +cells: List<&2,String>, +d: JDShowDesc) -> String:
  kc(String, p88_string_eq(jd_show_error(d), ""), u =>
    jd_show_nodes(book, jd_show_types(d), jd_show_names(d), U32.inc(i), U32.add(offset, jd_string_len(jd_show_cells(d))),
      defs ++ "const $jdSD" ++ U32.show(i) ++ "=" ++ U32.show(offset) ++ ";\n",
      List.append(&2,String, cells, jd_show_cells(d))), u => jd_fail(jd_show_error(d)))

# Library reachability roots are exactly host-callable definitions. A program
# roots main only; foreign effects enter through source reachability, not an
# exemption for legacy native IO implementations.

# Module: src/back/js/direct/program.bend:146
@unsafe
def jd_roots(+book: List<&2,KDef>, +library: Bool) -> List<&2,String>:
  kc(List<&2,String>, library, u => jd_library_roots(book, book), u => ["main"])

# Module: src/back/js/direct/program.bend:150
@unsafe
def jd_library_roots(+book: List<&2,KDef>, +defs: List<&2,KDef>) -> List<&2,String>:
  match defs:
    case Nil{}: Nil{}
    case Con{d, rest}: kc(List<&2,String>, p88_string_eq(dk(d), "Def") && U32.is_eq(dx(d), 0) && Bool.not(db(d)) &&
      Bool.not(p98_tag_eq(j_strip(dv(d)), "Absent")) && Bool.not(p98_tag_eq(j_strip(dv(d)), "Foreign")), u =>
        kc(List<&2,String>, j_io_type(book, dt(d)), u => jd_library_roots(book, rest),
          u => Con{dn(d), jd_library_roots(book, rest)}), u => jd_library_roots(book, rest))

# Module: src/back/js/direct/program.bend:159
@unsafe
def jd_program_selected(+book: List<&2,KDef>, +defs: List<&2,KDef>) -> String:
  jd_program_context(jd_calls_context(jd_selected_context(book, defs), defs), defs)

# Module: src/back/js/direct/program.bend:163
@unsafe
def jd_program_context(+book: List<&2,KDef>, +defs: List<&2,KDef>) -> String:
  kc(String, jd_calls_valid(book), u => jd_definitions(book, defs) ++ jd_program_main(book, lookup(book, "main")),
    u => jd_fail("direct tail-call analysis refused"))

# Module: src/back/js/direct/program.bend:168
@unsafe
def jd_program_main(+book: List<&2,KDef>, +main: KDef) -> String:
  kc(String, p88_string_eq(dk(lookup(book, "IO")), "Def") && db(lookup(book, "IO")), u =>
    kc(String, p88_string_eq(dk(main), "Def") && Bool.not(p98_tag_eq(j_strip(dv(main)), "Absent")), u =>
      kc(String, p98_tag_eq(j_strip(dv(main)), "Foreign"), u => jd_fail("main must be a filled def"), u =>
      kc(String, j_io_type(book, dt(main)), u =>
        "cli(process.argv.slice(1));io_exit(" ++ jd_name("main") ++ ",null);\n", u =>
        jd_show_nodes(book, [wnf(book, dt(main))], Nil{}, 0, 0, "", Nil{}))), u => jd_fail("no main to run")),
    u => jd_fail("a build needs import Base"))
