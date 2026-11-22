#!/usr/bin/env python3
"""AGY-W2B-1: Perceus Static In-Place Reuse (takeN -> ctorM same-class fusion)
+ Compact Inlined take{1..4} + Optional Trivial p111_rt_sink Skip.

Patches unified compiler.bend cleanly with standalone flags for ablation:
  --reuse     Enable Perceus static in-place reuse (takeN -> ctorM same class)
  --take      Enable bounded inline p125_rt_take{1..4} (<= 256 stmts)
  --sink-skip Enable inline trivial-term skip on p111_rt_sink
"""
import argparse
from pathlib import Path

DEFAULT_SRC = Path("/home/ai/bend2_agy/selfhost/build/agy/unified/compiler.bend")
DEFAULT_DST = Path("/home/ai/bend2_agy/selfhost/build/agy/wave2_bst/compiler.bend")

REUSE_CODE = r"""
# ============================================================================
# AGY-W2B-1: Perceus Static In-Place Reuse (takeN -> ctorM same-class fusion)
# ============================================================================

type AgyReuseMatch is Data:
  AgyReuseMatch{+ok: Bool, +ctor: String, +stmts: List<&2,P113DStmt>}

def agy_reuse_enabled() -> Bool: True{}
def agy_sink_skip_enabled() -> Bool: False{}

def agy_reuse_val_uses(+target: String, val: N111Value) -> Bool:
  match val:
    case N111Local{name}: String.eq(name,target)
    case _: False{}

@unsafe
def agy_reuse_vals_use(+target: String, vals: List<&2,N111Value>) -> Bool:
  match vals:
    case Nil{}: False{}
    case Con{v,rest}: agy_reuse_val_uses(target,v) || agy_reuse_vals_use(target,rest)

@unsafe
def agy_reuse_args_use(+target: String, args: List<&2,N111Arg>) -> Bool:
  match args:
    case Nil{}: False{}
    case Con{N111Arg{t,v},rest}: agy_reuse_val_uses(target,v) || agy_reuse_args_use(target,rest)

law agy_reuse_nstmts_use:
  for +target: String
  for stmts: List<&2,N111Stmt>
  Bool

@unsafe
def agy_reuse_nstmt_uses(+target: String, stmt: N111Stmt) -> Bool:
  match stmt:
    case N111Set{n,t,v}: agy_reuse_val_uses(target,v)
    case N111Bin{n,t,op,l,r}: agy_reuse_val_uses(target,l) || agy_reuse_val_uses(target,r)
    case N111Call{n,t,sym,args}: agy_reuse_args_use(target,args)
    case N111If{c,yes,no}: agy_reuse_val_uses(target,c) || agy_reuse_nstmts_use(target,yes) || agy_reuse_nstmts_use(target,no)
    case N111Return{v}: agy_reuse_val_uses(target,v)
    case N111Load{n,t,b,off}: agy_reuse_val_uses(target,b)
    case N111Store{t,b,off,v}: agy_reuse_val_uses(target,b) || agy_reuse_val_uses(target,v)
    case N111Offset{n,b,bytes}: agy_reuse_val_uses(target,b) || agy_reuse_val_uses(target,bytes)
    case N111Alloca{n,b,a}: False{}

@unsafe
def agy_reuse_nstmts_use(target,stmts):
  match stmts:
    case Nil{}: False{}
    case Con{s,rest}: agy_reuse_nstmt_uses(target,s) || agy_reuse_nstmts_use(target,rest)

law agy_reuse_stmts_use:
  for +target: String
  for stmts: List<&2,P113DStmt>
  Bool

@unsafe
def agy_reuse_stmt_uses(+target: String, stmt: P113DStmt) -> Bool:
  match stmt:
    case P113DScalar{s}: agy_reuse_nstmt_uses(target,s)
    case P113DIf{c,yes,no}: agy_reuse_val_uses(target,c) || agy_reuse_stmts_use(target,yes) || agy_reuse_stmts_use(target,no)
    case P113DCall{ds,t,args}: agy_reuse_vals_use(target,args)
    case P113DResult{vs}: agy_reuse_vals_use(target,vs)
    case P113DAgain{vs}: agy_reuse_vals_use(target,vs)

@unsafe
def agy_reuse_stmts_use(target,stmts):
  match stmts:
    case Nil{}: False{}
    case Con{s,rest}: agy_reuse_stmt_uses(target,s) || agy_reuse_stmts_use(target,rest)

law agy_reuse_pure_stmts:
  for stmts: List<&2,P113DStmt>
  Bool

@unsafe
def agy_reuse_pure_nstmt(stmt: N111Stmt) -> Bool:
  match stmt:
    case N111Call{n,t,sym,args}: False{}
    case N111If{c,yes,no}: False{}
    case N111Return{v}: False{}
    case _: True{}

@unsafe
def agy_reuse_pure_stmt(stmt: P113DStmt) -> Bool:
  match stmt:
    case P113DScalar{s}: agy_reuse_pure_nstmt(s)
    case P113DIf{c,yes,no}: agy_reuse_pure_stmts(yes) && agy_reuse_pure_stmts(no)
    case _: False{}

@unsafe
def agy_reuse_pure_stmts(stmts):
  match stmts:
    case Nil{}: True{}
    case Con{s,rest}: agy_reuse_pure_stmt(s) && agy_reuse_pure_stmts(rest)

def agy_reuse_ctor_compat(+c1: String, +c2: String) -> Bool:
  String.is_empty(c1) || String.is_empty(c2) || String.eq(c1,c2)

def agy_reuse_ctor_pick(+c1: String, +c2: String) -> String:
  nt_choose(String,String.is_empty(c1),u => c2,u => c1)

law agy_reuse_find:
  for +cls: U32
  for +rname: String
  for +ids: N111Ids
  for stmts: List<&2,P113DStmt>
  AgyReuseMatch

@unsafe
def agy_reuse_prepend(+head: P113DStmt, m: AgyReuseMatch) -> AgyReuseMatch:
  match m:
    case AgyReuseMatch{ok,ctor,rest}: AgyReuseMatch{ok,ctor,Con{head,rest}}

@unsafe
def agy_reuse_find_if(+cls: U32, +rname: String, +ids: N111Ids, +cond: N111Value,
    +yes: List<&2,P113DStmt>, +no: List<&2,P113DStmt>, +rest: List<&2,P113DStmt>,
    m1: AgyReuseMatch, m2: AgyReuseMatch) -> AgyReuseMatch:
  match m1 m2:
    case AgyReuseMatch{ok1,+c1,yes2} AgyReuseMatch{ok2,+c2,no2}:
      +chosen = agy_reuse_ctor_pick(c1,c2)
      nt_choose(AgyReuseMatch,ok1 && ok2 && agy_reuse_ctor_compat(c1,c2),
        u => AgyReuseMatch{True{},chosen,Con{P113DIf{cond,yes2,no2},rest}},
        u => nt_choose(AgyReuseMatch,agy_reuse_pure_stmts(yes) && agy_reuse_pure_stmts(no),
          v => agy_reuse_prepend(P113DIf{cond,yes,no},agy_reuse_find(cls,rname,ids,rest)),
          v => AgyReuseMatch{False{},"",Con{P113DIf{cond,yes,no},rest}}))

@unsafe
def agy_reuse_find_ctor(+cls: U32, +rname: String, +ids: N111Ids, +cname: String,
    +typ: N111Type, +sym: String, +args: List<&2,N111Arg>, +rest: List<&2,P113DStmt>) -> AgyReuseMatch:
  match typ args:
    case N111U64{} Con{N111Arg{N111Ptr{},N111Local{+state}},Con{N111Arg{N111U32{},N111CtorId{+ctor}},Con{N111Arg{N111Ptr{},N111Local{+buf}},Nil{}}}}:
      +m = agy_rt_ctor_arity(sym)
      nt_choose(AgyReuseMatch,U32.is_gt(m,0) && U32.is_eq(p185cc_class(m),cls) &&
          String.eq(state,"state") && p185cb_known(ctor,ids) && p185cc_known(ctor,m,ids),
        v => AgyReuseMatch{True{},ctor,Con{P113DScalar{N111Call{cname,N111U64{},
          "agy_rt_ctor_reuse" ++ U32.show(m),
          [N111Arg{N111Ptr{},N111Local{state}},N111Arg{N111U32{},N111CtorId{ctor}},
           N111Arg{N111Ptr{},N111Local{buf}},N111Arg{N111U64{},N111Local{rname}}]}},rest}},
        v => AgyReuseMatch{False{},"",Con{P113DScalar{N111Call{cname,typ,sym,args}},rest}})
    case _ _: AgyReuseMatch{False{},"",Con{P113DScalar{N111Call{cname,typ,sym,args}},rest}}

@unsafe
def agy_reuse_is_abort(stmts: List<&2,P113DStmt>) -> Bool:
  match stmts:
    case Nil{}: False{}
    case Con{P113DScalar{N111Call{n,t,+sym,args}},rest}:
      String.eq(sym,"p111_rt_fail") || (String.eq(sym,"p111_rt_sink") && agy_reuse_is_abort(rest))
    case Con{P113DScalar{other},rest}:
      agy_reuse_pure_nstmt(other) && agy_reuse_is_abort(rest)
    case _: False{}

@unsafe
def agy_reuse_find_call(+cls: U32, +rname: String, +ids: N111Ids, +cname: String,
    +typ: N111Type, +sym: String, +args: List<&2,N111Arg>, +rest: List<&2,P113DStmt>) -> AgyReuseMatch:
  nt_choose(AgyReuseMatch,String.eq(sym,"p111_rt_fail") || (String.eq(sym,"p111_rt_sink") && agy_reuse_is_abort(rest)),
    u => AgyReuseMatch{True{},"",Con{P113DScalar{N111Call{cname,typ,sym,args}},rest}},
    u => agy_reuse_find_ctor(cls,rname,ids,cname,typ,sym,args,rest))

@unsafe
def agy_reuse_find(cls,rname,ids,stmts):
  match stmts:
    case Nil{}: AgyReuseMatch{False{},"",[]}
    case Con{+head,+rest}:
      match head:
        case P113DScalar{N111Call{cname,typ,sym,args}}:
          agy_reuse_find_call(cls,rname,ids,cname,typ,sym,args,rest)
        case P113DScalar{other}:
          nt_choose(AgyReuseMatch,agy_reuse_pure_nstmt(other),
            u => agy_reuse_prepend(head,agy_reuse_find(cls,rname,ids,rest)),
            u => AgyReuseMatch{False{},"",stmts})
        case P113DIf{cond,yes,no}:
          agy_reuse_find_if(cls,rname,ids,cond,yes,no,rest,
            agy_reuse_find(cls,rname,ids,yes),agy_reuse_find(cls,rname,ids,no))
        case _: AgyReuseMatch{False{},"",stmts}

law agy_reuse_walk:
  for +ids: N111Ids
  for stmts: List<&2,P113DStmt>
  List<&2,P113DStmt>

@unsafe
def agy_reuse_take_matched(+ids: N111Ids, +tname: String, +state: String,
    +term: N111Value, +buf: String, +n: U32, +orig_head: P113DStmt, +rest: List<&2,P113DStmt>,
    found: AgyReuseMatch) -> List<&2,P113DStmt>:
  match found:
    case AgyReuseMatch{ok,+ctor,rest2}:
      nt_choose(List<&2,P113DStmt>,ok && Bool.not(String.is_empty(ctor)),
        v => Con{P113DScalar{N111Call{tname,N111U64{},"agy_rt_take_reuse" ++ U32.show(n),
          [N111Arg{N111Ptr{},N111Local{state}},N111Arg{N111U64{},term},
           N111Arg{N111Ptr{},N111Local{buf}},N111Arg{N111U32{},N111CtorId{ctor}}]}},
          agy_reuse_walk(ids,rest2)},
        v => Con{orig_head,agy_reuse_walk(ids,rest)})

@unsafe
def agy_reuse_try_take(+ids: N111Ids, +tname: String, +sym: String, +state: String,
    +term: N111Value, +buf: String, +n: U32, +orig_head: P113DStmt, +rest: List<&2,P113DStmt>) -> List<&2,P113DStmt>:
  nt_choose(List<&2,P113DStmt>,Bool.not(agy_reuse_stmts_use(tname,rest)),
    u => agy_reuse_take_matched(ids,tname,state,term,buf,n,orig_head,rest,agy_reuse_find(p185cc_class(n),tname,ids,rest)),
    u => Con{orig_head,agy_reuse_walk(ids,rest)})

@unsafe
def agy_reuse_walk(ids,stmts):
  match stmts:
    case Nil{}: []
    case Con{+head,+rest}:
      match head:
        case P113DScalar{N111Call{+tname,N111U64{},+sym,Con{N111Arg{N111Ptr{},N111Local{+state}},Con{N111Arg{N111U64{},+term},Con{N111Arg{N111Ptr{},N111Local{+buf}},Nil{}}}}}}:
          +n = agy_rt_take_arity(sym)
          nt_choose(List<&2,P113DStmt>,U32.is_gt(n,0) && String.eq(state,"state"),
            u => agy_reuse_try_take(ids,tname,sym,state,term,buf,n,head,rest),
            u => Con{head,agy_reuse_walk(ids,rest)})
        case P113DIf{cond,yes,no}:
          Con{P113DIf{cond,agy_reuse_walk(ids,yes),agy_reuse_walk(ids,no)},agy_reuse_walk(ids,rest)}
        case _:
          Con{head,agy_reuse_walk(ids,rest)}

@unsafe
def agy_reuse_body(+symbol: String, +ids: N111Ids, +body: List<&2,P113DStmt>) -> List<&2,P113DStmt>:
  nt_choose(List<&2,P113DStmt>,agy_reuse_enabled() &&
      (String.starts_with(symbol,"p113d_") || String.starts_with(symbol,"p114r_")) &&
      U32.is_le(p113i_size(body),256),
    u => agy_reuse_walk(ids,body),
    u => body)

def agy_rt_take_reuse_arity(+symbol: String) -> U32:
  nt_choose(U32,String.eq(symbol,"agy_rt_take_reuse1"),u => 1,u =>
  nt_choose(U32,String.eq(symbol,"agy_rt_take_reuse2"),u => 2,u =>
  nt_choose(U32,String.eq(symbol,"agy_rt_take_reuse3"),u => 3,u =>
  nt_choose(U32,String.eq(symbol,"agy_rt_take_reuse4"),u => 4,u => 0))))

def agy_rt_ctor_reuse_arity(+symbol: String) -> U32:
  nt_choose(U32,String.eq(symbol,"agy_rt_ctor_reuse1"),u => 1,u =>
  nt_choose(U32,String.eq(symbol,"agy_rt_ctor_reuse2"),u => 2,u =>
  nt_choose(U32,String.eq(symbol,"agy_rt_ctor_reuse3"),u => 3,u =>
  nt_choose(U32,String.eq(symbol,"agy_rt_ctor_reuse4"),u => 4,u => 0))))

@unsafe
def agy_rt_take_reuse_text(+name: String, +count: U32, +args: List<&2,N111Arg>,
    +ids: N111Ids, +frame: X181Frame, +site: U32) -> X188Seq:
  +slow = x181_label(site,frame)
  +done = x181_label(U32.inc(site),frame)
  +fallback = "p125_rt_take" ++ U32.show(count)
  x188_many([
    x186_call_arguments(args,ids,frame),
    x188_i2("movq",X187Rip{"p111_program",88,0},x188_reg(8,64)),
    x188_i2("andl",X187Imm{9,0},x188_reg(8,32)),
    x188_i2("cmpl",X187Imm{9,0},x188_reg(8,32)),
    x188_i1("jne",X187Target{slow}),
    x188_i2("movq",X187Rip{"p111_program",136,0},x188_reg(8,64)),
    x188_i2("movzbl",X187Indexed{8,1,1,0},x188_reg(8,32)),
    x188_i2("testl",x188_reg(8,32),x188_reg(8,32)),
    x188_i1("jnz",X187Target{slow}),
    x188_i2("movq",x188_reg(6,64),x188_reg(1,64)),
    x188_i2("shrq",X187Imm{40,0},x188_reg(1,64)),
    x188_i2("movl",x188_reg(1,32),x188_reg(0,32)),
    x188_i2("shrl",X187Imm{16,0},x188_reg(0,32)),
    x188_i2("cmpl",X187Imm{2,0},x188_reg(0,32)),
    x188_i1("jne",X187Target{slow}),
    x188_i2("andl",X187Imm{65535,0},x188_reg(1,32)),
    x188_i2("movq",X187Rip{"p111_program",24,0},x188_reg(8,64)),
    x188_i2("cmpq",x188_reg(8,64),x188_reg(1,64)),
    x188_i1("jae",X187Target{slow}),
    x188_i2("movq",X187Rip{"p111_program",128,0},x188_reg(8,64)),
    x188_i2("movzbl",X187Indexed{8,1,1,0},x188_reg(8,32)),
    x188_i2("cmpl",X187Imm{count,0},x188_reg(8,32)),
    x188_i1("jne",X187Target{slow}),
    x188_i2("movq",x188_reg(6,64),x188_reg(0,64)),
    x188_i2("shlq",X187Imm{24,0},x188_reg(0,64)),
    x188_i2("shrq",X187Imm{24,0},x188_reg(0,64)),
    x188_i2("movq",X187Rip{"p111_program",64,0},x188_reg(8,64)),
    x188_i2("addq",X187Imm{127,0},x188_reg(8,64)),
    x188_i2("andq",X187Imm{4294967168,4294967295},x188_reg(8,64)),
    x188_i2("addq",X187Imm{51413504,0},x188_reg(8,64)),
    x188_i2("cmpq",x188_reg(8,64),x188_reg(0,64)),
    x188_i1("jb",X187Target{slow}),
    x188_i2("movq",X187Mem{7,0},x188_reg(9,64)),
    x188_i2("leaq",X187Indexed{9,0,8,0},x188_reg(10,64)),
    agy_copy_words(10,2,11,count,0),
    x188_i1("jmp",X187Target{done}),
    x188_label(slow),
    x188_i2("xorl",x188_reg(0,32),x188_reg(0,32)),
    x188_i1("call",X187Target{fallback}),
    x188_i2("xorl",x188_reg(0,32),x188_reg(0,32)),
    x188_label(done),
    x181_store(name,frame,x188_reg(0,64))])

@unsafe
def agy_rt_ctor_reuse_text(+name: String, +count: U32, +args: List<&2,N111Arg>, +cid: U32,
    +ids: N111Ids, +frame: X181Frame, +site: U32) -> X188Seq:
  +cls = p185cc_class(count)
  +atOff = U32.mul(cls,8)
  +lenOff = U32.add(256,atOff)
  +words = agy_cls_words(cls)
  +normal = x181_label(site,frame)
  +slow = x181_label(U32.inc(site),frame)
  +done = x181_label(U32.add(site,2),frame)
  +fallback = "p125_rt_ctor" ++ U32.show(count)
  x188_many([
    x186_call_arguments(args,ids,frame),
    x188_i2("testq",x188_reg(1,64),x188_reg(1,64)),
    x188_i1("jz",X187Target{normal}),
    x188_i2("movq",X187Mem{7,0},x188_reg(9,64)),
    x188_i2("leaq",X187Indexed{9,1,8,0},x188_reg(10,64)),
    agy_copy_words(2,10,11,count,0),
    x188_i2("movabsq",X187Imm{0,U32.add(33554432,U32.mul(cid,256))},x188_reg(0,64)),
    x188_i2("orq",x188_reg(1,64),x188_reg(0,64)),
    x188_i1("jmp",X187Target{done}),
    x188_label(normal),
    x188_i2("movq",X187Rip{"p111_program",88,0},x188_reg(1,64)),
    x188_i2("andl",X187Imm{9,0},x188_reg(1,32)),
    x188_i2("cmpl",X187Imm{9,0},x188_reg(1,32)),
    x188_i1("jne",X187Target{slow}),
    x188_i2("movq",X187Rip{"p111_program",136,0},x188_reg(1,64)),
    x188_i2("movzbl",X187Indexed{1,6,1,0},x188_reg(1,32)),
    x188_i2("testl",x188_reg(1,32),x188_reg(1,32)),
    x188_i1("jnz",X187Target{slow}),
    x188_i2("movq",X187Mem{7,8},x188_reg(8,64)),
    x188_i2("movq",X187Mem{8,atOff},x188_reg(0,64)),
    x188_i2("testq",x188_reg(0,64),x188_reg(0,64)),
    x188_i1("jz",X187Target{slow}),
    x188_i2("movq",X187Mem{7,0},x188_reg(9,64)),
    x188_i2("leaq",X187Indexed{9,0,8,0},x188_reg(10,64)),
    x188_i2("movq",X187Mem{10,0},x188_reg(11,64)),
    x188_i2("movq",x188_reg(11,64),X187Mem{8,atOff}),
    x188_i2("subq",X187Imm{words,0},X187Mem{8,lenOff}),
    agy_copy_words(2,10,11,count,0),
    x188_i2("movabsq",X187Imm{0,U32.add(33554432,U32.mul(cid,256))},x188_reg(1,64)),
    x188_i2("orq",x188_reg(1,64),x188_reg(0,64)),
    x188_i1("jmp",X187Target{done}),
    x188_label(slow),
    x188_i2("xorl",x188_reg(0,32),x188_reg(0,32)),
    x188_i1("call",X187Target{fallback}),
    x188_label(done),
    x181_store(name,frame,x188_reg(0,64))])

@unsafe
def agy_rt_sink_skip_text(+name: String, +args: List<&2,N111Arg>,
    +ids: N111Ids, +frame: X181Frame, +site: U32) -> X188Seq:
  +done = x181_label(site,frame)
  x188_many([
    x186_call_arguments(args,ids,frame),
    x188_i2("movq",x188_reg(6,64),x188_reg(0,64)),
    x188_i2("shrq",X187Imm{56,0},x188_reg(0,64)),
    x188_i2("cmpq",X187Imm{2,0},x188_reg(0,64)),
    x188_i2("xorl",x188_reg(0,32),x188_reg(0,32)),
    x188_i1("jb",X187Target{done}),
    x188_i1("call",X187Target{"p111_rt_sink"}),
    x188_label(done),
    x181_store(name,frame,x188_reg(0,64))])
"""

