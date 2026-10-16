import Base

def p99_reverse_finish(same: Bool, left: String, right: String) -> Bool:
  same

def p99_reverse_walk(left: String, right: String, same: Bool) -> Bool:
  match left right same:
    case SNil{} SNil{} result: result
    case SNil{} SCon{h, t} result: False{}
    case SCon{h, t} SNil{} result: False{}
    case SCon{h1, t1} SCon{h2, t2} False{}: False{}
    case SCon{h1, t1} SCon{h2, t2} True{}:
      p99_reverse_walk(t1, t2, Char.is_eq(h1, h2))

# Filled definitions precede their callers, as required by upstream checking.
def p99_reverse_eq(+left: String, +right: String) -> Bool:
  p99_reverse_finish(p99_reverse_walk(left, right, True{}), left, right)

# Both newly constructed String values have one source-level owner here.
def p99_unique_entry(left: String, right: String) -> Bool:
  p99_reverse_eq(left, right)

def main() -> IO(Unit):
  +left : String = String.append("λ", "🙂")
  +right : String = String.append("λ", "🙂")
  do IO<Unit>:
    IO.print(U32.show(Bool.to_u32(p99_unique_entry(String.append("λ", "🙂"), String.append("λ", "🙂")))))
    IO.print(U32.show(Bool.to_u32(p99_reverse_eq(left, right))))
    IO.print(left)
    IO.print(right)

#|1
#|1
#|λ🙂
#|λ🙂
