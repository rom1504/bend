import Base

# Extraction consumes the chosen String and drops its owning tail.
def first(text: String) -> U32:
  match text:
    case SNil{}: 0
    case SCon{head, tail}: Char.to_u32(head)

# Both branches return one scalar; false also drops the unused entire left
# String. The true branch distinguishes argument order with a weighted sum.
def target(choose: Bool, left: String, right: String) -> U32:
  match choose:
    case True{}: U32.add(U32.mul(first(left), 1000), first(right))
    case False{}: first(right)

def capture(limit: U32) -> (U32 -> Bool):
  value => U32.is_gt(value, limit)

# The dynamic application keeps left/right live before the known terminal call.
def caller(f: U32 -> Bool, left: String, right: String, value: U32) -> U32:
  choice = f(value)
  target(choice, left, right)

def shared(+left: String, +right: String) -> IO(Unit):
  do IO<Unit>:
    Unit <- IO.print(U32.show(caller(capture(7), left, right, 8)))
    Unit <- IO.print(left)
    Unit <- IO.print(U32.show(caller(capture(7), left, right, 7)))
    Unit <- IO.print(right)
    Unit <- IO.print(U32.show(caller(capture(7), right, left, 8)))
    Unit <- IO.print(U32.show(caller(capture(7), right, left, 7)))
    IO.print(left ++ ":" ++ right)

def main() -> IO(Unit):
  do IO<Unit>:
    Unit <- IO.print(U32.show(caller(capture(0), "discard", "", 0)))
    Unit <- IO.print(U32.show(caller(capture(0), "", "Z", 1)))
    shared(String.reverse("tfelA"), String.reverse("thgirβ"))

#|0
#|90
#|65946
#|Aleft
#|946
#|βright
#|946065
#|65
#|Aleft:βright
