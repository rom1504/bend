import Base

type NatBox is Data:
  NatBox{number: Nat, text: String}

def unpack(box: NatBox) -> Nat & String:
  match box:
    case NatBox{number,text}: (number,text)

def observe(+number: Nat, +text: String) -> IO(Unit):
  (found,kept) = unpack(NatBox{number,text})
  do IO<Unit>:
    Unit <- IO.print(Nat.show(found))
    Unit <- IO.print(Nat.show(number))
    Unit <- IO.print(kept)
    IO.print(text)

def main() -> IO(Unit):
  observe(Nat.pow(2n,40n),String.reverse("🙂taN"))

#|1099511627776
#|1099511627776
#|Nat🙂
#|Nat🙂
