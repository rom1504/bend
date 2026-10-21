# Additive descriptor capability2 selects the existing packed scalar runtime.
# Only p113a_enabled_chunks reaches this hook, after checked scalar/unshared
# admission and the unchanged complete IR verifier. Old fallback stays uniform.
@unsafe
def p117p_items(items: List<&2,P111QDatum>, +index: U32, acc: List<&2,P111QDatum>) -> List<&2,P111QDatum>:
  match items:
    case Nil{}: nt_reverse(P111QDatum,acc,[])
    case Con{head,rest}: p117p_items(rest,U32.inc(index),Con{nt_choose(P111QDatum,U32.is_eq(index,11),u => P111QLong{3,0},u => head),acc})

@unsafe
def p117p_table(data: P111QData) -> P111QData:
  match data:
    case P111QData{+name,alignment,exported,items}:
      P111QData{name,alignment,exported,nt_choose(List<&2,P111QDatum>,String.eq(name,"p111_program"),u => p117p_items(items,0,[]),u => items)}

@unsafe
def p117p_tables(tables: List<&2,P111QData>, acc: List<&2,P111QData>) -> List<&2,P111QData>:
  match tables:
    case Nil{}: nt_reverse(P111QData,acc,[])
    case Con{head,rest}: p117p_tables(rest,Con{p117p_table(head),acc})

@unsafe
def p113a_bundle_chunks(+program: P111Program, +nodes: List<&2,P112SNode>, functions: List<&2,P113DFunction>) -> List<&2,String>:
  match program:
    case P111Program{+segments,constructors,show,names,effects,pure}:
      +ids = p111q_ids(program)
      nt_append(String,p113a_segment_chunks(segments,functions,ids,p113a_heap_min(nodes),p112f_index(segments)),
        nt_append(String,p111q_data_chunks(p117p_tables(nt_choose(List<&2,P111QData>,List.is_empty(&2,P112SNode,nodes),
          u => p111q_tables(program,ids),u => p112s_tables(program,nodes,ids)),[])),[p111q_main()]))

@unsafe
def p117p_address(+id: U32, +n: U32) -> List<&2,N111Stmt>:
  nt_append(N111Stmt,p113a_class(n),nt_append(N111Stmt,[
    N111Bin{p113a_name(n,"mask"),N111U64{},"sub",p113a_value(n,"size"),N111Const{1,0}},
    N111Bin{p113a_name(n,"index"),N111U64{},"and",p113a_value(n,"index"),p113a_value(n,"mask")},
    N111Bin{p113a_name(n,"base_bytes"),N111U64{},"shl",p113a_value(n,"location"),N111Const{3,0}},
    N111Bin{p113a_name(n,"index_bytes"),N111U64{},"shl",p113a_value(n,"index"),N111Const{2,0}},
    N111Bin{p113a_name(n,"bytes"),N111U64{},"add",p113a_value(n,"base_bytes"),p113a_value(n,"index_bytes")},
    N111Offset{p113a_name(n,"cell"),N111Local{"p113a_heap_base"},p113a_value(n,"bytes")}],
    nt_choose(List<&2,N111Stmt>,U32.is_eq(id,73),u => [],
      u => [N111Load{p113a_name(n,"old"),N111U32{},p113a_value(n,"cell"),0}])))

@unsafe
def p113a_success(+id: U32, +destination: String, +output: N111Value, +n: U32) -> List<&2,N111Stmt>:
  nt_choose(List<&2,N111Stmt>,U32.is_eq(id,72),
    u => p113a_pair_store(destination,output,p113a_value(n,"old"),n),u =>
    nt_append(N111Stmt,[N111Store{N111U32{},p113a_value(n,"cell"),0,p113a_value(n,"new")}],
      nt_choose(List<&2,N111Stmt>,U32.is_eq(id,73),
        v => [N111Set{destination,N111U64{},p113a_value(n,"array")}],
        v => p113a_pair_store(destination,output,p113a_value(n,"old"),n))))

@unsafe
def p113a_raw(+id: U32, +destination: String, +output: N111Value, +original: N111Stmt, +n: U32) -> List<&2,N111Stmt>:
  nt_choose(List<&2,N111Stmt>,U32.is_eq(id,75),
    u => nt_append(N111Stmt,p113a_class(n),p113a_pair_store(destination,output,p113a_value(n,"size"),n)),
    u => nt_append(N111Stmt,p117p_address(id,n),p113a_success(id,destination,output,n)))

@unsafe
def p113a_template(+original: N111Stmt, +n: U32, +heap_min: U32) -> List<&2,N111Stmt>:
  match original:
    case N111Call{+destination,N111U64{},+symbol,+args}:
      +id = p113a_call_id(symbol,args)
      nt_choose(List<&2,N111Stmt>,U32.is_eq(id,0),u => [original],u =>
        nt_append(N111Stmt,p113a_inputs(id,p111v_arg(args,2),n),[
          N111Bin{p113a_name(n,"tag"),N111U64{},"shr",p113a_value(n,"array"),N111Const{56,0}},
          N111Bin{p113a_name(n,"raw"),N111U64{},"eq",p113a_value(n,"tag"),N111Const{4,0}},
          N111Bin{p113a_name(n,"location"),N111U64{},"and",p113a_value(n,"array"),N111Const{4294967295,255}},
          N111Bin{p113a_name(n,"dynamic"),N111U64{},"uge",p113a_value(n,"location"),N111Const{heap_min,0}},
          N111Bin{p113a_name(n,"admitted"),N111U32{},"and",p113a_value(n,"raw"),p113a_value(n,"dynamic")},
          N111If{p113a_value(n,"admitted"),p113a_raw(id,destination,p111v_arg(args,4),original,n),[original]}]))
    case _: [original]

# Explicit unsigned loads establish the full Term value before64-bit use.
# QBE permits a long temporary in word contexts; high bits are now defined0.
@unsafe
def p111q_memory(+name: String, +typ: N111Type, +base: N111Value, +offset: U32, +value: N111Value, +store: Bool, +ids: N111Ids, +code: P111QCode) -> P111QCode:
  match code:
    case P111QCode{chunks,n,terminal,error}:
      +at = nt_choose(String,U32.is_eq(offset,0),u => p111q_value(base,ids),u => p111q_tmp(n))
      +prefix = nt_choose(List<&2,String>,U32.is_eq(offset,0),u => chunks,u =>
        Con{at ++ " =l add " ++ p111q_value(base,ids) ++ ", " ++ U32.show(offset) ++ "\n",chunks})
      +line = nt_choose(String,store,
        u => "store" ++ p111q_type(typ) ++ " " ++ p111q_value(value,ids) ++ ", " ++ at ++ "\n",
        u => p111q_local(name) ++ nt_choose(String,String.eq(p111q_type(typ),"w"),
          v => " =l loaduw ",v => " =" ++ p111q_type(typ) ++ " load" ++ p111q_type(typ) ++ " ") ++ at ++ "\n")
      P111QCode{Con{line,prefix},nt_choose(U32,U32.is_eq(offset,0),u => n,u => U32.inc(n)),terminal,error}
