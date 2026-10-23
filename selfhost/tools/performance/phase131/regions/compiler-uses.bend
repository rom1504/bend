import Base

type KTerm is Data:
  KTerm{+tag: String, +name: String, +id: U32, +quant: U32, +kids: List<&2, KTerm>, +removed: List<&2, String>, +originBegin: U32, +originEnd: U32}
  KLambda{+name: String, +id: U32, +quant: U32, +kids: List<&2,KTerm>, +removed: List<&2,String>, +originBegin: U32, +originEnd: U32, +quantityPresent: Bool}
  KLiteral{+kind: String, +number: U32, +text: String, +originBegin: U32, +originEnd: U32}

def p88_string_eq_go(a: String, b: String, same: Bool) -> Bool:
  match a b same:
    case SNil{} SNil{} result: result
    case SNil{} SCon{h, t} result: False{}
    case SCon{h, t} SNil{} result: False{}
    case SCon{h1, t1} SCon{h2, t2} False{}: False{}
    case SCon{h1, t1} SCon{h2, t2} True{}:
      p88_string_eq_go(t1, t2, Char.is_eq(h1, h2))

def p98_eq_finish(same: Bool, left: String, right: String) -> Bool:
  same

def p88_string_eq(+a: String, +b: String) -> Bool:
  p98_eq_finish(p88_string_eq_go(a, b, True{}), a, b)

def p98_tag_eq_read(term: KTerm, key: String) -> Bool:
  match term:
    case KTerm{tag, name, id, quant, kids, removed, begin, end}:
      p88_string_eq_go(tag, key, True{})
    case KLambda{name, id, quant, kids, removed, begin, end, present}:
      p88_string_eq("Lam", key)
    case KLiteral{kind, number, text, begin, end}:
      p88_string_eq("Lit", key)

def p98_tag_eq_finish(same: Bool, term: KTerm, key: String) -> Bool:
  same

def p98_tag_eq(+term: KTerm, +key: String) -> Bool:
  p98_tag_eq_finish(p98_tag_eq_read(term, key), term, key)

@unsafe
def kc(
  -A: Type,
  +b: Bool,
  yes: Unit -> A,
  no: Unit -> A,
) -> A:
  match b:
    case True{}:
      yes(Unit{})
    case False{}:
      no(Unit{})

@unsafe
def kt(
  +tag: String,
  +name: String,
  +id: U32,
  +quant: U32,
  +kids: List<&2, KTerm>,
) -> KTerm:
  KTerm{tag, name, id, quant, kids, Nil{}, 0, 0}

@unsafe
def atom(
  +tag: String,
) -> KTerm:
  kt(tag, "", 0, 0, Nil{})

@unsafe
def ix(
  +t: KTerm,
) -> U32:
  match t:
    case KTerm{tag, name, id, quant, kids, removed, originBegin, originEnd}:
      id
    case KLambda{name, id, quant, kids, removed, begin, end, present}:
      id
    case KLiteral{kind, number, text, literalBegin, literalEnd}:
      0

@unsafe
def ks(
  +t: KTerm,
) -> List<&2, KTerm>:
  match t:
    case KTerm{tag, name, id, quant, kids, removed, originBegin, originEnd}:
      kids
    case KLambda{name, id, quant, kids, removed, begin, end, present}:
      kids
    case KLiteral{kind, number, text, literalBegin, literalEnd}:
      Nil{}

@unsafe
def terms_at(
  +ts: List<&2, KTerm>,
  +n: U32,
) -> KTerm:
  match ts:
    case Nil{}:
      atom("Absent")
    case Con{h, t}:
      kc(KTerm, U32.is_eq(n, 0), u => h, u => terms_at(t, U32.sub(n, 1)))

@unsafe
def kid(
  +t: KTerm,
  +n: U32,
) -> KTerm:
  terms_at(ks(t), n)

@unsafe
def terms_len(
  +ts: List<&2, KTerm>,
) -> U32:
  match ts:
    case Nil{}:
      0
    case Con{h, t}:
      U32.add(1, terms_len(t))

@unsafe
def nt_choose(-A: Type, +b: Bool, yes: Unit -> A, no: Unit -> A) -> A:
  match b:
    case True{}: yes(Unit{})
    case False{}: no(Unit{})

@unsafe
def nt_bool(b: Bool) -> U32:
  match b:
    case True{}: 1
    case False{}: 0

@unsafe
def nq_uses(+t: KTerm, +id: U32) -> U32:
  nt_choose(U32, p98_tag_eq(t, "Var"), u => nt_bool(U32.is_eq(ix(t), id)), u =>
    nt_choose(U32, p98_tag_eq(t, "Mat") && U32.is_eq(terms_len(ks(t)), 2), u => U32.max(nq_uses(kid(t, 0), id), nq_uses(kid(t, 1), id)), u => nt_choose(U32, p98_tag_eq(t, "NWPattern"), v => nw_uses(ks(t), id), v => nq_uses_list(ks(t), id))))

@unsafe
def nq_uses_list(ts: List<&2, KTerm>, +id: U32) -> U32:
  match ts:
    case Nil{}: 0
    case Con{h, rest}: U32.min(2, U32.add(nq_uses(h, id), nq_uses_list(rest, id)))

@unsafe
def nw_uses(rows: List<&2, KTerm>, +id: U32) -> U32:
  match rows:
    case Nil{}: 0
    case Con{row, rest}: U32.max(nq_uses(kid(row, 0), id), nw_uses(rest, id))

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
