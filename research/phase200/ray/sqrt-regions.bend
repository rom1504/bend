# General known-effect sqrt: all allocated GPR/XMM homes survive the helper.
# Negative inputs retain sqrtf errno/FP behavior; no reassociation or fast-math.
def x200r_sqrt_admitted(+id: U32, count: U32, buffer: String) -> Bool:
  U32.is_eq(id,36) && U32.is_eq(count,1) && Bool.not(String.eq(buffer,"state"))

def x200r_float_unary(+id: U32) -> Bool:
  U32.is_eq(id,36) || x192_float_unary(id)

@unsafe
def x200r_sqrt_values(name: String, left: N111Value, ids: N111Ids, +frame: X181Frame, +homes: KDef) -> X188Seq:
  x188_many([x186_x_load(left,ids,frame,homes,x188_xmm(0)),
    x188_i1("call",X187Target{"p200_rt_f32_sqrt_keep"}),
    x186_x_publish(name,x188_xmm(0),frame,homes)])

@unsafe
def x200r_sqrt_buffer(name: String, buffer: String, ids: N111Ids, +frame: X181Frame) -> X188Seq:
  x188_many([x181_load(N111Local{buffer},ids,frame,x188_reg(10,64)),
    x188_i2("movd",X187Mem{10,0},x188_xmm(0)),
    x188_i1("call",X187Target{"p200_rt_f32_sqrt_keep"}),x186_float_result(name,frame)])

@unsafe
def x186_inline_op_when(enabled: Bool, stmt: N111Stmt) -> X186InlineOp:
  match stmt:
    case N111Call{name,N111U64{},symbol,
      Con{N111Arg{N111Ptr{},N111Local{state}},Con{N111Arg{N111U32{},N111Const{+id,0}},Con{N111Arg{N111Ptr{},N111Local{+buffer}},Con{N111Arg{N111U32{},N111Const{+count,0}},Nil{}}}}}}:
      nt_choose(X186InlineOp,enabled && String.eq(symbol,"p111_rt_op") && String.eq(state,"state") &&
          (x200r_sqrt_admitted(id,count,buffer) || nt_choose(Bool,x192_float_unary(id),
            v => x192_float_conversions_enabled() && U32.is_eq(count,1) && Bool.not(String.eq(buffer,"state")),
            v => U32.is_ge(id,26) && p112fp_supported(id,count))),
        u => X186InlineF32{name,id,buffer},u => X186InlineNone{})
    case _: X186InlineNone{}

@unsafe
def x186_f_operation(stmt: N111Stmt, +facts: List<&2,X185ScratchCell>, operation: X186InlineOp) -> X186FloatNode:
  match operation:
    case X186InlineF32{destination,+id,+buffer}:
      x186_f_values(stmt,destination,id,x185_sf_find(facts,buffer,0,N111U64{}),
        x185_sf_find(facts,buffer,nt_choose(U32,x200r_float_unary(id),u => 0,u => 8),N111U64{}))
    case X186InlineNone{}: X186FloatPlain{P113DScalar{stmt}}

@unsafe
def x186_m_call(stmt: N111Stmt, +scan: X186Memory, effect: X186InlineOp) -> X186Memory:
  match effect:
    case X186InlineF32{destination,+id,+buffer}:
      nt_choose(X186Memory,x200r_float_unary(id),
        u => x186_m_read(buffer,0,N111U64{},scan),
        u => x186_m_read(buffer,8,N111U64{},x186_m_read(buffer,0,N111U64{},scan)))
    case _: x186_m_unknown_call(stmt,scan)

@unsafe
def x186_x_float(+name: String, +id: U32, +left: N111Value, +right: N111Value,
    +ids: N111Ids, +frame: X181Frame, +homes: KDef) -> X188Seq:
  nt_choose(X188Seq,U32.is_eq(id,36),u => x200r_sqrt_values(name,left,ids,frame,homes),
    u => nt_choose(X188Seq,x192_float_unary(id),u => x192_float_conversion(name,id,left,ids,frame,homes),
    u => nt_choose(X188Seq,U32.is_lt(id,30),v => x186_x_arithmetic(name,id,left,right,ids,frame,homes),
      v => x186_x_compare(name,id,left,right,ids,frame,homes))))

@unsafe
def x186_f_values_text(+name: String, +id: U32, +left: N111Value, +right: N111Value,
    +ids: N111Ids, +frame: X181Frame) -> X188Seq:
  nt_choose(X188Seq,U32.is_eq(id,36),u => x200r_sqrt_values(name,left,ids,frame,missing()),
    u => nt_choose(X188Seq,x192_float_unary(id),
    u => x192_float_conversion(name,id,left,ids,frame,missing()),
    u => x188_many([x186_float_load(left,ids,frame,x188_xmm(0)),x186_float_load(right,ids,frame,x188_xmm(1)),
      x186_float_finish(name,id,frame)])))

