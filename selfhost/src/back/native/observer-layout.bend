
# Module: src/back/native/observer-layout.bend:6
type NO_Spec is Data:
  NO_Spec{+layout: NO_Layout, +owner: String, +fields: List<&2, String>}

# Module: src/back/native/observer-layout.bend:9
type NO_Schema is Data:
  NO_Schema{+params: List<&2, KTerm>, +roots: List<&2, U32>, +wrapper: KTerm, +result: U32, +observation: String, +specs: List<&2, NO_Spec>, +fresh: U32, +error: String}

# Module: src/back/native/observer-layout.bend:12
type NOL_Wrap is Data:
  NOL_Wrap{+term: KTerm, +roots: List<&2, U32>, +shells: U32, +observation: String, +error: String}

# Module: src/back/native/observer-layout.bend:16
@unsafe
def nol_error(+reason: String) -> KTerm:
  kt("NO_Refusal", reason, 0, 0, Nil{})

# Module: src/back/native/observer-layout.bend:20
@unsafe
def nol_plain(+ty: KTerm) -> Bool:
  p98_tag_eq(ty, "ADT") && List.is_empty(&2, KTerm, ks(ty)) && List.is_empty(&2, String, rm(ty))

# Module: src/back/native/observer-layout.bend:24
@unsafe
def nol_owner(+book: List<&2, KDef>, +ty: KTerm) -> Bool:
  +d = lookup(book, nm(ty))
  p98_tag_eq(ty, "ADT") && List.is_empty(&2, String, rm(ty)) && p88_string_eq(dk(d), "ADT") && U32.is_eq(dx(d), 0) && U32.is_eq(terms_len(ks(ty)), da(d))

# Read exactly the declared live fields after specializing type parameters.
# All aliases/substitutions retain the existing 64-step/4096-node limits.
# Prior field dependencies and indexed constructor results decline. Unlike
# nq_layout_leaf, a nested Sigma is not rejected for sharing its owner's name.

# Module: src/back/native/observer-layout.bend:33
@unsafe
def nol_fields(+book: List<&2, KDef>, +ty: KTerm, +tel: KTerm, +left: U32, +seen: List<&2, U32>) -> KTerm:
  +head = nq_layout_type(book, tel)
  nt_choose(KTerm, U32.is_eq(left, 0),
    u => nt_choose(KTerm, p98_tag_eq(head, "ADT") && p88_string_eq(nm(head), nm(ty)) && List.is_empty(&2, String, rm(head)) && Bool.not(nq_layout_dep(head, seen)) && norm_exact_lists(ks(head), ks(ty)), v => kt("NO_Types", "", 0, 0, Nil{}), v => nol_error("indexed constructor result")),
    u => nt_choose(KTerm, p98_tag_eq(head, "All") && Bool.not(U32.is_eq(qt(head), 0)) && U32.is_le(left, 16),
      v => nol_field(book, ty, head, nq_layout_type(book, kid(head, 0)), left, seen), v => nol_error("constructor telescope")))

# Module: src/back/native/observer-layout.bend:41
@unsafe
def nol_field(+book: List<&2, KDef>, +ty: KTerm, +head: KTerm, +field: KTerm, +left: U32, +seen: List<&2, U32>) -> KTerm:
  nt_choose(KTerm, nol_owner(book, field) && Bool.not(nq_layout_dep(field, seen)),
    u => nol_field_cons(field, nol_fields(book, ty, kid(head, 1), U32.sub(left, 1), Con{ix(head), seen})),
    u => nol_error("dependent or unsupported constructor field"))

# Module: src/back/native/observer-layout.bend:47
@unsafe
def nol_field_cons(+field: KTerm, +tail: KTerm) -> KTerm:
  nt_choose(KTerm, p98_tag_eq(tail, "NO_Types"), u => k_with_children(tail, Con{field, ks(tail)}), u => tail)

