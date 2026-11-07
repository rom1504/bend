# Same already-admitted packet computation inside ordinary supported IO.
def main() -> IO(Unit):
  +original = p173odw_make(6n,17)
  do IO<Unit>:
    Unit <- IO.print("begin")
    Unit <- IO.print(U32.show(p173odw_digest(p173odw_change(original,11))))
    Unit <- IO.print(U32.show(p173odw_digest(original)))
    Unit <- IO.print(U32.show(p173odw_digest(p173odw_change(P173OwnedVacant{71},29))))
    IO.print("end")
