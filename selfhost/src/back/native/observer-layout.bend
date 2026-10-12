# Bounded typed schemas for root-preserving native traversals.
# NO_Layout is supplied by observer-emitter.bend. This file proves only a
# bounded schema, never ownership, purity, return identity or runtime validity.
# Names below identify native representations, never candidate functions.

type NO_Spec is Data:
  NO_Spec{+layout: NO_Layout, +owner: String, +fields: List<&2, String>}

type NO_Schema is Data:
  NO_Schema{+params: List<&2, KTerm>, +roots: List<&2, U32>, +wrapper: KTerm, +result: U32, +observation: String, +specs: List<&2, NO_Spec>, +fresh: U32, +error: String}

type NOL_Wrap is Data:
  NOL_Wrap{+term: KTerm, +roots: List<&2, U32>, +shells: U32, +observation: String, +error: String}

@unsafe
def nol_error(+reason: String) -> KTerm:
  kt("NO_Refusal", reason, 0, 0, Nil{})

@unsafe
def nol_plain(+ty: KTerm) -> Bool:
  String.eq(tg(ty), "ADT") && List.is_empty(&2, KTerm, ks(ty)) && List.is_empty(&2, String, rm(ty))

@unsafe
def nol_owner(+book: List<&2, KDef>, +ty: KTerm) -> Bool:
  +d = lookup(book, nm(ty))
  String.eq(tg(ty), "ADT") && List.is_empty(&2, String, rm(ty)) && String.eq(dk(d), "ADT") && U32.is_eq(dx(d), 0) && U32.is_eq(terms_len(ks(ty)), da(d))

# Read exactly the declared live fields after specializing type parameters.
# All aliases/substitutions retain the existing 64-step/4096-node limits.
# Prior field dependencies and indexed constructor results decline. Unlike
# nq_layout_leaf, a nested Sigma is not rejected for sharing its owner's name.
@unsafe
def nol_fields(+book: List<&2, KDef>, +ty: KTerm, +tel: KTerm, +left: U32, +seen: List<&2, U32>) -> KTerm:
  +head = nq_layout_type(book, tel)
  nt_choose(KTerm, U32.is_eq(left, 0),
    u => nt_choose(KTerm, String.eq(tg(head), "ADT") && String.eq(nm(head), nm(ty)) && List.is_empty(&2, String, rm(head)) && Bool.not(nq_layout_dep(head, seen)) && norm_exact_lists(ks(head), ks(ty)), v => kt("NO_Types", "", 0, 0, Nil{}), v => nol_error("indexed constructor result")),
    u => nt_choose(KTerm, String.eq(tg(head), "All") && Bool.not(U32.is_eq(qt(head), 0)) && U32.is_le(left, 8),
      v => nol_field(book, ty, head, nq_layout_type(book, kid(head, 0)), left, seen), v => nol_error("constructor telescope")))

@unsafe
def nol_field(+book: List<&2, KDef>, +ty: KTerm, +head: KTerm, +field: KTerm, +left: U32, +seen: List<&2, U32>) -> KTerm:
  nt_choose(KTerm, nol_owner(book, field) && Bool.not(nq_layout_dep(field, seen)),
    u => nol_field_cons(field, nol_fields(book, ty, kid(head, 1), U32.sub(left, 1), Con{ix(head), seen})),
    u => nol_error("dependent or unsupported constructor field"))

@unsafe
def nol_field_cons(+field: KTerm, +tail: KTerm) -> KTerm:
  nt_choose(KTerm, String.eq(tg(tail), "NO_Types"), u => k_with_children(tail, Con{field, ks(tail)}), u => tail)

@unsafe
def nol_ctor_fields(+book: List<&2, KDef>, +ty: KTerm, +ctr: KDef) -> KTerm:
  nt_choose(KTerm, nol_owner(book, ty) && String.eq(dk(ctr), "Ctr") && U32.is_eq(dx(ctr), 0) && U32.is_le(da(ctr), 8),
    u => nol_fields(book, ty, nq_layout_specialize(dt(ctr), ks(ty), 64), da(ctr), Nil{}),
    u => nol_error("constructor descriptor"))

@unsafe
def nol_enum(+book: List<&2, KDef>, +ty: KTerm, ctors: List<&2, KDef>, +left: U32) -> Bool:
  match ctors:
    case Nil{}: True{}
    case Con{+ctr, +rest}:
      nt_choose(Bool, U32.is_gt(left, 0) && U32.is_eq(da(ctr), 0),
        u => String.eq(tg(nol_ctor_fields(book, ty, ctr)), "NO_Types") && nol_enum(book, ty, rest, U32.sub(left, 1)), u => False{})

