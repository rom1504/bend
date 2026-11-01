# The nt_reverse declaration below is copied byte-for-byte from compiler source.
# coverage/manifest.json binds its source and declaration digest.
import Base

@unsafe
def nt_reverse(-A: Data, xs: List<&2, A>, acc: List<&2, A>) -> List<&2, A>:
  match xs:
    case Nil{}: acc
    case Con{h, t}: nt_reverse(A, t, Con{h, acc})

@unsafe
def p108_join(xs: List<&2,String>) -> String:
  match xs:
    case Nil{}: ""
    case Con{h, Nil{}}: h
    case Con{h, rest}: h ++ "|" ++ p108_join(rest)

@unsafe
def p108_alias(+tail: List<&2,String>, +head: String) -> String:
  p108_join(nt_reverse(String, Con{head, tail}, Nil{})) ++ "/" ++ p108_join(tail) ++ "/" ++ head

def main() -> IO(Unit):
  do IO<Unit>:
    Unit <- IO.print(p108_join(nt_reverse(String, Nil{}, ["z"])))
    Unit <- IO.print(p108_join(nt_reverse(String, ["a", "bc", ""], ["tail"])))
    Unit <- IO.print(p108_alias(nt_reverse(String, ["c", "b"], Nil{}), String.reverse("daeh")))
    IO.print(p108_join(nt_reverse(String, [String.reverse("ba"), String.reverse("dc")], Nil{})))

#|z
#||bc|a|tail
#|c|b|head/b|c/head
#|cd|ab
