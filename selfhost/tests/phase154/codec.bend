# Private Phase154 boundary codec. No whole old IR is built before numeric
# lowering. The reverse codec is paid once at independent verification/output.
# Only exact canonical v_<U32> spellings collapse to numeric binder identities.
@unsafe
def p154c_name(+text: String) -> P154Name:
  match text:
    case SCon{a,SCon{b,tail}}:
      nt_choose(P154Name,U32.is_eq(Char.to_u32(a),118) && U32.is_eq(Char.to_u32(b),95),
        u => p154c_name_read(text,U32.read(tail)),u => P154Named{text})
    case _: P154Named{text}

@unsafe
def p154c_name_read(+text: String, parsed: Maybe<&2,U32>) -> P154Name:
  match parsed:
    case None{}: P154Named{text}
    case Some{+id}: nt_choose(P154Name,String.eq(text,"v_" ++ U32.show(id)),u => P154Binder{id},u => P154Named{text})

@unsafe
def p154c_value(value: N111Value) -> P154Value:
  match value:
    case N111Local{name}: P154Local{p154c_name(name)}
    case N111Const{lo,hi}: P154Const{lo,hi}
    case N111Symbol{name}: P154Symbol{name}
    case N111FuncId{name}: P154FuncId{name}
    case N111CtorId{name}: P154CtorId{name}

@unsafe
def p154c_decode_value(value: P154Value) -> N111Value:
  match value:
    case P154Local{name}: N111Local{p154n_text(name)}
    case P154Const{lo,hi}: N111Const{lo,hi}
    case P154Symbol{name}: N111Symbol{name}
    case P154FuncId{name}: N111FuncId{name}
    case P154CtorId{name}: N111CtorId{name}

@unsafe
def p154c_args(args: List<&2,N111Arg>) -> List<&2,P154Arg>:
  match args:
    case Nil{}: []
    case Con{N111Arg{typ,value},rest}: Con{P154Arg{typ,p154c_value(value)},p154c_args(rest)}

@unsafe
def p154c_decode_args(args: List<&2,P154Arg>) -> List<&2,N111Arg>:
  match args:
    case Nil{}: []
    case Con{P154Arg{typ,value},rest}: Con{N111Arg{typ,p154c_decode_value(value)},p154c_decode_args(rest)}

law p154c_scalars:
  for body: List<&2,N111Stmt>
  List<&2,P154Stmt>

@unsafe
def p154c_stmt(stmt: N111Stmt) -> P154Stmt:
  match stmt:
    case N111Set{name,typ,value}: P154Set{p154c_name(name),typ,p154c_value(value)}
    case N111Bin{name,typ,op,left,right}: P154Bin{p154c_name(name),typ,op,p154c_value(left),p154c_value(right)}
    case N111Call{name,typ,symbol,args}: P154Call{p154c_name(name),typ,symbol,p154c_args(args)}
    case N111If{condition,yes,no}: P154If{p154c_value(condition),p154c_scalars(yes),p154c_scalars(no)}
    case N111Return{value}: P154Return{p154c_value(value)}
    case N111Load{name,typ,base,offset}: P154Load{p154c_name(name),typ,p154c_value(base),offset}
    case N111Store{typ,base,offset,value}: P154Store{typ,p154c_value(base),offset,p154c_value(value)}
    case N111Offset{name,base,bytes}: P154Offset{p154c_name(name),p154c_value(base),p154c_value(bytes)}
    case N111Alloca{name,bytes,align}: P154Alloca{p154c_name(name),bytes,align}

@unsafe
def p154c_scalars(body):
  match body:
    case Nil{}: []
    case Con{head,rest}: Con{p154c_stmt(head),p154c_scalars(rest)}

law p154c_decode_scalars:
  for body: List<&2,P154Stmt>
  List<&2,N111Stmt>

