# Specialized native ABI11102 sqrt call. It remains an unknown call to every
# effect, scratch, liveness and XMM analysis; do not add opcode36 to FloatValues.
def x195s_enabled() -> Bool: True{}

type X195Sqrt is Data:
  X195Sqrt{+name: String, +buffer: String}

@unsafe
def x195s_pick(enabled: Bool, stmt: N111Stmt) -> Maybe<&2,X195Sqrt>:
  match stmt:
    case N111Call{name,N111U64{},symbol,[
      N111Arg{N111Ptr{},N111Local{state}},N111Arg{N111U32{},N111Const{36,0}},
      N111Arg{N111Ptr{},N111Local{+buffer}},N111Arg{N111U32{},N111Const{1,0}}]}:
      nt_choose(Maybe<&2,X195Sqrt>,enabled && String.eq(symbol,"p111_rt_op") &&
        String.eq(state,"state") && Bool.not(String.eq(buffer,"state")),
        u => Some{X195Sqrt{name,buffer}},u => None{})
    case _: None{}

@unsafe
def x195s_previous(+name: String, +typ: N111Type, +symbol: String, +args: List<&2,N111Arg>,
    +ids: N111Ids, +frame: X181Frame, code: X181Code) -> X181Code:
  +floating = x185_float_probe(N111Call{name,typ,symbol,args},ids,frame)
  +text = nt_choose(X188Seq,x188_empty(floating),
    u => x186_u32_float_probe(N111Call{name,typ,symbol,args},ids,frame),u => floating)
  x181_add(nt_choose(X188Seq,x188_empty(text),
    u => x188_many([x181_call_text(symbol,args,ids,frame),
      nt_choose(X188Seq,U32.is_eq(p111v_type(typ),1),v => x188_i2("movl",x188_reg(0,32),x188_reg(0,32)),v => X188Empty{}),
      x181_store(name,frame,x188_reg(0,64))]),u => text),code)

@unsafe
def x195s_original(stmt: N111Stmt, ids: N111Ids, frame: X181Frame, code: X181Code) -> X181Code:
  match stmt:
    case N111Call{name,typ,symbol,args}: x195s_previous(name,typ,symbol,args,ids,frame,code)
    case _: x181_error("sqrt specialization expected scalar call",code)

# Match the retained runtime exactly: zero > input uses ordered JA, so negative
# finite/infinite inputs call sqrtf; +/-0 and NaNs remain on the SQRTSS path.
@unsafe
def x195s_text(name: String, buffer: String, ids: N111Ids, +frame: X181Frame, +site: U32) -> X188Seq:
  x188_many([x181_load(N111Local{buffer},ids,frame,x188_reg(10,64)),
    x188_i2("movd",X187Mem{10,0},x188_xmm(0)),
    x188_i2("pxor",x188_xmm(1),x188_xmm(1)),
    x188_i2("ucomiss",x188_xmm(0),x188_xmm(1)),
    x188_i1("ja",X187Target{x181_label(site,frame)}),
    x188_i2("sqrtss",x188_xmm(0),x188_xmm(0)),
    x188_i1("jmp",X187Target{x181_label(U32.inc(site),frame)}),
    x188_label(x181_label(site,frame)),x188_i1("call",X187Target{"sqrtf"}),
    x188_label(x181_label(U32.inc(site),frame)),x186_float_result(name,frame)])

@unsafe
def x195s_expand(name: String, buffer: String, stmt: N111Stmt,
    +ids: N111Ids, +frame: X181Frame, +code: X181Code) -> X181Code:
  match code:
    case X181Code{chunks,+next,terminal,error}:
      nt_choose(X181Code,U32.is_le(next,4294967293),u =>
        X181Code{Con{x195s_text(name,buffer,ids,frame,next),chunks},U32.add(next,2),terminal,error},
        u => x195s_original(stmt,ids,frame,code))

@unsafe
def x195s_selected(pick: Maybe<&2,X195Sqrt>, stmt: N111Stmt,
    ids: N111Ids, frame: X181Frame, code: X181Code) -> X181Code:
  match pick:
    case Some{X195Sqrt{name,buffer}}: x195s_expand(name,buffer,stmt,ids,frame,code)
    case None{}: x195s_original(stmt,ids,frame,code)
