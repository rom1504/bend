

def p112fp_binary(id: U32) -> String:
  match id:
    case 26: "add"
    case 27: "sub"
    case 28: "mul"
    case 29: "div"
    case 30: "ceqs"
    case 31: "cnes"
    case 32: "clts"
    case 33: "cles"
    case 34: "cgts"
    case 35: "cges"
    case _: "INVALID_P112_FLOAT_OPERATION"


@unsafe
def p112fp_supported(+id: U32, +count: U32) -> Bool:
  (U32.is_eq(id,23) && U32.is_eq(count,1)) ||
    (U32.is_ge(id,26) && U32.is_le(id,35) && U32.is_eq(count,2))


@unsafe
def p112fp_binary_text(+id: U32, +name: String, +buffer: String, +n: U32) -> String:
  +rawa = p111q_tmp(n)
  +a = p111q_tmp(U32.add(n,1))
  +af = p111q_tmp(U32.add(n,2))
  +at = p111q_tmp(U32.add(n,3))
  +rawb = p111q_tmp(U32.add(n,4))
  +b = p111q_tmp(U32.add(n,5))
  +bf = p111q_tmp(U32.add(n,6))
  +out = p111q_tmp(U32.add(n,7))
  +bits = p111q_tmp(U32.add(n,8))
  rawa ++ " =l loadl " ++ p111q_local(buffer) ++ "\n" ++ a ++ " =w copy " ++ rawa ++ "\n" ++ af ++ " =s cast " ++ a ++ "\n" ++
  at ++ " =l add " ++ p111q_local(buffer) ++ ", 8\n" ++ rawb ++ " =l loadl " ++ at ++ "\n" ++ b ++ " =w copy " ++ rawb ++ "\n" ++
  bf ++ " =s cast " ++ b ++ "\n" ++
  nt_choose(String,U32.is_lt(id,30),
    u => out ++ " =s " ++ p112fp_binary(id) ++ " " ++ af ++ ", " ++ bf ++ "\n" ++
      bits ++ " =w cast " ++ out ++ "\n" ++ p111q_local(name) ++ " =l extuw " ++ bits ++ "\n",
    u => out ++ " =w " ++ p112fp_binary(id) ++ " " ++ af ++ ", " ++ bf ++ "\n" ++
      p111q_local(name) ++ " =l extuw " ++ out ++ "\n")


@unsafe
def p112fp_convert_text(+name: String, +buffer: String, +n: U32) -> String:
  +raw = p111q_tmp(n)
  +a = p111q_tmp(U32.inc(n))
  +out = p111q_tmp(U32.add(n,2))
  +bits = p111q_tmp(U32.add(n,3))
  raw ++ " =l loadl " ++ p111q_local(buffer) ++ "\n" ++ a ++ " =w copy " ++ raw ++ "\n" ++ out ++ " =s uwtof " ++ a ++ "\n" ++
  bits ++ " =w cast " ++ out ++ "\n" ++ p111q_local(name) ++ " =l extuw " ++ bits ++ "\n"


@unsafe
def p112fp_emit(+name: String, +id: U32, +buffer: String, code: P111QCode) -> P112FPEmission:
  match code:
    case P111QCode{chunks,+n,terminal,error}:
      P112FPEmission{True{},P111QCode{Con{nt_choose(String,U32.is_eq(id,23),
        u => p112fp_convert_text(name,buffer,n),u => p112fp_binary_text(id,name,buffer,n)),chunks},U32.add(n,9),terminal,error}}


@unsafe
def p112fp_expand(stmt: N111Stmt, +code: P111QCode) -> P112FPEmission:
  match stmt:
    case N111Call{+name,N111U64{},+symbol,
      Con{N111Arg{N111Ptr{},N111Local{state}},Con{N111Arg{N111U32{},N111Const{+id,0}},Con{N111Arg{N111Ptr{},N111Local{+buffer}},Con{N111Arg{N111U32{},N111Const{count,0}},Nil{}}}}}}:
      nt_choose(P112FPEmission,String.eq(symbol,"p111_rt_op") && String.eq(state,"state") && p112fp_supported(id,count),
        u => p112fp_emit(name,id,buffer,code),u => P112FPEmission{False{},code})
    case _: P112FPEmission{False{},code}


@unsafe
def p112fp_control_name(+name: String, good: Bool) -> String:
  nt_choose(String,good,u => "PASS " ++ name,u => "FAIL " ++ name)


def p112fp_control_call(id: N111Value, count: N111Value, buffer: String) -> N111Stmt:
  N111Call{"result",N111U64{},"p111_rt_op",[p111_state(),N111Arg{N111U32{},id},N111Arg{N111Ptr{},N111Local{buffer}},N111Arg{N111U32{},count}]}


