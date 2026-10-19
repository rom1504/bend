# All admitted frozen entries are emitted. This bounded prototype does not
# recompute a reachability closure or replan against the final ready set.
@unsafe
def p112r_private_chunks(entries: List<&2,P112RegionEntry>, +ids: N111Ids, acc: List<&2,String>) -> List<&2,String>:
  match entries:
    case Nil{}: acc
    case Con{P112RegionEntry{+segment,+plan,+rank,+sites},+rest}:
      p112r_private_chunks(rest,ids,Con{p112w_private(segment,ids,plan),acc})

@unsafe
def p112r_public_chunks(segments: List<&2,N111Segment>, +index: P112FusionIndex, +ids: N111Ids, +ready: KDef, acc: List<&2,String>) -> List<&2,String>:
  match segments:
    case Nil{}: nt_reverse(String,acc,[])
    case Con{+segment,+rest}:
      p112r_public_chunks(rest,index,ids,ready,Con{p112f_public(segment,ids,ready,p112f_plan_index(segment,index,ready)),acc})

# Keep one chunk per original segment so existing metadata/chunk consumers keep
# their boundary. Private definitions are attached to the first public chunk.
@unsafe
def p112r_attach(chunks: List<&2,String>, +private: String) -> List<&2,String>:
  match chunks:
    case Nil{}: []
    case Con{+first,+rest}: Con{private ++ first,rest}

@unsafe
def p112r_chunks(+segments: List<&2,N111Segment>, +ids: N111Ids, +acc: List<&2,String>, registry: P112RegionRegistry) -> List<&2,String>:
  match registry:
    case P112RegionRegistry{+ready,+symbols,+entries,+workers,+fusions}:
      p112r_attach(p112r_public_chunks(segments,p112f_index(segments),ids,ready,acc),nt_join(p112r_private_chunks(entries,ids,[]),""))

@unsafe
def p112r_segment_chunks(+segments: List<&2,N111Segment>, +ids: N111Ids, +acc: List<&2,String>) -> List<&2,String>:
  p112r_chunks(segments,ids,acc,p112r_index(segments))

@unsafe
def p112r_counts(registry: P112RegionRegistry) -> String:
  match registry:
    case P112RegionRegistry{+ready,+symbols,+entries,+workers,+fusions}: U32.show(workers) ++ "/" ++ U32.show(fusions)

@unsafe
def p112r_program_counts(program: P111Program) -> String:
  match program:
    case P111Program{+segments,+constructors,+show,+show_names,+effects,+pure}: p112r_counts(p112r_index(segments))
