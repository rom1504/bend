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
          v => X181Output{[x188_many([X188One{PSection{1}},X188One{PType{p112w_symbol(name),2}},
            x188_label(p112w_symbol(name)),x188_i1("jmp",X187Target{p113e_symbol(name)}),
            X188One{PSize{p112w_symbol(name)}}])],""},
          v => X181Output{[],"x86 imported worker signature mismatch: " ++ name}),
        u => X181Output{[],""})

@unsafe
def x181_program_join(first: X181Output, second: X181Output) -> X181Output:
  match first second:
    case X181Output{a,ae} X181Output{b,be}: X181Output{nt_append(X188Seq,a,b),p111_first(ae,be)}

# The shared cursor retains the original private bodies. Array templates were
# previously selected only by the QBE renderer. Reuse the existing structured
# admission, rewrite and setup factories under that same mode=2 certificate.
# Their fallback keeps the complete original runtime operation and ownership.
@unsafe
def x185_array_emit(function: P113DFunction, +symbol: String, +prelude: List<&2,N111Stmt>, +ids: N111Ids) -> X181Output:
  match function:
    case P113DFunction{name,+params,+result,public,body}:
      x185_function_setup(symbol,Con{"state",nt_choose(List<&2,String>,U32.is_eq(result,1),
        u => x181_param_names(params),u => Con{"__x181_result_out",x181_param_names(params)})},
        x181_scalar_rows(Con{N111Load{"p113a_heap_base",N111Ptr{},N111Local{"state"},0},prelude}),body,ids)

@unsafe
def x185_array_plain(+function: P113DFunction, ids: N111Ids, heap: U32) -> X181Output:
  match function:
    case P113DFunction{name,params,result,public,body}:
      x185_array_emit(p113a_function(function,heap),p113e_symbol(name),[],ids)

@unsafe
def x185_array_arguments(params: List<&2,NC_Binding>) -> List<&2,N111Arg>:
  match params:
    case Nil{}: []
    case Con{NC_Binding{id,word,kind},rest}:
      Con{N111Arg{N111U64{},N111Local{word}},x185_array_arguments(rest)}

# This call is only on the entry guard's false edge, before parameter mutation.
# Multiple results retain their incoming hidden output pointer and status.
@unsafe
def x185_array_dispatch(+name: String, +params: List<&2,NC_Binding>, +result: U32, +used: U32) -> List<&2,N111Stmt>:
  nt_append(N111Stmt,Con{N111Set{"p113a_version_guard",N111U32{},N111Const{1,0}},p117v_guard(params,1,used)},
    [N111If{N111Local{"p113a_version_guard"},[],[
      N111Call{"__x181_fallback",N111U64{},"p117v_" ++ nt_fid(name),
        Con{p111_state(),nt_choose(List<&2,N111Arg>,U32.is_eq(result,1),
          u => x185_array_arguments(params),
          u => Con{N111Arg{N111Ptr{},N111Local{"__x181_result_out"}},x185_array_arguments(params)})}},
      N111Return{N111Local{"__x181_fallback"}}]}])

@unsafe
def x185_array_version(+function: P113DFunction, +ids: N111Ids, +heap: U32, +used: U32, sites: KDef) -> X181Output:
  match function:
    case P113DFunction{+name,+params,+result,public,body}:
      x181_program_join(x185_array_emit(p113a_function(function,heap),"p117v_" ++ nt_fid(name),[],ids),
        x185_array_emit(p113a_function_done(name,params,result,public,p117v_rewrite(body,0,heap,used,sites)),
          p113e_symbol(name),nt_append(N111Stmt,p117h_prelude(params,1,used,heap),
            x185_array_dispatch(name,params,result,used)),ids))

@unsafe
def x185_array_scanned(+function: P113DFunction, +ids: N111Ids, +heap: U32, scan: P117HScan) -> X181Output:
  match function scan:
    case P113DFunction{+name,+params,result,public,+body} P117HScan{facts,slots,+mask,+used,+again,left,+next,+sites}:
      +used = U32.and(mask,used)
      nt_choose(X181Output,again && U32.is_gt(used,0) && U32.is_gt(next,0) &&
          U32.is_le(p113i_size(body),1024) && p117v_all(sites,next,used,0),
        u => x185_array_version(function,ids,heap,used,sites),
        u => nt_choose(X181Output,again && U32.is_gt(used,0),
          v => x185_array_emit(p113a_function_done(name,params,result,public,p117h_rewrite(body,0,heap,used,sites)),
            p113e_symbol(name),p117h_prelude(params,1,used,heap),ids),
          v => x185_array_plain(function,ids,heap)))