def p112fp_control_expanded(result: P112FPEmission) -> Bool:
  match result:
    case P112FPEmission{expanded,code}: expanded


@unsafe
def p112fp_control_probe(stmt: N111Stmt) -> Bool:
  p112fp_control_expanded(p112fp_expand(stmt,P111QCode{[],40,False{},""}))


@unsafe
def p112fp_control_temps(result: P112FPEmission) -> Bool:
  match result:
    case P112FPEmission{expanded,P111QCode{chunks,next,terminal,error}}: expanded && U32.is_eq(next,49) && Bool.not(terminal) && String.is_empty(error)


@unsafe
def p112fp_control_verified(+buffer: String, bytes: U32) -> Bool:
  +segment : N111Segment = N111Segment{"probe",0,1,0,0,[N111Alloca{buffer,bytes,8},p112fp_control_call(N111Const{26,0},N111Const{2,0},buffer),N111Return{N111Local{"result"}}]}
  String.is_empty(p111v_segment(segment,N111Ids{missing(),missing()}))


@unsafe
def p112fp_control_report() -> List<&2,String>:
  [p112fp_control_name("add",p112fp_control_probe(p112fp_control_call(N111Const{26,0},N111Const{2,0},"scratch"))),
   p112fp_control_name("division",p112fp_control_probe(p112fp_control_call(N111Const{29,0},N111Const{2,0},"scratch"))),
   p112fp_control_name("comparison",p112fp_control_probe(p112fp_control_call(N111Const{35,0},N111Const{2,0},"scratch"))),
   p112fp_control_name("unsigned-conversion",p112fp_control_probe(p112fp_control_call(N111Const{23,0},N111Const{1,0},"scratch"))),
   p112fp_control_name("sqrt-fallback",Bool.not(p112fp_control_probe(p112fp_control_call(N111Const{36,0},N111Const{1,0},"scratch")))),
   p112fp_control_name("to-u32-fallback",Bool.not(p112fp_control_probe(p112fp_control_call(N111Const{58,0},N111Const{1,0},"scratch")))),
   p112fp_control_name("wrong-arity-fallback",Bool.not(p112fp_control_probe(p112fp_control_call(N111Const{26,0},N111Const{1,0},"scratch")))),
   p112fp_control_name("high-op-fallback",Bool.not(p112fp_control_probe(p112fp_control_call(N111Const{26,1},N111Const{2,0},"scratch")))),
   p112fp_control_name("high-count-fallback",Bool.not(p112fp_control_probe(p112fp_control_call(N111Const{26,0},N111Const{2,1},"scratch")))),
   p112fp_control_name("dynamic-op-fallback",Bool.not(p112fp_control_probe(p112fp_control_call(N111Local{"op"},N111Const{2,0},"scratch")))),
   p112fp_control_name("other-buffer-supported",p112fp_control_probe(p112fp_control_call(N111Const{26,0},N111Const{2,0},"buffer"))),
   p112fp_control_name("integer-op-fallback",Bool.not(p112fp_control_probe(p112fp_control_call(N111Const{1,0},N111Const{2,0},"scratch")))),
   p112fp_control_name("noncall-fallback",Bool.not(p112fp_control_probe(N111Set{"result",N111U64{},N111Const{0,0}}))),
   p112fp_control_name("fresh-temporary-counter",p112fp_control_temps(p112fp_expand(p112fp_control_call(N111Const{26,0},N111Const{2,0},"scratch"),P111QCode{[],40,False{},""}))),
   p112fp_control_name("fusion-buffer-supported",p112fp_control_probe(p112fp_control_call(N111Const{26,0},N111Const{2,0},"p112f_site0_scratch"))),
   p112fp_control_name("alternate-buffer-original-verifier",p112fp_control_verified("buffer",16)),
   p112fp_control_name("fusion-buffer-original-verifier",p112fp_control_verified("p112f_site0_scratch",16)),
   p112fp_control_name("short-buffer-original-refusal",Bool.not(p112fp_control_verified("buffer",8))),
   p112fp_control_name("wrong-state-fallback",Bool.not(p112fp_control_probe(N111Call{"result",N111U64{},"p111_rt_op",[N111Arg{N111Ptr{},N111Local{"other_state"}},p111_u32(26),p111_scratch(),p111_u32(2)]}))),
   p112fp_control_name("nonlocal-buffer-fallback",Bool.not(p112fp_control_probe(N111Call{"result",N111U64{},"p111_rt_op",[p111_state(),p111_u32(26),N111Arg{N111Ptr{},N111Const{0,0}},p111_u32(2)]}))),
   p112fp_control_name("wrong-result-width-fallback",Bool.not(p112fp_control_probe(N111Call{"result",N111U32{},"p111_rt_op",[p111_state(),p111_u32(26),p111_scratch(),p111_u32(2)]})))]