@unsafe
def x186_float_operation(operation: X186InlineOp, +ids: N111Ids, +frame: X181Frame) -> X188Seq:
  match operation:
    case X186InlineF32{+name,+id,+buffer}:
      nt_choose(X188Seq,U32.is_eq(id,36),u => x200r_sqrt_buffer(name,buffer,ids,frame),
        u => nt_choose(X188Seq,x192_float_unary(id),
          v => x192_float_conversion_buffer(name,id,buffer,ids,frame),
          v => x185_float_text(name,id,buffer,ids,frame)))
    case X186InlineNone{}: X188Empty{}

@unsafe
def x195s_text(name: String, buffer: String, ids: N111Ids, +frame: X181Frame, +site: U32) -> X188Seq:
  x188_many([x181_load(N111Local{buffer},ids,frame,x188_reg(10,64)),
    x188_i2("movd",X187Mem{10,0},x188_xmm(0)),
    x188_i2("pxor",x188_xmm(1),x188_xmm(1)),
    x188_i2("ucomiss",x188_xmm(0),x188_xmm(1)),
    x188_i1("ja",X187Target{x181_label(site,frame)}),
    x188_i2("sqrtss",x188_xmm(0),x188_xmm(0)),
    x188_i1("jmp",X187Target{x181_label(U32.inc(site),frame)}),
    x188_label(x181_label(site,frame)),x188_i1("call",X187Target{"p200_rt_f32_sqrt_keep"}),
    x188_label(x181_label(U32.inc(site),frame)),x186_float_result(name,frame)])

@unsafe
def x200r_sqrt_core(name: String, left: N111Value, ids: N111Ids,
    +frame: X181Frame, +homes: KDef, +site: U32) -> X188Seq:
  x188_many([x186_x_load(left,ids,frame,homes,x188_xmm(0)),
    x188_i2("pxor",x188_xmm(1),x188_xmm(1)),
    x188_i2("ucomiss",x188_xmm(0),x188_xmm(1)),
    x188_i1("ja",X187Target{x181_label(site,frame)}),
    x188_i2("sqrtss",x188_xmm(0),x188_xmm(0)),
    x188_i1("jmp",X187Target{x181_label(U32.inc(site),frame)}),
    x188_label(x181_label(site,frame)),
    x188_i1("call",X187Target{"p200_rt_f32_sqrt_keep"}),
    x188_label(x181_label(U32.inc(site),frame)),
    x186_x_publish(name,x188_xmm(0),frame,homes)])

@unsafe
def x200r_sqrt_emit(+name: String, +left: N111Value, +ids: N111Ids,
    +frame: X181Frame, +homes: KDef, +code: X181Code) -> X181Code:
  match code:
    case X181Code{chunks,+next,terminal,error}:
      nt_choose(X181Code,U32.is_le(next,4294967293),
        u => X181Code{Con{x200r_sqrt_core(name,left,ids,frame,homes,next),chunks},U32.add(next,2),terminal,error},
        u => x181_add(x200r_sqrt_values(name,left,ids,frame,homes),code))

@unsafe
def x186_x_emit_node(+node: X186FloatNode, +ids: N111Ids, +frame: X181Frame, +homes: KDef, +code: X181Code) -> X181Code:
  match node:
    case X186FloatValues{+name,+id,+left,+right}:
      nt_choose(X181Code,U32.is_eq(id,36),u => x200r_sqrt_emit(name,left,ids,frame,homes,code),
        u => x181_add(x186_x_float(name,id,left,right,ids,frame,homes),code))
    case X186FloatPlain{+stmt}:
      match stmt:
        case P113DScalar{N111Set{name,N111U64{},value}}: x186_x_copy(stmt,name,value,ids,frame,homes,code)
        case _: x181_stmt(stmt,ids,frame,code)
    case X186FloatBranch{condition,yes,no}: x186_x_emit_if(condition,yes,no,ids,frame,homes,code)

@unsafe
def x186_f_emit_node(node: X186FloatNode, +ids: N111Ids, +frame: X181Frame, +code: X181Code) -> X181Code:
  match node:
    case X186FloatPlain{stmt}: x181_stmt(stmt,ids,frame,code)
    case X186FloatBranch{condition,yes,no}: x186_f_emit_if(condition,yes,no,ids,frame,code)
    case X186FloatValues{+destination,+id,+left,+right}:
      nt_choose(X181Code,U32.is_eq(id,36),u => x200r_sqrt_emit(destination,left,ids,frame,missing(),code),
        u => x181_add(x186_f_values_text(destination,id,left,right,ids,frame),code))
