@unsafe
def p114rt_registered(+segments: List<&2,N111Segment>, +functions: List<&2,P113DFunction>,
    +index: P112FusionIndex, +ids: N111Ids, +heap_min: U32, +constructors: U32, +arrays: Bool, registry: P112RegionRegistry) -> List<&2,String>:
  match registry:
    case P112RegionRegistry{ready,symbols,entries,workers,fusions}:
      +direct = p113e_signatures(functions,missing())
      nt_append(String,p114rt_private_chunks(functions,ids,heap_min,constructors,arrays,[]),
        p112c_attach(p113e_public_chunks(segments,direct,index,ids,ready,[]),
          nt_join(p113e_old_private_chunks(entries,direct,ids,[]),"")))

@unsafe
def p114rt_bundle(+program: P111Program, +nodes: List<&2,P112SNode>, +functions: List<&2,P113DFunction>, +arrays: Bool) -> List<&2,String>:
  match program:
    case P111Program{+segments,+constructors,show,names,effects,pure}:
      +ids = p111q_ids(program)
      +index = p112f_index(segments)
      nt_append(String,p114rt_registered(segments,functions,index,ids,p113a_heap_min(nodes),nt_count(N_Constructor,constructors),arrays,p112c_index_with(segments,index)),
        nt_append(String,p111q_data_chunks(Con{p114rt_arity_table(constructors),
          nt_choose(List<&2,P111QData>,List.is_empty(&2,P112SNode,nodes),
            u => p111q_tables(program,ids),u => p112s_tables(program,nodes,ids))}),[p111q_main()]))

@unsafe
def p114rt_admitted(program: P113AProgram) -> List<&2,String>:
  match program:
    case P113AProgram{P113DProgram{original,Nil{}},certificate}: p112s_chunks(original)
    case P113AProgram{P113DProgram{P112StaticProgram{program,nodes},functions},certificate}:
      p114rt_bundle(program,nodes,functions,p113a_enabled(certificate))

@unsafe
def p114rt_verify_done(+program: P113DProgram, +error: String) -> String:
  nt_choose(String,Bool.not(String.is_empty(error)),u => error,u =>
    nt_choose(String,p114rt_namespace(program),v => "",v => "reserved private runtime-template local"))
