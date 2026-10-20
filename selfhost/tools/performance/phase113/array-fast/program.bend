# Same descriptor layout as frozen static image emission: STAT_OFF=51413504,
# PAGE_LEN=128, physical result bank remains256. No dynamic runtime layout flag.
@unsafe
def p113a_heap_min(nodes: List<&2,P112SNode>) -> U32:
  U32.add(51413504,U32.and(U32.add(p112s_size(nodes,0),127),4294967168))

# Only the complete private worker bodies receive generated memory templates.
# Public fallback, static image, old private ABI and registration are unchanged.
@unsafe
def p113a_registered(+segments: List<&2,N111Segment>, +functions: List<&2,P113DFunction>,
    +index: P112FusionIndex, +ids: N111Ids, +heap_min: U32, registry: P112RegionRegistry) -> List<&2,String>:
  match registry:
    case P112RegionRegistry{ready,symbols,entries,workers,fusions}:
      +direct = p113e_signatures(functions,missing())
      nt_append(String,p113e_private_chunks(p113a_functions(functions,heap_min),ids,[]),
        p112c_attach(p113e_public_chunks(segments,direct,index,ids,ready,[]),
          nt_join(p113e_old_private_chunks(entries,direct,ids,[]),"")))

@unsafe
def p113a_segment_chunks(+segments: List<&2,N111Segment>, +functions: List<&2,P113DFunction>,
    +ids: N111Ids, +heap_min: U32, +index: P112FusionIndex) -> List<&2,String>:
  p113a_registered(segments,functions,index,ids,heap_min,p112c_index_with(segments,index))

@unsafe
def p113a_bundle_chunks(+program: P111Program, +nodes: List<&2,P112SNode>, functions: List<&2,P113DFunction>) -> List<&2,String>:
  match program:
    case P111Program{+segments,constructors,show,names,effects,pure}:
      +ids = p111q_ids(program)
      nt_append(String,p113a_segment_chunks(segments,functions,ids,p113a_heap_min(nodes),p112f_index(segments)),
        nt_append(String,p111q_data_chunks(nt_choose(List<&2,P111QData>,List.is_empty(&2,P112SNode,nodes),
          u => p111q_tables(program,ids),u => p112s_tables(program,nodes,ids))),[p111q_main()]))

@unsafe
def p113a_admitted_chunks(+program: P113AProgram) -> List<&2,String>:
  match program:
    case P113AProgram{+original,+certificate}:
      nt_choose(List<&2,String>,p113a_enabled(certificate),
        u => p113a_enabled_chunks(original),u => p113e_admitted_chunks(original))

@unsafe
def p113a_enabled_chunks(program: P113DProgram) -> List<&2,String>:
  match program:
    case P113DProgram{original,Nil{}}: p112s_chunks(original)
    case P113DProgram{P112StaticProgram{program,nodes},functions}: p113a_bundle_chunks(program,nodes,functions)

@unsafe
def p113a_checked_chunks(+program: P113AProgram, +error: String) -> List<&2,String>:
  nt_choose(List<&2,String>,String.is_empty(error),u => p113a_admitted_chunks(program),
    u => ["INVALID_P113_ARRAY_PROGRAM: " ++ error ++ "\n"])

@unsafe
def p113a_chunks(+program: P113AProgram) -> List<&2,String>:
  p113a_checked_chunks(program,p113a_verify(program))

@unsafe
def p113a_text(program: P113AProgram) -> String:
  nt_text_finish(nt_reverse(String,p113a_chunks(program),[]),"")

@unsafe
def p113a_inspection(+program: P113AProgram, error: String) -> P113AInspection:
  match program:
    case P113AProgram{P113DProgram{original,+functions},P113ACertificate{+scalar,+unshared}}:
      P113AInspection{scalar,unshared,scalar && unshared,nt_count(P113DFunction,functions),
        nt_choose(U32,scalar && unshared,u => p113a_count_functions(functions,0),u => 0),error}

@unsafe
def p113a_inspect_lowered(lowered: P113ALowering) -> P113AInspection:
  match lowered:
    case P113ALowered{+program,+error}:
      p113a_inspection(program,nt_choose(String,String.is_empty(error),u => p113a_verify(program),u => error))

@unsafe
def p113a_inspect_request(request: NR_Request) -> P113AInspection:
  p113a_inspect_lowered(p113a_lower_request(request))

@unsafe
def p113a_emit_verified(+program: P113AProgram, +error: String) -> P111Emission:
  nt_choose(P111Emission,String.is_empty(error),u => P111Emission{p113a_admitted_chunks(program),""},
    u => P111Emission{[],"array structured IR: " ++ error})

@unsafe
def p113a_emit_lowered(lowered: P113ALowering) -> P111Emission:
  match lowered:
    case P113ALowered{+program,+error}:
      nt_choose(P111Emission,String.is_empty(error),u => p113a_emit_verified(program,p113a_verify(program)),
        u => P111Emission{[],"array native lowering: " ++ error})