# Module: src/back/native/observer-layout.bend:51
@unsafe
def nol_ctor_fields(+book: List<&2, KDef>, +ty: KTerm, +ctr: KDef) -> KTerm:
  nt_choose(KTerm, nol_owner(book, ty) && p88_string_eq(dk(ctr), "Ctr") && U32.is_eq(dx(ctr), 0) && U32.is_le(da(ctr), 16),
    u => nol_fields(book, ty, nq_layout_specialize(dt(ctr), ks(ty), 64), da(ctr), Nil{}),
    u => nol_error("constructor descriptor"))

# Module: src/back/native/observer-layout.bend:57
@unsafe
def nol_enum(+book: List<&2, KDef>, +ty: KTerm, ctors: List<&2, KDef>, +left: U32) -> Bool:
  match ctors:
    case Nil{}: True{}
    case Con{+ctr, +rest}:
      nt_choose(Bool, U32.is_gt(left, 0) && U32.is_eq(da(ctr), 0),
        u => p98_tag_eq(nol_ctor_fields(book, ty, ctr), "NO_Types") && nol_enum(book, ty, rest, U32.sub(left, 1)), u => False{})

# Module: src/back/native/observer-layout.bend:65
@unsafe
def nol_scalar(+book: List<&2, KDef>, +ty: KTerm) -> Bool:
  +d = lookup(book, nm(ty))
  nt_choose(Bool, nol_plain(ty) && nol_owner(book, ty),
    u => nt_choose(Bool, db(d) && nb_contains(["Nat", "Char", "U32", "F32"], dn(d)),
      v => True{}, v => Bool.not(List.is_empty(&2, KDef, dc(d))) && nol_enum(book, ty, dc(d), 32)), u => False{})

# Module: src/back/native/observer-layout.bend:72
@unsafe
def nol_type_names(types: List<&2, KTerm>) -> List<&2, String>:
  match types:
    case Nil{}: Nil{}
    case Con{+h, +rest}: Con{nm(h), nol_type_names(rest)}

# Module: src/back/native/observer-layout.bend:78
@unsafe
def nol_spec(+book: List<&2, KDef>, +owner: String, +ctr: KDef, +storage: String, +fields: List<&2, KTerm>) -> NO_Spec:
  +key = nc_ctor_identity(book, dn(ctr))
  NO_Spec{NO_Layout{key, key, storage, terms_len(fields)}, owner, nol_type_names(fields)}

# Module: src/back/native/observer-layout.bend:83
@unsafe
def nol_root_fields(+book: List<&2, KDef>, +owner: String, fields: List<&2, KTerm>, +recursive: U32) -> Bool:
  match fields:
    case Nil{}: U32.is_eq(recursive, 1)
    case Con{+h, +rest}:
      nt_choose(Bool, nol_plain(h) && p88_string_eq(nm(h), owner),
        u => U32.is_eq(recursive, 0) && nol_root_fields(book, owner, rest, 1),
        u => nol_scalar(book, h) && nol_root_fields(book, owner, rest, recursive))

# Module: src/back/native/observer-layout.bend:92
@unsafe
def nol_root_pair(+book: List<&2, KDef>, +ty: KTerm, +nil: KDef, +cons: KDef) -> List<&2, NO_Spec>:
  +empty = nol_ctor_fields(book, ty, nil)
  +fields = nol_ctor_fields(book, ty, cons)
  nt_choose(List<&2, NO_Spec>, U32.is_eq(da(nil), 0) && U32.is_ge(da(cons), 2) && p98_tag_eq(empty, "NO_Types") && p98_tag_eq(fields, "NO_Types") && nol_root_fields(book, nm(ty), ks(fields), 0),
    u => [nol_spec(book, nm(ty), nil, "Nullary", Nil{}), nol_spec(book, nm(ty), cons, "Boxed", ks(fields))], u => Nil{})

# Module: src/back/native/observer-layout.bend:99
@unsafe
def nol_root_ctors(+book: List<&2, KDef>, +ty: KTerm, ctors: List<&2, KDef>) -> List<&2, NO_Spec>:
  match ctors:
    case Con{+a, Con{+b, Nil{}}}:
      nt_choose(List<&2, NO_Spec>, U32.is_eq(da(a), 0), u => nol_root_pair(book, ty, a, b), u => nol_root_pair(book, ty, b, a))
    case _: Nil{}

