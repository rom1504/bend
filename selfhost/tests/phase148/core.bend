# Private Phase148 codec. Array slots are bounded by the producer, not by
# native Array indexing (which intentionally wraps). No production override.
type P148Tape is Type:
  P148Tape{words: Array<U32>, values: Array<U32>, names: Array<String>,
    +used: U32, +valueUsed: U32, +nameUsed: U32}

type P148Unit is Type:
  P148Good{+name: String, +params: List<&2,NC_Binding>, +result: U32,
    +public: Bool, tape: P148Tape}
  P148Bad{+error: String}

type P148Size is Data:
  P148Size{words: U32, values: U32, names: U32, +statements: U32}

type P148Build is Type:
  P148Build{tape: P148Tape, +index: P147VTable, +wordLimit: U32,
    +valueLimit: U32, +nameLimit: U32, +error: String}

type P148Ref is Type:
  P148Ref{build: P148Build, +ref: U32}

# Forward signatures only for mutually recursive walkers.

law p148c_scalar_size:
  for stmt: N111Stmt
  P148Size

law p148c_direct_size:
  for stmt: P113DStmt
  P148Size

law p148c_encode_args:
  for args: List<&2,N111Arg>
  for +at: U32
  for build: P148Build
  P148Build

law p148c_encode_values:
  for values: List<&2,N111Value>
  for +at: U32
  for build: P148Build
  P148Build

law p148c_encode_names:
  for names: List<&2,String>
  for +at: U32
  for build: P148Build
  P148Build

law p148c_encode_params:
  for params: List<&2,NC_Binding>
  for build: P148Build
  P148Build

law p148c_encode_scalars:
  for body: List<&2,N111Stmt>
  for build: P148Build
  P148Build

law p148c_encode_body:
  for body: List<&2,P113DStmt>
  for build: P148Build
  P148Build

law p148c_decode_scalars:
  for +words: Array<U32>
  for +values: Array<U32>
  for +names: Array<String>
  for +used: U32
  for +valueUsed: U32
  for +nameUsed: U32
  for +at: U32
  for +end: U32
  List<&2,N111Stmt>

law p148c_decode_scalar:
  for +words: Array<U32>
  for +values: Array<U32>
  for +names: Array<String>
  for +used: U32
  for +valueUsed: U32
  for +nameUsed: U32
  for +pc: U32
  N111Stmt

law p148c_decode_body:
  for +words: Array<U32>
  for +values: Array<U32>
  for +names: Array<String>
  for +used: U32
  for +valueUsed: U32
  for +nameUsed: U32
  for +at: U32
  for +end: U32
  List<&2,P113DStmt>

law p148c_decode_direct:
  for +words: Array<U32>
  for +values: Array<U32>
  for +names: Array<String>
  for +used: U32
  for +valueUsed: U32
  for +nameUsed: U32
  for +pc: U32
  for tag: U32
  P113DStmt

law p148c_stmt_count:
  for +words: Array<U32>
  for +values: Array<U32>
  for +names: Array<String>
  for +used: U32
  for +valueUsed: U32
  for +nameUsed: U32
  for +at: U32
  for +end: U32
  U32

def p148c_limit() -> U32: 1048576

@unsafe
def p148w_take(pair: Array<U32> & U32) -> U32:
  match pair:
    case Tuple{data,value}: value

@unsafe
def p148w_get(+data: Array<U32>, at: U32) -> U32:
  p148w_take(Array.get(U32,data,at))

@unsafe
def p148w_set(data: Array<U32>, at: U32, value: U32) -> Array<U32>:
  Array.set(U32,data,at,value)

@unsafe
def p148w_new(words: U32) -> Array<U32>:
  Array.new(U32,p88_array_depth(words,1,0n),0)

@unsafe
def p148w_clone(data: Array<U32>) -> Array<U32> & Array<U32>:
  Array.clone(U32,data)

@unsafe
def p148n_take(pair: Array<String> & String) -> String:
  match pair:
    case Tuple{names,value}: value

@unsafe
def p148n_get(+names: Array<String>, id: U32) -> String:
  p148n_take(Array.get(String,names,id))

@unsafe
def p148c_find_at(+names: Array<String>, +used: U32, +name: String, +at: U32) -> U32:
  nt_choose(U32,U32.is_ge(at,used),u => used,u =>
    nt_choose(U32,String.eq(p148n_get(names,at),name),v => at,
      v => p148c_find_at(names,used,name,U32.inc(at))))

@unsafe
def p148c_find_name(+names: Array<String>, +used: U32, +name: String) -> U32:
  p148c_find_at(names,used,name,0)

# Every count is <= limit+1, so this addition cannot wrap U32.
@unsafe
def p148c_add(+a: U32, +b: U32) -> U32:
  nt_choose(U32,U32.is_le(U32.add(a,b),p148c_limit()),
    u => U32.add(a,b),u => U32.inc(p148c_limit()))

@unsafe
def p148c_sizes(a: P148Size, b: P148Size) -> P148Size:
  match a b:
    case P148Size{aw,av,an,astmts} P148Size{bw,bv,bn,bstmts}:
      P148Size{p148c_add(aw,bw),p148c_add(av,bv),p148c_add(an,bn),p148c_add(astmts,bstmts)}

@unsafe
def p148c_value_size(value: N111Value) -> P148Size:
  match value:
    case N111Const{lo,hi}: P148Size{0,3,0,0}
    case _: P148Size{0,3,1,0}

@unsafe
def p148c_values_size(values: List<&2,N111Value>) -> P148Size:
  match values:
    case Nil{}: P148Size{0,0,0,0}
    case Con{value,rest}:
      p148c_sizes(P148Size{1,0,0,0},p148c_sizes(p148c_value_size(value),p148c_values_size(rest)))

@unsafe
def p148c_args_size(args: List<&2,N111Arg>) -> P148Size:
  match args:
    case Nil{}: P148Size{0,0,0,0}
    case Con{N111Arg{typ,value},rest}:
      p148c_sizes(P148Size{2,0,0,0},p148c_sizes(p148c_value_size(value),p148c_args_size(rest)))

