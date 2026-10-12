import Base

type Choice75 is Data:
  Pick75{value: U32}
  Empty75{}

def choose75(x: Choice75) -> U32:
  match x:
    case Pick75{value}: U32.add(value, 2)
    case Empty75{}: 0

def main() -> U32:
  choose75(Pick75{40})

#|42
