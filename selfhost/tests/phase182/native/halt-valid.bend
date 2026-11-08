import Base

def main() -> IO(Unit):
  do IO<Unit>:
    IO.print("before")
    IO.die(Unit,7,"reported")
    IO.print("unreachable")

#|before
#|reported
#|exit 7
