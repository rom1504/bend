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

# Three real AST layouts; all roots stay owned across every observation.
def p99_tag_repeat(left: Nat, +generic: KTerm, +lambda: KTerm, +literal: KTerm, total: U32) -> U32:
  match left:
    case 0n: total
    case 1n+rest:
      +a = Bool.to_u32(p98_tag_eq(generic, "Var"))
      +b = Bool.to_u32(p98_tag_eq(lambda, "Lam"))
      +c = Bool.to_u32(p98_tag_eq(literal, "Lit"))
      p99_tag_repeat(rest, generic, lambda, literal, U32.add(total, U32.add(a, U32.add(b, c))))

# Print every stored field, including child and removed-name aliases.
def p99_literal_dump(term: KTerm) -> IO(Unit):
  match term:
    case KTerm{tag, name, id, quant, kids, removed, begin, end}: IO.print("unexpected generic child")
    case KLambda{name, id, quant, kids, removed, begin, end, present}: IO.print("unexpected lambda child")
    case KLiteral{kind, number, text, begin, end}:
      do IO<Unit>:
        IO.print(kind)
        IO.print(U32.show(number))
        IO.print(text)
        IO.print(U32.show(begin))
        IO.print(U32.show(end))

def p99_kids_dump(kids: List<&2, KTerm>) -> IO(Unit):
  match kids:
    case Nil{}: IO.print("kids-end")
    case Con{head, tail}:
      do IO<Unit>:
        p99_literal_dump(head)
        p99_kids_dump(tail)

def p99_removed_dump(names: List<&2, String>) -> IO(Unit):
  match names:
    case Nil{}: IO.print("removed-end")
    case Con{head, tail}:
      do IO<Unit>:
        IO.print(head)
        p99_removed_dump(tail)

def p99_root_dump(term: KTerm) -> IO(Unit):
  match term:
    case KTerm{tag, name, id, quant, kids, removed, begin, end}:
      do IO<Unit>:
        IO.print(tag)
        IO.print(name)
        IO.print(U32.show(id))
        IO.print(U32.show(quant))
        p99_kids_dump(kids)
        p99_removed_dump(removed)
        IO.print(U32.show(begin))
        IO.print(U32.show(end))
    case KLambda{name, id, quant, kids, removed, begin, end, present}:
      do IO<Unit>:
        IO.print("Lam")
        IO.print(name)
        IO.print(U32.show(id))
        IO.print(U32.show(quant))
        p99_kids_dump(kids)
        p99_removed_dump(removed)
        IO.print(U32.show(begin))
        IO.print(U32.show(end))
        IO.print(U32.show(Bool.to_u32(present)))
    case KLiteral{kind, number, text, begin, end}:
      p99_literal_dump(KLiteral{kind, number, text, begin, end})

def p99_tag_inputs(args: List<&1, String>) -> IO(Unit):
  match args:
    case Nil{}: IO.print("missing input")
    case Con{tag, Nil{}}: IO.print("missing second input")
    case Con{+tag, Con{+name, rest}}:
      +child : KTerm = KLiteral{"U32", 71, name, 4, 9}
      +kids : List<&2, KTerm> = [child]
      +removed : List<&2, String> = [name]
      +generic : KTerm = KTerm{tag, name, 17, 2, kids, removed, 11, 29}
      +lambda : KTerm = KLambda{name, 23, 1, kids, removed, 31, 47, True{}}
      +literal : KTerm = KLiteral{"Str", 37, name, 53, 79}
      do IO<Unit>:
        IO.print(U32.show(p99_tag_repeat(1000000n, generic, lambda, literal, 0)))
        p99_root_dump(generic)
        p99_root_dump(lambda)
        p99_root_dump(literal)
        p99_literal_dump(child)
        IO.print(tag)
        IO.print(name)

def main() -> IO(Unit):
  do IO<Unit>:
    args : List<&1, String> <- IO.args()
    p99_tag_inputs(args)