@unsafe
def p154c_decode_stmt(stmt: P154Stmt) -> N111Stmt:
  match stmt:
    case P154Set{name,typ,value}: N111Set{p154n_text(name),typ,p154c_decode_value(value)}
    case P154Bin{name,typ,op,left,right}: N111Bin{p154n_text(name),typ,op,p154c_decode_value(left),p154c_decode_value(right)}
    case P154Call{name,typ,symbol,args}: N111Call{p154n_text(name),typ,symbol,p154c_decode_args(args)}
    case P154If{condition,yes,no}: N111If{p154c_decode_value(condition),p154c_decode_scalars(yes),p154c_decode_scalars(no)}
    case P154Return{value}: N111Return{p154c_decode_value(value)}
    case P154Load{name,typ,base,offset}: N111Load{p154n_text(name),typ,p154c_decode_value(base),offset}
    case P154Store{typ,base,offset,value}: N111Store{typ,p154c_decode_value(base),offset,p154c_decode_value(value)}
    case P154Offset{name,base,bytes}: N111Offset{p154n_text(name),p154c_decode_value(base),p154c_decode_value(bytes)}
    case P154Alloca{name,bytes,align}: N111Alloca{p154n_text(name),bytes,align}

@unsafe
def p154c_decode_scalars(body):
  match body:
    case Nil{}: []
    case Con{head,rest}: Con{p154c_decode_stmt(head),p154c_decode_scalars(rest)}

@unsafe
def p154c_values(values: List<&2,N111Value>) -> List<&2,P154Value>:
  match values:
    case Nil{}: []
    case Con{head,rest}: Con{p154c_value(head),p154c_values(rest)}

@unsafe
def p154c_decode_values(values: List<&2,P154Value>) -> List<&2,N111Value>:
  match values:
    case Nil{}: []
    case Con{head,rest}: Con{p154c_decode_value(head),p154c_decode_values(rest)}

@unsafe
def p154c_names(names: List<&2,String>) -> List<&2,P154Name>:
  match names:
    case Nil{}: []
    case Con{head,rest}: Con{p154c_name(head),p154c_names(rest)}

@unsafe
def p154c_decode_names(names: List<&2,P154Name>) -> List<&2,String>:
  match names:
    case Nil{}: []
    case Con{head,rest}: Con{p154n_text(head),p154c_decode_names(rest)}

law p154c_from_body:
  for body: List<&2,P113DStmt>
  List<&2,P154DStmt>

@unsafe
def p154c_direct(stmt: P113DStmt) -> P154DStmt:
  match stmt:
    case P113DScalar{scalar}: P154DScalar{p154c_stmt(scalar)}
    case P113DIf{condition,yes,no}: P154DIf{p154c_value(condition),p154c_from_body(yes),p154c_from_body(no)}
    case P113DCall{destinations,target,args}: P154DCall{p154c_names(destinations),target,p154c_values(args)}
    case P113DResult{values}: P154DResult{p154c_values(values)}
    case P113DAgain{values}: P154DAgain{p154c_values(values)}

@unsafe
def p154c_from_body(body):
  match body:
    case Nil{}: []
    case Con{head,rest}: Con{p154c_direct(head),p154c_from_body(rest)}

law p154c_decode_body:
  for body: List<&2,P154DStmt>
  List<&2,P113DStmt>

@unsafe
def p154c_decode_direct(stmt: P154DStmt) -> P113DStmt:
  match stmt:
    case P154DScalar{scalar}: P113DScalar{p154c_decode_stmt(scalar)}
    case P154DIf{condition,yes,no}: P113DIf{p154c_decode_value(condition),p154c_decode_body(yes),p154c_decode_body(no)}
    case P154DCall{destinations,target,args}: P113DCall{p154c_decode_names(destinations),target,p154c_decode_values(args)}
    case P154DResult{values}: P113DResult{p154c_decode_values(values)}
    case P154DAgain{values}: P113DAgain{p154c_decode_values(values)}

@unsafe
def p154c_decode_body(body):
  match body:
    case Nil{}: []
    case Con{head,rest}: Con{p154c_decode_direct(head),p154c_decode_body(rest)}

@unsafe
def p154c_decode_function(function: P154DFunction) -> P113DFunction:
  match function:
    case P154DFunction{name,params,result,public,body}: P113DFunction{name,params,result,public,p154c_decode_body(body)}

# This forward whole-function adapter is for differential controls/ablations
# only. Timed direct production must not call it.
@unsafe
def p154c_function(function: P113DFunction) -> P154DFunction:
  match function:
    case P113DFunction{name,params,result,public,body}: P154DFunction{name,params,result,public,p154c_from_body(body)}
