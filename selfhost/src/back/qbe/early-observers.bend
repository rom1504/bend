

# Independent final admission of the actual demand-lowered program.
# Adapter bodies are checked exactly; all other bodies use the original verifier.
# No synthetic original body, producer validity bit or registry is trusted.

@unsafe
def p167v_allowed(+book: List<&2,KDef>, +source: String, +bangs: List<&2,String>, +ready: KDef) -> Bool:
  +definition = lookup(book,source)
  +arity = nd_arity(book,source)
  +signature = p111v_get(ready,p113d_public(book,source))
  String.eq(dk(definition),"Def") && Bool.not(nc_native_def(definition) || nc_foreign(definition) || nb_contains(bangs,source)) &&
    U32.is_le(arity,32) && String.eq(dk(signature),"P113Direct") &&
    U32.is_eq(da(signature),arity) && U32.is_eq(dx(signature),1) && U32.is_eq(ix(dv(signature)),0)



# Independent mixed original boundary. Generic bodies still use the unchanged
# verifier. Exact adapters are checked against source, headers AND final workers.
@unsafe
def p167v_obligation(+entry: KDef, +book: List<&2,KDef>, +bangs: List<&2,String>, +headers: KDef, +ready: KDef) -> Bool:
  +owner = dn(entry)
  +source = nm(dt(entry))
  +header = p111v_get(headers,owner)
  String.eq(dk(entry),"P164Adapter") && String.eq(tg(dt(entry)),"Ref") &&
    String.eq(owner,p113d_public(book,source)) && U32.is_eq(da(entry),nd_arity(book,source)) &&
    p167v_allowed(book,source,bangs,ready) && String.eq(dk(header),"function") &&
    U32.is_eq(da(header),da(entry)) && U32.is_eq(dx(header),0)



@unsafe
def p167v_bucket(entries: List<&2,KDef>, +book: List<&2,KDef>, +bangs: List<&2,String>, +headers: KDef, +ready: KDef) -> String:
  match entries:
    case Nil{}: ""
    case Con{+head,rest}:
      nt_choose(String,p167v_obligation(head,book,bangs,headers,ready),
        u => p167v_bucket(rest,book,bangs,headers,ready),
        u => "demand adapter source/header/final-worker obligation: " ++ dn(head))



@unsafe
def p167v_obligations(tree: KDef, +book: List<&2,KDef>, +bangs: List<&2,String>, +headers: KDef, +ready: KDef) -> String:
  match tree:
    case KIndexLeaf{hash,bucket}: p167v_bucket(bucket,book,bangs,headers,ready)
    case KIndexNode{hash,mask,left,right}:
      p111_first(p167v_obligations(left,book,bangs,headers,ready),p167v_obligations(right,book,bangs,headers,ready))
    case KDef{name,kind,arity,templates,typ,value,ctors,native,unsafe}:
      nt_choose(String,String.eq(kind,"Absent"),u => "",u => "demand invalid adapter map")



@unsafe
def p167v_one(+segment: N111Segment, +ids: N111Ids, adapters: KDef) -> String:
  match segment:
    case N111Segment{+name,+arity,result,incoming,flags,body}:
      +entry = p111v_get(adapters,name)
      nt_choose(String,String.eq(dk(entry),"Absent"),u => p111v_segment(segment,ids),u =>
        nt_choose(String,String.eq(dk(entry),"P164Adapter") && U32.is_eq(da(entry),arity) && p164a_shape(segment),
          v => "",v => "demand adapter body/header mismatch: " ++ name))



@unsafe
def p167v_segments(segments: List<&2,N111Segment>, +ids: N111Ids, +adapters: KDef) -> String:
  match segments:
    case Nil{}: ""
    case Con{head,rest}:
      p167v_segment_done(rest,ids,adapters,p167v_one(head,ids,adapters))



@unsafe
def p167v_segment_done(+rest: List<&2,N111Segment>, +ids: N111Ids, +adapters: KDef, +error: String) -> String:
  nt_choose(String,String.is_empty(error),u => p167v_segments(rest,ids,adapters),u => error)



