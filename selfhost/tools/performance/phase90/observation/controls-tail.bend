# Common logical result type keeps native layout out of the output comparison.
type P90FlatDef is Data:
  P90FlatDef{+name: String, +kind: String, +arity: U32, +templates: U32, +typ: KTerm, +value: KTerm, +ctors: List<&2,P90FlatDef>, +native: Bool, +unsafe: Bool}
  P90FlatLeaf{+hash: U32, +bucket: List<&2,P90FlatDef>}
  P90FlatNode{+hash: U32, +mask: U32, +left: P90FlatDef, +right: P90FlatDef}

type P90Case is Data:
  P90Case{+id: U32, +query: String, +found: P90FlatDef, +retained: List<&2,P90FlatDef>}

law p90_flat_list:
  for ds: List<&2,KDef>
  List<&2,P90FlatDef>

@unsafe
def p90_flat(d: KDef) -> P90FlatDef:
  match d:
    case KDef{name, kind, arity, templates, typ, value, ctors, native, unsafe}:
      P90FlatDef{name, kind, arity, templates, typ, value, p90_flat_list(ctors), native, unsafe}
    case KIndexLeaf{hash, bucket}: P90FlatLeaf{hash, p90_flat_list(bucket)}
    case KIndexNode{hash, mask, left, right}: P90FlatNode{hash, mask, p90_flat(left), p90_flat(right)}

@unsafe
def p90_flat_list(ds):
  match ds:
    case Nil{}: Nil{}
    case Con{d, rest}: Con{p90_flat(d), p90_flat_list(rest)}

@unsafe
def p90_case(id: U32, +query: String, +book: List<&2,KDef>) -> P90Case:
  P90Case{id, query, p90_flat(f_find(query, book)), p90_flat_list(book)}
