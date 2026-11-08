import Base
import ./namespace.bend as N

type NatBox is Data:
  NatBox{+value: Nat}

type PairData is Data:
  PairData{+left: U32, +right: U32}

type DottedBox is Data:
  namespace.Box{+value: Nat}

def nat_id(n: Nat) -> Nat: n
def nat_add(a: Nat, b: Nat) -> Nat: Nat.add(a, b)
def float_id(x: F32) -> F32: x
def float_from_nat(n: Nat) -> F32: F32.from_nat(n)
def float_pow(x: F32, y: F32) -> F32: F32.pow(x, y)
def float_read(s: String) -> Maybe<&2,F32>: F32.read(s)
def text_id(s: String) -> String: s
def text_literal() -> String: "a\u{d800}\u{110000}\u{ffffffff}"
def char_literal() -> U32: Char.to_u32('\u{ffffffff}')
def char_id(c: Char) -> Char: c
def char_round(n: U32) -> U32: Char.to_u32(Char.from_u32(n))
def char_out(n: U32) -> Char: Char.from_u32(n)
def text_out(n: U32) -> String: SCon{Char.from_u32(n), "x"}
def text_size(n: U32) -> Nat: String.length(SCon{Char.from_u32(n), "x"})
def text_tail_on(s: String) -> String:
  match s:
    case SNil{}: ""
    case SCon{h, t}: t
def text_tail(n: U32) -> String: text_tail_on(SCon{Char.from_u32(n), "x"})
def box_id(b: NatBox) -> NatBox: b
def box_make(n: Nat) -> NatBox: NatBox{n}
def imported_make(n: Nat) -> N.Box: N.make(n)
def imported_take(b: N.Box) -> Nat: N.take(b)
def dotted_make(n: Nat) -> DottedBox: namespace.Box{n}
def dotted_take(b: DottedBox) -> Nat:
  match b:
    case namespace.Box{n}: n
def imported_left(n: Nat) -> N.Choice: N.left(n)
def imported_right(n: Nat) -> N.Choice: N.right(n)
def imported_score(b: N.Choice) -> Nat:
  match b:
    case N.Local.Left{n}: n
    case N.Local.Right{n}: Nat.add(n, 1n)
def pair_array() -> Array<PairData>: Array.new(PairData, 2n, PairData{3, 5})
def namespace.make(n: Nat) -> Nat: n
def __proto__(n: Nat) -> Nat: n