@unsafe
def p167v_scans(+book: List<&2,KDef>, +bangs: List<&2,String>, +program: P113DProgram, +adapters: KDef,
    functions: P111VScan, constructors: P111VScan) -> String:
  match program functions constructors:
    case P113DProgram{+original,+direct} P111VScan{+fs,+fe,fc} P111VScan{+cs,+ce,cc}:
      +main = p111v_get(fs,"main")
      nt_choose(String,Bool.not(String.is_empty(fe)),u => fe,u =>
      nt_choose(String,Bool.not(String.is_empty(ce)),u => ce,u =>
      nt_choose(String,String.eq(dk(main),"Absent") || Bool.not(U32.is_eq(da(main),0)) || Bool.not(U32.is_eq(dx(main),0)),
        u => "program requires a direct, zero-argument main segment",u =>
        p167v_catalogued(original,N111Ids{fs,cs},adapters,
          p167v_obligations(adapters,book,bangs,fs,p113e_signatures(direct,missing()))))))



@unsafe
def p167v_catalogued(+original: P112StaticProgram, +ids: N111Ids, +adapters: KDef, +error: String) -> String:
  match original:
    case P112StaticProgram{P111Program{segments,ctors,show,names,effects,pure},nodes}:
      nt_choose(String,String.is_empty(error),u =>
        p111_first(p167v_segments(segments,ids,adapters),p112s_image_error(original)),u => error)



@unsafe
def p167v_original(+book: List<&2,KDef>, +bangs: List<&2,String>, +program: P113DProgram, +adapters: KDef) -> String:
  match program:
    case P113DProgram{P112StaticProgram{P111Program{segments,ctors,show,names,effects,pure},nodes},functions}:
      p167v_scans(book,bangs,program,adapters,p111v_functions(segments,P111VScan{missing(),"",0}),
        p111v_constructors(ctors,P111VScan{missing(),"",0}))



# All final workers are private. Public entry behavior is the independently
# authenticated actual adapter, not an emitter's choice to replace a generic body.
@unsafe
def p167v_private(functions: List<&2,P113DFunction>) -> Bool:
  match functions:
    case Nil{}: True{}
    case Con{P113DFunction{name,params,result,public,body},rest}:
      Bool.not(public) && p167v_private(rest)


# Additive attribution control: identical demand lowering/final admission and
# inherited segment/direct emission; only the checked live-register bit differs.
# p111q_segment_chunks still invokes the existing generic registry internally;
# retaining that behavior isolates this control from a no-registry treatment.
# Exact adapters are authenticated by p167v_final before this renderer is used.

@unsafe
def p167live_eligible(program: P113DProgram) -> Bool:
  match program:
    case P113DProgram{P112StaticProgram{P111Program{segments,ctors,show,names,effects,pure},nodes},+functions}:
      Bool.not(List.is_empty(&2,P113DFunction,functions)) &&
        p118z_segments(p164a_generic(segments,[])) && p118z_functions(functions)


# General observer-first experiment. Source permission and the unchanged
# source-derived observer/root-retention analysis precede any seeded admission.
# No source name is special-cased, and no fictitious scheduler header is made.

@unsafe
def p167ob_permission(+request: NR_Request) -> Bool:
  match request:
    case NR_Request{source,book,names,paths,scope,bound}:
      nt_choose(Bool,ns_definitions(book,names),u => True{},u => p118i_permission(request))



# Private early checking claims no scheduler ABI. Real constructors are checked
# independently; empty FIDs reject any seed needing an unmaterialized identity.
# Source-derived owning wrappers keep their original public marker only while
# selecting exact source/arity substitutions; every final function is private.
@unsafe
def p167ob_seed_checked(+constructors: List<&2,N_Constructor>, +functions: List<&2,P113DFunction>, scan: P111VScan) -> String:
  match scan:
    case P111VScan{index,+error,count}:
      +ids : N111Ids = N111Ids{missing(),ns_ctor_index(constructors,missing())}
      nt_choose(String,String.is_empty(error),
        u => p118b_verify_projected(ids,p118b_project_functions(p167l_private(functions),ids)),
        u => error)



