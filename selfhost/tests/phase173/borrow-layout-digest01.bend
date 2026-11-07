# Pair with borrowed-layout-workload and unchanged complete digest support.
@unsafe
def p173blc_repeat(n: Nat, +seed: U32, hash: U32) -> U32:
  match n:
    case 0n: hash
    case 1n+p:
      p173blc_repeat(p,U32.add(seed,7919),p173bwp_report(p173blc_large(seed),hash))

def main() -> U32:
  p173blc_repeat(8n,1,2166136261)
