import Base
# u3_bytecode_vm: Tagged-union bytecode VM evaluator over List<&2, Inst>
# Unseen benchmark testing 8-way ADT TSwitch jump-table, borrow (0 p111_rt_take),
# and register-state threading across 40,000 runs of a 256-instruction program.

type Inst is Data:
  IAdd{}
  ISub{}
  IMul{k: U32}
  IXor{k: U32}
  IShr{k: Nat}
  IShl{k: Nat}
  IRot{}
  IMix{k: U32}

type VMState is Data:
  VMS{r0: U32, r1: U32, r2: U32, r3: U32}

def prng(+x: U32) -> U32:
  +b = U32.xor(x, U32.shln(x, 13n))
  +d = U32.xor(b, U32.shrn(b, 17n))
  U32.xor(d, U32.shln(d, 5n))

def mk_inst.go(op: Nat, +arg: U32) -> Inst:
  match op:
    case 0n:
      IAdd{}
    case 1n:
      ISub{}
    case 2n:
      IMul{U32.or(arg, 1)}
    case 3n:
      IXor{arg}
    case 4n:
      IShr{U32.to_nat(U32.inc(U32.and(arg, 7)))}
    case 5n:
      IShl{U32.to_nat(U32.inc(U32.and(arg, 7)))}
    case 6n:
      IRot{}
    case 7n+p:
      IMix{arg}

def mk_inst(+op: U32, +arg: U32) -> Inst:
  mk_inst.go(U32.to_nat(op), arg)

def build_prog(+n: Nat, +seed: U32, acc: List<&2, Inst>) -> List<&2, Inst>:
  match n:
    case 0n:
      acc
    case 1n+p:
      +s1 = prng(seed)
      +s2 = prng(s1)
      build_prog(p, s2, Con{mk_inst(U32.and(s1, 7), s2), acc})

def eval_prog(prog: List<&2, Inst>, +r0: U32, +r1: U32, +r2: U32, +r3: U32) -> VMState:
  match prog:
    case Nil{}:
      VMS{r0, r1, r2, r3}
    case Con{ins, rest}:
      match ins:
        case IAdd{}:
          eval_prog(rest, U32.add(r0, r1), r1, r2, r3)
        case ISub{}:
          eval_prog(rest, U32.sub(r0, r2), r1, r2, r3)
        case IMul{k}:
          eval_prog(rest, U32.mul(r0, k), r1, r2, r3)
        case IXor{k}:
          eval_prog(rest, U32.xor(r0, k), r1, r2, r3)
        case IShr{k}:
          eval_prog(rest, U32.xor(r0, U32.shrn(r1, k)), r1, r2, r3)
        case IShl{k}:
          eval_prog(rest, U32.xor(r0, U32.shln(r2, k)), r1, r2, r3)
        case IRot{}:
          eval_prog(rest, r1, r2, r3, r0)
        case IMix{k}:
          eval_prog(rest, U32.add(U32.xor(r0, r3), k), U32.add(r1, r0), r2, U32.xor(r3, r1))

def run_vm(+iters: Nat, +prog: List<&2, Inst>, st: VMState) -> U32:
  match iters:
    case 0n:
      VMS{r0, r1, r2, r3} = st
      U32.xor(U32.xor(r0, r1), U32.xor(r2, r3))
    case 1n+p:
      VMS{r0, r1, r2, r3} = st
      run_vm(p, prog, eval_prog(prog, r0, r1, r2, r3))

def main() -> U32:
  +prog = build_prog(256n, 123456789, Nil{})
  run_vm(100000n, prog, VMS{1, 2, 3, 4})
