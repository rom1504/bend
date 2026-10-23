import Base

type P131Count is Data:
  P131Zero{}
  P131Once{}
  P131Many{}

type P131Mode is Data:
  P131Sequence{}
  P131Branch{}
  P131Pattern{}

def encode(count: P131Count) -> U32:
  match count:
    case P131Zero{}: 0
    case P131Once{}: 1
    case P131Many{}: 2

def mode(kind: P131Mode) -> U32:
  match kind:
    case P131Sequence{}: 0
    case P131Branch{}: 1
    case P131Pattern{}: 2

# Independent constructor semantics; these do not invoke production arithmetic.
def sequence(a: P131Count, b: P131Count) -> P131Count:
  match a b:
    case P131Zero{} value: value
    case P131Once{} P131Zero{}: P131Once{}
    case P131Once{} P131Once{}: P131Many{}
    case P131Once{} P131Many{}: P131Many{}
    case P131Many{} value: P131Many{}

def minimum(a: P131Count, b: P131Count) -> P131Count:
  match a b:
    case P131Zero{} value: P131Zero{}
    case P131Once{} P131Zero{}: P131Zero{}
    case P131Once{} P131Once{}: P131Once{}
    case P131Once{} P131Many{}: P131Once{}
    case P131Many{} value: value

def maximum(a: P131Count, b: P131Count) -> P131Count:
  match a b:
    case P131Zero{} value: value
    case P131Once{} P131Zero{}: P131Once{}
    case P131Once{} P131Once{}: P131Once{}
    case P131Once{} P131Many{}: P131Many{}
    case P131Many{} value: P131Many{}

def low(kind: P131Mode, a: P131Count, b: P131Count) -> P131Count:
  match kind:
    case P131Sequence{}: sequence(a,b)
    case P131Branch{}: minimum(a,b)
    case P131Pattern{}: P131Zero{}

def high(kind: P131Mode, a: P131Count, b: P131Count) -> P131Count:
  match kind:
    case P131Sequence{}: sequence(a,b)
    case P131Branch{}: maximum(a,b)
    case P131Pattern{}: maximum(a,b)
