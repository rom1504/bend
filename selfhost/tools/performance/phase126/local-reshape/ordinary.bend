import Base

type Hedge is Data:
  Tip{label: String}
  Branch{left: Hedge, right: Hedge}

def hedge.cross(left: Hedge, right: Hedge) -> Hedge:
  match left right:
    case Branch{a, b} Branch{c, d}: Branch{Branch{a, c}, Branch{b, d}}
    case Branch{a, b} Tip{label}: Tip{"none"}
    case Tip{label} Branch{c, d}: Tip{"none"}
    case Tip{left} Tip{right}: Tip{"none"}

def hedge.show(value: Hedge) -> String:
  match value:
    case Tip{label}: "[" ++ label ++ "]"
    case Branch{left, right}: "(" ++ hedge.show(left) ++ "|" ++ hedge.show(right) ++ ")"

def hedge.shared(+left: Hedge, +right: Hedge) -> IO(Unit):
  do IO<Unit>:
    Unit <- IO.print(hedge.show(hedge.cross(left, right)))
    Unit <- IO.print(hedge.show(left))
    IO.print(hedge.show(right))

def hedge.same(+value: Hedge) -> IO(Unit):
  do IO<Unit>:
    Unit <- IO.print(hedge.show(hedge.cross(value, value)))
    IO.print(hedge.show(value))

def hedge.payload(+label: String) -> IO(Unit):
  do IO<Unit>:
    Unit <- IO.print(hedge.show(hedge.cross(Branch{Tip{label}, Tip{"b"}}, Branch{Tip{"c"}, Tip{label}})))
    IO.print(label)

def main() -> IO(Unit):
  do IO<Unit>:
    Unit <- IO.print(hedge.show(hedge.cross(Branch{Tip{"a"}, Tip{"b"}}, Branch{Tip{"c"}, Tip{"d"}})))
    Unit <- hedge.shared(Branch{Tip{"left:" ++ U32.show(17)}, Tip{"b"}}, Branch{Tip{"c"}, Tip{"right:" ++ U32.show(31)}})
    Unit <- hedge.same(Branch{Tip{"same:" ++ U32.show(42)}, Tip{"other"}})
    Unit <- hedge.payload("alias:" ++ U32.show(99))
    Unit <- IO.print(hedge.show(hedge.cross(Tip{"unused"}, Branch{Tip{"c"}, Tip{"d"}})))
    IO.print(hedge.show(hedge.cross(Branch{Tip{"a"}, Tip{"b"}}, Tip{"unused"})))
