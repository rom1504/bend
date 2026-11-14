@unsafe
def x185_float_call(name: String, typ: N111Type, symbol: String, args: List<&2,N111Arg>,
    ids: N111Ids, frame: X181Frame, code: X181Code) -> X181Code:
  +stmt = N111Call{name,typ,symbol,args}
  x195s_selected(x195s_pick(x195s_enabled(),stmt),stmt,ids,frame,code)
