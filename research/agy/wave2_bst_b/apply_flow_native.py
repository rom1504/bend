#!/usr/bin/env python3
"""AGY-W2B-4: Certified Native In-Place Bitonic `flow` Merger Fast Path.

Certifies name-independently at KTerm level any bitonic merge function
`flow(d: Nat, s: Bool, w: T) -> T` over a 2-ctor tree ADT T = { Leaf{v: U32}, Node{l: T, r: T} }:
  - d == 0n: identity on Leaf{v} and Node{wa, wb};
  - d == 1n+p: identity on Leaf{v}, and on Node{wa, wb} computes
      fa fb = flow(p, s, wn(wa, s)) flow(p, s, wn(wb, s))
      Node{fa, fb}
  - where wn(t, s) is identity on Leaf{v} and calls warp(a, b, s) on Node{a, b},
    and `warp` is independently certified by x198pw_checked_plan with matching Leaf/Node.

Wraps `p114r_<flow>` with a depth-bounded (d <= 64) native-stack x86 recursive
helper that:
  - returns w immediately for d == 0 or Leaf;
  - inlines uniquely-owned Node unpack + free for wn(child, s) and calls p114r_<warp> directly;
  - reuses w's Node slot in-place (zero p111_rt_frame, zero p125_rt_take2/ctor2, zero warp_node call);
  - cleanly delegates to agy_flow_slow_<sym> / p114r_<wn> for d > 64, RFC-shared, static, or hot nodes.
"""
import argparse
from pathlib import Path

DEFAULT_SRC = Path("/home/ai/bend2_agy/selfhost/build/agy/wave2_bst_b/compiler.bend")
DEFAULT_DST = Path("/home/ai/bend2_agy/selfhost/build/agy/wave2_bst_b/compiler_flow.bend")