@unsafe
def nol_scalar(+book: List<&2, KDef>, +ty: KTerm) -> Bool:
  +d = lookup(book, nm(ty))
  nt_choose(Bool, nol_plain(ty) && nol_owner(book, ty),
    u => (db(d) && nb_contains(["Nat", "Char", "U32", "F32"], dn(d))) || (Bool.not(List.is_empty(&2, KDef, dc(d))) && nol_enum(book, ty, dc(d), 32)), u => False{})

@unsafe
def nol_type_names(types: List<&2, KTerm>) -> List<&2, String>:
  match types:
    case Nil{}: Nil{}
    case Con{+h, +rest}: Con{nm(h), nol_type_names(rest)}

@unsafe
def nol_spec(+book: List<&2, KDef>, +owner: String, +ctr: KDef, +storage: String, +fields: List<&2, KTerm>) -> NO_Spec:
  +key = nc_ctor_identity(book, dn(ctr))
  NO_Spec{NO_Layout{key, key, storage, terms_len(fields)}, owner, nol_type_names(fields)}

@unsafe
def nol_root_fields(+book: List<&2, KDef>, +owner: String, fields: List<&2, KTerm>, +recursive: U32) -> Bool:
  match fields:
    case Nil{}: U32.is_eq(recursive, 1)
    case Con{+h, +rest}:
      nt_choose(Bool, nol_plain(h) && String.eq(nm(h), owner),
        u => U32.is_eq(recursive, 0) && nol_root_fields(book, owner, rest, 1),
        u => nol_scalar(book, h) && nol_root_fields(book, owner, rest, recursive))

@unsafe
def nol_root_pair(+book: List<&2, KDef>, +ty: KTerm, +nil: KDef, +cons: KDef) -> List<&2, NO_Spec>:
  +empty = nol_ctor_fields(book, ty, nil)
  +fields = nol_ctor_fields(book, ty, cons)
  nt_choose(List<&2, NO_Spec>, U32.is_eq(da(nil), 0) && U32.is_ge(da(cons), 2) && String.eq(tg(empty), "NO_Types") && String.eq(tg(fields), "NO_Types") && nol_root_fields(book, nm(ty), ks(fields), 0),
    u => [nol_spec(book, nm(ty), nil, "Nullary", Nil{}), nol_spec(book, nm(ty), cons, "Boxed", ks(fields))], u => Nil{})

@unsafe
def nol_root_ctors(+book: List<&2, KDef>, +ty: KTerm, ctors: List<&2, KDef>) -> List<&2, NO_Spec>:
  match ctors:
    case Con{+a, Con{+b, Nil{}}}:
      nt_choose(List<&2, NO_Spec>, U32.is_eq(da(a), 0), u => nol_root_pair(book, ty, a, b), u => nol_root_pair(book, ty, b, a))
    case _: Nil{}

@unsafe
def nol_root_specs(+book: List<&2, KDef>, +ty: KTerm) -> List<&2, NO_Spec>:
  +d = lookup(book, nm(ty))
  nt_choose(List<&2, NO_Spec>, nol_plain(ty) && nol_owner(book, ty) && (Bool.not(db(d)) || String.eq(dn(d), "String")),
    u => nol_root_ctors(book, ty, dc(d)), u => Nil{})

# Scalar readers are available to inlined helpers even if no entry parameter
# has the corresponding type. Word/Array and boxed primitive destructuring are
# intentionally absent. A native Nat remains conditional on runtime admission.
@unsafe
def nol_scalar_ctors(+book: List<&2, KDef>, +ty: KTerm, ctors: List<&2, KDef>) -> List<&2, NO_Spec>:
  match ctors:
    case Nil{}: Nil{}
    case Con{+ctr, +rest}:
      +fields = nol_ctor_fields(book, ty, ctr)
      +storage = nt_choose(String, U32.is_eq(da(ctr), 0), u => "Nullary", u => nt_choose(String, String.eq(nm(ty), "Nat") && String.eq(dn(ctr), "Succ"), v => "Succ", v => nt_choose(String, String.eq(nm(ty), "Char") && String.eq(dn(ctr), "Chr"), w => "Char", w => "")))
      +tail = nol_scalar_ctors(book, ty, rest)
      nt_choose(List<&2, NO_Spec>, String.eq(tg(fields), "NO_Types") && Bool.not(String.eq(storage, "")), u => Con{nol_spec(book, nm(ty), ctr, storage, ks(fields)), tail}, u => tail)

