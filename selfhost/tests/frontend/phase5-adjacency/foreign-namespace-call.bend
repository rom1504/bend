import Base
law Adj.foreign:
  U32 -> IO(U32)
def Adj.foreign(x):
  import "./foreign.js"
def main() -> IO(U32):
  Adj.foreign (42)
