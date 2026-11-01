

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
    case N111Call{name,N111U64{},symbol,args}: p112t_runtime_call(symbol) && p112t_runtime_args(args)
    case N111Load{name,N111U64{},N111Local{base},offset}: String.eq(base,"scratch")
    case N111Store{N111U64{},N111Local{base},offset,value}: String.eq(base,"scratch")
    case _: False{}

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
  nt_choose(P112TailBody,p112t_failure(body),u => P112TailBody{True{},0,p112t_scalars(body)},u =>
    p112t_scan_normal(body,owner,arity))

@unsafe
def p112t_scan_next(body: List<&2,N111Stmt>, +owner: String, +arity: U32) -> P112TailBody:
  match body:
    case Nil{}: P112TailBody{True{},0,[]}
    case Con{N111If{condition,yes,no},rest}:
      p112e_tail_yes(condition,no,rest,owner,arity,p112t_scan(yes,owner,arity))
    case Con{+stmt,+rest}:
      nt_choose(P112TailBody,p112t_scalar_safe(stmt),
        u => p112e_tail_scalar(stmt,p112t_scan_normal(rest,owner,arity)),u => P112TailBody{False{},0,[]})

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


@unsafe
def p112q_snapshots(+count: U32, +index: U32, +code: P111QCode) -> P111QCode:
  nt_choose(P111QCode,U32.is_eq(index,count),u => code,u =>
    p112q_snapshot(count,index,code))


@unsafe
def p112q_snapshot(+count: U32, +index: U32, code: P111QCode) -> P111QCode:
  match code:
    case P111QCode{chunks,n,terminal,error}:
      p112q_snapshots(count,U32.inc(index),P111QCode{
        Con{"%p112_arg_" ++ U32.show(index) ++ " =l loadl %p112_at_" ++ U32.show(index) ++ "\n",
        Con{"%p112_at_" ++ U32.show(index) ++ " =l add %v_scratch, " ++ U32.show(U32.mul(index,8)) ++ "\n",chunks}},n,terminal,error})


@unsafe
def p112q_moves(params: List<&2,String>, +index: U32, +code: P111QCode) -> P111QCode:
  match params:
    case Nil{}: p112q_again(code)
    case Con{word,rest}:
      p112q_moves(rest,U32.inc(index),p111q_line(p111q_local(word) ++ " =l copy %p112_arg_" ++ U32.show(index) ++ "\n",code))


def p112q_again(code: P111QCode) -> P111QCode:
  match code:
    case P111QCode{chunks,n,terminal,error}: P111QCode{Con{"jmp @p112_again\n",chunks},n,True{},error}


@unsafe
def p112q_stmts(body: List<&2,P112TailStmt>, +params: List<&2,String>, +ids: N111Ids, +code: P111QCode) -> P111QCode:
  match body:
    case Nil{}: code
    case Con{stmt,rest}: p112q_stmts_head(stmt,rest,params,ids,code)


@unsafe
def p112q_stmts_head(+stmt: P112TailStmt, +rest: List<&2,P112TailStmt>, +params: List<&2,String>,
  +ids: N111Ids, +code: P111QCode) -> P111QCode:
  match code:
    case P111QCode{chunks,n,terminal,error}:
      nt_choose(P111QCode,String.is_empty(error),u =>
        nt_choose(P111QCode,terminal,u => p111q_problem("statement follows private loop transfer",code),u =>
          p112q_stmts(rest,params,ids,p112q_stmt(stmt,params,ids,code))),u => code)


@unsafe
def p112q_stmt(stmt: P112TailStmt, +params: List<&2,String>, +ids: N111Ids, +code: P111QCode) -> P111QCode:
  match stmt:
    case P112TailScalar{scalar}: p111q_stmt(scalar,ids,code)
    case P112TailAgain{}: p112q_moves(params,0,p112q_snapshots(nt_count(String,params),0,code))
    case P112TailIf{condition,yes,no}: p112q_if(condition,yes,no,params,ids,code)


@unsafe
def p112q_if(+condition: N111Value, +yes: List<&2,P112TailStmt>, +no: List<&2,P112TailStmt>,
  +params: List<&2,String>, +ids: N111Ids, code: P111QCode) -> P111QCode:
  match code:
    case P111QCode{chunks,n,terminal,error}:
      p112q_if_yes(n,no,params,ids,p112q_stmts(yes,params,ids,
        P111QCode{Con{p111q_label(n) ++ "\n",Con{"jnz " ++ p111q_value(condition,ids) ++ ", " ++ p111q_label(n) ++ ", " ++ p111q_label(U32.inc(n)) ++ "\n",chunks}},U32.add(n,3),False{},error}))


