# The independent verifier establishes the foreign primitive ABI before this pass.
# A successful probe carries the pointer to exactly the original argument buffer.
type X198WOp is Data:
  X198WNone{}
  X198WOp{+name: String,+buffer: String,+id: U32}

@unsafe
def x198w_op(stmt: N111Stmt) -> X198WOp:
  match stmt:
    case N111Call{name,N111U64{},symbol,
      Con{N111Arg{N111Ptr{},N111Local{state}},Con{N111Arg{N111U32{},N111Const{+id,0}},
      Con{N111Arg{N111Ptr{},N111Local{+buf}},Con{N111Arg{N111U32{},N111Const{+n,0}},Nil{}}}}}}:
      nt_choose(X198WOp,String.eq(symbol,"p111_rt_op") && String.eq(state,"state") && Bool.not(String.eq(buf,"state")) &&
        ((U32.is_eq(n,1) && (U32.is_eq(id,24) || U32.is_eq(id,25))) ||
         (U32.is_eq(n,2) && (U32.is_eq(id,63) || U32.is_eq(id,67)))),
        u => X198WOp{name,buf,id},u => X198WNone{})
    case _: X198WNone{}

@unsafe
def x198w_lt(dest: String,x: N111Value,other: Maybe<&2,N111Value>) -> Maybe<&2,N111Stmt>:
  match other:
    case Some{y}: Some{N111Bin{dest,N111U64{},"ult",x,y}}
    case _: None{}

# ABI11102 opcode 24 is a full-word copy, whereas 25 zeros the high word.
# Only substitute the stored source when its exact snapshot still dominates.
@unsafe
def x198w_found(+dest: String,+buf: String,+id: U32,+facts: List<&2,X185ScratchCell>,found: Maybe<&2,N111Value>) -> Maybe<&2,N111Stmt>:
  match found:
    case Some{+x}:
      nt_choose(Maybe<&2,N111Stmt>,U32.is_eq(id,24),u => Some{N111Set{dest,N111U64{},x}},u =>
        nt_choose(Maybe<&2,N111Stmt>,U32.is_eq(id,25),v => Some{N111Bin{dest,N111U64{},"and",x,N111Const{4294967295,0}}},v =>
          nt_choose(Maybe<&2,N111Stmt>,U32.is_eq(id,67),w =>
            x198w_lt(dest,x,x185_sf_find(facts,buf,8,N111U64{})),w => None{})))
    case _: None{}

@unsafe
def x198w_known(op: X198WOp,+facts: List<&2,X185ScratchCell>) -> Maybe<&2,N111Stmt>:
  match op:
    case X198WOp{dest,+buf,id}: x198w_found(dest,buf,id,facts,x185_sf_find(facts,buf,0,N111U64{}))
    case _: None{}

@unsafe
def x198w_step(replacement: Maybe<&2,N111Stmt>,stmt: N111Stmt,buffers: KDef,facts: List<&2,X185ScratchCell>) -> X185ScratchStep:
  match replacement:
    case Some{repl}: x185_sf_scalar(repl,buffers,facts)
    case _: x185_sf_scalar(stmt,buffers,facts)

@unsafe
def x198w_fact(+stmt: N111Stmt,+buffers: KDef,+facts: List<&2,X185ScratchCell>) -> X185ScratchStep:
  match stmt:
    case N111Call{name,ty,symbol,args}:
      x198w_step(x198w_known(x198w_op(stmt),facts),stmt,buffers,facts)
    case _: x185_sf_scalar(stmt,buffers,facts)

@unsafe
def x185_sf_body(body,buffers,facts):
  match body:
    case Nil{}: []
    case Con{P113DScalar{N111If{condition,yes,no}},rest}:
      x185_sf_if(condition,x181_scalar_rows(yes),x181_scalar_rows(no),rest,buffers)
    case Con{P113DIf{condition,yes,no},rest}: x185_sf_if(condition,yes,no,rest,buffers)
    case Con{P113DScalar{stmt},rest}: x185_sf_after(rest,buffers,x198w_fact(stmt,buffers,facts))
    case Con{head,rest}: Con{head,x185_sf_body(rest,buffers,[])}
