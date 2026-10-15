import Base
import ./production.bend as P

# Child replacement is a lens on node/lambda terms. Literal leaves deliberately
# ignore replacement: the universal put-back/overwrite laws still hold.
law children_put_back:
  for +t: P.KTerm
  {P.k_with_children(t, P.ks(t)) == t : P.KTerm}

def children_put_back(t):
  match t:
    case P.KTerm{tag, name, id, q, kids, removed, begin, end}: {==}
    case P.KLambda{name, id, q, kids, removed, begin, end, present}: {==}
    case P.KLiteral{kind, number, text, begin, end}: {==}

law children_last_write:
  for +t: P.KTerm
  for +first: List<&2, P.KTerm>
  for +last: List<&2, P.KTerm>
  {P.k_with_children(P.k_with_children(t, first), last) == P.k_with_children(t, last) : P.KTerm}

def children_last_write(t, first, last):
  match t:
    case P.KTerm{tag, name, id, q, kids, removed, begin, end}: {==}
    case P.KLambda{name, id, q, kids, removed, begin, end, present}: {==}
    case P.KLiteral{kind, number, text, begin, end}: {==}

law span_put_back:
  for +t: P.KTerm
  {P.k_with_span(t, P.kb(t), P.ke(t)) == t : P.KTerm}

def span_put_back(t):
  match t:
    case P.KTerm{tag, name, id, q, kids, removed, begin, end}: {==}
    case P.KLambda{name, id, q, kids, removed, begin, end, present}: {==}
    case P.KLiteral{kind, number, text, begin, end}: {==}

law span_last_write:
  for +t: P.KTerm
  for +a: U32
  for +b: U32
  for +c: U32
  for +d: U32
  {P.k_with_span(P.k_with_span(t, a, b), c, d) == P.k_with_span(t, c, d) : P.KTerm}

def span_last_write(t, a, b, c, d):
  match t:
    case P.KTerm{tag, name, id, q, kids, removed, begin, end}: {==}
    case P.KLambda{name, id, q, kids, removed, begin, end, present}: {==}
    case P.KLiteral{kind, number, text, begin, end}: {==}

law span_children_commute:
  for +t: P.KTerm
  for +kids: List<&2, P.KTerm>
  for +a: U32
  for +b: U32
  {P.k_with_span(P.k_with_children(t, kids), a, b) == P.k_with_children(P.k_with_span(t, a, b), kids) : P.KTerm}

def span_children_commute(t, kids, a, b):
  match t:
    case P.KTerm{tag, name, id, q, oldKids, removed, begin, end}: {==}
    case P.KLambda{name, id, q, oldKids, removed, begin, end, present}: {==}
    case P.KLiteral{kind, number, text, begin, end}: {==}

# Full observations group correlated metadata instead of counting every field
# as a separate theorem. These are specifications, not shipped compiler code.
type Metadata is Data:
  Metadata{+tag: String, +name: String, +id: U32, +q: U32, +removed: List<&2,String>, +begin: U32, +end: U32, +present: Bool, +number: U32, +text: String}

def metadata(+t: P.KTerm) -> Metadata:
  Metadata{P.tg(t), P.nm(t), P.ix(t), P.qt(t), P.rm(t), P.kb(t), P.ke(t), P.k_quantity_present(t), P.kl_number(t), P.kl_text(t)}

type Semantics is Data:
  Semantics{+tag: String, +name: String, +id: U32, +q: U32, +kids: List<&2,P.KTerm>, +removed: List<&2,String>, +present: Bool, +number: U32, +text: String}

def semantics(+t: P.KTerm) -> Semantics:
  Semantics{P.tg(t), P.nm(t), P.ix(t), P.qt(t), P.ks(t), P.rm(t), P.k_quantity_present(t), P.kl_number(t), P.kl_text(t)}

law children_preserve_metadata:
  for +t: P.KTerm
  for +kids: List<&2,P.KTerm>
  {metadata(P.k_with_children(t, kids)) == metadata(t) : Metadata}

def children_preserve_metadata(t, kids):
  match t:
    case P.KTerm{tag, name, id, q, oldKids, removed, begin, end}: {==}
    case P.KLambda{name, id, q, oldKids, removed, begin, end, present}: {==}
    case P.KLiteral{kind, number, text, begin, end}: {==}

law span_preserves_semantics:
  for +t: P.KTerm
  for +a: U32
  for +b: U32
  {semantics(P.k_with_span(t, a, b)) == semantics(t) : Semantics}

def span_preserves_semantics(t, a, b):
  match t:
    case P.KTerm{tag, name, id, q, kids, removed, begin, end}: {==}
    case P.KLambda{name, id, q, kids, removed, begin, end, present}: {==}
    case P.KLiteral{kind, number, text, begin, end}: {==}

# Semantic anchors prevent an implementation that ignores updates from passing
# only put-back/last-write/commutation properties.
law span_reads_new_begin:
  for +t: P.KTerm
  for +a: U32
  for +b: U32
  {P.kb(P.k_with_span(t, a, b)) == a : U32}

