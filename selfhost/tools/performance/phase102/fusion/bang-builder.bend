import Base

# A bang-reachable constructor builder must keep the scheduler/device-capable
# path. This is a safe ordinary definition; only the main call requests a bang.
def bang_builder(n: Nat) -> String:
  match n:
    case 0n: ""
    case 1n+rest: SCon{Char.from_u32(103), bang_builder(rest)}

def main() -> IO(Unit):
  text = bang_builder!(32n)
  IO.print(text)

#|gggggggggggggggggggggggggggggggg
