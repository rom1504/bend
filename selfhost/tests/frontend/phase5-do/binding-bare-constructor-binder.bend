import Base

def M.bind(-A: Type, -R: Type, v: U32, k: U32 -> U32) -> U32:
  k(v)

def M.pure(-R: Type, v: U32) -> U32:
  v

def main() -> U32:
  do M<U32>:
    False : U32 <- 4
    return 4
