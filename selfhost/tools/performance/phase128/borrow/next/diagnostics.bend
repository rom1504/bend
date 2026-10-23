@unsafe
def p128br_helper_names(helpers: List<&2,P128BRHelper>) -> List<&2,String>:
  match helpers:
    case Nil{}: []
    case Con{P128BRHelper{owner,params,roots,result,reader},rest}:
      Con{"helper=" ++ owner ++ ":" ++ result,p128br_helper_names(rest)}

@unsafe
def p128br_diagnose_lowered(+book: List<&2,KDef>, +names: List<&2,String>, +owner: String, lowered: P113ALowering) -> List<&2,String>:
  match lowered:
    case P113ALowered{+original,error}:
      +helpers = p128br_summaries(book,no_candidate_names(book,names,nc_bangs_names(book,names)),p128bs_original(original))
      +plan = p128br_plan(book,owner,helpers)
      +schema = no_plan_schema(plan)
      +params = no_plan_params(no_schema_params(schema))
      nt_append(String,["lowering_error=" ++ error,"owner=" ++ owner,
        "plan_error=" ++ no_plan_error(plan),"schema_error=" ++ no_schema_error(schema),
        "projected_residual_error=" ++ p128br_residual_error(plan),
        "eligible=" ++ U32.show(Bool.to_u32(p128br_eligible(book,plan))),
        "first_parameter=" ++ term_key(nq_layout_type(book,kid(nq_layout_type(book,dt(lookup(book,owner))),0))),
        "residual_error=" ++ nt_choose(String,String.is_empty(no_plan_error(plan)),
          u => p113d_error(p118b_lower(noa_body(no_plan_analysis(plan)),params,params,no_schema_specs_layouts(no_schema_specs(schema)),0)),u => "not-attempted")],
        p128br_helper_names(helpers))

@unsafe
def p128br_diagnose(+request: NR_Request, +owner: String) -> List<&2,String>:
  match request:
    case NR_Request{source,book,names,paths,scope,bound}:
      p128br_diagnose_lowered(book,names,owner,p113a_lower_request(request))
