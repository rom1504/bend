# Finite controls for the late-only preparation overlay. These do not change
# the production verifier, candidate factories, initial lowering or emission.

def p128prepc_function(name: String, value: U32) -> P113DFunction:
  P113DFunction{name,[],1,False{},[P113DResult{[N111Const{value,0}]}]}

@unsafe
def p128prepc_info(route: String) -> KDef:
  KDef{"source_name","NQSignature",0,0,kt("NQShape","Tuple",2,0,[]),kt("NQSig",route,0,0,[]),[],False{},False{}}

@unsafe
def p128prepc_render(candidates: List<&2,P113DCandidate>, +seed: List<&2,P113DFunction>) -> String:
  nt_join(p113e_private_chunks(p113d_passes(candidates,p113e_signatures(seed,missing()),
    nt_reverse(P113DFunction,seed,[]),32),N111Ids{missing(),missing()},[]),"")

@unsafe
def p128prepc_prune(candidates: List<&2,P113DCandidate>, +ready: KDef) -> List<&2,P113DCandidate>:
  match candidates:
    case Nil{}: []
    case Con{+candidate,+rest}:
      match candidate:
        case P113DCandidate{P113DFunction{+name,params,result,public,body},error,calls}:
          nt_choose(List<&2,P113DCandidate>,p113d_ready(ready,name),
            u => p128prepc_prune(rest,ready),u => Con{candidate,p128prepc_prune(rest,ready)})

@unsafe
def p128prepc_equal(+candidates: List<&2,P113DCandidate>, +seed: List<&2,P113DFunction>) -> Bool:
  String.eq(p128prepc_render(candidates,seed),
    p128prepc_render(p128prepc_prune(candidates,p113e_signatures(seed,missing())),seed))

@unsafe
def p128prep_controls() -> List<&2,String>:
  +existing = p128prepc_function("$product.control",17)
  +ready = p113e_signatures([existing],missing())
  +info = p128prepc_info("$product.control")
  +duplicate : P113DCandidate = P113DCandidate{p128prepc_function("$product.control",999),"",[]}
  +bad : P113DCandidate = P113DCandidate{P113DFunction{"$product.control",[],0,True{},[]},"deliberate error",["absent"]}
  +last : P113DCandidate = P113DCandidate{p128prepc_function("third",3),"",["second"]}
  +middle : P113DCandidate = P113DCandidate{p128prepc_function("second",2),"",["$product.control"]}
  +blocked : P113DCandidate = P113DCandidate{p128prepc_function("blocked",4),"",["absent"]}
  [p126bpc_row("late-flat-ready-exact-symbol",Bool.not(p128prep_flat_needed(info,ready))),
   p126bpc_row("late-flat-unknown-symbol-retained",p128prep_flat_needed(info,missing())),
   p126bpc_row("late-flat-public-ready-not-enough",p128prep_flat_needed(info,p113e_signatures([p128prepc_function("source_name",7)],missing()))),
   p126bpc_row("late-flat-other-route-retained",p128prep_flat_needed(p128prepc_info("$product.other"),ready)),
   p126bpc_row("late-flat-nondirect-record-not-ready",p128prep_flat_needed(info,p111v_put(missing(),"$product.control","P113Original",0,0))),
   p126bpc_row("late-flat-missing-signature-refused",Bool.not(p128prep_flat_needed(missing(),ready))),
   p126bpc_row("late-flat-exact-qbe-ready-body-retained",p128prepc_equal([duplicate],[existing])),
   p126bpc_row("late-flat-exact-qbe-ready-error-ignored",p128prepc_equal([bad],[existing])),
   p126bpc_row("late-flat-exact-qbe-dependency-order",p128prepc_equal([last,duplicate,middle],[existing])),
   p126bpc_row("late-flat-exact-qbe-blocked-unchanged",p128prepc_equal([blocked,bad,last,middle],[existing])),
   p126bpc_row("late-flat-exact-qbe-empty-ready",p128prepc_equal([last,middle,duplicate],[])),
   p126bpc_row("late-flat-final-verifier-still-refuses-invalid",Bool.not(String.is_empty(
     p113e_functions([P113DFunction{"invalid",[],0,False{},[]}],N111Ids{missing(),missing()},missing()))))]