@unsafe
def p148c_names_size(names: List<&2,String>) -> P148Size:
  match names:
    case Nil{}: P148Size{0,0,0,0}
    case Con{name,rest}: p148c_sizes(P148Size{1,0,1,0},p148c_names_size(rest))

@unsafe
def p148c_params_size(params: List<&2,NC_Binding>) -> U32:
  match params:
    case Nil{}: 0
    case Con{head,rest}: p148c_add(1,p148c_params_size(rest))

@unsafe
def p148c_scalars_size(body: List<&2,N111Stmt>) -> P148Size:
  match body:
    case Nil{}: P148Size{0,0,0,0}
    case Con{head,rest}: p148c_sizes(p148c_scalar_size(head),p148c_scalars_size(rest))

@unsafe
def p148c_scalar_size(stmt):
  match stmt:
    case N111Set{name,typ,value}: p148c_sizes(P148Size{8,0,1,1},p148c_value_size(value))
    case N111Bin{name,typ,op,left,right}:
      p148c_sizes(P148Size{8,0,2,1},p148c_sizes(p148c_value_size(left),p148c_value_size(right)))
    case N111Call{name,typ,symbol,args}: p148c_sizes(P148Size{8,0,2,1},p148c_args_size(args))
    case N111If{condition,yes,no}:
      p148c_sizes(P148Size{8,0,0,1},p148c_sizes(p148c_value_size(condition),
        p148c_sizes(p148c_scalars_size(yes),p148c_scalars_size(no))))
    case N111Return{value}: p148c_sizes(P148Size{8,0,0,1},p148c_value_size(value))
    case N111Load{name,typ,base,offset}: p148c_sizes(P148Size{8,0,1,1},p148c_value_size(base))
    case N111Store{typ,base,offset,value}:
      p148c_sizes(P148Size{8,0,0,1},p148c_sizes(p148c_value_size(base),p148c_value_size(value)))
    case N111Offset{name,base,bytes}:
      p148c_sizes(P148Size{8,0,1,1},p148c_sizes(p148c_value_size(base),p148c_value_size(bytes)))
    case N111Alloca{name,bytes,align}: P148Size{8,0,1,1}

@unsafe
def p148c_body_size(body: List<&2,P113DStmt>) -> P148Size:
  match body:
    case Nil{}: P148Size{0,0,0,0}
    case Con{head,rest}: p148c_sizes(p148c_direct_size(head),p148c_body_size(rest))

@unsafe
def p148c_direct_size(stmt):
  match stmt:
    case P113DScalar{scalar}: p148c_scalar_size(scalar)
    case P113DIf{condition,yes,no}:
      p148c_sizes(P148Size{8,0,0,1},p148c_sizes(p148c_value_size(condition),
        p148c_sizes(p148c_body_size(yes),p148c_body_size(no))))
    case P113DCall{destinations,target,args}:
      p148c_sizes(P148Size{8,0,1,1},p148c_sizes(p148c_names_size(destinations),p148c_values_size(args)))
    case P113DResult{values}: p148c_sizes(P148Size{8,0,0,1},p148c_values_size(values))
    case P113DAgain{values}: p148c_sizes(P148Size{8,0,0,1},p148c_values_size(values))

@unsafe
def p148c_position(build: P148Build) -> P148Ref:
  match build:
    case P148Build{P148Tape{words,values,names,+used,valueUsed,nameUsed},index,wc,vc,nc,error}:
      P148Ref{P148Build{P148Tape{words,values,names,used,valueUsed,nameUsed},index,wc,vc,nc,error},used}

@unsafe
def p148c_reserve(+count: U32, build: P148Build) -> P148Ref:
  match build:
    case P148Build{P148Tape{+words,+values,+names,+used,valueUsed,nameUsed},index,+wc,vc,nc,error}:
      nt_choose(P148Ref,U32.is_le(count,wc) && U32.is_le(used,U32.sub(wc,count)),
        u => P148Ref{P148Build{P148Tape{words,values,names,U32.add(used,count),valueUsed,nameUsed},index,wc,vc,nc,error},used},
        u => P148Ref{P148Build{P148Tape{words,values,names,used,valueUsed,nameUsed},index,wc,vc,nc,"phase148 word capacity"},0})

@unsafe
def p148c_word(build: P148Build, +at: U32, value: U32) -> P148Build:
  match build:
    case P148Build{P148Tape{+words,+values,+names,+used,valueUsed,nameUsed},index,+wc,vc,nc,error}:
      nt_choose(P148Build,U32.is_lt(at,used) && U32.is_lt(at,wc),
        u => P148Build{P148Tape{p148w_set(words,at,value),values,names,used,valueUsed,nameUsed},index,wc,vc,nc,error},
        u => P148Build{P148Tape{words,values,names,used,valueUsed,nameUsed},index,wc,vc,nc,"phase148 word write"})

@unsafe
def p148c_intern_fact(+name: String, build: P148Build, fact: P147VFact) -> P148Ref:
  match build fact:
    case _ P147VFact{word,id,kind,width,capacity}: P148Ref{build,id}
    case P148Build{P148Tape{+words,+values,+names,used,valueUsed,+nameUsed},index,wc,vc,+nc,error} _:
      nt_choose(P148Ref,U32.is_lt(nameUsed,nc),
        u => P148Ref{P148Build{P148Tape{words,values,Array.set(String,names,nameUsed,name),used,valueUsed,U32.inc(nameUsed)},
          p147v_put(index,name,nameUsed,0,0,0),wc,vc,nc,error},nameUsed},
        u => P148Ref{P148Build{P148Tape{words,values,names,used,valueUsed,nameUsed},index,wc,vc,nc,"phase148 name capacity"},0})

@unsafe
def p148c_intern(+name: String, build: P148Build) -> P148Ref:
  match build:
    case P148Build{tape,+index,wc,vc,nc,error}:
      p148c_intern_fact(name,P148Build{tape,index,wc,vc,nc,error},p147v_get(index,name))

