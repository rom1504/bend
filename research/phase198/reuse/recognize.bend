# Symbolic execution of the selected path under an exact two-owner constructor
# guard. Only a private nonescaping scratch buffer and fixed-size ownership
# operations are admitted. Token zero is unavailable and always rejects.
type X198Perm is Data:
  X198NoPerm{}
  X198Perm{+ctor: String, +slot_a: U32, +slot_b: U32}

type X198Sym is Data:
  X198Refuse{}
  X198Sym{+env: KDef, +ctor: String, +taken: U32, +made: U32, +slot0: U32, +slot1: U32}

def x198_sym_bind(+env: KDef, name: String, token: U32) -> KDef:
  p111v_put(env,name,"X198Token",token,0)

def x198_sym_get(value: N111Value, env: KDef) -> U32:
  match value:
    case N111Local{name}: da(p111v_get(env,name))
    case _: 0

def x198_sym_range(+x: U32, low: U32, high: U32) -> Bool:
  U32.is_ge(x,low) && U32.is_le(x,high)

def x198_sym_assign(name: String, +t: U32, state: X198Sym) -> X198Sym:
  match state:
    case X198Sym{env,ctor,taken,made,s0,s1}:
      nt_choose(X198Sym,U32.is_gt(t,0),u => X198Sym{x198_sym_bind(env,name,t),ctor,taken,made,s0,s1},u => X198Refuse{})
    case _: X198Refuse{}

def x198_sym_bin(name: String, +op: String, +x: U32, y: N111Value, +s: X198Sym) -> X198Sym:
  match y s:
    case N111Const{40,0} _:
      nt_choose(X198Sym,String.eq(op,"shr") && x198_sym_range(x,1,2),u => x198_sym_assign(name,U32.add(10,x),s),u => X198Refuse{})
    case N111Const{65535,0} _:
      nt_choose(X198Sym,String.eq(op,"and") && x198_sym_range(x,11,12),u => x198_sym_assign(name,U32.add(10,x),s),u => X198Refuse{})
    case N111CtorId{+c} X198Sym{env,+ctor,taken,made,s0,s1}:
      nt_choose(X198Sym,String.eq(op,"eq") && x198_sym_range(x,21,22) && Bool.not(String.is_empty(c)) &&
          (String.is_empty(ctor) || String.eq(ctor,c)),
        u => X198Sym{x198_sym_bind(env,name,U32.add(10,x)),c,taken,made,s0,s1},u => X198Refuse{})
    case _ _: X198Refuse{}

def x198_sym_node(+a: U32, +b: U32) -> U32:
  nt_choose(U32,x198_sym_range(a,3,6) && x198_sym_range(b,3,6),
    u => U32.add(256,U32.add(U32.mul(U32.sub(a,3),4),U32.sub(b,3))),
    u => nt_choose(U32,x198_sym_range(a,256,271) && x198_sym_range(b,256,271),
      v => U32.add(512,U32.add(U32.mul(U32.sub(a,256),16),U32.sub(b,256))),v => 0))

def x198_sym_op(+name: String, +fun: String, arg: N111Arg, +s: X198Sym) -> X198Sym:
  match arg s:
    case N111Arg{N111U64{},word} X198Sym{+env,ctor,+taken,made,s0,s1}:
      +id = x198_sym_get(word,env)
      nt_choose(X198Sym,String.eq(fun,"p125_rt_take2") && x198_sym_range(id,1,2) && U32.is_eq(U32.and(taken,id),0),
        u => X198Sym{x198_sym_bind(env,name,9),ctor,U32.or(taken,id),made,U32.inc(U32.mul(2,id)),U32.add(2,U32.mul(2,id))},
        u => X198Refuse{})
    case N111Arg{N111U32{},N111CtorId{c}} X198Sym{env,+ctor,taken,+made,+s0,+s1}:
      +v = x198_sym_node(s0,s1)
      nt_choose(X198Sym,String.eq(fun,"p125_rt_ctor2") && Bool.not(String.is_empty(ctor)) && String.eq(ctor,c) &&
          U32.is_lt(made,3) && U32.is_gt(v,0),
        u => X198Sym{x198_sym_bind(env,name,v),ctor,taken,U32.inc(made),s0,s1},u => X198Refuse{})
    case _ _: X198Refuse{}

def x198_sym_call(+name: String, +fun: String, args: List<&2,N111Arg>, +s: X198Sym) -> X198Sym:
  match args s:
    case Con{N111Arg{N111Ptr{},sv},Con{av,Con{N111Arg{N111Ptr{},buf},Nil{}}}} X198Sym{+env,ctor,taken,made,s0,s1}:
      nt_choose(X198Sym,U32.is_eq(x198_sym_get(sv,env),7) && U32.is_eq(x198_sym_get(buf,env),8),
        u => x198_sym_op(name,fun,av,s),u => X198Refuse{})
    case _ _: X198Refuse{}

