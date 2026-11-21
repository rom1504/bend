# Bound every pass to ordinary loop workers and at most 640 selected items.
@unsafe
def x199s_flat(todo: List<&2,X188Seq>, +fuel: U32, acc: List<&2,X187Parsed>) -> Maybe<&2,List<&2,X187Parsed>>:
  match todo:
    case Nil{}: Some{nt_reverse(X187Parsed,acc,[])}
    case Con{X188Empty{},rest}: x199s_flat(rest,fuel,acc)
    case Con{X188Join{a,b},rest}: x199s_flat(Con{a,Con{b,rest}},fuel,acc)
    case Con{X188One{item},rest}:
      nt_choose(Maybe<&2,List<&2,X187Parsed>>,U32.is_eq(fuel,0),u => None{},
        u => x199s_flat(rest,U32.sub(fuel,1),Con{item,acc}))

@unsafe
def x199s_bucket(bucket: List<&2,KDef>, +offset: U32) -> Bool:
  match bucket:
    case Nil{}: False{}
    case Con{+h,rest}: (String.eq(dk(h),"X181Stack") && U32.is_eq(da(h),offset) && U32.is_eq(dx(h),8)) || x199s_bucket(rest,offset)

@unsafe
def x199s_owned(slots: KDef, +offset: U32) -> Bool:
  match slots:
    case KIndexLeaf{hash,bucket}: x199s_bucket(bucket,offset)
    case KIndexNode{hash,mask,left,right}: x199s_owned(left,offset) || x199s_owned(right,offset)
    case _: False{}

def x199s_touches(arg: X187Operand, +reg: U32) -> Bool:
  match arg:
    case X187Reg{index,width,False{}}: U32.is_eq(index,reg)
    case X187Mem{base,disp}: U32.is_eq(base,reg)
    case X187Indexed{base,index,scale,disp}: U32.is_eq(base,reg) || U32.is_eq(index,reg)
    case _: False{}

@unsafe
def x199s_plain(+op: String) -> Bool:
  x197d_flag_pass(op) || x197d_flag_kill(op) || String.eq(op,"cmovaeq") || String.eq(op,"cmovbq") ||
    String.eq(op,"cmoveq") || String.eq(op,"cmovneq") || String.eq(op,"cmovaq") || String.eq(op,"imull") || String.eq(op,"imulq")

# Every admitted intervening operation has exactly two explicit operands.
# A label, other opcode, indirect clobber, call or control transfer ends the window.
@unsafe
def x199s_tail(items: List<&2,X187Parsed>, +label: String, +fuel: U32) -> Bool:
  match items:
    case Con{PInst{X187Instruction{op,[X187Target{dest}]}},rest}: String.eq(op,"jmp") && String.eq(dest,label)
    case Con{PInst{X187Instruction{op,[a,b]}},rest}: nt_choose(Bool,U32.is_gt(fuel,0) && x199s_plain(op),u => x199s_tail(rest,label,U32.sub(fuel,1)),u => False{})
    case _: False{}

@unsafe
def x199s_window(items: List<&2,X187Parsed>, +reg: U32, +disp: U32, +label: String, +fuel: U32) -> Bool:
  match items:
    case Con{PInst{X187Instruction{+op,[X187Mem{5,+offset},X187Reg{+dst,+width,False{}}]}},+rest}:
      nt_choose(Bool,U32.is_eq(disp,offset),u =>
        nt_choose(Bool,String.eq(op,"movq") && U32.is_eq(width,64) && x191_ff_register(dst),v => x199s_tail(rest,label,64),v => False{}),
        u => nt_choose(Bool,U32.is_gt(fuel,0) && x199s_plain(op) && Bool.not(U32.is_eq(reg,dst)),v => x199s_window(rest,reg,disp,label,U32.sub(fuel,1)),v => False{}))
    case Con{PInst{X187Instruction{op,[a,b]}},rest}:
      nt_choose(Bool,U32.is_gt(fuel,0) && x199s_plain(op) && Bool.not(x199s_touches(a,reg) || x199s_touches(b,reg)),u =>
        x199s_window(rest,reg,disp,label,U32.sub(fuel,1)),u => False{})
    case _: False{}

@unsafe
def x199s_count_arg(arg: X187Operand, +disp: U32, +wide: Bool) -> U32:
  match arg:
    case X187Mem{5,+offset}: Bool.to_u32(U32.is_lt(U32.sub(offset,disp),8) ||
      U32.is_lt(U32.sub(disp,offset),nt_choose(U32,wide,u => 32,u => 8)))
    case X187Reg{5,width,False{}}: 3
    case X187Indexed{5,index,scale,offset}: 3
    case X187Indexed{base,5,scale,offset}: 3
    case _: 0

@unsafe
def x199s_count_args(args: List<&2,X187Operand>, +disp: U32, +wide: Bool) -> U32:
  match args:
    case Nil{}: 0
    case Con{a,rest}: U32.add(x199s_count_arg(a,disp,wide),x199s_count_args(rest,disp,wide))

@unsafe
def x199s_count(items: List<&2,X187Parsed>, +disp: U32, +seen: U32) -> U32:
  match items:
    case Nil{}: seen
    case Con{PInst{X187Instruction{op,[X187Reg{5,64,False{}}]}},rest}:
      nt_choose(U32,String.eq(op,"pushq") || String.eq(op,"popq"),u => x199s_count(rest,disp,seen),u => 3)
    case Con{PInst{X187Instruction{op,[X187Reg{5,64,False{}},X187Reg{4,64,False{}}]}},rest}:
      nt_choose(U32,String.eq(op,"movq"),u => x199s_count(rest,disp,seen),u => 3)
    case Con{PInst{X187Instruction{op,[X187Reg{4,64,False{}},X187Reg{5,64,False{}}]}},rest}:
      nt_choose(U32,String.eq(op,"movq"),u => x199s_count(rest,disp,seen),u => 3)
    case Con{PInst{X187Instruction{op,args}},rest}:
      nt_choose(U32,U32.is_gt(seen,2),u => 3,u => x199s_count(rest,disp,U32.add(seen,x199s_count_args(args,disp,Bool.not(x199s_plain(op))))))
    case Con{other,rest}: x199s_count(rest,disp,seen)

