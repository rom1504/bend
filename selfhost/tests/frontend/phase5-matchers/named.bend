import Base
type MatcherBit is Data:
  MatcherOn{}
  MatcherOff{}
def apply(f: MatcherBit -> U32) -> U32:
  f(MatcherOn{})
def main() -> U32:
  apply(\{MatcherOn: 42; MatcherOff: 0})

#| 42
