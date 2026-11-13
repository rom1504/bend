def x181_reg(n):
  match n:
    case 0: x188_reg(12,64)
    case 1: x188_reg(3,64)
    case 2: x188_reg(13,64)
    case 3: x188_reg(14,64)
    case _: x188_reg(15,64)

def x181_argreg(n):
  match n:
    case 0: x188_reg(7,64)
    case 1: x188_reg(6,64)
    case 2: x188_reg(2,64)
    case 3: x188_reg(1,64)
    case 4: x188_reg(8,64)
    case _: x188_reg(9,64)

def x181_add(text,code):
  match code:
    case X181Code{chunks,next,terminal,error}: X181Code{Con{text,chunks},next,terminal,error}

def x181_error(text,code):
  match code:
    case X181Code{chunks,next,terminal,error}: X181Code{chunks,next,terminal,text}

def x181_epilogue(frame):
  x188_many([x186_saves_text(x186_saves_mask(frame),0,True{}),
    x188_i2("movq",x188_reg(5,64),x188_reg(4,64)),x188_i1("popq",x188_reg(5,64)),x188_i0("ret")])

def x181_return(text,frame,code):
  match code:
    case X181Code{chunks,next,terminal,error}:
      X181Code{Con{x188_cat(text,x181_epilogue(frame)),chunks},next,True{},error}

def x181_label(n: U32, frame: X181Frame) -> String:
  match frame:
    case X181Frame{slots,bytes,calls,params,symbol}: ".L" ++ symbol ++ "_b" ++ U32.show(n)

def x181_loop_label(frame: X181Frame) -> String:
  match frame:
    case X181Frame{slots,bytes,calls,params,symbol}: ".L" ++ symbol ++ "_loop"

@unsafe
def x181_stmts(body,ids,frame,code):
  match body code:
    case Nil{} _: code
    case Con{head,rest} X181Code{chunks,next,+terminal,+error}:
      nt_choose(X181Code,String.is_empty(error),
        u => nt_choose(X181Code,terminal,u => x181_error("x86 statement after terminal",code),
          u => x181_stmts(rest,ids,frame,x181_stmt(head,ids,frame,code))),u => code)

@unsafe
def x181_stmt(stmt: P113DStmt, +ids: N111Ids, +frame: X181Frame, +code: X181Code) -> X181Code:
  match stmt:
    case P113DScalar{scalar}: x181_scalar(scalar,ids,frame,code)
    case P113DIf{condition,yes,no}: x181_if(condition,yes,no,ids,frame,code)
    case P113DCall{destinations,target,args}: x181_call(destinations,target,args,ids,frame,code)
    case P113DResult{values}: x181_results(values,ids,frame,code)
    case P113DAgain{values}: x181_again(values,ids,frame,code)

@unsafe
def x181_if(+condition: N111Value, +yes: List<&2,P113DStmt>, +no: List<&2,P113DStmt>,
  +ids: N111Ids, +frame: X181Frame, code: X181Code) -> X181Code:
  match code:
    case X181Code{chunks,+next,terminal,error}:
      x181_if_yes(next,no,ids,frame,x181_stmts(yes,ids,frame,
        X181Code{Con{x188_many([x181_load(condition,ids,frame,x188_reg(10,64)),
          x188_i2("testl",x188_reg(10,32),x188_reg(10,32)),
          x188_i1("jz",X187Target{x181_label(next,frame)})]),chunks},U32.add(next,2),False{},error}))

@unsafe
def x181_if_yes(+label: U32, +no: List<&2,P113DStmt>, +ids: N111Ids,
  +frame: X181Frame, yes: X181Code) -> X181Code:
  match yes:
    case X181Code{chunks,next,+terminal,error}:
      x181_if_end(label,terminal,frame,x181_stmts(no,ids,frame,
        X181Code{Con{x188_cat(nt_choose(X188Seq,terminal,u => X188Empty{},
          u => x188_i1("jmp",X187Target{x181_label(U32.inc(label),frame)})),
          X188One{PLabel{x181_label(label,frame)}}),chunks},next,False{},error}))

@unsafe
def x181_if_end(+label: U32, +yes_end: Bool, +frame: X181Frame, no: X181Code) -> X181Code:
  match no:
    case X181Code{chunks,next,+terminal,error}:
      X181Code{nt_choose(List<&2,X188Seq>,yes_end && terminal,u => chunks,
        u => Con{X188One{PLabel{x181_label(U32.inc(label),frame)}},chunks}),next,yes_end && terminal,error}

@unsafe
def x181_args(values: List<&2,N111Value>) -> List<&2,N111Arg>:
  match values:
    case Nil{}: []
    case Con{head,rest}: Con{N111Arg{N111U64{},head},x181_args(rest)}

