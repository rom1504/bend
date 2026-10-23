# Compose request-local raw candidate reuse with the existing single observer
# scan. Only p128raw_prepare is replaced; original production gates stay intact.
# p128br_apply remains the separately selected patch-composition implementation.

@unsafe
def p128raw_br_compose(+raw: List<&2,P113DCandidate>, original: P113AProgram, workers: P118BWorkers, +patches: List<&2,P128BRPatch>) -> P111Emission:
  match original workers:
    case P113AProgram{P113DProgram{+static,+functions},certificate} P118BWorkers{+added,+error}:
      +checked = p111_first(error,p128br_check_added(static,added))
      +merged = nt_append(P113DFunction,added,p118b_without(functions,p113e_signatures(added,missing())))
      nt_choose(P111Emission,String.is_empty(checked),
        u => p126bp_complete(static,certificate,p128br_apply(nt_choose(List<&2,P113DFunction>,p126bp_has_flat(added),
          v => p113d_passes(raw,p113e_signatures(merged,missing()),nt_reverse(P113DFunction,merged,[]),32),
          v => merged),patches)),
        u => P111Emission{[],"borrowed helper base: " ++ checked})

@unsafe
def p128raw_br_finish(+raw: List<&2,P113DCandidate>, +original: P113AProgram, +workers: P118BWorkers, patches: P128BRPatches) -> P111Emission:
  match patches:
    case P128BRPatches{+edits,+error}:
      nt_choose(P111Emission,Bool.not(String.is_empty(error)),u => P111Emission{[],"borrowed helper plan: " ++ error},
        u => nt_choose(P111Emission,List.is_empty(&2,P128BRPatch,edits),
          v => p128raw_integrated(raw,original,workers),
          v => p128raw_br_compose(raw,original,workers,edits)))

@unsafe
def p128raw_br_scanned(+raw: List<&2,P113DCandidate>, +original: P113AProgram, +book: List<&2,KDef>, +source: List<&2,KDef>, +names: List<&2,String>, +cold: Bool, scan: P128BROpen) -> P111Emission:
  match scan:
    case P128BROpen{functions,+helpers,retry,+error}:
      nt_choose(P111Emission,String.is_empty(error),
        u => p128raw_br_finish(raw,
          nt_choose(P113AProgram,cold,v => p118e_cold(original,book,source,nh_definitions(book,names,[])),v => original),
          P118BWorkers{functions,""},
          p128br_retry_plans(book,retry,p128bs_original(original),helpers)),
        u => P111Emission{[],"borrowed profile: " ++ error})

@unsafe
def p128raw_br_prepare(request: NR_Request, raw: List<&2,P113DCandidate>, +original: P113AProgram, cold: Bool) -> P111Emission:
  match request:
    case NR_Request{+source,+book,+names,paths,scope,bound}:
      p128raw_br_scanned(raw,original,book,source,names,cold,
        p128br_scan(book,no_candidate_names(book,names,nc_bangs_names(book,names)),p128bs_original(original),[],[],[]))

@unsafe
def p128raw_prepare(+request: NR_Request, +raw: List<&2,P113DCandidate>, +original: P113AProgram) -> P111Emission:
  match original:
    case P113AProgram{program,P113ACertificate{scalar,unshared}}:
      nt_choose(P111Emission,scalar,u => p128raw_br_prepare(request,raw,original,True{}),u =>
        nt_choose(P111Emission,p118i_permission(request),
          v => p128raw_br_prepare(request,raw,original,False{}),v => P111Emission{p113a_admitted_chunks(original),""}))

@unsafe
def p128raw_br_controls() -> List<&2,String>:
  +request = p128rawc_request()
  +original = p128rawc_original()
  +workers : P118BWorkers = P118BWorkers{[],"control"}
  +patch : P128BRPatch = P128BRPatch{"absent",[]}
  [p126bpc_row("combined-observer-error-exact",p128rawc_same(
     p128raw_br_scanned([],original,[],[],[],True{},P128BROpen{[],[],[],"control"}),
     p128br_scanned(request,original,[],[],[],True{},P128BROpen{[],[],[],"control"}))),
   p126bpc_row("combined-helper-error-exact",p128rawc_same(
     p128raw_br_finish([],original,workers,P128BRPatches{[],"control"}),
     p128br_finish(request,original,workers,P128BRPatches{[],"control"}))),
   p126bpc_row("combined-base-error-exact",p128rawc_same(
     p128raw_br_compose([],original,workers,[patch]),p128br_compose(request,original,workers,[patch]))),
   p126bpc_row("combined-empty-patch-worker-error-exact",p128rawc_same(
     p128raw_br_finish([],original,workers,P128BRPatches{[],""}),
     p128br_finish(request,original,workers,P128BRPatches{[],""})))]