@unsafe
def p167ob_seed_verify(+constructors: List<&2,N_Constructor>, functions: List<&2,P113DFunction>) -> String:
  p167ob_seed_checked(constructors,functions,p111v_constructors(constructors,P111VScan{missing(),"",0}))



# Skip a raw source candidate only if the independently checked source worker
# supplies its exact ordinary boxed ABI. Other source names retain old lowering.
@unsafe
def p167ob_remaining(+book: List<&2,KDef>, names: List<&2,String>, +bangs: List<&2,String>, +ready: KDef) -> List<&2,String>:
  match names:
    case Nil{}: []
    case Con{+name,+rest}:
      nt_choose(List<&2,String>,p164a_allowed(book,name,bangs,ready),
        u => p167ob_remaining(book,rest,bangs,ready),
        u => Con{name,p167ob_remaining(book,rest,bangs,ready)})



# Keep actual generic/static/adapter admission, then use the maintained borrowed
# projection checker on ALL actual final private workers and actual final IDs.
# Projection does not establish source lifetime permission; p167ob_request does.
@unsafe
def p167ob_direct(+program: P113DProgram, +error: String) -> String:
  match program:
    case P113DProgram{P112StaticProgram{+original,nodes},+functions}:
      nt_choose(String,String.is_empty(error),u =>
        nt_choose(String,p167v_private(functions),
          v => p118b_verify_functions(functions,original),
          v => "observer first final worker must be private"),u => error)



@unsafe
def p167ob_final(+book: List<&2,KDef>, +bangs: List<&2,String>, +adapters: KDef, +program: P113DProgram) -> String:
  p167ob_direct(program,p167v_original(book,bangs,program,adapters))



# Reuse cached NO_Plans. Only genuine independently checkable leaf fallbacks
# enter p128bs_find; unavailable/nonleaf owners remain for the consumer retry.
@unsafe
def p168_scalars(+book: List<&2,KDef>, plans: List<&2,NO_Plan>, +original: List<&2,P113DFunction>,
    functions: List<&2,P113DFunction>, helpers: List<&2,P128BRHelper>, retry: List<&2,NO_Plan>) -> P128BROpen:
  match plans:
    case Nil{}: P128BROpen{nt_reverse(P113DFunction,functions,[]),
      nt_reverse(P128BRHelper,helpers,[]),nt_reverse(NO_Plan,retry,[]),""}
    case Con{+plan,rest}:
      p168_scalar_ready(book,rest,original,functions,helpers,retry,plan,
        nt_choose(P118BWorkers,p128bs_eligible(book,plan),
          u => p128bs_find(book,no_plan_owner(plan),plan,original),u => P118BWorkers{[],""}))



@unsafe
def p168_scalar_ready(+book: List<&2,KDef>, +rest: List<&2,NO_Plan>, +original: List<&2,P113DFunction>,
    +functions: List<&2,P113DFunction>, +helpers: List<&2,P128BRHelper>, +retry: List<&2,NO_Plan>,
    +plan: NO_Plan, +workers: P118BWorkers) -> P128BROpen:
  match workers:
    case P118BWorkers{+added,+error}:
      nt_choose(P128BROpen,String.is_empty(error),
        u => p168_scalars(book,rest,original,nt_reverse(P113DFunction,added,functions),
          nt_reverse(P128BRHelper,p128br_seed(no_plan_owner(plan),no_plan_schema(plan),workers),helpers),
          nt_choose(List<&2,NO_Plan>,List.is_empty(&2,P113DFunction,added),v => Con{plan,retry},v => retry)),
        u => P128BROpen{[],[],[],error})



@unsafe
def p168_stats(lowered: P167Lowered, extra: List<&2,U32>) -> P167Lowered:
  match lowered:
    case P167Lowered{program,adapters,error,stats}:
      P167Lowered{program,adapters,error,nt_append(U32,stats,extra)}