@unsafe
def p112f_index_bucket(bucket: List<&2,N111Segment>, +name: String) -> Maybe<&2,N111Segment>:
  match bucket:
    case Nil{}: None{}
    case Con{+segment,+rest}:
      match segment:
        case N111Segment{+key,+arity,+result,+incoming,+flags,+body}:
          nt_choose(Maybe<&2,N111Segment>,String.eq(key,name),u => Some{segment},u => p112f_index_bucket(rest,name))


def p112f_index_present(found: Maybe<&2,N111Segment>) -> Bool:
  match found:
    case None{}: False{}
    case Some{+segment}: True{}


@unsafe
def p112f_index_bucket_add(+bucket: List<&2,N111Segment>, +segment: N111Segment) -> List<&2,N111Segment>:
  match segment:
    case N111Segment{+name,+arity,+result,+incoming,+flags,+body}:
      nt_choose(List<&2,N111Segment>,p112f_index_present(p112f_index_bucket(bucket,name)),
        u => bucket,u => Con{segment,bucket})


@unsafe
def p112f_index_find(tree: P112FusionIndex, +name: String, +hash: U32) -> Maybe<&2,N111Segment>:
  match tree:
    case P112FusionEmpty{}: None{}
    case P112FusionLeaf{+stored,+bucket}:
      nt_choose(Maybe<&2,N111Segment>,U32.is_eq(hash,stored),u => p112f_index_bucket(bucket,name),u => None{})
    case P112FusionNode{+mask,+left,+right}:
      nt_choose(Maybe<&2,N111Segment>,U32.is_eq(U32.and(hash,mask),0),
        u => p112f_index_find(left,name,hash),u => p112f_index_find(right,name,hash))


@unsafe
def p112f_index_get(+tree: P112FusionIndex, +name: String) -> Maybe<&2,N111Segment>:
  p112f_index_find(tree,name,index_hash(name,2166136261))


@unsafe
def p112f_index_tip(tree: P112FusionIndex, +hash: U32) -> U32:
  match tree:
    case P112FusionEmpty{}: hash
    case P112FusionLeaf{+stored,+bucket}: stored
    case P112FusionNode{+mask,+left,+right}:
      nt_choose(U32,U32.is_eq(U32.and(hash,mask),0),u => p112f_index_tip(left,hash),u => p112f_index_tip(right,hash))


@unsafe
def p112f_index_join(+tree: P112FusionIndex, +segment: N111Segment, +hash: U32, +mask: U32) -> P112FusionIndex:
  nt_choose(P112FusionIndex,U32.is_eq(U32.and(hash,mask),0),
    u => P112FusionNode{mask,P112FusionLeaf{hash,[segment]},tree},
    u => P112FusionNode{mask,tree,P112FusionLeaf{hash,[segment]}})


@unsafe
def p112f_index_insert(+tree: P112FusionIndex, +segment: N111Segment, +hash: U32, +split: U32) -> P112FusionIndex:
  match tree:
    case P112FusionEmpty{}: P112FusionLeaf{hash,[segment]}
    case P112FusionLeaf{+stored,+bucket}:
      nt_choose(P112FusionIndex,U32.is_eq(split,0),
        u => P112FusionLeaf{hash,p112f_index_bucket_add(bucket,segment)},u => p112f_index_join(tree,segment,hash,split))
    case P112FusionNode{+mask,+left,+right}:
      nt_choose(P112FusionIndex,Bool.not(U32.is_eq(split,0)) && U32.is_lt(split,mask),
        u => p112f_index_join(tree,segment,hash,split),u =>
        nt_choose(P112FusionIndex,U32.is_eq(U32.and(hash,mask),0),
          v => P112FusionNode{mask,p112f_index_insert(left,segment,hash,split),right},
          v => P112FusionNode{mask,left,p112f_index_insert(right,segment,hash,split)}))


@unsafe
def p112f_index_add(+tree: P112FusionIndex, +segment: N111Segment) -> P112FusionIndex:
  match segment:
    case N111Segment{+name,+arity,+result,+incoming,+flags,+body}:
      +hash = index_hash(name,2166136261)
      p112f_index_insert(tree,segment,hash,index_split_bit(U32.xor(hash,p112f_index_tip(tree,hash))))


@unsafe
def p112f_index_build(segments: List<&2,N111Segment>, +tree: P112FusionIndex) -> P112FusionIndex:
  match segments:
    case Nil{}: tree
    case Con{+segment,+rest}: p112f_index_build(rest,p112f_index_add(tree,segment))


@unsafe
def p112f_index(segments: List<&2,N111Segment>) -> P112FusionIndex:
  p112f_index_build(segments,P112FusionEmpty{})

# Compatibility helper retains the former list-input interface. The emission
# and counting loops use p112f_index_get with their one shared program index.