@unsafe
def p112q_if_yes(+label: U32, +no: List<&2,P112TailStmt>, +params: List<&2,String>, +ids: N111Ids, yes: P111QCode) -> P111QCode:
  match yes:
    case P111QCode{chunks,n,terminal,error}:
      +prefix = nt_choose(List<&2,String>,terminal,u => chunks,u => Con{"jmp " ++ p111q_label(U32.add(label,2)) ++ "\n",chunks})
      p111q_if_done(label,terminal,p112q_stmts(no,params,ids,P111QCode{Con{p111q_label(U32.inc(label)) ++ "\n",prefix},n,False{},error}))


@unsafe
def p112q_loop_body(+body: List<&2,P112TailStmt>, +params: List<&2,String>, +ids: N111Ids, code: P111QCode) -> P111QCode:
  match code:
    case P111QCode{chunks,n,terminal,error}:
      p112q_stmts(body,params,ids,P111QCode{Con{"@p112_again\n",Con{"jmp @p112_again\n",chunks}},n,False{},error})


@unsafe
def p112q_planned(+segment: N111Segment, +ids: N111Ids, plan: P112TailPlan) -> String:
  match segment plan:
    case N111Segment{+name,arity,result,incoming,flags,+original} P112TailPlan{valid,loops,+params,+prefix,+body}:
      nt_choose(String,valid,
        u => "export function l $" ++ p111q_symbol(name) ++ "(l %state) {\n@entry\n" ++
          p144e_body_tail(p112q_loop_body(body,params,ids,
            p111q_stmts(prefix,ids,P111QCode{p111q_allocas(original,[]),0,False{},""})),"}\n"),
        u => p111q_segment(segment,ids))

@unsafe
def p112q_segment(+segment: N111Segment, +ids: N111Ids) -> String:
  p112q_planned(segment,ids,p112t_plan(segment))

# Exact one-function override used by the source assembler. Public chunks,
# metadata tables, scalar emitter and mandatory verifier remain unchanged.


@unsafe
def p112q_segment_chunks(segments: List<&2,N111Segment>, +ids: N111Ids, acc: List<&2,String>) -> List<&2,String>:
  match segments:
    case Nil{}: nt_reverse(String,acc,[])
    case Con{segment,rest}: p112q_segment_chunks(rest,ids,Con{p112q_segment(segment,ids),acc})


@unsafe
def p112t_failure_args(args: List<&2,N111Arg>) -> Bool:
  match args:
    case Con{N111Arg{N111Ptr{},N111Local{state}},Con{N111Arg{N111U32{},N111Const{code,0}},Nil{}}}:
      String.eq(state,"state") && U32.is_gt(code,0) && U32.is_le(code,8)
    case _: False{}


@unsafe
def p112t_failure_frame(stmt: N111Stmt) -> Bool:
  match stmt:
    case N111Call{name,N111U64{},symbol,Con{N111Arg{N111Ptr{},N111Local{state}},Con{N111Arg{N111U32{},N111FuncId{target}},Con{N111Arg{N111Ptr{},N111Local{scratch}},Con{N111Arg{N111U32{},N111Const{count,0}},Nil{}}}}}}:
      String.eq(symbol,"p111_rt_frame") && String.eq(state,"state") && String.eq(scratch,"scratch") && U32.is_le(count,255)
    case _: False{}


@unsafe
def p112t_failure(body: List<&2,N111Stmt>) -> Bool:
  match body:
    case Con{N111Call{dest,N111U64{},symbol,args},Con{N111Return{N111Local{word}},Nil{}}}:
      String.eq(symbol,"p111_rt_fail") && String.eq(dest,word) && p112t_failure_args(args)
    case Con{+stmt,rest}: (p112t_scalar_safe(stmt) || p112t_failure_frame(stmt)) && p112t_failure(rest)
    case _: False{}

# Failure recognition runs once at block entry. Ordinary scalar tails use this
# path directly, avoiding repeated full-suffix failure scans.


@unsafe
def p112t_scan_normal(+body: List<&2,N111Stmt>, +owner: String, +arity: U32) -> P112TailBody:
  nt_choose(P112TailBody,p112t_tail(body,owner,arity,0),
    u => P112TailBody{True{},1,p112t_tail_nodes(body,arity)},
    u => nt_choose(P112TailBody,p112t_transition(body),
      v => P112TailBody{True{},0,p112t_scalars(body)},v => p112t_scan_next(body,owner,arity)))


@unsafe
def p112t_buffer_args(args: List<&2,N111Arg>) -> Bool:
  match args:
    case Nil{}: True{}
    case Con{N111Arg{N111Ptr{},N111Local{name}},rest}: String.eq(name,"scratch") && p112t_buffer_args(rest)
    case Con{N111Arg{N111Ptr{},value},rest}: False{}
    case Con{arg,rest}: p112t_buffer_args(rest)