def x198_sym_step(stmt: N111Stmt, +s: X198Sym) -> X198Sym:
  match stmt s:
    case N111Bin{name,N111U64{},op,x,y} X198Sym{env,ctor,taken,made,s0,s1}:
      x198_sym_bin(name,op,x198_sym_get(x,env),y,s)
    case N111Set{name,N111U64{},v} X198Sym{env,ctor,taken,made,s0,s1}:
      x198_sym_assign(name,x198_sym_get(v,env),s)
    case N111Load{name,N111U64{},base,+off} X198Sym{env,ctor,taken,made,s0,s1}:
      nt_choose(X198Sym,U32.is_eq(x198_sym_get(base,env),8) && (U32.is_eq(off,0) || U32.is_eq(off,8)),
        u => x198_sym_assign(name,nt_choose(U32,U32.is_eq(off,0),v => s0,v => s1),s),u => X198Refuse{})
    case N111Store{N111U64{},base,+off,v} X198Sym{+env,ctor,taken,made,s0,s1}:
      +value = x198_sym_get(v,env)
      nt_choose(X198Sym,U32.is_eq(x198_sym_get(base,env),8) && U32.is_gt(value,0) && (U32.is_eq(off,0) || U32.is_eq(off,8)),
        u => X198Sym{env,ctor,taken,made,nt_choose(U32,U32.is_eq(off,0),v => value,v => s0),
          nt_choose(U32,U32.is_eq(off,8),v => value,v => s1)},u => X198Refuse{})
    case N111Call{name,N111U64{},fun,args} _: x198_sym_call(name,fun,args,s)
    case N111Alloca{+name,bytes,align} X198Sym{env,ctor,taken,made,s0,s1}:
      # A fixed x86 frame declaration emits no target instruction. Refuse a
      # redeclaration of a parameter / known symbolic scalar.
      nt_choose(X198Sym,U32.is_eq(da(p111v_get(env,name)),0) || String.eq(name,"scratch"),u => s,u => X198Refuse{})
    case _ _: X198Refuse{}

def x198_perm_spec(+ctor: String, value: U32) -> X198Perm:
  # Base-4 digits encode the original index occupying each destination.
  # Admit precisely one pair exchange; duplicated, lost or reordered extra
  # fields cannot match these six bijections.
  match value:
    case 587: X198Perm{ctor,0,1}
    case 659: X198Perm{ctor,0,2}
    case 728: X198Perm{ctor,0,3}
    case 551: X198Perm{ctor,1,2}
    case 569: X198Perm{ctor,1,3}
    case 542: X198Perm{ctor,2,3}
    case _: X198NoPerm{}

@unsafe
def x198_sym_walk(rows: List<&2,P113DStmt>, +s: X198Sym, +steps: U32) -> X198Perm:
  match rows s:
    case Con{P113DResult{Con{v,Nil{}}},Nil{}} X198Sym{env,ctor,3,3,s0,s1}:
      x198_perm_spec(ctor,x198_sym_get(v,env))
    case Con{P113DScalar{stmt},rest} X198Sym{env,ctor,taken,made,s0,s1}:
      nt_choose(X198Perm,U32.is_lt(steps,64),u => x198_sym_walk(rest,x198_sym_step(stmt,s),U32.inc(steps)),u => X198NoPerm{})
    case Con{P113DIf{test,yes,no},Nil{}} X198Sym{env,ctor,taken,made,s0,s1}:
      nt_choose(X198Perm,U32.is_lt(steps,64) && x198_sym_range(x198_sym_get(test,env),31,32),
        u => x198_sym_walk(yes,s,U32.inc(steps)),u => X198NoPerm{})
    case _ _: X198NoPerm{}

@unsafe
def x198_perm_pick(+params: List<&2,String>, setup: List<&2,P113DStmt>, body: List<&2,P113DStmt>) -> X198Perm:
  match params setup:
    case Con{+state,Con{+a,Con{+b,Nil{}}}} Nil{}:
      nt_choose(X198Perm,String.eq(state,"state") && Bool.not(String.eq(a,b) || String.eq(a,state) || String.eq(b,state) ||
          String.eq(a,"scratch") || String.eq(b,"scratch") || String.starts_with(a,"__x181") || String.starts_with(b,"__x181")),
        u => x198_sym_walk(body,X198Sym{x198_sym_bind(x198_sym_bind(x198_sym_bind(x198_sym_bind(missing(),state,7),a,1),b,2),"scratch",8),"",0,0,0,0},0),
        u => X198NoPerm{})
    case _ _: X198NoPerm{}