@unsafe
def p112f_find(+segments: List<&2,N111Segment>, +name: String) -> Maybe<&2,N111Segment>:
  p112f_index_get(p112f_index(segments),name)


@unsafe
def p112f_name(+prefix: String, +name: String) -> String:
  nt_choose(String,String.eq(name,"state"),u => name,u => prefix ++ "local_" ++ name)


@unsafe
def p112f_value(value: N111Value, +prefix: String) -> N111Value:
  match value:
    case N111Local{+name}: N111Local{p112f_name(prefix,name)}
    case _: value


@unsafe
def p112f_args(args: List<&2,N111Arg>, +prefix: String) -> List<&2,N111Arg>:
  match args:
    case Nil{}: []
    case Con{N111Arg{+typ,+value},+rest}: Con{N111Arg{typ,p112f_value(value,prefix)},p112f_args(rest,prefix)}


@unsafe
def p112f_rename(body: List<&2,N111Stmt>, +prefix: String) -> List<&2,N111Stmt>:
  match body:
    case Nil{}: []
    case Con{+stmt,+rest}: Con{p112f_stmt(stmt,prefix),p112f_rename(rest,prefix)}


@unsafe
def p112f_stmt(stmt: N111Stmt, +prefix: String) -> N111Stmt:
  match stmt:
    case N111Set{+name,+typ,+value}: N111Set{p112f_name(prefix,name),typ,p112f_value(value,prefix)}
    case N111Bin{+name,+typ,+op,+left,+right}: N111Bin{p112f_name(prefix,name),typ,op,p112f_value(left,prefix),p112f_value(right,prefix)}
    case N111Call{+name,+typ,+symbol,+args}: N111Call{p112f_name(prefix,name),typ,symbol,p112f_args(args,prefix)}
    case N111If{+condition,+yes,+no}: N111If{p112f_value(condition,prefix),p112f_rename(yes,prefix),p112f_rename(no,prefix)}
    case N111Return{+value}: N111Return{p112f_value(value,prefix)}
    case N111Load{+name,+typ,+base,+offset}: N111Load{p112f_name(prefix,name),typ,p112f_value(base,prefix),offset}
    case N111Store{+typ,+base,+offset,+value}: N111Store{typ,p112f_value(base,prefix),offset,p112f_value(value,prefix)}
    case N111Offset{+name,+base,+bytes}: N111Offset{p112f_name(prefix,name),p112f_value(base,prefix),p112f_value(bytes,prefix)}
    case N111Alloca{+name,+bytes,+align}: N111Alloca{p112f_name(prefix,name),bytes,align}


@unsafe
def p112f_clean_name(+name: String) -> Bool:
  Bool.not(String.starts_with(name,"p112f_"))


@unsafe
def p112f_clean_value(value: N111Value) -> Bool:
  match value:
    case N111Local{+name}: p112f_clean_name(name)
    case _: True{}


@unsafe
def p112f_clean_args(args: List<&2,N111Arg>) -> Bool:
  match args:
    case Nil{}: True{}
    case Con{N111Arg{+typ,+value},+rest}: p112f_clean_value(value) && p112f_clean_args(rest)


@unsafe
def p112f_clean(body: List<&2,N111Stmt>) -> Bool:
  match body:
    case Nil{}: True{}
    case Con{+stmt,+rest}: p112f_clean_stmt(stmt) && p112f_clean(rest)


@unsafe
def p112f_clean_stmt(stmt: N111Stmt) -> Bool:
  match stmt:
    case N111Set{+name,+typ,+value}: p112f_clean_name(name) && p112f_clean_value(value)
    case N111Bin{+name,+typ,+op,+left,+right}: p112f_clean_name(name) && p112f_clean_value(left) && p112f_clean_value(right)
    case N111Call{+name,+typ,+symbol,+args}: p112f_clean_name(name) && p112f_clean_args(args)
    case N111If{+condition,+yes,+no}: p112f_clean_value(condition) && p112f_clean(yes) && p112f_clean(no)
    case N111Return{+value}: p112f_clean_value(value)
    case N111Load{+name,+typ,+base,+offset}: p112f_clean_name(name) && p112f_clean_value(base)
    case N111Store{+typ,+base,+offset,+value}: p112f_clean_value(base) && p112f_clean_value(value)
    case N111Offset{+name,+base,+bytes}: p112f_clean_name(name) && p112f_clean_value(base) && p112f_clean_value(bytes)
    case N111Alloca{+name,+bytes,+align}: p112f_clean_name(name)


