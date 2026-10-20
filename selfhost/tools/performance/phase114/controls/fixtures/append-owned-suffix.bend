import Base

def repeat(n: Nat, suffix: String) -> String:
  match n:
    case 0n: suffix
    case 1n+p: repeat(p, "λ" ++ suffix)

def shared(+prefix: String, +suffix: String) -> IO(Unit):
  do IO<Unit>:
    Unit <- IO.print(prefix ++ suffix)
    Unit <- IO.print(prefix)
    Unit <- IO.print(suffix)
    Unit <- IO.print("" ++ suffix)
    Unit <- IO.print(prefix ++ "")
    IO.print(prefix ++ suffix)

def main() -> IO(Unit):
  do IO<Unit>:
    Unit <- IO.print("" ++ "")
    Unit <- IO.print("literalλ" ++ "suffix🙂")
    Unit <- shared(String.reverse("α"), String.reverse("🙂β"))
    Unit <- IO.print(Nat.show(String.length(repeat(257n, String.reverse("🙂β")) ++ "end")))
    IO.print(String.reverse(String.reverse("λ🙂") ++ "tail"))

#|
#|literalλsuffix🙂
#|αβ🙂
#|α
#|β🙂
#|β🙂
#|α
#|αβ🙂
#|262
#|liatλ🙂
