import Base
type AdjQualified is Data:
  Adj.Qualified{value: U32}
def main() -> AdjQualified:
  Adj.Qualified {42}
