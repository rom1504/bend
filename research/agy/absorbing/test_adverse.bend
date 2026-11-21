import Base

type Box is Data:
  Empty{}
  Full{val: U32}

# 1. Adverse: non-absorbing (modifies state in every branch)
def step_nonabs(+x: U32, st: Box) -> Box:
  match st:
    case Empty{}: Full{x}
    case Full{v}: Full{U32.add(v, x)}

def loop_nonabs(fuel: Nat, +x: U32, st: Box) -> Box:
  match fuel:
    case 0n: st
    case 1n+p: loop_nonabs(p, x, step_nonabs(x, st))

# 2. Adverse: step has absorbing branch, BUT f changes invariant arg x!
def pick_empty(b: Bool) -> Box:
  match b:
    case True{}: Full{99}
    case False{}: Empty{}

def step_maybe(+x: U32, st: Box) -> Box:
  match st:
    case Empty{}: pick_empty(U32.is_eq(x, 3))
    case Full{v}: Full{U32.add(v, 1)}

def loop_changing_x(fuel: Nat, +x: U32, st: Box) -> Box:
  match fuel:
    case 0n: st
    case 1n+p: loop_changing_x(p, U32.add(x, 1), step_maybe(x, st))

# 3. Adverse: Zero case does NOT return st
def dec_full(v: U32, z: Bool) -> Box:
  match z:
    case True{}: Empty{}
    case False{}: Full{U32.sub(v, 1)}

def step_abs_id(+x: U32, st: Box) -> Box:
  match st:
    case Empty{}: Empty{}
    case Full{v0}:
      +v = {v0 : U32}
      dec_full(v, U32.is_eq(v, 0))

def loop_bad_zero(fuel: Nat, +x: U32, st: Box) -> Box:
  match fuel:
    case 0n: Full{x}
    case 1n+p: loop_bad_zero(p, x, step_abs_id(x, st))

def box_val(b: Box) -> U32:
  match b:
    case Empty{}: 0
    case Full{v}: v

def main() -> IO(Unit):
  a = box_val(loop_nonabs(5n, 2, Empty{}))
  b = box_val(loop_changing_x(6n, 0, Empty{}))
  c = box_val(loop_bad_zero(5n, 7, Empty{}))
  IO.print(U32.show(U32.add(U32.add(U32.mul(a, 10000), U32.mul(b, 100)), c)))
