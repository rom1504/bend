# The second field's type depends on the first: outer shell must stay boxed.
import Base

def Choice123(flag: Bool) -> Data:
  match flag:
    case False{}: U32
    case True{}: Nat

type Packet123 is Data:
  Value123{flag: Bool, value: Choice123(flag)}

def inspect123(packet: Packet123) -> U32:
  match packet:
    case Value123{False{}, value}: value
    case Value123{True{}, value}: U32.from_nat(value)

def main() -> U32 & U32:
  (inspect123(Value123{False{}, 17}), inspect123(Value123{True{}, 9n}))

#|(17, 9)
