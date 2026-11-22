import Base

def dyn_zero_go(n: Nat, +acc: U32) -> U32:
  match n:
    case 0n: acc
    case 1n+p: dyn_zero_go(p, U32.and(acc, 0))

def dyn_zero() -> U32:
  dyn_zero_go(U32.to_nat(300000), 0)

type TriggerHot is Data:
  TriggerHot{a: U32, b: U32}

def trigger(t: TriggerHot) -> U32:
  match t:
    case TriggerHot{a, b}: U32.add(a, b)

def s_hash(s: String, acc: U32) -> U32:
  match s:
    case SNil{}: acc
    case SCon{Chr{x}, t}: s_hash(t, U32.add(U32.mul(acc, 31), x))

def m_digest(xs: List<&2, Sigma<&2, &2, String, _ => U32>>, acc: U32) -> U32:
  match xs:
    case Nil{}: acc
    case (k, v) <> t: m_digest(t, U32.xor(U32.mul(s_hash(k, acc), 16777619), v))

def main() -> IO(Unit):
  +z = dyn_zero()
  m = Map.new(&2, U32)
  m = Map.set(&2, U32, m, "a", U32.add(z, 1))
  m = Map.set(&2, U32, m, "b", U32.add(z, 2))
  m = Map.set(&2, U32, m, "c", U32.add(z, 3))
  m = Map.set(&2, U32, m, "d", U32.add(z, 4))
  +t = trigger(TriggerHot{z, 0})
  m = Map.del(&2, U32, m, "b")
  IO.print(U32.show(U32.add(m_digest(Map.to_list(&2, U32, m), 2166136261), t)))