@unsafe
def x181_call(+destinations: List<&2,String>, +target: String, +args: List<&2,N111Value>,
  +ids: N111Ids, +frame: X181Frame, +code: X181Code) -> X181Code:
  match destinations:
    case Con{name,Nil{}}:
      x181_add(x188_cat(x181_call_text(p113e_symbol(target),Con{N111Arg{N111Ptr{},N111Local{"state"}},x181_args(args)},ids,frame),
        x181_store(name,frame,x188_reg(0,64))),code)
    case _:
      x181_load_results(destinations,0,ids,frame,x181_add(
        x181_call_text(p113e_symbol(target),Con{N111Arg{N111Ptr{},N111Local{"state"}},
          Con{N111Arg{N111Ptr{},N111Local{"__x181_results"}},x181_args(args)}},ids,frame),code))

@unsafe
def x181_load_results(names: List<&2,String>, +offset: U32, +ids: N111Ids, +frame: X181Frame, code: X181Code) -> X181Code:
  match names:
    case Nil{}: code
    case Con{name,rest}:
      x181_load_results(rest,U32.add(offset,8),ids,frame,x181_add(
        x188_many([x181_load(N111Local{"__x181_results"},ids,frame,x188_reg(11,64)),
          x188_i2("movq",X187Mem{11,offset},x188_reg(0,64)),
          x181_store(name,frame,x188_reg(0,64))]),code))

@unsafe
def x181_results(values: List<&2,N111Value>, +ids: N111Ids, +frame: X181Frame, +code: X181Code) -> X181Code:
  match values:
    case Con{head,Nil{}}: x181_return(x181_load(head,ids,frame,x188_reg(0,64)),frame,code)
    case _: x181_store_results(values,0,ids,frame,code)

@unsafe
def x181_store_results(values: List<&2,N111Value>, +offset: U32, +ids: N111Ids, +frame: X181Frame, code: X181Code) -> X181Code:
  match values:
    case Nil{}: x181_return(x188_i2("xorl",x188_reg(0,32),x188_reg(0,32)),frame,code)
    case Con{head,rest}:
      x181_store_results(rest,U32.add(offset,8),ids,frame,x181_add(
        x188_many([x181_load(head,ids,frame,x188_reg(10,64)),
          x181_load(N111Local{"__x181_result_out"},ids,frame,x188_reg(11,64)),
          x188_i2("movq",x188_reg(10,64),X187Mem{11,offset})]),code))

@unsafe
def x181_tail_args(frame: X181Frame) -> List<&2,String>:
  match frame:
    case X181Frame{slots,bytes,calls,Nil{},symbol}: []
    case X181Frame{slots,bytes,calls,Con{state,rest},symbol}: x181_tail_skip(rest)

@unsafe
def x181_tail_skip(params: List<&2,String>) -> List<&2,String>:
  match params:
    case Nil{}: []
    case Con{+head,+rest}:
      nt_choose(List<&2,String>,String.eq(head,"__x181_result_out"),u => rest,u => params)

@unsafe
def x181_again(+values: List<&2,N111Value>, +ids: N111Ids, +frame: X181Frame, +code: X181Code) -> X181Code:
  x186_again_planned(values,ids,frame,code,x186_parallel(x181_tail_args(frame),values,ids,frame))

@unsafe
def x186_again_planned(values: List<&2,N111Value>, +ids: N111Ids, +frame: X181Frame,
    code: X181Code, plan: Maybe<&2,X188Seq>) -> X181Code:
  match plan:
    case Some{text}: x181_tail_moves([],0,ids,frame,x181_add(text,code))
    case None{}: x181_tail_moves(x181_tail_args(frame),0,ids,frame,x181_tail_snapshot(values,0,ids,frame,code))

@unsafe
def x181_tail_snapshot(values: List<&2,N111Value>, +offset: U32, +ids: N111Ids, +frame: X181Frame, code: X181Code) -> X181Code:
  match values:
    case Nil{}: code
    case Con{head,rest}:
      x181_tail_snapshot(rest,U32.add(offset,8),ids,frame,x181_add(
        x188_many([x181_load(head,ids,frame,x188_reg(10,64)),
          x181_load(N111Local{"__x181_tail"},ids,frame,x188_reg(11,64)),
          x188_i2("movq",x188_reg(10,64),X187Mem{11,offset})]),code))

@unsafe
def x181_tail_moves(params: List<&2,String>, +offset: U32, +ids: N111Ids, +frame: X181Frame, code: X181Code) -> X181Code:
  match params code:
    case Nil{} X181Code{chunks,next,terminal,error}:
      X181Code{Con{x188_i1("jmp",X187Target{x181_loop_label(frame)}),chunks},next,True{},error}
    case Con{name,rest} _:
      x181_tail_moves(rest,U32.add(offset,8),ids,frame,x181_add(
        x188_many([x181_load(N111Local{"__x181_tail"},ids,frame,x188_reg(11,64)),
          x188_i2("movq",X187Mem{11,offset},x188_reg(0,64)),
          x181_store(name,frame,x188_reg(0,64))]),code))

