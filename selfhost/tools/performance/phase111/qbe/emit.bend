# QBE accepts non-SSA mutable temporaries and constructs SSA itself. Emit the
# structured variables directly; do not introduce stack slots for every local.
type P111QCode is Data:
  P111QCode{+chunks: List<&2,String>, +next: U32, +terminal: Bool, +error: String}

def p111q_type(typ: N111Type) -> String:
  match typ:
    case N111U32{}: "w"
    case _: "l"

@unsafe
def p111q_local(+name: String) -> String:
  nt_choose(String,String.eq(name,"state"),u => "%state",u => "%v_" ++ name)

def p111q_symbol(name: String) -> String:
  "p111_" ++ nt_fid(name)

def p111q_tmp(n: U32) -> String:
  "%t_" ++ U32.show(n)

def p111q_label(n: U32) -> String:
  "@b_" ++ U32.show(n)

@unsafe
def p111q_id(+tree: KDef, +name: String) -> String:
  p111q_id_found(index_find(tree,name,index_hash(name,2166136261),32))

@unsafe
def p111q_id_found(+found: KDef) -> String:
  nt_choose(String,String.eq(dk(found),"N111Id"),u => U32.show(da(found)),u => "INVALID_N111_ID")

@unsafe
def p111q_value(+value: N111Value, +ids: N111Ids) -> String:
  match value ids:
    case N111Local{name} _: p111q_local(name)
    case N111Const{lo,hi} _: p111q_u64(lo,hi)
    case N111Symbol{name} _: "$" ++ name
    case N111FuncId{name} N111Ids{functions,constructors}: p111q_id(functions,name)
    case N111CtorId{name} N111Ids{functions,constructors}: p111q_id(constructors,name)

@unsafe
def p111q_comparison(+op: String) -> Bool:
  String.eq(op,"eq") || String.eq(op,"ne") || String.eq(op,"ult") || String.eq(op,"ule") ||
  String.eq(op,"ugt") || String.eq(op,"uge") || String.eq(op,"slt") || String.eq(op,"sle") ||
  String.eq(op,"sgt") || String.eq(op,"sge")

@unsafe
def p111q_binop(+op: String, +typ: N111Type) -> String:
  nt_choose(String,p111q_comparison(op),u => "c" ++ op ++ p111q_type(typ),u =>
    nt_choose(String,String.eq(op,"add") || String.eq(op,"sub") || String.eq(op,"mul") ||
      String.eq(op,"and") || String.eq(op,"or") || String.eq(op,"xor") || String.eq(op,"shl") ||
      String.eq(op,"shr") || String.eq(op,"sar"),u => op,u => "INVALID_N111_BINARY"))

@unsafe
def p111q_args(+args: List<&2,N111Arg>, +ids: N111Ids, +first: Bool, acc: List<&2,String>) -> String:
  match args:
    case Nil{}: nt_text_finish(acc,"")
    case Con{N111Arg{typ,value},rest}:
      p111q_args(rest,ids,False{},Con{p111q_type(typ) ++ " " ++ p111q_value(value,ids),
        Con{nt_choose(String,first,u => "",u => ", "),acc}})

def p111q_line(line: String, code: P111QCode) -> P111QCode:
  match code:
    case P111QCode{chunks,n,terminal,error}: P111QCode{Con{line,chunks},n,terminal,error}

def p111q_problem(message: String, code: P111QCode) -> P111QCode:
  match code:
    case P111QCode{chunks,n,terminal,error}: P111QCode{chunks,n,terminal,message}

@unsafe
def p111q_stmts(+body: List<&2,N111Stmt>, +ids: N111Ids, code: P111QCode) -> P111QCode:
  match body:
    case Nil{}: code
    case Con{stmt,rest}: p111q_stmts_head(stmt,rest,ids,code)

@unsafe
def p111q_stmts_head(+stmt: N111Stmt, +rest: List<&2,N111Stmt>, +ids: N111Ids, +code: P111QCode) -> P111QCode:
  match code:
    case P111QCode{chunks,n,terminal,error}:
      nt_choose(P111QCode,Bool.not(String.eq(error,"")),u => code,u =>
        nt_choose(P111QCode,terminal,u => p111q_problem("statement follows terminal instruction",code),u =>
          p111q_stmts(rest,ids,p111q_stmt(stmt,ids,code))))

@unsafe
def p111q_stmt(+stmt: N111Stmt, +ids: N111Ids, +code: P111QCode) -> P111QCode:
  match stmt:
    case N111Set{name,typ,value}:
      p111q_line(p111q_local(name) ++ " =" ++ p111q_type(typ) ++ " copy " ++ p111q_value(value,ids) ++ "\n",code)
    case N111Bin{name,typ,op,left,right}:
      p111q_line(p111q_local(name) ++ " =" ++ nt_choose(String,p111q_comparison(op),u => "w",u => p111q_type(typ)) ++
        " " ++ p111q_binop(op,typ) ++ " " ++ p111q_value(left,ids) ++ ", " ++ p111q_value(right,ids) ++ "\n",code)
    case N111Call{name,typ,symbol,args}:
      p111q_line(p111q_local(name) ++ " =" ++ p111q_type(typ) ++ " call $" ++ symbol ++ "(" ++ p111q_args(args,ids,True{},[]) ++ ")\n",code)
    case N111If{condition,yes,no}: p111q_if(condition,yes,no,ids,code)
    case N111Return{value}: p111q_return(p111q_value(value,ids),code)
    case N111Load{name,typ,base,offset}: p111q_memory(name,typ,base,offset,N111Const{0,0},False{},ids,code)
    case N111Store{typ,base,offset,value}: p111q_memory("",typ,base,offset,value,True{},ids,code)
    case N111Offset{name,base,bytes}:
      p111q_line(p111q_local(name) ++ " =l add " ++ p111q_value(base,ids) ++ ", " ++ p111q_value(bytes,ids) ++ "\n",code)
    case N111Alloca{name,bytes,align}: code

