
@unsafe
def p111q_div10(+lo: U32, +hi: U32) -> P111QDecimal:
  +a = U32.shrn(hi,16n)
  +b = U32.add(U32.mul(U32.mod(a,10),65536),U32.and(hi,65535))
  +c = U32.add(U32.mul(U32.mod(b,10),65536),U32.shrn(lo,16n))
  +d = U32.add(U32.mul(U32.mod(c,10),65536),U32.and(lo,65535))
  P111QDecimal{U32.add(U32.mul(U32.div(c,10),65536),U32.div(d,10)),
    U32.add(U32.mul(U32.div(a,10),65536),U32.div(b,10)),U32.mod(d,10)}

@unsafe
def p111q_decimal_step(+value: P111QDecimal, acc: String) -> String:
  match value:
    case P111QDecimal{lo,hi,digit}:
      p111q_decimal_go(lo,hi,SCon{Char.from_u32(U32.add(48,digit)),acc})

@unsafe
def p111q_decimal_go(+lo: U32, +hi: U32, +acc: String) -> String:
  nt_choose(String,U32.is_eq(lo,0) && U32.is_eq(hi,0),u => acc,
    u => p111q_decimal_step(p111q_div10(lo,hi),acc))

@unsafe
def p111q_u64(+lo: U32, +hi: U32) -> String:
  nt_choose(String,U32.is_eq(hi,0),u => U32.show(lo),u => p111q_decimal_go(lo,hi,""))

@unsafe
def p111q_datum(+datum: P111QDatum) -> String:
  match datum:
    case P111QByte{value}: "b " ++ U32.show(value)
    case P111QWord{value}: "w " ++ U32.show(value)
    case P111QLong{lo,hi}: "l " ++ p111q_u64(lo,hi)
    case P111QReloc{symbol,offset}:
      "l $" ++ symbol ++ nt_choose(String,U32.is_eq(offset,0),u => "",u => " + " ++ U32.show(offset))
    case P111QZeros{bytes}: "z " ++ U32.show(bytes)

@unsafe
def p111q_data_items(+items: List<&2,P111QDatum>, +first: Bool, acc: List<&2,String>) -> List<&2,String>:
  match items:
    case Nil{}: acc
    case Con{head,rest}:
      p111q_data_items(rest,False{},Con{p111q_datum(head),Con{nt_choose(String,first,u => "",u => ", "),acc}})

@unsafe
def p111q_data(+data: P111QData) -> String:
  match data:
    case P111QData{name,alignment,exported,items}:
      nt_choose(String,exported,u => "export ",u => "") ++ "data $" ++ name ++ " = align " ++ U32.show(alignment) ++ " { " ++
      nt_text_finish(p111q_data_items(items,True{},[])," }\n")

@unsafe
def p111q_data_chunks_go(items: List<&2,P111QData>, acc: List<&2,String>) -> List<&2,String>:
  match items:
    case Nil{}: nt_reverse(String,acc,[])
    case Con{head,rest}: p111q_data_chunks_go(rest,Con{p111q_data(head),acc})

@unsafe
def p111q_data_chunks(items: List<&2,P111QData>) -> List<&2,String>:
  p111q_data_chunks_go(p118c_tables(items),[])

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
def p111q_args(args: List<&2,N111Arg>, +ids: N111Ids, +first: Bool, chunks: List<&2,String>) -> List<&2,String>:
  match args:
    case Nil{}: chunks
    case Con{N111Arg{typ,value},rest}:
      p111q_args(rest,ids,False{},Con{p111q_type(typ) ++ " " ++ p111q_value(value,ids),
        Con{nt_choose(String,first,u => "",u => ", "),chunks}})

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
      nt_choose(P111QCode,String.eq(error,""),u =>
        nt_choose(P111QCode,terminal,u => p111q_problem("statement follows terminal instruction",code),u =>
          p111q_stmts(rest,ids,p111q_stmt(stmt,ids,code))),u => code)

@unsafe
def p111q_stmt(+stmt: N111Stmt, +ids: N111Ids, +code: P111QCode) -> P111QCode:
  match code:
    case P111QCode{chunks,next,terminal,error}:
      nt_choose(P111QCode,Bool.not(terminal) && String.is_empty(error),
        u => p128bf_selected(stmt,p128bf_match(stmt,ids,next),ids,code),u => p128bf_previous(stmt,ids,code))

def p111q_return(value: String, code: P111QCode) -> P111QCode:
  match code:
    case P111QCode{chunks,n,terminal,error}: P111QCode{Con{"ret " ++ value ++ "\n",chunks},n,True{},error}

