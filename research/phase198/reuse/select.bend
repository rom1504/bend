# Typed SysV entry wrapper. The old worker is called with the original three
# physical arguments on every refusal. The two owned input words remain live
# through the guard and are published under the fresh parent on success.
def x198_perm_reg(n: U32) -> X187Operand: x188_reg(n,64)

def x198_perm_shape(+arg: U32, +id: U32, +slow: String) -> X188Seq:
  x188_many([x188_i2("movq",x198_perm_reg(arg),x198_perm_reg(0)),
    x188_i2("shrq",X187Imm{40,0},x198_perm_reg(0)),
    x188_i2("cmpl",X187Imm{U32.add(131072,id),0},x188_reg(0,32)),x188_i1("jne",X187Target{slow})])

def x198_perm_bound(+arg: U32, +loc: U32, +slow: String) -> X188Seq:
  x188_many([x188_i2("movq",x198_perm_reg(arg),x198_perm_reg(loc)),
    x188_i2("andq",x198_perm_reg(0),x198_perm_reg(loc)),
    x188_i2("cmpq",x198_perm_reg(1),x198_perm_reg(loc)),x188_i1("jb",X187Target{slow})])

def x198_perm_slot(+slot: U32) -> X187Operand:
  X187Indexed{10,nt_choose(U32,U32.is_lt(slot,2),u => 8,u => 9),8,U32.mul(U32.and(slot,1),8)}

def x198_perm_fast(+id: U32, +a: U32, +b: U32, +slow: String) -> X188Seq:
  x188_many([x198_perm_shape(6,id,slow),x198_perm_shape(2,id,slow),
    x188_i2("cmpq",x198_perm_reg(6),x198_perm_reg(2)),x188_i1("je",X187Target{slow}),
    x188_i2("movq",X187Rip{"p111_program",88,0},x198_perm_reg(1)),
    x188_i2("andq",X187Imm{9,0},x198_perm_reg(1)),
    x188_i2("cmpq",X187Imm{9,0},x198_perm_reg(1)),x188_i1("jne",X187Target{slow}),
    x188_i2("movq",X187Rip{"p111_program",64,0},x198_perm_reg(1)),
    x188_i2("addq",X187Imm{127,0},x198_perm_reg(1)),
    x188_i2("andq",X187Imm{4294967168,4294967295},x198_perm_reg(1)),
    x188_i2("addq",X187Imm{51413504,0},x198_perm_reg(1)),
    x188_i2("movabsq",X187Imm{4294967295,255},x198_perm_reg(0)),
    x198_perm_bound(6,8,slow),x198_perm_bound(2,9,slow),
    x188_i2("movq",X187Mem{7,0},x198_perm_reg(10)),
    x188_i2("movq",x198_perm_slot(a),x198_perm_reg(0)),x188_i2("movq",x198_perm_slot(b),x198_perm_reg(11)),
    x188_i2("movq",x198_perm_reg(11),x198_perm_slot(a)),x188_i2("movq",x198_perm_reg(0),x198_perm_slot(b)),
    x188_i2("subq",X187Imm{24,0},x198_perm_reg(4)),
    x188_i2("movq",x198_perm_reg(6),X187Mem{4,0}),x188_i2("movq",x198_perm_reg(2),X187Mem{4,8}),
    x188_i2("movl",X187Imm{id,0},x188_reg(6,32)),x188_i2("movq",x198_perm_reg(4),x198_perm_reg(2)),
    x188_i1("call",X187Target{"p125_rt_ctor2"}),x188_i2("addq",X187Imm{24,0},x198_perm_reg(4)),x188_i0("ret")])

def x198_perm_cid(ctor: String, ids: N111Ids) -> U32:
  match ids:
    case N111Ids{functions,ctors}: da(p111v_get(ctors,ctor))

def x198_perm_wrapper(+symbol: String, +slow: String, id: U32, a: U32, b: U32) -> X181Output:
  X181Output{[x188_many([X188One{PSection{1}},X188One{PGlobal{symbol}},X188One{PType{symbol,2}},
    X188One{PLabel{symbol}},x198_perm_fast(id,a,b,slow),X188One{PSize{symbol}}])],""}

@unsafe
def x198_perm_selected(plan: X198Perm, +symbol: String, +params: List<&2,String>, +setup: List<&2,P113DStmt>,
    +body: List<&2,P113DStmt>, +ids: N111Ids) -> X181Output:
  match plan:
    case X198Perm{+ctor,a,b}:
      +slow = "p198r_original_" ++ symbol
      nt_choose(X181Output,p185cc_known(ctor,2,ids),u => x181_program_join(
        x198_perm_wrapper(symbol,slow,x198_perm_cid(ctor,ids),a,b),x186_float_function(slow,params,setup,body,ids)),
        u => x186_float_function(symbol,params,setup,body,ids))
    case X198NoPerm{}: x186_float_function(symbol,params,setup,body,ids)
