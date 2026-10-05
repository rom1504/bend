import Base

law Ghost.request:
  IO(U32)

def Ghost.request():
  import "./dead-foreign-let-v1.js"

law main:
  IO(Unit)

def main():
  unused = Ghost.request()
  IO.print("alive")

#|alive