@unsafe
def nol_scalar_specs(+book: List<&2, KDef>, defs: List<&2, KDef>) -> List<&2, NO_Spec>:
  match defs:
    case Nil{}: Nil{}
    case Con{+d, +rest}:
      +ty = kt("ADT", dn(d), 0, 0, Nil{})
      nt_choose(List<&2, NO_Spec>, String.eq(dk(d), "ADT") && nol_scalar(book, ty),
        u => List.append(&2, NO_Spec, nol_scalar_ctors(book, ty, dc(d)), nol_scalar_specs(book, rest)), u => nol_scalar_specs(book, rest))

@unsafe
def nol_failure(+reason: String, +fresh: U32) -> NO_Schema:
  NO_Schema{Nil{}, Nil{}, atom("Absent"), 0, "", Nil{}, fresh, reason}

@unsafe
def no_schema(+book: List<&2, KDef>, +d: KDef, +firstFresh: U32) -> NO_Schema:
  nt_choose(NO_Schema, String.eq(dk(d), "Def") && Bool.not(nc_foreign(d) || nc_native_def(d)) && U32.is_le(nd_arity(book, dn(d)), 4) && U32.is_lt(firstFresh, 2147483600),
    u => nol_params(book, dt(d), Nil{}, Nil{}, Nil{}, Nil{}, firstFresh, 32, nd_arity(book, dn(d))), u => nol_failure("unsupported observer definition", firstFresh))

@unsafe
def nol_params(+book: List<&2, KDef>, +ty: KTerm, +params: List<&2, KTerm>, +roots: List<&2, U32>, +specs: List<&2, NO_Spec>, +seen: List<&2, U32>, +fresh: U32, +fuel: U32, +arity: U32) -> NO_Schema:
  nt_choose(NO_Schema, U32.is_eq(fuel, 0), u => nol_failure("parameter telescope budget", fresh),
    u => nol_param_head(book, nq_layout_type(book, ty), params, roots, specs, seen, fresh, U32.sub(fuel, 1), arity))

@unsafe
def nol_param_head(+book: List<&2, KDef>, +head: KTerm, +params: List<&2, KTerm>, +roots: List<&2, U32>, +specs: List<&2, NO_Spec>, +seen: List<&2, U32>, +fresh: U32, +fuel: U32, +arity: U32) -> NO_Schema:
  nt_choose(NO_Schema, String.eq(tg(head), "All"),
    u => nt_choose(NO_Schema, U32.is_eq(qt(head), 0),
      v => nol_params(book, kid(head, 1), params, roots, specs, Con{ix(head), seen}, fresh, fuel, arity),
      v => nol_param_type(book, head, nq_layout_type(book, kid(head, 0)), params, roots, specs, seen, fresh, fuel, arity)),
    u => nol_result(book, head, List.reverse(&2, KTerm, params), List.reverse(&2, U32, roots), specs, seen, fresh, arity))

@unsafe
def nol_param_type(+book: List<&2, KDef>, +head: KTerm, +ty: KTerm, +params: List<&2, KTerm>, +roots: List<&2, U32>, +specs: List<&2, NO_Spec>, +seen: List<&2, U32>, +fresh: U32, +fuel: U32, +arity: U32) -> NO_Schema:
  +rootSpecs = nol_root_specs(book, ty)
  +isRoot = Bool.not(List.is_empty(&2, NO_Spec, rootSpecs))
  nt_choose(NO_Schema, Bool.not(nq_layout_dep(ty, seen)) && (isRoot || nol_scalar(book, ty)) && U32.is_lt(terms_len(params), arity),
    u => nol_params(book, kid(head, 1), Con{var(nm(ty), nc_id(fresh)), params}, nt_choose(List<&2, U32>, isRoot, v => Con{terms_len(params), roots}, v => roots), List.append(&2, NO_Spec, rootSpecs, specs), Con{ix(head), seen}, U32.inc(fresh), fuel, arity),
    u => nol_failure("unsupported or dependent parameter", fresh))

