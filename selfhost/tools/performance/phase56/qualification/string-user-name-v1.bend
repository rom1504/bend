# No Base import: this is an ordinary user definition with a native spelling.
type StringEqVerdict is Type:
  Same{}
  Different{}

def String.eq(a: StringEqVerdict, b: StringEqVerdict) -> StringEqVerdict:
  Different{}

def witness() -> StringEqVerdict:
  String.eq(Same{}, Same{})
