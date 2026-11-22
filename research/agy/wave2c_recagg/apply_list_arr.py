#!/usr/bin/env python3
"""
AGY-W2C-LISTAPP + AGY-W2C-ARRLIST:
1. AGY-W2C-LISTAPP: General, purely structural in-place owned list/string append
   for any TRMC worker ($p118.trmc.*) matching:
     Nil => p118_rt_finish(st, root, parent, b)
     Con{h, t} => p111_rt_take(a, 2); p118_rt_extend(parent, Con, [h], 1); again(t, b, ...)
   Works on String.append, List.append, and any user-defined list append!
   When p118_root == 0 and prefix of `a` is owned (tag == 0x02), walks in-place
   with zero stack frame, zero allocations, zero frees, and patches the final
   tail cell to `b`. If an RFC-shared (0x82) tail is encountered mid-list,
   hands off cleanly to the slow TRMC worker with (next, b, orig_a, last_owned).

2. AGY-W2C-ARRLIST: Native x86 fast path for Array.to_list.go on raw Array<U32>
   (tag == 0x04), building the Con list in reverse directly from the flat u32
   buffer without binary-tree Array.split / p111_rt_special_take / p114r frames.
"""
from pathlib import Path
import sys

LISTAPP_BEND = r'''
# === AGY-W2C-LISTAPP ===

@unsafe
def agy_la_ctor_id(ids: N111Ids, +name: String) -> U32:
  match ids:
    case N111Ids{functions,constructors}:
      +found = index_find(constructors,name,index_hash(name,2166136261),32)
      nt_choose(U32,String.eq(dk(found),"N111Id"),u => da(found),u => 4294967295)

@unsafe
def agy_la_is_local(v: N111Value, +want: String) -> Bool:
  match v:
    case N111Local{n}: String.eq(n,want)
    case _: False{}

@unsafe
def agy_la_extract_ctor(v: N111Value) -> String:
  match v:
    case N111CtorId{n}: n
    case _: ""

@unsafe
def agy_la_finish_arg4(args: List<&2,N111Arg>, +bname: String) -> Bool:
  match args:
    case Con{_,Con{_,Con{_,Con{N111Arg{_,val},Nil{}}}}}: agy_la_is_local(val,bname)
    case _: False{}

@unsafe
def agy_la_ext_arg3(args: List<&2,N111Arg>, +con_name: String) -> Bool:
  match args:
    case Con{_,Con{_,Con{N111Arg{_,cv},Con{_,Con{N111Arg{_,N111Const{1,0}},Nil{}}}}}}:
      String.eq(agy_la_extract_ctor(cv),con_name)
    case _: False{}

@unsafe
def agy_la_has_finish_b(stmts: List<&2,P113DStmt>, +bname: String) -> Bool:
  match stmts:
    case Nil{}: False{}
    case Con{P113DScalar{N111Call{dst,t,sym,args}},+rest}:
      String.eq(sym,"p118_rt_finish") && agy_la_finish_arg4(args,bname)
    case Con{P113DResult{_},Nil{}}: False{}
    case _: False{}

@unsafe
def agy_la_scan_con(stmts: List<&2,P113DStmt>, +aname: String, +bname: String, +con_name: String,
    +saw_take: Bool, +saw_ext: Bool, +saw_again: Bool) -> Bool:
  match stmts:
    case Nil{}: saw_take && saw_ext && saw_again
    case Con{P113DScalar{N111Call{dst,t,sym,args}},+rest}:
      nt_choose(Bool,String.eq(sym,"p111_rt_take"),u =>
        agy_la_scan_con(rest,aname,bname,con_name,True{},saw_ext,saw_again),u =>
      nt_choose(Bool,String.eq(sym,"p118_rt_extend"),u =>
        agy_la_ext_arg3(args,con_name) &&
          agy_la_scan_con(rest,aname,bname,con_name,saw_take,True{},saw_again),
        u => False{}))
    case Con{P113DScalar{N111Load{_,_,_,_}},rest}:
      agy_la_scan_con(rest,aname,bname,con_name,saw_take,saw_ext,saw_again)
    case Con{P113DScalar{N111Store{_,_,_,_}},rest}:
      agy_la_scan_con(rest,aname,bname,con_name,saw_take,saw_ext,saw_again)
    case Con{P113DScalar{N111Bin{_,_,_,_,_}},rest}:
      agy_la_scan_con(rest,aname,bname,con_name,saw_take,saw_ext,saw_again)
    case Con{P113DScalar{N111If{_,_,_}},rest}:
      agy_la_scan_con(rest,aname,bname,con_name,saw_take,saw_ext,saw_again)
    case Con{P113DScalar{N111Set{_,_,_}},rest}:
      agy_la_scan_con(rest,aname,bname,con_name,saw_take,saw_ext,saw_again)
    case Con{P113DScalar{N111Offset{_,_,_}},rest}:
      agy_la_scan_con(rest,aname,bname,con_name,saw_take,saw_ext,saw_again)
    case Con{P113DScalar{N111Alloca{_,_,_}},rest}:
      agy_la_scan_con(rest,aname,bname,con_name,saw_take,saw_ext,saw_again)
    case Con{P113DAgain{Con{_,Con{v2,Con{_,Con{_,Nil{}}}}}},Nil{}}:
      agy_la_is_local(v2,bname) && agy_la_scan_con(Nil{},aname,bname,con_name,saw_take,saw_ext,True{})
    case _: False{}

@unsafe
def agy_la_find_tag_cmp(stmts: List<&2,P113DStmt>, +cond: String) -> String:
  match stmts:
    case Nil{}: ""
    case Con{P113DScalar{N111Bin{dst,_,op,l,r}},rest}:
      nt_choose(String,String.eq(dst,cond) && String.eq(op,"eq"),u =>
        nt_choose(String,Bool.not(String.is_empty(agy_la_extract_ctor(r))),
          v => agy_la_extract_ctor(r),v => agy_la_extract_ctor(l)),
        u => agy_la_find_tag_cmp(rest,cond))
    case Con{_,rest}: agy_la_find_tag_cmp(rest,cond)

@unsafe
def agy_la_match_con_branch(stmts: List<&2,P113DStmt>, +prefix: List<&2,P113DStmt>,
    +aname: String, +bname: String) -> String:
  match stmts:
    case Nil{}: ""
    case Con{P113DIf{N111Local{cond},yes,no},_}:
      +con_name = agy_la_find_tag_cmp(prefix,cond)
      nt_choose(String,Bool.not(String.is_empty(con_name)) &&
          agy_la_scan_con(yes,aname,bname,con_name,False{},False{},False{}),
        u => con_name,u => "")
    case Con{h,rest}: agy_la_match_con_branch(rest,Con{h,prefix},aname,bname)

@unsafe
def agy_la_match_body(stmts: List<&2,P113DStmt>, +prefix: List<&2,P113DStmt>,
    +aname: String, +bname: String) -> String & String:
  match stmts:
    case Nil{}: ("","")
    case Con{P113DIf{N111Local{cond},yes,no},_}:
      +nil_name = agy_la_find_tag_cmp(prefix,cond)
      +con_name = agy_la_match_con_branch(no,Nil{},aname,bname)
      nt_choose(String & String,Bool.not(String.is_empty(nil_name)) &&
          Bool.not(String.is_empty(con_name)) &&
          Bool.not(String.eq(nil_name,con_name)) &&
          agy_la_has_finish_b(yes,bname),
        u => (nil_name,con_name),u => ("",""))
    case Con{h,rest}: agy_la_match_body(rest,Con{h,prefix},aname,bname)

@unsafe
def agy_la_detect(function: P113DFunction) -> String & String:
  match function:
    case P113DFunction{+name,Con{NC_Binding{_,aname,_},Con{NC_Binding{_,bname,_},Con{NC_Binding{_,rname,_},Con{NC_Binding{_,pname,_},Nil{}}}}},1,False{},body}:
      nt_choose(String & String,String.starts_with(name,"$p118.trmc.") &&
          String.eq(rname,"p118_root") && String.eq(pname,"p118_parent"),
        u => agy_la_match_body(body,Nil{},aname,bname),u => ("",""))
    case _: ("","")

# Zero-stack-frame in-place owned list/string append wrapper for TRMC worker:
# Args: %rdi=state, %rsi=a, %rdx=b, %rcx=p118_root, %r8=p118_parent
# Supports both tag==0x02 (unshared) and tag==0x82 with rc==1 (uniquely owned RFC)!
# Never mutates until SNil/Nil is reached, so any shared node (rc>=2) bails cleanly!
@unsafe
def agy_la_emit_fast(+symbol: String, +slow_sym: String, +nil_cid: U32, +con_cid: U32) -> X181Output:
  +pfx = ".Lla_" ++ symbol
  +l_notnil = pfx ++ "_nn"
  +l_walk   = pfx ++ "_wk"
  +l_lok    = pfx ++ "_lk"
  +l_patch  = pfx ++ "_pt"
  +l_bail   = pfx ++ "_bl"
  X181Output{[x188_many([
    X188One{PSection{1}},X188One{PGlobal{symbol}},X188One{PType{symbol,2}},x188_label(symbol),
    # Fast path only when p118_root == 0 (top-level call)
    x188_i2("testq",x188_reg(1,64),x188_reg(1,64)),
    x188_i1("jne",X187Target{slow_sym}),
    # Check cid(a) == nil_cid -> return b
    x188_i2("movq",x188_reg(6,64),x188_reg(9,64)),
    x188_i2("shrq",X187Imm{40,0},x188_reg(9,64)),
    x188_i2("andq",X187Imm{65535,0},x188_reg(9,64)),
    x188_i2("cmpq",X187Imm{nil_cid,0},x188_reg(9,64)),
    x188_i1("jne",X187Target{l_notnil}),
    x188_i2("movq",x188_reg(2,64),x188_reg(0,64)),
    x188_i0("ret"),
    x188_label(l_notnil),
    x188_i2("cmpq",X187Imm{con_cid,0},x188_reg(9,64)),
    x188_i1("jne",X187Target{slow_sym}),
    # %r10 = heap, %rax = orig_a, %r8 = cur, %r11 = 0xffffffffff
    x188_i2("movq",X187Mem{7,0},x188_reg(10,64)),
    x188_i2("movq",x188_reg(6,64),x188_reg(0,64)),
    x188_i2("movq",x188_reg(6,64),x188_reg(8,64)),
    x188_i2("movabsq",X187Imm{4294967295,255},x188_reg(11,64)),
    x188_label(l_walk),
    # Check cur (%r8) is uniquely owned: tag==0x02 or (tag==0x82 && (heap[rfc]&0xffffff)==1)
    x188_i2("movq",x188_reg(8,64),x188_reg(9,64)),
    x188_i2("andq",x188_reg(11,64),x188_reg(9,64)),
    x188_i2("movq",x188_reg(8,64),x188_reg(1,64)),
    x188_i2("shrq",X187Imm{56,0},x188_reg(1,64)),
    x188_i2("cmpq",X187Imm{2,0},x188_reg(1,64)),
    x188_i1("je",X187Target{l_lok}),
    x188_i2("cmpq",X187Imm{130,0},x188_reg(1,64)),
    x188_i1("jne",X187Target{l_bail}),
    x188_i2("movq",X187Indexed{10,9,8,0},x188_reg(9,64)),
    x188_i2("movq",x188_reg(9,64),x188_reg(1,64)),
    x188_i2("andq",X187Imm{16777215,0},x188_reg(1,64)),
    x188_i2("cmpq",X187Imm{1,0},x188_reg(1,64)),
    x188_i1("jne",X187Target{l_bail}),
    x188_i2("shrq",X187Imm{24,0},x188_reg(9,64)),
    x188_label(l_lok),
    # Reject static terms (loc < HEAP_OFF) before any in-place mutation
    x188_i2("movq",X187Rip{"p111_program",64,0},x188_reg(1,64)),
    x188_i2("addq",X187Imm{127,0},x188_reg(1,64)),
    x188_i2("andq",X187Imm{4294967168,4294967295},x188_reg(1,64)),
    x188_i2("addq",X187Imm{51413504,0},x188_reg(1,64)),
    x188_i2("cmpq",x188_reg(1,64),x188_reg(9,64)),
    x188_i1("jb",X187Target{l_bail}),
    # %rcx = next = heap[loc + 1]
    x188_i2("movq",X187Indexed{10,9,8,8},x188_reg(1,64)),
    x188_i2("movq",x188_reg(1,64),x188_reg(6,64)),
    x188_i2("shrq",X187Imm{40,0},x188_reg(6,64)),
    x188_i2("andq",X187Imm{65535,0},x188_reg(6,64)),
    x188_i2("cmpq",X187Imm{nil_cid,0},x188_reg(6,64)),
    x188_i1("je",X187Target{l_patch}),
    x188_i2("cmpq",X187Imm{con_cid,0},x188_reg(6,64)),
    x188_i1("jne",X187Target{l_bail}),
    x188_i2("movq",x188_reg(1,64),x188_reg(8,64)),
    x188_i1("jmp",X187Target{l_walk}),
    x188_label(l_patch),
    x188_i2("movq",x188_reg(2,64),X187Indexed{10,9,8,8}),
    x188_i0("ret"),
    x188_label(l_bail),
    # Restore original (a=%rax, root=0, parent=0) and jump to slow TRMC worker
    x188_i2("movq",x188_reg(0,64),x188_reg(6,64)),
    x188_i2("xorl",x188_reg(1,32),x188_reg(1,32)),
    x188_i2("xorl",x188_reg(8,32),x188_reg(8,32)),
    x188_i1("jmp",X187Target{slow_sym}),
    X188One{PSize{symbol}}
  ])],""}

@unsafe
def agy_la_try(+function: P113DFunction, +ids: N111Ids, pair: String & String) -> Maybe<&2,X181Output>:
  match function pair:
    case P113DFunction{+name,+params,+result,public,+body} Tuple{+nil_n,+con_n}:
      +ncid = agy_la_ctor_id(ids,nil_n)
      +ccid = agy_la_ctor_id(ids,con_n)
      nt_choose(Maybe<&2,X181Output>,Bool.not(String.is_empty(nil_n)) &&
          Bool.not(String.is_empty(con_n)) && U32.is_lt(ncid,65536) && U32.is_lt(ccid,65536),
        u =>
          +sym = p113e_symbol(name)
          +slow = sym ++ "__slow"
          +pnames : List<&2,String> = Con{"state",x181_param_names(params)}
          Some{x181_program_join(agy_la_emit_fast(sym,slow,ncid,ccid),x181_function(slow,pnames,body,ids))},
        u => None{})
'''