@unsafe
def nol_result(+book: List<&2, KDef>, +ty: KTerm, +params: List<&2, KTerm>, +roots: List<&2, U32>, +specs: List<&2, NO_Spec>, +seen: List<&2, U32>, +fresh: U32, +arity: U32) -> NO_Schema:
  nt_choose(NO_Schema, U32.is_eq(terms_len(params), arity) && U32.is_ge(nt_count(U32, roots), 1) && U32.is_le(nt_count(U32, roots), 2) && Bool.not(nq_layout_dep(ty, seen)),
    u => nol_finish(book, params, roots, specs, fresh, nol_wrap(book, ty, params, roots, 0, "", nc_id(fresh))),
    u => nol_failure("observer requires one or two nondependent roots", fresh))

@unsafe
def nol_wrap_fail(+reason: String, +roots: List<&2, U32>, +shells: U32, +observation: String) -> NOL_Wrap:
  NOL_Wrap{atom("Absent"), roots, shells, observation, reason}

@unsafe
def nol_wrap(+book: List<&2, KDef>, +sourceType: KTerm, +params: List<&2, KTerm>, +roots: List<&2, U32>, +shells: U32, +observation: String, +result: U32) -> NOL_Wrap:
  +ty = nq_layout_type(book, sourceType)
  nt_choose(NOL_Wrap, Bool.not(List.is_empty(&2, NO_Spec, nol_root_specs(book, ty))),
    u => nol_wrap_root(ty, params, roots, shells, observation),
    u => nt_choose(NOL_Wrap, nol_scalar(book, ty),
      v => nt_choose(NOL_Wrap, String.eq(observation, ""), w => NOL_Wrap{var(nm(ty), result), roots, shells, nm(ty), ""}, w => nol_wrap_fail("multiple observations", roots, shells, observation)),
      v => nol_wrap_shell(book, ty, params, roots, shells, observation, result, dc(lookup(book, nm(ty))))))

@unsafe
def nol_wrap_root(+ty: KTerm, +params: List<&2, KTerm>, roots: List<&2, U32>, +shells: U32, +observation: String) -> NOL_Wrap:
  match roots:
    case Nil{}: nol_wrap_fail("extra returned root", Nil{}, shells, observation)
    case Con{+index, +rest}:
      +param = terms_at(params, index)
      nt_choose(NOL_Wrap, String.eq(nm(param), nm(ty)), u => NOL_Wrap{param, rest, shells, observation, ""}, u => nol_wrap_fail("root projection order or type", roots, shells, observation))

@unsafe
def nol_wrap_shell(+book: List<&2, KDef>, +ty: KTerm, +params: List<&2, KTerm>, +roots: List<&2, U32>, +shells: U32, +observation: String, +result: U32, ctors: List<&2, KDef>) -> NOL_Wrap:
  match ctors:
    case Con{+ctr, Nil{}}:
      +owner = lookup(book, nm(ty))
      +fields = nol_ctor_fields(book, ty, ctr)
      nt_choose(NOL_Wrap, U32.is_lt(shells, 2) && nol_owner(book, ty) && U32.is_ge(da(ctr), 1) && String.eq(tg(fields), "NO_Types") && (Bool.not(db(owner)) || (String.eq(dn(owner), "Sigma") && String.eq(dn(ctr), "Tuple") && U32.is_eq(da(ctr), 2))),
        u => nol_wrap_constructor(nc_ctor_identity(book, dn(ctr)), nol_wrap_fields(book, ks(fields), params, roots, U32.inc(shells), observation, result)),
        u => nol_wrap_fail("unsupported or excess result shell", roots, shells, observation))
    case _: nol_wrap_fail("result is not a fixed constructor", roots, shells, observation)

@unsafe
def nol_wrap_fields(+book: List<&2, KDef>, fields: List<&2, KTerm>, +params: List<&2, KTerm>, +roots: List<&2, U32>, +shells: U32, +observation: String, +result: U32) -> NOL_Wrap:
  match fields:
    case Nil{}: NOL_Wrap{kt("NO_WrapFields", "", 0, 0, Nil{}), roots, shells, observation, ""}
    case Con{+head, +rest}: nol_wrap_tail(book, rest, params, result, nol_wrap(book, head, params, roots, shells, observation, result))

@unsafe
def nol_wrap_tail(+book: List<&2, KDef>, +rest: List<&2, KTerm>, +params: List<&2, KTerm>, +result: U32, +head: NOL_Wrap) -> NOL_Wrap:
  match head:
    case NOL_Wrap{+term, +roots, +shells, +observation, +error}:
      nt_choose(NOL_Wrap, String.eq(error, ""), u => nol_wrap_cons(term, nol_wrap_fields(book, rest, params, roots, shells, observation, result)), u => head)

