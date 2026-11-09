# The existing native F32 ABI carries raw low32 bits in full word homes.
# This mirrors p112fp's verified binary-call admission, keeping all other
# imports on the original call path. xmm0/xmm1 and r10/r11 are ephemeral.
def x185_float_enabled() -> Bool: True{}

def x185_float_arithmetic(id: U32) -> String:
  match id:
    case 26: "addss"
    case 27: "subss"
    case 28: "mulss"
    case _: "divss"

# ucomiss(a,b): unordered sets ZF/PF/CF. Collect both conditions before
# combining bytes changes flags; equality/order exclude unordered, ne includes
# it. Above/above-equal already exclude unordered without a second predicate.
def x185_float_compare(id: U32) -> String:
  match id:
    case 30: "  sete %r10b\n  setnp %r11b\n  andb %r11b, %r10b\n"
    case 31: "  setne %r10b\n  setp %r11b\n  orb %r11b, %r10b\n"
    case 32: "  setb %r10b\n  setnp %r11b\n  andb %r11b, %r10b\n"
    case 33: "  setbe %r10b\n  setnp %r11b\n  andb %r11b, %r10b\n"
    case 34: "  seta %r10b\n"
    case _: "  setae %r10b\n"

@unsafe
def x185_float_text(name: String, +id: U32, buffer: String, +ids: N111Ids, +frame: X181Frame) -> String:
  x181_load(N111Local{buffer},ids,frame,"%r10") ++
    "  movq 0(%r10), %r11\n  movd %r11d, %xmm0\n  movq 8(%r10), %r11\n  movd %r11d, %xmm1\n" ++
    nt_choose(String,U32.is_lt(id,30),
      u => "  " ++ x185_float_arithmetic(id) ++ " %xmm1, %xmm0\n  movd %xmm0, %r10d\n",
      u => "  ucomiss %xmm1, %xmm0\n" ++ x185_float_compare(id) ++ "  movzbl %r10b, %r10d\n") ++
    x181_store(name,frame,"%r10")

@unsafe
def x185_float_probe(stmt: N111Stmt, +ids: N111Ids, +frame: X181Frame) -> String:
  match stmt:
    case N111Call{name,N111U64{},symbol,
      Con{N111Arg{N111Ptr{},N111Local{state}},Con{N111Arg{N111U32{},N111Const{+id,0}},Con{N111Arg{N111Ptr{},N111Local{buffer}},Con{N111Arg{N111U32{},N111Const{count,0}},Nil{}}}}}}:
      nt_choose(String,x185_float_enabled() && String.eq(symbol,"p111_rt_op") && String.eq(state,"state") &&
          U32.is_ge(id,26) && p112fp_supported(id,count),
        u => x185_float_text(name,id,buffer,ids,frame),u => "")
    case _: ""

@unsafe
def x185_float_call(+name: String, +typ: N111Type, +symbol: String, +args: List<&2,N111Arg>,
    +ids: N111Ids, +frame: X181Frame, code: X181Code) -> X181Code:
  +text = x185_float_probe(N111Call{name,typ,symbol,args},ids,frame)
  x181_add(nt_choose(String,String.is_empty(text),
    u => x181_call_text(symbol,args,ids,frame) ++
      nt_choose(String,U32.is_eq(p111v_type(typ),1),v => "  movl %eax, %eax\n",v => "") ++
      x181_store(name,frame,"%rax"),u => text),code)