OLD_INLINE_TRY = """@unsafe
def agy_rt_inline_try(+name: String, +typ: N111Type, +symbol: String, +args: List<&2,N111Arg>,
    +ids: N111Ids, +frame: X181Frame, +code: X181Code) -> X181Code:
  match typ args code:
    case N111U64{} Con{N111Arg{N111Ptr{},N111Local{+state}},Con{N111Arg{N111U32{},N111CtorId{+ctor}},Con{N111Arg{N111Ptr{},N111Local{+buf}},Nil{}}}} X181Code{chunks,+next,terminal,error}:
      +n = agy_rt_ctor_arity(symbol)
      nt_choose(X181Code,agy_ctor_inline_enabled() && agy_frame_ctor_ok(frame) && U32.is_gt(n,0) &&
          String.eq(state,"state") && p185cb_known(ctor,ids) && p185cc_known(ctor,n,ids) && U32.is_le(next,4294967293),
        u => X181Code{Con{agy_rt_ctor_text(name,symbol,args,agy_ctor_cid(ctor,ids),n,ids,frame,next),chunks},U32.add(next,2),terminal,error},
        u => agy_rt_inline_fallback(name,typ,symbol,args,ids,frame,code))
    case N111U64{} Con{N111Arg{N111Ptr{},N111Local{+state}},Con{N111Arg{N111U64{},term},Con{N111Arg{N111Ptr{},N111Local{+buf}},Nil{}}}} X181Code{chunks,+next,terminal,error}:
      +n = agy_rt_take_arity(symbol)
      nt_choose(X181Code,agy_take_inline_enabled() && agy_frame_ctor_ok(frame) && U32.is_gt(n,0) &&
          String.eq(state,"state") && U32.is_le(next,4294967293),
        u => X181Code{Con{agy_rt_take_text(name,symbol,args,n,ids,frame,next),chunks},U32.add(next,2),terminal,error},
        u => agy_rt_inline_fallback(name,typ,symbol,args,ids,frame,code))
    case _ _ _: agy_rt_inline_fallback(name,typ,symbol,args,ids,frame,code)"""

