# Actual maintained final verifier on nonempty arithmetic/branch programs.
# Each round requires acceptance, missing-local rejection and duplicate-header
# rejection. The independently determined result is 3 * rounds.
@unsafe
def p167w_body(+value: U32, +bad: Bool) -> List<&2,N111Stmt>:
  [N111Set{"a",N111U64{},N111Const{value,0}},
   N111Bin{"b",N111U64{},"add",N111Local{"a"},N111Const{3,0}},
   N111Set{"condition",N111U32{},N111Const{1,0}},
   N111If{N111Local{"condition"},
     [N111Return{nt_choose(N111Value,bad,u => N111Local{"missing"},u => N111Local{"b"})}],
     [N111Return{N111Const{0,0}}]}]

@unsafe
def p167w_segments(+n: U32, +value: U32, +bad: U32) -> List<&2,N111Segment>:
  match n:
    case 0: [N111Segment{"main",0,1,0,0,p167w_body(value,U32.is_eq(bad,1))}]
    case other:
      +name = nt_choose(String,U32.is_eq(bad,2),u => "main",u => "worker_" ++ U32.show(n))
      Con{N111Segment{name,0,1,0,0,p167w_body(U32.add(value,n),False{})},
        p167w_segments(U32.sub(n,1),value,bad)}

@unsafe
def p167w_check(value: U32, bad: U32) -> Bool:
  String.is_empty(p111_verify_program(P111Program{p167w_segments(31,value,bad),[],[0],[],[],True{}}))

@unsafe
def p167w_round(+n: U32, +acc: U32) -> U32:
  match n:
    case 0: acc
    case other:
      +ok = Bool.to_u32(p167w_check(n,0))
      +missing = Bool.to_u32(Bool.not(p167w_check(n,1)))
      +duplicate = Bool.to_u32(Bool.not(p167w_check(n,2)))
      p167w_round(U32.sub(n,1),U32.add(acc,U32.add(ok,U32.add(missing,duplicate))))

@unsafe
def main() -> U32:
  p167w_round(256,0)
#| 768
