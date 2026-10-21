# A finite value does not exist for this single-constructor recursive type.
# Keep its ordinary eliminator in the checked book for an admission query.
import Base

type Knot123 is Data:
  Tie123{next: Knot123}

def unwrap123(value: Knot123) -> Knot123:
  match value:
    case Tie123{next}: next

def main() -> U32:
  17

#|17
