# The verified program object and its segment functions share one constructor
# dictionary. The runtime binds its three Ord constructors from that dictionary.
# Refuse any missing/malformed dictionary. This is distinct from an integer
# comparison which returns an unboxed Bool.
@unsafe
def x198ord_id(+key: KDef) -> Bool:
  String.eq(dk(key),"N111Id") && U32.is_eq(dx(key),0) && U32.is_lt(da(key),65536)

@unsafe
def x198ord_tag(+id: KDef,+reg: U32) -> X188Seq:
  x188_i2("movabsq",X187Imm{0,U32.add(16777216,U32.mul(256,da(id)))},x188_reg(reg,64))

@unsafe
def x198ord_eval(+word: Bool,lt: KDef,eq: KDef,gt: KDef) -> X188Seq:
  x188_many([
      nt_choose(X188Seq,word,v => x188_i2("movl",X187Mem{10,0},x188_reg(11,32)),v => x188_i2("movq",X187Mem{10,0},x188_reg(11,64))),
      nt_choose(X188Seq,word,v => x188_i2("cmpl",X187Mem{10,8},x188_reg(11,32)),v => x188_i2("cmpq",X187Mem{10,8},x188_reg(11,64))),
      x198ord_tag(eq,11),x198ord_tag(lt,10),x188_i2("cmovbq",x188_reg(10,64),x188_reg(11,64)),
      x198ord_tag(gt,10),x188_i2("cmovaq",x188_reg(10,64),x188_reg(11,64))])

@unsafe
def x198ord_apply(+word: Bool,+name: String,buffer: String,+lt: KDef,+eq: KDef,+gt: KDef,+ids: N111Ids,+frame: X181Frame) -> X188Seq:
  nt_choose(X188Seq,x198ord_id(lt) && x198ord_id(eq) && x198ord_id(gt) && Bool.not(U32.is_eq(da(lt),da(eq)) ||
      U32.is_eq(da(lt),da(gt)) || U32.is_eq(da(eq),da(gt))),u =>
    x188_many([x181_load(N111Local{buffer},ids,frame,x188_reg(10,64)),x198ord_eval(word,lt,eq,gt),
      x181_store(name,frame,x188_reg(11,64))]),u => X188Empty{})

@unsafe
def x198ord_probe(+stmt: N111Stmt,+ids: N111Ids,+frame: X181Frame) -> X188Seq:
  match stmt ids:
    case N111Call{name,N111U64{},symbol,Con{N111Arg{N111Ptr{},N111Local{state}},Con{N111Arg{N111U32{},N111Const{+op,0}},Con{N111Arg{N111Ptr{},N111Local{+buf}},Con{N111Arg{N111U32{},N111Const{2,0}},Nil{}}}}}} N111Ids{fs,+cs}:
      nt_choose(X188Seq,(U32.is_eq(op,22) || U32.is_eq(op,66)) && String.eq(symbol,"p111_rt_op") &&
        String.eq(state,"state") && Bool.not(String.eq(buf,"state")),u => x198ord_apply(U32.is_eq(op,22),name,buf,
          p111v_get(cs,"LT"),p111v_get(cs,"EQ"),p111v_get(cs,"GT"),ids,frame),u => X188Empty{})
    case _ _: X188Empty{}

@unsafe
def x198ord_select(+stmt: N111Stmt,+ids: N111Ids,+frame: X181Frame) -> X188Seq:
  +chosen = x198ord_probe(stmt,ids,frame)
  nt_choose(X188Seq,x188_empty(chosen),u => x186_u32_float_probe_when(x186_u32_float_enabled(),stmt,ids,frame),u => chosen)

@unsafe
def x186_u32_float_probe(stmt: N111Stmt, ids: N111Ids, frame: X181Frame) -> X188Seq:
  x198ord_select(stmt,ids,frame)
