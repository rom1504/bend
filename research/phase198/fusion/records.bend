# Fuse a finite list producer with its left-to-right consuming Map fold.
def probe.records(n: Nat, +i: U32, +seed: U32, m: Map<&2, U32>) -> Map<&2, U32>:
  match n:
    case 0n: m
    case 1n+p:
      +key = String.append("部門", U32.show(U32.mod(U32.add(i, seed), 16)))
      amount = U32.mod(U32.add(U32.mul(i, 37), seed), 1000)
      value = p37.amount(U32.read(U32.show(amount)))
      probe.records(p, U32.add(i, 1), seed,
        p37.aggregate.put(key, value, Map.get(U32, 0, m, key)))

def bench(size: U32, seed: U32) -> String:
  p37.render(Map.to_list(&2, U32, probe.records(U32.to_nat(size), 0, seed, Map.new(&2, U32))))
