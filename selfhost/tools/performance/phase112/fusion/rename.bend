# All continuation locals, including scratch, receive a per-site namespace.
# Original segments with any p112f_ local are refused by the hygiene gate.
@unsafe
def p112f_name(+prefix: String, +name: String) -> String:
  nt_choose(String,String.eq(name,"state"),u => name,u => prefix ++ "local_" ++ name)

@unsafe
def p112f_value(value: N111Value, +prefix: String) -> N111Value:
  match value:
    case N111Local{+name}: N111Local{p112f_name(prefix,name)}
    case _: value

@unsafe
def p112f_args(args: List<&2,N111Arg>, +prefix: String) -> List<&2,N111Arg>:
  match args:
    case Nil{}: []
    case Con{N111Arg{+typ,+value},+rest}: Con{N111Arg{typ,p112f_value(value,prefix)},p112f_args(rest,prefix)}

@unsafe
def p112f_rename(body: List<&2,N111Stmt>, +prefix: String) -> List<&2,N111Stmt>:
  match body:
    case Nil{}: []
    case Con{+stmt,+rest}: Con{p112f_stmt(stmt,prefix),p112f_rename(rest,prefix)}

@unsafe
def p112f_stmt(stmt: N111Stmt, +prefix: String) -> N111Stmt:
  match stmt:
    case N111Set{+name,+typ,+value}: N111Set{p112f_name(prefix,name),typ,p112f_value(value,prefix)}
    case N111Bin{+name,+typ,+op,+left,+right}: N111Bin{p112f_name(prefix,name),typ,op,p112f_value(left,prefix),p112f_value(right,prefix)}
    case N111Call{+name,+typ,+symbol,+args}: N111Call{p112f_name(prefix,name),typ,symbol,p112f_args(args,prefix)}
    case N111If{+condition,+yes,+no}: N111If{p112f_value(condition,prefix),p112f_rename(yes,prefix),p112f_rename(no,prefix)}
    case N111Return{+value}: N111Return{p112f_value(value,prefix)}
    case N111Load{+name,+typ,+base,+offset}: N111Load{p112f_name(prefix,name),typ,p112f_value(base,prefix),offset}
    case N111Store{+typ,+base,+offset,+value}: N111Store{typ,p112f_value(base,prefix),offset,p112f_value(value,prefix)}
    case N111Offset{+name,+base,+bytes}: N111Offset{p112f_name(prefix,name),p112f_value(base,prefix),p112f_value(bytes,prefix)}
    case N111Alloca{+name,+bytes,+align}: N111Alloca{p112f_name(prefix,name),bytes,align}

@unsafe
def p112f_clean_name(+name: String) -> Bool:
  Bool.not(String.starts_with(name,"p112f_"))

@unsafe
def p112f_clean_value(value: N111Value) -> Bool:
  match value:
    case N111Local{+name}: p112f_clean_name(name)
    case _: True{}

@unsafe
def p112f_clean_args(args: List<&2,N111Arg>) -> Bool:
  match args:
    case Nil{}: True{}
    case Con{N111Arg{+typ,+value},+rest}: p112f_clean_value(value) && p112f_clean_args(rest)

@unsafe
def p112f_clean(body: List<&2,N111Stmt>) -> Bool:
  match body:
    case Nil{}: True{}
    case Con{+stmt,+rest}: p112f_clean_stmt(stmt) && p112f_clean(rest)

@unsafe
def p112f_clean_stmt(stmt: N111Stmt) -> Bool:
  match stmt:
    case N111Set{+name,+typ,+value}: p112f_clean_name(name) && p112f_clean_value(value)
    case N111Bin{+name,+typ,+op,+left,+right}: p112f_clean_name(name) && p112f_clean_value(left) && p112f_clean_value(right)
    case N111Call{+name,+typ,+symbol,+args}: p112f_clean_name(name) && p112f_clean_args(args)
    case N111If{+condition,+yes,+no}: p112f_clean_value(condition) && p112f_clean(yes) && p112f_clean(no)
    case N111Return{+value}: p112f_clean_value(value)
    case N111Load{+name,+typ,+base,+offset}: p112f_clean_name(name) && p112f_clean_value(base)
    case N111Store{+typ,+base,+offset,+value}: p112f_clean_value(base) && p112f_clean_value(value)
    case N111Offset{+name,+base,+bytes}: p112f_clean_name(name) && p112f_clean_value(base) && p112f_clean_value(bytes)
    case N111Alloca{+name,+bytes,+align}: p112f_clean_name(name)
