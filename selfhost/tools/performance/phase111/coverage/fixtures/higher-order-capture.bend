import Base

def apply(f: U32 -> String, x: U32) -> String:
  f(x)

def capture(prefix: String) -> (U32 -> String):
  x => prefix ++ U32.show(x)

def main() -> IO(Unit):
  IO.print(apply(capture("captured="), 42))

#|captured=42
