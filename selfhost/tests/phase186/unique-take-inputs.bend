import Base

type TakePacket is Data:
  TakeOne{a: List<&2,U32>}
  TakeTwo{a: List<&2,U32>, b: List<&2,U32>}
  TakeThree{a: List<&2,U32>, b: List<&2,U32>, c: List<&2,U32>}
  TakeFour{a: List<&2,U32>, b: List<&2,U32>, c: List<&2,U32>, d: List<&2,U32>}

@unsafe
def take_values(n: Nat, +next: U32) -> List<&2,U32>:
  match n:
    case 0n: []
    case 1n+p: Con{next,take_values(p,U32.inc(next))}

@unsafe
def take_sum(values: List<&2,U32>) -> U32:
  match values:
    case Nil{}: 0
    case Con{value,rest}: U32.add(value,take_sum(rest))

def take_score(packet: TakePacket) -> U32:
  match packet:
    case TakeOne{a}: take_sum(a)
    case TakeTwo{a,b}: U32.add(take_sum(a),take_sum(b))
    case TakeThree{a,b,c}: U32.add(take_sum(a),U32.add(take_sum(b),take_sum(c)))
    case TakeFour{a,b,c,d}: U32.add(U32.add(take_sum(a),take_sum(b)),U32.add(take_sum(c),take_sum(d)))

@unsafe
def take_defer(n: U32, packet: TakePacket) -> TakePacket:
  match n:
    case 0: packet
    case _: take_defer(U32.sub(n,1),packet)

# Parent ownership and field ownership are independent: these packets own
# retained list fields, and the last packet itself also has two consumers.
def main() -> List<&2,U32>:
  +values = take_values(64n,1)
  +shared = take_defer(4096,TakeThree{values,values,values})
  [take_score(take_defer(4096,TakeOne{values})),
   take_score(take_defer(4096,TakeTwo{values,values})),
   take_score(take_defer(4096,TakeThree{values,values,values})),
   take_score(take_defer(4096,TakeFour{values,values,values,values})),
   U32.add(take_score(shared),take_score(shared))]
#|[2080, 4160, 6240, 8320, 12480]
