# Mirror the mature NF self-tail criterion (exact owner, terminal position,
# arity), then use the checked structured graph rather than NF's generated C.
# Additional state/scheduler restrictions make unsupported segments fall back.
@unsafe
def p112t_params(+body: List<&2,N111Stmt>, +arity: U32, +index: U32,
  +params: List<&2,String>, +prefix: List<&2,N111Stmt>) -> P112TailPrelude:
  nt_choose(P112TailPrelude,U32.is_eq(index,arity),
    u => P112TailPrelude{True{},nt_reverse(String,params,[]),nt_reverse(N111Stmt,prefix,[]),body},
    u => p112t_param(body,arity,index,params,prefix))

@unsafe
def p112t_param(+body: List<&2,N111Stmt>, +arity: U32, +index: U32,
  +params: List<&2,String>, +prefix: List<&2,N111Stmt>) -> P112TailPrelude:
  match body:
    case Con{+stmt,rest}: p112t_param_stmt(stmt,rest,arity,index,params,prefix)
    case _: P112TailPrelude{False{},[],[],[]}

@unsafe
def p112t_param_stmt(+stmt: N111Stmt, +rest: List<&2,N111Stmt>, +arity: U32,
  +index: U32, +params: List<&2,String>, +prefix: List<&2,N111Stmt>) -> P112TailPrelude:
  match stmt:
    case N111Call{+word,N111U64{},symbol,
      Con{N111Arg{N111Ptr{},N111Local{state}},Con{N111Arg{N111U32{},N111Const{slot,hi}},Nil{}}}}:
      nt_choose(P112TailPrelude,String.eq(symbol,"p111_rt_reg_get") && String.eq(state,"state") &&
        U32.is_eq(slot,index) && U32.is_eq(hi,0) && Bool.not(nb_contains(params,word)),
        u => p112t_params(rest,arity,U32.inc(index),Con{word,params},Con{stmt,prefix}),
        u => P112TailPrelude{False{},[],[],[]})
    case _: P112TailPrelude{False{},[],[],[]}

@unsafe
def p112t_prelude(body: List<&2,N111Stmt>, +arity: U32) -> P112TailPrelude:
  match body:
    case Con{N111Alloca{name,bytes,align},+rest}:
      nt_choose(P112TailPrelude,String.eq(name,"scratch") && U32.is_eq(bytes,2048) && U32.is_eq(align,8),
        u => p112t_params(rest,arity,0,[],[N111Alloca{"scratch",2048,8}]),
        u => P112TailPrelude{False{},[],[],[]})
    case _: P112TailPrelude{False{},[],[],[]}

@unsafe
def p112t_jump_args(args: List<&2,N111Arg>, +owner: String, +arity: U32) -> Bool:
  match args:
    case Con{N111Arg{N111Ptr{},N111Local{state}},
      Con{N111Arg{N111U32{},N111FuncId{name}},
      Con{N111Arg{N111Ptr{},N111Local{scratch}},
      Con{N111Arg{N111U32{},N111Const{count,hi}},Nil{}}}}}:
      String.eq(state,"state") && String.eq(name,owner) && String.eq(scratch,"scratch") &&
        U32.is_eq(count,arity) && U32.is_eq(hi,0)
    case _: False{}

@unsafe
def p112t_jump(body: List<&2,N111Stmt>, +owner: String, +arity: U32) -> Bool:
  match body:
    case Con{N111Call{+dest,N111U64{},symbol,args},Con{N111Return{N111Local{word}},Nil{}}}:
      String.eq(symbol,"p111_rt_jump") && String.eq(dest,word) && p112t_jump_args(args,owner,arity)
    case _: False{}

@unsafe
def p112t_tail(+body: List<&2,N111Stmt>, +owner: String, +arity: U32, +index: U32) -> Bool:
  nt_choose(Bool,U32.is_eq(index,arity),u => p112t_jump(body,owner,arity),
    u => p112t_tail_store(body,owner,arity,index))

@unsafe
def p112t_tail_store(body: List<&2,N111Stmt>, +owner: String, +arity: U32, +index: U32) -> Bool:
  match body:
    case Con{N111Store{N111U64{},N111Local{base},offset,value},rest}:
      String.eq(base,"scratch") && U32.is_eq(offset,U32.mul(index,8)) &&
        p112t_tail(rest,owner,arity,U32.inc(index))
    case _: False{}

# The exact stores are retained. Again snapshots every slot before rebinding.
@unsafe
def p112t_tail_nodes(body: List<&2,N111Stmt>, left: U32) -> List<&2,P112TailStmt>:
  match body left:
    case _ 0: [P112TailAgain{}]
    case Con{stmt,rest} _: Con{P112TailScalar{stmt},p112t_tail_nodes(rest,U32.sub(left,1))}
    case _ _: []

@unsafe
def p112t_runtime_call(+symbol: String) -> Bool:
  String.eq(symbol,"p111_rt_keep") || String.eq(symbol,"p111_rt_sink") ||
  String.eq(symbol,"p111_rt_ctor") || String.eq(symbol,"p111_rt_take") ||
  String.eq(symbol,"p111_rt_closure") || String.eq(symbol,"p111_rt_tag") ||
  String.eq(symbol,"p111_rt_op") || String.eq(symbol,"p111_rt_special_ctor") ||
  String.eq(symbol,"p111_rt_special_test") || String.eq(symbol,"p111_rt_special_take")