ARRLIST_BEND = r'''
# === AGY-W2C-ARRLIST ===

@unsafe
def agy_al_ctor_id(ids: N111Ids, +name: String) -> U32:
  match ids:
    case N111Ids{functions,constructors}:
      +found = index_find(constructors,name,index_hash(name,2166136261),32)
      nt_choose(U32,String.eq(dk(found),"N111Id"),u => da(found),u => 4294967295)

@unsafe
def agy_al_is_match(+name: String, +params: List<&2,String>, +ids: N111Ids) -> Bool:
  (String.eq(name,"$direct.Array.to_list.go~0") || String.eq(name,"Array.to_list.go~0")) &&
  U32.is_eq(nt_count(String,params),6) &&
  U32.is_lt(agy_al_ctor_id(ids,"Con"),65536)

# Fast path for p114r_$direct.Array.to_list.go~0(st=%rdi, a=%rsi, acc=%rdx, mode=%rcx, depth=%r8, val=%r9)
@unsafe
def agy_al_emit_fast(+symbol: String, +slow_sym: String, +con_cid: U32) -> X181Output:
  +pfx = ".Lal_" ++ symbol
  +l_loop = pfx ++ "_lp"
  +l_done = pfx ++ "_dn"
  +l_bail = pfx ++ "_bl"
  X181Output{[x188_many([
    X188One{PSection{1}},X188One{PGlobal{symbol}},X188One{PType{symbol,2}},x188_label(symbol),
    # Fast path only on mode == 0 && tag(a) == 4 (raw Array<U32>) && cls <= 24 && loc >= 1
    x188_i2("testq",x188_reg(1,64),x188_reg(1,64)),
    x188_i1("jne",X187Target{slow_sym}),
    x188_i2("movq",x188_reg(6,64),x188_reg(10,64)),
    x188_i2("shrq",X187Imm{56,0},x188_reg(10,64)),
    x188_i2("cmpq",X187Imm{4,0},x188_reg(10,64)),
    x188_i1("jne",X187Target{slow_sym}),
    x188_i2("movq",x188_reg(6,64),x188_reg(10,64)),
    x188_i2("shrq",X187Imm{40,0},x188_reg(10,64)),
    x188_i2("andq",X187Imm{31,0},x188_reg(10,64)),
    x188_i2("cmpq",X187Imm{24,0},x188_reg(10,64)),
    x188_i1("ja",X187Target{slow_sym}),
    x188_i2("movabsq",X187Imm{4294967295,255},x188_reg(11,64)),
    x188_i2("andq",x188_reg(6,64),x188_reg(11,64)),
    x188_i2("cmpq",X187Imm{1,0},x188_reg(11,64)),
    x188_i1("jb",X187Target{slow_sym}),
    # Prologue (16-byte aligned: push rbp + 5 regs + sub 40 = 80 bytes)
    x188_i1("pushq",x188_reg(5,64)),
    x188_i2("movq",x188_reg(4,64),x188_reg(5,64)),
    x188_i1("pushq",x188_reg(3,64)),
    x188_i1("pushq",x188_reg(12,64)),
    x188_i1("pushq",x188_reg(13,64)),
    x188_i1("pushq",x188_reg(14,64)),
    x188_i1("pushq",x188_reg(15,64)),
    x188_i2("subq",X187Imm{40,0},x188_reg(4,64)),
    # %r12 = st, %rbx = a, %r15 = acc, %r13 = base = heap + (loc << 3), %r14 = size = 1 << cls
    x188_i2("movq",x188_reg(7,64),x188_reg(12,64)),
    x188_i2("movq",x188_reg(6,64),x188_reg(3,64)),
    x188_i2("movq",x188_reg(2,64),x188_reg(15,64)),
    x188_i2("movq",X187Mem{12,0},x188_reg(13,64)),
    x188_i2("shlq",X187Imm{3,0},x188_reg(11,64)),
    x188_i2("addq",x188_reg(11,64),x188_reg(13,64)),
    x188_i2("movq",x188_reg(10,64),x188_reg(1,64)),
    x188_i2("movabsq",X187Imm{1,0},x188_reg(14,64)),
    x188_i2("shlq",x188_reg(1,8),x188_reg(14,64)),
    # Loop i = size down to 1 (accessing base[i - 1])
    x188_label(l_loop),
    x188_i2("subq",X187Imm{1,0},x188_reg(14,64)),
    x188_i2("movl",X187Indexed{13,14,4,0},x188_reg(0,32)),
    x188_i2("movq",x188_reg(0,64),X187Mem{4,0}),
    x188_i2("movq",x188_reg(15,64),X187Mem{4,8}),
    x188_i2("movq",x188_reg(12,64),x188_reg(7,64)),
    x188_i2("movabsq",X187Imm{con_cid,0},x188_reg(6,64)),
    x188_i2("movq",x188_reg(4,64),x188_reg(2,64)),
    x188_i2("xorl",x188_reg(0,32),x188_reg(0,32)),
    x188_i1("call",X187Target{"p125_rt_ctor2"}),
    x188_i2("movq",x188_reg(0,64),x188_reg(15,64)),
    x188_i2("testq",x188_reg(14,64),x188_reg(14,64)),
    x188_i1("jne",X187Target{l_loop}),
    x188_label(l_done),
    # Sink a (%rbx) and return acc (%r15)
    x188_i2("movq",x188_reg(12,64),x188_reg(7,64)),
    x188_i2("movq",x188_reg(3,64),x188_reg(6,64)),
    x188_i2("xorl",x188_reg(0,32),x188_reg(0,32)),
    x188_i1("call",X187Target{"p111_rt_sink"}),
    x188_i2("movq",x188_reg(15,64),x188_reg(0,64)),
    x188_i2("addq",X187Imm{40,0},x188_reg(4,64)),
    x188_i1("popq",x188_reg(15,64)),
    x188_i1("popq",x188_reg(14,64)),
    x188_i1("popq",x188_reg(13,64)),
    x188_i1("popq",x188_reg(12,64)),
    x188_i1("popq",x188_reg(3,64)),
    x188_i1("popq",x188_reg(5,64)),
    x188_i0("ret"),
    X188One{PSize{symbol}}
  ])],""}
'''

