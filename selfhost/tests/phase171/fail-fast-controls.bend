# Finite observations, run through separate checked baseline/candidate APIs.
# Failed-code partial bodies are not an equivalence claim; first errors are.

type P171FFCase is Data:
  P171FFCase{+name: String, +expected: String, +code: P113DCode}

@unsafe
def p171ff_match_term(+name: String, yes: KTerm, no: KTerm) -> KTerm:
  kt("NMatch","",0,0,[kt("Mat",name,1,1,[yes,kt("Lam","x",99,1,[no])]),var("x",0)])

@unsafe
def p171ff_cases() -> List<&2,P171FFCase>:
  +word = kt("NWord","7",0,0,[])
  +bad = kt("BadFirst","",0,0,[])
  +later = kt("BadLater","",0,0,[])
  +body = var("bound",7)
  +plan = p112_liveness_terms([body])
  +rest = p112_liveness_terms([later])
  +target : P113PTarget = P113PTarget{[],atom("Absent"),True{},"owner",[]}
  +env : List<&2,NC_Binding> = [NC_Binding{0,"v_0",N_W64{}}]
  +row = kt("Row","0",32,0,[word])
  +yes : P113DCode = P113DCode{[P113DResult{[N111Const{7,0}]}],17,"",[]}
  +failed : P113DCode = P113DCode{[],17,"first literal error",["discarded.call"]}
  +shape = kt("NQShape","Pair",2,0,[])
  +pair = kt("NCtr","Pair",0,0,[word,word])
  +self = kt("NCall","owner",0,0,[])
  +pself = kt("NPCall","owner",0,0,[])
  [P171FFCase{"direct-let-ok","",p113d_let([],word,body,[],7,"owner",P113DReturn{},17)},
   P171FFCase{"direct-let-first-error","direct: unsupported core node BadFirst",p113d_let([],bad,later,[],7,"owner",P113DReturn{},17)},
   P171FFCase{"direct-live-ok","",p113dl_let([],word,plan,[],7,"owner",P113DReturn{},17)},
   P171FFCase{"direct-live-first-error","direct: unsupported core node BadFirst",p113dl_let([],bad,rest,[],7,"owner",P113DReturn{},17)},
   P171FFCase{"product-flat-ok","",p113pl_bind_flat([],pair,body,[],7,target,17,shape)},
   P171FFCase{"product-flat-first-error","product unsupported core node BadFirst",p113pl_bind_flat([],bad,later,[],7,target,17,shape)},
   P171FFCase{"product-box-ok","",p113pl_bind_boxed([],word,body,[],7,target,17)},
   P171FFCase{"product-box-first-error","product unsupported core node BadFirst",p113pl_bind_boxed([],bad,later,[],7,target,17)},
   P171FFCase{"product-live-ok","",p113px_boxed([],word,plan,[],7,target,17)},
   P171FFCase{"product-live-first-error","product unsupported core node BadFirst",p113px_boxed([],bad,rest,[],7,target,17)},
   P171FFCase{"direct-rows-ok","",p113dm_more([],row,[row],env,"owner",P113DReturn{},0,yes)},
   P171FFCase{"direct-rows-first-error","first literal error",p113dm_more([],row,[row],env,"owner",P113DReturn{},0,failed)},
   P171FFCase{"product-rows-ok","",p113pm_more([],row,[row],env,target,0,yes)},
   P171FFCase{"product-rows-first-error","first literal error",p113pm_more([],row,[row],env,target,0,failed)},
   P171FFCase{"direct-match-ok","",p113dm_original_match([],p171ff_match_term("Unit",word,word),env,"owner",P113DReturn{},17)},
   P171FFCase{"direct-match-first-error","direct: unsupported core node BadFirst",p113dm_original_match([],p171ff_match_term("Unit",bad,later),env,"owner",P113DReturn{},17)},
   P171FFCase{"direct-effect-priority","direct: effect match",p113dm_original_match([],p171ff_match_term("Emit",bad,later),env,"owner",P113DReturn{},17)},
   P171FFCase{"product-match-ok","",p113pm_original_match([],p171ff_match_term("Unit",word,word),env,target,17)},
   P171FFCase{"product-match-first-error","product unsupported core node BadFirst",p113pm_original_match([],p171ff_match_term("Unit",bad,later),env,target,17)},
   P171FFCase{"product-effect-priority","product effect or specialized Word match",p113pm_original_match([],p171ff_match_term("Halt",bad,later),env,target,17)},
   P171FFCase{"direct-self-diagnostic","direct: non-tail self call",p113d_let([],self,later,[],7,"owner",P113DReturn{},17)},
   P171FFCase{"product-self-retry-diagnostic","product non-tail self call",p113pl_bind_boxed([],pself,later,[],7,target,17)}]

@unsafe
def p171ff_kept(candidates: List<&2,P113DCandidate>) -> List<&2,P113DFunction>:
  p113d_passes(p126sc_candidates(candidates),missing(),[],32)

@unsafe
def p171ff_same(a: List<&2,P113DCandidate>, b: List<&2,P113DCandidate>) -> Bool:
  p134v_list(~P113DFunction,~p134v_function,p171ff_kept(a),p171ff_kept(b))

@unsafe
def p171ff_failed(+name: String, calls: List<&2,String>, body: List<&2,P113DStmt>) -> P113DCandidate:
  P113DCandidate{P113DFunction{name,[],1,True{},body},"same first error",calls}

@unsafe
def p171ff_scc_controls() -> List<&2,String>:
  +a = p126sc_test_candidate(p126sc_test_function("a","b"))
  +b = p126sc_test_candidate(p126sc_test_function("b","a"))
  +body : List<&2,P113DStmt> = [P113DCall{["z"],"a",[]},P113DResult{[N111Local{"z"}]}]
  +old = p171ff_failed("bad",["a","b"],body)
  +cut = p171ff_failed("bad",[],[])
  [p126sc_row("failed-metadata-independent",p171ff_same([old,a,b],[cut,a,b])),
   p126sc_row("failed-slot-preserved",p171ff_same([a,old,b],[a,cut,b])),
   p126sc_row("failed-duplicate-before",p171ff_same([p171ff_failed("b",["a"],body),a,b],[p171ff_failed("b",[],[]),a,b])),
   p126sc_row("failed-duplicate-after",p171ff_same([a,b,p171ff_failed("b",["a"],body)],[a,b,p171ff_failed("b",[],[])])),
   p126sc_row("failed-generated-name-collision",p171ff_same([a,b,p171ff_failed("$p126scc.0",["a"],body)],[a,b,p171ff_failed("$p126scc.0",[],[])])),
   p126sc_row("successful-pair-still-verifies",String.is_empty(p113e_functions(p171ff_kept([old,a,b]),N111Ids{missing(),missing()},missing())))]
