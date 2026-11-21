# Only complete verified equations are accepted; no function spelling is a rule.
@unsafe
def p205o_law_found(+book: List<&2,KDef>, state: Maybe<&2,KDef>) -> Bool:
  match state:
    case None{}: False{}
    case Some{roles}: String.eq(dk(p111v_get(roles,"append")),"String.append") && j_primitive_definition(book,lookup(book,"U32.is_eq"),2)

@unsafe
def p205o_law(+book: List<&2,KDef>, +join: String, +split: String) -> Bool:
  +r0 = p111v_put(p111v_put(missing(),"join",join,0,0),"split",split,0,0)
  +r1 = p205_verify(book,Some{r0},"join",p205_join_equation())
  +r2 = p205_verify(book,r1,"split",p205_split_equation())
  +r3 = p205_verify(book,r2,"join_rest",p205_join_rest_equation())
  +r4 = p205_verify(book,r3,"pick",p205_pick_equation())
  +r5 = p205_verify(book,r4,"push",p205_push_equation())
  p205o_law_found(book,p205_verify(book,r5,"append",p205_append_equation()))

@unsafe
def p205o_inner(+context: List<&2,KDef>, +replace: String, +join: KTerm, +split: KTerm) -> KTerm:
  kc(KTerm,U32.is_eq(terms_len(ks(join)),2) && U32.is_eq(terms_len(ks(split)),2) &&
      p205_atom(j_strip(kid(join,0)),atom("Absent")) && p205_atom(j_strip(kid(split,0)),atom("Absent")),
    u => kc(KTerm,p205o_law(context,nm(join),nm(split)),
      v => p205o_call(replace,kid(join,0),kid(split,0),kid(split,1)),v => atom("Absent")),u => atom("Absent"))

@unsafe
def p205o_attempt(+context: List<&2,KDef>, +replace: String, +t: KTerm) -> KTerm:
  +join = j_call_spine(j_strip(t),[])
  kc(KTerm,U32.is_eq(terms_len(ks(join)),2),
    u => p205o_inner(context,replace,join,j_call_spine(j_strip(kid(join,1)),[])),u => atom("Absent"))

type P205OWalk is Data:
  P205OWalk{+term: KTerm, +changed: Bool}
type P205OKids is Data:
  P205OKids{+kids: List<&2,KTerm>, +changed: Bool}

@unsafe
def p205o_walk(+context: List<&2,KDef>, +replace: String, +t: KTerm) -> P205OWalk:
  +rewrite = p205o_attempt(context,replace,t)
  kc(P205OWalk,p98_tag_eq(rewrite,"Absent"),
    u => p205o_walk_children(t,p205o_kids(context,replace,ks(t))),u => P205OWalk{rewrite,True{}})

@unsafe
def p205o_walk_children(+t: KTerm, found: P205OKids) -> P205OWalk:
  match found:
    case P205OKids{kids,+changed}: P205OWalk{kc(KTerm,changed,u => k_with_children(t,kids),u => t),changed}

@unsafe
def p205o_kids(+context: List<&2,KDef>, +replace: String, kids: List<&2,KTerm>) -> P205OKids:
  match kids:
    case Nil{}: P205OKids{[],False{}}
    case Con{h,t}: p205o_kids_join(p205o_walk(context,replace,h),p205o_kids(context,replace,t))

@unsafe
def p205o_kids_join(head: P205OWalk, tail: P205OKids) -> P205OKids:
  match head tail:
    case P205OWalk{term,changed} P205OKids{kids,more}: P205OKids{Con{term,kids},changed || more}

@unsafe
def p205o_record(+raw: KDef, +edits: KDef, result: P205OWalk) -> KDef:
  match result:
    case P205OWalk{term,changed}: kc(KDef,changed,u => index_set(edits,dg_event_output(raw,term),index_hash(dn(raw),2166136261),32),u => edits)

@unsafe
def p205o_collect(+context: List<&2,KDef>, +replace: String, defs: List<&2,KDef>, +edits: KDef) -> KDef:
  match defs:
    case Nil{}: edits
    case Con{+d,rest}:
      +raw = lookup(context,dn(d))
      +next = kc(KDef,String.eq(dk(raw),"Def") && Bool.not(db(raw)) && U32.is_eq(dx(raw),0) &&
          Bool.not(p98_tag_eq(dv(raw),"Foreign")) && Bool.not(p98_tag_eq(dv(raw),"Absent")),
        u => p205o_record(raw,edits,p205o_walk(context,replace,dv(raw))),u => edits)
      p205o_collect(context,replace,rest,next)

# All changed bodies are checked again in the extended context. A single failure
# abandons the whole optional one-pass phase, including both synthetic helpers.
@unsafe
def p205o_check_edits(+context: List<&2,KDef>, defs: List<&2,KDef>, +edits: KDef, +checked: KDef) -> Maybe<&2,KDef>:
  match defs:
    case Nil{}: Some{checked}
    case Con{+d,+rest}:
      +change = p111v_get(edits,dn(d))
      kc(Maybe<&2,KDef>,String.eq(dk(change),"Absent"),u => p205o_check_edits(context,rest,edits,checked),
        u => p205o_edit_checked(context,rest,edits,checked,p205_recheck(context,change)))

