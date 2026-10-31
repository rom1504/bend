

@unsafe
def p128rf_members(names: List<&2,String>, tree: KDef) -> KDef:
  match names:
    case Nil{}: tree
    case Con{+name,rest}:
      p128rf_members(rest,index_set(tree,
        KDef{name,"P128ReachMember",0,0,{KTerm{"Absent", "", 0, 0, Nil{}, Nil{}, 0, 0} : KTerm},{KTerm{"Absent", "", 0, 0, Nil{}, Nil{}, 0, 0} : KTerm},[],False{},False{}},
        index_hash(name,2166136261),32))


@unsafe
def p128rf_member(+members: KDef, +name: String) -> Bool:
  String.eq(dk(index_find(members,name,index_hash(name,2166136261),32)),"P128ReachMember")


@unsafe
def p128rf_filter(book: List<&2,KDef>, +members: KDef) -> List<&2,KDef>:
  match book:
    case Nil{}: []
    case Con{+d,+rest}:
      kc(List<&2,KDef>,p128rf_member(members,dn(d)),
        u => Con{d,p128rf_filter(rest,members)},u => p128rf_filter(rest,members))


@unsafe
def p128rf_controls() -> List<&2,String>:
  +a = p128rfc_def("alpha",1)
  +a2 = p128rfc_def("alpha",9)
  +b = p128rfc_def("beta",2)
  +empty = p128rfc_def("",3)
  +unicode = p128rfc_def("λ.树",4)
  +collisionA = p128rfc_def("costarring",5)
  +collisionB = p128rfc_def("liquid",6)
  +leaf : KDef = KIndexLeaf{17,[a,b]}
  +node : KDef = KIndexNode{17,1,leaf,missing()}
  +cache : KDef = KDef{"$kernel.cache","BookCache",7,0,{KTerm{"Absent", "", 0, 0, Nil{}, Nil{}, 0, 0} : KTerm},{KTerm{"Absent", "", 0, 0, Nil{}, Nil{}, 0, 0} : KTerm},[node],True{},False{}}
  +book : List<&2,KDef> = [a,b,a2,empty,unicode,collisionA,collisionB,leaf,node,cache]
  [p128rfc_row("reach-empty-both",p128rfc_equal([],[])),
   p128rfc_row("reach-empty-book",p128rfc_equal([],["alpha","λ.树"])),
   p128rfc_row("reach-empty-live",p128rfc_defs(kr_filter(book,[]),[])),
   p128rfc_row("reach-no-match",p128rfc_defs(kr_filter(book,["absent"]),[])),
   p128rfc_row("reach-duplicate-definitions-retained-in-order",p128rfc_defs(kr_filter(book,["alpha"]),[a,a2])),
   p128rfc_row("reach-duplicate-live-does-not-duplicate-output",p128rfc_defs(kr_filter(book,["alpha","alpha"]),[a,a2])),
   p128rfc_row("reach-book-order-not-live-order",p128rfc_defs(kr_filter(book,["beta","alpha"]),[a,b,a2])),
   p128rfc_row("reach-empty-name-includes-index-values",p128rfc_defs(kr_filter(book,[""]),[empty,leaf,node])),
   p128rfc_row("reach-unicode-name",p128rfc_defs(kr_filter(book,["λ.树"]),[unicode])),
   p128rfc_row("reach-exact-case-sensitive",p128rfc_defs(kr_filter(book,["Alpha"]),[])),
   p128rfc_row("reach-cache-name-retains-original-payload",p128rfc_defs(kr_filter(book,["$kernel.cache"]),[cache])),
   p128rfc_row("reach-collision-premise",U32.is_eq(index_hash("costarring",2166136261),index_hash("liquid",2166136261))),
   p128rfc_row("reach-collision-a-only",p128rfc_defs(kr_filter(book,["costarring"]),[collisionA])),
   p128rfc_row("reach-collision-b-only",p128rfc_defs(kr_filter(book,["liquid"]),[collisionB])),
   p128rfc_row("reach-collision-both",p128rfc_defs(kr_filter(book,["liquid","costarring"]),[collisionA,collisionB])),
   p128rfc_row("reach-reference-all-shapes",p128rfc_equal(book,["alpha","","λ.树","liquid","costarring","$kernel.cache"])),
   p128rfc_row("reach-reference-mixed-misses",p128rfc_equal(book,["absent","β","beta","","λ.树","alpha","alpha"])),
   p128rfc_row("reach-128-duplicate-events",p128rfc_equal(p128rfc_range(128,"alpha"),["alpha","missing"])),
   p128rfc_row("reach-128-distinct-events",p128rfc_equal(p128rfc_rows(128),p128rfc_names(128))),
   p128rfc_row("reach-128-mixed-membership",p128rfc_equal(p128rfc_rows(128),["name.1","name.64","name.128","name.129"]))]


@unsafe
def p128raw_plan_finish(original: P112SResult, +raw: List<&2,P113DCandidate>) -> P128RawLowering:
  P128RawLowering{p113d_finish(original,
    p113d_passes(p126sc_candidates(raw),missing(),[],32)),raw}


