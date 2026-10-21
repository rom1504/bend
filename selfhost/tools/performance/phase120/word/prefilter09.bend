# Version09: include law declarations in each whole-declaration override.
law p120w_prefilter_scalars:
  List<&2,N111Stmt> -> U32 -> U32
law p120w_prefilter_body:
  List<&2,P113DStmt> -> U32 -> U32

# Cost-only necessary-condition refinement of model07. No fact or IR changes.
# Flags:1=possible sign shr31,2=possible logical shr1..30,4=or consumer.
# Local counts conservatively admit both shift classes; no lookup is performed.
@unsafe
def p120wpf_count(value: N111Value) -> U32:
  match value:
    case N111Const{+lo,hi}:
      nt_choose(U32,U32.is_eq(hi,0),u =>
        nt_choose(U32,U32.is_eq(lo,31),v => 1,v =>
          nt_choose(U32,U32.is_gt(lo,0) && U32.is_lt(lo,31),w => 2,w => 0)),u => 0)
    case N111Local{name}: 3
    case _: 0

@unsafe
def p120w_prefilter_scalar(stmt: N111Stmt, +flags: U32) -> U32:
  match stmt:
    case N111Bin{name,typ,+op,left,right}:
      U32.or(flags,nt_choose(U32,String.eq(op,"or"),u => 4,u =>
        nt_choose(U32,String.eq(op,"shr"),v => p120wpf_count(right),v => 0)))
    case N111If{condition,yes,no}:
      p120w_prefilter_scalars(no,p120w_prefilter_scalars(yes,flags))
    case _: flags

@unsafe
def p120w_prefilter_scalars(body, flags):
  match body:
    case Nil{}: flags
    case Con{stmt,rest}:
      +flags = flags
      nt_choose(U32,U32.is_eq(flags,7),u => flags,
        u => p120w_prefilter_scalars(rest,p120w_prefilter_scalar(stmt,flags)))

@unsafe
def p120w_prefilter_body(body, flags):
  match body:
    case Nil{}: flags
    case Con{stmt,rest}:
      +flags = flags
      nt_choose(U32,U32.is_eq(flags,7),u => flags,
        u => p120w_prefilter_body(rest,p120w_prefilter_stmt(stmt,flags)))

@unsafe
def p120w_function(+function: P113DFunction) -> P113DFunction:
  match function:
    case P113DFunction{+name,+params,+result,+public,+body}:
      nt_choose(P113DFunction,U32.is_lt(p113i_size(body),1024),u =>
        nt_choose(P113DFunction,U32.is_eq(p120w_prefilter_body(body,0),7),
          v => p120w_finish(name,params,result,public,p120w_walk(body,
            P120WScan{[],p120w_seed(params,1,[]),U32.inc(nt_count(NC_Binding,params)),0})),
          v => function),u => function)