@unsafe
def p111q_memory(+name: String, +typ: N111Type, +base: N111Value, +offset: U32, +value: N111Value, +store: Bool, +ids: N111Ids, code: P111QCode) -> P111QCode:
  match code:
    case P111QCode{chunks,n,terminal,error}:
      +at = nt_choose(String,U32.is_eq(offset,0),u => p111q_value(base,ids),u => p111q_tmp(n))
      +prefix = nt_choose(List<&2,String>,U32.is_eq(offset,0),u => chunks,u =>
        Con{"\n",Con{U32.show(offset),Con{", ",Con{p111q_value(base,ids),Con{" =l add ",Con{at,chunks}}}}}})
      +parts = nt_choose(List<&2,String>,store,
        u => Con{"\n",Con{at,Con{", ",Con{p111q_value(value,ids),Con{" ",Con{p111q_type(typ),Con{"store",prefix}}}}}}},
        u => Con{"\n",Con{at,Con{nt_choose(String,String.eq(p111q_type(typ),"w"),
          v => " =l loaduw ",v => " =" ++ p111q_type(typ) ++ " load" ++ p111q_type(typ) ++ " "),Con{p111q_local(name),prefix}}}})
      P111QCode{parts,nt_choose(U32,U32.is_eq(offset,0),u => n,u => U32.inc(n)),terminal,error}

@unsafe
def p111q_if(+condition: N111Value, +yes: List<&2,N111Stmt>, +no: List<&2,N111Stmt>, +ids: N111Ids, +code: P111QCode) -> P111QCode:
  +diamond = p113bq_scalar(yes,no)
  nt_choose(P111QCode,p113bq_ready(diamond,code),u => p113bq_emit(condition,diamond,ids,code),
    u => p113bq_scalar_original(condition,yes,no,ids,code))

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
      nt_choose(String,String.eq(error,""),u =>
        nt_choose(String,terminal,u => nt_text_finish(chunks,""),u => "INVALID_N111_FALLTHROUGH\n"),u => "INVALID_N111_BODY\n")

@unsafe
def p111q_segment(+segment: N111Segment, +ids: N111Ids) -> String:
  match segment:
    case N111Segment{name,arity,result,incoming,flags,body}:
      "export function l $" ++ p111q_symbol(name) ++ "(l %state) {\n@entry\n" ++
      p144e_body_tail(p111q_stmts(body,ids,P111QCode{p111q_allocas(body,[]),0,False{},""}),"}\n")


# Phase111 module: selfhost/tools/performance/phase111/qbe/program.bend
# Assemble separately emitted functions and ABI data. IDs use a Patricia index
# built once; emitting a reference never scans all previously emitted segments.

@unsafe
def p111q_insert(+tree: KDef, +name: String, id: U32) -> KDef:
  index_set(tree,KDef{name,"N111Id",id,0,{KTerm{"Absent", "", 0, 0, Nil{}, Nil{}, 0, 0} : KTerm},{KTerm{"Absent", "", 0, 0, Nil{}, Nil{}, 0, 0} : KTerm},[],False{},False{}},index_hash(name,2166136261),32)

@unsafe
def p111q_function_ids(segments: List<&2,N111Segment>, +next: U32, tree: KDef) -> KDef:
  match segments:
    case Nil{}: tree
    case Con{N111Segment{name,arity,result,incoming,flags,body},rest}:
      p111q_function_ids(rest,U32.inc(next),p111q_insert(tree,name,next))

@unsafe
def p111q_constructor_ids(constructors: List<&2,N_Constructor>, +next: U32, tree: KDef) -> KDef:
  match constructors:
    case Nil{}: tree
    case Con{N_Constructor{+name,arity,hot},rest}:
      p111q_constructor_ids(rest,U32.inc(next),
        index_set(tree,KDef{name,"N111Id",next,arity,{KTerm{"Absent", "", 0, 0, Nil{}, Nil{}, 0, 0} : KTerm},{KTerm{"Absent", "", 0, 0, Nil{}, Nil{}, 0, 0} : KTerm},[],False{},False{}},
          index_hash(name,2166136261),32))

@unsafe
def p111q_ids(+program: P111Program) -> N111Ids:
  match program:
    case P111Program{segments,constructors,show,show_names,effects,pure}:
      N111Ids{p111q_function_ids(segments,0,missing()),p111q_constructor_ids(constructors,0,missing())}

@unsafe
def p111q_segment_chunks(+segments: List<&2,N111Segment>, +ids: N111Ids, +acc: List<&2,String>) -> List<&2,String>:
  p112c_segment_chunks(segments,ids,acc)

