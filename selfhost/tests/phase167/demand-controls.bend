# Finite final-boundary controls; malformed inputs are never executed.
# The adapter fixture is written independently from p164a_body.
@unsafe
def p167c_book() -> List<&2,KDef>:
  [KDef{"main","Def",0,0,atom("U32"),KTerm{"U32","7",0,0,[],[],0,0},[],False{},False{}}]

def p167c_body() -> List<&2,N111Stmt>:
  [N111Alloca{"p164_adapter_out",8,8},
   N111Call{"p164_value",N111U64{},"p113d_FID_109_97_105_110_",[N111Arg{N111Ptr{},N111Local{"state"}}]},
   N111Store{N111U64{},N111Local{"p164_adapter_out"},0,N111Local{"p164_value"}},
   N111Call{"p164_reply",N111U64{},"p111_rt_return",[
     N111Arg{N111Ptr{},N111Local{"state"}},N111Arg{N111Ptr{},N111Local{"p164_adapter_out"}},N111Arg{N111U32{},N111Const{1,0}}]},
   N111Return{N111Local{"p164_reply"}}]

def p167c_segment() -> N111Segment:
  N111Segment{"main",0,1,0,0,p167c_body()}

def p167c_worker() -> P113DFunction:
  P113DFunction{"main",[],1,False{},[P113DResult{[N111Const{7,0}]}]}

def p167c_program(segments: List<&2,N111Segment>, functions: List<&2,P113DFunction>, constructors: List<&2,N_Constructor>, nodes: List<&2,P112SNode>) -> P113DProgram:
  P113DProgram{P112StaticProgram{P111Program{segments,constructors,[0],[],[],True{}},nodes},functions}

@unsafe
def p167c_adapters() -> KDef:
  p164a_put(missing(),"main","main",0)

@unsafe
def p167c_pass(segments: List<&2,N111Segment>, functions: List<&2,P113DFunction>, adapters: KDef, bangs: List<&2,String>) -> Bool:
  String.is_empty(p167v_final(p167c_book(),bangs,adapters,p167c_program(segments,functions,[],[])))

@unsafe
def p167c_bad_segment(segment: N111Segment) -> Bool:
  Bool.not(p167c_pass([segment],[p167c_worker()],p167c_adapters(),[]))

@unsafe
def p167c_bad_worker(worker: P113DFunction) -> Bool:
  Bool.not(p167c_pass([p167c_segment()],[worker],p167c_adapters(),[]))

@unsafe
def p167c_reject(program: P113DProgram) -> Bool:
  Bool.not(String.is_empty(p167v_final(p167c_book(),[],p167c_adapters(),program)))

@unsafe
def p167c_row(+name: String, ok: Bool) -> String:
  nt_choose(String,ok,u => name ++ ":pass",u => name ++ ":FAIL")

@unsafe
def p167c_error_only(emission: P111Emission) -> Bool:
  match emission:
    case P111Emission{chunks,error}: List.is_empty(&2,String,chunks) && String.eq(error,"demand final IR: deliberately invalid")
    case _: False{}

@unsafe
def p167c_source_kind(kind: String) -> Bool:
  +definition : KDef = KDef{"main",kind,0,0,atom("U32"),KTerm{"U32","7",0,0,[],[],0,0},[],False{},False{}}
  Bool.not(String.is_empty(p167v_final([definition],[],p167c_adapters(),p167c_program([p167c_segment()],[p167c_worker()],[],[]))))

