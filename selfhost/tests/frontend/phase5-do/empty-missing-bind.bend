import Base

type Box is Data:
  Mk{v: U32}

def main() -> Box:
  do Box<>:
    x : U32 <- Mk{3}
    return x