@unsafe
def p112t_runtime_args(args: List<&2,N111Arg>) -> Bool:
  match args:
    case Con{N111Arg{N111Ptr{},N111Local{name}},rest}: String.eq(name,"state") && p112t_buffer_args(rest)
    case _: False{}


@unsafe
def p112a_original_stmt(+stmt: N111Stmt, +ids: N111Ids, +code: P111QCode) -> P111QCode:
  match stmt code:
    case N111Set{name,typ,value} P111QCode{chunks,n,terminal,error}:
      P111QCode{Con{"\n",Con{p111q_value(value,ids),Con{" copy ",Con{p111q_type(typ),Con{" =",Con{p111q_local(name),chunks}}}}}},n,terminal,error}
    case N111Bin{name,+typ,+op,left,right} P111QCode{chunks,n,terminal,error}:
      P111QCode{Con{"\n",Con{p111q_value(right,ids),Con{", ",Con{p111q_value(left,ids),Con{" ",Con{p111q_binop(op,typ),Con{" ",Con{
        nt_choose(String,p111q_comparison(op),u => "w",u => p111q_type(typ)),Con{" =",Con{p111q_local(name),chunks}}}}}}}}}},n,terminal,error}
    case N111Call{name,typ,symbol,args} P111QCode{chunks,n,terminal,error}:
      P111QCode{Con{")\n",p111q_args(args,ids,True{},
        Con{p111q_local(name) ++ " =" ++ p111q_type(typ) ++ " call $" ++ symbol ++ "(",chunks})},n,terminal,error}
    case N111Load{name,typ,base,offset} _: p111q_memory(name,typ,base,offset,N111Const{0,0},False{},ids,code)
    case N111Store{typ,base,offset,value} _: p111q_memory("",typ,base,offset,value,True{},ids,code)
    case N111Offset{name,base,bytes} P111QCode{chunks,n,terminal,error}:
      P111QCode{Con{"\n",Con{p111q_value(bytes,ids),Con{", ",Con{p111q_value(base,ids),Con{" =l add ",Con{p111q_local(name),chunks}}}}}},n,terminal,error}
    case N111If{condition,yes,no} _: p111q_if(condition,yes,no,ids,code)
    case N111Return{value} _: p111q_return(p111q_value(value,ids),code)
    case N111Alloca{name,bytes,align} _: code


@unsafe
def p112a_tag(+name: String, word: N111Value) -> List<&2, N111Stmt>:
  [N111Bin{name, N111U64{}, "shr", word, N111Const{40, 0}},
   N111Bin{name, N111U64{}, "and", N111Local{name}, N111Const{65535, 0}}]


@unsafe
def p112a_expand(+mode: U32, +stmt: N111Stmt) -> List<&2, N111Stmt>:
  match stmt:
    case N111Call{+name, N111U64{}, +symbol, Con{N111Arg{N111Ptr{}, N111Local{+context}}, Con{N111Arg{N111U64{}, +word}, Nil{}}}}:
      nt_choose(List<&2, N111Stmt>, (U32.is_eq(mode, 1) || U32.is_eq(mode, 3)) && String.eq(symbol, "p111_rt_tag") && String.eq(context, "state"),
        u => p112a_tag(name, word), u => [stmt])
    case N111Call{+name, N111U64{}, +symbol, Con{N111Arg{N111Ptr{}, N111Local{+context}}, Con{N111Arg{N111U32{}, N111Const{+index, +high}}, Nil{}}}}:
      nt_choose(List<&2, N111Stmt>, (U32.is_eq(mode, 2) || U32.is_eq(mode, 3)) && String.eq(symbol, "p111_rt_reg_get") && String.eq(context, "state") && U32.is_eq(high, 0) && U32.is_lt(index, 255),
        u => [N111Load{name, N111U64{}, N111Local{"state"}, U32.add(40, U32.mul(index, 8))}], u => [stmt])
    case _: [stmt]

# Expansion outputs are rendered through the exact original renderer. Thus an
# unchanged call cannot recurse through expansion. Original nested If rendering
# still visits the globally selected statement entry for each child statement.


@unsafe
def p112a_words(words: List<&2, N111Stmt>, +ids: N111Ids, +code: P111QCode) -> P111QCode:
  match words:
    case Nil{}: code
    case Con{head, rest}: p112a_words(rest, ids, p112a_original_stmt(head, ids, code))


@unsafe
def p112a_stmt(mode: U32, stmt: N111Stmt, ids: N111Ids, code: P111QCode) -> P111QCode:
  p112a_words(p112a_expand(mode, stmt), ids, code)
