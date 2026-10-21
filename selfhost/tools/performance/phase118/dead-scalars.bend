# Optional backward dead-definition cleanup. Only total integer definitions are
# removed. Names are mutable locations: kill destination before adding inputs.
type P118DScalar is Data:
  P118DScalar{+body: List<&2,N111Stmt>, +live: List<&2,String>}
type P118DBody is Data:
  P118DBody{+body: List<&2,P113DStmt>, +live: List<&2,String>}

@unsafe
def p118d_add(+name: String, +live: List<&2,String>) -> List<&2,String>:
  nt_choose(List<&2,String>,nb_contains(live,name),u => live,u => Con{name,live})

@unsafe
def p118d_kill(+name: String, live: List<&2,String>) -> List<&2,String>:
  match live:
    case Nil{}: []
    case Con{+head,+rest}:
      nt_choose(List<&2,String>,String.eq(head,name),
        u => p118d_kill(name,rest),u => Con{head,p118d_kill(name,rest)})

@unsafe
def p118d_kills(names: List<&2,String>, live: List<&2,String>) -> List<&2,String>:
  match names:
    case Nil{}: live
    case Con{name,rest}: p118d_kills(rest,p118d_kill(name,live))

@unsafe
def p118d_union(names: List<&2,String>, live: List<&2,String>) -> List<&2,String>:
  match names:
    case Nil{}: live
    case Con{name,rest}: p118d_union(rest,p118d_add(name,live))

@unsafe
def p118d_value(value: N111Value, live: List<&2,String>) -> List<&2,String>:
  match value:
    case N111Local{name}: p118d_add(name,live)
    case _: live

@unsafe
def p118d_values(values: List<&2,N111Value>, live: List<&2,String>) -> List<&2,String>:
  match values:
    case Nil{}: live
    case Con{head,rest}: p118d_values(rest,p118d_value(head,live))

@unsafe
def p118d_args(args: List<&2,N111Arg>, live: List<&2,String>) -> List<&2,String>:
  match args:
    case Nil{}: live
    case Con{N111Arg{typ,value},rest}: p118d_args(rest,p118d_value(value,live))

@unsafe
def p118d_integer(typ: N111Type) -> Bool:
  match typ:
    case N111U32{}: True{}
    case N111U64{}: True{}
    case _: False{}

@unsafe
def p118d_total(+op: String) -> Bool:
  String.eq(op,"add") || String.eq(op,"sub") || String.eq(op,"mul") ||
  String.eq(op,"and") || String.eq(op,"or") || String.eq(op,"xor") ||
  String.eq(op,"eq") || String.eq(op,"ne") || String.eq(op,"ult") ||
  String.eq(op,"ule") || String.eq(op,"ugt") || String.eq(op,"uge")

law p118d_scalars:
  List<&2,N111Stmt> -> List<&2,String> -> P118DScalar

@unsafe
def p118d_scalar_join(+condition: N111Value, yes: P118DScalar, no: P118DScalar, out: List<&2,N111Stmt>) -> P118DScalar:
  match yes no:
    case P118DScalar{yb,yl} P118DScalar{nb,nl}:
      P118DScalar{Con{N111If{condition,yb,nb},out},p118d_value(condition,p118d_union(yl,nl))}

@unsafe
def p118d_scalar(+stmt: N111Stmt, +live: List<&2,String>, +out: List<&2,N111Stmt>) -> P118DScalar:
  match stmt:
    case N111Set{+name,+typ,+value}:
      nt_choose(P118DScalar,p118d_integer(typ) && Bool.not(nb_contains(live,name)),
        u => P118DScalar{out,live},
        u => P118DScalar{Con{stmt,out},p118d_value(value,p118d_kill(name,live))})
    case N111Bin{+name,+typ,+op,+left,+right}:
      nt_choose(P118DScalar,p118d_integer(typ) && p118d_total(op) && Bool.not(nb_contains(live,name)),
        u => P118DScalar{out,live},
        u => P118DScalar{Con{stmt,out},p118d_value(left,p118d_value(right,p118d_kill(name,live)))})
    case N111Call{name,typ,symbol,args}:
      P118DScalar{Con{stmt,out},p118d_args(args,p118d_kill(name,live))}
    case N111If{condition,yes,no}:
      p118d_scalar_join(condition,p118d_scalars(yes,live),p118d_scalars(no,live),out)
    case N111Return{value}: P118DScalar{Con{stmt,out},p118d_value(value,[])}
    case N111Load{name,typ,base,offset}:
      P118DScalar{Con{stmt,out},p118d_value(base,p118d_kill(name,live))}
    case N111Store{typ,base,offset,value}:
      P118DScalar{Con{stmt,out},p118d_value(base,p118d_value(value,live))}
    case N111Offset{name,base,bytes}:
      P118DScalar{Con{stmt,out},p118d_value(base,p118d_value(bytes,p118d_kill(name,live)))}
    case N111Alloca{name,bytes,align}: P118DScalar{Con{stmt,out},p118d_kill(name,live)}

