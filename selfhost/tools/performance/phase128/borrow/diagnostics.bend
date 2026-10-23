# Read-only diagnostics. These exports do not alter admission or emission.
# p128bs_plan_diagnostic needs only checked request analysis; readiness also
# performs the ordinary lowering once, never the candidate transformation.

@unsafe
def p128bs_flag(value: Bool) -> String:
  U32.show(Bool.to_u32(value))

@unsafe
def p128bs_plan_diagnostic(request: NR_Request, +owner: String) -> List<&2,String>:
  match request:
    case NR_Request{source,+book,names,paths,scope,bound}:
      +plan = no_observer_plan(book,owner,True{})
      +schema = no_plan_schema(plan)
      +wrapper = no_schema_wrapper(schema)
      +params = no_plan_params(no_schema_params(schema))
      ["owner=" ++ owner,
       "plan_error=" ++ no_plan_error(plan),
       "schema_error=" ++ no_schema_error(schema),
       "analysis_error=" ++ noa_error(no_plan_analysis(plan)),
       "wrapper=" ++ tg(wrapper) ++ ":" ++ nm(wrapper) ++ ":" ++ U32.show(ix(wrapper)),
       "observation=" ++ no_schema_observation(schema),
       "result=" ++ U32.show(no_schema_result(schema)),
       "roots=" ++ U32.show(nt_count(U32,no_schema_roots(schema))),
       "params=" ++ U32.show(nt_count(NC_Binding,params)),
       "existing_eligible=" ++ p128bs_flag(p118b_eligible(book,plan)),
       "residual_error=" ++ nt_choose(String,String.is_empty(no_plan_error(plan)),
         u => nc_error(no_emit(noa_body(no_plan_analysis(plan)),params,params,
           no_schema_specs_layouts(no_schema_specs(schema)),0)),u => "not-attempted")]

@unsafe
def p128bs_calls(body: List<&2,P113DStmt>) -> List<&2,String>:
  match body:
    case Nil{}: []
    case Con{P113DCall{destinations,target,args},rest}:
      Con{"call=" ++ target,p128bs_calls(rest)}
    case Con{P113DIf{condition,yes,no},rest}:
      nt_append(String,p128bs_calls(yes),nt_append(String,p128bs_calls(no),p128bs_calls(rest)))
    case Con{head,rest}: p128bs_calls(rest)

@unsafe
def p128bsd_find(+wanted: String, functions: List<&2,P113DFunction>) -> List<&2,String>:
  match functions:
    case Nil{}: ["ready=missing"]
    case Con{P113DFunction{+name,+params,+result,+public,+body},rest}:
      nt_choose(List<&2,String>,String.eq(name,wanted),
        u => nt_append(String,["ready=" ++ name,"public=" ++ p128bs_flag(public),
          "arity=" ++ U32.show(nt_count(NC_Binding,params)),
          "results=" ++ U32.show(result)],p128bs_calls(body)),
        u => p128bsd_find(wanted,rest))

@unsafe
def p128bs_ready_lowered(+wanted: String, lowered: P113ALowering) -> List<&2,String>:
  match lowered:
    case P113ALowered{P113AProgram{P113DProgram{static,functions},certificate},error}:
      Con{"lowering_error=" ++ error,p128bsd_find(wanted,functions)}

@unsafe
def p128bs_ready_diagnostic(+request: NR_Request, owner: String) -> List<&2,String>:
  match request:
    case NR_Request{source,book,names,paths,scope,bound}:
      p128bs_ready_lowered(p113d_public(book,owner),p113a_lower_request(request))