@unsafe
def p167e_controls() -> List<&2,String>:
  +segment = p167c_segment()
  +worker = p167c_worker()
  +body = p167c_body()
  +adapters = p167c_adapters()
  +generic : N111Segment = N111Segment{"main",0,1,0,0,[N111Return{N111Const{7,0}}]}
  [p167c_row("valid-generic-final",p167c_pass([generic],[],missing(),[])),
   p167c_row("independent-adapter-shape",p164a_shape(segment)),
   p167c_row("valid-private-adapter-final",p167c_pass([segment],[worker],adapters,[])),
   p167c_row("missing-worker-refused",Bool.not(p167c_pass([segment],[],adapters,[]))),
   p167c_row("missing-adapter-map-refused",Bool.not(p167c_pass([segment],[worker],missing(),[]))),
   p167c_row("missing-header-refused",Bool.not(p167c_pass([],[worker],adapters,[]))),
   p167c_row("duplicate-header-refused",Bool.not(p167c_pass([segment,segment],[worker],adapters,[]))),
   p167c_row("duplicate-worker-refused",Bool.not(p167c_pass([segment],[worker,worker],adapters,[]))),
   p167c_row("source-mismatch-refused",Bool.not(p167c_pass([segment],[worker],p164a_put(missing(),"other","main",0),[]))),
   p167c_row("source-law-refused",p167c_source_kind("Law")),
   p167c_row("source-bang-refused",Bool.not(p167c_pass([segment],[worker],adapters,["main"]))),
   p167c_row("map-arity-refused",Bool.not(p167c_pass([segment],[worker],p164a_put(missing(),"main","main",1),[]))),
   p167c_row("header-arity-refused",p167c_bad_segment(N111Segment{"main",1,1,0,0,body})),
   p167c_row("header-result-refused",p167c_bad_segment(N111Segment{"main",0,2,0,0,body})),
   p167c_row("header-incoming-refused",p167c_bad_segment(N111Segment{"main",0,1,1,0,body})),
   p167c_row("header-flags-refused",p167c_bad_segment(N111Segment{"main",0,1,0,1,body})),
   p167c_row("body-mismatch-refused",p167c_bad_segment(generic)),
   p167c_row("worker-arity-refused",p167c_bad_worker(P113DFunction{"main",[NC_Binding{0,"x",N_W64{}}],1,False{},[P113DResult{[N111Local{"x"}]}]})),
   p167c_row("worker-result-refused",p167c_bad_worker(P113DFunction{"main",[],2,False{},[P113DResult{[N111Const{7,0},N111Const{8,0}]}]})),
   p167c_row("worker-public-refused",p167c_bad_worker(P113DFunction{"main",[],1,True{},[P113DResult{[N111Const{7,0}]}]})),
   p167c_row("worker-unterminated-refused",p167c_bad_worker(P113DFunction{"main",[],1,False{},[]})),
   p167c_row("unknown-fid-refused",p167c_bad_worker(P113DFunction{"main",[],1,False{},[P113DResult{[N111FuncId{"absent"}]}]})),
   p167c_row("unknown-cid-refused",p167c_bad_worker(P113DFunction{"main",[],1,False{},[P113DResult{[N111CtorId{"absent"}]}]})),
   p167c_row("unknown-direct-refused",p167c_bad_worker(P113DFunction{"main",[],1,False{},[P113DCall{["r"],"absent",[]},P113DResult{[N111Local{"r"}]}]})),
   p167c_row("self-direct-refused",p167c_bad_worker(P113DFunction{"main",[],1,False{},[P113DCall{["r"],"main",[]},P113DResult{[N111Local{"r"}]}]})),
   p167c_row("cyclic-direct-refused",Bool.not(p167c_pass([segment],[
     P113DFunction{"other",[],1,False{},[P113DCall{["r"],"main",[]},P113DResult{[N111Local{"r"}]}]},
     P113DFunction{"main",[],1,False{},[P113DCall{["r"],"other",[]},P113DResult{[N111Local{"r"}]}]}],adapters,[]))),
   p167c_row("undefined-local-refused",p167c_bad_worker(P113DFunction{"main",[],1,False{},[P113DResult{[N111Local{"absent"}]}]})),
   p167c_row("duplicate-constructor-refused",p167c_reject(p167c_program([segment],[worker],[N_Constructor{"A",0,False{}},N_Constructor{"A",0,False{}}],[]))),
   p167c_row("invalid-static-image-refused",p167c_reject(p167c_program([segment],[worker],[N_Constructor{"A",0,False{}}],[P112SNode{0,"A",[]}]))),
   p167c_row("error-emits-no-chunks",p167c_error_only(p167e_verified(p167c_program([segment],[worker],[],[]),"deliberately invalid")))]