@unsafe
def p168_finished(source: List<&2,KDef>, book: List<&2,KDef>, names: List<&2,String>,
    constructors: List<&2,N_Constructor>, nodes: List<&2,P112SNode>, bangs: List<&2,String>,
    stats: List<&2,U32>, +functions: List<&2,P113DFunction>, patches: P128BRPatches) -> P167Lowered:
  match patches:
    case P128BRPatches{+edits,+error}:
      nt_choose(P167Lowered,String.is_empty(error),
        u => p168_finish_functions(source,book,names,constructors,nodes,bangs,
          nt_append(U32,stats,[nt_count(P128BRPatch,edits)]),p128br_apply(functions,edits)),
        u => p167l_fail("early scalar consumer retry: " ++ error))



@unsafe
def p168_finish_functions(source: List<&2,KDef>, book: List<&2,KDef>, names: List<&2,String>,
    constructors: List<&2,N_Constructor>, nodes: List<&2,P112SNode>, bangs: List<&2,String>,
    stats: List<&2,U32>, +functions: List<&2,P113DFunction>) -> P167Lowered:
  p168_stats(p167l_functions(source,book,names,constructors,nodes,bangs,functions),
    nt_append(U32,stats,[nt_count(P113DFunction,functions)]))



@unsafe
def p168_retry(source: List<&2,KDef>, +book: List<&2,KDef>, names: List<&2,String>,
    constructors: List<&2,N_Constructor>, nodes: List<&2,P112SNode>, bangs: List<&2,String>,
    stats: List<&2,U32>, +functions: List<&2,P113DFunction>, +helpers: List<&2,P128BRHelper>,
    +retry: List<&2,NO_Plan>) -> P167Lowered:
  p168_finished(source,book,names,constructors,nodes,bangs,
    nt_append(U32,stats,[nt_count(P128BRHelper,helpers),nt_count(NO_Plan,retry)]),functions,
    p128br_retry_plans(book,retry,functions,helpers))



@unsafe
def p168_scalar_verified(source: List<&2,KDef>, book: List<&2,KDef>, names: List<&2,String>,
    constructors: List<&2,N_Constructor>, nodes: List<&2,P112SNode>, bangs: List<&2,String>,
    stats: List<&2,U32>, functions: List<&2,P113DFunction>, +added: List<&2,P113DFunction>,
    helpers: List<&2,P128BRHelper>, retry: List<&2,NO_Plan>, +error: String) -> P167Lowered:
  nt_choose(P167Lowered,String.is_empty(error),
    u => p168_retry(source,book,names,constructors,nodes,bangs,
      nt_append(U32,stats,[nt_count(P113DFunction,added)]),
      nt_append(P113DFunction,added,p118b_without(functions,p113e_signatures(added,missing()))),helpers,retry),
    u => p167l_fail("early scalar closed-worker verification: " ++ error))



@unsafe
def p168_scalar_result(source: List<&2,KDef>, book: List<&2,KDef>, names: List<&2,String>,
    +constructors: List<&2,N_Constructor>, nodes: List<&2,P112SNode>, bangs: List<&2,String>,
    stats: List<&2,U32>, functions: List<&2,P113DFunction>, scan: P128BROpen) -> P167Lowered:
  match scan:
    case P128BROpen{+added,helpers,retry,+error}:
      nt_choose(P167Lowered,String.is_empty(error),
        u => p168_scalar_verified(source,book,names,constructors,nodes,bangs,stats,functions,added,helpers,retry,
          p167ob_seed_verify(constructors,added)),
        u => p167l_fail("early scalar production: " ++ error))



@unsafe
def p168_inlined(source: List<&2,KDef>, +book: List<&2,KDef>, names: List<&2,String>,
    constructors: List<&2,N_Constructor>, nodes: List<&2,P112SNode>, bangs: List<&2,String>,
    stats: List<&2,U32>, helpers: List<&2,P128BRHelper>, retry: List<&2,NO_Plan>,
    +functions: List<&2,P113DFunction>) -> P167Lowered:
  p168_scalar_result(source,book,names,constructors,nodes,bangs,stats,functions,
    p168_scalars(book,retry,functions,[],nt_reverse(P128BRHelper,helpers,[]),[]))