OLD_DIRECT = '''@unsafe
def x181_direct(function,ids):
  match function:
    case P113DFunction{+name,+params,+result,public,+body}:
      +names : List<&2,String> = Con{"state",nt_choose(List<&2,String>,U32.is_eq(result,1),u => x181_param_names(params),u => Con{"__x181_result_out",x181_param_names(params)})}
      +error = p111_first(x181_hygiene_names(x181_param_names(params)),x181_hygiene_stmts(body))
      nt_choose(X181Output,String.is_empty(error),u =>
        nt_choose(X181Output,x198n_enabled() && U32.is_eq(result,1) && U32.is_le(nt_count(NC_Binding,params),8) && x185_late_enabled() && p114t_names(names) && p114t_body_names(body),v =>
          x198n_late(p113e_symbol(name),names,params,ids,x185_late_stmts(body,ids,0)),v =>
          x181_function(p113e_symbol(name),names,body,ids)),u => X181Output{[],error})'''

NEW_DIRECT = LISTAPP_BEND + '''
@unsafe
def x181_direct_after_la(la: Maybe<&2,X181Output>, +function: P113DFunction, +ids: N111Ids) -> X181Output:
  match la:
    case Some{out}: out
    case None{}:
      match function:
        case P113DFunction{+name,+params,+result,public,+body}:
          +names : List<&2,String> = Con{"state",nt_choose(List<&2,String>,U32.is_eq(result,1),u => x181_param_names(params),u => Con{"__x181_result_out",x181_param_names(params)})}
          +error = p111_first(x181_hygiene_names(x181_param_names(params)),x181_hygiene_stmts(body))
          nt_choose(X181Output,String.is_empty(error),u =>
            nt_choose(X181Output,x198n_enabled() && U32.is_eq(result,1) && U32.is_le(nt_count(NC_Binding,params),8) && x185_late_enabled() && p114t_names(names) && p114t_body_names(body),v =>
              x198n_late(p113e_symbol(name),names,params,ids,x185_late_stmts(body,ids,0)),v =>
              x181_function(p113e_symbol(name),names,body,ids)),u => X181Output{[],error})

@unsafe
def x181_direct(function,ids):
  x181_direct_after_la(agy_la_try(function,ids,agy_la_detect(function)),function,ids)'''

