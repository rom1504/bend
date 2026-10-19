# Exact replacement; all other Phase111 emission and verification stays intact.
@unsafe
def p111q_segment_chunks(segments: List<&2,N111Segment>, +ids: N111Ids, acc: List<&2,String>) -> List<&2,String>:
  match segments:
    case Nil{}: nt_reverse(String,acc,[])
    case Con{segment,rest}: p111q_segment_chunks(rest,ids,Con{p112q_segment(segment,ids),acc})
