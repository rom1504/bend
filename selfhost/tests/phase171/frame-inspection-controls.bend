# Header/empty-body refusals only; these are not semantic import controls.
# Root must source-check and execute before reporting any control as passed.

@unsafe
def p171h_refused(arity: U32, result: U32, incoming: U32, flags: U32) -> Bool:
  +segment : N111Segment = N111Segment{"p171_owner",arity,result,incoming,flags,[]}
  Bool.not(p114h_valid(p114h_plan(segment,p112f_index([segment]),p124r_view(missing(),missing()))))

@unsafe
def p171h_header_controls() -> List<&2,Bool>:
  [p171h_refused(0,1,0,0),p171h_refused(9,1,0,0),
   p171h_refused(1,2,0,0),p171h_refused(1,1,1,0),
   p171h_refused(1,1,0,1),p171h_refused(1,1,0,0)]
