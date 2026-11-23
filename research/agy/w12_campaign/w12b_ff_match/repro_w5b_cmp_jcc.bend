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

def w5b_set_cc(op: String) -> String:
  nt_choose(String, agy_str_eq(op, "sete"), u => "e", u => "")

def w5b_j_cc(+cc: String, inv: Bool) -> String:
  nt_choose(String, inv, u => "jn" ++ cc, u => "j" ++ cc)

def w5b_reg_dead_fast(r: U32, tail: List<&2,X187Parsed>, fnItems: List<&2,X187Parsed>) -> Bool:
  True{}

@unsafe
def w5b_try_cmp_jcc(+cmpInst: X187Parsed, rest: List<&2,X187Parsed>, +fnItems: List<&2,X187Parsed>) -> Maybe<&2,List<&2,X187Parsed>>:
  match rest:
    case Con{PInst{X187Instruction{+opSet,Con{X187Reg{+rA,8,False{}},Nil{}}}},
         Con{PInst{X187Instruction{opZ,Con{X187Reg{rz1,8,False{}},Con{X187Reg{rz2,32,False{}},Nil{}}}}},
         Con{PInst{X187Instruction{opX,Con{X187Imm{1,0},Con{X187Reg{rx,32,False{}},Nil{}}}}},
         Con{PInst{X187Instruction{opM,Con{X187Reg{rm1,64,False{}},Con{X187Reg{+rB,64,False{}},Nil{}}}}},
         Con{PInst{X187Instruction{opT,Con{X187Reg{rt1,32,False{}},Con{X187Reg{rt2,32,False{}},Nil{}}}}},
         Con{PInst{X187Instruction{+opJ,Con{X187Target{+lbl},Nil{}}}},+tail}}}}}}:
      +cc = w5b_set_cc(opSet)
      +isE = agy_str_eq(opJ,"je") || agy_str_eq(opJ,"jz")
      +isN = agy_str_eq(opJ,"jne") || agy_str_eq(opJ,"jnz")
      +ok = Bool.not(String.is_empty(cc)) && (isE || isN) &&
            agy_str_eq(opZ,"movzbl") && agy_str_eq(opX,"xorl") && agy_str_eq(opM,"movq") && agy_str_eq(opT,"testl") &&
            U32.is_eq(rz1,rA) && U32.is_eq(rz2,rA) && U32.is_eq(rx,rA) && U32.is_eq(rm1,rA) &&
            U32.is_eq(rt1,rB) && U32.is_eq(rt2,rB) &&
            w5b_reg_dead_fast(rA,tail,fnItems) && w5b_reg_dead_fast(rB,tail,fnItems)
      nt_choose(Maybe<&2,List<&2,X187Parsed>>,ok,
        u => Some{Con{cmpInst,Con{PInst{X187Instruction{w5b_j_cc(cc,isN),[X187Target{lbl}]}},tail}}},
        u => None{})
    case Con{PInst{X187Instruction{+opSet,Con{X187Reg{+rA,8,False{}},Nil{}}}},
         Con{PInst{X187Instruction{opZ,Con{X187Reg{rz1,8,False{}},Con{X187Reg{rz2,32,False{}},Nil{}}}}},
         Con{PInst{X187Instruction{opM,Con{X187Reg{rm1,64,False{}},Con{X187Reg{+rB,64,False{}},Nil{}}}}},
         Con{PInst{X187Instruction{opX,Con{X187Imm{1,0},Con{X187Reg{rx,32,False{}},Nil{}}}}},
         Con{PInst{X187Instruction{opT,Con{X187Reg{rt1,32,False{}},Con{X187Reg{rt2,32,False{}},Nil{}}}}},
         Con{PInst{X187Instruction{+opJ,Con{X187Target{+lbl},Nil{}}}},+tail}}}}}}:
      +cc = w5b_set_cc(opSet)
      +isE = agy_str_eq(opJ,"je") || agy_str_eq(opJ,"jz")
      +isN = agy_str_eq(opJ,"jne") || agy_str_eq(opJ,"jnz")
      +ok = Bool.not(String.is_empty(cc)) && (isE || isN) &&
            agy_str_eq(opZ,"movzbl") && agy_str_eq(opM,"movq") && agy_str_eq(opX,"xorl") && agy_str_eq(opT,"testl") &&
            U32.is_eq(rz1,rA) && U32.is_eq(rz2,rA) && U32.is_eq(rm1,rA) && U32.is_eq(rx,rB) &&
            U32.is_eq(rt1,rB) && U32.is_eq(rt2,rB) &&
            w5b_reg_dead_fast(rA,tail,fnItems) && w5b_reg_dead_fast(rB,tail,fnItems)
      nt_choose(Maybe<&2,List<&2,X187Parsed>>,ok,
        u => Some{Con{cmpInst,Con{PInst{X187Instruction{w5b_j_cc(cc,isN),[X187Target{lbl}]}},tail}}},
        u => None{})
    case Con{PInst{X187Instruction{+opSet,Con{X187Reg{+rA,8,False{}},Nil{}}}},
         Con{PInst{X187Instruction{opZ,Con{X187Reg{rz1,8,False{}},Con{X187Reg{rz2,32,False{}},Nil{}}}}},
         Con{PInst{X187Instruction{opM,Con{X187Reg{rm1,64,False{}},Con{X187Reg{+rB,64,False{}},Nil{}}}}},
         Con{PInst{X187Instruction{opT,Con{X187Reg{rt1,32,False{}},Con{X187Reg{rt2,32,False{}},Nil{}}}}},
         Con{PInst{X187Instruction{+opJ,Con{X187Target{+lbl},Nil{}}}},+tail}}}}}:
      +cc = w5b_set_cc(opSet)
      +isE = agy_str_eq(opJ,"je") || agy_str_eq(opJ,"jz")
      +isN = agy_str_eq(opJ,"jne") || agy_str_eq(opJ,"jnz")
      +ok = Bool.not(String.is_empty(cc)) && (isE || isN) &&
            agy_str_eq(opZ,"movzbl") && agy_str_eq(opM,"movq") && agy_str_eq(opT,"testl") &&
            U32.is_eq(rz1,rA) && U32.is_eq(rz2,rA) && U32.is_eq(rm1,rA) &&
            U32.is_eq(rt1,rB) && U32.is_eq(rt2,rB) &&
            w5b_reg_dead_fast(rA,tail,fnItems) && w5b_reg_dead_fast(rB,tail,fnItems)
      nt_choose(Maybe<&2,List<&2,X187Parsed>>,ok,
        u => Some{Con{cmpInst,Con{PInst{X187Instruction{w5b_j_cc(cc,isE),[X187Target{lbl}]}},tail}}},
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
    score_maybe(w5b_try_cmp_jcc(
      PInst{X187Instruction{"cmpq", [X187Reg{0, 64, False{}}, X187Reg{1, 64, False{}}]}},
      [
        PInst{X187Instruction{"sete", [X187Reg{0, 8, False{}}]}},
        PInst{X187Instruction{"movzbl", [X187Reg{0, 8, False{}}, X187Reg{0, 32, False{}}]}},
        PInst{X187Instruction{"movq", [X187Reg{0, 64, False{}}, X187Reg{1, 64, False{}}]}},
        PInst{X187Instruction{"testl", [X187Reg{1, 32, False{}}, X187Reg{1, 32, False{}}]}},
        PInst{X187Instruction{"je", [X187Target{"L1"}]}}
      ], Nil{})),
    score_maybe(w5b_try_cmp_jcc(
      PInst{X187Instruction{"cmpq", [X187Reg{0, 64, False{}}, X187Reg{1, 64, False{}}]}},
      [PEmpty{}], Nil{})))
