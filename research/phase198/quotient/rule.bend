type P198Quot is Data:
  P198NoQuot{}
  P198Shift{+shift: U32}
  P198Magic{+multiplier: U32, +shift: U32}

# q,r represent floor and residue of 2^(32+s) divided by d.
@unsafe
def p198q_search(+d: U32, +q: U32, +r: U32, +s: U32, +scale: U32) -> P198Quot:
  nt_choose(P198Quot,U32.is_le(U32.sub(d,r),scale) && U32.is_lt(q,4294967295),
    u => P198Magic{U32.inc(q),U32.add(32,s)},u =>
    nt_choose(P198Quot,U32.is_lt(q,2147483648) && U32.is_lt(s,16),v =>
      p198q_search(d,U32.add(U32.mul(q,2),U32.div(U32.mul(r,2),d)),U32.mod(U32.mul(r,2),d),U32.inc(s),U32.mul(scale,2)),
      v => P198NoQuot{}))

@unsafe
def p198q_log(+d: U32, +shift: U32) -> U32:
  nt_choose(U32,U32.is_le(d,1),u => shift,u => p198q_log(U32.shrn(d,1n),U32.inc(shift)))

@unsafe
def p198q_plan(+d: U32) -> P198Quot:
  nt_choose(P198Quot,U32.is_eq(d,0),u => P198NoQuot{},u =>
    nt_choose(P198Quot,U32.is_eq(U32.and(d,U32.sub(d,1)),0),v => P198Shift{p198q_log(d,0)},v =>
      nt_choose(P198Quot,U32.is_le(d,65535),w =>
        p198q_search(d,U32.div(4294967295,d),U32.inc(U32.mod(4294967295,d)),0,1),w => P198NoQuot{})))

@unsafe
def p198q_fallback(+name: String, +values: List<&2,N111Value>) -> P111ValueCode:
  +id = p111_op_id(name)
  nt_choose(P111ValueCode,U32.is_eq(id,0),u => P111ValueCode{Nil{},N111Const{0,0},"unknown native primitive " ++ name},
    u => P111ValueCode{nt_append(N111Stmt,p111_store(values,0),[N111Call{"value",N111U64{},"p111_rt_op",[
      p111_state(),p111_u32(id),p111_scratch(),p111_u32(nt_count(N111Value,values))]}]),N111Local{"value"},""})

@unsafe
def p198q_emit(+name: String, +values: List<&2,N111Value>, +x: N111Value, +d: U32, plan: P198Quot) -> P111ValueCode:
  match plan:
    case P198NoQuot{}: p198q_fallback(name,values)
    case P198Shift{shift}:
      nt_choose(P111ValueCode,String.eq(name,"u32_mod"),u =>
        P111ValueCode{[N111Bin{"value",N111U64{},"and",x,N111Const{U32.sub(d,1),0}}],N111Local{"value"},""},
        u => P111ValueCode{[N111Bin{"p112_s_a",N111U64{},"and",x,N111Const{4294967295,0}},
          N111Bin{"value",N111U64{},"shr",N111Local{"p112_s_a"},N111Const{shift,0}}],N111Local{"value"},""})
    case P198Magic{m,s}:
      +scalar : List<&2,N111Stmt> = [N111Bin{"p112_s_a",N111U64{},"and",x,N111Const{4294967295,0}},
        N111Bin{"p112_s_b",N111U64{},"mul",N111Local{"p112_s_a"},N111Const{m,0}}]
      nt_choose(P111ValueCode,String.eq(name,"u32_div"),u => P111ValueCode{nt_append(N111Stmt,scalar,
        [N111Bin{"value",N111U64{},"shr",N111Local{"p112_s_b"},N111Const{s,0}}]),N111Local{"value"},""},
        u => P111ValueCode{nt_append(N111Stmt,scalar,[N111Bin{"p112_s_b",N111U64{},"shr",N111Local{"p112_s_b"},N111Const{s,0}},
          N111Bin{"value",N111U64{},"mul",N111Local{"p112_s_b"},N111Const{d,0}},
          N111Bin{"value",N111U64{},"sub",N111Local{"p112_s_a"},N111Local{"value"}}]),N111Local{"value"},""})

@unsafe
def p125i_previous_fallback(+name: String, +values: List<&2,N111Value>) -> P111ValueCode:
  match values:
    case Con{+x,Con{N111Const{+lo,hi},Nil{}}}:
      nt_choose(P111ValueCode,(String.eq(name,"u32_div") || String.eq(name,"u32_mod")) && p112_scalar_safe(values),
        u => p198q_emit(name,values,x,lo,p198q_plan(lo)),u => p198q_fallback(name,values))
    case _: p198q_fallback(name,values)