# Module: src/back/native/observer-layout.bend:106
@unsafe
def nol_root_specs(+book: List<&2, KDef>, +ty: KTerm) -> List<&2, NO_Spec>:
  +d = lookup(book, nm(ty))
  nt_choose(List<&2, NO_Spec>, nol_plain(ty) && nol_owner(book, ty) && (Bool.not(db(d)) || p88_string_eq(dn(d), "String")),
    u => nol_root_ctors(book, ty, dc(d)), u => Nil{})

# Scalar readers are available to inlined helpers even if no entry parameter
# has the corresponding type. Word/Array and boxed primitive destructuring are
# intentionally absent. A native Nat remains conditional on runtime admission.

# Module: src/back/native/observer-layout.bend:115
@unsafe
def nol_scalar_ctors(+book: List<&2, KDef>, +ty: KTerm, ctors: List<&2, KDef>) -> List<&2, NO_Spec>:
  match ctors:
    case Nil{}: Nil{}
    case Con{+ctr, +rest}:
      +fields = nol_ctor_fields(book, ty, ctr)
      +storage = nt_choose(String, U32.is_eq(da(ctr), 0), u => "Nullary", u => nt_choose(String, p88_string_eq(nm(ty), "Nat") && p88_string_eq(dn(ctr), "Succ"), v => "Succ", v => nt_choose(String, p88_string_eq(nm(ty), "Char") && p88_string_eq(dn(ctr), "Chr"), w => "Char", w => "")))
      +tail = nol_scalar_ctors(book, ty, rest)
      nt_choose(List<&2, NO_Spec>, p98_tag_eq(fields, "NO_Types") && Bool.not(p88_string_eq(storage, "")), u => Con{nol_spec(book, nm(ty), ctr, storage, ks(fields)), tail}, u => tail)

# Module: src/back/native/observer-layout.bend:125
@unsafe
def nol_scalar_specs(+book: List<&2, KDef>, defs: List<&2, KDef>) -> List<&2, NO_Spec>:
  match defs:
    case Nil{}: Nil{}
    case Con{+d, +rest}:
      +ty = kt("ADT", dn(d), 0, 0, Nil{})
      nt_choose(List<&2, NO_Spec>, nt_choose(Bool, p88_string_eq(dk(d), "ADT"), v => nol_scalar(book, ty), v => False{}),
        u => List.append(&2, NO_Spec, nol_scalar_ctors(book, ty, dc(d)), nol_scalar_specs(book, rest)), u => nol_scalar_specs(book, rest))

# Module: src/back/native/observer-layout.bend:134
@unsafe
def nol_failure(+reason: String, +fresh: U32) -> NO_Schema:
  NO_Schema{Nil{}, Nil{}, {KTerm{"Absent", "", 0, 0, Nil{}, Nil{}, 0, 0} : KTerm}, 0, "", Nil{}, fresh, reason}

# Module: src/back/native/observer-layout.bend:138
@unsafe
def no_schema(+book: List<&2, KDef>, +d: KDef, +firstFresh: U32) -> NO_Schema:
  nt_choose(NO_Schema, p88_string_eq(dk(d), "Def") && Bool.not(nc_foreign(d) || nc_native_def(d)) && U32.is_le(nd_arity(book, dn(d)), 4) && U32.is_lt(firstFresh, 2147483600),
    u => nol_params(book, dt(d), Nil{}, Nil{}, Nil{}, Nil{}, firstFresh, 32, nd_arity(book, dn(d))), u => nol_failure("unsupported observer definition", firstFresh))

# Module: src/back/native/observer-layout.bend:143
@unsafe
def nol_params(+book: List<&2, KDef>, +ty: KTerm, +params: List<&2, KTerm>, +roots: List<&2, U32>, +specs: List<&2, NO_Spec>, +seen: List<&2, U32>, +fresh: U32, +fuel: U32, +arity: U32) -> NO_Schema:
  nt_choose(NO_Schema, U32.is_eq(fuel, 0), u => nol_failure("parameter telescope budget", fresh),
    u => nol_param_head(book, nq_layout_type(book, ty), params, roots, specs, seen, fresh, U32.sub(fuel, 1), arity))

