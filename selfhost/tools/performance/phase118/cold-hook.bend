# One exact table boundary covers generic, static, direct and packed-array
# renderers. Existing descriptor layout and hot table order are unchanged.
@unsafe
def p111q_data_chunks(items: List<&2,P111QData>) -> List<&2,String>:
  p111q_data_chunks_go(p118c_tables(items),[])
