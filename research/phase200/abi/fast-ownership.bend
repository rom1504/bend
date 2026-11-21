# A complete high byte of zero or one denotes a plain word or packed immediate.
# The original scalar allocator still treats this as a call. RAX and R10 have
# no persistent homes. The slow edge takes the ordinary snapshot-aware call.
@unsafe
def x200a_guard(+name: String, +word: String, +symbol: String,
  +args: List<&2,N111Arg>, +ids: N111Ids, +frame: X181Frame, +code: X181Code) -> X181Code:
  match code:
    case X181Code{chunks,+next,terminal,error}:
      nt_choose(X181Code,U32.is_lt(next,4294967295),u => X181Code{Con{x188_many([
        x181_load(N111Local{word},ids,frame,x188_reg(10,64)),
        nt_choose(X188Seq,String.eq(symbol,"p111_rt_keep"),
          u => x188_i2("movq",x188_reg(10,64),x188_reg(0,64)),
          u => x188_i2("xorl",x188_reg(0,32),x188_reg(0,32))),
        x188_i2("shrq",X187Imm{57,0},x188_reg(10,64)),
        x188_i1("jz",X187Target{x181_label(next,frame)}),
        x181_call_text(symbol,args,ids,frame),
        x188_label(x181_label(next,frame)),
        x181_store(name,frame,x188_reg(0,64))]),chunks},
        U32.inc(next),terminal,error},u => x181_add(x188_many([x181_call_text(symbol,args,ids,frame),
          x181_store(name,frame,x188_reg(0,64))]),code))

@unsafe
def x200a_previous(+stmt: N111Stmt, ids: N111Ids, frame: X181Frame, code: X181Code) -> X181Code:
  x195s_selected(x195s_pick(x195s_enabled(),stmt),stmt,ids,frame,code)

@unsafe
def x200a_select(+stmt: N111Stmt, +ids: N111Ids, +frame: X181Frame, +code: X181Code) -> X181Code:
  match stmt:
    case N111Call{+name,N111U64{},+symbol,+args}:
      match args:
        case Con{N111Arg{N111Ptr{},N111Local{state}},Con{N111Arg{N111U64{},N111Local{word}},Nil{}}}:
          nt_choose(X181Code,String.eq(state,"state") && Bool.not(String.is_empty(name)) &&
              (String.eq(symbol,"p111_rt_keep") || String.eq(symbol,"p111_rt_sink")),
            u => x200a_guard(name,word,symbol,args,ids,frame,code),
            u => x200a_previous(stmt,ids,frame,code))
        case _: x200a_previous(stmt,ids,frame,code)
    case _: x200a_previous(stmt,ids,frame,code)

@unsafe
def x185_float_call(name: String, typ: N111Type, symbol: String, args: List<&2,N111Arg>,
    ids: N111Ids, frame: X181Frame, code: X181Code) -> X181Code:
  x200a_select(N111Call{name,typ,symbol,args},ids,frame,code)
