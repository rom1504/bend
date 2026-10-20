import Base

type NatBox is Data:
  NatBox{number: Nat, text: String}

def unpack(box: NatBox) -> Nat & String:
  match box:
    case NatBox{number,text}: (number,text)

def observe_pair(number: Nat, text: String, pair: Nat & String) -> IO(Unit):
  (found,kept) = pair
  do IO<Unit>:
    Unit <- IO.print(Nat.show(found))
    Unit <- IO.print(Nat.show(number))
    Unit <- IO.print(kept)
    IO.print(text)

def observe(+number: Nat, +text: String) -> IO(Unit):
  observe_pair(number,text,unpack(NatBox{number,text}))

def main() -> IO(Unit):
  observe(Nat.pow(2n,40n),String.reverse("🙂taN"))

#|1099511627776
#|1099511627776
#|Nat🙂
#|Nat🙂
