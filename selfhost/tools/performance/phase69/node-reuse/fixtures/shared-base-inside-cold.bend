import Base

type Envelope is Data:
  Wrap{text: String}

def size(e: Envelope) -> Nat:
  match e:
    case Wrap{s}: String.length(s)

def main() -> Nat:
  +s = String.append("abc", "defg")
  Nat.add(size(Wrap{s}), size(Wrap{s}))

#|14n
