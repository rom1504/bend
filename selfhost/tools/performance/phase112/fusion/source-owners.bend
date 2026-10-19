import Base

@unsafe
def p112_fusion_identity(text: String) -> String:
  text

@unsafe
def p112_fusion_choose(a: String, b: String) -> String:
  a

@unsafe
def p112_fusion_shared(+text: String) -> String:
  result = p112_fusion_identity(text)
  p112_fusion_choose(result, text)

def main() -> String:
  p112_fusion_shared(String.reverse("😀α"))

#|"α😀"