@unsafe
def x199s_add(store: X191FrameStore, +rest: List<&2,X187Parsed>, +all: List<&2,X187Parsed>, +slots: KDef,
    +label: String, +found: List<&2,X191FrameStore>) -> List<&2,X191FrameStore>:
  match store:
    case X191FrameStore{+r,+disp}:
      nt_choose(List<&2,X191FrameStore>,(U32.is_eq(r,0) || U32.is_eq(r,11)) && U32.is_gt(U32.sub(0,disp),48),u =>
        nt_choose(List<&2,X191FrameStore>,x199s_window(rest,r,disp,label,24),v =>
          nt_choose(List<&2,X191FrameStore>,U32.is_eq(x199s_count(all,disp,0),2) && x199s_owned(slots,U32.sub(0,disp)),
            w => Con{X191FrameStore{r,disp},found},w => found),v => found),u => found)
    case _: found

@unsafe
def x199s_scan(items: List<&2,X187Parsed>, +all: List<&2,X187Parsed>, +slots: KDef, +label: String,
    +found: List<&2,X191FrameStore>) -> List<&2,X191FrameStore>:
  match items:
    case Nil{}: found
    case Con{item,+rest}: nt_choose(List<&2,X191FrameStore>,U32.is_ge(nt_count(X191FrameStore,found),8),
      u => found,u => x199s_scan(rest,all,slots,label,x199s_add(x191_ff_store(item),rest,all,slots,label,found)))

@unsafe
def x199s_lookup(found: List<&2,X191FrameStore>, +offset: U32) -> U32:
  match found:
    case Nil{}: 16
    case Con{X191FrameStore{r,d},rest}: nt_choose(U32,U32.is_eq(d,offset),u => r,u => x199s_lookup(rest,offset))
    case Con{X191FrameStoreNone{},rest}: x199s_lookup(rest,offset)

@unsafe
def x199s_load(+item: X187Parsed,+dst: U32,+reg: U32) -> X188Seq:
  nt_choose(X188Seq,U32.is_lt(reg,16),u => nt_choose(X188Seq,U32.is_eq(reg,dst),v => X188Empty{},
    v => x188_i2("movq",x188_reg(reg,64),x188_reg(dst,64))),u => X188One{item})

@unsafe
def x199s_item(+item: X187Parsed, found: List<&2,X191FrameStore>) -> X188Seq:
  match item:
    case PInst{X187Instruction{op,[X187Reg{r,64,False{}},X187Mem{5,d}]}}:
      nt_choose(X188Seq,U32.is_lt(x199s_lookup(found,d),16),u => X188Empty{},u => X188One{item})
    case PInst{X187Instruction{op,[X187Mem{5,d},X187Reg{dst,64,False{}}]}}:
      x199s_load(item,dst,x199s_lookup(found,d))
    case _: X188One{item}

@unsafe
def x199s_emit(items: List<&2,X187Parsed>, +found: List<&2,X191FrameStore>, out: List<&2,X188Seq>) -> X188Seq:
  match items:
    case Nil{}: x188_finish(out)
    case Con{item,rest}: x199s_emit(rest,found,Con{x199s_item(item,found),out})

@unsafe
def x199s_finish(found: List<&2,X191FrameStore>, items: List<&2,X187Parsed>, original: X188Seq) -> X188Seq:
  match found:
    case Nil{}: original
    case Con{head,tail}: x199s_emit(items,Con{head,tail},[])

@unsafe
def x199s_check(flat: Maybe<&2,List<&2,X187Parsed>>, original: X188Seq, slots: KDef, label: String) -> X188Seq:
  match flat:
    case Some{+items}: x199s_finish(x199s_scan(items,items,slots,label,[]),items,original)
    case _: original

@unsafe
def x199s_apply(+code: X188Seq,slots: KDef,label: String) -> X188Seq:
  x199s_check(x199s_flat([code],640,[]),code,slots,label)

@unsafe
def x199s_frame(code: X188Seq,+frame: X181Frame) -> X188Seq:
  match frame:
    case X181Frame{slots,bytes,calls,ps,sym}: x199s_apply(code,slots,x181_loop_label(frame))

@unsafe
def x199s_done(+symbol: String,result: X181Code,+eligible: Bool,frame: X181Frame) -> X181Output:
  match result:
    case X181Code{chunks,next,+terminal,+error}:
      +code = x191_frame_forward(x188_finish(chunks))
      X181Output{[x188_cat(nt_choose(X188Seq,eligible,u => x199s_frame(code,frame),u => code),X188One{PSize{symbol}})],
        nt_choose(String,String.is_empty(error) && Bool.not(terminal),u => "x86 unterminated function",u => error)}

@unsafe
def x191_function_saved(+symbol: String, +setup: List<&2,P113DStmt>, +body: List<&2,P113DStmt>,
    facts: X190BranchFacts, +ids: N111Ids, +frame: X181Frame) -> X181Output:
  x199s_done(symbol,x190_stmts(body,facts,ids,frame,x181_add(x188_label(x181_loop_label(frame)),
    x181_stmts(setup,ids,frame,X181Code{[x181_prologue(frame)],0,False{},""}))),
    U32.is_le(p113i_add(p113i_size(setup),p113i_size(body)),256) && x190_register_loop(body),frame)