@unsafe
def p148c_value_words(build: P148Build, kind: U32, lo: U32, hi: U32) -> P148Ref:
  match build:
    case P148Build{P148Tape{+words,+values,+names,used,+valueUsed,nameUsed},index,wc,+vc,nc,error}:
      nt_choose(P148Ref,U32.is_ge(vc,3) && U32.is_le(valueUsed,U32.sub(vc,3)),
        u => P148Ref{P148Build{P148Tape{words,
          p148w_set(p148w_set(p148w_set(values,valueUsed,kind),U32.inc(valueUsed),lo),U32.add(valueUsed,2),hi),
          names,used,U32.add(valueUsed,3),nameUsed},index,wc,vc,nc,error},valueUsed},
        u => P148Ref{P148Build{P148Tape{words,values,names,used,valueUsed,nameUsed},index,wc,vc,nc,"phase148 value capacity"},0})

@unsafe
def p148c_step28(+kind: U32, pair: P148Ref) -> P148Ref:
  match pair:
    case P148Ref{next,id}: p148c_value_words(next,kind,id,0)
@unsafe
def p148c_value_named(kind: U32, name: String, build: P148Build) -> P148Ref:
  p148c_step28(kind,p148c_intern(name,build))

@unsafe
def p148c_value(value: N111Value, build: P148Build) -> P148Ref:
  match value:
    case N111Local{name}: p148c_value_named(1,name,build)
    case N111Const{lo,hi}: p148c_value_words(build,2,lo,hi)
    case N111Symbol{name}: p148c_value_named(3,name,build)
    case N111FuncId{name}: p148c_value_named(4,name,build)
    case N111CtorId{name}: p148c_value_named(5,name,build)

@unsafe
def p148c_header(build: P148Build, +at: U32, tag: U32, dest: U32,
    first: U32, second: U32, aux0: U32, aux1: U32, payload: U32, next: U32) -> P148Build:
  match build:
    case P148Build{P148Tape{+words,+values,+names,+used,valueUsed,nameUsed},index,+wc,vc,nc,error}:
      nt_choose(P148Build,U32.is_ge(used,8) && U32.is_ge(wc,8) &&
          U32.is_le(at,U32.sub(used,8)) && U32.is_le(at,U32.sub(wc,8)),
        u => P148Build{P148Tape{
          p148w_set(p148w_set(p148w_set(p148w_set(p148w_set(p148w_set(p148w_set(p148w_set(
            words,at,tag),U32.inc(at),dest),U32.add(at,2),first),U32.add(at,3),second),
            U32.add(at,4),aux0),U32.add(at,5),aux1),U32.add(at,6),payload),U32.add(at,7),next),
          values,names,used,valueUsed,nameUsed},index,wc,vc,nc,error},
        u => P148Build{P148Tape{words,values,names,used,valueUsed,nameUsed},index,wc,vc,nc,"phase148 header write"})

@unsafe
def p148c_header_here(build: P148Build, at: U32, tag: U32, dest: U32,
    first: U32, second: U32, aux0: U32, aux1: U32, payload: U32) -> P148Build:
  match build:
    case P148Build{P148Tape{words,values,names,+used,valueUsed,nameUsed},index,wc,vc,nc,error}:
      p148c_header(P148Build{P148Tape{words,values,names,used,valueUsed,nameUsed},index,wc,vc,nc,error},
        at,tag,dest,first,second,aux0,aux1,payload,used)

@unsafe
def p148c_typed(tag: U32, typ: N111Type) -> U32:
  U32.add(tag,U32.mul(256,p111v_type(typ)))

@unsafe
def p148c_step27(+at: U32, +typ: N111Type, +rest: List<&2,N111Arg>, pair: P148Ref) -> P148Build:
  match pair:
    case P148Ref{next,ref}:
      p148c_encode_args(rest,U32.add(at,2),p148c_word(p148c_word(next,at,p111v_type(typ)),U32.inc(at),ref))

@unsafe
def p148c_encode_args(args,at,build):
  match args:
    case Nil{}: build
    case Con{N111Arg{typ,value},rest}:
      p148c_step27(at,typ,rest,p148c_value(value,build))

@unsafe
def p148c_step26(+at: U32, +rest: List<&2,N111Value>, pair: P148Ref) -> P148Build:
  match pair:
    case P148Ref{next,ref}: p148c_encode_values(rest,U32.inc(at),p148c_word(next,at,ref))

@unsafe
def p148c_encode_values(values,at,build):
  match values:
    case Nil{}: build
    case Con{value,rest}:
      p148c_step26(at,rest,p148c_value(value,build))

@unsafe
def p148c_step25(+at: U32, +rest: List<&2,String>, pair: P148Ref) -> P148Build:
  match pair:
    case P148Ref{next,id}: p148c_encode_names(rest,U32.inc(at),p148c_word(next,at,id))

@unsafe
def p148c_encode_names(names,at,build):
  match names:
    case Nil{}: build
    case Con{name,rest}:
      p148c_step25(at,rest,p148c_intern(name,build))

@unsafe
def p148c_step24(+rest: List<&2,NC_Binding>, pair: P148Ref) -> P148Build:
  match pair:
    case P148Ref{next,id}: p148c_encode_params(rest,next)

@unsafe
def p148c_encode_params(params,build):
  match params:
    case Nil{}: build
    case Con{NC_Binding{id,name,kind},rest}:
      p148c_step24(rest,p148c_intern(name,build))

@unsafe
def p148c_step20(+tag: U32, +aux0: U32, +aux1: U32, +at: U32, +id: U32, pair: P148Ref) -> P148Build:
  match pair:
    case P148Ref{done,ref}: p148c_header_here(done,at,tag,id,ref,0,aux0,aux1,0)

@unsafe
def p148c_step21(+tag: U32, +value: N111Value, +aux0: U32, +aux1: U32, +at: U32, pair: P148Ref) -> P148Build:
  match pair:
    case P148Ref{next,id}:
      p148c_step20(tag,aux0,aux1,at,id,p148c_value(value,next))

@unsafe
def p148c_named_one(tag: U32, name: String, value: N111Value, aux0: U32, aux1: U32,
    at: U32, build: P148Build) -> P148Build:
  p148c_step21(tag,value,aux0,aux1,at,p148c_intern(name,build))

@unsafe
def p148c_step17(+tag: U32, +aux0: U32, +at: U32, +id: U32, +a: U32, pair: P148Ref) -> P148Build:
  match pair:
    case P148Ref{done,b}: p148c_header_here(done,at,tag,id,a,b,aux0,0,0)

