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

# Three live fields exercise slot2, swapped recursive arguments, and aliases.
type WideTrail is Data:
  WideEnd{+text: String}
  WideStep{+first: String, +second: String, +rest: WideTrail}

def swap_build(n: Nat, +left: String, +right: String) -> WideTrail:
  match n:
    case 0n: WideEnd{user_join(left, right)}
    case 1n+rest: WideStep{left, right, swap_build(rest, right, left)}

def duplicate_build(n: Nat, +word: String) -> WideTrail:
  match n:
    case 0n: WideEnd{word}
    case 1n+rest: WideStep{word, word, duplicate_build(rest, word)}

def wide_text(xs: WideTrail) -> String:
  match xs:
    case WideEnd{text}: text
    case WideStep{first, second, rest}: first ++ "/" ++ second ++ ";" ++ wide_text(rest)

def main() -> IO(Unit):
  +prefix : String = "ab"
  +suffix : String = "cd"
  +long : String = repeat_a(30000n)
  +joined : String = user_join(prefix, suffix)
  do IO<Unit>:
    Unit <- IO.print(joined)
    Unit <- IO.print(prefix)
    Unit <- IO.print(suffix)
    Unit <- IO.print(user_join("", suffix))
    Unit <- IO.print(user_join(prefix, ""))
    Unit <- IO.print(U32.show(trail_sum(map_codes(joined), 0)))
    Unit <- IO.print(U32.show(checksum(user_join(long, suffix), 0)))
    Unit <- IO.print(U32.show(checksum(long, 0)))
    Unit <- IO.print(user_join(joined, joined))
    Unit <- IO.print(wide_text(swap_build(3n, joined, suffix)))
    Unit <- IO.print(wide_text(duplicate_build(2n, joined)))
    Unit <- IO.print(joined)
    IO.print(suffix)

#|abcd
#|ab
#|cd
#|cd
#|ab
#|398
#|2910199
#|2910000
#|abcdabcd
#|abcd/cd;cd/abcd;abcd/cd;cdabcd
#|abcd/abcd;abcd/abcd;abcd
#|abcd
#|cd
