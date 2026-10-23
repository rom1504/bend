# Preserve every existing residual layout/binder/arity gate in no_emit. Only
# a derived NO_ReadCall value receives a structural placeholder, after all of
# its argument atoms have passed the same environment check. Actual call types,
# target/order and results also pass the complete independent direct verifier.
# Replacing a call by zero here is not a semantic equivalence claim.

@unsafe
def p128br_project_call(+value: KTerm, +env: List<&2,NC_Binding>) -> KTerm:
  nt_choose(KTerm,String.eq(tg(value),"NO_ReadCall"),
    u => nt_choose(KTerm,no_atoms_valid(ks(value),env) && Bool.not(String.is_empty(nm(value))),
      v => kt("NWord","0",0,0,[]),v => atom("Absent")),u => value)

@unsafe
def p128br_project_residual(+t: KTerm, +env: List<&2,NC_Binding>) -> KTerm:
  nt_choose(KTerm,String.eq(tg(t),"NO_Let") && U32.is_eq(terms_len(ks(t)),2),
    u => k_with_children(t,[p128br_project_call(kid(t,0),env),
      p128br_project_residual(kid(t,1),Con{nc_binding(ix(t)),env})]),
    u => nt_choose(KTerm,String.eq(tg(t),"NO_Match") && U32.is_eq(terms_len(ks(t)),4),
      v => k_with_children(t,[kid(t,0),kid(t,1),
        p128br_project_residual(kid(t,2),no_bind_fields(ks(kid(t,1)),env)),
        p128br_project_residual(kid(t,3),env)]),v => t))

@unsafe
def p128br_residual_error(+plan: NO_Plan) -> String:
  +schema = no_plan_schema(plan)
  +params = no_plan_params(no_schema_params(schema))
  nc_error(no_emit(p128br_project_residual(noa_body(no_plan_analysis(plan)),params),
    params,params,no_schema_specs_layouts(no_schema_specs(schema)),0))
