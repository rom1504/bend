import Base
import ../../../proofs/phase94/candidate01/helper.bend as H
import ../../../proofs/phase94/candidate01/reference.bend as R

def p94.hit(mask: U32, value: U32) -> Bool:
  U32.is_eq(U32.and(mask, value), 0)

def p94.drop(value: U32, suffix: U32) -> U32:
  U32.add(U32.mul(value, 31), suffix)

def p94.rows(+n: Nat) -> List<&2, U32>:
  match n:
    case 0n: Nil{}
    case 1n+p: Con{U32.from_nat(p), p94.rows(p)}

def p94.fold(rows: List<&2, U32>, acc: U32) -> U32:
  match rows:
    case Nil{}: acc
    case Con{head, rest}: p94.fold(rest, U32.add(U32.mul(acc, 31), head))

def p94.checksum(part: H.NPE_Part<U32, U32>) -> U32:
  match part:
    case H.NPE_Part{rows, drop}: p94.fold(rows, drop)

def p94.kernel(+mask: U32, rows: List<&2, U32>, binding: U32) -> H.NPE_Part<U32, U32>:
  @KERNEL@

def p94.loop(n: Nat, +rows: List<&2, U32>, +mask: U32, +binding: U32, acc: U32) -> U32:
  match n:
    case 0n: acc
    case 1n+p:
      p94.loop(p, rows, mask, binding, U32.add(acc, p94.checksum(p94.kernel(mask, rows, binding))))

def p94.nat(x: Maybe<&2, Nat>) -> Nat:
  match x:
    case None{}: 1n
    case Some{n}: n

def p94.options(args: List<String>) -> (Nat & Nat) & (U32 & U32):
  match args:
    case reps <> size <> mask <> binding <> Nil{}:
      ((p94.nat(Nat.read(reps)), p94.nat(Nat.read(size))), (U32.from_nat(p94.nat(Nat.read(mask))), U32.from_nat(p94.nat(Nat.read(binding)))))
    case head <> rest: p94.options(rest)
    case Nil{}: ((10n, 16n), (1, 17))

def p94.execute(reps: Nat, +rows: List<&2, U32>, +mask: U32, +binding: U32) -> IO(Unit):
  do IO<Unit>:
    Unit <- IO.print(U32.show(p94.checksum(p94.kernel(mask, rows, binding))))
    t0 : Nat <- IO.now()
    Unit <- IO.print(U32.show(p94.loop(reps, rows, mask, binding, 0)))
    t1 : Nat <- IO.now()
    IO.print(Nat.show(Nat.sub(t1, t0)))

def p94.run(options: (Nat & Nat) & (U32 & U32)) -> IO(Unit):
  (sizes, values) = options
  (reps, size) = sizes
  (mask, binding) = values
  p94.execute(reps, p94.rows(size), mask, binding)

def main() -> IO(Unit):
  do IO<Unit>:
    args : List<String> <- IO.args()
    p94.run(p94.options(args))