@unsafe
def p112f_frame(body: List<&2,N111Stmt>, +index: U32, +captures: List<&2,N111Value>) -> Maybe<&2,P112FusionFrame>:
  match body:
    case Con{N111Store{N111U64{},N111Local{+base},+offset,+value},+rest}:
      nt_choose(Maybe<&2,P112FusionFrame>,String.eq(base,"scratch") && U32.is_eq(offset,U32.mul(index,8)) && U32.is_lt(index,8),
        u => p112f_frame(rest,U32.inc(index),Con{value,captures}),u => None{})
    case Con{N111Call{+dest,N111U64{},+symbol,Con{N111Arg{N111Ptr{},N111Local{+state}},Con{N111Arg{N111U32{},N111FuncId{+name}},Con{N111Arg{N111Ptr{},N111Local{+scratch}},Con{N111Arg{N111U32{},N111Const{+count,0}},Nil{}}}}}},+rest}:
      nt_choose(Maybe<&2,P112FusionFrame>,String.eq(symbol,"p111_rt_frame") && String.eq(state,"state") && String.eq(scratch,"scratch") && U32.is_eq(count,index),
        u => Some{P112FusionFrame{nt_reverse(N111Value,captures,[]),name,dest,rest}},u => None{})
    case _: None{}

# The remainder may manipulate frames and transfer control, but cannot observe
# the register bank, popped stack slots, raw state, or arbitrary external effects.


@unsafe
def p112f_transition(body: List<&2,N111Stmt>) -> Bool:
  match body:
    case Con{N111Call{+dest,N111U64{},+symbol,+args},Con{N111Return{N111Local{+word}},Nil{}}}:
      String.eq(dest,word) && p112t_runtime_args(args) &&
        (String.eq(symbol,"p111_rt_jump") || String.eq(symbol,"p111_rt_return") || String.eq(symbol,"p111_rt_apply") || String.eq(symbol,"p111_rt_fail"))
    case _: False{}


@unsafe
def p112f_safe(+body: List<&2,N111Stmt>) -> Bool:
  nt_choose(Bool,p112f_transition(body),u => True{},u => p112f_safe_next(body))


@unsafe
def p112f_safe_next(body: List<&2,N111Stmt>) -> Bool:
  match body:
    case Nil{}: True{}
    case Con{N111If{+condition,+yes,+no},+rest}: p112f_safe(yes) && p112f_safe(no) && p112f_safe(rest)
    case Con{+stmt,+rest}: (p112t_scalar_safe(stmt) || p112t_failure_frame(stmt)) && p112f_safe(rest)


@unsafe
def p112f_size(body: List<&2,N111Stmt>) -> U32:
  match body:
    case Nil{}: 0
    case Con{N111If{+condition,+yes,+no},+rest}: U32.add(1,U32.add(p112f_size(yes),U32.add(p112f_size(no),p112f_size(rest))))
    case Con{+stmt,+rest}: U32.inc(p112f_size(rest))


@unsafe
def p112f_cont_result(body: List<&2,N111Stmt>, +captures: List<&2,String>, +pop: String) -> Maybe<&2,P112FusionCont>:
  match body:
    case Con{N111Call{+word,N111U64{},+symbol,Con{N111Arg{N111Ptr{},N111Local{+state}},Con{N111Arg{N111U32{},N111Const{0,0}},Nil{}}}},+rest}:
      nt_choose(Maybe<&2,P112FusionCont>,String.eq(symbol,"p111_rt_reg_get") && String.eq(state,"state") && Bool.not(nb_contains(captures,word) || String.eq(word,"state") || String.eq(word,"scratch")) && p112f_safe(rest) && U32.is_le(p112f_size(rest),128),
        u => Some{P112FusionCont{nt_reverse(String,captures,[]),word,pop,rest}},u => None{})
    case _: None{}


@unsafe
def p112f_cont_gets(+body: List<&2,N111Stmt>, +count: U32, +index: U32, +captures: List<&2,String>, +pop: String) -> Maybe<&2,P112FusionCont>:
  nt_choose(Maybe<&2,P112FusionCont>,U32.is_eq(count,index),u => p112f_cont_result(body,captures,pop),u =>
    p112f_cont_get(body,count,index,captures,pop))


@unsafe
def p112f_cont_get(body: List<&2,N111Stmt>, +count: U32, +index: U32, +captures: List<&2,String>, +pop: String) -> Maybe<&2,P112FusionCont>:
  match body:
    case Con{N111Call{+word,N111U64{},+symbol,Con{N111Arg{N111Ptr{},N111Local{+state}},Con{N111Arg{N111U32{},N111Const{+slot,0}},Nil{}}}},+rest}:
      nt_choose(Maybe<&2,P112FusionCont>,String.eq(symbol,"p111_rt_stack_get") && String.eq(state,"state") && U32.is_eq(slot,index) && Bool.not(nb_contains(captures,word) || String.eq(word,"state") || String.eq(word,"scratch")),
        u => p112f_cont_gets(rest,count,U32.inc(index),Con{word,captures},pop),u => None{})
    case _: None{}


