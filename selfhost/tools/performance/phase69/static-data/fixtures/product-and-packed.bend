import Base

type Scalar69 is Data:
  Scalar69{value: U32}

type Product69 is Data:
  Product69{left: Scalar69, right: U32}

def packet69() -> Product69:
  Product69{Scalar69{11}, 31}

def consume69(value: Product69) -> U32:
  match value:
    case Product69{left, right}:
      match left:
        case Scalar69{number}: U32.add(U32.mul(number, 100), right)

def main() -> U32:
  consume69(packet69())

#|1131
