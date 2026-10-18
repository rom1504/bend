# Assemble separately emitted functions and ABI data. IDs use a Patricia index
# built once; emitting a reference never scans all previously emitted segments.
@unsafe
def p111q_insert(+tree: KDef, +name: String, id: U32) -> KDef:
  index_set(tree,KDef{name,"N111Id",id,0,atom("Absent"),atom("Absent"),[],False{},False{}},index_hash(name,2166136261),32)

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
    case Con{N_Constructor{name,arity,hot},rest}:
      p111q_constructor_ids(rest,U32.inc(next),p111q_insert(tree,name,next))

@unsafe
def p111q_ids(+program: P111Program) -> N111Ids:
  match program:
    case P111Program{segments,constructors,show,show_names,effects,pure}:
      N111Ids{p111q_function_ids(segments,0,missing()),p111q_constructor_ids(constructors,0,missing())}

@unsafe
def p111q_segment_chunks(segments: List<&2,N111Segment>, +ids: N111Ids, acc: List<&2,String>) -> List<&2,String>:
  match segments:
    case Nil{}: nt_reverse(String,acc,[])
    case Con{segment,rest}: p111q_segment_chunks(rest,ids,Con{p111q_segment(segment,ids),acc})

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