@unsafe
def p112f_cont_pop(body: List<&2,N111Stmt>, +count: U32) -> Maybe<&2,P112FusionCont>:
  match body:
    case Con{N111Call{+word,N111U64{},+symbol,Con{N111Arg{N111Ptr{},N111Local{+state}},Con{N111Arg{N111U32{},N111Const{+held,0}},Nil{}}}},+rest}:
      nt_choose(Maybe<&2,P112FusionCont>,String.eq(symbol,"p111_rt_stack_pop") && String.eq(state,"state") && U32.is_eq(held,count),
        u => p112f_cont_gets(rest,count,0,[],word),u => None{})
    case _: None{}


@unsafe
def p112f_cont_body(body: List<&2,N111Stmt>, +count: U32) -> Maybe<&2,P112FusionCont>:
  match body:
    case Con{N111Alloca{+name,2048,8},+rest}:
      nt_choose(Maybe<&2,P112FusionCont>,String.eq(name,"scratch"),u =>
        nt_choose(Maybe<&2,P112FusionCont>,U32.is_eq(count,0),v => p112f_cont_gets(rest,0,0,[],""),v => p112f_cont_pop(rest,count)),u => None{})
    case _: None{}


@unsafe
def p112f_cont(segment: N111Segment, +count: U32) -> Maybe<&2,P112FusionCont>:
  match segment:
    case N111Segment{+name,+arity,+result,+incoming,+flags,+body}:
      nt_choose(Maybe<&2,P112FusionCont>,U32.is_eq(arity,U32.inc(count)) && U32.is_eq(result,1) && U32.is_eq(incoming,1) && U32.is_eq(flags,0) && p112f_clean(body),
        u => p112f_cont_body(body,count),u => None{})


@unsafe
def p112f_values(body: List<&2,N111Stmt>, left: U32) -> List<&2,N111Value>:
  match body left:
    case _ 0: []
    case Con{N111Store{+typ,+base,+offset,+value},+rest} _: Con{value,p112f_values(rest,U32.sub(left,1))}
    case _ _: []


@unsafe
def p112f_snapshots(values: List<&2,N111Value>, +prefix: String, +kind: String, +index: U32) -> List<&2,N111Stmt>:
  match values:
    case Nil{}: []
    case Con{+value,+rest}: Con{N111Set{prefix ++ kind ++ U32.show(index),N111U64{},value},p112f_snapshots(rest,prefix,kind,U32.inc(index))}


@unsafe
def p112f_callargs(+count: U32, +index: U32, +prefix: String) -> List<&2,N111Arg>:
  nt_choose(List<&2,N111Arg>,U32.is_eq(count,index),u => [],u =>
    Con{N111Arg{N111U64{},N111Local{prefix ++ "arg_" ++ U32.show(index)}},p112f_callargs(count,U32.inc(index),prefix)})


@unsafe
def p112f_bind_captures(words: List<&2,String>, +prefix: String, +index: U32) -> List<&2,N111Stmt>:
  match words:
    case Nil{}: []
    case Con{+word,+rest}: Con{N111Set{p112f_name(prefix,word),N111U64{},N111Local{prefix ++ "capture_" ++ U32.show(index)}},p112f_bind_captures(rest,prefix,U32.inc(index))}


@unsafe
def p112f_inline(cont: P112FusionCont, +prefix: String) -> List<&2,N111Stmt>:
  match cont:
    case P112FusionCont{+captures,+result,+pop,+body}:
      Con{N111Alloca{p112f_name(prefix,"scratch"),2048,8},
        nt_append(N111Stmt,nt_choose(List<&2,N111Stmt>,String.eq(pop,""),u => [],u => [N111Set{p112f_name(prefix,pop),N111U64{},N111Const{0,0}}]),
          nt_append(N111Stmt,p112f_bind_captures(captures,prefix,0),
            Con{N111Set{p112f_name(prefix,result),N111U64{},N111Local{prefix ++ "result"}},p112f_rename(body,prefix)}))}


@unsafe
def p112f_fused(frame: P112FusionFrame, +cont: P112FusionCont, +target: String, +arity: U32, +site: U32) -> List<&2,N111Stmt>:
  match frame:
    case P112FusionFrame{+captures,+name,+dest,+tail}:
      +prefix = "p112f_" ++ U32.show(site) ++ "_"
      nt_append(N111Stmt,p112f_snapshots(captures,prefix,"capture_",0),
        Con{N111Set{dest,N111U64{},N111Const{0,0}},
          nt_append(N111Stmt,p112f_snapshots(p112f_values(tail,arity),prefix,"arg_",0),
            Con{N111Call{prefix ++ "result",N111U64{},p112w_symbol(target),Con{p111_state(),p112f_callargs(arity,0,prefix)}},p112f_inline(cont,prefix)})})


