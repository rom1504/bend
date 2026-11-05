# OPTIONAL second candidate. Keep this module out of the broad-discovery
# snapshot. Only the successful mixed-open continuation invokes this path.
# The emitted generic/static fields are reconstructed from that retained value;
# no hash, pointer identity or full-body comparison grants authority.
@unsafe
def p164i_ctor_schema(old: List<&2,N_Constructor>, candidate: List<&2,N_Constructor>) -> Bool:
  match old candidate:
    case Nil{} Nil{}: True{}
    case Con{N_Constructor{name,arity,hot},rest} Con{N_Constructor{other,count,cold},tail}:
      String.eq(name,other) && U32.is_eq(arity,count) && p164i_ctor_schema(rest,tail)
    case _ _: False{}

@unsafe
def p164i_verified(+book: List<&2,KDef>, +bangs: List<&2,String>, +adapters: KDef,
    +program: P113AProgram, +headers: KDef) -> P111Emission:
  match program:
    case P113AProgram{P113DProgram{original,+functions},certificate}:
      p164i_obligations(program,p164v_obligations(adapters,book,bangs,headers,p113e_signatures(functions,missing())))

@unsafe
def p164i_obligations(+program: P113AProgram, +error: String) -> P111Emission:
  match program:
    case P113AProgram{+direct,+certificate}:
      nt_choose(P111Emission,String.is_empty(error),
        u => p164h_final_error(P134Admitted{program},p164v_final_original(program,direct,certificate,"")),
        u => P111Emission{[],"hybrid retained obligations: " ++ error})

@unsafe
def p164i_rebuild(+book: List<&2,KDef>, +bangs: List<&2,String>, +adapters: KDef,
    retained: P112StaticProgram, certificate: P113ACertificate, +constructors: List<&2,N_Constructor>, functions: List<&2,P113DFunction>) -> P111Emission:
  match retained:
    case P112StaticProgram{P111Program{+segments,+old,show,names,effects,pure},nodes}:
      nt_choose(P111Emission,p164i_ctor_schema(old,constructors),
        u => p164i_headers(book,bangs,adapters,
          P113AProgram{P113DProgram{P112StaticProgram{P111Program{segments,constructors,show,names,effects,pure},nodes},functions},certificate},
          p111v_functions(segments,P111VScan{missing(),"",0})),
        u => P111Emission{[],"hybrid retained constructor schema changed"})

@unsafe
def p164i_headers(book: List<&2,KDef>, bangs: List<&2,String>, adapters: KDef,
    +program: P113AProgram, scan: P111VScan) -> P111Emission:
  match scan:
    case P111VScan{headers,+error,count}:
      nt_choose(P111Emission,String.is_empty(error),u => p164i_verified(book,bangs,adapters,program,headers),
        u => P111Emission{[],"hybrid retained header schema: " ++ error})

@unsafe
def p164i_plan(book: List<&2,KDef>, bangs: List<&2,String>, adapters: KDef,
    retained: P112StaticProgram, certificate: P113ACertificate, plan: P134EmissionPlan) -> P111Emission:
  match plan:
    case P134Admitted{P113AProgram{P113DProgram{P112StaticProgram{P111Program{segments,constructors,show,names,effects,pure},nodes},functions},changed}}:
      p164i_rebuild(book,bangs,adapters,retained,certificate,constructors,functions)
    case _: P111Emission{[],"hybrid retained unexpected non-admitted plan"}

@unsafe
def p164i_final(book: List<&2,KDef>, bangs: List<&2,String>, adapters: KDef,
    retained: P112StaticProgram, certificate: P113ACertificate, emission: P111Emission) -> P111Emission:
  match emission:
    case P111Emission{chunks,+error}:
      nt_choose(P111Emission,String.is_empty(error),
        u => P111Emission{[],"hybrid unexpected materialized success"},u => P111Emission{[],error})
    case P134Planned{plan}: p164i_plan(book,bangs,adapters,retained,certificate,plan)

# Override only the private continuation after successful original checking.
# Its all-function error argument is still produced by p147d actual-ID checking.
@unsafe
def p164h_functions(+request: NR_Request, +book: List<&2,KDef>, +bangs: List<&2,String>, +adapters: KDef,
    +raw: List<&2,P113DCandidate>, +original: P112StaticProgram, +functions: List<&2,P113DFunction>, +ids: N111Ids, +error: String) -> P111Emission:
  +certificate : P113ACertificate = p113a_certificate(request)
  nt_choose(P111Emission,String.is_empty(error),u =>
    p164i_final(book,bangs,adapters,original,certificate,p146c_finish(request,certificate,raw,
      p114s_ranges_lowered(p114s_inline_lowered(P114SLowered{P114SBoundary{original,ids,functions,True{}},""})))),
    u => P111Emission{[],"hybrid direct verification: " ++ error})
