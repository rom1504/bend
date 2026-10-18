# Additional generic ownership controls, separate from the frozen reverse witnesses.
import Base

@unsafe
def p109_list_discard(xs: List<&2, String>, acc: List<&2, String>) -> List<&2, String>:
  match xs:
    case Nil{}: acc
    case Con{h, t}: p109_list_discard(t, acc)

@unsafe
def p109_list_duplicate(xs: List<&2, String>, acc: List<&2, String>) -> List<&2, String>:
  match xs:
    case Nil{}: acc
    case Con{+h, t}: p109_list_duplicate(t, Con{h, Con{h, acc}})

def p109_string_discard(xs: String, acc: String) -> String:
  match xs:
    case SNil{}: acc
    case SCon{h, t}: p109_string_discard(t, acc)

def p109_string_duplicate(xs: String, acc: String) -> String:
  match xs:
    case SNil{}: acc
    case SCon{+h, t}: p109_string_duplicate(t, SCon{h, SCon{h, acc}})

@unsafe
def p109_join(xs: List<&2, String>) -> String:
  match xs:
    case Nil{}: ""
    case Con{h, Nil{}}: h
    case Con{h, rest}: h ++ "|" ++ p109_join(rest)

def main() -> IO(Unit):
  do IO<Unit>:
    Unit <- IO.print(p109_join(p109_list_discard(["a", "bc"], ["tail"])))
    Unit <- IO.print(p109_join(p109_list_duplicate(["a", "bc"], ["tail"])))
    Unit <- IO.print(p109_string_discard("a🙂", "!"))
    IO.print(p109_string_duplicate("a🙂", "!"))

#|tail
#|bc|bc|a|a|tail
#|!
#|🙂🙂aa!
