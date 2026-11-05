@unsafe
def p164xt_pass(rows: List<&2,String>) -> U32:
  match rows:
    case Nil{}: 0
    case Con{head,rest}:
      nt_choose(U32,String.ends_with(head,":pass"),u => p164xt_pass(rest),u => 1)

@unsafe
def main() -> U32:
  p164xt_pass(p164xc_controls())