@unsafe
def x185_array_selected(+function: P113DFunction, +ids: N111Ids, +heap: U32) -> X181Output:
  match function:
    case P113DFunction{name,+params,result,public,+body}:
      +count = nt_count(NC_Binding,params)
      nt_choose(X181Output,U32.is_gt(count,16) || Bool.not(p117h_params_clean(params)),
        u => x185_array_plain(function,ids,heap),
        u => x185_array_scanned(function,ids,heap,p117h_walk(body,count,
          P117HScan{p117h_seed(params,1,missing()),missing(),U32.sub(U32.shln(1,U32.to_nat(count)),1),0,False{},8192,0,missing()})))

@unsafe
def x185_array_function(+function: P113DFunction, +ids: N111Ids, +heap: U32, +mode: U32) -> X181Output:
  match function:
    case P113DFunction{name,+params,result,public,+body}:
      +error = p111_first(x181_hygiene_names(x181_param_names(params)),x181_hygiene_stmts(body))
      nt_choose(X181Output,Bool.not(String.is_empty(error)),u => X181Output{[],error},u =>
        nt_choose(X181Output,U32.is_eq(mode,2) && U32.is_gt(p113a_count_body(body,0),0) &&
          p113a_params(params) && p113a_body_names(body),
          v => x185_array_selected(function,ids,heap),v => x181_direct(function,ids)))

@unsafe
def x181_program_private(+function: P113DFunction, context: P134Context, +available: KDef) -> X181Output:
  match function context:
    case P113DFunction{name,params,result,public,body} P134Context{ids,index,direct,ready,view,lookups,heap,mode}:
      x181_program_join(X181Output{[],x181_program_stmts(body,available)},
        x181_program_join(x185_array_function(function,ids,heap,mode),x181_forward(function,ready)))

@unsafe
def x181_program_public(+segment: N111Segment, context: P134Context, +available: KDef) -> X181Output:
  match segment context:
    case N111Segment{+name,arity,result,incoming,flags,body} P134Context{+ids,index,+direct,ready,view,lookups,heap,mode}:
      +function = p111v_get(direct,name)
      x181_program_join(X181Output{[],x181_program_scalars(body,available)},
        nt_choose(X181Output,Bool.not(U32.is_eq(mode,0)) &&
          Bool.not(String.eq(dk(function),"P113Direct") && U32.is_eq(ix(dv(function)),1)),
          u => x193f_public(segment,index,ids,ready,available),u => x181_segment(segment,ids)))


def x181_program_datum(datum: P111QDatum) -> X188Seq:
  X188One{PDatum{datum}}

# Both output consumers share the complete typed table interface.
def x188_table_head(+name: String, alignment: U32, exported: Bool) -> X188Seq:
  x188_many([X188One{PSection{3}},X188One{PAlign{alignment}},
    nt_choose(X188Seq,exported,u => X188One{PGlobal{name}},u => X188Empty{}),
    X188One{PType{name,1}},x188_label(name)])

@unsafe
def x181_program_data_items(items: List<&2,P111QDatum>, +available: KDef, acc: List<&2,X188Seq>) -> X181Output:
  match items:
    case Nil{}: X181Output{nt_reverse(X188Seq,acc,[]),""}
    case Con{+head,rest}:
      x181_program_data_item(head,rest,available,acc)

@unsafe
def x181_program_data_item(+item: P111QDatum, rest: List<&2,P111QDatum>, +available: KDef, acc: List<&2,X188Seq>) -> X181Output:
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
      x181_program_join(X181Output{[x188_table_head(name,alignment,exported)],""},
        x181_program_join(x181_program_data_items(items,available,[]),
          X181Output{[X188One{PSize{name}}],""}))

# Tail transfer preserves argc/argv and their normal SysV return address.
# The descriptor supplies all constructor identities, static words and effects.
def x181_program_main() -> X188Seq:
  x188_many([X188One{PSection{1}},X188One{PGlobal{"main"}},X188One{PType{"main",2}},
    x188_label("main"),x188_i2("leaq",X187Rip{"p111_program",0,0},x188_reg(2,64)),
    x188_i1("jmp",X187Target{"p111_rt_main"}),X188One{PSize{"main"}}])

def x181_program_note() -> X188Seq:
  X188One{PSection{4}}

# Accumulation is reversed once. A refusal never exposes partial assembly.
@unsafe
def x181_program_piece(piece: X181Output, next: P134Cursor, available: KDef, acc: List<&2,X188Seq>) -> X181Output:
  match piece:
    case X181Output{chunks,+error}:
      nt_choose(X181Output,String.is_empty(error),
        u => x181_program_cursor(next,available,nt_reverse(X188Seq,chunks,acc)),
        u => X181Output{[],error})

@unsafe
def x181_program_cursor(cursor: P134Cursor, +available: KDef, acc: List<&2,X188Seq>) -> X181Output:
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
    case P134Main{}: X181Output{nt_reverse(X188Seq,acc,[x181_program_main(),x181_program_note()]),""}
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