OLD_WORKER = '''@unsafe
def x198pw_worker(+name: String,+params: List<&2,String>,+setup: List<&2,P113DStmt>,+body: List<&2,P113DStmt>,
    +ids: N111Ids,+entry: KDef) -> X181Output:
  +symbol = p114r_symbol(name)
  nt_choose(X181Output,String.eq(dk(entry),"X198PWCertified") && x198pw_h_args(params),
    u => x198pw_worker_cids(symbol,params,setup,body,ids,nm(dt(entry)),nm(dv(entry))),
    u => x185_function_setup(symbol,params,setup,body,ids))'''

NEW_WORKER = ARRLIST_BEND + '''
@unsafe
def x198pw_worker(+name: String,+params: List<&2,String>,+setup: List<&2,P113DStmt>,+body: List<&2,P113DStmt>,
    +ids: N111Ids,+entry: KDef) -> X181Output:
  +symbol = p114r_symbol(name)
  nt_choose(X181Output,String.eq(dk(entry),"X198PWCertified") && x198pw_h_args(params),
    u => x198pw_worker_cids(symbol,params,setup,body,ids,nm(dt(entry)),nm(dv(entry))),
    u => nt_choose(X181Output,agy_al_is_match(name,params,ids),
      v =>
        +slow = "agy_al_orig_" ++ symbol
        x181_program_join(agy_al_emit_fast(symbol,slow,agy_al_ctor_id(ids,"Con")),
          x185_function_setup(slow,params,setup,body,ids)),
      v => x185_function_setup(symbol,params,setup,body,ids)))'''

