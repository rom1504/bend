# Pure projection controls, never unverified target calls.
@unsafe
def p125vc_call(symbol: String, second: N111Arg, count: U32, high: U32, state: String, buffer: String) -> N111Stmt:
  N111Call{"answer",N111U64{},symbol,[N111Arg{N111Ptr{},N111Local{state}},second,
    N111Arg{N111Ptr{},N111Local{buffer}},N111Arg{N111U32{},N111Const{count,high}}]}

@unsafe
def p125vc_shape(stmt: N111Stmt, expected: String) -> Bool:
  match stmt:
    case N111Call{dest,N111U64{},symbol,args}:
      String.eq(dest,"answer") && String.eq(symbol,expected) && U32.is_eq(nt_count(N111Arg,args),3)
    case _: False{}

@unsafe
def p125vc_refused(stmt: N111Stmt) -> Bool:
  match stmt:
    case N111Call{dest,typ,symbol,args}: Bool.not(String.starts_with(symbol,"p125_rt_"))
    case _: True{}

@unsafe
def p125vc_controls() -> List<&2,String>:
  [p113ft_row("ctor1",p125vc_shape(p118xs_original(p125vc_call("p111_rt_ctor",N111Arg{N111U32{},N111CtorId{"One"}},1,0,"state","scratch")),"p125_rt_ctor1")),
   p113ft_row("ctor4",p125vc_shape(p118xs_original(p125vc_call("p111_rt_ctor",N111Arg{N111U32{},N111CtorId{"Four"}},4,0,"state","scratch")),"p125_rt_ctor4")),
   p113ft_row("take1",p125vc_shape(p118xs_original(p125vc_call("p111_rt_take",p111_word(N111Local{"owner"}),1,0,"state","scratch")),"p125_rt_take1")),
   p113ft_row("take4",p125vc_shape(p118xs_original(p125vc_call("p111_rt_take",p111_word(N111Local{"owner"}),4,0,"state","scratch")),"p125_rt_take4")),
   p113ft_row("zero-count-fallback",p125vc_refused(p118xs_original(p125vc_call("p111_rt_ctor",N111Arg{N111U32{},N111CtorId{"Zero"}},0,0,"state","scratch")))),
   p113ft_row("large-count-fallback",p125vc_refused(p118xs_original(p125vc_call("p111_rt_take",p111_word(N111Local{"owner"}),5,0,"state","scratch")))),
   p113ft_row("high-count-fallback",p125vc_refused(p118xs_original(p125vc_call("p111_rt_take",p111_word(N111Local{"owner"}),1,1,"state","scratch")))),
   p113ft_row("wrong-state-fallback",p125vc_refused(p118xs_original(p125vc_call("p111_rt_take",p111_word(N111Local{"owner"}),1,0,"other","scratch")))),
   p113ft_row("state-as-buffer-fallback",p125vc_refused(p118xs_original(p125vc_call("p111_rt_take",p111_word(N111Local{"owner"}),1,0,"state","state")))),
   p113ft_row("non-CID-ctor-fallback",p125vc_refused(p118xs_original(p125vc_call("p111_rt_ctor",p111_u32(7),1,0,"state","scratch")))),
   p113ft_row("different-import-fallback",p125vc_refused(p118xs_original(p125vc_call("p111_rt_op",p111_u32(24),1,0,"state","scratch"))))]