@unsafe
def p118d_scalar_reverse(reversed: List<&2,N111Stmt>, scan: P118DScalar) -> P118DScalar:
  match reversed scan:
    case Nil{} _: scan
    case Con{stmt,rest} P118DScalar{out,live}:
      p118d_scalar_reverse(rest,p118d_scalar(stmt,live,out))

@unsafe
def p118d_scalars(body, live):
  p118d_scalar_reverse(nt_reverse(N111Stmt,body,[]),P118DScalar{[],live})

law p118d_body:
  List<&2,P113DStmt> -> List<&2,String> -> P118DBody

@unsafe
def p118d_body_join(+condition: N111Value, yes: P118DBody, no: P118DBody, out: List<&2,P113DStmt>) -> P118DBody:
  match yes no:
    case P118DBody{yb,yl} P118DBody{nb,nl}:
      P118DBody{Con{P113DIf{condition,yb,nb},out},p118d_value(condition,p118d_union(yl,nl))}

@unsafe
def p118d_body_scalar(scan: P118DScalar, out: List<&2,P113DStmt>) -> P118DBody:
  match scan:
    case P118DScalar{body,live}: P118DBody{nt_append(P113DStmt,p113d_scalars(body),out),live}

@unsafe
def p118d_stmt(+stmt: P113DStmt, +live: List<&2,String>, out: List<&2,P113DStmt>) -> P118DBody:
  match stmt:
    case P113DScalar{scalar}: p118d_body_scalar(p118d_scalar(scalar,live,[]),out)
    case P113DIf{condition,yes,no}: p118d_body_join(condition,p118d_body(yes,live),p118d_body(no,live),out)
    case P113DCall{destinations,target,args}:
      P118DBody{Con{stmt,out},p118d_values(args,p118d_kills(destinations,live))}
    case P113DResult{values}: P118DBody{Con{stmt,out},p118d_values(values,[])}
    case P113DAgain{values}: P118DBody{Con{stmt,out},p118d_values(values,[])}

@unsafe
def p118d_body_reverse(reversed: List<&2,P113DStmt>, scan: P118DBody) -> P118DBody:
  match reversed scan:
    case Nil{} _: scan
    case Con{stmt,rest} P118DBody{out,live}: p118d_body_reverse(rest,p118d_stmt(stmt,live,out))

@unsafe
def p118d_body(body, live):
  p118d_body_reverse(nt_reverse(P113DStmt,body,[]),P118DBody{[],live})

@unsafe
def p118d_function_done(name: String, params: List<&2,NC_Binding>, result: U32, public: Bool, scan: P118DBody) -> P113DFunction:
  match scan:
    case P118DBody{body,live}: P113DFunction{name,params,result,public,body}

@unsafe
def p118d_function(+function: P113DFunction) -> P113DFunction:
  match function:
    case P113DFunction{+name,+params,+result,+public,+body}:
      nt_choose(P113DFunction,U32.is_lt(p113i_size(body),4096),
        u => p118d_function_done(name,params,result,public,p118d_body(body,[])),u => function)

@unsafe
def p118d_functions(functions: List<&2,P113DFunction>) -> List<&2,P113DFunction>:
  match functions:
    case Nil{}: []
    case Con{function,rest}: Con{p118d_function(function),p118d_functions(rest)}

@unsafe
def p118d_boundary(+boundary: P114SBoundary) -> P114SBoundary:
  match boundary:
    case P114SBoundary{original,ids,functions,valid}:
      nt_choose(P114SBoundary,valid,u => p114s_commit(boundary,p118d_functions(functions)),u => boundary)

# Sole integration hook. Preserve the original range commit before cleanup.
@unsafe
def p114s_ranges(+boundary: P114SBoundary) -> P114SBoundary:
  match boundary:
    case P114SBoundary{original,ids,functions,valid}:
      nt_choose(P114SBoundary,valid,
        u => p118d_boundary(p114s_commit(boundary,p113k_functions(functions))),u => boundary)
