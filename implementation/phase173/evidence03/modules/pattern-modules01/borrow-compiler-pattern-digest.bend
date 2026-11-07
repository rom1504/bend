# Pair with borrow-compiler-digest-support.bend; all fields enter the digest.
@unsafe
def p173bfp_repeat(n: Nat, +seed: U32, hash: U32) -> U32:
  match n:
    case 0n: hash
    case 1n+p:
      p173bfp_repeat(p,U32.add(seed,7919),p173bwp_report(p173bfp_large(seed),hash))

def main() -> U32:
  p173bfp_repeat(8n,1,2166136261)