@unsafe
def p128raw_prepared(+source: List<&2,KDef>, +names: List<&2,String>, prepared: P112SPrepared) -> P128RawLowering:
  match prepared:
    case P112SPrepared{+book,+nodes,+error}:
      nt_choose(P128RawLowering,String.is_empty(error),u =>
        p128raw_plan_finish(p112s_finish(nodes,p111_finish(source,names,
          p111_compile_defs(book,names,nc_bangs_names(book,names),0,[]))),
          p113pl_candidates(book,names,nc_bangs_names(book,names),book_cached(nq_signatures(book,names),0))),
        u => P128RawLowering{P113DLowered{P113DProgram{P112StaticProgram{p111_empty(),[]},[]},error},[]})


@unsafe
def p128raw_lower_request(request: NR_Request) -> P128RawLowering:
  p144o_lower_request(request)

@unsafe
def p128raw_close(raw: List<&2,P113DCandidate>, original: P113AProgram, +added: List<&2,P113DFunction>) -> P111Emission:
  match original:
    case P113AProgram{P113DProgram{+static,+functions},+certificate}:
      +merged = nt_append(P113DFunction,added,p118b_without(functions,p113e_signatures(added,missing())))
      p126bp_complete(static,certificate,
        p113d_passes(raw,p113e_signatures(merged,missing()),nt_reverse(P113DFunction,merged,[]),32))


@unsafe
def p128raw_workers(+raw: List<&2,P113DCandidate>, +original: P113AProgram, +workers: P118BWorkers) -> P111Emission:
  match original workers:
    case P113AProgram{P113DProgram{P112StaticProgram{+program,nodes},functions},certificate} P118BWorkers{+added,+error}:
      +checked = p111_first(error,p118b_verify_functions(added,program))
      nt_choose(P111Emission,String.is_empty(checked),
        u => nt_choose(P111Emission,p126bp_has_flat(added),
          v => p128raw_close(raw,original,added),v => p118b_compose(original,workers)),
        u => P111Emission{[],"flat observer workers: " ++ checked})


@unsafe
def p128raw_integrated(+raw: List<&2,P113DCandidate>, +original: P113AProgram, +workers: P118BWorkers) -> P111Emission:
  match workers:
    case P118BWorkers{functions,+error}:
      nt_choose(P111Emission,String.is_empty(error) && p126bp_has_flat(functions),
        u => p128raw_workers(raw,original,workers),u => p118e_emit_workers(original,workers))


@unsafe
def p128raw_borrow(request: NR_Request, raw: List<&2,P113DCandidate>, original: P113AProgram) -> P111Emission:
  match request:
    case NR_Request{source,+book,+names,paths,scope,bound}:
      p128raw_integrated(raw,original,
        p118e_workers(book,no_candidate_names(book,names,nc_bangs_names(book,names)),[]))


@unsafe
def p128raw_permitted(+request: NR_Request, raw: List<&2,P113DCandidate>, original: P113AProgram) -> P111Emission:
  match request:
    case NR_Request{source,+book,+names,paths,scope,bound}:
      +hot = nh_definitions(book,names,[])
      p128raw_borrow(request,raw,p118e_cold(original,book,source,hot))


@unsafe
def p128raw_prepare(+request: NR_Request, +raw: List<&2,P113DCandidate>, +original: P113AProgram) -> P111Emission:
  match original:
    case P113AProgram{program,P113ACertificate{scalar,unshared}}:
      nt_choose(P111Emission,scalar,u => p128raw_br_prepare(request,raw,original,True{}),u =>
        nt_choose(P111Emission,p118i_permission(request),
          v => p128raw_br_prepare(request,raw,original,False{}),v => P134Planned{P134Admitted{original}}))

@unsafe
def p128raw_verified(+request: NR_Request, +raw: List<&2,P113DCandidate>, +original: P113AProgram, +error: String) -> P111Emission:
  nt_choose(P111Emission,String.is_empty(error),u => p128raw_prepare(request,raw,original),
    u => P111Emission{[],"array structured IR: " ++ error})


@unsafe
def p128raw_lowered(+request: NR_Request, +raw: List<&2,P113DCandidate>, lowered: P113ALowering) -> P111Emission:
  match lowered:
    case P113ALowered{+program,+error}:
      nt_choose(P111Emission,String.is_empty(error),
        u => p128raw_verified(request,raw,program,p113a_verify(program)),
        u => P111Emission{[],"array native lowering: " ++ error})


@unsafe
def p128raw_session_finish(request: NR_Request, certificate: P113ACertificate, session: P128RawLowering) -> P111Emission:
  match session:
    case P128RawLowering{lowered,raw}:
      p146c_finish(request,certificate,raw,
        p114s_ranges_lowered(p114s_inline_lowered(p114s_open_lowered(lowered))))

@unsafe
def p128raw_emit_admitted(+request: NR_Request, +error: String) -> P111Emission:
  nt_choose(P111Emission,String.is_empty(error),u =>
    p128raw_session_finish(request,p113a_certificate(request),p128raw_lower_request(request)),
    u => P111Emission{[],"compile: " ++ error})


