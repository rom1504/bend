

@unsafe
def p114s_ids(original: P112StaticProgram) -> N111Ids:
  match original:
    case P112StaticProgram{P111Program{segments,constructors,show,names,effects,pure},nodes}:
      N111Ids{p113e_originals(segments,missing()),ns_ctor_index(constructors,missing())}


@unsafe
def p114s_unchecked(program: P113DProgram) -> P114SBoundary:
  match program:
    case P113DProgram{original,functions}:
      P114SBoundary{original,N111Ids{missing(),missing()},functions,False{}}


@unsafe
def p114s_open_functions(original: P112StaticProgram, +functions: List<&2,P113DFunction>, +ids: N111Ids) -> P114SBoundary:
  P114SBoundary{original,ids,functions,String.is_empty(p113e_functions(functions,ids,missing()))}


@unsafe
def p114s_open_original(+original: P112StaticProgram, +functions: List<&2,P113DFunction>, error: String) -> P114SBoundary:
  nt_choose(P114SBoundary,String.is_empty(error),
    u => p114s_open_functions(original,functions,p114s_ids(original)),
    u => P114SBoundary{original,N111Ids{missing(),missing()},functions,False{}})

# Preserve original-verifier-before-direct-verifier ordering. A rejected input
# stays unchanged, as in both original optimizer wrappers. Its public final
# verifier still supplies the original diagnostic.


@unsafe
def p114s_open(program: P113DProgram) -> P114SBoundary:
  match program:
    case P113DProgram{+original,functions}:
      p114s_open_original(original,functions,p112s_verify(original))

# No candidate program/certificate is accepted here: only a transformed list.
# The original static image and IDs are retained from this exact session.


@unsafe
def p114s_commit(boundary: P114SBoundary, +candidate: List<&2,P113DFunction>) -> P114SBoundary:
  match boundary:
    case P114SBoundary{+original,+ids,+functions,+valid}:
      nt_choose(P114SBoundary,valid,
        u => nt_choose(P114SBoundary,String.is_empty(p113e_functions(candidate,ids,missing())),
          v => P114SBoundary{original,ids,candidate,True{}},
          v => P114SBoundary{original,ids,functions,True{}}),
        u => P114SBoundary{original,ids,functions,False{}})


@unsafe
def p114s_inline(+boundary: P114SBoundary) -> P114SBoundary:
  match boundary:
    case P114SBoundary{original,ids,functions,valid}:
      nt_choose(P114SBoundary,valid,
        u => p134v_commit(boundary,p113i_functions(functions,P113IEmpty{},[])),
        u => boundary)

@unsafe
def p114s_ranges(boundary: P114SBoundary) -> P114SBoundary:
  boundary

@unsafe
def p114s_close(boundary: P114SBoundary) -> P113DProgram:
  match boundary:
    case P114SBoundary{original,ids,functions,valid}: P113DProgram{original,functions}


@unsafe
def p114s_optimize(program: P113DProgram) -> P113DProgram:
  p114s_close(p114s_ranges(p114s_inline(p114s_open(program))))


@unsafe
def p114s_open_lowered(lowered: P113DLowering) -> P114SLowered:
  match lowered:
    case P113DLowered{+program,+error}:
      P114SLowered{nt_choose(P114SBoundary,String.is_empty(error),
        u => p114s_open(program),u => p114s_unchecked(program)),error}


@unsafe
def p114s_inline_lowered(lowered: P114SLowered) -> P114SLowered:
  match lowered:
    case P114SLowered{boundary,error}: P114SLowered{p114s_inline(boundary),error}


@unsafe
def p114s_ranges_lowered(lowered: P114SLowered) -> P114SLowered:
  match lowered:
    case P114SLowered{boundary,error}: P114SLowered{p114s_ranges(boundary),error}


@unsafe
def p114s_close_lowered(lowered: P114SLowered) -> P113DLowering:
  match lowered:
    case P114SLowered{boundary,error}: P113DLowered{p114s_close(boundary),error}


@unsafe
def p114s_lower_request(request: NR_Request) -> P113DLowering:
  p114s_close_lowered(p114s_ranges_lowered(p114s_inline_lowered(p114s_open_lowered(p113pl_lower_request(request)))))


@unsafe
def p114s_control_report() -> List<&2,String>:
  nt_append(String,p114st_case(0,"scaling-empty"),
  nt_append(String,p114st_case(1,"scaling-identity"),
  nt_append(String,p114st_case(2,"scaling-product-calls"),
  nt_append(String,p114st_case(3,"scaling-branch"),
  nt_append(String,p114st_case(4,"scaling-tail-loop"),p114st_case(5,"scaling-public-main"))))))

# Optional same-request check for small, genuinely checked source fixtures.
# Full compiler inputs should use the split driver and compare file pins;
# this control intentionally computes both pipelines and rendered strings.


@unsafe
def p114s_control_lowered(lowered: P113DLowering) -> Bool:
  match lowered:
    case P113DLowered{program,+error}:
      String.is_empty(error) && p114st_equivalent(program)


@unsafe
def p114s_control_request(request: NR_Request) -> Bool:
  p114s_control_lowered(p113pl_lower_request(request))


@unsafe
def p114ts_names(names: List<&2,String>, valid: Bool) -> Bool:
  match names:
    case Nil{}: valid
    case Con{name,rest}: p114ts_names(rest,valid && p114t_local_name(name))


@unsafe
def p114ts_params(params: List<&2,NC_Binding>, valid: Bool) -> Bool:
  match params:
    case Nil{}: valid
    case Con{NC_Binding{id,word,kind},rest}: p114ts_params(rest,valid && p114t_local_name(word))


@unsafe
def p114ts_scalar_list(body: List<&2,N111Stmt>, valid: Bool) -> Bool:
  match body:
    case Nil{}: valid
    case Con{head,rest}: p114ts_scalar_list(rest,valid && p114t_scalar_names(head))


@unsafe
def p114ts_body(body: List<&2,P113DStmt>, valid: Bool) -> Bool:
  match body:
    case Nil{}: valid
    case Con{P113DScalar{stmt},rest}: p114ts_body(rest,valid && p114t_scalar_names(stmt))
    case Con{P113DIf{condition,yes,no},rest}:
      p114ts_body(rest,valid && p114t_body_names(yes) && p114t_body_names(no))
    case Con{P113DCall{destinations,target,args},rest}: p114ts_body(rest,valid && p114t_names(destinations))
    case Con{head,rest}: p114ts_body(rest,valid)


@unsafe
def p114ts_functions(functions: List<&2,P113DFunction>, valid: Bool) -> Bool:
  match functions:
    case Nil{}: valid
    case Con{P113DFunction{name,params,result,public,body},rest}:
      p114ts_functions(rest,valid && p114t_params(params) && p114t_body_names(body))


@unsafe
def p114ts_segments(segments: List<&2,N111Segment>, valid: Bool) -> Bool:
  match segments:
    case Nil{}: valid
    case Con{N111Segment{name,arity,result,incoming,flags,body},rest}:
      p114ts_segments(rest,valid && p114t_scalar_list_names(body))