@unsafe
def x181_incoming(params: List<&2,String>, +n: U32, +frame: X181Frame, acc: List<&2,X188Seq>) -> X188Seq:
  match params:
    case Nil{}: x188_finish(acc)
    case Con{name,rest}:
      x181_incoming(rest,U32.inc(n),frame,Con{
        x188_cat(nt_choose(X188Seq,U32.is_lt(n,6),u => x188_i2("movq",x181_argreg(n),x188_reg(0,64)),
          u => x188_i2("movq",X187Mem{5,U32.add(16,U32.mul(U32.sub(n,6),8))},x188_reg(0,64))),
          x181_store(name,frame,x188_reg(0,64))),acc})

@unsafe
def x181_prologue(+frame: X181Frame) -> X188Seq:
  match frame:
    case X181Frame{slots,+bytes,+calls,+params,+symbol}:
      x188_many([X188One{PSection{1}},X188One{PGlobal{symbol}},X188One{PType{symbol,2}},X188One{PLabel{symbol}},
        x188_i1("pushq",x188_reg(5,64)),x188_i2("movq",x188_reg(4,64),x188_reg(5,64)),
        x188_i2("subq",X187Imm{U32.add(U32.mul(U32.div(U32.add(U32.add(bytes,calls),15),16),16),48),0},x188_reg(4,64)),
        x186_saves_text(x186_saves_mask(frame),0,False{}),x181_incoming(params,0,frame,[])])

@unsafe
def x181_function(+symbol: String, +params: List<&2,String>, +body: List<&2,P113DStmt>, +ids: N111Ids) -> X181Output:
  x185_function_setup(symbol,params,[],body,ids)

# Setup executes once. Again only reaches the body label, so invariant array
# metadata is not recomputed from changing parameter homes on a backedge.
@unsafe
def x185_function_setup(+symbol: String, +params: List<&2,String>, +setup: List<&2,P113DStmt>,
    +body: List<&2,P113DStmt>, +ids: N111Ids) -> X181Output:
  nt_choose(X181Output,x185_late_enabled() && p114t_names(params) && p114t_body_names(setup) && p114t_body_names(body),
    u => x185_function_late_setup(symbol,params,body,ids,x185_late_stmts(setup,ids,0)),
    u => x185_function_place(symbol,params,setup,body,ids))

@unsafe
def x185_function_late_setup(symbol: String, params: List<&2,String>, body: List<&2,P113DStmt>,
    +ids: N111Ids, setup: P113ABody) -> X181Output:
  match setup:
    case P113ABody{ready,next}: x185_function_late_body(symbol,params,ready,ids,x185_late_stmts(body,ids,next))

@unsafe
def x185_function_late_body(symbol: String, params: List<&2,String>, setup: List<&2,P113DStmt>,
    ids: N111Ids, body: P113ABody) -> X181Output:
  match body:
    case P113ABody{ready,next}: x185_function_place(symbol,params,setup,ready,ids)

@unsafe
def x185_function_place(+symbol: String, +params: List<&2,String>, +setup: List<&2,P113DStmt>,
    +body: List<&2,P113DStmt>, +ids: N111Ids) -> X181Output:
  x186_function_memory(symbol,params,setup,x185_prepare_body(params,setup,x185_scratch_body(params,setup,body)),ids)

@unsafe
def x186_function_memory(symbol: String, +params: List<&2,String>, +setup: List<&2,P113DStmt>,
    body: List<&2,P113DStmt>, ids: N111Ids) -> X181Output:
  x185_function_copied(symbol,params,setup,x185_dead_body(setup,
    x185_copy_function(params,setup,x186_expression_body(setup,
      x190_local_values_body(setup,x192_predicate_body(x186_private_body(params,setup,body)))))),ids)

def x185_loop_registers_enabled() -> Bool: True{}

@unsafe
def x185_function_copied(+symbol: String, +params: List<&2,String>, +setup: List<&2,P113DStmt>,
    +body: List<&2,P113DStmt>, +ids: N111Ids) -> X181Output:
  x186_float_function(symbol,params,setup,body,ids)

@unsafe
def x185_function_frame(+symbol: String, +setup: List<&2,P113DStmt>, +body: List<&2,P113DStmt>,
    +ids: N111Ids, +frame: X181Frame) -> X181Output:
  x186_function_saved(symbol,setup,body,ids,x186_saves_frame(frame))

