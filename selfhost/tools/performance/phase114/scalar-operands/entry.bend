# The original checked function and every nonselected render path are retained.
@unsafe
def p113e_private(+function: P113DFunction, +ids: N111Ids) -> String:
  match function:
    case P113DFunction{name,params,result,public,+body}:
      +buffers = p114so_buffers(body)
      nt_choose(String,String.is_empty(p114so_first(buffers)),
        u => p114so_private_original(function,ids),u => p114so_private(function,ids))

def p114so_first(names: List<&2,String>) -> String:
  match names:
    case Nil{}: ""
    case Con{name,rest}: name