@unsafe
def p112f_found(+frame: P112FusionFrame, +target: String, +arity: U32, +site: U32, found: Maybe<&2,N111Segment>) -> Maybe<&2,List<&2,N111Stmt>>:
  match frame found:
    case _ None{}: None{}
    case P112FusionFrame{+captures,+name,+dest,+tail} Some{+segment}:
      p112f_cont_found(frame,target,arity,site,p112f_cont(segment,nt_count(N111Value,captures)))


@unsafe
def p112f_cont_found(+frame: P112FusionFrame, +target: String, +arity: U32, +site: U32, found: Maybe<&2,P112FusionCont>) -> Maybe<&2,List<&2,N111Stmt>>:
  match found:
    case None{}: None{}
    case Some{+cont}: Some{p112f_fused(frame,cont,target,arity,site)}


@unsafe
def p112f_target(+frame: P112FusionFrame, +index: P112FusionIndex, +ready: KDef, +site: U32, +target: String) -> Maybe<&2,List<&2,N111Stmt>>:
  match frame:
    case P112FusionFrame{+captures,+name,+dest,+tail}:
      +arity = da(p111v_get(ready,target))
      nt_choose(Maybe<&2,List<&2,N111Stmt>>,p112w_ready(ready,target) && U32.is_le(arity,8) && p112t_tail(tail,target,arity,0),
        u => p112f_found(frame,target,arity,site,p112f_index_get(index,name)),u => None{})


@unsafe
def p112f_try_frame(frame: Maybe<&2,P112FusionFrame>, +index: P112FusionIndex, +ready: KDef, +site: U32) -> Maybe<&2,List<&2,N111Stmt>>:
  match frame:
    case None{}: None{}
    case Some{+value}:
      match value:
        case P112FusionFrame{+captures,+name,+dest,+tail}: p112f_target(value,index,ready,site,p112w_target(tail))


@unsafe
def p112f_try(+body: List<&2,N111Stmt>, +index: P112FusionIndex, +ready: KDef, +site: U32) -> Maybe<&2,List<&2,N111Stmt>>:
  nt_choose(Maybe<&2,List<&2,N111Stmt>>,U32.is_lt(site,8),
    u => p112f_try_frame(p112f_frame(body,0,[]),index,ready,site),u => None{})


@unsafe
def p112f_scan(+body: List<&2,N111Stmt>, +index: P112FusionIndex, +ready: KDef, +site: U32) -> P112FusionBody:
  p112f_scan_try(body,index,ready,site,p112f_try(body,index,ready,site))


@unsafe
def p112f_scan_try(+body: List<&2,N111Stmt>, +index: P112FusionIndex, +ready: KDef, +site: U32, attempt: Maybe<&2,List<&2,N111Stmt>>) -> P112FusionBody:
  match attempt:
    case Some{+fused}: P112FusionBody{fused,1,U32.inc(site)}
    case None{}: p112f_scan_next(body,index,ready,site)


@unsafe
def p112f_prepend(+stmt: N111Stmt, tail: P112FusionBody) -> P112FusionBody:
  match tail:
    case P112FusionBody{+body,+count,+next}: P112FusionBody{Con{stmt,body},count,next}


@unsafe
def p112f_scan_next(body: List<&2,N111Stmt>, +index: P112FusionIndex, +ready: KDef, +site: U32) -> P112FusionBody:
  match body:
    case Nil{}: P112FusionBody{[],0,site}
    case Con{N111If{+condition,+yes,+no},+rest}: p112f_scan_yes(condition,no,rest,index,ready,p112f_scan(yes,index,ready,site))
    case Con{+stmt,+rest}: p112f_prepend(stmt,p112f_scan(rest,index,ready,site))


@unsafe
def p112f_scan_yes(+condition: N111Value, +no: List<&2,N111Stmt>, +rest: List<&2,N111Stmt>, +index: P112FusionIndex, +ready: KDef, yes: P112FusionBody) -> P112FusionBody:
  match yes:
    case P112FusionBody{+body,+count,+next}: p112f_scan_no(condition,body,count,rest,index,ready,p112f_scan(no,index,ready,next))


@unsafe
def p112f_scan_no(+condition: N111Value, +yes: List<&2,N111Stmt>, +yc: U32, +rest: List<&2,N111Stmt>, +index: P112FusionIndex, +ready: KDef, no: P112FusionBody) -> P112FusionBody:
  match no:
    case P112FusionBody{+body,+count,+next}: p112f_scan_rest(condition,yes,body,U32.add(yc,count),p112f_scan(rest,index,ready,next))


@unsafe
def p112f_scan_rest(+condition: N111Value, +yes: List<&2,N111Stmt>, +no: List<&2,N111Stmt>, +bc: U32, rest: P112FusionBody) -> P112FusionBody:
  match rest:
    case P112FusionBody{+body,+count,+next}: P112FusionBody{Con{N111If{condition,yes,no},body},U32.add(bc,count),next}


