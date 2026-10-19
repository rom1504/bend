# Typed immutable-image adapter over the selected Phase111 QBE emitter.
# Admission requires p112s_verify; this never parses C or generated QBE text.
def p112s_datum(value: N111Value) -> P111QDatum:
  match value:
    case N111Const{lo,hi}: P111QLong{lo,hi}
    case _: P111QReloc{"INVALID_P112_STATIC_WORD",0}

@unsafe
def p112s_image_fields(fields: List<&2,P112SWord>, +constructors: KDef, acc: List<&2,P111QDatum>) -> List<&2,P111QDatum>:
  match fields:
    case Nil{}: acc
    case Con{head,rest}: p112s_image_fields(rest,constructors,Con{p112s_datum(p112s_word(head,constructors)),acc})

@unsafe
def p112s_image_items(nodes: List<&2,P112SNode>, +constructors: KDef, acc: List<&2,P111QDatum>) -> List<&2,P111QDatum>:
  match nodes:
    case Nil{}: nt_reverse(P111QDatum,acc,[])
    case Con{P112SNode{offset,name,fields},rest}:
      p112s_image_items(rest,constructors,p112s_image_fields(fields,constructors,acc))

# ABI11101 has 24 eight-byte descriptor slots. Only static_words (slot8,
# byte64) and static_image (slot19,byte152) differ from the selected descriptor.
@unsafe
def p112s_descriptor_items(items: List<&2,P111QDatum>, +index: U32, +size: U32, acc: List<&2,P111QDatum>) -> List<&2,P111QDatum>:
  match items:
    case Nil{}: nt_reverse(P111QDatum,acc,[])
    case Con{head,rest}:
      p112s_descriptor_items(rest,U32.inc(index),size,Con{p112s_descriptor_item(head,index,size),acc})

def p112s_descriptor_item(item: P111QDatum, index: U32, size: U32) -> P111QDatum:
  match index:
    case 8: P111QLong{size,0}
    case 19: P111QReloc{"p111_static_image",0}
    case _: item

@unsafe
def p112s_patch_data(+data: P111QData, +size: U32) -> P111QData:
  match data:
    case P111QData{+name,alignment,exported,items}:
      nt_choose(P111QData,String.eq(name,"p111_program"),
        u => P111QData{name,alignment,exported,p112s_descriptor_items(items,0,size,[])},u => data)

@unsafe
def p112s_patch_tables(tables: List<&2,P111QData>, +size: U32, acc: List<&2,P111QData>) -> List<&2,P111QData>:
  match tables:
    case Nil{}: nt_reverse(P111QData,acc,[])
    case Con{head,rest}: p112s_patch_tables(rest,size,Con{p112s_patch_data(head,size),acc})

@unsafe
def p112s_tables(+program: P111Program, +nodes: List<&2,P112SNode>, +ids: N111Ids) -> List<&2,P111QData>:
  match program:
    case P111Program{segments,constructors,show,show_names,effects,pure}:
      nt_append(P111QData,p112s_patch_tables(p111q_tables(program,ids),p112s_size(nodes,0),[]),
        [P111QData{"p111_static_image",8,False{},p112s_image_items(nodes,p112s_ctors(constructors,0,missing()),[])}])

@unsafe
def p112s_chunks_static(+program: P111Program, nodes: List<&2,P112SNode>, +ids: N111Ids) -> List<&2,String>:
  match program:
    case P111Program{segments,constructors,show,show_names,effects,pure}:
      nt_append(String,p111q_segment_chunks(segments,ids,[]),
        nt_append(String,p111q_data_chunks(p112s_tables(program,nodes,ids)),[p111q_main()]))

@unsafe
def p112s_chunks(bundle: P112StaticProgram) -> List<&2,String>:
  match bundle:
    case P112StaticProgram{+program,+nodes}:
      nt_choose(List<&2,String>,List.is_empty(&2,P112SNode,nodes),u => p111q_chunks(program),
        u => p112s_chunks_static(program,nodes,p111q_ids(program)))

@unsafe
def p112s_text(bundle: P112StaticProgram) -> String:
  nt_text_finish(nt_reverse(String,p112s_chunks(bundle),[]),"")
