@unsafe
def p176pn_repeat(n: Nat, +seed: U32, hash: U32) -> U32:
  match n:
    case 0n: hash
    case 1n+p:
      p176pn_repeat(p,U32.add(seed,7919),p173bwp_report(p173bfp_large(seed),hash))

@unsafe
def p176pn_run() -> U32:
  p176pn_repeat(64n,1,2166136261)

def main() -> U32:
  p176pn_run()
