# Consume the checked semantic bodies retained by P169 preparation. Renderer
# fusion/legacy workers are optional here: public adapters already call p113d.
# No QBE text is parsed. A raw reference to an unavailable legacy worker fails
# the entire output, including references carried as symbol values or data.

@unsafe
def x181_program_symbol(+symbol: String, +available: KDef) -> String:
  nt_choose(String,String.starts_with(symbol,"p112w_"),
    u => nt_choose(String,String.eq(dk(p111v_get(available,symbol)),"X181Forward"),
      v => "",v => "x86 unavailable legacy worker: " ++ symbol),u => "")

@unsafe
def x181_program_value(value: N111Value, +available: KDef) -> String:
  match value:
    case N111Symbol{symbol}: x181_program_symbol(symbol,available)
    case _: ""

@unsafe
def x181_program_values(values: List<&2,N111Value>, +available: KDef) -> String:
  match values:
    case Nil{}: ""
    case Con{head,rest}: p111_first(x181_program_value(head,available),x181_program_values(rest,available))

@unsafe
def x181_program_args(args: List<&2,N111Arg>, +available: KDef) -> String:
  match args:
    case Nil{}: ""
    case Con{N111Arg{typ,value},rest}:
      p111_first(x181_program_value(value,available),x181_program_args(rest,available))

@unsafe
def x181_program_scalar(stmt: N111Stmt, +available: KDef) -> String:
  match stmt:
    case N111Set{name,typ,value}: x181_program_value(value,available)
    case N111Bin{name,typ,op,left,right}:
      p111_first(x181_program_value(left,available),x181_program_value(right,available))
    case N111Call{name,typ,symbol,args}:
      p111_first(x181_program_symbol(symbol,available),x181_program_args(args,available))
    case N111If{condition,yes,no}:
      p111_first(x181_program_value(condition,available),
        p111_first(x181_program_scalars(yes,available),x181_program_scalars(no,available)))
    case N111Return{value}: x181_program_value(value,available)
    case N111Load{name,typ,base,offset}: x181_program_value(base,available)
    case N111Store{typ,base,offset,value}:
      p111_first(x181_program_value(base,available),x181_program_value(value,available))
    case N111Offset{name,base,bytes}:
      p111_first(x181_program_value(base,available),x181_program_value(bytes,available))
    case N111Alloca{name,bytes,align}: ""

@unsafe
def x181_program_scalars(body: List<&2,N111Stmt>, +available: KDef) -> String:
  match body:
    case Nil{}: ""
    case Con{head,rest}: p111_first(x181_program_scalar(head,available),x181_program_scalars(rest,available))

@unsafe
def x181_program_stmt(stmt: P113DStmt, +available: KDef) -> String:
  match stmt:
    case P113DScalar{scalar}: x181_program_scalar(scalar,available)
    case P113DIf{condition,yes,no}:
      p111_first(x181_program_value(condition,available),
        p111_first(x181_program_stmts(yes,available),x181_program_stmts(no,available)))
    case P113DCall{destinations,target,args}: x181_program_values(args,available)
    case P113DResult{values}: x181_program_values(values,available)
    case P113DAgain{values}: x181_program_values(values,available)

@unsafe
def x181_program_stmts(body: List<&2,P113DStmt>, +available: KDef) -> String:
  match body:
    case Nil{}: ""
    case Con{head,rest}: p111_first(x181_program_stmt(head,available),x181_program_stmts(rest,available))

# Same import rule as p168j_forward_if. The extra signature check refuses a
# malformed cursor instead of selecting a different calling convention.
@unsafe
def x181_forward_selected(+name: String, +ready: KDef) -> Bool:
  +entry = p111v_get(ready,name)
  String.eq(dk(entry),"P112Worker") && U32.is_eq(dx(entry),0)

@unsafe
def x181_forward_index(functions: List<&2,P113DFunction>, +ready: KDef, +index: KDef) -> KDef:
  match functions:
    case Nil{}: index
    case Con{P113DFunction{+name,params,result,public,body},rest}:
      x181_forward_index(rest,ready,nt_choose(KDef,x181_forward_selected(name,ready),
        u => p111v_put(index,p112w_symbol(name),"X181Forward",nt_count(NC_Binding,params),result),u => index))

@unsafe
def x181_cursor_index(cursor: P134Cursor, index: KDef) -> KDef:
  match cursor:
    case P134Private{functions,P134Context{ids,fusion,direct,ready,view,lookups,heap,mode},next}:
      x181_cursor_index(next,x181_forward_index(functions,ready,index))
    case P134Legacy{entries,context,next}: x181_cursor_index(next,index)
    case P134Public{segments,context,next}: x181_cursor_index(next,index)
    case _: index

@unsafe
def x181_forward(+function: P113DFunction, +ready: KDef) -> X181Output:
  match function:
    case P113DFunction{+name,+params,+result,public,body}:
      nt_choose(X181Output,x181_forward_selected(name,ready),
        u => nt_choose(X181Output,U32.is_eq(result,1) &&
            U32.is_eq(da(p111v_get(ready,name)),nt_count(NC_Binding,params)),
          v => X181Output{[".text\n.type " ++ p112w_symbol(name) ++ ", @function\n" ++
            p112w_symbol(name) ++ ":\njmp " ++ p113e_symbol(name) ++ "\n.size " ++
            p112w_symbol(name) ++ ", .-" ++ p112w_symbol(name) ++ "\n"],""},
          v => X181Output{[],"x86 imported worker signature mismatch: " ++ name}),
        u => X181Output{[],""})

