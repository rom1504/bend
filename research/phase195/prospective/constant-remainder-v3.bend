# Experimental only. Generic nonzero U32 remainder by certified literal.
# This module has NOT been source-checked or executed. Reuses original scratch
# facts and ordinary integer IR; no new machine instruction or hidden local.
# Zero/one and unsuccessful reciprocal searches preserve the original call.
type X195RemMagic is Data:
  X195RemNone{}
  X195RemMagic{+multiplier: U32, +shift: U32}

# Let q=floor(2^(32+s)/d), r=2^(32+s) mod d, m=q+(r!=0),
# e=m*d-2^(32+s). Admit e<=2^s and m<=MAX. For every n<2^32,
# 0<=n*e/(d*2^(32+s))<1/d; this is less than the smallest
# distance to the next quotient, so floor(n*m/2^(32+s))=floor(n/d).
# All certificate construction uses bounded U32 arithmetic, never large Nat
# recursion. Doubling r uses r>=d-r to avoid unsigned overflow.
law x195rem_search:
  for +d: U32
  for +q: U32
  for +r: U32
  for +power: U32
  for +shift: U32
  X195RemMagic

@unsafe
def x195rem_next(+d: U32, +q: U32, +r: U32, +power: U32, +shift: U32) -> X195RemMagic:
  nt_choose(X195RemMagic,U32.is_ge(r,U32.sub(d,r)),
    u => x195rem_search(d,U32.inc(U32.mul(q,2)),U32.sub(r,U32.sub(d,r)),power,shift),
    u => x195rem_search(d,U32.mul(q,2),U32.mul(r,2),power,shift))

@unsafe
def x195rem_search(d,q,r,power,shift):
  nt_choose(X195RemMagic,U32.is_eq(r,0),u => X195RemMagic{q,shift},u =>
    nt_choose(X195RemMagic,U32.is_eq(q,4294967295),v => X195RemNone{},v =>
      nt_choose(X195RemMagic,U32.is_le(U32.sub(d,r),power),w => X195RemMagic{U32.inc(q),shift},w =>
        nt_choose(X195RemMagic,U32.is_lt(shift,63) && U32.is_le(q,2147483647),
          z => x195rem_next(d,q,r,U32.mul(power,2),U32.inc(shift)),z => X195RemNone{}))))

@unsafe
def x195rem_start(+d: U32, +q: U32, +r: U32) -> X195RemMagic:
  nt_choose(X195RemMagic,U32.is_eq(r,U32.sub(d,1)),
    u => x195rem_search(d,U32.inc(q),0,1,32),
    u => x195rem_search(d,q,U32.inc(r),1,32))

@unsafe
def x195rem_magic(+divisor: U32) -> X195RemMagic:
  nt_choose(X195RemMagic,U32.is_gt(divisor,1),
    u => x195rem_start(divisor,U32.div(4294967295,divisor),U32.mod(4294967295,divisor)),
    u => X195RemNone{})

# Destination cannot overwrite the numerator before its final subtraction.
# Other original locals are not modified. Low32 normalization precedes MUL64;
# multiplier<=2^32-1 guarantees the product fits in an unsigned64 word.
@unsafe
def x195rem_numerator(value: N111Value, name: String) -> Bool:
  match value:
    case N111Local{source}: Bool.not(String.eq(source,name))
    case N111Const{lo,hi}: True{}
    case _: False{}

@unsafe
def x195rem_expand(original: N111Stmt, +name: String, +left: N111Value,
    +divisor: U32, magic: X195RemMagic) -> List<&2,N111Stmt>:
  match magic:
    case X195RemNone{}: [original]
    case X195RemMagic{m,k}:
      [N111Bin{name,N111U64{},"and",left,N111Const{4294967295,0}},
       N111Bin{name,N111U64{},"mul",N111Local{name},N111Const{m,0}},
       N111Bin{name,N111U64{},"shr",N111Local{name},N111Const{k,0}},
       N111Bin{name,N111U32{},"mul",N111Local{name},N111Const{divisor,0}},
       N111Bin{name,N111U32{},"sub",left,N111Local{name}}]

@unsafe
def x195rem_values(+original: N111Stmt, +name: String,
    a: Maybe<&2,N111Value>, b: Maybe<&2,N111Value>) -> List<&2,N111Stmt>:
  match a b:
    case Some{+left} Some{N111Const{+divisor,0}}:
      nt_choose(List<&2,N111Stmt>,x195rem_numerator(left,name),
        u => x195rem_expand(original,name,left,divisor,x195rem_magic(divisor)),u => [original])
    case _ _: [original]

@unsafe
def x195rem_scalar(+stmt: N111Stmt, +facts: List<&2,X185ScratchCell>) -> List<&2,N111Stmt>:
  match stmt:
    case N111Call{+name,N111U64{},+symbol,
      Con{N111Arg{N111Ptr{},N111Local{+state}},
      Con{N111Arg{N111U32{},N111Const{19,0}},
      Con{N111Arg{N111Ptr{},N111Local{+buffer}},
      Con{N111Arg{N111U32{},N111Const{2,0}},Nil{}}}}}}:
      nt_choose(List<&2,N111Stmt>,String.eq(symbol,"p111_rt_op") && String.eq(state,"state") &&
          Bool.not(String.eq(buffer,"state")),u =>
        x195rem_values(stmt,name,x185_sf_find(facts,buffer,0,N111U64{}),
          x185_sf_find(facts,buffer,8,N111U64{})),u => [stmt])
    case _: [stmt]

law x195rem_walk:
  for body: List<&2,P113DStmt>
  for +buffers: KDef
  for +facts: List<&2,X185ScratchCell>
  List<&2,P113DStmt>

@unsafe
def x195rem_walk(body,buffers,facts):
  match body:
    case Nil{}: []
    case Con{P113DScalar{N111If{condition,yes,no}},rest}:
      Con{P113DIf{condition,x195rem_walk(x181_scalar_rows(yes),buffers,[]),
        x195rem_walk(x181_scalar_rows(no),buffers,[])},x195rem_walk(rest,buffers,[])}
    case Con{P113DIf{condition,yes,no},rest}:
      Con{P113DIf{condition,x195rem_walk(yes,buffers,[]),x195rem_walk(no,buffers,[])},
        x195rem_walk(rest,buffers,[])}
    case Con{P113DScalar{+stmt},rest}:
      nt_append(P113DStmt,x181_scalar_rows(x195rem_scalar(stmt,facts)),
        x195rem_walk(rest,buffers,x186_f_facts(x185_sf_scalar(stmt,buffers,facts))))
    case Con{head,rest}: Con{head,x195rem_walk(rest,buffers,[])}

@unsafe
def x195rem_body(+params: List<&2,String>, +setup: List<&2,P113DStmt>, +body: List<&2,P113DStmt>) -> List<&2,P113DStmt>:
  x195rem_walk(body,x186_f_buffers(params,setup,body),[])
