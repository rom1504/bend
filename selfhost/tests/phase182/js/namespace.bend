import Base

type Box is Data:
  Box{+value: Nat}

type Choice is Data:
  Local.Left{+value: Nat}
  Local.Right{+value: Nat}

def make(n: Nat) -> Box:
  Box{n}

def take(b: Box) -> Nat:
  match b:
    case Box{n}: n

def left(n: Nat) -> Choice: Local.Left{n}
def right(n: Nat) -> Choice: Local.Right{n}
