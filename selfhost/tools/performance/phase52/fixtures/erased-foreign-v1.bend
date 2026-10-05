import Base

law Ghost.request:
  IO(U32)

def Ghost.request():
  import "./dead-foreign-let-v1.js"

def ignore(-effect: IO(U32)) -> IO(Unit):
  IO.print("erased")

def main() -> IO(Unit):
  ignore(Ghost.request())

#|erased