@unsafe
def p111q_segment_table(segments: List<&2,N111Segment>, +kind: U32, acc: List<&2,P111QDatum>) -> List<&2,P111QDatum>:
  match segments:
    case Nil{}: p111q_nonempty(nt_reverse(P111QDatum,acc,[]))
    case Con{N111Segment{name,arity,result,incoming,flags,body},rest}:
      p111q_segment_table(rest,kind,Con{p111q_segment_datum(name,arity,incoming,flags,kind),acc})

@unsafe
def p111q_segment_datum(name: String, arity: U32, incoming: U32, flags: U32, kind: U32) -> P111QDatum:
  match kind:
    case 0: P111QReloc{p111q_symbol(name),0}
    case 1: P111QByte{arity}
    case 2: P111QByte{flags}
    case _: P111QByte{incoming}

@unsafe
def p111q_ctor_table(constructors: List<&2,N_Constructor>, +hot_table: Bool, acc: List<&2,P111QDatum>) -> List<&2,P111QDatum>:
  match constructors:
    case Nil{}: p111q_nonempty(nt_reverse(P111QDatum,acc,[]))
    case Con{N_Constructor{name,arity,hot},rest}:
      p111q_ctor_table(rest,hot_table,Con{P111QByte{nt_choose(U32,hot_table,u => nt_bool(hot),u => arity)},acc})

@unsafe
def p111q_ctor_names_go(constructors: List<&2,N_Constructor>, acc: List<&2,String>) -> List<&2,String>:
  match constructors:
    case Nil{}: nt_reverse(String,acc,[])
    case Con{N_Constructor{name,arity,hot},rest}: p111q_ctor_names_go(rest,Con{name,acc})

@unsafe
def p111q_ctor_names(constructors: List<&2,N_Constructor>) -> List<&2,String>:
  p111q_ctor_names_go(constructors,[])

def p111q_nonempty(items: List<&2,P111QDatum>) -> List<&2,P111QDatum>:
  match items:
    case Nil{}: [P111QByte{0}]
    case Con{head,rest}: Con{head,rest}

@unsafe
def p111q_words_go(items: List<&2,U32>, acc: List<&2,P111QDatum>) -> List<&2,P111QDatum>:
  match items:
    case Nil{}: nt_reverse(P111QDatum,acc,[])
    case Con{head,rest}: p111q_words_go(rest,Con{P111QWord{head},acc})

@unsafe
def p111q_words(items: List<&2,U32>) -> List<&2,P111QDatum>:
  p111q_words_go(items,[])

# Strings are UTF-8 bytes with explicit trailing zero, independently of the
# host C source encoding, linker escaping, or JavaScript number representation.
@unsafe
def p111q_utf8_char(+code: U32, +acc: List<&2,P111QDatum>) -> List<&2,P111QDatum>:
  nt_choose(List<&2,P111QDatum>,U32.is_lt(code,128),u => Con{P111QByte{code},acc},u =>
    nt_choose(List<&2,P111QDatum>,U32.is_lt(code,2048),u =>
      Con{P111QByte{U32.add(128,U32.and(code,63))},Con{P111QByte{U32.add(192,U32.shrn(code,6n))},acc}},u =>
      nt_choose(List<&2,P111QDatum>,U32.is_lt(code,65536),u =>
        Con{P111QByte{U32.add(128,U32.and(code,63))},Con{P111QByte{U32.add(128,U32.and(U32.shrn(code,6n),63))},Con{P111QByte{U32.add(224,U32.shrn(code,12n))},acc}}},u =>
        Con{P111QByte{U32.add(128,U32.and(code,63))},Con{P111QByte{U32.add(128,U32.and(U32.shrn(code,6n),63))},Con{P111QByte{U32.add(128,U32.and(U32.shrn(code,12n),63))},Con{P111QByte{U32.add(240,U32.shrn(code,18n))},acc}}}})))

@unsafe
def p111q_utf8(text: String, acc: List<&2,P111QDatum>) -> List<&2,P111QDatum>:
  match text:
    case SNil{}: nt_reverse(P111QDatum,acc,[P111QByte{0}])
    case SCon{head,rest}: p111q_utf8(rest,p111q_utf8_char(Char.to_u32(head),acc))

@unsafe
def p111q_string_refs(names: List<&2,String>, +prefix: String, +index: U32, acc: List<&2,P111QDatum>) -> List<&2,P111QDatum>:
  match names:
    case Nil{}: p111q_nonempty(nt_reverse(P111QDatum,acc,[]))
    case Con{name,rest}:
      p111q_string_refs(rest,prefix,U32.inc(index),Con{P111QReloc{prefix ++ "_" ++ U32.show(index),0},acc})

