import Base

type MixedTrail is Data:
  MixedEnd{+text: String}
  MixedShort{+text: String, +tail: MixedTrail}
  MixedWide{+left: String, +stamp: U32, +right: String, +tail: MixedTrail}

# Final recursive positions alternate between slot1 and slot3. The terminal
# result is an owned constructor containing an already shared String child.
def mixed_build(n: Nat, +left: String, +right: String, wide: Bool) -> MixedTrail:
  match n wide:
    case 0n flag: MixedEnd{left}
    case Succ{+rest} False{}:
      MixedShort{left, mixed_build(rest, right, left, True{})}
    case Succ{+rest} True{}:
      MixedWide{left, U32.from_nat(rest), right, mixed_build(rest, right, left, False{})}

def mixed_text(value: MixedTrail) -> String:
  match value:
    case MixedEnd{text}: "E{" ++ text ++ "}"
    case MixedShort{text, tail}: "S{" ++ text ++ ";" ++ mixed_text(tail) ++ "}"
    case MixedWide{left, stamp, right, tail}:
      "W{" ++ left ++ ";" ++ U32.show(stamp) ++ ";" ++ right ++ ";" ++ mixed_text(tail) ++ "}"

def main() -> IO(Unit):
  +left : String = String.append("λ", "left")
  +right : String = String.append("🙂", "right")
  do IO<Unit>:
    IO.print(mixed_text(mixed_build(0n, left, right, False{})))
    IO.print(mixed_text(mixed_build(1n, left, right, False{})))
    IO.print(mixed_text(mixed_build(1n, left, right, True{})))
    IO.print(mixed_text(mixed_build(5n, left, right, False{})))
    IO.print(mixed_text(mixed_build(6n, left, right, True{})))
    IO.print(left)
    IO.print(right)