@unsafe
def p205o_edit_checked(+context: List<&2,KDef>, +rest: List<&2,KDef>, +edits: KDef, +checked: KDef, +change: KDef) -> Maybe<&2,KDef>:
  kc(Maybe<&2,KDef>,String.eq(dk(change),"Absent"),u => None{},
    u => p205o_check_edits(context,rest,edits,index_set(checked,change,index_hash(dn(change),2166136261),32)))

@unsafe
def p205o_commit_checked(+oldContext: List<&2,KDef>, +stops: List<&2,String>, +verdict: String,
  +original: List<&2,KDef>, +context: List<&2,KDef>, +helpers: List<&2,KDef>, checked: Maybe<&2,KDef>) -> P86Plan:
  match checked:
    case None{}: P86PlanReady{nr_prepare_annotated(oldContext,original),verdict}
    case Some{edits}: p205o_final(oldContext,stops,verdict,original,context,List.append(&2,KDef,helpers,p205_overlay(original,edits)))

@unsafe
def p205o_final(+oldContext: List<&2,KDef>, +stops: List<&2,String>, +verdict: String,
  +original: List<&2,KDef>, +context: List<&2,KDef>, +candidate: List<&2,KDef>) -> P86Plan:
  kc(P86Plan,String.is_empty(jl_checked_error(context,candidate,["main"],stops)),
    u => P86PlanReady{nr_prepare_annotated(context,candidate),verdict},
    u => P86PlanReady{nr_prepare_annotated(oldContext,original),verdict})

@unsafe
def p205o_commit(+oldContext: List<&2,KDef>, +stops: List<&2,String>, +verdict: String,
  +original: List<&2,KDef>, +edits: KDef, result: Maybe<&2,P205OHelpers>) -> P86Plan:
  match result:
    case None{}: P86PlanReady{nr_prepare_annotated(oldContext,original),verdict}
    case Some{P205OHelpers{+context,helpers,emit,replace,bound}}:
      p205o_commit_checked(oldContext,stops,verdict,original,context,helpers,p205o_check_edits(context,original,edits,missing()))

@unsafe
def p205o_admitted(+context: List<&2,KDef>, +stops: List<&2,String>, +verdict: String,
  +original: List<&2,KDef>, +base: U32, +emit: String, +replace: String, +edits: KDef) -> P86Plan:
  kc(P86Plan,String.eq(dk(edits),"Absent"),u => P86PlanReady{nr_prepare_annotated(context,original),verdict},
    u => p205o_commit(context,stops,verdict,original,edits,p205o_prepare(context,base,emit,replace)))

@unsafe
def p205o_named(+context: List<&2,KDef>, +stops: List<&2,String>, +verdict: String,
  +original: List<&2,KDef>, +base: U32, +emit: String, +replace: String) -> P86Plan:
  kc(P86Plan,U32.is_lt(base,4294901760) && String.eq(dk(lookup(context,emit)),"Absent") && String.eq(dk(lookup(context,replace)),"Absent"),
    u => p205o_admitted(context,stops,verdict,original,base,emit,replace,p205o_collect(context,replace,original,missing())),
    u => P86PlanReady{nr_prepare_annotated(context,original),verdict})

# Cheap signature discovery only on already-selected reachable definitions.
# Stop on finding both; do not inspect a single body on a negative request.
@unsafe
def p205o_signatures(defs: List<&2,KDef>, +split: Bool, +join: Bool) -> Bool:
  kc(Bool,split && join,u => True{},u => p205o_signatures_more(defs,split,join))

@unsafe
def p205o_signatures_more(defs: List<&2,KDef>, +split: Bool, +join: Bool) -> Bool:
  match defs:
    case Nil{}: False{}
    case Con{+d,rest}:
      +eligible = String.eq(dk(d),"Def") && Bool.not(db(d)) && U32.is_eq(dx(d),0)
      p205o_signatures(rest,split || (eligible && p205_signature(dt(d),["U32","String","Strings"])),
        join || (eligible && p205_signature(dt(d),["String","Strings","String"])))

# Count actual reachable definitions, not source bytes or benchmark identities.
# Large compiler requests keep their original preparation path.
@unsafe
def p205o_bounded(defs: List<&2,KDef>, +remaining: U32) -> Bool:
  match defs:
    case Nil{}: True{}
    case Con{d,rest}: kc(Bool,U32.is_eq(remaining,0),u => False{},u => p205o_bounded(rest,U32.sub(remaining,1)))

@unsafe
def p205o_start(+context: List<&2,KDef>, +stops: List<&2,String>, +verdict: String, +original: List<&2,KDef>) -> P86Plan:
  kc(P86Plan,p205o_bounded(original,1024),u =>
    kc(P86Plan,p205o_signatures(original,False{},False{}),v => p205o_start_admitted(context,stops,verdict,original),
      v => P86PlanReady{nr_prepare_annotated(context,original),verdict}),
    u => P86PlanReady{nr_prepare_annotated(context,original),verdict})

@unsafe
def p205o_start_admitted(+context: List<&2,KDef>, stops: List<&2,String>, verdict: String, original: List<&2,KDef>) -> P86Plan:
  +base = norm_book_bound(context)
  p205o_named(context,stops,verdict,original,base,"$p205.one.emit." ++ U32.show(base),"$p205.one.replace." ++ U32.show(base))