@unsafe
def p148c_step18(+tag: U32, +right: N111Value, +aux0: U32, +at: U32, +id: U32, pair: P148Ref) -> P148Build:
  match pair:
    case P148Ref{after,a}:
      p148c_step17(tag,aux0,at,id,a,p148c_value(right,after))

@unsafe
def p148c_step19(+tag: U32, +left: N111Value, +right: N111Value, +aux0: U32, +at: U32, pair: P148Ref) -> P148Build:
  match pair:
    case P148Ref{next,id}:
      p148c_step18(tag,right,aux0,at,id,p148c_value(left,next))

@unsafe
def p148c_named_two(tag: U32, name: String, left: N111Value, right: N111Value,
    aux0: U32, at: U32, build: P148Build) -> P148Build:
  p148c_step19(tag,left,right,aux0,at,p148c_intern(name,build))

@unsafe
def p148c_step16(+at: U32, +name: String, +typ: N111Type, +left: N111Value, +right: N111Value, pair: P148Ref) -> P148Build:
  match pair:
    case P148Ref{next,id}: p148c_named_two(p148c_typed(2,typ),name,left,right,id,at,next)

@unsafe
def p148c_call_done(tag: U32, id: U32, symbol: U32, count: U32, at: U32,
    payload: U32, build: P148Build) -> P148Build:
  p148c_header_here(build,at,tag,id,0,0,symbol,count,payload)

@unsafe
def p148c_step8(+tag: U32, +args: List<&2,N111Arg>, +count: U32, +at: U32, +id: U32, +sym: U32, pair: P148Ref) -> P148Build:
  match pair:
    case P148Ref{last,+payload}:
      p148c_call_done(tag,id,sym,count,at,payload,p148c_encode_args(args,payload,last))

@unsafe
def p148c_step9(+tag: U32, +args: List<&2,N111Arg>, +count: U32, +at: U32, +id: U32, pair: P148Ref) -> P148Build:
  match pair:
    case P148Ref{after,sym}:
      p148c_step8(tag,args,count,at,id,sym,p148c_reserve(U32.mul(count,2),after))

@unsafe
def p148c_step10(+tag: U32, +symbol: String, +args: List<&2,N111Arg>, +count: U32, +at: U32, pair: P148Ref) -> P148Build:
  match pair:
    case P148Ref{next,id}:
      p148c_step9(tag,args,count,at,id,p148c_intern(symbol,next))

@unsafe
def p148c_encode_call(name: String, tag: U32, symbol: String, args: List<&2,N111Arg>,
    +count: U32, at: U32, build: P148Build) -> P148Build:
  p148c_step10(tag,symbol,args,count,at,p148c_intern(name,build))

@unsafe
def p148c_branch_done(tag: U32, condition: U32, at: U32, yesStart: U32,
    noStart: U32, build: P148Build) -> P148Build:
  p148c_header_here(build,at,tag,0,condition,0,yesStart,noStart,0)

@unsafe
def p148c_scalar_yes_position(condition: U32, no: List<&2,N111Stmt>, at: U32,
    yesStart: U32, pair: P148Ref) -> P148Build:
  match pair:
    case P148Ref{build,noStart}:
      p148c_branch_done(4,condition,at,yesStart,noStart,p148c_encode_scalars(no,build))

@unsafe
def p148c_scalar_yes(condition: U32, no: List<&2,N111Stmt>, at: U32,
    yesStart: U32, build: P148Build) -> P148Build:
  p148c_scalar_yes_position(condition,no,at,yesStart,p148c_position(build))

@unsafe
def p148c_scalar_begin(condition: U32, yes: List<&2,N111Stmt>, no: List<&2,N111Stmt>, at: U32,
    pair: P148Ref) -> P148Build:
  match pair:
    case P148Ref{build,yesStart}:
      p148c_scalar_yes(condition,no,at,yesStart,p148c_encode_scalars(yes,build))

@unsafe
def p148c_step15(+at: U32, +yes: List<&2,N111Stmt>, +no: List<&2,N111Stmt>, pair: P148Ref) -> P148Build:
  match pair:
    case P148Ref{next,ref}: p148c_scalar_begin(ref,yes,no,at,p148c_position(next))

@unsafe
def p148c_step14(+at: U32, pair: P148Ref) -> P148Build:
  match pair:
    case P148Ref{next,ref}: p148c_header_here(next,at,5,0,ref,0,0,0,0)

@unsafe
def p148c_step12(+at: U32, +typ: N111Type, +offset: U32, +a: U32, pair: P148Ref) -> P148Build:
  match pair:
    case P148Ref{done,b}: p148c_header_here(done,at,p148c_typed(7,typ),0,a,b,offset,0,0)

@unsafe
def p148c_step13(+at: U32, +typ: N111Type, +value: N111Value, +offset: U32, pair: P148Ref) -> P148Build:
  match pair:
    case P148Ref{next,a}:
      p148c_step12(at,typ,offset,a,p148c_value(value,next))

@unsafe
def p148c_step11(+at: U32, +bytes: U32, +align: U32, pair: P148Ref) -> P148Build:
  match pair:
    case P148Ref{next,id}: p148c_header_here(next,at,9,id,0,0,bytes,align,0)

@unsafe
def p148c_encode_scalar(stmt: N111Stmt, +at: U32, build: P148Build) -> P148Build:
  match stmt:
    case N111Set{name,typ,value}: p148c_named_one(p148c_typed(1,typ),name,value,0,0,at,build)
    case N111Bin{name,typ,op,left,right}:
      p148c_step16(at,name,typ,left,right,p148c_intern(op,build))

    case N111Call{name,typ,symbol,+args}:
      p148c_encode_call(name,p148c_typed(3,typ),symbol,args,nt_count(N111Arg,args),at,build)
    case N111If{condition,yes,no}:
      p148c_step15(at,yes,no,p148c_value(condition,build))

    case N111Return{value}:
      p148c_step14(at,p148c_value(value,build))

    case N111Load{name,typ,base,offset}: p148c_named_one(p148c_typed(6,typ),name,base,offset,0,at,build)
    case N111Store{typ,base,offset,value}:
      p148c_step13(at,typ,value,offset,p148c_value(base,build))

    case N111Offset{name,base,bytes}: p148c_named_two(8,name,base,bytes,0,at,build)
    case N111Alloca{name,bytes,align}:
      p148c_step11(at,bytes,align,p148c_intern(name,build))

