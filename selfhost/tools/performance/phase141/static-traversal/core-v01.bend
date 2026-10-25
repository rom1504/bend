# Research candidate: use the existing language's closed template argument.
# No runtime callback parameter; no change to list order or Bool combination.
# Source only: this module has not yet passed a checked build or native gate.
@unsafe
def p141st_list(~A: Data, ~same: A -> A -> Bool, a: List<&2,A>, b: List<&2,A>) -> Bool:
  match a b:
    case Nil{} Nil{}: True{}
    case Con{x,xs} Con{y,ys}: same(x,y) && p141st_list(~A,~same,xs,ys)
    case _ _: False{}

# State stays runtime data. It must not enter the template key or be captured
# by the closed same function. This is an additional transfer control only.
@unsafe
def p141st_state(~A: Data, ~S: Data, ~same: S -> A -> A -> Bool, +state: S, a: List<&2,A>, b: List<&2,A>) -> Bool:
  match a b:
    case Nil{} Nil{}: True{}
    case Con{x,xs} Con{y,ys}: same(state,x,y) && p141st_state(~A,~S,~same,state,xs,ys)
    case _ _: False{}
