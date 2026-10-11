import Base

law first:
  for -A: Type
  for x: A
  for y: A
  A

def first(A, x, y):
  x

type ClosureBox is Type:
  ClosureBox{f: String -> String}

def apply_box(box: ClosureBox) -> String:
  match box:
    case ClosureBox{f}:
      f("discarded")

def main() -> IO(Unit):
  f = {first(String, "kept") : String -> String}
  IO.print(apply_box(ClosureBox{f}))

#|kept
