import Base

# Repeated consuming traversal, Unicode, and a static tail in a dynamic node.
def text69() -> String:
  "Aλ🙂"

def prefix69(c: Char, tail: String) -> String:
  SCon{c, tail}

def main() -> Nat:
  +text = text69()
  +prefixed = prefix69('Z', text)
  Nat.add(String.length(text), String.length(prefixed))

#|7n
