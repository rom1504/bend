# Matched construction control: produce the genuine current generic IR AND the
# same raw direct workers, verify the generic IR, then emit only the same closed
# direct workers/policy as p163o. No fabricated generic program or certificate.
# This is an attribution control, not a proposed production pipeline.

type P163GRaw is Data:
  P163GRaw{+book: List<&2,KDef>, +lowered: P128RawLowering}
  P163GError{+error: String}

@unsafe
def p163g_selected(+source: List<&2,KDef>, +book: List<&2,KDef>, closure: NR_Closure) -> P163GRaw:
  match closure:
    case NR_Closure{+names,facts}:
      +fresh = ns_attach_book(book,facts,0,[])
      +error = p163d_source_names(fresh,names,nc_bangs_names(fresh,names))
      nt_choose(P163GRaw,String.is_empty(error),
        u => P163GRaw{fresh,p144o_catalogued(source,fresh,names,
          nc_add_ctors(nc_default_ctors(),
            p144o_constructors(source,source,p144o_payload(nc_ctor_context(book)))))},
        u => P163GError{error})

# This matches p163d_plan's source check, recomputed main closure, fresh facts
# and exact constructor recipe. p144o_catalogued then performs ONE authentic
# static preparation, generic lowering and direct-candidate/admission sequence.
@unsafe
def p163g_raw(request: NR_Request) -> P163GRaw:
  match request:
    case NR_Request{+source,+book,names,paths,scope,bound}:
      +error = nc_compile_error_known(source,bound)
      nt_choose(P163GRaw,String.is_empty(error),
        u => p163g_selected(source,book,nr_walk(book,["main"],[],[])),
        u => P163GError{"direct generic control request: " ++ error})

@unsafe
def p163g_checked(+book: List<&2,KDef>, original: P112StaticProgram,
    functions: List<&2,P113DFunction>, +error: String) -> P163DLibrary:
  match original:
    case P112StaticProgram{P111Program{segments,constructors,show,show_names,effects,pure},nodes}:
      nt_choose(P163DLibrary,String.is_empty(error),
        u => p163d_admitted(book,["main"],constructors,nodes,p163d_private(functions)),
        u => p163d_fail("direct generic control original verification: " ++ error))

# Generic verification traverses the real produced bodies and static image.
# Only afterward are their segments discarded. The unchanged closed verifier
# then checks the SAME direct worker list with zero scheduler identities.
@unsafe
def p163g_lowered(+book: List<&2,KDef>, lowered: P128RawLowering) -> P163DLibrary:
  match lowered:
    case P128RawLowering{P113DLowered{P113DProgram{+original,functions},+error},raw}:
      nt_choose(P163DLibrary,String.is_empty(error),
        u => p163g_checked(book,original,functions,p112s_verify(original)),
        u => p163d_fail("direct generic control lowering: " ++ error))

@unsafe
def p163g_closed(raw: P163GRaw) -> P163DLibrary:
  match raw:
    case P163GError{error}: p163d_fail(error)
    case P163GRaw{book,lowered}: p163g_lowered(book,lowered)

@unsafe
def p163g_finish_closed(+mode: U32, +request: NR_Request, +plan: P163DLibrary) -> P111Emission:
  match request:
    case NR_Request{source,book,names,paths,scope,bound}:
      p163x_library(source,book,nt_choose(P163DLibrary,U32.is_eq(mode,0),
        u => plan,u => p163o_apply(mode,request,plan)))

# The separately timed raw/finish API must receive its SAME checked request.
# p163g_executable enforces that association by construction. Raw timing includes
# common static/candidate work; do not label that whole interval generic-only.
@unsafe
def p163g_finish(+mode: U32, request: NR_Request, raw: P163GRaw) -> P111Emission:
  nt_choose(P111Emission,U32.is_lt(mode,4),
    u => p163g_finish_closed(mode,request,p163g_closed(raw)),
    u => P111Emission{[],"direct generic control mode must be 0..3"})

@unsafe
def p163g_executable(+mode: U32, +request: NR_Request) -> P111Emission:
  nt_choose(P111Emission,U32.is_lt(mode,4),
    u => p163g_finish(mode,request,p163g_raw(request)),
    u => P111Emission{[],"direct generic control mode must be 0..3"})

@unsafe
def p163g_summary(raw: P163GRaw) -> String:
  match raw:
    case P163GError{error}: "REFUSED: " ++ error
    case P163GRaw{book,P128RawLowering{P113DLowered{P113DProgram{
        P112StaticProgram{P111Program{segments,constructors,show,names,effects,pure},nodes},functions},+error},candidates}}:
      nt_choose(String,String.is_empty(error),
        u => "genericSegments=" ++ U32.show(nt_count(N111Segment,segments)) ++
          ";directFunctions=" ++ U32.show(nt_count(P113DFunction,functions)) ++
          ";rawCandidates=" ++ U32.show(nt_count(P113DCandidate,candidates)) ++
          ";constructors=" ++ U32.show(nt_count(N_Constructor,constructors)) ++
          ";staticWords=" ++ U32.show(p112s_size(nodes,0)),
        u => "REFUSED: " ++ error)
