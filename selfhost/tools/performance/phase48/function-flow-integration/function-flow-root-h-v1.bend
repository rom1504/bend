# Isolated Phase48 planner. Original book supplies public guards/fallback; only
# the separately named root has normalized code in the private analysis view.
@unsafe
def j_function_flow_root(+book: List<&2,KDef>, +d: KDef) -> String:
  kc(String, j_instance_source_definition(d) && U32.is_le(da(d), 8) &&
    U32.is_eq(j_lambda_count(dv(d)), da(d)) && j_instance_root_signature(book, dt(d), da(d)) &&
    Bool.not(db(d)) && Bool.not(j_string_literal(book, d)),
    u => kc(String, jff_needed(book, [dv(d)], 4096),
      u => jff_root_fresh(book, d, jff_book_terms(book)), u => ""), u => "")

# Do not reopen tiny acyclic first-order roots: a real function-valued source
# edge or an immediately called literal lambda is necessary for this planner.
@unsafe
def jff_needed(+book: List<&2,KDef>, +todo: List<&2,KTerm>, +fuel: U32) -> Bool:
  match todo:
    case Nil{}: False{}
    case Con{t, rest}:
      kc(Bool, U32.is_gt(fuel, 0),
        u => kc(Bool, String.eq(tg(t), "Ref") && jff_function_signature(lookup(book, nm(t))),
          u => True{},
          u => kc(Bool, String.eq(tg(t), "App") && String.eq(tg(j_strip(kid(t, 0))), "Lam"),
            u => True{}, u => jff_needed(book,
              List.append(&2,KTerm, kc(List<&2,KTerm>, String.eq(tg(t), "Ann"),
                u => [kid(t, 0)], u => ks(t)), rest), U32.sub(fuel, 1)))), u => False{})

@unsafe
def jff_function_signature(+d: KDef) -> Bool:
  kc(Bool, String.eq(dk(d), "Def") && Bool.not(db(d)) && U32.is_eq(dx(d), 0),
    u => jff_signature_function(dt(d), kc(U32, String.eq(tg(j_strip(dv(d))), "Mat"),
      u => 1, u => j_lambda_count(dv(d)))), u => False{})

@unsafe
def jff_signature_function(+ty: KTerm, +left: U32) -> Bool:
  kc(Bool, U32.is_eq(left, 0), u => String.eq(tg(ty), "All"),
    u => kc(Bool, String.eq(tg(ty), "All") && U32.is_le(left, 32),
      u => String.eq(tg(kid(ty, 0)), "All") || jff_signature_function(kid(ty, 1), U32.sub(left, 1)),
      u => False{}))

# BookCache and planner metadata are indexes, not additional source definitions.
# Original checked definitions remain in the ordinary list after that cache.
@unsafe
def jff_book_terms(+defs: List<&2,KDef>) -> List<&2,KTerm>:
  match defs:
    case Nil{}: Nil{}
    case Con{d, rest}:
      kc(List<&2,KTerm>, String.eq(dk(d), "Def") || String.eq(dk(d), "ADT") || String.eq(dk(d), "Ctr"),
        u => Con{dt(d), Con{dv(d), List.append(&2,KTerm, jff_book_terms(dc(d)), jff_book_terms(rest))}},
        u => jff_book_terms(rest))

@unsafe
def jff_root_fresh(+book: List<&2,KDef>, +d: KDef, +terms: List<&2,KTerm>) -> String:
  kc(String, jff_bounded(terms, 1048576),
    u => jff_root_max(book, d, jff_max(terms, 0)), u => "")

@unsafe
def jff_root_max(+book: List<&2,KDef>, +d: KDef, +highest: U32) -> String:
  kc(String, U32.is_lt(highest, 4294967295),
    u => jff_root_result(book, d, j_function_flow(book, dv(d), U32.inc(highest))), u => "")

