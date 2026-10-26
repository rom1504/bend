# Independent ordinary values: no reflected heap graphs or unchecked native IR.
import Base

def p144_append_make(n: Nat, +char: Char, tail: String) -> String:
  match n:
    case 0n: tail
    case 1n+p: p144_append_make(p,char,SCon{char,tail})

def p144_append_shared(+left: String, +right: String) -> IO(Unit):
  do IO<Unit>:
    Unit <- IO.print(String.append(left,right))
    Unit <- IO.print(left)
    IO.print(right)

def p144_append_overlap(+tail: String) -> IO(Unit):
  do IO<Unit>:
    Unit <- IO.print(String.append(SCon{Chr{65},tail},tail))
    IO.print(tail)

def main() -> IO(Unit):
  do IO<Unit>:
    Unit <- IO.print(String.append(p144_append_make(16n,Chr{120},SNil{}),"!"))
    Unit <- p144_append_shared(p144_append_make(3n,Chr{97},SNil{}),"z")
    Unit <- p144_append_overlap(p144_append_make(3n,Chr{98},SNil{}))
    Unit <- IO.print(String.append("static:","é🙂"))
    Unit <- IO.print(String.append(SNil{},"right"))
    Unit <- IO.print(String.append("left",SNil{}))
    Unit <- IO.print(String.append(SNil{},SNil{}))
    IO.print(Nat.show(String.length(String.append(p144_append_make(4096n,Chr{113},SNil{}),"!!"))))