@unsafe
def p112f_plan_index(+segment: N111Segment, +index: P112FusionIndex, +ready: KDef) -> P112FusionBody:
  match segment:
    case N111Segment{+name,+arity,+result,+incoming,+flags,+body}:
      nt_choose(P112FusionBody,U32.is_eq(result,1) && U32.is_eq(flags,0) && p112f_clean(body),
        u => p112f_scan(body,index,ready,0),u => P112FusionBody{body,0,0})


@unsafe
def p112f_plan(+segment: N111Segment, +segments: List<&2,N111Segment>, +ready: KDef) -> P112FusionBody:
  p112f_plan_index(segment,p112f_index(segments),ready)


@unsafe
def p112f_public(+segment: N111Segment, +ids: N111Ids, +ready: KDef, plan: P112FusionBody) -> String:
  match segment plan:
    case N111Segment{+name,+arity,+result,+incoming,+flags,+original} P112FusionBody{+body,+count,+next}:
      nt_choose(String,U32.is_eq(count,0),u => p112w_public_segment(segment,ids,ready),
        u => p112w_public_segment(N111Segment{name,arity,result,incoming,flags,body},ids,ready))


@unsafe
def p112f_chunk_index(+segment: N111Segment, +index: P112FusionIndex, +ids: N111Ids, +ready: KDef, +targets: KDef) -> String:
  match segment:
    case N111Segment{+name,+arity,+result,+incoming,+flags,+body}:
      p112f_public(segment,ids,ready,p112f_plan_index(segment,index,ready)) ++ nt_choose(String,p112w_ready(targets,name),
        u => p112w_private(segment,ids,p112w_plan(segment,ready)),u => "")


@unsafe
def p112f_chunk(+segment: N111Segment, +segments: List<&2,N111Segment>, +ids: N111Ids, +ready: KDef, +targets: KDef) -> String:
  p112f_chunk_index(segment,p112f_index(segments),ids,ready,targets)


@unsafe
def p112f_chunks_index(todo: List<&2,N111Segment>, +index: P112FusionIndex, +ids: N111Ids, +ready: KDef, +targets: KDef, acc: List<&2,String>) -> List<&2,String>:
  match todo:
    case Nil{}: nt_reverse(String,acc,[])
    case Con{+segment,+rest}: p112f_chunks_index(rest,index,ids,ready,targets,Con{p112f_chunk_index(segment,index,ids,ready,targets),acc})


@unsafe
def p112f_chunks(+todo: List<&2,N111Segment>, +segments: List<&2,N111Segment>, +ids: N111Ids, +ready: KDef, +targets: KDef, +acc: List<&2,String>) -> List<&2,String>:
  p112f_chunks_index(todo,p112f_index(segments),ids,ready,targets,acc)


@unsafe
def p112f_indexed(+segments: List<&2,N111Segment>, +ids: N111Ids, +ready: KDef, +acc: List<&2,String>) -> List<&2,String>:
  p112f_chunks(segments,segments,ids,ready,p112w_targets(segments,ready,missing()),acc)


@unsafe
def p112f_segment_chunks(+segments: List<&2,N111Segment>, +ids: N111Ids, +acc: List<&2,String>) -> List<&2,String>:
  p112f_indexed(segments,ids,p112w_index(segments),acc)


def p112f_count(plan: P112FusionBody) -> U32:
  match plan:
    case P112FusionBody{+body,+count,+next}: count


@unsafe
def p112f_counts_index(todo: List<&2,N111Segment>, +index: P112FusionIndex, +ready: KDef, +changed: U32, +sites: U32) -> String:
  match todo:
    case Nil{}: U32.show(changed) ++ "/" ++ U32.show(sites)
    case Con{+segment,+rest}:
      +count = p112f_count(p112f_plan_index(segment,index,ready))
      p112f_counts_index(rest,index,ready,U32.add(changed,nt_bool(U32.is_gt(count,0))),U32.add(sites,count))


@unsafe
def p112f_counts(+todo: List<&2,N111Segment>, +segments: List<&2,N111Segment>, +ready: KDef, +changed: U32, +sites: U32) -> String:
  p112f_counts_index(todo,p112f_index(segments),ready,changed,sites)


@unsafe
def p112f_program_counts(program: P111Program) -> String:
  match program:
    case P111Program{+segments,+constructors,+show,+show_names,+effects,+pure}: p112f_counts(segments,segments,p112w_index(segments),0,0)


@unsafe
def p112fp_after_accessors(+stmt: N111Stmt, +ids: N111Ids, result: P112FPEmission) -> P111QCode:
  match result:
    case P112FPEmission{expanded,+code}:
      nt_choose(P111QCode,expanded,u => code,u => p112a_stmt(3,stmt,ids,code))
