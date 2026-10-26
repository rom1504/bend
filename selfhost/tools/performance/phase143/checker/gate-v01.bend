# Profitability only. The prepared-Base screen is near break-even at64 rows,
# positive at256 and strongly positive at1024. Stop counting at256 eligible
# definitions; the ordinary small-request checker keeps its original path.
@unsafe
def p143cg_enough(definitions: List<&2,KDef>, left: U32) -> Bool:
  match left:
    case 0: True{}
    case +n:
      match definitions:
        case Nil{}: False{}
        case Con{definition,rest}:
          p143cg_enough(rest,nt_choose(U32,p143cp_childless(definition),
            u => U32.sub(n,1),u => n))
