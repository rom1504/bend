# Exact original Phase111 statement renderer, declaration rename only.
@unsafe
def p112a_original_stmt(+stmt: N111Stmt, +ids: N111Ids, +code: P111QCode) -> P111QCode:
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
