# Apply only as the optional final segment-emission override.
@unsafe
def p111q_segment_chunks(+segments: List<&2,N111Segment>, +ids: N111Ids, +acc: List<&2,String>) -> List<&2,String>:
  p112f_segment_chunks(segments,ids,acc)