@unsafe
def p148c_step23(+head: N111Stmt, +rest: List<&2,N111Stmt>, pair: P148Ref) -> P148Build:
  match pair:
    case P148Ref{next,at}: p148c_encode_scalars(rest,p148c_encode_scalar(head,at,next))

@unsafe
def p148c_encode_scalars(body,build):
  match body:
    case Nil{}: build
    case Con{head,rest}:
      p148c_step23(head,rest,p148c_reserve(8,build))

@unsafe
def p148c_direct_yes_position(condition: U32, no: List<&2,P113DStmt>, at: U32,
    yesStart: U32, pair: P148Ref) -> P148Build:
  match pair:
    case P148Ref{build,noStart}:
      p148c_branch_done(10,condition,at,yesStart,noStart,p148c_encode_body(no,build))

@unsafe
def p148c_direct_yes(condition: U32, no: List<&2,P113DStmt>, at: U32,
    yesStart: U32, build: P148Build) -> P148Build:
  p148c_direct_yes_position(condition,no,at,yesStart,p148c_position(build))

@unsafe
def p148c_direct_begin(condition: U32, yes: List<&2,P113DStmt>, no: List<&2,P113DStmt>, at: U32,
    pair: P148Ref) -> P148Build:
  match pair:
    case P148Ref{build,yesStart}:
      p148c_direct_yes(condition,no,at,yesStart,p148c_encode_body(yes,build))

@unsafe
def p148c_step7(+at: U32, +yes: List<&2,P113DStmt>, +no: List<&2,P113DStmt>, pair: P148Ref) -> P148Build:
  match pair:
    case P148Ref{next,ref}: p148c_direct_begin(ref,yes,no,at,p148c_position(next))

@unsafe
def p148c_direct_call_done(target: U32, nd: U32, na: U32, at: U32,
    payload: U32, build: P148Build) -> P148Build:
  p148c_header_here(build,at,11,target,0,0,nd,na,payload)

@unsafe
def p148c_step5(+destinations: List<&2,String>, +args: List<&2,N111Value>, +nd: U32, +na: U32, +at: U32, +id: U32, pair: P148Ref) -> P148Build:
  match pair:
    case P148Ref{after,+payload}:
      p148c_direct_call_done(id,nd,na,at,payload,
        p148c_encode_values(args,U32.add(payload,nd),p148c_encode_names(destinations,payload,after)))

@unsafe
def p148c_step6(+destinations: List<&2,String>, +args: List<&2,N111Value>, +nd: U32, +na: U32, +at: U32, pair: P148Ref) -> P148Build:
  match pair:
    case P148Ref{next,id}:
      p148c_step5(destinations,args,nd,na,at,id,p148c_reserve(U32.add(nd,na),next))

@unsafe
def p148c_encode_direct_call(destinations: List<&2,String>, target: String, args: List<&2,N111Value>,
    +nd: U32, +na: U32, at: U32, build: P148Build) -> P148Build:
  p148c_step6(destinations,args,nd,na,at,p148c_intern(target,build))

@unsafe
def p148c_vector_done(tag: U32, count: U32, at: U32, payload: U32, build: P148Build) -> P148Build:
  p148c_header_here(build,at,tag,0,0,0,count,0,payload)

@unsafe
def p148c_step4(+tag: U32, +values: List<&2,N111Value>, +count: U32, +at: U32, pair: P148Ref) -> P148Build:
  match pair:
    case P148Ref{next,+payload}:
      p148c_vector_done(tag,count,at,payload,p148c_encode_values(values,payload,next))

@unsafe
def p148c_encode_vector(tag: U32, values: List<&2,N111Value>, +count: U32,
    at: U32, build: P148Build) -> P148Build:
  p148c_step4(tag,values,count,at,p148c_reserve(count,build))

@unsafe
def p148c_encode_direct(stmt: P113DStmt, +at: U32, build: P148Build) -> P148Build:
  match stmt:
    case P113DScalar{scalar}: p148c_encode_scalar(scalar,at,build)
    case P113DIf{condition,yes,no}:
      p148c_step7(at,yes,no,p148c_value(condition,build))

    case P113DCall{+destinations,target,+args}:
      p148c_encode_direct_call(destinations,target,args,nt_count(String,destinations),nt_count(N111Value,args),at,build)
    case P113DResult{+values}: p148c_encode_vector(12,values,nt_count(N111Value,values),at,build)
    case P113DAgain{+values}: p148c_encode_vector(13,values,nt_count(N111Value,values),at,build)

@unsafe
def p148c_step22(+head: P113DStmt, +rest: List<&2,P113DStmt>, pair: P148Ref) -> P148Build:
  match pair:
    case P148Ref{next,at}: p148c_encode_body(rest,p148c_encode_direct(head,at,next))

@unsafe
def p148c_encode_body(body,build):
  match body:
    case Nil{}: build
    case Con{head,rest}:
      p148c_step22(head,rest,p148c_reserve(8,build))

@unsafe
def p148c_step1(pair: P148Ref) -> P148Build:
  match pair:
    case P148Ref{c,id}: c

@unsafe
def p148c_step2(pair: P148Ref) -> P148Build:
  match pair:
    case P148Ref{b,id}:
      p148c_step1(p148c_intern("xor",b))

@unsafe
def p148c_step3(pair: P148Ref) -> P148Build:
  match pair:
    case P148Ref{a,id}:
      p148c_step2(p148c_intern("scratch",a))

@unsafe
def p148c_seed(build: P148Build) -> P148Build:
  p148c_step3(p148c_intern("state",build))

@unsafe
def p148c_pack_finish(name: String, params: List<&2,NC_Binding>, result: U32,
    public: Bool, +expectedWords: U32, +expectedValues: U32, build: P148Build) -> P148Unit:
  match build:
    case P148Build{P148Tape{words,values,names,+used,+valueUsed,nameUsed},index,wc,vc,nc,+error}:
      nt_choose(P148Unit,Bool.not(String.is_empty(error)),u => P148Bad{error},u =>
        nt_choose(P148Unit,U32.is_eq(used,expectedWords) && U32.is_eq(valueUsed,expectedValues),
          v => P148Good{name,params,result,public,P148Tape{words,values,names,used,valueUsed,nameUsed}},
          v => P148Bad{"phase148 inconsistent size census"}))

