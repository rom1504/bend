import Base
type MatcherBit is Data:
  Matcher.On{}
  Matcher.Off{}
def apply(f: MatcherBit -> U32) -> U32:
  f(Matcher.On{})
def main() -> U32:
  apply(\{Matcher.On: 42; Matcher.Off: 0})

#| 42