@unsafe
def p128raw_emit_request(+request: NR_Request) -> P111Emission:
  p128raw_emit_admitted(request,p111_runtime_admission(request))


@unsafe
def p128raw_emit_plan(plan: P86Plan) -> P111Emission:
  match plan:
    case P86PlanError{error}: P111Emission{[],error}
    case P86PlanReady{request,verdict}: p128raw_emit_request(request)


@unsafe
def p128raw_compile_prepared(+path: String, +source: String, prepared: P86Preparation) -> P111Emission:
  match prepared:
    case P86PreparationError{error}: P111Emission{[],error}
    case P86PreparationReady{seed}: p128raw_emit_plan(p86_plan(seed,path,source))


@unsafe
def p128raw_controls() -> List<&2,String>:
  +request = p128rawc_request()
  +original = p128rawc_original()
  +base : P112SResult = P112SResult{P112StaticProgram{p111_empty(),[]},""}
  +a = p126sc_test_candidate(p126sc_test_function("a","b"))
  +b = p126sc_test_candidate(p126sc_test_function("b","a"))
  +helper : P113DFunction = P113DFunction{"$product.observe",[],1,False{},[P113DResult{[N111Const{17,0}]}]}
  +body : P113DFunction = P113DFunction{"consumer",[],1,False{},[
    P113DCall{["answer"],"$product.observe",[]},P113DResult{[N111Local{"answer"}]}]}
  +caller : P113DCandidate = P113DCandidate{body,"",["$product.observe"]}
  [p126bpc_row("raw-admission-error-exact",p128rawc_same(p128raw_emit_admitted(request,"control"),p111_emit_admitted(request,"control"))),
   p126bpc_row("raw-plan-error-exact",p128rawc_same(p128raw_emit_plan(P86PlanError{"control"}),p111_emit_plan(P86PlanError{"control"}))),
   p126bpc_row("raw-preparation-error-exact",p128rawc_same(
     p128raw_compile_prepared("x","",P86PreparationError{"control"}),
     p111_compile_prepared("x","",P86PreparationError{"control"}))),
   p126bpc_row("raw-static-preparation-error",String.eq(p128rawc_error(p128raw_prepared([],[],P112SPrepared{[],[],"control"})),"control")),
   p126bpc_row("raw-lowering-error-exact",p128rawc_same(
     p128raw_lowered(request,[],P113ALowered{original,"control"}),p118e_lowered(request,P113ALowered{original,"control"}))),
   p126bpc_row("raw-original-verifier-error-exact",p128rawc_same(
     p128raw_verified(request,[],original,"control"),p118e_verified(request,original,"control"))),
   p126bpc_row("raw-pre-scc-candidates-retained",p128rawc_counts(p128raw_plan_finish(base,[a,b]),2,3)),
   p126bpc_row("raw-blocked-candidate-retained",p128rawc_counts(p128raw_plan_finish(base,[caller]),1,0)),
   p126bpc_row("raw-late-dependency-admitted-exact-qbe",p128rawc_late(caller,helper,body)),
   p126bpc_row("raw-error-candidate-retained",p128rawc_counts(p128raw_plan_finish(base,[P113DCandidate{body,"control",[]}]),1,0)),
   p126bpc_row("raw-independent-verifier-refuses-invalid",Bool.not(String.is_empty(
     p113e_functions([P113DFunction{"invalid",[],0,False{},[]}],N111Ids{missing(),missing()},missing()))))]

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
      nt_choose(P111Emission,String.is_empty(error),u => nt_choose(P111Emission,List.is_empty(&2,P128BRPatch,edits),
          v => p128raw_integrated(raw,original,workers),
          v => p128raw_br_compose(raw,original,workers,edits)),
        u => P111Emission{[],"borrowed helper plan: " ++ error})


@unsafe
def p128raw_br_scanned(+raw: List<&2,P113DCandidate>, +original: P113AProgram, +book: List<&2,KDef>, +source: List<&2,KDef>, +names: List<&2,String>, +cold: Bool, scan: P128BROpen) -> P111Emission:
  match scan:
    case P128BROpen{+functions,+helpers,+retry,+error}:
      nt_choose(P111Emission,String.is_empty(error),u =>
        p131p_scanned(raw,book,helpers,retry,functions,
          nt_choose(P113AProgram,cold,v => p118e_cold(original,book,source,nh_definitions(book,names,[])),v => original)),
        u => P111Emission{[],"borrowed profile: " ++ error})

@unsafe
def p128raw_br_prepare(request: NR_Request, raw: List<&2,P113DCandidate>, +original: P113AProgram, cold: Bool) -> P111Emission:
  match request:
    case NR_Request{+source,+book,+names,paths,scope,bound}:
      p128raw_br_scanned(raw,original,book,source,names,cold,
        p128br_scan(book,no_candidate_names(book,names,nc_bangs_names(book,names)),p128bs_original(original),[],[],[]))


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
