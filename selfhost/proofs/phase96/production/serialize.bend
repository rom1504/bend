# Test-only observers. Strings are complete arrays of Unicode scalar values.
# These observers match constructors directly, independently of the projections.
@unsafe
def p96.bool(b: Bool) -> String:
  match b:
    case True{}: "true"
    case False{}: "false"

@unsafe
def p96.chars(s: String) -> String:
  match s:
    case SNil{}: ""
    case SCon{h, SNil{}}: U32.show(Char.to_u32(h))
    case SCon{h, SCon{c, rest}}:
      U32.show(Char.to_u32(h)) ++ "," ++ p96.chars(SCon{c, rest})

@unsafe
def p96.string(s: String) -> String:
  "[" ++ p96.chars(s) ++ "]"

@unsafe
def p96.strings_body(xs: List<&2,String>) -> String:
  match xs:
    case Nil{}: ""
    case Con{h, Nil{}}: p96.string(h)
    case Con{h, Con{x, rest}}: p96.string(h) ++ "," ++ p96.strings_body(Con{x, rest})

@unsafe
def p96.strings(xs: List<&2,String>) -> String:
  "[" ++ p96.strings_body(xs) ++ "]"

law p96.term:
  for t: KTerm
  String

@unsafe
def p96.terms_body(xs: List<&2,KTerm>) -> String:
  match xs:
    case Nil{}: ""
    case Con{h, Nil{}}: p96.term(h)
    case Con{h, Con{x, rest}}: p96.term(h) ++ "," ++ p96.terms_body(Con{x, rest})

@unsafe
def p96.terms(xs: List<&2,KTerm>) -> String:
  "[" ++ p96.terms_body(xs) ++ "]"

@unsafe
def p96.term(t):
  match t:
    case KTerm{tag, name, id, quant, kids, removed, begin, end}:
      "[0," ++ p96.string(tag) ++ "," ++ p96.string(name) ++ "," ++ U32.show(id) ++ "," ++ U32.show(quant) ++ "," ++ p96.terms(kids) ++ "," ++ p96.strings(removed) ++ "," ++ U32.show(begin) ++ "," ++ U32.show(end) ++ "]"
    case KLambda{name, id, quant, kids, removed, begin, end, present}:
      "[1," ++ p96.string(name) ++ "," ++ U32.show(id) ++ "," ++ U32.show(quant) ++ "," ++ p96.terms(kids) ++ "," ++ p96.strings(removed) ++ "," ++ U32.show(begin) ++ "," ++ U32.show(end) ++ "," ++ p96.bool(present) ++ "]"
    case KLiteral{kind, number, text, begin, end}:
      "[2," ++ p96.string(kind) ++ "," ++ U32.show(number) ++ "," ++ p96.string(text) ++ "," ++ U32.show(begin) ++ "," ++ U32.show(end) ++ "]"

law p96.def:
  for d: KDef
  String

@unsafe
def p96.defs_body(ds: List<&2,KDef>) -> String:
  match ds:
    case Nil{}: ""
    case Con{h, Nil{}}: p96.def(h)
    case Con{h, Con{x, rest}}: p96.def(h) ++ "," ++ p96.defs_body(Con{x, rest})

@unsafe
def p96.defs(ds: List<&2,KDef>) -> String:
  "[" ++ p96.defs_body(ds) ++ "]"

@unsafe
def p96.def(d):
  match d:
    case KDef{name, kind, arity, templates, typ, value, ctors, native, unsafe}:
      "[0," ++ p96.string(name) ++ "," ++ p96.string(kind) ++ "," ++ U32.show(arity) ++ "," ++ U32.show(templates) ++ "," ++ p96.term(typ) ++ "," ++ p96.term(value) ++ "," ++ p96.defs(ctors) ++ "," ++ p96.bool(native) ++ "," ++ p96.bool(unsafe) ++ "]"
    case KIndexLeaf{hash, bucket}:
      "[1," ++ U32.show(hash) ++ "," ++ p96.defs(bucket) ++ "]"
    case KIndexNode{hash, mask, left, right}:
      "[2," ++ U32.show(hash) ++ "," ++ U32.show(mask) ++ "," ++ p96.def(left) ++ "," ++ p96.def(right) ++ "]"

@unsafe
def p96.kind(k: N_WordKind) -> String:
  match k:
    case N_W32{}: "0"
    case N_W64{}: "1"
    case N_Box{}: "2"

@unsafe
def p96.binding(b: NC_Binding) -> String:
  match b:
    case NC_Binding{id, word, kind}:
      "[" ++ U32.show(id) ++ "," ++ p96.string(word) ++ "," ++ p96.kind(kind) ++ "]"

@unsafe
def p96.env_body(xs: List<&2,NC_Binding>) -> String:
  match xs:
    case Nil{}: ""
    case Con{h, Nil{}}: p96.binding(h)
    case Con{h, Con{x, rest}}: p96.binding(h) ++ "," ++ p96.env_body(Con{x, rest})

@unsafe
def p96.env(xs: List<&2,NC_Binding>) -> String:
  "[" ++ p96.env_body(xs) ++ "]"

@unsafe
def p96.partition(p: NC_EnvPartition) -> String:
  match p:
    case NC_EnvPartition{live, drop}:
      "[" ++ p96.env(live) ++ "," ++ p96.string(drop) ++ "]"

@unsafe
def p96.set(s: NU_Set) -> String:
  match s:
    case NU_Empty{}: "[0]"
    case NU_Leaf{key}: "[1," ++ U32.show(key) ++ "]"
    case NU_Node{mask, left, right}:
      "[2," ++ U32.show(mask) ++ "," ++ p96.set(left) ++ "," ++ p96.set(right) ++ "]"

# Test inputs cross the production book-final fast-path boundary without a
# giant source literal. Full payloads distinguish repeated definition names.
@unsafe
def p96.event(+i: U32) -> KDef:
  KDef{"event" ++ U32.show(U32.mod(i, 7)), "Def", 0, 0,
    KTerm{"ADT", "Nat", 0, 0, Nil{}, Nil{}, 0, 0},
    KLiteral{"Nat", i, "", i, U32.inc(i)}, Nil{}, False{}, False{}}

@unsafe
def p96.events(n: Nat, +i: U32) -> List<&2,KDef>:
  match n:
    case 0n: Nil{}
    case 1n+p: Con{p96.event(i), p96.events(p, U32.inc(i))}

@unsafe
def p96.cache_events(book: List<&2,KDef>) -> List<&2,KDef>:
  match book:
    case Nil{}: Nil{}
    case Con{cache, events}: events