# Module: src/back/native/observer-layout.bend:148
@unsafe
def nol_param_head(+book: List<&2, KDef>, +head: KTerm, +params: List<&2, KTerm>, +roots: List<&2, U32>, +specs: List<&2, NO_Spec>, +seen: List<&2, U32>, +fresh: U32, +fuel: U32, +arity: U32) -> NO_Schema:
  nt_choose(NO_Schema, p98_tag_eq(head, "All"),
    u => nt_choose(NO_Schema, U32.is_eq(qt(head), 0),
      v => nol_params(book, kid(head, 1), params, roots, specs, Con{ix(head), seen}, fresh, fuel, arity),
      v => nol_param_type(book, head, nq_layout_type(book, kid(head, 0)), params, roots, specs, seen, fresh, fuel, arity)),
    u => nol_result(book, head, List.reverse(&2, KTerm, params), List.reverse(&2, U32, roots), specs, seen, fresh, arity))

# Module: src/back/native/observer-layout.bend:156
@unsafe
def nol_param_type(+book: List<&2, KDef>, +head: KTerm, +ty: KTerm, +params: List<&2, KTerm>, +roots: List<&2, U32>, +specs: List<&2, NO_Spec>, +seen: List<&2, U32>, +fresh: U32, +fuel: U32, +arity: U32) -> NO_Schema:
  +rootSpecs = nol_root_specs(book, ty)
  +isRoot = Bool.not(List.is_empty(&2, NO_Spec, rootSpecs))
  nt_choose(NO_Schema, Bool.not(nq_layout_dep(ty, seen)) && (isRoot || nol_scalar(book, ty)) && U32.is_lt(terms_len(params), arity),
    u => nol_params(book, kid(head, 1), Con{var(nm(ty), nc_id(fresh)), params}, nt_choose(List<&2, U32>, isRoot, v => Con{terms_len(params), roots}, v => roots), List.append(&2, NO_Spec, rootSpecs, specs), Con{ix(head), seen}, U32.inc(fresh), fuel, arity),
    u => nol_failure("unsupported or dependent parameter", fresh))

# Module: src/back/native/observer-layout.bend:164
@unsafe
def nol_result(+book: List<&2, KDef>, +ty: KTerm, +params: List<&2, KTerm>, +roots: List<&2, U32>, +specs: List<&2, NO_Spec>, +seen: List<&2, U32>, +fresh: U32, +arity: U32) -> NO_Schema:
  nt_choose(NO_Schema, U32.is_eq(terms_len(params), arity) && U32.is_ge(nt_count(U32, roots), 1) && U32.is_le(nt_count(U32, roots), 2) && Bool.not(nq_layout_dep(ty, seen)),
    u => nol_finish(book, params, roots, specs, fresh, nol_wrap(book, ty, params, roots, 0, "", nc_id(fresh))),
    u => nol_failure("observer requires one or two nondependent roots", fresh))

# Module: src/back/native/observer-layout.bend:170
@unsafe
def nol_wrap_fail(+reason: String, +roots: List<&2, U32>, +shells: U32, +observation: String) -> NOL_Wrap:
  NOL_Wrap{{KTerm{"Absent", "", 0, 0, Nil{}, Nil{}, 0, 0} : KTerm}, roots, shells, observation, reason}

# Module: src/back/native/observer-layout.bend:174
@unsafe
def nol_wrap(+book: List<&2, KDef>, +sourceType: KTerm, +params: List<&2, KTerm>, +roots: List<&2, U32>, +shells: U32, +observation: String, +result: U32) -> NOL_Wrap:
  +ty = nq_layout_type(book, sourceType)
  nt_choose(NOL_Wrap, List.is_empty(&2, NO_Spec, nol_root_specs(book, ty)),
    u => nt_choose(NOL_Wrap, nol_scalar(book, ty),
      v => nt_choose(NOL_Wrap, p88_string_eq(observation, ""), w => NOL_Wrap{var(nm(ty), result), roots, shells, nm(ty), ""}, w => nol_wrap_fail("multiple observations", roots, shells, observation)),
      v => nol_wrap_shell(book, ty, params, roots, shells, observation, result, dc(lookup(book, nm(ty))))),
    u => nol_wrap_root(ty, params, roots, shells, observation))

