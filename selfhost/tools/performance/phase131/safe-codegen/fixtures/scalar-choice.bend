import Base

# An unrelated text search with a literal-returning selector. The recursion is
# structurally visible in safe source, although its call is deferred by a lambda.
def word_choice(value: U32, tail: Unit -> U32, order: Cmp) -> U32:
  match order:
    case LT{}: tail(Unit{})
    case EQ{}: value
    case GT{}: 4294967295

def nat_choice(value: Nat, tail: Unit -> Nat, order: Cmp) -> Nat:
  match order:
    case LT{}: tail(Unit{})
    case EQ{}: value
    case GT{}: 0n

def text_search(text: String, +wanted: U32) -> U32:
  match text:
    case SNil{}: 0
    case SCon{+c,rest}:
      word_choice(Char.to_u32(c),u => text_search(rest,wanted),U32.cmp(Char.to_u32(c),wanted))

# No literal callback in this wrapper's call: ordinary dynamic fallback remains.
def dynamic(value: U32, tail: Unit -> U32, order: Cmp) -> U32:
  word_choice(value,tail,order)

def shared(+text: String) -> IO(Unit):
  do IO<Unit>:
    Unit <- IO.print(U32.show(word_choice(7,u => text_search(text,99),LT{})))
    IO.print(text)

def main() -> IO(Unit):
  do IO<Unit>:
    Unit <- IO.print(U32.show(word_choice(7,u => 9,LT{})))
    Unit <- IO.print(U32.show(word_choice(7,u => 9,EQ{})))
    Unit <- IO.print(U32.show(word_choice(7,u => 9,GT{})))
    Unit <- IO.print(Nat.show(nat_choice(5n,u => 8n,GT{})))
    Unit <- IO.print(U32.show(dynamic(7,u => 11,LT{})))
    Unit <- IO.print(U32.show(text_search("abcdef",100)))
    shared("abcdef")

#|9
#|7
#|4294967295
#|0
#|11
#|100
#|99
#|abcdef
