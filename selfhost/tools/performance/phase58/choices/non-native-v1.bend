# No Base: familiar constructor/type names have an ordinary object layout.
type Bool is Data:
  True{}
  False{}

type Unit is Data:
  Unit{}

type Answer is Data:
  Left{}
  Right{}

def switchboard(-A: Type, +b: Bool, yes: Unit -> A, no: Unit -> A) -> A:
  match b:
    case True{}:
      yes(Unit{})
    case False{}:
      no(Unit{})

def witness(+b: Bool) -> Answer:
  switchboard(Answer, b, u => Left{}, u => Right{})
