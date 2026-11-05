# Isolated reuse of maintained transformations on the actual closed plan.
# Modes: 0 original; 1 bounded inlining/scalar facts; 2 rederived cold metadata;
# 3 both. No generic segments, generic-program certificates, or borrowed imports.
# Current p114s_ranges is an intentional no-op; the inliner already calls the
# maintained p113k_function scalar pass for eligible function bodies.

def p163o_enabled(mode: U32, bit: U32) -> Bool:
  Bool.not(U32.is_eq(U32.and(mode,bit),0))

@unsafe
def p163o_covered(exports: List<&2,P163DExport>, +names: List<&2,String>) -> Bool:
  match exports:
    case Nil{}: True{}
    case Con{P163DExport{source,owner,arity},rest}:
      nb_contains(names,source) && p163o_covered(rest,names)

# The closed library and this request come from the same p163o_plan invocation.
# Reuse the independently derived source sharing analysis, not a caller-supplied
# cold list. Uncovered exports or unknown sharing retain all existing hot flags.
@unsafe
def p163o_cold(+request: NR_Request, +exports: List<&2,P163DExport>,
    +constructors: List<&2,N_Constructor>) -> List<&2,N_Constructor>:
  match request:
    case NR_Request{source,book,names,paths,scope,bound}:
      nt_choose(List<&2,N_Constructor>,p163o_covered(exports,names),
        u => p163o_cold_checked(constructors,p118c_plan(request)),u => constructors)

@unsafe
def p163o_cold_checked(+constructors: List<&2,N_Constructor>, plan: P118CPlan) -> List<&2,N_Constructor>:
  match plan:
    case P118CPlan{request,hot,cold,valid,error}:
      nt_choose(List<&2,N_Constructor>,valid && String.is_empty(error),
        u => p118c_ctors(constructors,cold),u => constructors)

# This checks the unchanged final direct/static verifier on the real catalogue.
# It does not assert that that structural verifier proves ownership analysis;
# cold eligibility remains the unchanged source-derived sharing predicate above.
@unsafe
def p163o_commit(+exports: List<&2,P163DExport>, +constructors: List<&2,N_Constructor>,
    +nodes: List<&2,P112SNode>, +functions: List<&2,P113DFunction>) -> P163DLibrary:
  +error = p163d_verify(constructors,nodes,functions)
  nt_choose(P163DLibrary,String.is_empty(error),
    u => P163DLibrary{exports,constructors,nodes,functions,"",""},
    u => p163d_fail("direct optimization final verification: " ++ error))

@unsafe
def p163o_apply(+mode: U32, request: NR_Request, plan: P163DLibrary) -> P163DLibrary:
  match plan:
    case P163DLibrary{+exports,+constructors,+nodes,+functions,text,+error}:
      nt_choose(P163DLibrary,String.is_empty(error),
        u => p163o_commit(exports,
          nt_choose(List<&2,N_Constructor>,p163o_enabled(mode,2),
            v => p163o_cold(request,exports,constructors),v => constructors),nodes,
          nt_choose(List<&2,P113DFunction>,p163o_enabled(mode,1),
            v => p113i_functions(functions,P113IEmpty{},[]),v => functions)),
        u => p163d_fail(error))

@unsafe
def p163o_plan(+mode: U32, +request: NR_Request, +roots: List<&2,String>) -> P163DLibrary:
  nt_choose(P163DLibrary,U32.is_lt(mode,4),
    u => nt_choose(P163DLibrary,U32.is_eq(mode,0),
      v => p163d_plan(request,roots),v => p163o_apply(mode,request,p163d_plan(request,roots))),
    u => p163d_fail("direct optimization mode must be 0..3"))

@unsafe
def p163o_executable_mode(mode: U32, +request: NR_Request) -> P111Emission:
  match request:
    case NR_Request{source,book,names,paths,scope,bound}:
      p163x_library(source,book,p163o_plan(mode,request,["main"]))

@unsafe
def p163o_executable(request: NR_Request) -> P111Emission:
  p163o_executable_mode(3,request)

@unsafe
def p163o_library(mode: U32, request: NR_Request, roots: List<&2,String>) -> P163DLibrary:
  p163d_render(p163o_plan(mode,request,roots))

# Structural controls complement the actual full-result runtime oracles.
@unsafe
def p163o_controls() -> List<&2,String>:
  +functions : List<&2,P113DFunction> = [p163dc_id(),p163dc_call("p163.id")]
  [p163dc_row("inline-final-closed-verifier",
     String.is_empty(p163d_verify([],[],p113i_functions(functions,P113IEmpty{},[])))),
   p163dc_row("inline-does-not-authorize-unknown-call",Bool.not(String.is_empty(
     p163d_verify([],[],p113i_functions([p163dc_call("absent")],P113IEmpty{},[]))))),
   p163dc_row("cold-uncovered-export-refused",Bool.not(p163o_covered([P163DExport{"missing","missing",0}],["main"]))),
   p163dc_row("cold-known-export-covered",p163o_covered([P163DExport{"main","renamed.main",0}],["main"]))]
