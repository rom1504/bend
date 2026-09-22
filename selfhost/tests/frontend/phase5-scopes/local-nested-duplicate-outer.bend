import Base
type ScopeLeaf is Data:
  ScopeLeaf{first: U32, second: U32}
type ScopeOuter is Data:
  ScopeOuter{inner: ScopeLeaf, final: U32}
def choose(p: ScopeOuter, outer: U32) -> U32:
  ScopeOuter{ScopeLeaf{x, y}, x} = p
  U32.add(x, U32.add(y, outer))
def main() -> U32:
  choose(ScopeOuter{ScopeLeaf{1, 2}, 3}, 4)
#| 9
