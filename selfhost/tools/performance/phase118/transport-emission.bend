# Capability4 is derived from the complete verified pre-template program.
# No descriptor/table/IR string rewriting; the existing renderer is reused.
@unsafe
def p118z_cap_items(items: List<&2,P111QDatum>, +index: U32) -> List<&2,P111QDatum>:
  match items:
    case Nil{}: []
    case Con{+head,rest}: Con{nt_choose(P111QDatum,U32.is_eq(index,11),u => p118z_cap_item(head),u => head),p118z_cap_items(rest,U32.inc(index))}

@unsafe
def p118z_cap_item(item: P111QDatum) -> P111QDatum:
  match item:
    case P111QLong{lo,hi}: P111QLong{U32.or(lo,4),hi}
    case _: item

@unsafe
def p118z_tables(tables: List<&2,P111QData>) -> List<&2,P111QData>:
  match tables:
    case Nil{}: []
    case Con{P111QData{+name,alignment,exported,+items},rest}:
      Con{P111QData{name,alignment,exported,nt_choose(List<&2,P111QDatum>,String.eq(name,"p111_program"),
        u => p118z_cap_items(items,0),u => items)},p118z_tables(rest)}

@unsafe
def p118z_bundle(+program: P111Program, +nodes: List<&2,P112SNode>, +functions: List<&2,P113DFunction>, +arrays: Bool) -> List<&2,String>:
  match program:
    case P111Program{+segments,constructors,show,names,effects,pure}:
      +ids = p111q_ids(program)
      +tables = nt_choose(List<&2,P111QData>,List.is_empty(&2,P112SNode,nodes),u => p111q_tables(program,ids),u => p112s_tables(program,nodes,ids))
      nt_append(String,nt_choose(List<&2,String>,arrays,
        u => p113a_segment_chunks(segments,functions,ids,p113a_heap_min(nodes),p112f_index(segments)),
        u => p113e_segment_chunks(segments,functions,ids,p112f_index(segments))),
        nt_append(String,p111q_data_chunks(p118z_tables(nt_choose(List<&2,P111QData>,arrays,
          u => p117p_tables(tables,[]),u => tables))),[p111q_main()]))

@unsafe
def p113a_admitted_chunks(+program: P113AProgram) -> List<&2,String>:
  match program:
    case P113AProgram{P113DProgram{P112StaticProgram{raw,nodes},Con{head,rest}},certificate}:
      nt_choose(List<&2,String>,p118z_eligible(program),
        u => p118z_bundle(raw,nodes,Con{head,rest},p113a_enabled(certificate)),
        u => p118z_original_chunks(program))
    case _: p118z_original_chunks(program)

@unsafe
def p118z_original_chunks(program: P113AProgram) -> List<&2,String>:
  match program:
    case P113AProgram{+original,+certificate}:
      nt_choose(List<&2,String>,p113a_enabled(certificate),
        u => p113a_enabled_chunks(original),u => p113e_admitted_chunks(original))