FLOW_CODE = r"""
# ============================================================================
# AGY-W2B-4: Certified Native In-Place Bitonic `flow` Fast Path
# ============================================================================

type AgyFlowPlan is Data:
  AgyFlowNone{}
  AgyFlowPlan{+owner: String, +leaf: String, +node: String, +warp: String, +wn: String}

def agy_fl_pat_z_leaf() -> X198PWPattern:
  X198PWCase{"zero",X198PWLam{"s",X198PWCase{"leaf",X198PWLam{"v",x198pw_leaf("v")}}}}

def agy_fl_pat_z_node() -> X198PWPattern:
  X198PWCase{"zero",X198PWLam{"s",x198pw_two("node","a","b",x198pw_node(x198pw_v("a"),x198pw_v("b")))}}

def agy_fl_pat_s_leaf() -> X198PWPattern:
  X198PWCase{"succ",X198PWLam{"p",X198PWLam{"s",X198PWCase{"leaf",X198PWLam{"v",x198pw_leaf("v")}}}}}

def agy_fl_pat_s_node() -> X198PWPattern:
  X198PWCase{"succ",X198PWLam{"p",X198PWLam{"s",x198pw_two("node","wa","wb",
    X198PWLet2{
      X198PWCall{"self",[x198pw_v("p"),x198pw_v("s"),X198PWCall{"wn",[x198pw_v("wa"),x198pw_v("s")]}]},
      X198PWCall{"self",[x198pw_v("p"),x198pw_v("s"),X198PWCall{"wn",[x198pw_v("wb"),x198pw_v("s")]}]},
      x198pw_node(x198pw_v("res0"),x198pw_v("res1"))})}}}

def agy_fl_pat_wn_leaf() -> X198PWPattern:
  X198PWCase{"leaf",X198PWLam{"v",X198PWLam{"s",x198pw_leaf("v")}}}

def agy_fl_pat_wn_node() -> X198PWPattern:
  x198pw_two("node","a","b",X198PWLam{"s",X198PWCall{"warp",[x198pw_v("a"),x198pw_v("b"),x198pw_v("s")]}})

@unsafe
def agy_fl_check_warp(+book: List<&2,KDef>, +owner: String, +wn: String, +leaf_id: String, +node_id: String,
    +warp_name: String, wp: X198PWPlan) -> AgyFlowPlan:
  match wp:
    case X198PWPlan{w_owner,w_leaf,w_node}:
      nt_choose(AgyFlowPlan,String.eq(w_leaf,leaf_id) && String.eq(w_node,node_id),
        u => AgyFlowPlan{owner,leaf_id,node_id,warp_name,wn},
        u => AgyFlowNone{})
    case _: AgyFlowNone{}

@unsafe
def agy_fl_finish(+book: List<&2,KDef>, +owner: String, +ty: String, s: X198PWState) -> AgyFlowPlan:
  match s:
    case X198PWState{+roles,vars}:
      +leaf = x198pw_name(roles,"leaf")
      +node = x198pw_name(roles,"node")
      +wn = x198pw_name(roles,"wn")
      +warp = x198pw_name(roles,"warp")
      +leaf_id = nc_ctor_identity(book,leaf)
      +node_id = nc_ctor_identity(book,node)
      nt_choose(AgyFlowPlan,x198pw_data(book,ty,leaf,node) && Bool.not(String.is_empty(warp)),
        u => agy_fl_check_warp(book,owner,wn,leaf_id,node_id,warp,x198pw_checked_plan(book,lookup(book,warp))),
        u => AgyFlowNone{})
    case _: AgyFlowNone{}

@unsafe
def agy_fl_family(+book: List<&2,KDef>, +owner: String, +ty: String, +leaf: String, +node: String) -> AgyFlowPlan:
  +r0 = x198pw_put(x198pw_put(x198pw_put(x198pw_put(x198pw_put(
    missing(),"self",owner),"leaf",leaf),"node",node),"zero","Zero"),"succ","Succ")
  +s1 = x198pw_def(book,"self",3,agy_fl_pat_z_leaf(),X198PWState{r0,missing()})
  +s2 = x198pw_def(book,"self",3,agy_fl_pat_z_node(),s1)
  +s3 = x198pw_def(book,"self",3,agy_fl_pat_s_leaf(),s2)
  +s4 = x198pw_def(book,"self",3,agy_fl_pat_s_node(),s3)
  +s5 = x198pw_def(book,"wn",2,agy_fl_pat_wn_leaf(),s4)
  +s6 = x198pw_def(book,"wn",2,agy_fl_pat_wn_node(),s5)
  agy_fl_finish(book,owner,ty,s6)

@unsafe
def agy_fl_try_ctors(+book: List<&2,KDef>, +owner: String, +ty: String, cs: List<&2,KDef>) -> AgyFlowPlan:
  match cs:
    case Con{+a,Con{+b,Nil{}}}:
      nt_choose(AgyFlowPlan,x198pw_ctor(a,dn(a),["U32"],ty) && x198pw_ctor(b,dn(b),[ty,ty],ty),
        u => agy_fl_family(book,owner,ty,dn(a),dn(b)),
        u => nt_choose(AgyFlowPlan,x198pw_ctor(b,dn(b),["U32"],ty) && x198pw_ctor(a,dn(a),[ty,ty],ty),
          v => agy_fl_family(book,owner,ty,dn(b),dn(a)),
          v => AgyFlowNone{}))
    case _: AgyFlowNone{}

@unsafe
def agy_fl_checked_plan(+book: List<&2,KDef>, +d: KDef) -> AgyFlowPlan:
  +t = dt(d)
  +ty = nm(kid(kid(kid(t,1),1),0))
  +adt = lookup(book,ty)
  nt_choose(AgyFlowPlan,x198pw_tel(t,["Nat","Bool",ty],ty) &&
      String.eq(dk(adt),"ADT") && U32.is_eq(da(adt),0) && U32.is_eq(dx(adt),0) && Bool.not(db(adt)),
    u => agy_fl_try_ctors(book,dn(d),ty,dc(adt)),
    u => AgyFlowNone{})

def agy_fl_add(p: AgyFlowPlan, acc: List<&2,AgyFlowPlan>) -> List<&2,AgyFlowPlan>:
  match p:
    case AgyFlowNone{}: acc
    case AgyFlowPlan{o,l,n,w,wn}: Con{AgyFlowPlan{o,l,n,w,wn},acc}

def agy_fl_key(owner: String) -> String: "$agy.flow/" ++ owner

@unsafe
def agy_fl_owners(scope: List<&2,KDef>, +book: List<&2,KDef>, +acc: List<&2,AgyFlowPlan>) -> List<&2,AgyFlowPlan>:
  match scope:
    case Nil{}: acc
    case Con{+d,rest}:
      agy_fl_owners(rest,book,nt_choose(List<&2,AgyFlowPlan>,
        String.eq(dk(d),"Def") && U32.is_eq(da(d),3) && Bool.not(db(d) || du(d)) &&
        String.eq(tg(dt(d)),"All") && String.eq(tg(kid(dt(d),1)),"All") && String.eq(tg(kid(kid(dt(d),1),1)),"All"),
        u => agy_fl_add(agy_fl_checked_plan(book,d),acc),u => acc))

@unsafe
def agy_fl_mark(plans: List<&2,AgyFlowPlan>, ids: N111Ids) -> N111Ids:
  match plans ids:
    case Con{AgyFlowPlan{owner,leaf,node,warp,wn},rest} N111Ids{+fs,cs}:
      +key = agy_fl_key("$direct." ++ owner)
      +c0 : KDef = KDef{"w","Name",0,0,kt("Name",warp,0,0,[]),kt("Name",wn,0,0,[]),[],False{},False{}}
      +entry : KDef = KDef{key,"AgyFlowCertified",0,0,kt("Name",leaf,0,0,[]),kt("Name",node,0,0,[]),[c0],False{},False{}}
      agy_fl_mark(rest,N111Ids{nt_choose(KDef,String.eq(dk(p111v_get(fs,key)),"Absent"),
        u => index_set(fs,entry,index_hash(key,2166136261),32),u => fs),cs})
    case _ N111Ids{fs,cs}: N111Ids{fs,cs}

def agy_fl_context(+plans: List<&2,AgyFlowPlan>, ctx: P134Context) -> P134Context:
  match ctx:
    case P134Context{ids,idx,direct,ready,view,lookups,heap,mode}:
      P134Context{agy_fl_mark(plans,ids),idx,direct,ready,view,lookups,heap,mode}

@unsafe
def agy_fl_cursor(+plans: List<&2,AgyFlowPlan>, cursor: P134Cursor) -> P134Cursor:
  match cursor:
    case P134Private{fs,c,next}: P134Private{fs,agy_fl_context(plans,c),agy_fl_cursor(plans,next)}
    case P134Public{ss,c,next}: P134Public{ss,agy_fl_context(plans,c),agy_fl_cursor(plans,next)}
    case P134Legacy{es,c,next}: P134Legacy{es,agy_fl_context(plans,c),agy_fl_cursor(plans,next)}
    case p: p

@unsafe
def agy_fl_ready(+plans: List<&2,AgyFlowPlan>, p: P169Prepared) -> P169Prepared:
  match p:
    case P169Prepared{forwards,+cursor,+error}:
      P169Prepared{forwards,nt_choose(P134Cursor,String.is_empty(error) && Bool.not(List.is_empty(&2,AgyFlowPlan,plans)),
        u => agy_fl_cursor(plans,cursor),u => cursor),error}

@unsafe
def agy_fl_annotate(r: NR_Request, +prepared: P169Prepared) -> P169Prepared:
  match r:
    case NR_Request{source,+book,names,paths,scope,bound}:
      agy_fl_ready(agy_fl_owners(scope,book,[]),prepared)

@unsafe
def agy_fl_get_mark(name: String, ids: N111Ids) -> KDef:
  match ids:
    case N111Ids{fs,cs}: p111v_get(fs,agy_fl_key(name))

@unsafe
def agy_fl_machine(+prefix: String, +slow: String, +warp_sym: String, +wn_sym: String,
    +leaf_cid: U32, +node_cid: U32) -> X188Seq:
  +node_chk = U32.add(131072,node_cid)
  +l_rec = prefix ++ "_rc"
  +l_ret_w = prefix ++ "_rw"
  +l_chk_leaf = prefix ++ "_cl"
  +l_slow_rec = prefix ++ "_sr"
  +l_wn = prefix ++ "_wn"
  +l_wn_leaf = prefix ++ "_wl"
  +l_wn_slow = prefix ++ "_ws"
  x188_many([
    # Entry guards (before any callee-saved push): mode==0, depth==0, val==0, d<=64, cap&9==9, !cid_hot[node]
    x188_i2("cmpq",X187Imm{0,0},x188_reg(8,64)),
    x188_i1("jne",X187Target{slow}),
    x188_i2("cmpq",X187Imm{0,0},x188_reg(9,64)),
    x188_i1("jne",X187Target{slow}),
    x188_i2("cmpq",X187Imm{0,0},X187Mem{4,8}),
    x188_i1("jne",X187Target{slow}),
    x188_i2("cmpq",X187Imm{64,0},x188_reg(6,64)),
    x188_i1("ja",X187Target{slow}),
    x188_i2("movq",X187Rip{"p111_program",88,0},x188_reg(0,64)),
    x188_i2("andl",X187Imm{9,0},x188_reg(0,32)),
    x188_i2("cmpl",X187Imm{9,0},x188_reg(0,32)),
    x188_i1("jne",X187Target{slow}),
    x188_i2("movq",X187Rip{"p111_program",136,0},x188_reg(0,64)),
    x188_i2("movl",X187Imm{node_cid,0},x188_reg(10,32)),
    x188_i2("movzbl",X187Indexed{0,10,1,0},x188_reg(0,32)),
    x188_i2("testl",x188_reg(0,32),x188_reg(0,32)),
    x188_i1("jnz",X187Target{slow}),
    # Save 5 callee-saved regs (entry %rsp is 8 mod 16 -> 5 pushes = 0 mod 16)
    x188_i1("pushq",x188_reg(3,64)),
    x188_i1("pushq",x188_reg(12,64)),
    x188_i1("pushq",x188_reg(13,64)),
    x188_i1("pushq",x188_reg(14,64)),
    x188_i1("pushq",x188_reg(15,64)),
    x188_i2("movq",x188_reg(7,64),x188_reg(12,64)),
    x188_i2("movq",x188_reg(2,64),x188_reg(13,64)),
    x188_i2("movq",X187Mem{12,0},x188_reg(14,64)),
    x188_i2("movq",X187Rip{"p111_program",64,0},x188_reg(15,64)),
    x188_i2("addq",X187Imm{127,0},x188_reg(15,64)),
    x188_i2("andq",X187Imm{4294967168,4294967295},x188_reg(15,64)),
    x188_i2("addq",X187Imm{51413504,0},x188_reg(15,64)),
    # %rsi=d, %rcx=w -> call .Lrec -> result in %rax
    x188_i1("call",X187Target{l_rec}),
    x188_i1("popq",x188_reg(15,64)),
    x188_i1("popq",x188_reg(14,64)),
    x188_i1("popq",x188_reg(13,64)),
    x188_i1("popq",x188_reg(12,64)),
    x188_i1("popq",x188_reg(3,64)),
    x188_i0("ret"),

    # .Lrec(%rsi=d, %rcx=w) -> %rax; preserves %r12..%r15, %rbx
    x188_label(l_rec),
    x188_i2("testq",x188_reg(6,64),x188_reg(6,64)),
    x188_i1("jz",X187Target{l_ret_w}),
    x188_i2("movq",x188_reg(1,64),x188_reg(0,64)),
    x188_i2("shrq",X187Imm{40,0},x188_reg(0,64)),
    x188_i2("cmpq",X187Imm{node_chk,0},x188_reg(0,64)),
    x188_i1("jne",X187Target{l_chk_leaf}),
    x188_i2("movq",x188_reg(1,64),x188_reg(0,64)),
    x188_i2("shlq",X187Imm{24,0},x188_reg(0,64)),
    x188_i2("shrq",X187Imm{24,0},x188_reg(0,64)),
    x188_i2("cmpq",x188_reg(15,64),x188_reg(0,64)),
    x188_i1("jb",X187Target{l_slow_rec}),
    # Fast in-place Node path: push %rbx, d-1, w (3 pushes -> %rsp 0 mod 16!)
    x188_i1("pushq",x188_reg(3,64)),
    x188_i2("subq",X187Imm{1,0},x188_reg(6,64)),
    x188_i1("pushq",x188_reg(6,64)),
    x188_i1("pushq",x188_reg(1,64)),
    x188_i2("leaq",X187Indexed{14,0,8,0},x188_reg(3,64)),
    # Left child: wa = (%rbx) -> wn -> rec -> (%rbx)
    x188_i2("movq",X187Mem{3,0},x188_reg(1,64)),
    x188_i1("call",X187Target{l_wn}),
    x188_i2("movq",X187Mem{4,8},x188_reg(6,64)),
    x188_i1("call",X187Target{l_rec}),
    x188_i2("movq",x188_reg(0,64),X187Mem{3,0}),
    # Right child: wb = 8(%rbx) -> wn -> rec -> 8(%rbx)
    x188_i2("movq",X187Mem{3,8},x188_reg(1,64)),
    x188_i1("call",X187Target{l_wn}),
    x188_i2("movq",X187Mem{4,8},x188_reg(6,64)),
    x188_i1("call",X187Target{l_rec}),
    x188_i2("movq",x188_reg(0,64),X187Mem{3,8}),
    # Return original w in-place!
    x188_i1("popq",x188_reg(0,64)),
    x188_i1("popq",x188_reg(6,64)),
    x188_i1("popq",x188_reg(3,64)),
    x188_i0("ret"),

    x188_label(l_chk_leaf),
    x188_i2("andl",X187Imm{65535,0},x188_reg(0,32)),
    x188_i2("cmpl",X187Imm{leaf_cid,0},x188_reg(0,32)),
    x188_i1("jne",X187Target{l_slow_rec}),
    x188_label(l_ret_w),
    x188_i2("movq",x188_reg(1,64),x188_reg(0,64)),
    x188_i0("ret"),

    # Slow recursive call: slow(state, d, s, w, 0, 0, 0)
    # Entry %rsp is 8 mod 16 -> sub $24 -> 0 mod 16, 0(%rsp)=0
    x188_label(l_slow_rec),
    x188_i2("subq",X187Imm{24,0},x188_reg(4,64)),
    x188_i2("movq",x188_reg(12,64),x188_reg(7,64)),
    x188_i2("movq",x188_reg(13,64),x188_reg(2,64)),
    x188_i2("xorl",x188_reg(8,32),x188_reg(8,32)),
    x188_i2("xorl",x188_reg(9,32),x188_reg(9,32)),
    x188_i2("movq",x188_reg(8,64),X187Mem{4,0}),
    x188_i1("call",X187Target{slow}),
    x188_i2("addq",X187Imm{24,0},x188_reg(4,64)),
    x188_i0("ret"),

    # .Lwn(%rcx=child) -> %rcx = warp_node(child, s)
    x188_label(l_wn),
    x188_i2("movq",x188_reg(1,64),x188_reg(0,64)),
    x188_i2("shrq",X187Imm{40,0},x188_reg(0,64)),
    x188_i2("cmpq",X187Imm{node_chk,0},x188_reg(0,64)),
    x188_i1("jne",X187Target{l_wn_leaf}),
    x188_i2("movq",x188_reg(1,64),x188_reg(0,64)),
    x188_i2("shlq",X187Imm{24,0},x188_reg(0,64)),
    x188_i2("shrq",X187Imm{24,0},x188_reg(0,64)),
    x188_i2("cmpq",x188_reg(15,64),x188_reg(0,64)),
    x188_i1("jb",X187Target{l_wn_slow}),
    # Check ALC_LEN[1] + 2 < 32768 before freeing class-1 Node slot
    x188_i2("movq",X187Mem{12,8},x188_reg(8,64)),
    x188_i2("movq",X187Mem{8,264},x188_reg(11,64)),
    x188_i2("addq",X187Imm{2,0},x188_reg(11,64)),
    x188_i2("cmpq",X187Imm{32768,0},x188_reg(11,64)),
    x188_i1("jae",X187Target{l_wn_slow}),
    # Unpack a0=%rsi, a1=%rdx, push loc onto ALC_AT[1], update ALC_LEN[1]
    x188_i2("leaq",X187Indexed{14,0,8,0},x188_reg(10,64)),
    x188_i2("movq",X187Mem{10,0},x188_reg(6,64)),
    x188_i2("movq",X187Mem{10,8},x188_reg(2,64)),
    x188_i2("movq",X187Mem{8,8},x188_reg(9,64)),
    x188_i2("movq",x188_reg(9,64),X187Mem{10,0}),
    x188_i2("movq",x188_reg(0,64),X187Mem{8,8}),
    x188_i2("movq",x188_reg(11,64),X187Mem{8,264}),
    # Call p114r_<warp>(%r12, a0=%rsi, a1=%rdx, %r13, 0, 0, 0)
    x188_i2("subq",X187Imm{24,0},x188_reg(4,64)),
    x188_i2("movq",x188_reg(12,64),x188_reg(7,64)),
    x188_i2("movq",x188_reg(13,64),x188_reg(1,64)),
    x188_i2("xorl",x188_reg(8,32),x188_reg(8,32)),
    x188_i2("xorl",x188_reg(9,32),x188_reg(9,32)),
    x188_i2("movq",x188_reg(8,64),X187Mem{4,0}),
    x188_i1("call",X187Target{warp_sym}),
    x188_i2("addq",X187Imm{24,0},x188_reg(4,64)),
    x188_i2("movq",x188_reg(0,64),x188_reg(1,64)),
    x188_i0("ret"),

    x188_label(l_wn_leaf),
    x188_i2("andl",X187Imm{65535,0},x188_reg(0,32)),
    x188_i2("cmpl",X187Imm{leaf_cid,0},x188_reg(0,32)),
    x188_i1("jne",X187Target{l_wn_slow}),
    x188_i0("ret"),

    # Slow wn: call p114r_<wn>(%r12, child, %r13, 0, 0, 0)
    x188_label(l_wn_slow),
    x188_i2("subq",X187Imm{8,0},x188_reg(4,64)),
    x188_i2("movq",x188_reg(12,64),x188_reg(7,64)),
    x188_i2("movq",x188_reg(1,64),x188_reg(6,64)),
    x188_i2("movq",x188_reg(13,64),x188_reg(2,64)),
    x188_i2("xorl",x188_reg(1,32),x188_reg(1,32)),
    x188_i2("xorl",x188_reg(8,32),x188_reg(8,32)),
    x188_i2("xorl",x188_reg(9,32),x188_reg(9,32)),
    x188_i1("call",X187Target{wn_sym}),
    x188_i2("addq",X187Imm{8,0},x188_reg(4,64)),
    x188_i2("movq",x188_reg(0,64),x188_reg(1,64)),
    x188_i0("ret")])

@unsafe
def agy_fl_emit_wrapper(+symbol: String, +slow: String, +warp_sym: String, +wn_sym: String,
    leaf_cid: U32, node_cid: U32) -> X181Output:
  X181Output{[x188_many([
    X188One{PSection{1}},X188One{PGlobal{symbol}},X188One{PType{symbol,2}},X188One{PLabel{symbol}},
    agy_fl_machine(".Lagy_fl_" ++ symbol,slow,warp_sym,wn_sym,leaf_cid,node_cid),
    X188One{PSize{symbol}}])],""}

@unsafe
def agy_fl_worker_cids(+symbol: String, +params: List<&2,String>, +setup: List<&2,P113DStmt>,
    +body: List<&2,P113DStmt>, +ids: N111Ids, +leaf: String, +node: String, +warp: String, +wn: String) -> X181Output:
  +leaf_id = x198pw_cid(leaf,ids)
  +node_id = x198pw_cid(node,ids)
  +slow = "agy_flow_slow_" ++ symbol
  +warp_sym = p114r_symbol("$direct." ++ warp)
  +wn_sym = p114r_symbol("$direct." ++ wn)
  nt_choose(X181Output,x198pw_has_cid(leaf_id,1) && x198pw_has_cid(node_id,2) && U32.is_ne(da(leaf_id),da(node_id)),
    u => x181_program_join(agy_fl_emit_wrapper(symbol,slow,warp_sym,wn_sym,da(leaf_id),da(node_id)),
      x185_function_setup(slow,params,setup,body,ids)),
    u => x185_function_setup(symbol,params,setup,body,ids))

@unsafe
def agy_fl_worker_child(+symbol: String, +params: List<&2,String>, +setup: List<&2,P113DStmt>,
    +body: List<&2,P113DStmt>, +ids: N111Ids, +leaf: String, +node: String, cs: List<&2,KDef>) -> X181Output:
  match cs:
    case Con{+c0,Nil{}}: agy_fl_worker_cids(symbol,params,setup,body,ids,leaf,node,nm(dt(c0)),nm(dv(c0)))
    case _: x185_function_setup(symbol,params,setup,body,ids)

@unsafe
def agy_fl_try_worker(+name: String, +params: List<&2,String>, +setup: List<&2,P113DStmt>,
    +body: List<&2,P113DStmt>, +ids: N111Ids) -> X181Output:
  +symbol = p114r_symbol(name)
  +entry = agy_fl_get_mark(name,ids)
  nt_choose(X181Output,String.eq(dk(entry),"AgyFlowCertified") && x198pw_h_args(params),
    u => agy_fl_worker_child(symbol,params,setup,body,ids,nm(dt(entry)),nm(dv(entry)),dc(entry)),
    u => x185_function_setup(symbol,params,setup,body,ids))
"""