# New internal mode2 differs only at the protected ordinary-composition step.
# The old mode1 and mode0 bodies are copied exactly from the admission treatment.
@unsafe
def p168_closed(+mode: U32, +source: List<&2,KDef>, +book: List<&2,KDef>, +names: List<&2,String>,
    +constructors: List<&2,N_Constructor>, +nodes: List<&2,P112SNode>, +bangs: List<&2,String>,
    +stats: List<&2,U32>, +helpers: List<&2,P128BRHelper>, +retry: List<&2,NO_Plan>,
    +seeds: KDef, +functions: List<&2,P113DFunction>) -> P167Lowered:
  +stats = nt_append(U32,stats,[nt_count(P113DFunction,functions)])
  nt_choose(P167Lowered,U32.is_eq(mode,2),
    u => p169o_closed(source,book,names,constructors,nodes,bangs,stats,helpers,
      p169q_plans(book,retry),seeds,functions),
    u => nt_choose(P167Lowered,U32.is_eq(mode,1),
      v => p169q_closed(source,book,names,constructors,nodes,bangs,stats,helpers,
        p169q_plans(book,retry),seeds,functions),
      v => p168_inlined(source,book,names,constructors,nodes,bangs,stats,helpers,retry,functions)))



@unsafe
def p168_candidates(+mode: U32, source: List<&2,KDef>, book: List<&2,KDef>, +names: List<&2,String>,
    constructors: List<&2,N_Constructor>, nodes: List<&2,P112SNode>, bangs: List<&2,String>,
    +remaining: U32, +workers: List<&2,P113DFunction>, helpers: List<&2,P128BRHelper>,
    retry: List<&2,NO_Plan>, +raw: List<&2,P113DCandidate>) -> P167Lowered:
  +ready = p113e_signatures(workers,missing())
  p168_closed(mode,source,book,names,constructors,nodes,bangs,
    [mode,U32.sub(nt_count(String,names),remaining),nt_count(P113DFunction,workers),remaining,nt_count(P113DCandidate,raw)],
    helpers,retry,ready,p113d_passes(p126sc_candidates(raw),ready,nt_reverse(P113DFunction,workers,[]),32))



@unsafe
def p168_selected(mode: U32, source: List<&2,KDef>, +book: List<&2,KDef>, +names: List<&2,String>,
    constructors: List<&2,N_Constructor>, nodes: List<&2,P112SNode>, +bangs: List<&2,String>,
    workers: List<&2,P113DFunction>, helpers: List<&2,P128BRHelper>, retry: List<&2,NO_Plan>,
    +remaining: List<&2,String>) -> P167Lowered:
  p168_candidates(mode,source,book,names,constructors,nodes,bangs,nt_count(String,remaining),workers,helpers,retry,
    p113pl_candidates(book,remaining,bangs,book_cached(nq_signatures(book,names),0)))



@unsafe
def p168_seed_verified(mode: U32, source: List<&2,KDef>, +book: List<&2,KDef>, +names: List<&2,String>,
    constructors: List<&2,N_Constructor>, nodes: List<&2,P112SNode>, +bangs: List<&2,String>,
    +workers: List<&2,P113DFunction>, helpers: List<&2,P128BRHelper>, retry: List<&2,NO_Plan>,
    +error: String) -> P167Lowered:
  nt_choose(P167Lowered,String.is_empty(error),
    u => p168_selected(mode,source,book,names,constructors,nodes,bangs,workers,helpers,retry,
      p167ob_remaining(book,names,bangs,p113e_signatures(workers,missing()))),
    u => p167l_fail("early scalar observer verification: " ++ error))



@unsafe
def p168_scanned(mode: U32, source: List<&2,KDef>, book: List<&2,KDef>, names: List<&2,String>,
    +constructors: List<&2,N_Constructor>, nodes: List<&2,P112SNode>, bangs: List<&2,String>,
    scan: P128BROpen) -> P167Lowered:
  match scan:
    case P128BROpen{+workers,helpers,retry,+error}:
      nt_choose(P167Lowered,String.is_empty(error),
        u => p168_seed_verified(mode,source,book,names,constructors,nodes,bangs,workers,helpers,retry,
          p167ob_seed_verify(constructors,workers)),
        u => p167l_fail("early scalar observer classification: " ++ error))



