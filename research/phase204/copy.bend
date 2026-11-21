# A wrapped scalar If must also run the pass to normalize it into P113DIf.
@unsafe
def x204_copy_scalar(stmt: N111Stmt) -> Bool:
  match stmt:
    case N111Set{name,typ,N111Local{source}}: Bool.not(U32.is_eq(p111v_type(typ),1))
    case N111If{condition,yes,no}: True{}
    case _: False{}

@unsafe
def x204_copy_possible(body: List<&2,P113DStmt>) -> Bool:
  match body:
    case Nil{}: False{}
    case Con{P113DScalar{stmt},rest}: x204_copy_scalar(stmt) || x204_copy_possible(rest)
    case Con{P113DIf{condition,yes,no},rest}:
      x204_copy_possible(yes) || x204_copy_possible(no) || x204_copy_possible(rest)
    case Con{head,rest}: x204_copy_possible(rest)

# Only called on internal maps built from missing() by index_set with the
# hash of the exact stored key. A single bucket can check spelling directly.
@unsafe
def x204_local_get(+tree: KDef, +name: String) -> KDef:
  match tree:
    case KIndexLeaf{stored,bucket}: index_bucket(bucket,name)
    case KIndexNode{stored,mask,left,right}: p111v_get(tree,name)
    case KDef{label,kind,arity,templates,typ,value,ctors,native,unsafe}: missing()
