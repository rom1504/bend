import Base

# Generic tail recursion swaps two owning String arguments. The odd iteration
# count and discarded second owner exercise simultaneous moves and cleanup.
@unsafe
def p112_owner_swap(n: U32, a: String, b: String) -> String:
  match n:
    case 0: a
    case _: p112_owner_swap(U32.sub(n, 1), b, a)

def main() -> String:
  p112_owner_swap(100001, String.reverse("😀α"), String.reverse("β"))

#|"β"