@unsafe
def p168_prepared(mode: U32, source: List<&2,KDef>, +names: List<&2,String>, constructors: List<&2,N_Constructor>,
    prepared: P112SPrepared) -> P167Lowered:
  match prepared:
    case P112SPrepared{+book,nodes,+error}:
      +bangs = nc_bangs_names(book,names)
      nt_choose(P167Lowered,String.is_empty(error),
        u => p168_scanned(mode,source,book,names,constructors,nodes,bangs,
          p128br_scan(book,no_candidate_names(book,names,bangs),[],[],[],[])),
        u => p167l_fail("early scalar static preparation: " ++ error))



@unsafe
def p168_catalogued(mode: U32, source: List<&2,KDef>, +book: List<&2,KDef>, +names: List<&2,String>,
    +constructors: List<&2,N_Constructor>) -> P167Lowered:
  p168_prepared(mode,source,names,constructors,p112s_prepare(book,names,constructors))



# Do not authorize this from the later prepared book, a workload name or a
# caller-supplied certificate. Invalid public modes fail before any lowering.
@unsafe
def p168_request_mode(+mode: U32, +request: NR_Request) -> P167Lowered:
  match request:
    case NR_Request{+source,+book,+names,paths,scope,bound}:
      +error = nc_compile_error_known(source,bound)
      nt_choose(P167Lowered,U32.is_gt(mode,1),u => p167l_fail("early scalar mode must be 0 or 1"),u =>
      nt_choose(P167Lowered,String.is_empty(error),u =>
        nt_choose(P167Lowered,p167ob_permission(request),
          v => p168_catalogued(nt_choose(U32,U32.is_eq(mode,1),
            w => p169o_certified(mode,p113a_certificate(request)),w => mode),
            source,book,names,nc_add_ctors(nc_default_ctors(),
              p144o_constructors(source,source,p144o_payload(nc_ctor_context(book))))),
          v => p167l_fail("early scalar source permission refused")),
        u => p167l_fail("early scalar request: " ++ error)))


# Experimental alternative to broad p168_inline. Load after early-scalars.bend
# with the sole explicit experimental override p168_closed. Frozen API01 keeps
# its original policy; in this API mode0 is unchanged and mode1 is selective.

type P168TSelection is Data:
  P168TSelection{+blocked: KDef, +targets: KDef}



@unsafe
def p168t_has(index: KDef, name: String) -> Bool:
  Bool.not(String.eq(dk(p111v_get(index,name)),"Absent"))



@unsafe
def p168t_accept(original: P113DFunction, +candidate: P113DFunction) -> P113DFunction:
  match candidate:
    case P113DFunction{name,params,result,public,body}:
      nt_choose(P113DFunction,p128bs_leaf(body),u => candidate,u => original)



# Preparation is retained only when it establishes the original leaf contract.
# Existing leaf owners, non-target consumers and general observer seeds stay exact.
@unsafe
def p168t_target(+original: P113DFunction, table: P113ITable) -> P113DFunction:
  match original:
    case P113DFunction{name,params,result,public,body}:
      nt_choose(P113DFunction,p128bs_leaf(body),u => original,
        u => p168t_accept(original,p113i_function(original,table)))



@unsafe
def p168t_walk(functions: List<&2,P113DFunction>, +seeds: KDef, +blocked: KDef,
    +targets: KDef, +table: P113ITable, +reversed: List<&2,P113DFunction>) -> List<&2,P113DFunction>:
  match functions:
    case Nil{}: nt_reverse(P113DFunction,reversed,[])
    case Con{+head,+rest}:
      match head:
        case P113DFunction{+name,params,result,public,body}:
          nt_choose(List<&2,P113DFunction>,p113d_ready(seeds,name),
            u => p168t_walk(rest,seeds,blocked,targets,table,Con{head,reversed}),
            u => nt_choose(List<&2,P113DFunction>,p168t_has(blocked,name),
              v => p168t_walk(rest,seeds,blocked,targets,table,
                Con{nt_choose(P113DFunction,p168t_has(targets,name),
                  w => p168t_target(head,table),w => head),reversed}),
              v => p168t_walk(rest,seeds,blocked,targets,
                nt_choose(P113ITable,p113i_original_clean(head) && p128bs_leaf(body),
                  w => p113i_table_function(head,table),w => table),Con{head,reversed})))



