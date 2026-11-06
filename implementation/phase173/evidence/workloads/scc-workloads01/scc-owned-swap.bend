import Base

# Two owned arguments rotate on every tail transfer. Even depth200000 gives
# (100000+11) + 3*(100000+29) = 400098. This catches destructive sequential
# argument assignment; machine/native stack depth must stay bounded.
law p173swap_a:
  for +left: U32
  for xs: List<&1,U32>
  for ys: List<&1,U32>
  U32

law p173swap_b:
  for +left: U32
  for xs: List<&1,U32>
  for ys: List<&1,U32>
  U32

law p173swap_c:
  for +left: U32
  for xs: List<&1,U32>
  for ys: List<&1,U32>
  U32

law p173swap_sum:
  for values: List<&1,U32>
  for +acc: U32
  U32

law p173swap_done:
  for xs: List<&1,U32>
  for ys: List<&1,U32>
  U32

@unsafe
def p173swap_a(left,xs,ys):
  match left:
    case 0: p173swap_done(xs,ys)
    case _: p173swap_b(U32.sub(left,1),ys,Con{1,xs})

@unsafe
def p173swap_b(left,xs,ys):
  match left:
    case 0: p173swap_done(xs,ys)
    case _: p173swap_c(U32.sub(left,1),ys,Con{1,xs})

@unsafe
def p173swap_c(left,xs,ys):
  match left:
    case 0: p173swap_done(xs,ys)
    case _: p173swap_a(U32.sub(left,1),ys,Con{1,xs})

@unsafe
def p173swap_sum(values,acc):
  match values:
    case Nil{}: acc
    case Con{value,rest}: p173swap_sum(rest,U32.add(acc,value))

@unsafe
def p173swap_done(xs,ys):
  U32.add(p173swap_sum(xs,0),U32.mul(3,p173swap_sum(ys,0)))

def main() -> U32:
  p173swap_a(200000,[11],[29])

#| 400098