@unsafe
def nol_wrap_cons(+head: KTerm, tail: NOL_Wrap) -> NOL_Wrap:
  match tail:
    case NOL_Wrap{+term, +roots, +shells, +observation, +error}: NOL_Wrap{k_with_children(term, Con{head, ks(term)}), roots, shells, observation, error}

@unsafe
def nol_wrap_constructor(+ctor: String, fields: NOL_Wrap) -> NOL_Wrap:
  match fields:
    case NOL_Wrap{+term, +roots, +shells, +observation, +error}: NOL_Wrap{kt("Ctr", ctor, 0, 0, ks(term)), roots, shells, observation, error}

@unsafe
def nol_finish(+book: List<&2, KDef>, +params: List<&2, KTerm>, +roots: List<&2, U32>, +specs: List<&2, NO_Spec>, +fresh: U32, result: NOL_Wrap) -> NO_Schema:
  match result:
    case NOL_Wrap{+wrapper, +remaining, +shells, +observation, +error}:
      +reason = nt_choose(String, Bool.not(String.eq(error, "")), u => error, u => nt_choose(String, List.is_empty(&2, U32, remaining) && U32.is_gt(shells, 0) && Bool.not(String.eq(observation, "")), v => "", v => "result must contain every root once and one scalar"))
      +ready = nt_choose(List<&2, NO_Spec>, String.eq(reason, ""), u => List.append(&2, NO_Spec, specs, nol_scalar_specs(book, book)), u => Nil{})
      NO_Schema{params, roots, wrapper, nc_id(fresh), observation, ready, U32.inc(fresh), reason}

@unsafe
def no_schema_specs_layouts(specs: List<&2, NO_Spec>) -> List<&2, NO_Layout>:
  match specs:
    case Nil{}: Nil{}
    case Con{+spec, +rest}:
      match spec:
        case NO_Spec{+layout, +owner, +fields}: Con{layout, no_schema_specs_layouts(rest)}

@unsafe
def no_schema_spec(+key: String, specs: List<&2, NO_Spec>) -> Maybe<&2, NO_Spec>:
  match specs:
    case Nil{}: None{}
    case Con{+spec, +rest}:
      match spec:
        case NO_Spec{+layout, +owner, +fields}:
          match layout:
            case NO_Layout{+name, +ctor, +storage, +width}: nt_choose(Maybe<&2, NO_Spec>, String.eq(key, name), u => Some{spec}, u => no_schema_spec(key, rest))

@unsafe
def no_schema_params(schema: NO_Schema) -> List<&2, KTerm>:
  match schema:
    case NO_Schema{+params, +roots, +wrapper, +result, +observation, +specs, +fresh, +error}: params

@unsafe
def no_schema_roots(schema: NO_Schema) -> List<&2, U32>:
  match schema:
    case NO_Schema{+params, +roots, +wrapper, +result, +observation, +specs, +fresh, +error}: roots

@unsafe
def no_schema_wrapper(schema: NO_Schema) -> KTerm:
  match schema:
    case NO_Schema{+params, +roots, +wrapper, +result, +observation, +specs, +fresh, +error}: wrapper

@unsafe
def no_schema_result(schema: NO_Schema) -> U32:
  match schema:
    case NO_Schema{+params, +roots, +wrapper, +result, +observation, +specs, +fresh, +error}: result

@unsafe
def no_schema_observation(schema: NO_Schema) -> String:
  match schema:
    case NO_Schema{+params, +roots, +wrapper, +result, +observation, +specs, +fresh, +error}: observation

@unsafe
def no_schema_specs(schema: NO_Schema) -> List<&2, NO_Spec>:
  match schema:
    case NO_Schema{+params, +roots, +wrapper, +result, +observation, +specs, +fresh, +error}: specs

@unsafe
def no_schema_fresh(schema: NO_Schema) -> U32:
  match schema:
    case NO_Schema{+params, +roots, +wrapper, +result, +observation, +specs, +fresh, +error}: fresh

@unsafe
def no_schema_error(schema: NO_Schema) -> String:
  match schema:
    case NO_Schema{+params, +roots, +wrapper, +result, +observation, +specs, +fresh, +error}: error