@unsafe
def p148c_pack_alloc(+function: P113DFunction, +words: U32, +valueWords: U32,
    +names: U32, +valueCapacity: U32) -> P148Unit:
  match function:
    case P113DFunction{name,+params,result,public,body}:
      p148c_pack_finish(name,params,result,public,words,valueWords,
        p148c_encode_body(body,p148c_encode_params(params,p148c_seed(
          P148Build{P148Tape{p148w_new(words),p148w_new(valueCapacity),
            Array.new(String,p88_array_depth(names,1,0n),""),0,0,0},
            P147VEmpty{},words,valueCapacity,names,""}))))

@unsafe
def p148c_pack_gate(+function: P113DFunction, +words: U32, +valueWords: U32,
    +names: U32, +valueCapacity: U32) -> P148Unit:
  nt_choose(P148Unit,U32.is_le(words,p148c_limit()) && U32.is_le(names,p148c_limit()) &&
      U32.is_le(valueCapacity,p148c_limit()),
    u => p148c_pack_alloc(function,words,valueWords,names,valueCapacity),
    u => P148Bad{"phase148 unit capacity limit"})

@unsafe
def p148c_pack_sized(+function: P113DFunction, params: U32, size: P148Size) -> P148Unit:
  match size:
    case P148Size{words,+values,names,+statements}:
      p148c_pack_gate(function,words,values,p148c_add(3,p148c_add(names,params)),
        p148c_add(16,p148c_add(p148c_add(values,values),p148c_add(statements,p148c_add(statements,statements)))))

@unsafe
def p148_pack(+function: P113DFunction) -> P148Unit:
  match function:
    case P113DFunction{name,params,result,public,body}:
      p148c_pack_sized(function,p148c_params_size(params),p148c_body_size(body))

@unsafe
def p148c_at(+words: Array<U32>, +values: Array<U32>, +names: Array<String>, +used: U32, +valueUsed: U32, +nameUsed: U32, at: U32) -> U32:
  p148w_get(words,at)

@unsafe
def p148c_field(+words: Array<U32>, +values: Array<U32>, +names: Array<String>, +used: U32, +valueUsed: U32, +nameUsed: U32, pc: U32, field: U32) -> U32:
  p148c_at(words,values,names,used,valueUsed,nameUsed,U32.add(pc,field))

@unsafe
def p148c_name(+words: Array<U32>, +values: Array<U32>, +names: Array<String>, +used: U32, +valueUsed: U32, +nameUsed: U32, id: U32) -> String:
  p148n_get(names,id)

@unsafe
def p148c_decode_type(width: U32) -> N111Type:
  match width:
    case 1: N111U32{}
    case 2: N111U64{}
    case _: N111Ptr{}

@unsafe
def p148c_decode_value_words(+words: Array<U32>, +values: Array<U32>, +names: Array<String>, +used: U32, +valueUsed: U32, +nameUsed: U32, kind: U32, lo: U32, hi: U32) -> N111Value:
  match kind:
    case 1: N111Local{p148c_name(words,values,names,used,valueUsed,nameUsed,lo)}
    case 2: N111Const{lo,hi}
    case 3: N111Symbol{p148c_name(words,values,names,used,valueUsed,nameUsed,lo)}
    case 4: N111FuncId{p148c_name(words,values,names,used,valueUsed,nameUsed,lo)}
    case _: N111CtorId{p148c_name(words,values,names,used,valueUsed,nameUsed,lo)}

@unsafe
def p148c_decode_value(+words: Array<U32>, +values: Array<U32>, +names: Array<String>, +used: U32, +valueUsed: U32, +nameUsed: U32, +ref: U32) -> N111Value:
  p148c_decode_value_words(words,values,names,used,valueUsed,nameUsed,p148w_get(values,ref),
    p148w_get(values,U32.inc(ref)),p148w_get(values,U32.add(ref,2)))

@unsafe
def p148c_decode_args(+words: Array<U32>, +values: Array<U32>, +names: Array<String>, +used: U32, +valueUsed: U32, +nameUsed: U32, +at: U32, +count: U32) -> List<&2,N111Arg>:
  nt_choose(List<&2,N111Arg>,U32.is_eq(count,0),u => [],u =>
    Con{N111Arg{p148c_decode_type(p148c_at(words,values,names,used,valueUsed,nameUsed,at)),p148c_decode_value(words,values,names,used,valueUsed,nameUsed,p148c_at(words,values,names,used,valueUsed,nameUsed,U32.inc(at)))},
      p148c_decode_args(words,values,names,used,valueUsed,nameUsed,U32.add(at,2),U32.sub(count,1))})

@unsafe
def p148c_decode_values(+words: Array<U32>, +values: Array<U32>, +names: Array<String>, +used: U32, +valueUsed: U32, +nameUsed: U32, +at: U32, +count: U32) -> List<&2,N111Value>:
  nt_choose(List<&2,N111Value>,U32.is_eq(count,0),u => [],u =>
    Con{p148c_decode_value(words,values,names,used,valueUsed,nameUsed,p148c_at(words,values,names,used,valueUsed,nameUsed,at)),p148c_decode_values(words,values,names,used,valueUsed,nameUsed,U32.inc(at),U32.sub(count,1))})

@unsafe
def p148c_decode_names(+words: Array<U32>, +values: Array<U32>, +names: Array<String>, +used: U32, +valueUsed: U32, +nameUsed: U32, +at: U32, +count: U32) -> List<&2,String>:
  nt_choose(List<&2,String>,U32.is_eq(count,0),u => [],u =>
    Con{p148c_name(words,values,names,used,valueUsed,nameUsed,p148c_at(words,values,names,used,valueUsed,nameUsed,at)),p148c_decode_names(words,values,names,used,valueUsed,nameUsed,U32.inc(at),U32.sub(count,1))})

