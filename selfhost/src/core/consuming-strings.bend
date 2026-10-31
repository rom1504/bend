
# Phase88 native-host-only consuming string helpers.
# Consuming compiler-host helpers. No reconstructed input pair or host closure.
# Deliberately safe: checked ownership must suffice without @unsafe.
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

def p88_string_order_go(a: String, b: String, order: Cmp) -> Cmp:
  match a b order:
    case SNil{} SNil{} result: result
    case SNil{} SCon{h, t} LT{}: LT{}
    case SNil{} SCon{h, t} EQ{}: LT{}
    case SNil{} SCon{h, t} GT{}: GT{}
    case SCon{h, t} SNil{} LT{}: LT{}
    case SCon{h, t} SNil{} EQ{}: GT{}
    case SCon{h, t} SNil{} GT{}: GT{}
    case SCon{h1, t1} SCon{h2, t2} LT{}: LT{}
    case SCon{h1, t1} SCon{h2, t2} GT{}: GT{}
    case SCon{h1, t1} SCon{h2, t2} EQ{}:
      p88_string_order_go(t1, t2, U32.cmp(Char.to_u32(h1), Char.to_u32(h2)))

def p88_string_order(a: String, b: String) -> Cmp:
  p88_string_order_go(a, b, EQ{})

# Module: /home/ai/bend2/build/publish/bend/selfhost/build/phase88/cache-js01/entry.bend:185
@unsafe
def p88_string_at(state: P88State, +id: U32) -> P88Step:
  match state:
    case P88State{cursor, nodes, strings, made, +sn, begin, end}:
      p88_string_gate(cursor, nodes, strings, made, sn, begin, end, id, U32.is_lt(id, sn))

# Module: /home/ai/bend2/build/publish/bend/selfhost/build/phase88/cache-js01/entry.bend:191
@unsafe
def p88_string_gate(cursor: P88Cursor, nodes: Array<P88Node>, strings: Array<String>, made: U32, sn: U32, begin: U32, end: U32, id: U32, ok: Bool) -> P88Step:
  match ok:
    case False{}: P88Step{P88State{P88Cursor{"",0},nodes,strings,made,sn,begin,end},P88Bad{}}
    case True{}: p88_string_got(cursor,nodes,made,sn,begin,end,Array.get(String,strings,id))

@unsafe
def p88_string_got(cursor: P88Cursor, nodes: Array<P88Node>, made: U32, sn: U32, begin: U32, end: U32, pair: Array<String> & String) -> P88Step:
  (strings, text) = pair
  P88Step{P88State{cursor, nodes, strings, made, sn, begin, end}, P88String{text}}

# Phase98 fused scalar tag observation.
# Requires the production KTerm datatype and exact held equality/walker.
# Only the generic tag uses the borrowed walker; literals use held equality.
# The term remains live while the selected tag is compared.
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
