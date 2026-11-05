# Small Phase165 derivative of tests/check/conversion_shared_cells_once.bend; depth4 bounds the no-memo control.
import Base


def mix(a: U32, b: U32) -> U32:
  (a * 31 + b : U32)

def root_loop(d: Nat, +h: U32) -> U32:
  match d:
    case 0n: h
    case 1n+p: root_loop(p, mix(h, h))

def sq(+h: U32) -> U32:
  mix(h, h)

def root_rec(d: Nat, +x: U32) -> U32:
  match d:
    case 0n: x
    case 1n+p: sq(root_rec(p, x))




def agree_4(+x: U32) -> {root_loop(4n, x) == root_rec(4n, x) : U32}:
  {==}

#|ALL PROOFS CHECK
#|Use --verdict for mathematical validity.
