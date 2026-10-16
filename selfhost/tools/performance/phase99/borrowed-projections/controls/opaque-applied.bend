import Base

type P99Opaque is Data:
  P99Opaque{+names: List<&2, String>, +counts: List<&2, U32>, +stamp: U32}

# Ignoring opaque applied fields while reading a scalar remains admissible.
def p99_opaque_stamp(box: P99Opaque) -> U32:
  match box:
    case P99Opaque{names, counts, stamp}: stamp

# The List<String> field has no borrowed matcher authority.
def p99_opaque_read(box: P99Opaque) -> Bool:
  match box:
    case P99Opaque{names, counts, stamp}:
      match names:
        case Nil{}: True{}
        case Con{head, tail}: String.is_empty(head)

# The two applied List instantiations cannot share a nominal permission.
def p99_opaque_count(box: P99Opaque) -> U32:
  match box:
    case P99Opaque{names, counts, stamp}:
      match counts:
        case Nil{}: 0
        case Con{head, tail}: head

def p99_opaque_escape(box: P99Opaque) -> List<&2, String>:
  match box:
    case P99Opaque{names, counts, stamp}: names

def p99_names_dump(names: List<&2, String>) -> IO(Unit):
  match names:
    case Nil{}: IO.print("names-end")
    case Con{head, tail}:
      do IO<Unit>:
        IO.print(head)
        p99_names_dump(tail)

def p99_counts_dump(counts: List<&2, U32>) -> IO(Unit):
  match counts:
    case Nil{}: IO.print("counts-end")
    case Con{head, tail}:
      do IO<Unit>:
        IO.print(U32.show(head))
        p99_counts_dump(tail)

def p99_opaque_dump(box: P99Opaque) -> IO(Unit):
  match box:
    case P99Opaque{names, counts, stamp}:
      do IO<Unit>:
        p99_names_dump(names)
        p99_counts_dump(counts)
        IO.print(U32.show(stamp))

def main() -> IO(Unit):
  +names : List<&2, String> = [String.append("payload", "λ🙂"), "second"]
  +counts : List<&2, U32> = [61, 67]
  +box : P99Opaque = P99Opaque{names, counts, 73}
  +escaped : List<&2, String> = p99_opaque_escape(P99Opaque{names, counts, 79})
  do IO<Unit>:
    IO.print(U32.show(p99_opaque_stamp(box)))
    IO.print(U32.show(Bool.to_u32(p99_opaque_read(box))))
    IO.print(U32.show(p99_opaque_count(box)))
    p99_names_dump(escaped)
    p99_opaque_dump(box)
    p99_names_dump(names)
    p99_counts_dump(counts)