@unsafe
def p148c_decode_scalars_tag(+words: Array<U32>, +values: Array<U32>, +names: Array<String>, +used: U32, +valueUsed: U32, +nameUsed: U32, +at: U32, +end: U32, tag: U32) -> List<&2,N111Stmt>:
  match tag:
    case 14: nt_append(N111Stmt,p148c_decode_scalars(words,values,names,used,valueUsed,nameUsed,p148c_field(words,values,names,used,valueUsed,nameUsed,at,4),p148c_field(words,values,names,used,valueUsed,nameUsed,at,5)),
      p148c_decode_scalars(words,values,names,used,valueUsed,nameUsed,p148c_field(words,values,names,used,valueUsed,nameUsed,at,7),end))
    case 15: p148c_decode_scalars(words,values,names,used,valueUsed,nameUsed,p148c_field(words,values,names,used,valueUsed,nameUsed,at,7),end)
    case _: Con{p148c_decode_scalar(words,values,names,used,valueUsed,nameUsed,at),p148c_decode_scalars(words,values,names,used,valueUsed,nameUsed,p148c_field(words,values,names,used,valueUsed,nameUsed,at,7),end)}

@unsafe
def p148c_decode_scalars(words,values,names,used,valueUsed,nameUsed,at,end):
  nt_choose(List<&2,N111Stmt>,U32.is_ge(at,end),u => [],u =>
    p148c_decode_scalars_tag(words,values,names,used,valueUsed,nameUsed,at,end,U32.and(p148c_field(words,values,names,used,valueUsed,nameUsed,at,0),255)))

@unsafe
def p148c_decode_scalar_tag(+words: Array<U32>, +values: Array<U32>, +names: Array<String>, +used: U32, +valueUsed: U32, +nameUsed: U32, +pc: U32, tag: U32, +width: U32) -> N111Stmt:
  match tag:
    case 1: N111Set{p148c_name(words,values,names,used,valueUsed,nameUsed,p148c_field(words,values,names,used,valueUsed,nameUsed,pc,1)),p148c_decode_type(width),
      p148c_decode_value(words,values,names,used,valueUsed,nameUsed,p148c_field(words,values,names,used,valueUsed,nameUsed,pc,2))}
    case 2: N111Bin{p148c_name(words,values,names,used,valueUsed,nameUsed,p148c_field(words,values,names,used,valueUsed,nameUsed,pc,1)),p148c_decode_type(width),
      p148c_name(words,values,names,used,valueUsed,nameUsed,p148c_field(words,values,names,used,valueUsed,nameUsed,pc,4)),p148c_decode_value(words,values,names,used,valueUsed,nameUsed,p148c_field(words,values,names,used,valueUsed,nameUsed,pc,2)),
      p148c_decode_value(words,values,names,used,valueUsed,nameUsed,p148c_field(words,values,names,used,valueUsed,nameUsed,pc,3))}
    case 3: N111Call{p148c_name(words,values,names,used,valueUsed,nameUsed,p148c_field(words,values,names,used,valueUsed,nameUsed,pc,1)),p148c_decode_type(width),
      p148c_name(words,values,names,used,valueUsed,nameUsed,p148c_field(words,values,names,used,valueUsed,nameUsed,pc,4)),p148c_decode_args(words,values,names,used,valueUsed,nameUsed,p148c_field(words,values,names,used,valueUsed,nameUsed,pc,6),p148c_field(words,values,names,used,valueUsed,nameUsed,pc,5))}
    case 4: N111If{p148c_decode_value(words,values,names,used,valueUsed,nameUsed,p148c_field(words,values,names,used,valueUsed,nameUsed,pc,2)),
      p148c_decode_scalars(words,values,names,used,valueUsed,nameUsed,p148c_field(words,values,names,used,valueUsed,nameUsed,pc,4),p148c_field(words,values,names,used,valueUsed,nameUsed,pc,5)),
      p148c_decode_scalars(words,values,names,used,valueUsed,nameUsed,p148c_field(words,values,names,used,valueUsed,nameUsed,pc,5),p148c_field(words,values,names,used,valueUsed,nameUsed,pc,7))}
    case 5: N111Return{p148c_decode_value(words,values,names,used,valueUsed,nameUsed,p148c_field(words,values,names,used,valueUsed,nameUsed,pc,2))}
    case 6: N111Load{p148c_name(words,values,names,used,valueUsed,nameUsed,p148c_field(words,values,names,used,valueUsed,nameUsed,pc,1)),p148c_decode_type(width),
      p148c_decode_value(words,values,names,used,valueUsed,nameUsed,p148c_field(words,values,names,used,valueUsed,nameUsed,pc,2)),p148c_field(words,values,names,used,valueUsed,nameUsed,pc,4)}
    case 7: N111Store{p148c_decode_type(width),p148c_decode_value(words,values,names,used,valueUsed,nameUsed,p148c_field(words,values,names,used,valueUsed,nameUsed,pc,2)),
      p148c_field(words,values,names,used,valueUsed,nameUsed,pc,4),p148c_decode_value(words,values,names,used,valueUsed,nameUsed,p148c_field(words,values,names,used,valueUsed,nameUsed,pc,3))}
    case 8: N111Offset{p148c_name(words,values,names,used,valueUsed,nameUsed,p148c_field(words,values,names,used,valueUsed,nameUsed,pc,1)),
      p148c_decode_value(words,values,names,used,valueUsed,nameUsed,p148c_field(words,values,names,used,valueUsed,nameUsed,pc,2)),p148c_decode_value(words,values,names,used,valueUsed,nameUsed,p148c_field(words,values,names,used,valueUsed,nameUsed,pc,3))}
    case _: N111Alloca{p148c_name(words,values,names,used,valueUsed,nameUsed,p148c_field(words,values,names,used,valueUsed,nameUsed,pc,1)),p148c_field(words,values,names,used,valueUsed,nameUsed,pc,4),p148c_field(words,values,names,used,valueUsed,nameUsed,pc,5)}

@unsafe
def p148c_decode_scalar(words,values,names,used,valueUsed,nameUsed,pc):
  +header = p148c_field(words,values,names,used,valueUsed,nameUsed,pc,0)
  p148c_decode_scalar_tag(words,values,names,used,valueUsed,nameUsed,pc,U32.and(header,255),U32.div(header,256))