NEW_INLINE_TRY = REUSE_CODE + """
@unsafe
def agy_rt_inline_try(+name: String, +typ: N111Type, +symbol: String, +args: List<&2,N111Arg>,
    +ids: N111Ids, +frame: X181Frame, +code: X181Code) -> X181Code:
  match typ args code:
    case N111U64{} Con{N111Arg{N111Ptr{},N111Local{+state}},Con{N111Arg{N111U64{},term},Con{N111Arg{N111Ptr{},N111Local{+buf}},Con{N111Arg{N111U32{},N111CtorId{+ctor}},Nil{}}}}} X181Code{chunks,+next,terminal,error}:
      +n = agy_rt_take_reuse_arity(symbol)
      nt_choose(X181Code,U32.is_gt(n,0) && String.eq(state,"state") && U32.is_le(next,4294967293),
        u => X181Code{Con{agy_rt_take_reuse_text(name,n,args,ids,frame,next),chunks},U32.add(next,2),terminal,error},
        u => agy_rt_inline_fallback(name,typ,symbol,args,ids,frame,code))
    case N111U64{} Con{N111Arg{N111Ptr{},N111Local{+state}},Con{N111Arg{N111U32{},N111CtorId{+ctor}},Con{N111Arg{N111Ptr{},N111Local{+buf}},Con{N111Arg{N111U64{},rval},Nil{}}}}} X181Code{chunks,+next,terminal,error}:
      +n = agy_rt_ctor_reuse_arity(symbol)
      nt_choose(X181Code,U32.is_gt(n,0) && String.eq(state,"state") && p185cb_known(ctor,ids) && p185cc_known(ctor,n,ids) && U32.is_le(next,4294967292),
        u => X181Code{Con{agy_rt_ctor_reuse_text(name,n,args,agy_ctor_cid(ctor,ids),ids,frame,next),chunks},U32.add(next,3),terminal,error},
        u => agy_rt_inline_fallback(name,typ,symbol,args,ids,frame,code))
    case N111U64{} Con{N111Arg{N111Ptr{},N111Local{+state}},Con{N111Arg{N111U32{},N111CtorId{+ctor}},Con{N111Arg{N111Ptr{},N111Local{+buf}},Nil{}}}} X181Code{chunks,+next,terminal,error}:
      +n = agy_rt_ctor_arity(symbol)
      nt_choose(X181Code,agy_ctor_inline_enabled() && agy_frame_ctor_ok(frame) && U32.is_gt(n,0) &&
          String.eq(state,"state") && p185cb_known(ctor,ids) && p185cc_known(ctor,n,ids) && U32.is_le(next,4294967293),
        u => X181Code{Con{agy_rt_ctor_text(name,symbol,args,agy_ctor_cid(ctor,ids),n,ids,frame,next),chunks},U32.add(next,2),terminal,error},
        u => agy_rt_inline_fallback(name,typ,symbol,args,ids,frame,code))
    case N111U64{} Con{N111Arg{N111Ptr{},N111Local{+state}},Con{N111Arg{N111U64{},term},Con{N111Arg{N111Ptr{},N111Local{+buf}},Nil{}}}} X181Code{chunks,+next,terminal,error}:
      +n = agy_rt_take_arity(symbol)
      nt_choose(X181Code,agy_take_inline_enabled() && agy_frame_ctor_ok(frame) && U32.is_gt(n,0) &&
          String.eq(state,"state") && U32.is_le(next,4294967293),
        u => X181Code{Con{agy_rt_take_text(name,symbol,args,n,ids,frame,next),chunks},U32.add(next,2),terminal,error},
        u => agy_rt_inline_fallback(name,typ,symbol,args,ids,frame,code))
    case N111U64{} Con{N111Arg{N111Ptr{},N111Local{+state}},Con{N111Arg{N111U32{},N111CtorId{+ctor}},Con{N111Arg{N111Ptr{},buf},Con{N111Arg{N111U32{},N111Const{0,0}},Nil{}}}}} X181Code{chunks,+next,terminal,error}:
      nt_choose(X181Code,String.eq(symbol,"p111_rt_ctor") && String.eq(state,"state") && p185cb_known(ctor,ids) && p185cc_known(ctor,0,ids),
        u => X181Code{Con{x188_many([
          x188_i2("movabsq",X187Imm{0,U32.add(16777216,U32.mul(agy_ctor_cid(ctor,ids),256))},x188_reg(0,64)),
          x181_store(name,frame,x188_reg(0,64))]),chunks},next,terminal,error},
        u => agy_rt_inline_fallback(name,typ,symbol,args,ids,frame,code))
    case N111U64{} Con{N111Arg{N111Ptr{},N111Local{+state}},Con{N111Arg{N111U64{},term},Nil{}}} X181Code{chunks,+next,terminal,error}:
      nt_choose(X181Code,agy_sink_skip_enabled() && String.eq(symbol,"p111_rt_sink") &&
          String.eq(state,"state") && U32.is_le(next,4294967294),
        u => X181Code{Con{agy_rt_sink_skip_text(name,args,ids,frame,next),chunks},U32.inc(next),terminal,error},
        u => agy_rt_inline_fallback(name,typ,symbol,args,ids,frame,code))
    case _ _ _: agy_rt_inline_fallback(name,typ,symbol,args,ids,frame,code)"""

