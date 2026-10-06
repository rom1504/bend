# No Base: legal user datatype names have an ordinary object layout.
type OpaqueBool is Data:
  OpaqueTrue{}
  OpaqueFalse{}

type OpaqueUnit is Data:
  OpaqueUnit{}

type Answer is Data:
  Left{}
  Right{}

def switchboard(-A: Type, +b: OpaqueBool, yes: OpaqueUnit -> A, no: OpaqueUnit -> A) -> A:
  match b:
    case OpaqueTrue{}:
      yes(OpaqueUnit{})
    case OpaqueFalse{}:
      no(OpaqueUnit{})

def witness(+b: OpaqueBool) -> Answer:
  switchboard(Answer, b, u => Left{}, u => Right{})
