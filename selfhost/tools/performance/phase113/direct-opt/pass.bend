@unsafe
def p113i_table_function(+function: P113DFunction, +table: P113ITable) -> P113ITable:
  match function:
    case P113DFunction{+name,params,result,public,body}:
      nt_choose(P113ITable,p113i_eligible(function),
        u => p113i_put(table,function,index_hash(name,2166136261),0),u => table)

@unsafe
def p113i_function(+function: P113DFunction, +table: P113ITable) -> P113DFunction:
  match function:
    case P113DFunction{+name,+params,+result,+public,+body}:
      nt_choose(P113DFunction,public && U32.is_eq(result,1) && p113i_params(params) && p113i_clean(body) && U32.is_le(p113i_size(body),1024),
        u => p113i_function_done(function,name,params,result,public,p113i_scan(body,table,0,128)),u => function)

@unsafe
def p113i_function_done(+original: P113DFunction, +name: String, +params: List<&2,NC_Binding>, +result: U32, +public: Bool, scan: P113IScan) -> P113DFunction:
  match scan:
    case P113IScan{+body,next,budget}:
      nt_choose(P113DFunction,U32.is_le(p113i_stack(body),16384),
        u => P113DFunction{name,params,result,public,body},u => original)

@unsafe
def p113i_functions(functions: List<&2,P113DFunction>, +table: P113ITable, acc: List<&2,P113DFunction>) -> List<&2,P113DFunction>:
  match functions:
    case Nil{}: nt_reverse(P113DFunction,acc,[])
    case Con{+head,rest}: p113i_functions_step(head,rest,table,acc,p113i_function(head,table))

@unsafe
def p113i_functions_step(+original: P113DFunction, +rest: List<&2,P113DFunction>, +table: P113ITable, +acc: List<&2,P113DFunction>, +function: P113DFunction) -> List<&2,P113DFunction>:
  p113i_functions(rest,nt_choose(P113ITable,p113i_original_clean(original),
    u => p113i_table_function(function,table),u => table),Con{function,acc})

@unsafe
def p113i_admitted(program: P113DProgram) -> P113DProgram:
  match program:
    case P113DProgram{original,functions}: P113DProgram{original,p113i_functions(functions,P113IEmpty{},[])}

@unsafe
def p113i_verified(+original: P113DProgram, +candidate: P113DProgram) -> P113DProgram:
  nt_choose(P113DProgram,String.is_empty(p113d_verify(candidate)),u => candidate,u => original)

@unsafe
def p113i_optimize(+program: P113DProgram) -> P113DProgram:
  nt_choose(P113DProgram,String.is_empty(p113d_verify(program)),
    u => p113i_verified(program,p113i_admitted(program)),u => program)
