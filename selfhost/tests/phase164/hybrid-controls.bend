# Small malformed-IR controls. None of these programs is executed.
# Expected adapter instructions below are independently written, not obtained
# from p164a_body. Full source/runtime correctness remains a separate gate.

@unsafe
def p164c_book() -> List<&2,KDef>:
  [KDef{"main","Def",0,0,atom("U32"),KTerm{"U32","7",0,0,[],[],0,0},[],False{},False{}}]

def p164c_worker(+name: String, params: List<&2,NC_Binding>, result: U32, public: Bool,
    body: List<&2,P113DStmt>) -> P113DFunction:
  P113DFunction{name,params,result,public,body}

def p164c_main() -> P113DFunction:
  P113DFunction{"main",[],1,True{},[P113DResult{[N111Const{7,0}]}]}

# The exact zero-argument contract is kept independent of the producer.
def p164c_zero_body() -> List<&2,N111Stmt>:
  [N111Alloca{"p164_adapter_out",8,8},
   N111Call{"p164_value",N111U64{},"p113d_FID_109_97_105_110_",[N111Arg{N111Ptr{},N111Local{"state"}}]},
   N111Store{N111U64{},N111Local{"p164_adapter_out"},0,N111Local{"p164_value"}},
   N111Call{"p164_reply",N111U64{},"p111_rt_return",[
     N111Arg{N111Ptr{},N111Local{"state"}},N111Arg{N111Ptr{},N111Local{"p164_adapter_out"}},N111Arg{N111U32{},N111Const{1,0}}]},
   N111Return{N111Local{"p164_reply"}}]

@unsafe
def p164c_program(segments: List<&2,N111Segment>, functions: List<&2,P113DFunction>) -> P113DProgram:
  P113DProgram{P112StaticProgram{P111Program{segments,[],[0],[],[],True{}},[]},functions}

@unsafe
def p164c_adapters() -> KDef:
  p164a_put(missing(),"main","main",0)

@unsafe
def p164c_pass(+segments: List<&2,N111Segment>, +functions: List<&2,P113DFunction>, +adapters: KDef, bangs: List<&2,String>) -> Bool:
  String.is_empty(p164v_final(p164c_book(),bangs,adapters,
    P113AProgram{p164c_program(segments,functions),P113ACertificate{False{},False{}}}))

@unsafe
def p164c_bad(segment: N111Segment) -> Bool:
  Bool.not(p164c_pass([segment],[p164c_main()],p164c_adapters(),[]))

@unsafe
def p164c_bad_worker(worker: P113DFunction) -> Bool:
  Bool.not(p164c_pass([p164a_segment("main",0)],[worker],p164c_adapters(),[]))

@unsafe
def p164c_row(+name: String, ok: Bool) -> String:
  nt_choose(String,ok,u => name ++ ":pass",u => name ++ ":FAIL")

@unsafe
def p164c_error(emission: P111Emission) -> String:
  match emission:
    case P111Emission{chunks,error}: error
    case _: ""

@unsafe
def p164c_controls() -> List<&2,String>:
  +body = p164c_zero_body()
  +segment : N111Segment = N111Segment{"main",0,1,0,0,body}
  +worker = p164c_main()
  +adapters = p164c_adapters()
  [p164c_row("independent-zero-adapter-shape",p164a_shape(segment)),
   p164c_row("mixed-final-valid",p164c_pass([segment],[worker],adapters,[])),
   p164c_row("lost-final-worker-refused",Bool.not(p164c_pass([segment],[],adapters,[]))),
   p164c_row("missing-adapter-map-refused",Bool.not(p164c_pass([segment],[worker],missing(),[]))),
   p164c_row("missing-owner-header-refused",Bool.not(p164c_pass([], [worker],adapters,[]))),
   p164c_row("duplicate-header-refused",Bool.not(p164c_pass([segment,segment],[worker],adapters,[]))),
   p164c_row("duplicate-worker-refused",Bool.not(p164c_pass([segment],[worker,worker],adapters,[]))),
   p164c_row("source-owner-mismatch-refused",Bool.not(p164c_pass([segment],[worker],p164a_put(missing(),"other","main",0),[]))),
   p164c_row("source-bang-refused",Bool.not(p164c_pass([segment],[worker],adapters,["main"]))),
   p164c_row("map-arity-refused",Bool.not(p164c_pass([segment],[worker],p164a_put(missing(),"main","main",1),[]))),
   p164c_row("header-arity-refused",p164c_bad(N111Segment{"main",1,1,0,0,body})),
   p164c_row("header-result-refused",p164c_bad(N111Segment{"main",0,2,0,0,body})),
   p164c_row("header-incoming-refused",p164c_bad(N111Segment{"main",0,1,1,0,body})),
   p164c_row("header-effect-flag-refused",p164c_bad(N111Segment{"main",0,1,0,1,body})),
   p164c_row("empty-adapter-body-refused",p164c_bad(N111Segment{"main",0,1,0,0,[]})),
   p164c_row("raw-result-return-refused",p164c_bad(N111Segment{"main",0,1,0,0,[N111Return{N111Const{7,0}}]})),
   p164c_row("extra-adapter-instruction-refused",p164c_bad(N111Segment{"main",0,1,0,0,Con{N111Return{N111Const{0,0}},body}})),
   p164c_row("worker-arity-refused",p164c_bad_worker(p164c_worker("main",[NC_Binding{0,"x",N_W64{}}],1,True{},[P113DResult{[N111Local{"x"}]}]))),
   p164c_row("worker-result-refused",p164c_bad_worker(p164c_worker("main",[],2,True{},[P113DResult{[N111Const{7,0},N111Const{8,0}]}]))),
   p164c_row("worker-private-claim-refused",p164c_bad_worker(p164c_worker("main",[],1,False{},[P113DResult{[N111Const{7,0}]}]))),
   p164c_row("worker-unterminated-refused",p164c_bad_worker(p164c_worker("main",[],1,True{},[]))),
   p164c_row("worker-unknown-direct-call-refused",p164c_bad_worker(p164c_worker("main",[],1,True{},[P113DCall{["r"],"absent",[]},P113DResult{[N111Local{"r"}]}]))),
   p164c_row("worker-self-call-refused",p164c_bad_worker(p164c_worker("main",[],1,True{},[P113DCall{["r"],"main",[]},P113DResult{[N111Local{"r"}]}]))),
   p164c_row("worker-removed-fid-refused",p164c_bad_worker(p164c_worker("main",[],1,True{},[P113DResult{[N111FuncId{"removed.continuation"}]}]))),
   p164c_row("worker-undefined-value-refused",p164c_bad_worker(p164c_worker("main",[],1,True{},[P113DResult{[N111Local{"not_assigned"}]}]))),
   p164c_row("worker-scheduler-transition-refused",p164c_bad_worker(p164c_worker("main",[],1,True{},[
     P113DScalar{N111Call{"r",N111U64{},"p111_rt_jump",[p111_state(),N111Arg{N111U32{},N111FuncId{"main"}},p111_scratch(),p111_u32(0)]}},
     P113DResult{[N111Local{"r"}]}]))),
   p164c_row("unguarded-materialized-success-refused",Bool.not(String.is_empty(
     p164c_error(p164h_final(p164c_book(),[],adapters,P111Emission{[],""}))))),
   p164c_row("materialized-error-preserved",String.eq(
     p164c_error(p164h_final(p164c_book(),[],adapters,P111Emission{[],"expected failure"})),"expected failure"))]
