# Optional final hook; requires its own region-multi conjunctive admission.
@unsafe
def p111q_segment_chunks(+segments: List<&2,N111Segment>, +ids: N111Ids, +acc: List<&2,String>) -> List<&2,String>:
  p112c_segment_chunks(segments,ids,acc)
