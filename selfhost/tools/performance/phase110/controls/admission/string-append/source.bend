# Calls the actual Base implementation; no copied String.append algorithm.
import Base

def main() -> IO(Unit):
  IO.print(String.append("aλ", "🙂z"))

#|aλ🙂z
