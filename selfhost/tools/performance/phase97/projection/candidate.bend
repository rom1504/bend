@unsafe
def f_find(
  +name: String,
  +book: List<&2, KDef>,
) -> KDef:
  match book:
    case Nil{}:
      KDef{name, "Missing", 0, 0, atom("Absent"), atom("Absent"), Nil{}, False{}, False{}}
    case Con{d, ds}:
      match d:
        case KDef{+label, kind, arity, templates, typ, value, ctors, native, unsafe}:
          f_find_fields(name, ds, label, kind, arity, templates, typ, value, ctors, native, unsafe, f_eq(name, label))
        case KIndexLeaf{hash, bucket}:
          f_find_next(name, KIndexLeaf{hash, bucket}, ds, f_eq(name, ""))
        case KIndexNode{hash, mask, left, right}:
          f_find_next(name, KIndexNode{hash, mask, left, right}, ds, f_eq(name, ""))

@unsafe
def f_find_fields(
  +name: String, +ds: List<&2,KDef>,
  +label: String, +kind: String, +arity: U32, +templates: U32,
  +typ: KTerm, +value: KTerm, +ctors: List<&2,KDef>,
  +native: Bool, +unsafe: Bool, same: Bool,
) -> KDef:
  match same:
    case True{}: KDef{label, kind, arity, templates, typ, value, ctors, native, unsafe}
    case False{}: f_find(name, ds)