@unsafe
def p112t_scalar_safe(stmt: N111Stmt) -> Bool:
  match stmt:
    case N111Set{name,N111Ptr{},value}: False{}
    case N111Set{name,typ,value}: True{}
    case N111Bin{name,N111Ptr{},op,left,right}: False{}
    case N111Bin{name,typ,op,left,right}: True{}
    case N111Call{name,N111U64{},symbol,args}: p112t_runtime_call(symbol)
    case N111Load{name,N111U64{},N111Local{base},offset}: String.eq(base,"scratch")
    case N111Store{N111U64{},N111Local{base},offset,value}: String.eq(base,"scratch")
    case _: False{}

# Other exits retain their exact transition. No transition helper may appear
# earlier in a path, and bare machine returns are outside this private plan.
@unsafe
def p112t_transition(body: List<&2,N111Stmt>) -> Bool:
  match body:
    case Con{N111Call{dest,N111U64{},symbol,args},Con{N111Return{N111Local{word}},Nil{}}}:
      (String.eq(symbol,"p111_rt_jump") || String.eq(symbol,"p111_rt_return")) && String.eq(dest,word)
    case _: False{}

def p112t_scalars(body: List<&2,N111Stmt>) -> List<&2,P112TailStmt>:
  match body:
    case Nil{}: []
    case Con{stmt,rest}: Con{P112TailScalar{stmt},p112t_scalars(rest)}

@unsafe
def p112t_prepend_scalar(+stmt: N111Stmt, tail: P112TailBody) -> P112TailBody:
  match tail:
    case P112TailBody{valid,loops,body}: P112TailBody{valid && p112t_scalar_safe(stmt),loops,Con{P112TailScalar{stmt},body}}

@unsafe
def p112t_branch(+condition: N111Value, yes: P112TailBody, no: P112TailBody, tail: P112TailBody) -> P112TailBody:
  match yes no tail:
    case P112TailBody{yv,yl,yb} P112TailBody{nv,nl,nb} P112TailBody{tv,tl,tb}:
      P112TailBody{yv && nv && tv,U32.add(yl,U32.add(nl,tl)),Con{P112TailIf{condition,yb,nb},tb}}

@unsafe
def p112t_scan(+body: List<&2,N111Stmt>, +owner: String, +arity: U32) -> P112TailBody:
  nt_choose(P112TailBody,p112t_tail(body,owner,arity,0),
    u => P112TailBody{True{},1,p112t_tail_nodes(body,arity)},
    u => nt_choose(P112TailBody,p112t_transition(body),
      v => P112TailBody{True{},0,p112t_scalars(body)},v => p112t_scan_next(body,owner,arity)))

@unsafe
def p112t_scan_next(body: List<&2,N111Stmt>, +owner: String, +arity: U32) -> P112TailBody:
  match body:
    case Nil{}: P112TailBody{True{},0,[]}
    case Con{N111If{condition,yes,no},rest}:
      p112t_branch(condition,p112t_scan(yes,owner,arity),p112t_scan(no,owner,arity),p112t_scan(rest,owner,arity))
    case Con{stmt,rest}: p112t_prepend_scalar(stmt,p112t_scan(rest,owner,arity))

@unsafe
def p112t_finish(+params: List<&2,String>, +prefix: List<&2,N111Stmt>, body: P112TailBody) -> P112TailPlan:
  match body:
    case P112TailBody{valid,loops,nodes}: P112TailPlan{valid && U32.is_gt(loops,0),loops,params,prefix,nodes}

@unsafe
def p112t_admit_prelude(+owner: String, +arity: U32, prelude: P112TailPrelude) -> P112TailPlan:
  match prelude:
    case P112TailPrelude{+valid,+params,+prefix,+body}:
      nt_choose(P112TailPlan,valid,u => p112t_finish(params,prefix,p112t_scan(body,owner,arity)),
        u => P112TailPlan{False{},0,[],[],[]})

@unsafe
def p112t_plan(segment: N111Segment) -> P112TailPlan:
  match segment:
    case N111Segment{+name,+arity,result,incoming,flags,+body}:
      nt_choose(P112TailPlan,U32.is_eq(incoming,0) && U32.is_eq(flags,0) &&
        U32.is_eq(result,1) && U32.is_le(arity,255),
        u => p112t_admit_prelude(name,arity,p112t_prelude(body,arity)),
        u => P112TailPlan{False{},0,[],[],[]})

def p112t_admitted(plan: P112TailPlan) -> Bool:
  match plan:
    case P112TailPlan{valid,loops,params,prefix,body}: valid

def p112t_loop_count(plan: P112TailPlan) -> U32:
  match plan:
    case P112TailPlan{valid,loops,params,prefix,body}: nt_choose(U32,valid,u => loops,u => 0)

@unsafe
def p112t_count_segments(segments: List<&2,N111Segment>, +acc: U32) -> U32:
  match segments:
    case Nil{}: acc
    case Con{segment,rest}: p112t_count_segments(rest,U32.add(acc,nt_bool(p112t_admitted(p112t_plan(segment)))))

@unsafe
def p112t_count_loops(segments: List<&2,N111Segment>, +acc: U32) -> U32:
  match segments:
    case Nil{}: acc
    case Con{segment,rest}: p112t_count_loops(rest,U32.add(acc,p112t_loop_count(p112t_plan(segment))))

@unsafe
def p112t_program_counts(program: P111Program) -> String:
  match program:
    case P111Program{+segments,constructors,show,show_names,effects,pure}:
      U32.show(p112t_count_segments(segments,0)) ++ "/" ++ U32.show(p112t_count_loops(segments,0))
