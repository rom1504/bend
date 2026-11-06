# Exact finite IR controls for the successor. No runtime bodies are executed.
# Every branch retains its own environment and complete remaining continuation.

@unsafe
def p171di_exact(actual: P171DCode, expected: List<&2,P113DStmt>, next: U32, yes: U32, no: U32, rooted: Bool) -> Bool:
  match actual:
    case P171DCode{body,helpers,n,accepted,declined,held}:
      p134v_list(~P113DStmt,~p134v_stmt,body,expected) && List.is_empty(&2,P113DFunction,helpers) &&
        U32.is_eq(n,next) && U32.is_eq(accepted,yes) && U32.is_eq(declined,no) && p134v_bool(held,rooted)

@unsafe
def p171di_assign(+bit: U32) -> Bool:
  p171di_exact(p171dc_run([
    P113DScalar{N111Set{"condition",N111U32{},N111Const{bit,0}}},
    P113DScalar{N111If{N111Local{"condition"},
      [N111Set{"selected",N111U64{},N111Local{"root"}}],
      [N111Set{"selected",N111U64{},N111Const{0,0}}]}},
    P113DScalar{N111Set{"alias",N111U64{},N111Local{"selected"}}},
    P113DResult{[N111Local{"alias"}]}],[]),[
    P113DScalar{N111Set{"condition",N111U32{},N111Const{bit,0}}},
    P113DIf{N111Local{"condition"},[
      P113DScalar{N111Set{"selected",N111U64{},N111Local{"root"}}},
      P113DScalar{N111Set{"alias",N111U64{},N111Local{"selected"}}},
      P113DResult{[N111Const{1,0},N111Local{"alias"}]}],[
      P113DScalar{N111Set{"selected",N111U64{},N111Const{0,0}}},
      P113DScalar{N111Set{"alias",N111U64{},N111Local{"selected"}}},
      P113DResult{[N111Const{1,0},N111Local{"alias"}]}]}],8,2,0,True{})

@unsafe
def p171di_refusal(stmt: N111Stmt) -> Bool:
  p171di_exact(p171dc_run([
    P113DScalar{N111Set{"condition",N111U32{},N111Const{1,0}}},
    P113DScalar{N111If{N111Local{"condition"},[stmt],[]}},
    P113DResult{[N111Local{"root"}]}],[]),[
    P113DScalar{N111Set{"condition",N111U32{},N111Const{1,0}}},
    P113DIf{N111Local{"condition"},[P113DResult{[N111Const{0,0},N111Const{0,0}]}],
      [P113DResult{[N111Const{1,0},N111Local{"root"}]}]}],4,1,1,True{})

@unsafe
def p171d_scalar_if_controls() -> List<&2,String>:
  [p171dc_row("scalar-if-true-full-branches-later-alias",p171di_assign(1)),
   p171dc_row("scalar-if-false-full-branches-later-alias",p171di_assign(0)),
   p171dc_row("scalar-if-store-arm-declines-before-continuation",p171di_refusal(N111Store{N111U64{},N111Local{"scratch"},0,N111Local{"root"}})),
   p171dc_row("scalar-if-terminal-arm-declines-without-fallthrough",p171di_refusal(N111Return{N111Local{"root"}})),
   p171dc_row("scalar-if-unknown-call-arm-declines",p171di_refusal(N111Call{"effect",N111U64{},"unknown_effect",[p111_state()]})),
   p171dc_row("scalar-if-unknown-condition-declines",p171di_exact(p171dc_run([
     P113DScalar{N111If{N111Local{"unknown"},[],[]}},P113DResult{[N111Local{"root"}]}],[]),
     [P113DResult{[N111Const{0,0},N111Const{0,0}]}],1,0,1,False{})),
   p171dc_row("scalar-if-branch-local-does-not-leak",p171di_exact(p171dc_run([
     P113DScalar{N111Set{"condition",N111U32{},N111Const{1,0}}},
     P113DScalar{N111If{N111Local{"condition"},[N111Set{"local",N111U64{},N111Local{"root"}}],[]}},
     P113DResult{[N111Local{"local"}]}],[]),[
     P113DScalar{N111Set{"condition",N111U32{},N111Const{1,0}}},
     P113DIf{N111Local{"condition"},[
       P113DScalar{N111Set{"local",N111U64{},N111Local{"root"}}},P113DResult{[N111Const{1,0},N111Local{"local"}]}],
       [P113DResult{[N111Const{0,0},N111Const{0,0}]}]}],5,1,1,True{}))]
