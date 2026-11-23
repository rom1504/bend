import Base

def samples(+depth: Nat, +x: U32, +salt: U32) -> U32:
  match depth:
    case 0n: U32.xor(U32.mul(x, x), salt)
    case 1n+p:
      a b = samples(p, x, salt) samples(p, U32.add(x, U32.shln(7, p)), salt)
      U32.add(a, b)

def main() -> IO(Unit):
  IO.print(U32.show(samples(0n, 4294967287, 37)) ++ "," ++ U32.show(samples(1n, 4294967287, 37)) ++ "," ++ U32.show(samples(8n, 4294967287, 37)))
