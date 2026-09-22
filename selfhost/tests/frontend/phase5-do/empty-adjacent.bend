import Base

def M.bind(-A: Type, v: U32, k: U32 -> U32) -> U32:
  k(v)

def M.pure(v: U32) -> U32:
  v

def main() -> U32:
  do M<>:
    x : U32 <- 4
    return x