@unsafe
def p148c_decode_body_tag(+words: Array<U32>, +values: Array<U32>, +names: Array<String>, +used: U32, +valueUsed: U32, +nameUsed: U32, +at: U32, +end: U32, tag: U32) -> List<&2,P113DStmt>:
  match tag:
    case 14: nt_append(P113DStmt,p148c_decode_body(words,values,names,used,valueUsed,nameUsed,p148c_field(words,values,names,used,valueUsed,nameUsed,at,4),p148c_field(words,values,names,used,valueUsed,nameUsed,at,5)),
      p148c_decode_body(words,values,names,used,valueUsed,nameUsed,p148c_field(words,values,names,used,valueUsed,nameUsed,at,7),end))
    case 15: p148c_decode_body(words,values,names,used,valueUsed,nameUsed,p148c_field(words,values,names,used,valueUsed,nameUsed,at,7),end)
    case _: Con{p148c_decode_direct(words,values,names,used,valueUsed,nameUsed,at,tag),p148c_decode_body(words,values,names,used,valueUsed,nameUsed,p148c_field(words,values,names,used,valueUsed,nameUsed,at,7),end)}

@unsafe
def p148c_decode_body(words,values,names,used,valueUsed,nameUsed,at,end):
  nt_choose(List<&2,P113DStmt>,U32.is_ge(at,end),u => [],u =>
    p148c_decode_body_tag(words,values,names,used,valueUsed,nameUsed,at,end,U32.and(p148c_field(words,values,names,used,valueUsed,nameUsed,at,0),255)))

@unsafe
def p148c_decode_direct(words,values,names,used,valueUsed,nameUsed,pc,tag):
  match tag:
    case 10: P113DIf{p148c_decode_value(words,values,names,used,valueUsed,nameUsed,p148c_field(words,values,names,used,valueUsed,nameUsed,pc,2)),
      p148c_decode_body(words,values,names,used,valueUsed,nameUsed,p148c_field(words,values,names,used,valueUsed,nameUsed,pc,4),p148c_field(words,values,names,used,valueUsed,nameUsed,pc,5)),
      p148c_decode_body(words,values,names,used,valueUsed,nameUsed,p148c_field(words,values,names,used,valueUsed,nameUsed,pc,5),p148c_field(words,values,names,used,valueUsed,nameUsed,pc,7))}
    case 11: P113DCall{p148c_decode_names(words,values,names,used,valueUsed,nameUsed,p148c_field(words,values,names,used,valueUsed,nameUsed,pc,6),p148c_field(words,values,names,used,valueUsed,nameUsed,pc,4)),
      p148c_name(words,values,names,used,valueUsed,nameUsed,p148c_field(words,values,names,used,valueUsed,nameUsed,pc,1)),p148c_decode_values(words,values,names,used,valueUsed,nameUsed,
        U32.add(p148c_field(words,values,names,used,valueUsed,nameUsed,pc,6),p148c_field(words,values,names,used,valueUsed,nameUsed,pc,4)),p148c_field(words,values,names,used,valueUsed,nameUsed,pc,5))}
    case 12: P113DResult{p148c_decode_values(words,values,names,used,valueUsed,nameUsed,p148c_field(words,values,names,used,valueUsed,nameUsed,pc,6),p148c_field(words,values,names,used,valueUsed,nameUsed,pc,4))}
    case 13: P113DAgain{p148c_decode_values(words,values,names,used,valueUsed,nameUsed,p148c_field(words,values,names,used,valueUsed,nameUsed,pc,6),p148c_field(words,values,names,used,valueUsed,nameUsed,pc,4))}
    case _: P113DScalar{p148c_decode_scalar(words,values,names,used,valueUsed,nameUsed,pc)}

@unsafe
def p148c_stmt_count_tag(+words: Array<U32>, +values: Array<U32>, +names: Array<String>, +used: U32, +valueUsed: U32, +nameUsed: U32, +at: U32, +end: U32, +tag: U32) -> U32:
  +tail = p148c_stmt_count(words,values,names,used,valueUsed,nameUsed,p148c_field(words,values,names,used,valueUsed,nameUsed,at,7),end)
  nt_choose(U32,U32.is_eq(tag,15),u => tail,u =>
  nt_choose(U32,U32.is_eq(tag,14),u => p148c_add(tail,p148c_stmt_count(words,values,names,used,valueUsed,nameUsed,p148c_field(words,values,names,used,valueUsed,nameUsed,at,4),p148c_field(words,values,names,used,valueUsed,nameUsed,at,5))),u =>
  nt_choose(U32,U32.is_eq(tag,4) || U32.is_eq(tag,10),u =>
    p148c_add(1,p148c_add(tail,p148c_add(p148c_stmt_count(words,values,names,used,valueUsed,nameUsed,p148c_field(words,values,names,used,valueUsed,nameUsed,at,4),p148c_field(words,values,names,used,valueUsed,nameUsed,at,5)),
      p148c_stmt_count(words,values,names,used,valueUsed,nameUsed,p148c_field(words,values,names,used,valueUsed,nameUsed,at,5),p148c_field(words,values,names,used,valueUsed,nameUsed,at,7))))),u => U32.inc(tail))))

# Bad has no function to recover. Callers retain their original fallback and
# must branch on P148Bad before unpack; this total arm is never a success.
@unsafe
def p148c_stmt_count(words,values,names,used,valueUsed,nameUsed,at,end):
  nt_choose(U32,U32.is_ge(at,end),u => 0,u =>
    p148c_stmt_count_tag(words,values,names,used,valueUsed,nameUsed,at,end,U32.and(p148c_field(words,values,names,used,valueUsed,nameUsed,at,0),255)))

@unsafe
def p148_unpack(unit: P148Unit) -> P113DFunction:
  match unit:
    case P148Good{name,params,result,public,tape}:
      match tape:
        case P148Tape{words,values,names,+used,valueUsed,nameUsed}:
          P113DFunction{name,params,result,public,p148c_decode_body(words,values,names,used,valueUsed,nameUsed,0,used)}
    case P148Bad{error}: P113DFunction{"",[],0,False{},[]}

# Parameter-matching continuations keep computed records out of match spines.

