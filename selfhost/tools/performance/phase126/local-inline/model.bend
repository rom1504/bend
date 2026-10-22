# Emission-only catalogue derived from the final verified function bodies.
# Its entries contain no supplied certificate or separately evaluated values.
type P126ITable is Data:
  P126ITable{+name: String, +last: U32}

type P126ICtx is Data:
  P126ICtx{+params: List<&2,NC_Binding>, +buffers: List<&2,String>, +ids: N111Ids, +tables: List<&2,P126ITable>}

@unsafe
def p126i_lookup(tables: List<&2,P126ITable>, +name: String) -> Maybe<&2,U32>:
  match tables:
    case Nil{}: None{}
    case Con{P126ITable{key,last},rest}:
      nt_choose(Maybe<&2,U32>,String.eq(key,name),u => Some{last},u => p126i_lookup(rest,name))

@unsafe
def p126i_cells(+name: String, cells: Maybe<&2,List<&2,U32>>, +acc: List<&2,P126ITable>) -> List<&2,P126ITable>:
  match cells:
    case None{}: acc
    case Some{values}:
      +count = nt_count(U32,values)
      nt_choose(List<&2,P126ITable>,U32.is_ge(count,4),
        u => Con{P126ITable{name,U32.sub(count,1)},acc},u => acc)

@unsafe
def p126i_add(function: P113DFunction, +acc: List<&2,P126ITable>) -> List<&2,P126ITable>:
  match function:
    case P113DFunction{name,[NC_Binding{id,+word,kind}],result,public,body}:
      nt_choose(List<&2,P126ITable>,U32.is_eq(result,1),
        u => p126i_cells(name,p126s_cells(word,body,0),acc),u => acc)
    case _: acc

@unsafe
def p126i_catalogue(functions: List<&2,P113DFunction>, acc: List<&2,P126ITable>) -> List<&2,P126ITable>:
  match functions:
    case Nil{}: nt_reverse(P126ITable,acc,[])
    case Con{head,rest}: p126i_catalogue(rest,p126i_add(head,acc))

@unsafe
def p126i_present(found: Maybe<&2,U32>) -> Bool:
  match found:
    case Some{last}: True{}
    case None{}: False{}

@unsafe
def p126i_recognized(names: List<&2,String>, target: String, values: List<&2,N111Value>, tables: List<&2,P126ITable>) -> Bool:
  match names values:
    case [name] [value]: p126i_present(p126i_lookup(tables,target))
    case _ _: False{}

@unsafe
def p126i_calls_walk(body: List<&2,P113DStmt>, +pending: List<&2,List<&2,P113DStmt>>, +tables: List<&2,P126ITable>) -> Bool:
  match body pending:
    case Nil{} Nil{}: False{}
    case Nil{} Con{more,rest}: p126i_calls_walk(more,rest,tables)
    case Con{P113DCall{names,target,values},rest} _:
      nt_choose(Bool,p126i_recognized(names,target,values,tables),
        u => True{},u => p126i_calls_walk(rest,pending,tables))
    case Con{P113DIf{condition,yes,no},rest} _:
      p126i_calls_walk(yes,Con{no,Con{rest,pending}},tables)
    case Con{stmt,rest} _: p126i_calls_walk(rest,pending,tables)

@unsafe
def p126i_calls(body: List<&2,P113DStmt>, tables: List<&2,P126ITable>) -> Bool:
  p126i_calls_walk(body,[],tables)
