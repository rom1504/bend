import Base

# A 2,000-codepoint literal tests the actual compact/static emission path.
# Repeated consuming traversals must preserve immortal graph contents.
def literal69_long() -> String:
  "abC 123 λ🙂abC 123 λ🙂abC 123 λ🙂abC 123 λ🙂abC 123 λ🙂abC 123 λ🙂abC 123 λ🙂abC 123 λ🙂abC 123 λ🙂abC 123 λ🙂abC 123 λ🙂abC 123 λ🙂abC 123 λ🙂abC 123 λ🙂abC 123 λ🙂abC 123 λ🙂abC 123 λ🙂abC 123 λ🙂abC 123 λ🙂abC 123 λ🙂abC 123 λ🙂abC 123 λ🙂abC 123 λ🙂abC 123 λ🙂abC 123 λ🙂abC 123 λ🙂abC 123 λ🙂abC 123 λ🙂abC 123 λ🙂abC 123 λ🙂abC 123 λ🙂abC 123 λ🙂abC 123 λ🙂abC 123 λ🙂abC 123 λ🙂abC 123 λ🙂abC 123 λ🙂abC 123 λ🙂abC 123 λ🙂abC 123 λ🙂abC 123 λ🙂abC 123 λ🙂abC 123 λ🙂abC 123 λ🙂abC 123 λ🙂abC 123 λ🙂abC 123 λ🙂abC 123 λ🙂abC 123 λ🙂abC 123 λ🙂abC 123 λ🙂abC 123 λ🙂abC 123 λ🙂abC 123 λ🙂abC 123 λ🙂abC 123 λ🙂abC 123 λ🙂abC 123 λ🙂abC 123 λ🙂abC 123 λ🙂abC 123 λ🙂abC 123 λ🙂abC 123 λ🙂abC 123 λ🙂abC 123 λ🙂abC 123 λ🙂abC 123 λ🙂abC 123 λ🙂abC 123 λ🙂abC 123 λ🙂abC 123 λ🙂abC 123 λ🙂abC 123 λ🙂abC 123 λ🙂abC 123 λ🙂abC 123 λ🙂abC 123 λ🙂abC 123 λ🙂abC 123 λ🙂abC 123 λ🙂abC 123 λ🙂abC 123 λ🙂abC 123 λ🙂abC 123 λ🙂abC 123 λ🙂abC 123 λ🙂abC 123 λ🙂abC 123 λ🙂abC 123 λ🙂abC 123 λ🙂abC 123 λ🙂abC 123 λ🙂abC 123 λ🙂abC 123 λ🙂abC 123 λ🙂abC 123 λ🙂abC 123 λ🙂abC 123 λ🙂abC 123 λ🙂abC 123 λ🙂abC 123 λ🙂abC 123 λ🙂abC 123 λ🙂abC 123 λ🙂abC 123 λ🙂abC 123 λ🙂abC 123 λ🙂abC 123 λ🙂abC 123 λ🙂abC 123 λ🙂abC 123 λ🙂abC 123 λ🙂abC 123 λ🙂abC 123 λ🙂abC 123 λ🙂abC 123 λ🙂abC 123 λ🙂abC 123 λ🙂abC 123 λ🙂abC 123 λ🙂abC 123 λ🙂abC 123 λ🙂abC 123 λ🙂abC 123 λ🙂abC 123 λ🙂abC 123 λ🙂abC 123 λ🙂abC 123 λ🙂abC 123 λ🙂abC 123 λ🙂abC 123 λ🙂abC 123 λ🙂abC 123 λ🙂abC 123 λ🙂abC 123 λ🙂abC 123 λ🙂abC 123 λ🙂abC 123 λ🙂abC 123 λ🙂abC 123 λ🙂abC 123 λ🙂abC 123 λ🙂abC 123 λ🙂abC 123 λ🙂abC 123 λ🙂abC 123 λ🙂abC 123 λ🙂abC 123 λ🙂abC 123 λ🙂abC 123 λ🙂abC 123 λ🙂abC 123 λ🙂abC 123 λ🙂abC 123 λ🙂abC 123 λ🙂abC 123 λ🙂abC 123 λ🙂abC 123 λ🙂abC 123 λ🙂abC 123 λ🙂abC 123 λ🙂abC 123 λ🙂abC 123 λ🙂abC 123 λ🙂abC 123 λ🙂abC 123 λ🙂abC 123 λ🙂abC 123 λ🙂abC 123 λ🙂abC 123 λ🙂abC 123 λ🙂abC 123 λ🙂abC 123 λ🙂abC 123 λ🙂abC 123 λ🙂abC 123 λ🙂abC 123 λ🙂abC 123 λ🙂abC 123 λ🙂abC 123 λ🙂abC 123 λ🙂abC 123 λ🙂abC 123 λ🙂abC 123 λ🙂abC 123 λ🙂abC 123 λ🙂abC 123 λ🙂abC 123 λ🙂abC 123 λ🙂abC 123 λ🙂abC 123 λ🙂abC 123 λ🙂abC 123 λ🙂abC 123 λ🙂abC 123 λ🙂abC 123 λ🙂abC 123 λ🙂abC 123 λ🙂abC 123 λ🙂abC 123 λ🙂"

def main() -> Nat:
  +text = literal69_long()
  Nat.add(String.length(text), String.length(text))

#|4000n