OLD_PW_WORKER = """@unsafe
def x198pw_worker(+name: String,+params: List<&2,String>,+setup: List<&2,P113DStmt>,+body: List<&2,P113DStmt>,
    +ids: N111Ids,+entry: KDef) -> X181Output:
  +symbol = p114r_symbol(name)
  nt_choose(X181Output,String.eq(dk(entry),"X198PWCertified") && x198pw_h_args(params),
    u => x198pw_worker_cids(symbol,params,setup,body,ids,nm(dt(entry)),nm(dv(entry))),
    u => x185_function_setup(symbol,params,setup,body,ids))"""

NEW_PW_WORKER = FLOW_CODE + """
@unsafe
def x198pw_worker(+name: String,+params: List<&2,String>,+setup: List<&2,P113DStmt>,+body: List<&2,P113DStmt>,
    +ids: N111Ids,+entry: KDef) -> X181Output:
  +symbol = p114r_symbol(name)
  nt_choose(X181Output,String.eq(dk(entry),"X198PWCertified") && x198pw_h_args(params),
    u => x198pw_worker_cids(symbol,params,setup,body,ids,nm(dt(entry)),nm(dv(entry))),
    u => agy_fl_try_worker(name,params,setup,body,ids))"""

def once(s: str, old: str, new: str, label: str) -> str:
    n = s.count(old)
    assert n == 1, f"{label}: expected 1 match, got {n}"
    return s.replace(old, new, 1)

