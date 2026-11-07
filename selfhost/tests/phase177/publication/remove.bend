# Preserve all retained rows and order; replace scheduler recursion with a loop.
@unsafe
def index_remove(+ds: List<&2,KDef>, +name: String) -> List<&2,KDef>:
  p177i_remove(ds,name,Nil{})

def p177i_keep(row: KDef, done: List<&2,KDef>, same: Bool) -> List<&2,KDef>:
  match same:
    case True{}: done
    case False{}: Con{row,done}

@unsafe
def p177i_remove(ds,name,done):
  match ds:
    case Nil{}: book_final_reverse(done,Nil{})
    case Con{+row,rest}:
      p177i_remove(rest,name,p177i_keep(row,done,p88_string_eq(dn(row),name)))