@unsafe
def jff_root_result(+book: List<&2,KDef>, +d: KDef, +r: JFunctionFlow) -> String:
  match r:
    case JFunctionFlow{term, next, steps, dependencies, valid}:
      kc(String, valid && U32.is_gt(steps, 0) &&
        String.eq(dk(lookup(book, j_instance_name(0))), "Absent"),
        u => jff_root_private(book, d, dependencies,
          KDef{j_instance_name(0), "Def", da(d), 0, dt(d), term, Nil{}, False{}, du(d)}), u => "")

@unsafe
def jff_root_private(+book: List<&2,KDef>, +d: KDef, +dependencies: List<&2,String>, +private: KDef) -> String:
  +view = Con{private, book}
  jff_root_proved(book, view, d, dependencies, private,
    j_pure_graph(view, private, JPure{Nil{}, 131072, True{}}))

@unsafe
def jff_root_proved(+book: List<&2,KDef>, +view: List<&2,KDef>, +d: KDef,
  +dependencies: List<&2,String>, +private: KDef, +pure: JPure) -> String:
  kc(String, j_pure_valid(pure),
    u => jff_root_rows(book, view, d, private, pure,
      Con{j_instance_alias(d), jff_dependency_rows(book, dependencies)},
      jff_source_rows(book, j_pure_defs(pure), dn(private)),
      Con{private, jff_private_defs(book, j_pure_defs(pure), dn(private))}), u => "")

# Aliases are exact ORIGINAL source definitions, never rewritten root syntax.
# The complete primitive collector scans every row's original body, including
# removed callback/factory/helper operations and every untaken branch.
@unsafe
def jff_dependency_rows(+book: List<&2,KDef>, +names: List<&2,String>) -> List<&2,KDef>:
  match names:
    case Nil{}: Nil{}
    case Con{name, rest}: Con{j_instance_alias(lookup(book, name)), jff_dependency_rows(book, rest)}

@unsafe
def jff_source_rows(+book: List<&2,KDef>, +defs: List<&2,KDef>, +private: String) -> List<&2,KDef>:
  match defs:
    case Nil{}: Nil{}
    case Con{d, rest}:
      kc(List<&2,KDef>, String.eq(dn(d), private),
        u => jff_source_rows(book, rest, private),
        u => Con{j_instance_alias(lookup(book, dn(d))), jff_source_rows(book, rest, private)})

@unsafe
def jff_private_defs(+book: List<&2,KDef>, +defs: List<&2,KDef>, +root: String) -> List<&2,KDef>:
  match defs:
    case Nil{}: Nil{}
    case Con{d, rest}:
      kc(List<&2,KDef>, db(d) || String.eq(dn(d), root) || j_string_literal(book, d),
        u => jff_private_defs(book, rest, root), u => Con{d, jff_private_defs(book, rest, root)})

@unsafe
def jff_root_rows(+book: List<&2,KDef>, +view: List<&2,KDef>, +d: KDef, +private: KDef,
  +pure: JPure, +rows: List<&2,KDef>, +sourceRows: List<&2,KDef>, +defs: List<&2,KDef>) -> String:
  +all = List.append(&2,KDef, rows, sourceRows)
  kc(String, j_instance_all_exact(book, all) && U32.is_le(j_region_def_count(all), 128),
    u => jff_root_emit(book, d, all, pure, j_function_flow_worker(view, defs, 0)), u => "")

@unsafe
def jff_root_emit(+book: List<&2,KDef>, +d: KDef, +rows: List<&2,KDef>, +pure: JPure, +emission: JWEmission) -> String:
  match emission:
    case JWEmission{declarations, numberNat, recursive}:
      kc(String, Bool.not(String.eq(declarations, "")),
        u => j_instance_root_guarded_mode(book, d, rows, 0, pure,
          "/* private known function flow */" ++ declarations, numberNat), u => "")

# Baseline Phase47 emission API has no result-consumer entry argument. This
# planner deliberately puts its normalized private root at index0. A separate
# V-composition patch may pass this same explicit entry to that successor API.
@unsafe
def j_function_flow_worker(+book: List<&2,KDef>, +defs: List<&2,KDef>, +entry: U32) -> JWEmission:
  kc(JWEmission, U32.is_eq(entry, 0),
    u => j_worker_emission(book, defs), u => JWEmission{"", False{}, False{}})