def patch(text: str) -> str:
    if OLD_PW_WORKER in text:
        text = once(text, OLD_PW_WORKER, NEW_PW_WORKER, "OLD_PW_WORKER")
    else:
        old_ro = OLD_PW_WORKER.replace(
            "u => x185_function_setup(symbol,params,setup,body,ids))",
            "u => agy_ro_worker(name,params,setup,body,ids))",
        )
        new_ro = NEW_PW_WORKER.replace(
            "u => agy_fl_worker_child(symbol,params,setup,body,ids,nm(dt(entry)),nm(dv(entry)),dc(entry)),\n    u => x185_function_setup(symbol,params,setup,body,ids))",
            "u => agy_fl_worker_child(symbol,params,setup,body,ids,nm(dt(entry)),nm(dv(entry)),dc(entry)),\n    u => agy_ro_worker(name,params,setup,body,ids))",
        )
        text = once(text, old_ro, new_ro, "OLD_PW_WORKER_RO")
    # Hook right after x198pw_annotate / agy_zip_annotate at the single caller site
    if "agy_zip_annotate(r,x198pw_annotate(r,prepared))" in text:
        text = once(
            text,
            "agy_zip_annotate(r,x198pw_annotate(r,prepared))",
            "agy_fl_annotate(r,agy_zip_annotate(r,x198pw_annotate(r,prepared)))",
            "hook after agy_zip_annotate",
        )
    else:
        text = once(
            text,
            "u => x198pw_annotate(r,prepared),u => prepared)",
            "u => agy_fl_annotate(r,x198pw_annotate(r,prepared)),u => prepared)",
            "hook after x198pw_annotate",
        )
    return text

def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--src", type=Path, default=DEFAULT_SRC)
    ap.add_argument("--dst", type=Path, default=DEFAULT_DST)
    a = ap.parse_args()
    out = patch(a.src.read_text())
    a.dst.parent.mkdir(parents=True, exist_ok=True)
    a.dst.write_text(out)
    print(f"Patched AGY-W2B-4 (certified native flow) -> {a.dst} ({len(out)} bytes)")

if __name__ == "__main__":
    main()