@unsafe
def p168t_selected(functions: List<&2,P113DFunction>, seeds: KDef,
    selection: P168TSelection) -> List<&2,P113DFunction>:
  match selection:
    case P168TSelection{blocked,targets}:
      p168t_walk(functions,seeds,blocked,targets,P113IEmpty{},[])


# Private Phase169 successor. No producer-owned Boolean authorizes machine code:
# the unchanged eligibility predicate is evaluated against this exact prepared
# book and immutable plan, then reused only before those inputs can change.

@unsafe
def p169q_metadata(+arity: U32, +result: U32, +incoming: U32, +flags: U32) -> Bool:
  U32.is_eq(incoming,0) && U32.is_eq(flags,0) && U32.is_eq(result,1) && U32.is_le(arity,32)



@unsafe
def p169q_import(+name: String, +arity: U32, direct: KDef) -> Bool:
  +function = p111v_get(direct,name)
  String.eq(dk(function),"P113Direct") && U32.is_eq(da(function),arity) &&
    U32.is_eq(dx(function),1) && U32.is_eq(ix(dv(function)),1)



type P169ScalarPlan is Data:
  P169ScalarPlan{+plan: NO_Plan, +eligible: Bool}



@unsafe
def p169q_plans(+book: List<&2,KDef>, plans: List<&2,NO_Plan>) -> List<&2,P169ScalarPlan>:
  match plans:
    case Nil{}: []
    case Con{+plan,rest}:
      Con{P169ScalarPlan{plan,p128bs_eligible(book,plan)},p169q_plans(book,rest)}



@unsafe
def p169q_selection(+book: List<&2,KDef>, plans: List<&2,P169ScalarPlan>,
    blocked: KDef, +targets: KDef) -> P168TSelection:
  match plans:
    case Nil{}: P168TSelection{blocked,targets}
    case Con{P169ScalarPlan{plan,eligible},rest}:
      +owner = p113d_public(book,no_plan_owner(plan))
      p169q_selection(book,rest,p167l_mark(blocked,owner),
        nt_choose(KDef,eligible,u => p167l_mark(targets,owner),u => targets))



@unsafe
def p169q_scalars(+book: List<&2,KDef>, plans: List<&2,P169ScalarPlan>,
    +original: List<&2,P113DFunction>, functions: List<&2,P113DFunction>,
    helpers: List<&2,P128BRHelper>, retry: List<&2,NO_Plan>) -> P128BROpen:
  match plans:
    case Nil{}: P128BROpen{nt_reverse(P113DFunction,functions,[]),
      nt_reverse(P128BRHelper,helpers,[]),nt_reverse(NO_Plan,retry,[]),""}
    case Con{P169ScalarPlan{+plan,eligible},rest}:
      p169q_scalar_ready(book,rest,original,functions,helpers,retry,plan,
        nt_choose(P118BWorkers,eligible,
          u => p128bs_find(book,no_plan_owner(plan),plan,original),u => P118BWorkers{[],""}))



@unsafe
def p169q_scalar_ready(+book: List<&2,KDef>, +rest: List<&2,P169ScalarPlan>,
    +original: List<&2,P113DFunction>, +functions: List<&2,P113DFunction>,
    +helpers: List<&2,P128BRHelper>, +retry: List<&2,NO_Plan>,
    +plan: NO_Plan, +workers: P118BWorkers) -> P128BROpen:
  match workers:
    case P118BWorkers{+added,+error}:
      nt_choose(P128BROpen,String.is_empty(error),
        u => p169q_scalars(book,rest,original,nt_reverse(P113DFunction,added,functions),
          nt_reverse(P128BRHelper,p128br_seed(no_plan_owner(plan),no_plan_schema(plan),workers),helpers),
          nt_choose(List<&2,NO_Plan>,List.is_empty(&2,P113DFunction,added),v => Con{plan,retry},v => retry)),
        u => P128BROpen{[],[],[],error})



