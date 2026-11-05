# Standalone controls for imports-only metadata selection and literal ABI text.
# These fixtures do not claim that an empty body is independently verified.
# The ablation must retain the original final verifier before registry seeding.

@unsafe
def p164jc_row(+name: String, ok: Bool) -> String:
  nt_choose(String,ok,u => name ++ ":pass",u => name ++ ":FAIL")

@unsafe
def p164jc_direct(arity: U32, result: U32, public: Bool) -> KDef:
  p113e_insert(missing(),KDef{"main","P113Direct",arity,result,atom("Absent"),
    kt("P113Public","",Bool.to_u32(public),0,[]),[],False{},False{}})

@unsafe
def p164jc_refuses(segment: N111Segment, direct: KDef) -> Bool:
  Bool.not(p164j_eligible(segment,direct))

@unsafe
def p164jc_registry_ok(registry: P112RegionRegistry) -> Bool:
  match registry:
    case P112RegionRegistry{+ready,symbols,entries,workers,fusions}:
      +worker = p111v_get(ready,"main")
      +symbol = p111v_get(symbols,"p112w_FID_109_97_105_110_")
      String.eq(dk(worker),"P112Worker") && U32.is_eq(da(worker),0) && U32.is_eq(dx(worker),0) &&
        String.eq(dk(symbol),"P112RegionSymbol") && U32.is_eq(da(symbol),0) && U32.is_eq(dx(symbol),0) &&
        List.is_empty(&2,P112RegionEntry,entries) && U32.is_eq(workers,1) && U32.is_eq(fusions,0)

@unsafe
def p164jc_candidates_ok(candidates: List<&2,P112MultiCandidate>) -> Bool:
  match candidates:
    case Con{P112MultiCandidate{N111Segment{name,arity,result,incoming,flags,body}},Nil{}}:
      String.eq(name,"other")
    case _: False{}

@unsafe
def p164jc_controls() -> List<&2,String>:
  +segment : N111Segment = N111Segment{"main",0,1,0,0,[]}
  +other : N111Segment = N111Segment{"other",0,1,0,0,[]}
  +direct = p164jc_direct(0,1,True{})
  +imports = p111v_put(missing(),"main","P112Worker",0,0)
  +worker : P113DFunction = P113DFunction{"main",[],1,True{},[]}
  [p164jc_row("eligible-zero",p164j_eligible(segment,direct)),
   p164jc_row("eligible-arity32",p164j_eligible(N111Segment{"main",32,1,0,0,[]},p164jc_direct(32,1,True{}))),
   p164jc_row("arity33-refused",p164jc_refuses(N111Segment{"main",33,1,0,0,[]},p164jc_direct(33,1,True{}))),
   p164jc_row("missing-worker-refused",p164jc_refuses(segment,missing())),
   p164jc_row("wrong-name-refused",p164jc_refuses(other,direct)),
   p164jc_row("wrong-kind-refused",p164jc_refuses(segment,p111v_put(missing(),"main","P112Worker",0,0))),
   p164jc_row("private-worker-refused",p164jc_refuses(segment,p164jc_direct(0,1,False{}))),
   p164jc_row("worker-arity-refused",p164jc_refuses(segment,p164jc_direct(1,1,True{}))),
   p164jc_row("worker-result-refused",p164jc_refuses(segment,p164jc_direct(0,2,True{}))),
   p164jc_row("header-result-refused",p164jc_refuses(N111Segment{"main",0,2,0,0,[]},direct)),
   p164jc_row("incoming-capture-refused",p164jc_refuses(N111Segment{"main",0,1,1,0,[]},direct)),
   p164jc_row("effect-flag-refused",p164jc_refuses(N111Segment{"main",0,1,0,1,[]},direct)),
   p164jc_row("registry-real-import-no-fake-plan",p164jc_registry_ok(p164j_imports([segment,other],direct,
     P112RegionRegistry{missing(),missing(),[],0,0}))),
   p164jc_row("candidate-only-import-removed",p164jc_candidates_ok(p164j_candidates([segment,other],imports,[]))),
   p164jc_row("independent-zero-forwarder",String.eq(p164j_forward_if(worker,imports),
     "function l $p112w_FID_109_97_105_110_(l %state) {\n@entry\n%p164_forward =l call $p113d_FID_109_97_105_110_(l %state)\nret %p164_forward\n}\n")),
   p164jc_row("independent-two-forwarder",String.eq(p164j_forward("main",2),
     "function l $p112w_FID_109_97_105_110_(l %state, l %p112_arg_0, l %p112_arg_1) {\n@entry\n%p164_forward =l call $p113d_FID_109_97_105_110_(l %state, l %p112_arg_0, l %p112_arg_1)\nret %p164_forward\n}\n")),
   p164jc_row("unregistered-forwarder-absent",String.is_empty(p164j_forward_if(worker,missing()))),
   p164jc_row("analyzed-region-forwarder-absent",String.is_empty(p164j_forward_if(worker,
     p111v_put(missing(),"main","P112Worker",0,1))))]
