# Continuation locals are renamed with p114r_resume_. Ordinary input locals
# using that namespace are left on the original generic renderer.
@unsafe
def p114r_clean_name(name: String) -> Bool:
  Bool.not(String.starts_with(name,"p114r_"))

def p114r_clean_value(value: N111Value) -> Bool:
  match value:
    case N111Local{name}: p114r_clean_name(name)
    case _: True{}

def p114r_clean_args(args: List<&2,N111Arg>) -> Bool:
  match args:
    case Nil{}: True{}
    case Con{N111Arg{typ,value},rest}: p114r_clean_value(value) && p114r_clean_args(rest)

@unsafe
def p114r_clean(body: List<&2,N111Stmt>) -> Bool:
  match body:
    case Nil{}: True{}
    case Con{stmt,rest}: p114r_clean_stmt(stmt) && p114r_clean(rest)

@unsafe
def p114r_clean_stmt(stmt: N111Stmt) -> Bool:
  match stmt:
    case N111Set{name,typ,value}: p114r_clean_name(name) && p114r_clean_value(value)
    case N111Bin{name,typ,op,left,right}: p114r_clean_name(name) && p114r_clean_value(left) && p114r_clean_value(right)
    case N111Call{name,typ,symbol,args}: p114r_clean_name(name) && p114r_clean_args(args)
    case N111If{condition,yes,no}: p114r_clean_value(condition) && p114r_clean(yes) && p114r_clean(no)
    case N111Return{value}: p114r_clean_value(value)
    case N111Load{name,typ,base,offset}: p114r_clean_name(name) && p114r_clean_value(base)
    case N111Store{typ,base,offset,value}: p114r_clean_value(base) && p114r_clean_value(value)
    case N111Offset{name,base,bytes}: p114r_clean_name(name) && p114r_clean_value(base) && p114r_clean_value(bytes)
    case N111Alloca{name,bytes,align}: p114r_clean_name(name)

def p114r_clean_cont(found: Maybe<&2,N111Segment>) -> Bool:
  match found:
    case Some{N111Segment{name,arity,result,incoming,flags,body}}: p114r_clean(body)
    case None{}: False{}

@unsafe
def p114r_hygiene(+original: List<&2,N111Stmt>, +index: P112FusionIndex, plan: P114RPlan) -> Bool:
  match plan:
    case P114RPlan{valid,params,body,continuation,head,result,unwind}:
      valid && p114r_clean(original) && p114r_clean_cont(p112f_index_get(index,continuation))
