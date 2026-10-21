# Exact observer admission conjunction, evaluated from left to right lazily.
# No predicate, permission, residual gate, or lowering decision is removed.
# In particular, accepted plans still pass the mature C residual emitter check.
# This is an isolated source candidate; it does not select or install a compiler.

@unsafe
def p118b_eligible(+book: List<&2,KDef>, +plan: NO_Plan) -> Bool:
  +schema = no_plan_schema(plan)
  +params = no_plan_params(no_schema_params(schema))
  +roots = no_schema_roots(schema)
  +wrapper = no_schema_wrapper(schema)
  +result = no_schema_result(schema)
  +env : List<&2,NC_Binding> = Con{NC_Binding{result,"p118b_observation",N_W64{}},params}
  nt_choose(Bool,String.is_empty(no_plan_error(plan)),u =>
    nt_choose(Bool,String.eq(dk(lookup(book,p118b_read_name(no_plan_owner(plan)))),"Absent"),u =>
      nt_choose(Bool,U32.is_gt(nt_count(U32,roots),0),u =>
        nt_choose(Bool,U32.is_le(nt_count(U32,roots),2),u =>
          nt_choose(Bool,Bool.not(String.eq(tg(wrapper),"Var")),u =>
            nt_choose(Bool,p118b_root_once(wrapper,no_schema_params(schema),roots,0),u =>
              nt_choose(Bool,U32.is_eq(nq_uses(wrapper,result),1),u =>
                nt_choose(Bool,no_wrapper_once(wrapper,env),u =>
                  nt_choose(Bool,U32.is_le(no_wrapper_nodes(book,wrapper,env,2),2),u =>
                    String.is_empty(nc_error(no_emit(noa_body(no_plan_analysis(plan)),params,params,
                      no_schema_specs_layouts(no_schema_specs(schema)),0))),
                    u => False{}),
                  u => False{}),
                u => False{}),
              u => False{}),
            u => False{}),
          u => False{}),
        u => False{}),
      u => False{}),
    u => False{})
