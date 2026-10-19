# Private admission/target indexes and private bodies use only original segments.
# Fused public bodies cannot create a new private dependency or machine cycle.
@unsafe
def p112f_plan_index(+segment: N111Segment, +index: P112FusionIndex, +ready: KDef) -> P112FusionBody:
  match segment:
    case N111Segment{+name,+arity,+result,+incoming,+flags,+body}:
      nt_choose(P112FusionBody,U32.is_eq(result,1) && U32.is_eq(flags,0) && p112f_clean(body),
        u => p112f_scan(body,index,ready,0),u => P112FusionBody{body,0,0})

@unsafe
def p112f_plan(+segment: N111Segment, +segments: List<&2,N111Segment>, +ready: KDef) -> P112FusionBody:
  p112f_plan_index(segment,p112f_index(segments),ready)

@unsafe
def p112f_public(+segment: N111Segment, +ids: N111Ids, +ready: KDef, plan: P112FusionBody) -> String:
  match segment plan:
    case N111Segment{+name,+arity,+result,+incoming,+flags,+original} P112FusionBody{+body,+count,+next}:
      nt_choose(String,U32.is_eq(count,0),u => p112w_public_segment(segment,ids,ready),
        u => p112w_public_segment(N111Segment{name,arity,result,incoming,flags,body},ids,ready))

@unsafe
def p112f_chunk_index(+segment: N111Segment, +index: P112FusionIndex, +ids: N111Ids, +ready: KDef, +targets: KDef) -> String:
  match segment:
    case N111Segment{+name,+arity,+result,+incoming,+flags,+body}:
      p112f_public(segment,ids,ready,p112f_plan_index(segment,index,ready)) ++ nt_choose(String,p112w_ready(targets,name),
        u => p112w_private(segment,ids,p112w_plan(segment,ready)),u => "")

@unsafe
def p112f_chunk(+segment: N111Segment, +segments: List<&2,N111Segment>, +ids: N111Ids, +ready: KDef, +targets: KDef) -> String:
  p112f_chunk_index(segment,p112f_index(segments),ids,ready,targets)

@unsafe
def p112f_chunks_index(todo: List<&2,N111Segment>, +index: P112FusionIndex, +ids: N111Ids, +ready: KDef, +targets: KDef, acc: List<&2,String>) -> List<&2,String>:
  match todo:
    case Nil{}: nt_reverse(String,acc,[])
    case Con{+segment,+rest}: p112f_chunks_index(rest,index,ids,ready,targets,Con{p112f_chunk_index(segment,index,ids,ready,targets),acc})

@unsafe
def p112f_chunks(+todo: List<&2,N111Segment>, +segments: List<&2,N111Segment>, +ids: N111Ids, +ready: KDef, +targets: KDef, +acc: List<&2,String>) -> List<&2,String>:
  p112f_chunks_index(todo,p112f_index(segments),ids,ready,targets,acc)

@unsafe
def p112f_indexed(+segments: List<&2,N111Segment>, +ids: N111Ids, +ready: KDef, +acc: List<&2,String>) -> List<&2,String>:
  p112f_chunks(segments,segments,ids,ready,p112w_targets(segments,ready,missing()),acc)

@unsafe
def p112f_segment_chunks(+segments: List<&2,N111Segment>, +ids: N111Ids, +acc: List<&2,String>) -> List<&2,String>:
  p112f_indexed(segments,ids,p112w_index(segments),acc)

def p112f_count(plan: P112FusionBody) -> U32:
  match plan:
    case P112FusionBody{+body,+count,+next}: count

@unsafe
def p112f_counts_index(todo: List<&2,N111Segment>, +index: P112FusionIndex, +ready: KDef, +changed: U32, +sites: U32) -> String:
  match todo:
    case Nil{}: U32.show(changed) ++ "/" ++ U32.show(sites)
    case Con{+segment,+rest}:
      +count = p112f_count(p112f_plan_index(segment,index,ready))
      p112f_counts_index(rest,index,ready,U32.add(changed,nt_bool(U32.is_gt(count,0))),U32.add(sites,count))

@unsafe
def p112f_counts(+todo: List<&2,N111Segment>, +segments: List<&2,N111Segment>, +ready: KDef, +changed: U32, +sites: U32) -> String:
  p112f_counts_index(todo,p112f_index(segments),ready,changed,sites)

@unsafe
def p112f_program_counts(program: P111Program) -> String:
  match program:
    case P111Program{+segments,+constructors,+show,+show_names,+effects,+pure}: p112f_counts(segments,segments,p112w_index(segments),0,0)