def span_reads_new_begin(t, a, b):
  match t:
    case P.KTerm{tag, name, id, q, kids, removed, begin, end}: {==}
    case P.KLambda{name, id, q, kids, removed, begin, end, present}: {==}
    case P.KLiteral{kind, number, text, begin, end}: {==}

law span_reads_new_end:
  for +t: P.KTerm
  for +a: U32
  for +b: U32
  {P.ke(P.k_with_span(t, a, b)) == b : U32}

def span_reads_new_end(t, a, b):
  match t:
    case P.KTerm{tag, name, id, q, kids, removed, begin, end}: {==}
    case P.KLambda{name, id, q, kids, removed, begin, end, present}: {==}
    case P.KLiteral{kind, number, text, begin, end}: {==}

law node_reads_new_children:
  for +tag: String
  for +name: String
  for +id: U32
  for +q: U32
  for +oldKids: List<&2,P.KTerm>
  for +removed: List<&2,String>
  for +begin: U32
  for +end: U32
  for +newKids: List<&2,P.KTerm>
  {P.ks(P.k_with_children(P.KTerm{tag,name,id,q,oldKids,removed,begin,end},newKids)) == newKids : List<&2,P.KTerm>}

def node_reads_new_children(tag,name,id,q,oldKids,removed,begin,end,newKids): {==}

law lambda_reads_new_children:
  for +name: String
  for +id: U32
  for +q: U32
  for +oldKids: List<&2,P.KTerm>
  for +removed: List<&2,String>
  for +begin: U32
  for +end: U32
  for +present: Bool
  for +newKids: List<&2,P.KTerm>
  {P.ks(P.k_with_children(P.KLambda{name,id,q,oldKids,removed,begin,end,present},newKids)) == newKids : List<&2,P.KTerm>}

def lambda_reads_new_children(name,id,q,oldKids,removed,begin,end,present,newKids): {==}

law literal_ignores_children:
  for +kind: String
  for +number: U32
  for +text: String
  for +begin: U32
  for +end: U32
  for +newKids: List<&2,P.KTerm>
  {P.k_with_children(P.KLiteral{kind,number,text,begin,end},newKids) == P.KLiteral{kind,number,text,begin,end} : P.KTerm}

def literal_ignores_children(kind,number,text,begin,end,newKids): {==}

law rebuild_put_back:
  for +t: P.KTerm
  {P.k_rebuild(t,P.nm(t),P.ix(t),P.qt(t),P.ks(t),P.rm(t),P.kb(t),P.ke(t)) == t : P.KTerm}

def rebuild_put_back(t):
  match t:
    case P.KTerm{tag, name, id, q, kids, removed, begin, end}: {==}
    case P.KLambda{name, id, q, kids, removed, begin, end, present}: {==}
    case P.KLiteral{kind, number, text, begin, end}: {==}

law children_update_is_rebuild:
  for +t: P.KTerm
  for +kids: List<&2,P.KTerm>
  {P.k_with_children(t,kids) == P.k_rebuild(t,P.nm(t),P.ix(t),P.qt(t),kids,P.rm(t),P.kb(t),P.ke(t)) : P.KTerm}

def children_update_is_rebuild(t,kids):
  match t:
    case P.KTerm{tag, name, id, q, oldKids, removed, begin, end}: {==}
    case P.KLambda{name, id, q, oldKids, removed, begin, end, present}: {==}
    case P.KLiteral{kind, number, text, begin, end}: {==}

# Projecting a literal is intentionally not projecting a generic KTerm payload.
law literal_observation:
  for +kind: String
  for +number: U32
  for +text: String
  for +begin: U32
  for +end: U32
  {semantics(P.KLiteral{kind,number,text,begin,end}) == Semantics{"Lit",kind,0,0,Nil{},Nil{},False{},number,text} : Semantics}

def literal_observation(kind,number,text,begin,end): {==}

law lambda_observation:
  for +name: String
  for +id: U32
  for +q: U32
  for +kids: List<&2,P.KTerm>
  for +removed: List<&2,String>
  for +begin: U32
  for +end: U32
  for +present: Bool
  {semantics(P.KLambda{name,id,q,kids,removed,begin,end,present}) == Semantics{"Lam",name,id,q,kids,removed,present,0,""} : Semantics}

def lambda_observation(name,id,q,kids,removed,begin,end,present): {==}

law node_observation:
  for +tag: String
  for +name: String
  for +id: U32
  for +q: U32
  for +kids: List<&2,P.KTerm>
  for +removed: List<&2,String>
  for +begin: U32
  for +end: U32
  {semantics(P.KTerm{tag,name,id,q,kids,removed,begin,end}) == Semantics{tag,name,id,q,kids,removed,String.eq(tag,"Lam"),0,""} : Semantics}

def node_observation(tag,name,id,q,kids,removed,begin,end): {==}
