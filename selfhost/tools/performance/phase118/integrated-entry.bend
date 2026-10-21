# Production-shaped experimental entry: one checked request owns lowering,
# verification, sharing facts and derived observers. No caller-supplied plan or
# transformed IR is accepted here. Diagnostic APIs remain independently guarded.

# Keep candidate order, including each reader before its public adapter, without
# retaining one recursive stack frame per source definition. Each NO_Plan is
# analyzed once and consumed directly after the existing complete eligibility
# and mature residual checks have succeeded.
@unsafe
def p118e_workers(+book: List<&2,KDef>, names: List<&2,String>, +reversed: List<&2,P113DFunction>) -> P118BWorkers:
  match names:
    case Nil{}: P118BWorkers{nt_reverse(P113DFunction,reversed,[]),""}
    case Con{+name,+rest}:
      +plan = no_observer_plan(book,name,True{})
      nt_choose(P118BWorkers,p118b_eligible(book,plan),
        u => p118e_worker_result(book,rest,reversed,p118b_functions(book,name,plan)),
        u => p118e_workers(book,rest,reversed))

@unsafe
def p118e_worker_result(book: List<&2,KDef>, names: List<&2,String>, reversed: List<&2,P113DFunction>, workers: P118BWorkers) -> P118BWorkers:
  match workers:
    case P118BWorkers{functions,+error}:
      nt_choose(P118BWorkers,String.is_empty(error),
        u => p118e_workers(book,names,nt_reverse(P113DFunction,functions,reversed)),
        u => P118BWorkers{[],error})

# Empty additions need no second signature index. Nonempty additions retain the
# independent borrowed-function structural checker in p118b_compose, including
# exact constructor/arity checking of every readonly runtime import.
@unsafe
def p118e_emit_functions(+original: P113AProgram, +functions: List<&2,P113DFunction>) -> P111Emission:
  match functions:
    case Nil{}: P111Emission{p113a_admitted_chunks(original),""}
    case Con{head,rest}: p118b_compose(original,P118BWorkers{functions,""})

@unsafe
def p118e_emit_workers(original: P113AProgram, workers: P118BWorkers) -> P111Emission:
  match workers:
    case P118BWorkers{functions,+error}:
      nt_choose(P111Emission,String.is_empty(error),
        u => p118e_emit_functions(original,functions),
        u => P111Emission{[],"borrowed profile: " ++ error})

# This is an internal continuation of successful request-bound verification.
# Unknown sharing retains the entire original metadata, rather than asserting
# that an empty cold list is an independently established certificate.
@unsafe
def p118e_cold(+original: P113AProgram, book: List<&2,KDef>, source: List<&2,KDef>, +hot: List<&2,String>) -> P113AProgram:
  nt_choose(P113AProgram,nb_contains(hot,"*"),u => original,
    u => p118c_apply_verified(original,p118c_candidates(book,source,hot)))

@unsafe
def p118e_permitted(request: NR_Request, original: P113AProgram) -> P111Emission:
  match request:
    case NR_Request{source,+book,+names,paths,scope,bound}:
      +hot = nh_definitions(book,names,[])
      p118e_emit_workers(p118e_cold(original,book,source,hot),
        p118e_workers(book,no_candidate_names(book,names,nc_bangs_names(book,names)),[]))

# p113a_lower_request derives scalar permission from this same request. Reusing
# that result avoids another full ns_definitions traversal without strengthening
# permission: unshared is still used only by the original array profile.
@unsafe
def p118e_prepare(request: NR_Request, +original: P113AProgram) -> P111Emission:
  match original:
    case P113AProgram{program,P113ACertificate{scalar,unshared}}:
      nt_choose(P111Emission,scalar,u => p118e_permitted(request,original),
        u => P111Emission{p113a_admitted_chunks(original),""})

@unsafe
def p118e_verified(request: NR_Request, original: P113AProgram, +error: String) -> P111Emission:
  nt_choose(P111Emission,String.is_empty(error),u => p118e_prepare(request,original),
    u => P111Emission{[],"array structured IR: " ++ error})

@unsafe
def p118e_lowered(request: NR_Request, lowered: P113ALowering) -> P111Emission:
  match lowered:
    case P113ALowered{+program,+error}:
      nt_choose(P111Emission,String.is_empty(error),
        u => p118e_verified(request,program,p113a_verify(program)),
        u => P111Emission{[],"array native lowering: " ++ error})

# The sole override. Existing p111_emit_plan still performs runtime admission;
# lower_request retains source/bound checking and the original lowering passes.
# The original full verifier runs once before either derived transformation.
@unsafe
def p111_emit_admitted(+request: NR_Request, +error: String) -> P111Emission:
  nt_choose(P111Emission,String.is_empty(error),
    u => p118e_lowered(request,p113a_lower_request(request)),
    u => P111Emission{[],"compile: " ++ error})