# Module: src/back/native/observer-layout.bend:183
@unsafe
def nol_wrap_root(+ty: KTerm, +params: List<&2, KTerm>, roots: List<&2, U32>, +shells: U32, +observation: String) -> NOL_Wrap:
  match roots:
    case Nil{}: nol_wrap_fail("extra returned root", Nil{}, shells, observation)
    case Con{+index, +rest}:
      +param = terms_at(params, index)
      nt_choose(NOL_Wrap, p88_string_eq(nm(param), nm(ty)), u => NOL_Wrap{param, rest, shells, observation, ""}, u => nol_wrap_fail("root projection order or type", roots, shells, observation))

# Module: src/back/native/observer-layout.bend:191
@unsafe
def nol_wrap_shell(+book: List<&2, KDef>, +ty: KTerm, +params: List<&2, KTerm>, +roots: List<&2, U32>, +shells: U32, +observation: String, +result: U32, ctors: List<&2, KDef>) -> NOL_Wrap:
  match ctors:
    case Con{+ctr, Nil{}}:
      +owner = lookup(book, nm(ty))
      +fields = nol_ctor_fields(book, ty, ctr)
      nt_choose(NOL_Wrap, U32.is_lt(shells, 2) && nol_owner(book, ty) && U32.is_ge(da(ctr), 1) && p98_tag_eq(fields, "NO_Types") && (Bool.not(db(owner)) || (p88_string_eq(dn(owner), "Sigma") && p88_string_eq(dn(ctr), "Tuple") && U32.is_eq(da(ctr), 2))),
        u => nol_wrap_constructor(nc_ctor_identity(book, dn(ctr)), nol_wrap_fields(book, ks(fields), params, roots, U32.inc(shells), observation, result)),
        u => nol_wrap_fail("unsupported or excess result shell", roots, shells, observation))
    case _: nol_wrap_fail("result is not a fixed constructor", roots, shells, observation)

# Module: src/back/native/observer-layout.bend:202
@unsafe
def nol_wrap_fields(+book: List<&2, KDef>, fields: List<&2, KTerm>, +params: List<&2, KTerm>, +roots: List<&2, U32>, +shells: U32, +observation: String, +result: U32) -> NOL_Wrap:
  match fields:
    case Nil{}: NOL_Wrap{kt("NO_WrapFields", "", 0, 0, Nil{}), roots, shells, observation, ""}
    case Con{+head, +rest}: nol_wrap_tail(book, rest, params, result, nol_wrap(book, head, params, roots, shells, observation, result))

# Module: src/back/native/observer-layout.bend:208
@unsafe
def nol_wrap_tail(+book: List<&2, KDef>, +rest: List<&2, KTerm>, +params: List<&2, KTerm>, +result: U32, +head: NOL_Wrap) -> NOL_Wrap:
  match head:
    case NOL_Wrap{+term, +roots, +shells, +observation, +error}:
      nt_choose(NOL_Wrap, p88_string_eq(error, ""), u => nol_wrap_cons(term, nol_wrap_fields(book, rest, params, roots, shells, observation, result)), u => head)

# Module: src/back/native/observer-layout.bend:214
@unsafe
def nol_wrap_cons(+head: KTerm, tail: NOL_Wrap) -> NOL_Wrap:
  match tail:
    case NOL_Wrap{+term, +roots, +shells, +observation, +error}: NOL_Wrap{k_with_children(term, Con{head, ks(term)}), roots, shells, observation, error}

# Module: src/back/native/observer-layout.bend:219
@unsafe
def nol_wrap_constructor(+ctor: String, fields: NOL_Wrap) -> NOL_Wrap:
  match fields:
    case NOL_Wrap{+term, +roots, +shells, +observation, +error}: NOL_Wrap{kt("Ctr", ctor, 0, 0, ks(term)), roots, shells, observation, error}

