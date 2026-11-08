import Base

def main() -> IO(Unit):
  do IO<Unit>:
    IO.print("before")
    IO.exit(255)
    IO.print("unreachable")

#|before
#|exit 255
