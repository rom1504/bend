# Repeatedly execute the unchanged compiler occurrence-count computation.
# The shared tree stays held; its shape is independent of the query identifier.
def p131u_var(id: U32) -> KTerm:
  kt("Var","",id,0,[])

def p131u_tree(depth: Nat) -> KTerm:
  match depth:
    case 0n: p131u_var(7)
    case 1n+rest:
      +child = p131u_tree(rest)
      kt("App","",0,0,[child,child])

def p131u_check() -> IO(Unit):
  +tree = p131u_tree(4n)
  +var = p131u_var(7)
  +lit : KTerm = KLiteral{"String",0,"λ",0,0}
  do IO<Unit>:
    Unit <- IO.print(U32.show(nq_uses(tree,7)))
    Unit <- IO.print(U32.show(nq_uses(tree,8)))
    Unit <- IO.print(U32.show(nq_uses(kt("Mat","",0,0,[var,var]),7)))
    Unit <- IO.print(U32.show(nq_uses(kt("Mat","",0,0,[tree,p131u_var(8)]),7)))
    Unit <- IO.print(U32.show(nq_uses(kt("Mat","",0,0,[var]),7)))
    Unit <- IO.print(U32.show(nq_uses(lit,7)))
    Unit <- IO.print(U32.show(nq_uses(KLambda{"x",0,2,[var,lit],[],0,0,True{}},7)))
    Unit <- IO.print(U32.show(nq_uses(kt("NWPattern","",0,0,[kt("Row","",0,0,[var]),kt("Row","",0,0,[var])]),7)))
    Unit <- IO.print(U32.show(nq_uses(kt("NWPattern","",0,0,[]),7)))
    IO.print(U32.show(nq_uses(kt("NWPattern","",0,0,[atom("Row")]),7)))

def p131u_repeat(left: Nat, +tree: KTerm, sum: U32) -> U32:
  match left:
    case 0n: sum
    case 1n+rest:
      p131u_repeat(rest,tree,U32.add(sum,U32.add(nq_uses(tree,7),nq_uses(tree,8))))

def p131u_timed(repeats: Nat) -> IO(Unit):
  +tree = p131u_tree(7n)
  do IO<Unit>:
    Unit <- IO.print(U32.show(U32.add(nq_uses(tree,7),nq_uses(tree,8))))
    before : Nat <- IO.now()
    Unit <- IO.print(U32.show(p131u_repeat(repeats,tree,0)))
    after : Nat <- IO.now()
    IO.print(Nat.show(Nat.sub(after,before)))

def p131u_select(repeats: Nat) -> IO(Unit):
  match repeats:
    case 0n: p131u_check()
    case 1n+rest: p131u_timed(1n+rest)

def p131u_value(value: Maybe<&2,Nat>, fallback: Nat) -> Nat:
  match value:
    case None{}: fallback
    case Some{number}: number

def p131u_args(args: List<String>, fallback: Nat) -> Nat:
  match args:
    case Nil{}: fallback
    case head <> tail: p131u_args(tail,p131u_value(Nat.read(head),fallback))

def main() -> IO(Unit):
  do IO<Unit>:
    args : List<String> <- IO.args()
    p131u_select(p131u_args(args,0n))