def p111q_return(value: String, code: P111QCode) -> P111QCode:
  match code:
    case P111QCode{chunks,n,terminal,error}: P111QCode{Con{"ret " ++ value ++ "\n",chunks},n,True{},error}

@unsafe
def p111q_memory(+name: String, +typ: N111Type, +base: N111Value, +offset: U32, +value: N111Value, +store: Bool, +ids: N111Ids, +code: P111QCode) -> P111QCode:
  match code:
    case P111QCode{chunks,n,terminal,error}:
      +at = nt_choose(String,U32.is_eq(offset,0),u => p111q_value(base,ids),u => p111q_tmp(n))
      +prefix = nt_choose(List<&2,String>,U32.is_eq(offset,0),u => chunks,u =>
        Con{at ++ " =l add " ++ p111q_value(base,ids) ++ ", " ++ U32.show(offset) ++ "\n",chunks})
      +line = nt_choose(String,store,
        u => "store" ++ p111q_type(typ) ++ " " ++ p111q_value(value,ids) ++ ", " ++ at ++ "\n",
        u => p111q_local(name) ++ " =" ++ p111q_type(typ) ++ " load" ++ p111q_type(typ) ++ " " ++ at ++ "\n")
      P111QCode{Con{line,prefix},nt_choose(U32,U32.is_eq(offset,0),u => n,u => U32.inc(n)),terminal,error}

@unsafe
def p111q_if(+condition: N111Value, +yes: List<&2,N111Stmt>, +no: List<&2,N111Stmt>, +ids: N111Ids, +code: P111QCode) -> P111QCode:
  match code:
    case P111QCode{chunks,n,terminal,error}:
      p111q_if_yes(n,no,ids,p111q_stmts(yes,ids,
        P111QCode{Con{p111q_label(n) ++ "\n",Con{"jnz " ++ p111q_value(condition,ids) ++ ", " ++ p111q_label(n) ++ ", " ++ p111q_label(U32.inc(n)) ++ "\n",chunks}},U32.add(n,3),False{},error}))

@unsafe
def p111q_if_yes(+label: U32, +no: List<&2,N111Stmt>, +ids: N111Ids, +yes: P111QCode) -> P111QCode:
  match yes:
    case P111QCode{chunks,n,terminal,error}:
      +prefix = nt_choose(List<&2,String>,terminal,u => chunks,u => Con{"jmp " ++ p111q_label(U32.add(label,2)) ++ "\n",chunks})
      p111q_if_done(label,terminal,p111q_stmts(no,ids,P111QCode{Con{p111q_label(U32.inc(label)) ++ "\n",prefix},n,False{},error}))

@unsafe
def p111q_if_done(+label: U32, +yes_terminal: Bool, +no: P111QCode) -> P111QCode:
  match no:
    case P111QCode{chunks,n,terminal,error}:
      +both = yes_terminal && terminal
      +jumped = nt_choose(List<&2,String>,terminal,u => chunks,u => Con{"jmp " ++ p111q_label(U32.add(label,2)) ++ "\n",chunks})
      P111QCode{nt_choose(List<&2,String>,both,u => jumped,u => Con{p111q_label(U32.add(label,2)) ++ "\n",jumped}),n,both,error}

# Static alloca declarations are hoisted before every branch/return. Ordinary
# variables remain direct QBE temporaries; only explicit runtime buffers allocate.
@unsafe
def p111q_allocas(+body: List<&2,N111Stmt>, acc: List<&2,String>) -> List<&2,String>:
  match body:
    case Nil{}: acc
    case Con{stmt,rest}: p111q_allocas(rest,p111q_alloca(stmt,acc))

@unsafe
def p111q_alloca(+stmt: N111Stmt, +acc: List<&2,String>) -> List<&2,String>:
  match stmt:
    case N111Alloca{name,bytes,align}:
      Con{p111q_local(name) ++ " =l " ++ nt_choose(String,U32.is_eq(align,4) || U32.is_eq(align,8) || U32.is_eq(align,16),u => "alloc" ++ U32.show(align),u => "INVALID_N111_ALIGNMENT") ++ " " ++ U32.show(bytes) ++ "\n",acc}
    case N111If{condition,yes,no}: p111q_allocas(no,p111q_allocas(yes,acc))
    case _: acc

@unsafe
def p111q_body_text(+code: P111QCode) -> String:
  match code:
    case P111QCode{chunks,n,terminal,error}:
      nt_choose(String,Bool.not(String.eq(error,"")),u => "INVALID_N111_BODY\n",u =>
        nt_choose(String,terminal,u => nt_text_finish(chunks,""),u => "INVALID_N111_FALLTHROUGH\n"))

@unsafe
def p111q_segment(+segment: N111Segment, +ids: N111Ids) -> String:
  match segment:
    case N111Segment{name,arity,result,incoming,flags,body}:
      "export function l $" ++ p111q_symbol(name) ++ "(l %state) {\n@entry\n" ++
      p111q_body_text(p111q_stmts(body,ids,P111QCode{p111q_allocas(body,[]),0,False{},""})) ++ "}\n"
