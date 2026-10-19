import Base

# Both inputs are consumed owners. The unselected input must be dropped.
def select_owner(value: U32, left: String, right: String) -> String:
  match value:
    case 17: left
    case _: right

# Aliases survive the selector; selected is observed again after both aliases.
def observe(value: U32, +left: String, +right: String) -> IO(Unit):
  +selected = select_owner(value, left, right)
  do IO<Unit>:
    Unit <- IO.print(selected)
    Unit <- IO.print(left)
    Unit <- IO.print(right)
    IO.print(selected)

def main() -> IO(Unit):
  do IO<Unit>:
    Unit <- observe(17, String.reverse("λtfel"), String.reverse("🙂thgir"))
    observe(18, String.reverse("λtfel"), String.reverse("🙂thgir"))

#|leftλ
#|leftλ
#|right🙂
#|leftλ
#|right🙂
#|leftλ
#|right🙂
#|right🙂
