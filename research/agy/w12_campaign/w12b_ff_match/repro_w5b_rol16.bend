import Base

type X187Operand is Data:
  X187Reg{+index: U32, +width: U32, +vector: Bool}
  X187Imm{+lo: U32, +hi: U32}
  X187Mem{+base: U32, +disp: U32}
  X187Rip{+symbol: String, +addendLo: U32, +addendHi: U32}
  X187Target{+symbol: String}
  X187Indexed{+base: U32, +index: U32, +scale: U32, +disp: U32}

type X187Instruction is Data:
  X187Instruction{+op: String, +operands: List<&2,X187Operand>}

type X187Parsed is Data:
  PInst{+inst: X187Instruction}
  PLabel{+name: String}
  PEmpty{}

def nt_choose(-A: Type, +b: Bool, t: Unit -> A, f: Unit -> A) -> A:
  match b:
    case True{}: t(Unit{})
    case False{}: f(Unit{})

def agy_str_eq(a: String, b: String) -> Bool:
  String.eq(a, b)

def x188_reg(r: U32, w: U32) -> X187Operand:
  X187Reg{r, w, False{}}

def w5b_reg_dead_fast(r: U32, tail: List<&2,X187Parsed>, fnItems: List<&2,X187Parsed>) -> Bool:
  True{}

@unsafe
def w5b_try_rol16(+rX: U32, +rA: U32, rest: List<&2,X187Parsed>, +fnItems: List<&2,X187Parsed>) -> Maybe<&2,List<&2,X187Parsed>>:
  match rest:
    case Con{PInst{X187Instruction{op1,Con{X187Imm{+k,0},Con{X187Reg{ra1,64,False{}},Nil{}}}}},
         Con{PInst{X187Instruction{op2,Con{X187Reg{ra2a,32,False{}},Con{X187Reg{ra2b,32,False{}},Nil{}}}}},
         Con{PInst{X187Instruction{op3,Con{X187Reg{rx3,64,False{}},Con{X187Reg{+rB,64,False{}},Nil{}}}}},
         Con{PInst{X187Instruction{op4,Con{X187Imm{+m,0},Con{X187Reg{rb4,64,False{}},Nil{}}}}},
         Con{PInst{X187Instruction{op5,Con{X187Reg{rb5,64,False{}},Con{X187Reg{ra5,64,False{}},Nil{}}}}},
         Con{PInst{X187Instruction{op6,Con{X187Imm{65535,0},Con{X187Reg{ra6,64,False{}},Nil{}}}}},+tail}}}}}}:
      +ok = agy_str_eq(op1,"shlq") && agy_str_eq(op2,"movl") && agy_str_eq(op3,"movq") &&
            agy_str_eq(op4,"shrq") && agy_str_eq(op5,"orq") && agy_str_eq(op6,"andq") &&
            U32.is_eq(ra1,rA) && U32.is_eq(ra2a,rA) && U32.is_eq(ra2b,rA) &&
            U32.is_eq(rx3,rX) && U32.is_eq(rb4,rB) && U32.is_eq(rb5,rB) &&
            U32.is_eq(ra5,rA) && U32.is_eq(ra6,rA) &&
            Bool.not(U32.is_eq(rB,rA)) && Bool.not(U32.is_eq(rB,rX)) &&
            U32.is_ge(k,1) && U32.is_le(k,15) && U32.is_eq(U32.add(k,m),16) &&
            w5b_reg_dead_fast(rB,tail,fnItems)
      nt_choose(Maybe<&2,List<&2,X187Parsed>>,ok,
        u => Some{Con{PInst{X187Instruction{"movzwl",[x188_reg(rX,32),x188_reg(rA,32)]}},
                  Con{PInst{X187Instruction{"rolw",[X187Imm{k,0},x188_reg(rA,32)]}},tail}}},
        u => None{})
    case _: None{}

def len_parsed(xs: List<&2, X187Parsed>) -> U32:
  match xs:
    case Nil{}: 0
    case Con{_, rest}: U32.add(1, len_parsed(rest))

def score_maybe(m: Maybe<&2,List<&2,X187Parsed>>) -> U32:
  match m:
    case None{}: 0
    case Some{xs}: U32.add(100, len_parsed(xs))

@unsafe
def main() -> U32:
  U32.add(
    score_maybe(w5b_try_rol16(0, 1, [
      PInst{X187Instruction{"shlq", [X187Imm{3, 0}, X187Reg{1, 64, False{}}]}},
      PInst{X187Instruction{"movl", [X187Reg{1, 32, False{}}, X187Reg{1, 32, False{}}]}},
      PInst{X187Instruction{"movq", [X187Reg{0, 64, False{}}, X187Reg{2, 64, False{}}]}},
      PInst{X187Instruction{"shrq", [X187Imm{13, 0}, X187Reg{2, 64, False{}}]}},
      PInst{X187Instruction{"orq", [X187Reg{2, 64, False{}}, X187Reg{1, 64, False{}}]}},
      PInst{X187Instruction{"andq", [X187Imm{65535, 0}, X187Reg{1, 64, False{}}]}}
    ], Nil{})),
    score_maybe(w5b_try_rol16(0, 1, [PEmpty{}], Nil{})))
