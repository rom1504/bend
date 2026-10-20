# Separate per-case local/scratch namespaces are disjoint from all originals.
# This gate is additional to the unchanged whole-program verifier.
@unsafe
def p114h_clean_name(+name: String) -> Bool:
  Bool.not(String.starts_with(name,"p114h_") || String.starts_with(name,"p114r_"))

def p114h_clean_value(value: N111Value) -> Bool:
  match value:
    case N111Local{name}: p114h_clean_name(name)
    case _: True{}

def p114h_clean_args(args: List<&2,N111Arg>) -> Bool:
  match args:
    case Nil{}: True{}
    case Con{N111Arg{typ,value},rest}: p114h_clean_value(value) && p114h_clean_args(rest)

@unsafe
def p114h_clean(body: List<&2,N111Stmt>) -> Bool:
  match body:
    case Nil{}: True{}
    case Con{stmt,rest}: p114h_clean_stmt(stmt) && p114h_clean(rest)

@unsafe
def p114h_clean_stmt(stmt: N111Stmt) -> Bool:
  match stmt:
    case N111Set{name,typ,value}: p114h_clean_name(name) && p114h_clean_value(value)
    case N111Bin{name,typ,op,left,right}: p114h_clean_name(name) && p114h_clean_value(left) && p114h_clean_value(right)
    case N111Call{name,typ,symbol,args}: p114h_clean_name(name) && p114h_clean_args(args)
    case N111If{condition,yes,no}: p114h_clean_value(condition) && p114h_clean(yes) && p114h_clean(no)
    case N111Return{value}: p114h_clean_value(value)
    case N111Load{name,typ,base,offset}: p114h_clean_name(name) && p114h_clean_value(base)
    case N111Store{typ,base,offset,value}: p114h_clean_value(base) && p114h_clean_value(value)
    case N111Offset{name,base,bytes}: p114h_clean_name(name) && p114h_clean_value(base) && p114h_clean_value(bytes)
    case N111Alloca{name,bytes,align}: p114h_clean_name(name)


def p114h_clean_segment(segment: N111Segment) -> Bool:
  match segment:
    case N111Segment{name,arity,result,incoming,flags,body}: p114h_clean(body)
