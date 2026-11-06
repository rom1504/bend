import Base

# Independent owned tail-SCC transfer workload, not an optimizer-name fixture.
# Positive reference: output must be 200000. Source must remain byte-identical
# between the ordinary and experimental compiler runs.

law p173owned_a:
  for +left: U32
  for values: List<&1,U32>
  U32

law p173owned_b:
  for +left: U32
  for values: List<&1,U32>
  U32

law p173owned_c:
  for +left: U32
  for values: List<&1,U32>
  U32

law p173owned_sum:
  for values: List<&1,U32>
  for +acc: U32
  U32

@unsafe
def p173owned_a(left,values):
  match left:
    case 0: p173owned_sum(values,0)
    case _: p173owned_b(U32.sub(left,1),Con{1,values})

@unsafe
def p173owned_b(left,values):
  match left:
    case 0: p173owned_sum(values,0)
    case _: p173owned_c(U32.sub(left,1),Con{1,values})

@unsafe
def p173owned_c(left,values):
  match left:
    case 0: p173owned_sum(values,0)
    case _: p173owned_a(U32.sub(left,1),Con{1,values})

@unsafe
def p173owned_sum(values,acc):
  match values:
    case Nil{}: acc
    case Con{value,rest}: p173owned_sum(rest,U32.add(acc,value))

def main() -> U32:
  p173owned_a(200000,[])

#| 200000