@unsafe
def x186_function_saved(+symbol: String, +setup: List<&2,P113DStmt>, +body: List<&2,P113DStmt>,
    +ids: N111Ids, +frame: X181Frame) -> X181Output:
  x181_function_done(symbol,x190_stmts(body,x190_branch_facts(x190_frame_params(frame),setup,body),ids,frame,x181_add(X188One{PLabel{x181_loop_label(frame)}},
    x181_stmts(setup,ids,frame,X181Code{[x181_prologue(frame)],0,False{},""}))))

@unsafe
def x181_function_frame(+symbol: String, +body: List<&2,P113DStmt>, +ids: N111Ids, +frame: X181Frame) -> X181Output:
  x185_function_frame(symbol,[],body,ids,frame)

@unsafe
def x181_function_done(+symbol: String, code: X181Code) -> X181Output:
  match code:
    case X181Code{chunks,next,+terminal,+error}:
      X181Output{[x188_cat(x191_frame_forward(x188_finish(chunks)),X188One{PSize{symbol}})],
        nt_choose(String,String.is_empty(error) && Bool.not(terminal),u => "x86 unterminated function",u => error)}

@unsafe
def x181_param_names(params: List<&2,NC_Binding>) -> List<&2,String>:
  match params:
    case Nil{}: []
    case Con{NC_Binding{id,word,kind},rest}: Con{word,x181_param_names(rest)}

# The native verifier permits these local spellings. Refuse collisions before
# introducing backend-owned result pointers and buffers; never shadow an input
# variable with an implicit frame slot. Global function names are FID encoded.
law x181_hygiene_scalars:
  for body: List<&2,N111Stmt>
  String

law x181_hygiene_stmts:
  for body: List<&2,P113DStmt>
  String

@unsafe
def x181_hygiene_name(+name: String) -> String:
  nt_choose(String,String.starts_with(name,"__x181"),
    u => "x86 reserved local name: " ++ name,u => "")

@unsafe
def x181_hygiene_names(names: List<&2,String>) -> String:
  match names:
    case Nil{}: ""
    case Con{head,rest}: p111_first(x181_hygiene_name(head),x181_hygiene_names(rest))

@unsafe
def x181_hygiene_scalar(stmt: N111Stmt) -> String:
  match stmt:
    case N111Set{name,typ,value}: x181_hygiene_name(name)
    case N111Bin{name,typ,op,left,right}: x181_hygiene_name(name)
    case N111Call{name,typ,symbol,args}: x181_hygiene_name(name)
    case N111If{condition,yes,no}: p111_first(x181_hygiene_scalars(yes),x181_hygiene_scalars(no))
    case N111Load{name,typ,base,offset}: x181_hygiene_name(name)
    case N111Offset{name,base,bytes}: x181_hygiene_name(name)
    case N111Alloca{name,bytes,align}: x181_hygiene_name(name)
    case _: ""

@unsafe
def x181_hygiene_scalars(body):
  match body:
    case Nil{}: ""
    case Con{head,rest}: p111_first(x181_hygiene_scalar(head),x181_hygiene_scalars(rest))

@unsafe
def x181_hygiene_stmt(stmt: P113DStmt) -> String:
  match stmt:
    case P113DScalar{scalar}: x181_hygiene_scalar(scalar)
    case P113DIf{condition,yes,no}: p111_first(x181_hygiene_stmts(yes),x181_hygiene_stmts(no))
    case P113DCall{destinations,target,args}: x181_hygiene_names(destinations)
    case _: ""

@unsafe
def x181_hygiene_stmts(body):
  match body:
    case Nil{}: ""
    case Con{head,rest}: p111_first(x181_hygiene_stmt(head),x181_hygiene_stmts(rest))

@unsafe
def x181_direct(function,ids):
  match function:
    case P113DFunction{name,+params,+result,public,+body}:
      +error = p111_first(x181_hygiene_names(x181_param_names(params)),x181_hygiene_stmts(body))
      nt_choose(X181Output,String.is_empty(error),
        u => x181_function(p113e_symbol(name),Con{"state",nt_choose(List<&2,String>,U32.is_eq(result,1),
          v => x181_param_names(params),v => Con{"__x181_result_out",x181_param_names(params)})},body,ids),
        u => X181Output{[],error})

@unsafe
def x181_segment(segment,ids):
  match segment:
    case N111Segment{name,arity,result,incoming,flags,+body}:
      +error = x181_hygiene_scalars(body)
      nt_choose(X181Output,String.is_empty(error),
        u => x181_function(p111q_symbol(name),["state"],x181_scalar_rows(body),ids),
        u => X181Output{[],error})

# The branch plan sees setup and incoming definitions as well as the loop body.
def x190_frame_params(frame: X181Frame) -> List<&2,String>:
  match frame:
    case X181Frame{slots,bytes,calls,params,symbol}: params