@unsafe
def p169q_inlined(source: List<&2,KDef>, +book: List<&2,KDef>, names: List<&2,String>,
    constructors: List<&2,N_Constructor>, nodes: List<&2,P112SNode>, bangs: List<&2,String>,
    stats: List<&2,U32>, helpers: List<&2,P128BRHelper>, plans: List<&2,P169ScalarPlan>,
    +functions: List<&2,P113DFunction>) -> P167Lowered:
  p168_scalar_result(source,book,names,constructors,nodes,bangs,stats,functions,
    p169q_scalars(book,plans,functions,[],nt_reverse(P128BRHelper,helpers,[]),[]))



@unsafe
def p169q_closed(source: List<&2,KDef>, +book: List<&2,KDef>, names: List<&2,String>,
    constructors: List<&2,N_Constructor>, nodes: List<&2,P112SNode>, bangs: List<&2,String>,
    stats: List<&2,U32>, helpers: List<&2,P128BRHelper>, +plans: List<&2,P169ScalarPlan>,
    seeds: KDef, functions: List<&2,P113DFunction>) -> P167Lowered:
  p169q_inlined(source,book,names,constructors,nodes,bangs,stats,helpers,plans,
    p168t_selected(functions,seeds,p169q_selection(book,plans,missing(),missing())))


# Optional bounded ordinary composition BEFORE borrowed-worker conversion.
# Seed and every retry owner remain excluded from table publication. The only
# extra work is ordinary nonblocked p113i_function plus its original table gate.
# Normal entry derives the existing certificate from the actual request; mode2
# is internal only. The public p168_request_mode still admits only modes0/1.

@unsafe
def p169o_next(+original: P113DFunction, rest: List<&2,P113DFunction>, seeds: KDef,
    blocked: KDef, targets: KDef, +table: P113ITable,
    reversed: List<&2,P113DFunction>, +function: P113DFunction) -> List<&2,P113DFunction>:
  p169o_walk(rest,seeds,blocked,targets,
    nt_choose(P113ITable,p113i_original_clean(original),
      u => p113i_table_function(function,table),u => table),Con{function,reversed})



@unsafe
def p169o_walk(functions: List<&2,P113DFunction>, +seeds: KDef, +blocked: KDef,
    +targets: KDef, +table: P113ITable, +reversed: List<&2,P113DFunction>) -> List<&2,P113DFunction>:
  match functions:
    case Nil{}: nt_reverse(P113DFunction,reversed,[])
    case Con{+head,+rest}:
      match head:
        case P113DFunction{+name,params,result,public,body}:
          nt_choose(List<&2,P113DFunction>,p113d_ready(seeds,name),
            u => p169o_walk(rest,seeds,blocked,targets,table,Con{head,reversed}),
            u => nt_choose(List<&2,P113DFunction>,p168t_has(blocked,name),
              v => p169o_walk(rest,seeds,blocked,targets,table,
                Con{nt_choose(P113DFunction,p168t_has(targets,name),
                  w => p168t_target(head,table),w => head),reversed}),
              v => p169o_next(head,rest,seeds,blocked,targets,table,reversed,
                p113i_function(head,table))))



@unsafe
def p169o_selected(functions: List<&2,P113DFunction>, seeds: KDef,
    selection: P168TSelection) -> List<&2,P113DFunction>:
  match selection:
    case P168TSelection{blocked,targets}:
      p169o_walk(functions,seeds,blocked,targets,P113IEmpty{},[])



@unsafe
def p169o_closed(source: List<&2,KDef>, +book: List<&2,KDef>, names: List<&2,String>,
    constructors: List<&2,N_Constructor>, nodes: List<&2,P112SNode>, bangs: List<&2,String>,
    stats: List<&2,U32>, helpers: List<&2,P128BRHelper>, +plans: List<&2,P169ScalarPlan>,
    seeds: KDef, functions: List<&2,P113DFunction>) -> P167Lowered:
  p169q_inlined(source,book,names,constructors,nodes,bangs,stats,helpers,plans,
    p169o_selected(functions,seeds,p169q_selection(book,plans,missing(),missing())))



@unsafe
def p169o_certified(+mode: U32, certificate: P113ACertificate) -> U32:
  nt_choose(U32,U32.is_eq(mode,1) && p113a_enabled(certificate),u => 2,u => mode)
