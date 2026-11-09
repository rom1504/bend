import Base

type Envelope is Data:
  Envelope{+payload: Nat}

def unwrap(envelope: Envelope) -> Nat:
  match envelope:
    case Envelope{payload}: payload

def twice(+envelope: Envelope) -> Nat:
  Nat.add(unwrap(envelope),unwrap(envelope))

@unsafe
def wrap_input(left: U32, +payload: Nat) -> Envelope:
  match left:
    case 0: Envelope{payload}
    case _: wrap_input(U32.sub(left,1),payload)

# Payloads below/at the 40-bit boundary are packed; larger words require heap
# constructors. A bounded loop feeds dynamic function parameters to the
# constructor. Retained aliases exercise both representation-specific paths.
# Wide values are built arithmetically: the selected frontend accepts U32
# source literal magnitudes, and Nat values must stay within the 48-bit immediate range.
def main() -> List<&2,Nat>:
  +word32 = Nat.mul(65536n,65536n)
  +word40 = Nat.mul(word32,256n)
  +word48_max = Nat.add(Nat.mul(word32,65535n),Nat.sub(word32,1n))
  [unwrap(wrap_input(4096,0n)),unwrap(wrap_input(4096,1n)),unwrap(wrap_input(4096,word32)),
   unwrap(wrap_input(4096,Nat.sub(word40,1n))),unwrap(wrap_input(4096,word40)),
   unwrap(wrap_input(4096,word48_max)),twice(wrap_input(4096,word40)),
   twice(wrap_input(4096,Nat.sub(word40,1n)))]

#|[0n, 1n, 4294967296n, 1099511627775n, 1099511627776n, 281474976710655n, 2199023255552n, 2199023255550n]
