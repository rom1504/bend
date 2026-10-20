@unsafe
def p113d_body(+code: P113DCode) -> List<&2,P113DStmt>:
  match code:
    case P113DCode{body,fresh,error,calls}: body

@unsafe
def p113d_fresh(+code: P113DCode) -> U32:
  match code:
    case P113DCode{body,fresh,error,calls}: fresh

@unsafe
def p113d_error(+code: P113DCode) -> String:
  match code:
    case P113DCode{body,fresh,error,calls}: error

@unsafe
def p113d_calls(+code: P113DCode) -> List<&2,String>:
  match code:
    case P113DCode{body,fresh,error,calls}: calls

def p113d_scalars(body: List<&2,N111Stmt>) -> List<&2,P113DStmt>:
  match body:
    case Nil{}: []
    case Con{stmt,rest}: Con{P113DScalar{stmt},p113d_scalars(rest)}

@unsafe
def p113d_prepend(prefix: List<&2,N111Stmt>, code: P113DCode) -> P113DCode:
  match code:
    case P113DCode{body,fresh,error,calls}: P113DCode{nt_append(P113DStmt,p113d_scalars(prefix),body),fresh,error,calls}

def p113d_fail(error: String, n: U32) -> P113DCode:
  P113DCode{[],n,error,[]}

@unsafe
def p113d_join(+first: P113DCode, +second: P113DCode) -> P113DCode:
  P113DCode{nt_append(P113DStmt,p113d_body(first),p113d_body(second)),p113d_fresh(second),
    p111_first(p113d_error(first),p113d_error(second)),nt_append(String,p113d_calls(first),p113d_calls(second))}

@unsafe
def p113d_result(word: N111Value, target: P113DTarget, n: U32) -> P113DCode:
  match target:
    case P113DReturn{}: P113DCode{[P113DResult{[word]}],n,"",[]}
    case P113DLocal{name}: P113DCode{[P113DScalar{N111Set{name,N111U64{},word}}],n,"",[]}

@unsafe
def p113d_emitted(+target: P113DTarget, +n: U32, value: P111ValueCode) -> P113DCode:
  match value:
    case P111ValueCode{body,word,+error}:
      nt_choose(P113DCode,String.is_empty(error),u => p113d_prepend(body,p113d_result(word,target,n)),u => p113d_fail(error,n))

@unsafe
def p113d_branch(condition: N111Value, +yes: P113DCode, +no: P113DCode) -> P113DCode:
  P113DCode{[P113DIf{condition,p113d_body(yes),p113d_body(no)}],p113d_fresh(no),
    p111_first(p113d_error(yes),p113d_error(no)),nt_append(String,p113d_calls(yes),p113d_calls(no))}

@unsafe
def p113d_tail(target: P113DTarget) -> Bool:
  match target:
    case P113DReturn{}: True{}
    case _: False{}

@unsafe
def p113d_public(+book: List<&2,KDef>, +name: String) -> String:
  nt_choose(String,U32.is_eq(nd_arity(book,name),0),u => nc_ref_name(book,name),u => nd_name(nc_ref_name(book,name)))

@unsafe
def p113d_call(+name: String, +args: List<&2,N111Value>, +owner: String, +target: P113DTarget, +n: U32) -> P113DCode:
  nt_choose(P113DCode,String.eq(name,owner),
    u => nt_choose(P113DCode,p113d_tail(target),u => P113DCode{[P113DAgain{args}],n,"",[]},u => p113d_fail("direct: non-tail self call",n)),
    u => p113d_call_target(name,args,target,n))

@unsafe
def p113d_call_target(+name: String, args: List<&2,N111Value>, target: P113DTarget, n: U32) -> P113DCode:
  match target:
    case P113DReturn{}: P113DCode{[P113DCall{["p113_result"],name,args},P113DResult{[N111Local{"p113_result"}]}],n,"",[name]}
    case P113DLocal{dest}: P113DCode{[P113DCall{[dest],name,args}],n,"",[name]}

# Scalar snippets are reused whole, including their own checked shifts and
# branches. The direct path never interprets generated backend text.
@unsafe
def p113d_value(+book: List<&2,KDef>, +t: KTerm, +env: List<&2,NC_Binding>) -> P111ValueCode:
  nt_choose(P111ValueCode,String.eq(tg(t),"NStatic"),
    u => p112s_value(book,t),u => p111_value(t,env))
