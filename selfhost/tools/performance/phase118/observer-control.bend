import Base

# User-defined root-preserving observer: names play no part in admission.
def inspect_chain(xs: String, n: U32) -> String & U32:
  match xs:
    case SNil{}: ("", n)
    case SCon{head, rest}:
      (tail, count) = inspect_chain(rest, U32.inc(n))
      (SCon{head, tail}, count)

def print_inspection(pair: String & U32) -> IO(Unit):
  (text, count) = pair
  do IO<Unit>:
    IO.print(text)
    IO.print(U32.show(count))

def cmp_text(order: Cmp) -> String:
  match order:
    case LT{}: "lt"
    case EQ{}: "eq"
    case GT{}: "gt"

def print_comparison(pair: (String & String) & Cmp) -> IO(Unit):
  ((left, right), order) = pair
  do IO<Unit>:
    IO.print(left)
    IO.print(right)
    IO.print(cmp_text(order))

def main() -> IO(Unit):
  +word : String = String.append("λ", "abc🙂")
  do IO<Unit>:
    print_inspection(inspect_chain("", 17))
    print_inspection(inspect_chain(word, 3))
    IO.print(word)
    print_inspection(inspect_chain(word, 0))
    print_comparison(String.cmp(word, word))
    print_comparison(String.cmp("abc", "abd"))
    print_comparison(String.cmp("abcd", "abc"))
    IO.print(word)

#|
#|17
#|λabc🙂
#|8
#|λabc🙂
#|λabc🙂
#|5
#|λabc🙂
#|λabc🙂
#|eq
#|abc
#|abd
#|lt
#|abcd
#|abc
#|gt
#|λabc🙂