OLD_PLACE = """@unsafe
def x186_function_memory(symbol: String, +params: List<&2,String>, +setup: List<&2,P113DStmt>,
    body: List<&2,P113DStmt>, ids: N111Ids) -> X181Output:
  x185_function_copied(symbol,params,setup,x185_dead_body(setup,
    x185_copy_function(params,setup,x186_expression_body(setup,
      x190_local_values_body(setup,x192_predicate_body(x186_private_body(params,setup,body)))))),ids)"""

NEW_PLACE = """@unsafe
def x186_function_memory(+symbol: String, +params: List<&2,String>, +setup: List<&2,P113DStmt>,
    body: List<&2,P113DStmt>, +ids: N111Ids) -> X181Output:
  x185_function_copied(symbol,params,setup,agy_reuse_body(symbol,ids,x185_dead_body(setup,
    x185_copy_function(params,setup,x186_expression_body(setup,
      x190_local_values_body(setup,x192_predicate_body(x186_private_body(params,setup,body))))))),ids)"""

def patch(text: str, reuse: bool, take: bool, sink_skip: bool) -> str:
    assert text.count(OLD_INLINE_TRY) == 1, "OLD_INLINE_TRY not unique"
    new_try = NEW_INLINE_TRY
    if not reuse:
        new_try = new_try.replace("def agy_reuse_enabled() -> Bool: True{}", "def agy_reuse_enabled() -> Bool: False{}")
    if sink_skip:
        new_try = new_try.replace("def agy_sink_skip_enabled() -> Bool: False{}", "def agy_sink_skip_enabled() -> Bool: True{}")
    text = text.replace(OLD_INLINE_TRY, new_try, 1)
    if text.count(OLD_PLACE) == 1:
        text = text.replace(OLD_PLACE, NEW_PLACE, 1)
    else:
        import re
        pat = re.compile(
            r'(@unsafe\ndef x186_function_memory\()symbol: String, (\+params: List<&2,String>, \+setup: List<&2,P113DStmt>,\n'
            r'    body: List<&2,P113DStmt>, )ids: N111Ids(\) -> X181Output:\n'
            r'  x185_function_copied\(symbol,params,setup,)(.+?)(,ids\))',
            re.S,
        )
        m = list(pat.finditer(text))
        assert len(m) == 1, f"x186_function_memory not unique ({len(m)})"
        text = pat.sub(r'\1+symbol: String, \2+ids: N111Ids\3agy_reuse_body(symbol,ids,\4)\5', text, count=1)
    if take:
        old_t = "def agy_take_inline_enabled() -> Bool: False{}"
        assert text.count(old_t) == 1, "agy_take_inline_enabled not unique"
        text = text.replace(old_t, "def agy_take_inline_enabled() -> Bool: True{}", 1)
    return text

def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--src", type=Path, default=DEFAULT_SRC)
    ap.add_argument("--dst", type=Path, default=DEFAULT_DST)
    ap.add_argument("--reuse", action="store_true")
    ap.add_argument("--take", action="store_true")
    ap.add_argument("--sink-skip", action="store_true")
    a = ap.parse_args()
    out = patch(a.src.read_text(), a.reuse, a.take, a.sink_skip)
    a.dst.parent.mkdir(parents=True, exist_ok=True)
    a.dst.write_text(out)
    print(f"Patched (reuse={a.reuse}, take={a.take}, sink_skip={a.sink_skip}) -> {a.dst} ({len(out)} bytes)")

if __name__ == "__main__":
    main()
