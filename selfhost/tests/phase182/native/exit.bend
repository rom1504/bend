import Base

def main() -> IO(Unit):
  do IO<Unit>:
    IO.print("before")
    IO.exit(23)
    IO.print("unreachable")

#|before
#|exit 23
