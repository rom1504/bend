# Bounded capability experiment: reuse the existing ordinary-worker closure
# after verified observer helpers become ready, before retrying scalar callers.
# Reuse the exact retained raw candidate catalogue from the actual entry.
# Existing source lowering and final projected verifier remain authoritative.

@unsafe
def p131p_has_product(helpers: List<&2,P128BRHelper>) -> Bool:
  match helpers:
    case Nil{}: False{}
    case Con{P128BRHelper{owner,params,roots,result,reader,wrapper,resultId},rest}:
      String.eq(tg(wrapper),"Ctr") || p131p_has_product(rest)

@unsafe
def p131p_scalar_helpers(helpers: List<&2,P128BRHelper>) -> List<&2,P128BRHelper>:
  match helpers:
    case Nil{}: []
    case Con{+head,+rest}:
      match head:
        case P128BRHelper{owner,params,roots,result,reader,wrapper,resultId}:
          nt_choose(List<&2,P128BRHelper>,String.eq(tg(wrapper),"Var"),
            u => Con{head,p131p_scalar_helpers(rest)},u => p131p_scalar_helpers(rest))

@unsafe
def p131p_retry(+book: List<&2,KDef>, +retry: List<&2,NO_Plan>, +closed: List<&2,P113DFunction>, +helpers: List<&2,P128BRHelper>) -> P128BRPatches:
  p128br_retry_plans(book,retry,closed,helpers)

@unsafe
def p131p_complete(+static: P112StaticProgram, +certificate: P113ACertificate, +closed: List<&2,P113DFunction>, patches: P128BRPatches) -> P111Emission:
  match patches:
    case P128BRPatches{edits,+error}:
      nt_choose(P111Emission,String.is_empty(error),
        u => p126bp_complete(static,certificate,p128br_apply(closed,edits)),
        u => P111Emission{[],"product projection retry: " ++ error})

@unsafe
def p131p_close(+raw: List<&2,P113DCandidate>, +book: List<&2,KDef>, original: P113AProgram, +added: List<&2,P113DFunction>, +helpers: List<&2,P128BRHelper>, +retry: List<&2,NO_Plan>) -> P111Emission:
  match original:
    case P113AProgram{P113DProgram{+static,+functions},+certificate}:
      +checked = p128br_check_added(static,added)
      nt_choose(P111Emission,String.is_empty(checked),u =>
        p131p_closed(raw,book,static,certificate,helpers,retry,
          nt_append(P113DFunction,added,p118b_without(functions,p113e_signatures(added,missing())))),
        u => P111Emission{[],"product projection helpers: " ++ checked})

@unsafe
def p131p_closed(+raw: List<&2,P113DCandidate>, +book: List<&2,KDef>, +static: P112StaticProgram, +certificate: P113ACertificate, +helpers: List<&2,P128BRHelper>, +retry: List<&2,NO_Plan>, +merged: List<&2,P113DFunction>) -> P111Emission:
  +closed = p113d_passes(raw,p113e_signatures(merged,missing()),nt_reverse(P113DFunction,merged,[]),32)
  p131p_complete(static,certificate,closed,p131p_retry(book,retry,closed,helpers))

@unsafe
def p128raw_br_scanned(+raw: List<&2,P113DCandidate>, +original: P113AProgram, +book: List<&2,KDef>, +source: List<&2,KDef>, +names: List<&2,String>, +cold: Bool, scan: P128BROpen) -> P111Emission:
  match scan:
    case P128BROpen{+functions,+helpers,+retry,+error}:
      nt_choose(P111Emission,String.is_empty(error),u =>
        p131p_scanned(raw,book,helpers,retry,functions,
          nt_choose(P113AProgram,cold,v => p118e_cold(original,book,source,nh_definitions(book,names,[])),v => original)),
        u => P111Emission{[],"borrowed profile: " ++ error})

@unsafe
def p131p_scanned(+raw: List<&2,P113DCandidate>, +book: List<&2,KDef>, +helpers: List<&2,P128BRHelper>, +retry: List<&2,NO_Plan>, +functions: List<&2,P113DFunction>, +original: P113AProgram) -> P111Emission:
  nt_choose(P111Emission,p131p_has_product(helpers) && Bool.not(List.is_empty(&2,NO_Plan,retry)),
    u => p131p_close(raw,book,original,functions,helpers,retry),
    u => p128raw_br_finish(raw,original,P118BWorkers{functions,""},p128br_retry_plans(book,retry,p128bs_original(original),helpers)))
