import Base

type Row is Data:
  Row{left: String, right: String, score: U32, limit: U32}

# The predicate and conditional reconstruction are deliberately after recursion.
# Two owned fields and two independent scalars must survive that call in order.
def resume(+left: String, right: String, score: U32, limit: U32, rest: List<&2, String>) -> List<&2, String>:
  keep = U32.is_gt(score, limit)
  match keep:
    case True{}: Con{left, Con{right, Con{left, rest}}}
    case False{}: Con{right, rest}

def transform(items: List<&2, Row>) -> List<&2, String>:
  match items:
    case Nil{}: []
    case Con{item, tail}:
      match item:
        case Row{left, right, score, limit}:
          rest = transform(tail)
          resume(left, right, score, limit, rest)

def join(items: List<&2, String>) -> String:
  match items:
    case Nil{}: ""
    case Con{head, tail}: head ++ "|" ++ join(tail)

def describe(items: List<&2, Row>) -> String:
  match items:
    case Nil{}: ""
    case Con{item, tail}:
      match item:
        case Row{left, right, score, limit}:
          left ++ "/" ++ right ++ ":" ++ U32.show(score) ++ ">" ++ U32.show(limit) ++ ";" ++ describe(tail)

def shared(+left: String, +right: String) -> IO(Unit):
  +items : List<&2, Row> = [Row{left, right, 3, 1}, Row{right, left, 1, 2}, Row{"end", "tail", 0, 0}]
  do IO<Unit>:
    Unit <- IO.print(join(transform(items)))
    Unit <- IO.print(left)
    Unit <- IO.print(right)
    Unit <- IO.print(join(transform(items)))
    IO.print(describe(items))

def main() -> IO(Unit):
  do IO<Unit>:
    Unit <- IO.print(join(transform([])))
    Unit <- IO.print(join(transform([Row{"A", "B", 4294967295, 0}])))
    Unit <- IO.print(join(transform([Row{"X", "Y", 0, 4294967295}])))
    shared(String.reverse("α"), String.reverse("🙂β"))

#|
#|A|B|A|
#|Y|
#|α|β🙂|α|α|tail|
#|α
#|β🙂
#|α|β🙂|α|α|tail|
#|α/β🙂:3>1;β🙂/α:1>2;end/tail:0>0;