OLD_WORKER_ROREC = '''@unsafe
def x198pw_worker(+name: String,+params: List<&2,String>,+setup: List<&2,P113DStmt>,+body: List<&2,P113DStmt>,
    +ids: N111Ids,+entry: KDef) -> X181Output:
  +symbol = p114r_symbol(name)
  nt_choose(X181Output,String.eq(dk(entry),"X198PWCertified") && x198pw_h_args(params),
    u => x198pw_worker_cids(symbol,params,setup,body,ids,nm(dt(entry)),nm(dv(entry))),
    u => agy_ro_worker(name,params,setup,body,ids))'''

NEW_WORKER_ROREC = ARRLIST_BEND + '''
@unsafe
def x198pw_worker(+name: String,+params: List<&2,String>,+setup: List<&2,P113DStmt>,+body: List<&2,P113DStmt>,
    +ids: N111Ids,+entry: KDef) -> X181Output:
  +symbol = p114r_symbol(name)
  nt_choose(X181Output,String.eq(dk(entry),"X198PWCertified") && x198pw_h_args(params),
    u => x198pw_worker_cids(symbol,params,setup,body,ids,nm(dt(entry)),nm(dv(entry))),
    u => nt_choose(X181Output,agy_al_is_match(name,params,ids),
      v =>
        +slow = "agy_al_orig_" ++ symbol
        x181_program_join(agy_al_emit_fast(symbol,slow,agy_al_ctor_id(ids,"Con")),
          x185_function_setup(slow,params,setup,body,ids)),
      v => agy_ro_worker(name,params,setup,body,ids)))'''

