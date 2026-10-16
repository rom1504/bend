import Base

# Every branch owns a view of the same original suffix. Prefixes and joins
# differ by branch, making reordered or prematurely dropped results visible.
def p101_tree(+depth: Nat, +text: String) -> String:
  match depth:
    case 0n: text ++ "\n"
    case 1n+p:
      left right = p101_tree(p, "L" ++ text) p101_tree(p, "R" ++ text)
      left ++ right

def main() -> IO(Unit):
  +source : String = "λ\0🙂X"
  result = p101_tree!(4n, source)
  do IO<Unit>:
    IO.print(result)
    IO.print(source)