# Module: src/back/native/observer-layout.bend:224
@unsafe
def nol_finish(+book: List<&2, KDef>, +params: List<&2, KTerm>, +roots: List<&2, U32>, +specs: List<&2, NO_Spec>, +fresh: U32, result: NOL_Wrap) -> NO_Schema:
  match result:
    case NOL_Wrap{+wrapper, +remaining, +shells, +observation, +error}:
      +reason = nt_choose(String, p88_string_eq(error, ""), u => nt_choose(String, ((List.is_empty(&2, U32, remaining) && U32.is_gt(shells, 0)) || (p98_tag_eq(wrapper, "Var") && U32.is_eq(ix(wrapper), nc_id(fresh)) && U32.is_eq(shells, 0))) && Bool.not(p88_string_eq(observation, "")), v => "", v => "result must contain every root once and one scalar"), u => error)
      +ready = nt_choose(List<&2, NO_Spec>, p88_string_eq(reason, ""), u => List.append(&2, NO_Spec, specs, nol_scalar_specs(book, book)), u => Nil{})
      NO_Schema{params, roots, wrapper, nc_id(fresh), observation, ready, U32.inc(fresh), reason}

# Module: src/back/native/observer-layout.bend:232
@unsafe
def no_schema_specs_layouts(specs: List<&2, NO_Spec>) -> List<&2, NO_Layout>:
  match specs:
    case Nil{}: Nil{}
    case Con{+spec, +rest}:
      match spec:
        case NO_Spec{+layout, +owner, +fields}: Con{layout, no_schema_specs_layouts(rest)}

# Module: src/back/native/observer-layout.bend:240
@unsafe
def no_schema_spec(+key: String, specs: List<&2, NO_Spec>) -> Maybe<&2, NO_Spec>:
  match specs:
    case Nil{}: None{}
    case Con{+spec, +rest}:
      match spec:
        case NO_Spec{+layout, +owner, +fields}:
          match layout:
            case NO_Layout{+name, +ctor, +storage, +width}: nt_choose(Maybe<&2, NO_Spec>, p88_string_eq(key, name), u => Some{spec}, u => no_schema_spec(key, rest))

# Module: src/back/native/observer-layout.bend:250
@unsafe
def no_schema_params(schema: NO_Schema) -> List<&2, KTerm>:
  match schema:
    case NO_Schema{+params, +roots, +wrapper, +result, +observation, +specs, +fresh, +error}: params

# Module: src/back/native/observer-layout.bend:255
@unsafe
def no_schema_roots(schema: NO_Schema) -> List<&2, U32>:
  match schema:
    case NO_Schema{+params, +roots, +wrapper, +result, +observation, +specs, +fresh, +error}: roots

# Module: src/back/native/observer-layout.bend:260
@unsafe
def no_schema_wrapper(schema: NO_Schema) -> KTerm:
  match schema:
    case NO_Schema{+params, +roots, +wrapper, +result, +observation, +specs, +fresh, +error}: wrapper

# Module: src/back/native/observer-layout.bend:265
@unsafe
def no_schema_result(schema: NO_Schema) -> U32:
  match schema:
    case NO_Schema{+params, +roots, +wrapper, +result, +observation, +specs, +fresh, +error}: result

# Module: src/back/native/observer-layout.bend:270
@unsafe
def no_schema_observation(schema: NO_Schema) -> String:
  match schema:
    case NO_Schema{+params, +roots, +wrapper, +result, +observation, +specs, +fresh, +error}: observation

# Module: src/back/native/observer-layout.bend:275
@unsafe
def no_schema_specs(schema: NO_Schema) -> List<&2, NO_Spec>:
  match schema:
    case NO_Schema{+params, +roots, +wrapper, +result, +observation, +specs, +fresh, +error}: specs

# Module: src/back/native/observer-layout.bend:280
@unsafe
def no_schema_fresh(schema: NO_Schema) -> U32:
  match schema:
    case NO_Schema{+params, +roots, +wrapper, +result, +observation, +specs, +fresh, +error}: fresh

# Module: src/back/native/observer-layout.bend:285
@unsafe
def no_schema_error(schema: NO_Schema) -> String:
  match schema:
    case NO_Schema{+params, +roots, +wrapper, +result, +observation, +specs, +fresh, +error}: error
