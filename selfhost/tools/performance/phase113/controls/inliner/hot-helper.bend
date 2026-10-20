import Base

# Repeated closed helper calls with U32 wrap; no program-name specialization.
def mix(+x: U32) -> U32:
  U32.xor(U32.add(x, 17), U32.shln(x, 3n))

def loop(n: Nat, x: U32) -> U32:
  match n:
    case 0n: x
    case 1n+p: loop(p, mix(x))

def main() -> IO(Unit):
  do IO<Unit>:
    Unit <- IO.print(U32.show(loop(0n, 4294967295)))
    Unit <- IO.print(U32.show(loop(1n, 4294967295)))
    Unit <- IO.print(U32.show(loop(31n, 7)))
    IO.print(U32.show(loop(100001n, 123)))

#|4294967295
#|4294967272
#|605313926
#|4180656564
