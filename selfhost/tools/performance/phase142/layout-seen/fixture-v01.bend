# Scaling diagnostic, not a source-typechecked user program or corpus benchmark.
# n owned definition bodies each reference the predecessor twice; node zero is
# intentionally missing. Original jl_term determines the actual traversal.
type P142JGFixture is Data:
  P142JGFixture{+defs: List<&2,KDef>, +roots: List<&2,String>, +stops: List<&2,String>, +nodes: U32}

def p142jg_name(n: U32) -> String:
  "p142.layout.node." ++ U32.show(n)

@unsafe
def p142jg_defs(+n: U32, built: List<&2,KDef>) -> List<&2,KDef>:
  match n:
    case 0: built
    case _:
      +next = U32.sub(n,1)
      +target = p142jg_name(next)
      p142jg_defs(next,Con{p142jt_def(p142jg_name(n),"Def",0,False{},p142jt_two(target,target)),built})

def p142jg_fixture(+n: U32) -> P142JGFixture:
  P142JGFixture{p142jg_defs(n,[]),[p142jg_name(n)],[],n}
