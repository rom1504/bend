import Base

# Names and representations are user-defined: the rule must be structural.
type Trail is Data:
  Stop{}
  Step{+code: U32, +rest: Trail}

def user_join(xs: String, +tail: String) -> String:
  match xs:
    case SNil{}: tail
    case SCon{head, rest}: SCon{head, user_join(rest, tail)}

def map_codes(xs: String) -> Trail:
  match xs:
    case SNil{}: Stop{}
    case SCon{head, rest}: Step{U32.inc(Char.to_u32(head)), map_codes(rest)}

def trail_sum(xs: Trail, acc: U32) -> U32:
  match xs:
    case Stop{}: acc
    case Step{head, rest}: trail_sum(rest, U32.add(acc, head))

def repeat_a(n: Nat) -> String:
  match n:
    case 0n: ""
    case 1n+rest: SCon{Char.from_u32(97), repeat_a(rest)}

def checksum(xs: String, acc: U32) -> U32:
  match xs:
    case SNil{}: acc
    case SCon{head, rest}: checksum(rest, U32.add(acc, Char.to_u32(head)))

def main() -> IO(Unit):
  +prefix = "ab"
  +suffix = "cd"
  +long = repeat_a(30000n)
  +joined = user_join(prefix, suffix)
  do IO<Unit>:
    Unit <- IO.print(joined)
    Unit <- IO.print(prefix)
    Unit <- IO.print(suffix)
    Unit <- IO.print(user_join("", suffix))
    Unit <- IO.print(user_join(prefix, ""))
    Unit <- IO.print(U32.show(trail_sum(map_codes(joined), 0)))
    Unit <- IO.print(U32.show(checksum(user_join(long, suffix), 0)))
    IO.print(U32.show(checksum(long, 0)))

#|abcd
#|ab
#|cd
#|cd
#|ab
#|398
#|2910199
#|2910000