@unsafe
def x181_program_join(first: X181Output, second: X181Output) -> X181Output:
  match first second:
    case X181Output{a,ae} X181Output{b,be}: X181Output{nt_append(String,a,b),p111_first(ae,be)}

@unsafe
def x181_program_private(+function: P113DFunction, context: P134Context, +available: KDef) -> X181Output:
  match function context:
    case P113DFunction{name,params,result,public,body} P134Context{ids,index,direct,ready,view,lookups,heap,mode}:
      x181_program_join(X181Output{[],x181_program_stmts(body,available)},
        x181_program_join(x181_direct(function,ids),x181_forward(function,ready)))

@unsafe
def x181_program_public(+segment: N111Segment, context: P134Context, +available: KDef) -> X181Output:
  match segment context:
    case N111Segment{name,arity,result,incoming,flags,body} P134Context{ids,index,direct,ready,view,lookups,heap,mode}:
      x181_program_join(X181Output{[],x181_program_scalars(body,available)},x181_segment(segment,ids))

def x181_program_datum(datum: P111QDatum) -> String:
  match datum:
    case P111QByte{value}: ".byte " ++ U32.show(value) ++ "\n"
    case P111QWord{value}: ".long " ++ U32.show(value) ++ "\n"
    case P111QLong{lo,hi}: ".quad " ++ p111q_u64(lo,hi) ++ "\n"
    case P111QReloc{symbol,offset}: ".quad " ++ symbol ++ "+" ++ U32.show(offset) ++ "\n"
    case P111QZeros{bytes}: ".zero " ++ U32.show(bytes) ++ "\n"

@unsafe
def x181_program_data_items(items: List<&2,P111QDatum>, +available: KDef, acc: List<&2,String>) -> X181Output:
  match items:
    case Nil{}: X181Output{nt_reverse(String,acc,[]),""}
    case Con{+head,rest}:
      x181_program_data_item(head,rest,available,acc)

@unsafe
def x181_program_data_item(+item: P111QDatum, rest: List<&2,P111QDatum>, +available: KDef, acc: List<&2,String>) -> X181Output:
  match item:
    case P111QReloc{+symbol,offset}:
      nt_choose(X181Output,String.is_empty(x181_program_symbol(symbol,available)),
        u => x181_program_data_items(rest,available,Con{x181_program_datum(item),acc}),
        u => X181Output{[],x181_program_symbol(symbol,available)})
    case _: x181_program_data_items(rest,available,Con{x181_program_datum(item),acc})

@unsafe
def x181_program_data(data: P111QData, +available: KDef) -> X181Output:
  match data:
    case P111QData{+name,alignment,exported,items}:
      x181_program_join(X181Output{[".data\n.balign " ++ U32.show(alignment) ++ "\n" ++
        nt_choose(String,exported,u => ".globl " ++ name ++ "\n",u => "") ++
        ".type " ++ name ++ ", @object\n" ++ name ++ ":\n"],""},
        x181_program_join(x181_program_data_items(items,available,[]),
          X181Output{[".size " ++ name ++ ", .-" ++ name ++ "\n"],""}))

# Tail transfer preserves argc/argv and their normal SysV return address.
# The descriptor supplies all constructor identities, static words and effects.
def x181_program_main() -> String:
  ".text\n.globl main\n.type main, @function\nmain:\nleaq p111_program(%rip), %rdx\njmp p111_rt_main\n.size main, .-main\n"

def x181_program_note() -> String:
  ".section .note.GNU-stack,\"\",@progbits\n"

# Accumulation is reversed once. A refusal never exposes partial assembly.
@unsafe
def x181_program_piece(piece: X181Output, next: P134Cursor, available: KDef, acc: List<&2,String>) -> X181Output:
  match piece:
    case X181Output{chunks,+error}:
      nt_choose(X181Output,String.is_empty(error),
        u => x181_program_cursor(next,available,nt_reverse(String,chunks,acc)),
        u => X181Output{[],error})

@unsafe
def x181_program_cursor(cursor: P134Cursor, +available: KDef, acc: List<&2,String>) -> X181Output:
  match cursor:
    case P134Private{Nil{},context,next}: x181_program_cursor(next,available,acc)
    case P134Private{Con{head,rest},+context,next}:
      x181_program_piece(x181_program_private(head,context,available),P134Private{rest,context,next},available,acc)
    case P134Legacy{entries,context,next}: x181_program_cursor(next,available,acc)
    case P134Public{Nil{},context,next}: x181_program_cursor(next,available,acc)
    case P134Public{Con{head,rest},+context,next}:
      x181_program_piece(x181_program_public(head,context,available),P134Public{rest,context,next},available,acc)
    case P134Tables{Nil{}}: x181_program_cursor(P134Main{},available,acc)
    case P134Tables{Con{head,rest}}:
      x181_program_piece(x181_program_data(head,available),P134Tables{rest},available,acc)
    case P134Main{}: X181Output{nt_reverse(String,acc,[x181_program_main(),x181_program_note()]),""}
    case P134Data{items,first,rest}: X181Output{[],"x86 requires a complete data cursor"}
    case P134End{}: X181Output{[],"x86 cursor ended before program tables and entry"}

@unsafe
def x181_cursor(+cursor: P134Cursor) -> X181Output:
  x181_program_cursor(cursor,x181_cursor_index(cursor,missing()),[])

# P169Prepared is not a certificate. The owning frontend must construct it
# through the unchanged final admission path before invoking this renderer.
@unsafe
def x181_prepared(prepared: P169Prepared) -> X181Output:
  match prepared:
    case P169Prepared{forwarders,cursor,+error}:
      nt_choose(X181Output,String.is_empty(error),u => x181_cursor(cursor),u => X181Output{[],error})
