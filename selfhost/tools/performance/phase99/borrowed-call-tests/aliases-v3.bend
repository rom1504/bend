import Base

def p99_equal_walk(a: String, b: String, same: Bool) -> Bool:
  match a b same:
    case SNil{} SNil{} result: result
    case SNil{} SCon{h, t} result: False{}
    case SCon{h, t} SNil{} result: False{}
    case SCon{h1, t1} SCon{h2, t2} False{}: False{}
    case SCon{h1, t1} SCon{h2, t2} True{}:
      p99_equal_walk(t1, t2, Char.is_eq(h1, h2))

def p99_hold(same: Bool, a: String, b: String) -> Bool:
  same

def p99_same_alias(+a: String) -> Bool:
  p99_hold(p99_equal_walk(a, a, True{}), a, a)

def p99_carry(+a: String, +b: String, same: Bool) -> Bool:
  p99_hold(p99_equal_walk(a, b, same), a, b)

def p99_tail_read(+a: String, +b: String) -> Bool:
  match a:
    case SNil{}: p99_hold(p99_equal_walk(SNil{}, b, True{}), a, b)
    case SCon{head, rest}: p99_hold(p99_equal_walk(rest, b, True{}), a, b)

# An escaping child is an owned result, never a scalar borrowed-call result.
def p99_escape(a: String) -> String:
  match a:
    case SNil{}: SNil{}
    case SCon{head, tail}: tail

def main() -> IO(Unit):
  +root : String = "λ🙂tail"
  +tail : String = "🙂tail"
  +escaped : String = p99_escape(root)
  do IO<Unit>:
    IO.print_err("borrowed-call-controls")
    IO.print(U32.show(Bool.to_u32(p99_same_alias(root))))
    IO.print(U32.show(Bool.to_u32(p99_carry(root, root, False{}))))
    IO.print(U32.show(Bool.to_u32(p99_carry(root, root, True{}))))
    IO.print(U32.show(Bool.to_u32(p99_tail_read(root, tail))))
    IO.print(escaped)
    IO.print(root)
    IO.print(tail)

#|1
#|0
#|1
#|1
#|🙂tail
#|λ🙂tail
#|🙂tail
