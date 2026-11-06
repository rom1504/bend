# Independent optional ablation. Every True condition is identical to the
# maintained p128bs_eligible; expensive stages run only after prior admission.

@unsafe
def p169e_emit(+plan: NO_Plan, +schema: NO_Schema) -> Bool:
  +params = no_plan_params(no_schema_params(schema))
  String.is_empty(nc_error(no_emit(noa_body(no_plan_analysis(plan)),params,params,
    no_schema_specs_layouts(no_schema_specs(schema)),0)))

@unsafe
def p169e_names(+book: List<&2,KDef>, +plan: NO_Plan, +schema: NO_Schema) -> Bool:
  nt_choose(Bool,String.eq(dk(lookup(book,p118b_read_name(no_plan_owner(plan)))),"Absent"),
    u => nt_choose(Bool,String.eq(dk(lookup(book,p128bs_owned(no_plan_owner(plan)))),"Absent"),
      v => p169e_emit(plan,schema),v => False{}),u => False{})

@unsafe
def p169e_roots(+book: List<&2,KDef>, +plan: NO_Plan, +schema: NO_Schema, +wrapper: KTerm) -> Bool:
  +count = nt_count(U32,no_schema_roots(schema))
  nt_choose(Bool,U32.is_ge(count,1) && U32.is_le(count,2),
    u => nt_choose(Bool,nol_scalar(book,kt("ADT",nm(wrapper),0,0,[])),
      v => p169e_names(book,plan,schema),v => False{}),u => False{})

@unsafe
def p169e_shape(+book: List<&2,KDef>, +plan: NO_Plan, +schema: NO_Schema) -> Bool:
  +wrapper = no_schema_wrapper(schema)
  nt_choose(Bool,String.eq(tg(wrapper),"Var") &&
    U32.is_eq(ix(wrapper),no_schema_result(schema)) &&
    String.eq(nm(wrapper),no_schema_observation(schema)),
    u => p169e_roots(book,plan,schema,wrapper),u => False{})

@unsafe
def p128bs_eligible(+book: List<&2,KDef>, +plan: NO_Plan) -> Bool:
  nt_choose(Bool,String.is_empty(no_plan_error(plan)),
    u => p169e_shape(book,plan,no_plan_schema(plan)),u => False{})
