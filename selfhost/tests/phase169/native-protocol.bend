# Optional native-entry protocol successor. The hosted p169s_plan contract stays
# unchanged. Frontend/Base errors pass through; runtime admission owns compile:.

@unsafe
def p169np_admitted(+request: NR_Request, +error: String) -> P169Prepared:
  nt_choose(P169Prepared,String.is_empty(error),
    u => p169s_lowered(request,p168_request_mode(1,request)),
    u => p169s_fail("compile: " ++ error))

@unsafe
def p169np_plan(plan: P86Plan) -> P169Prepared:
  match plan:
    case P86PlanError{error}: p169s_fail(error)
    case P86PlanReady{+request,verdict}:
      p169np_admitted(request,p111_runtime_admission(request))

# Sole override: the same preparation and p86_plan run once. Accepted requests
# use the unchanged lower/verify/stream path; no text replacement or rechecking.
@unsafe
def p169n_prepared(+path: String, +source: String, prepared: P86Preparation) -> P169Prepared:
  match prepared:
    case P86PreparationError{error}: p169s_fail(error)
    case P86PreparationReady{seed}: p169np_plan(p86_plan(seed,path,source))