@unsafe
def p111q_string_defs(names: List<&2,String>, +prefix: String, +index: U32, acc: List<&2,P111QData>) -> List<&2,P111QData>:
  match names:
    case Nil{}: nt_reverse(P111QData,acc,[])
    case Con{name,rest}:
      p111q_string_defs(rest,prefix,U32.inc(index),Con{P111QData{prefix ++ "_" ++ U32.show(index),1,False{},p111q_utf8(name,[])},acc})

@unsafe
def p111q_strings(+names: List<&2,String>, +prefix: String) -> List<&2,P111QData>:
  Con{P111QData{prefix,8,False{},p111q_string_refs(names,prefix,0,[])},p111q_string_defs(names,prefix,0,[])}

@unsafe
def p111q_width(segments: List<&2,N111Segment>, +results_only: Bool, +acc: U32) -> U32:
  match segments:
    case Nil{}: acc
    case Con{N111Segment{name,arity,result,incoming,flags,body},rest}:
      p111q_width(rest,results_only,nb_max(acc,nt_choose(U32,results_only,u => result,u => nb_max(arity,result))))

@unsafe
def p111q_main_id(ids: N111Ids) -> U32:
  match ids:
    case N111Ids{functions,constructors}: da(index_find(functions,"main",index_hash("main",2166136261),32))

@unsafe
def p111q_descriptor(+program: P111Program, ids: N111Ids) -> P111QData:
  match program:
    case P111Program{segments,constructors,show,show_names,effects,pure}:
      P111QData{"p111_program",8,True{},[
        P111QLong{11101,0},P111QLong{192,0},
        P111QLong{nt_count(N111Segment,segments),0},P111QLong{nt_count(N_Constructor,constructors),0},
        P111QLong{p111q_main_id(ids),0},P111QLong{nt_bool(pure),0},
        P111QLong{p111q_width(segments,False{},2),0},P111QLong{p111q_width(segments,True{},1),0},
        P111QLong{0,0},P111QLong{nt_count(U32,show),0},P111QLong{nt_count(String,show_names),0},P111QLong{1,0},
        P111QReloc{"p111_segments",0},P111QReloc{"p111_fid_arity",0},P111QReloc{"p111_fid_flags",0},P111QReloc{"p111_fid_results",0},
        P111QReloc{"p111_cid_arity",0},P111QReloc{"p111_cid_hot",0},P111QReloc{"p111_cid_names",0},P111QLong{0,0},
        P111QReloc{"p111_show_desc",0},P111QReloc{"p111_show_names",0},P111QLong{nt_count(String,effects),0},P111QReloc{"p111_effects",0}]}

@unsafe
def p111q_tables(+program: P111Program, +ids: N111Ids) -> List<&2,P111QData>:
  match program:
    case P111Program{segments,constructors,show,show_names,effects,pure}:
      nt_append(P111QData,[
        P111QData{"p111_segments",8,False{},p111q_segment_table(segments,0,[])},
        P111QData{"p111_fid_arity",1,False{},p111q_segment_table(segments,1,[])},
        P111QData{"p111_fid_flags",1,False{},p111q_segment_table(segments,2,[])},
        P111QData{"p111_fid_results",1,False{},p111q_segment_table(segments,3,[])},
        P111QData{"p111_cid_arity",1,False{},p111q_ctor_table(constructors,False{},[])},
        P111QData{"p111_cid_hot",1,False{},p111q_ctor_table(constructors,True{},[])},
        P111QData{"p111_show_desc",4,False{},p111q_nonempty(p111q_words(show))},
        p111q_descriptor(program,ids)],
        nt_append(P111QData,p111q_strings(p111q_ctor_names(constructors),"p111_cid_names"),
          nt_append(P111QData,p111q_strings(show_names,"p111_show_names"),p111q_strings(effects,"p111_effects"))))

def p111q_main() -> String:
  "export function w $main(w %argc, l %argv) {\n@entry\n%result =w call $p111_rt_main(w %argc, l %argv, l $p111_program)\nret %result\n}\n"

# The caller must first run p111_verify_program. Keeping emission separate from
# admission permits reuse of already validated IR without redundant tree walks.
@unsafe
def p111q_chunks(+program: P111Program) -> List<&2,String>:
  p111q_chunks_indexed(program,p111q_ids(program))

@unsafe
def p111q_chunks_indexed(+program: P111Program, +ids: N111Ids) -> List<&2,String>:
  match program:
    case P111Program{segments,constructors,show,show_names,effects,pure}:
      nt_append(String,p111q_segment_chunks(segments,ids,[]),nt_append(String,p111q_data_chunks(p111q_tables(program,ids)),[p111q_main()]))

@unsafe
def p111q_text(program: P111Program) -> String:
  nt_text_finish(nt_reverse(String,p111q_chunks(program),[]),"")