def patch(src: str) -> str:
    if "# === AGY-W2C-LISTAPP ===" not in src:
        if OLD_DIRECT in src:
            src = src.replace(OLD_DIRECT, NEW_DIRECT, 1)
        else:
            # Chain cleanly on top of any prior x181_direct wrapper (e.g., BST zipper / F32LOOP)
            marker = "@unsafe\ndef x181_direct("
            assert src.count(marker) == 1, f"x181_direct not unique ({src.count(marker)})"
            wrapper = (
                LISTAPP_BEND
                + "\n@unsafe\ndef x181_direct_after_la(la: Maybe<&2,X181Output>, +function: P113DFunction, +ids: N111Ids) -> X181Output:\n"
                + "  match la:\n"
                + "    case Some{out}: out\n"
                + "    case None{}: x181_direct_orig_la(function,ids)\n\n"
                + "@unsafe\ndef x181_direct_orig_la("
            )
            # Find end of x181_direct block? Easier: rename existing def x181_direct -> x181_direct_orig_la
            # and define x181_direct after it!
            import re
            m = re.search(r"@unsafe\ndef x181_direct\(.*?(?=\n@unsafe\ndef |\nlaw |\ntype |\Z)", src, re.S)
            assert m is not None, "could not find x181_direct body"
            orig_block = m.group(0)
            renamed = orig_block.replace(
                "def x181_direct(function,ids):",
                "def x181_direct_orig_la(+function: P113DFunction, +ids: N111Ids) -> X181Output:",
                1,
            )
            if renamed == orig_block:
                renamed = orig_block.replace("def x181_direct(", "def x181_direct_orig_la(", 1)
            new_block = (
                LISTAPP_BEND
                + "\n"
                + renamed
                + "\n\n@unsafe\ndef x181_direct_after_la(la: Maybe<&2,X181Output>, +function: P113DFunction, +ids: N111Ids) -> X181Output:\n"
                + "  match la:\n"
                + "    case Some{out}: out\n"
                + "    case None{}: x181_direct_orig_la(function,ids)\n\n"
                + "@unsafe\ndef x181_direct(function,ids):\n"
                + "  x181_direct_after_la(agy_la_try(function,ids,agy_la_detect(function)),function,ids)"
            )
            src = src[:m.start()] + new_block + src[m.end():]
    if "# === AGY-W2C-ARRLIST ===" not in src:
        old_fl = OLD_WORKER.replace(
            "u => x185_function_setup(symbol,params,setup,body,ids))",
            "u => agy_fl_try_worker(name,params,setup,body,ids))",
        )
        new_fl = NEW_WORKER_ROREC.replace(
            "v => agy_ro_worker(name,params,setup,body,ids)))",
            "v => agy_fl_try_worker(name,params,setup,body,ids)))",
        )
        if old_fl in src:
            src = src.replace(old_fl, new_fl, 1)
        elif OLD_WORKER_ROREC in src:
            src = src.replace(OLD_WORKER_ROREC, NEW_WORKER_ROREC, 1)
        elif OLD_WORKER in src:
            src = src.replace(OLD_WORKER, NEW_WORKER, 1)
        else:
            raise AssertionError("OLD_WORKER anchor not found")
    return src

if __name__ == "__main__":
    inp, outp = Path(sys.argv[1]), Path(sys.argv[2])
    outp.write_text(patch(inp.read_text()))
    print(f"Patched {inp} -> {outp} (AGY-W2C-LISTAPP + AGY-W2C-ARRLIST)")
