import Base

@unsafe
def p112_direct_leaf(a: String, b: String) -> String:
  b

@unsafe
def p112_direct_middle(a: String, b: String) -> String:
  p112_direct_leaf(b, a)

@unsafe
def p112_direct_alias(+text: String) -> String:
  p112_direct_middle(text, text)

def main() -> String:
  p112_direct_alias(String.reverse("😀α"))

#|"α😀"
