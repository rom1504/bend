#!/usr/bin/env python3
"""AGY-W2B-3: Certified In-Place Binary-Tree Zipper-Insert Fast Path.

Certifies name-independently at KTerm level any fueled binary-tree zipper-insert
function `f(fuel: Nat, x: U32, t: T) -> T` of the form:
  f(fuel, x, t) = fin(x, down(fuel, x, (t, Nil{})))
over a 2-constructor ADT T = { Leaf{}, Node{l: T, v: U32, r: T} } where:
  - `down` descends Node using U32.is_lt(x, v), pushing frames onto List<Frame>,
    absorbing at Leaf{} (handles both pre- and post-AGY-005b forms);
  - `fin` inserts Node{Leaf{}, x, Leaf{}} at Leaf{} and rebuilds unchanged at Node;
  - `up` pops frames and rebuilds the exact same Node path.

Emits a 42-instruction leaf x86 fast path wrapping `p113d_<f>` (preserving
`agy_zip_slow_<sym>` as exact fallback). On uniquely owned cold heap trees,
walks down in-place with zero zipper/frame allocations and allocates only the
single inserted leaf Node. Bails cleanly with zero heap mutations on RFC-shared,
static (`loc < HEAP_OFF`), hot (`cid_hot[node] != 0`), disabled capability, or
empty freelist.
"""
import argparse
from pathlib import Path

DEFAULT_SRC = Path("/home/ai/bend2_agy/selfhost/build/agy/wave2_bst/compiler.bend")
DEFAULT_DST = Path("/home/ai/bend2_agy/selfhost/build/agy/wave2_bst_b/compiler.bend")

ZIPPER_CODE = r"""
# ============================================================================
# AGY-W2B-3: Certified In-Place Binary-Tree Zipper-Insert Fast Path
# ============================================================================

type AgyZipPlan is Data:
  AgyZipNone{}
  AgyZipPlan{+owner: String, +leaf: String, +node: String}

type AgyZipPat is Data:
  AgyZCase{+role: String, +body: AgyZipPat}
  AgyZLam{+slot: String, +body: AgyZipPat}
  AgyZVar{+slot: String}
  AgyZCall{+role: String, +args: List<&2,AgyZipPat>}
  AgyZCtr{+role: String, +fields: List<&2,AgyZipPat>}
  AgyZLet1{+slot: String, +val: AgyZipPat, +body: AgyZipPat}

law agy_zip_match:
  for +p: AgyZipPat
  for +term: KTerm
  for +state: X198PWState
  X198PWState

@unsafe
def agy_zip_seq(ps: List<&2,AgyZipPat>, ts: List<&2,KTerm>, +s: X198PWState) -> X198PWState:
  match ps ts s:
    case Nil{} Nil{} _: s
    case Con{p,pr} Con{t,tr} X198PWState{roles,vars}: agy_zip_seq(pr,tr,agy_zip_match(p,t,s))
    case _ _ _: X198PWBad{}

@unsafe
def agy_zip_call_m(role: String, ps: List<&2,AgyZipPat>, chain: KPChain, s: X198PWState) -> X198PWState:
  match chain:
    case KPChain{args,+head}:
      nt_choose(X198PWState,String.eq(tg(head),"Ref") && List.is_empty(&2,KTerm,ks(head)),
        u => agy_zip_seq(ps,args,x198pw_role(role,nm(head),s)),u => X198PWBad{})

@unsafe
def agy_zip_let1_m(slot: String, pv: AgyZipPat, pb: AgyZipPat, +b: KTerm, body: KTerm, s: X198PWState) -> X198PWState:
  nt_choose(X198PWState,String.eq(tg(b),"Bind") && U32.is_eq(terms_len(ks(b)),1),
    u => agy_zip_match(pb,body,x198pw_bind(slot,ix(b),agy_zip_match(pv,kid(b,0),s))),
    u => X198PWBad{})

@unsafe
def agy_zip_match_t(p: AgyZipPat, +t: KTerm, +s: X198PWState) -> X198PWState:
  match p s:
    case AgyZCase{+role,body} X198PWState{+roles,vars}:
      +expected = x198pw_name(roles,role)
      nt_choose(X198PWState,String.is_empty(expected),
        u => nt_choose(X198PWState,String.eq(tg(t),"Mat") && U32.is_eq(terms_len(ks(t)),2),
          v => agy_zip_match(body,kid(t,0),x198pw_role(role,nm(t),s)),
          v => X198PWBad{}),
        u => agy_zip_match(body,x198pw_arm(t,expected,8),s))
    case AgyZLam{slot,body} X198PWState{roles,vars}:
      nt_choose(X198PWState,String.eq(tg(t),"Lam") && U32.is_eq(terms_len(ks(t)),1) && U32.is_gt(qt(t),0),
        u => agy_zip_match(body,kid(t,0),x198pw_bind(slot,ix(t),s)),u => X198PWBad{})
    case AgyZVar{slot} X198PWState{roles,vars}:
      +v = p111v_get(vars,slot)
      nt_choose(X198PWState,String.eq(tg(t),"Var") && String.eq(dk(v),"X198PWVar") && U32.is_eq(ix(t),da(v)),
        u => s,u => X198PWBad{})
    case AgyZCall{role,args} X198PWState{roles,vars}:
      agy_zip_call_m(role,args,x198pw_spine(t,[],8),s)
    case AgyZCtr{+role,fields} X198PWState{roles,vars}:
      nt_choose(X198PWState,String.eq(tg(t),"Ctr") && U32.is_eq(terms_len(ks(t)),nt_count(AgyZipPat,fields)),
        u => agy_zip_seq(fields,ks(t),x198pw_role(role,nm(t),s)),u => X198PWBad{})
    case AgyZLet1{slot,pv,pb} X198PWState{roles,vars}:
      nt_choose(X198PWState,String.eq(tg(t),"Let") && U32.is_eq(terms_len(ks(t)),2),
        u => agy_zip_let1_m(slot,pv,pb,kid(t,0),kid(t,1),s),u => X198PWBad{})
    case _ _: X198PWBad{}

@unsafe
def agy_zip_match(p,term,state):
  agy_zip_match_t(p,nc_unann(term),state)

@unsafe
def agy_zip_def(+book: List<&2,KDef>, role: String, +arity: U32, pat: AgyZipPat, state: X198PWState) -> X198PWState:
  match state:
    case X198PWState{+roles,vars}:
      +d = lookup(book,x198pw_name(roles,role))
      nt_choose(X198PWState,String.eq(dk(d),"Def") && U32.is_eq(da(d),arity) && Bool.not(nc_native_def(d) || nc_foreign(d) || du(d)),
        u => agy_zip_match(pat,dv(d),X198PWState{roles,missing()}),u => X198PWBad{})
    case _: X198PWBad{}

def agy_z_v(s: String) -> AgyZipPat: AgyZVar{s}

def agy_zip_pat_insert() -> AgyZipPat:
  AgyZLam{"fuel",AgyZLam{"x",AgyZLam{"t",
    AgyZCall{"fin",[agy_z_v("x"),
      AgyZCall{"down",[agy_z_v("fuel"),agy_z_v("x"),
        AgyZCtr{"pair",[agy_z_v("t"),AgyZCtr{"nil",[]}]}]}]} }}}

def agy_zip_pat_fin_leaf() -> AgyZipPat:
  AgyZLam{"x",AgyZCase{"pair",AgyZCase{"leaf",AgyZLam{"path",
    AgyZCall{"up",[agy_z_v("path"),AgyZCtr{"node",[AgyZCtr{"leaf",[]},agy_z_v("x"),AgyZCtr{"leaf",[]}]}]}}}}}

def agy_zip_pat_fin_node() -> AgyZipPat:
  AgyZLam{"x",AgyZCase{"pair",AgyZCase{"node",AgyZLam{"l",AgyZLam{"v",AgyZLam{"r",AgyZLam{"path",
    AgyZCall{"up",[agy_z_v("path"),AgyZCtr{"node",[agy_z_v("l"),agy_z_v("v"),agy_z_v("r")]}]}}}}}}}}

def agy_zip_pat_up_nil() -> AgyZipPat:
  AgyZCase{"nil",AgyZLam{"acc",agy_z_v("acc")}}

def agy_zip_pat_up_con(dir: String, a: String, b: String) -> AgyZipPat:
  AgyZCase{"con",AgyZCase{"frame",AgyZLam{"v",AgyZLam{"other",AgyZCase{dir,AgyZLam{"rest",AgyZLam{"acc",
    AgyZCall{"up",[agy_z_v("rest"),AgyZCtr{"node",[agy_z_v(a),agy_z_v("v"),agy_z_v(b)]}]}}}}}}}}

def agy_zip_pat_down_zero() -> AgyZipPat:
  AgyZCase{"zero",AgyZLam{"x",AgyZLam{"st",agy_z_v("st")}}}

# Post-AGY-005b down: Succ arm directly matches st = (Leaf, path) -> (Leaf, path) and (Node, path) -> down(f, x, pick(...))
def agy_zip_pat_down_succ_leaf() -> AgyZipPat:
  AgyZCase{"succ",AgyZLam{"f",AgyZLam{"x",AgyZCase{"pair",AgyZCase{"leaf",AgyZLam{"path",
    AgyZCtr{"pair",[AgyZCtr{"leaf",[]},agy_z_v("path")]}}}}}}}

def agy_zip_pat_down_succ_node_let() -> AgyZipPat:
  AgyZCase{"succ",AgyZLam{"f",AgyZLam{"x",AgyZCase{"pair",AgyZCase{"node",AgyZLam{"l",AgyZLam{"v0",AgyZLam{"r",AgyZLam{"path",
    AgyZLet1{"v",agy_z_v("v0"),
      AgyZCall{"down",[agy_z_v("f"),agy_z_v("x"),
        AgyZCall{"pick",[agy_z_v("l"),agy_z_v("v"),agy_z_v("r"),agy_z_v("path"),
          AgyZCall{"lt",[agy_z_v("x"),agy_z_v("v")]}]}]}}}}}}}}}}}

def agy_zip_pat_down_succ_node_dir() -> AgyZipPat:
  AgyZCase{"succ",AgyZLam{"f",AgyZLam{"x",AgyZCase{"pair",AgyZCase{"node",AgyZLam{"l",AgyZLam{"v",AgyZLam{"r",AgyZLam{"path",
    AgyZCall{"down",[agy_z_v("f"),agy_z_v("x"),
      AgyZCall{"pick",[agy_z_v("l"),agy_z_v("v"),agy_z_v("r"),agy_z_v("path"),
        AgyZCall{"lt",[agy_z_v("x"),agy_z_v("v")]}]}]} }}}}}}}}}

def agy_zip_pat_pick(+dir: String, keep: String, save: String) -> AgyZipPat:
  AgyZLam{"l",AgyZLam{"v",AgyZLam{"r",AgyZLam{"path",AgyZCase{dir,
    AgyZCtr{"pair",[agy_z_v(keep),AgyZCtr{"con",[AgyZCtr{"frame",[agy_z_v("v"),agy_z_v(save),AgyZCtr{dir,[]}]},agy_z_v("path")]}]}}}}}}

@unsafe
def agy_zip_or(s1: X198PWState, s2: X198PWState) -> X198PWState:
  match s1:
    case X198PWState{r,v}: X198PWState{r,v}
    case _: s2

@unsafe
def agy_zip_data_layout(cs: List<&2,KDef>, +ty: String, +leaf: String, +node: String) -> Bool:
  match cs:
    case Con{+a,Con{+b,Nil{}}}:
      (x198pw_ctor(a,leaf,[],ty) && x198pw_ctor(b,node,[ty,"U32",ty],ty)) ||
      (x198pw_ctor(b,leaf,[],ty) && x198pw_ctor(a,node,[ty,"U32",ty],ty))
    case _: False{}

@unsafe
def agy_zip_data_ok(+book: List<&2,KDef>, +ty: String, +leaf: String, +node: String) -> Bool:
  +d = lookup(book,ty)
  String.eq(dk(d),"ADT") && U32.is_eq(da(d),0) && U32.is_eq(dx(d),0) && Bool.not(db(d)) &&
    agy_zip_data_layout(dc(d),ty,leaf,node)

@unsafe
def agy_zip_finish(+book: List<&2,KDef>, +owner: String, +ty: String, s: X198PWState) -> AgyZipPlan:
  match s:
    case X198PWState{+roles,vars}:
      +leaf = x198pw_name(roles,"leaf")
      +node = x198pw_name(roles,"node")
      nt_choose(AgyZipPlan,x198pw_intrinsic(book,roles,"lt","u32_is_lt") && agy_zip_data_ok(book,ty,leaf,node),
        u => AgyZipPlan{owner,nc_ctor_identity(book,leaf),nc_ctor_identity(book,node)},
        u => AgyZipNone{})
    case _: AgyZipNone{}

@unsafe
def agy_zip_check_family(+book: List<&2,KDef>, +owner: String, +ty: String, +leaf: String, +node: String) -> AgyZipPlan:
  +r0 = x198pw_put(x198pw_put(x198pw_put(x198pw_put(x198pw_put(x198pw_put(x198pw_put(x198pw_put(x198pw_put(x198pw_put(
    missing(),"self",owner),"leaf",leaf),"node",node),"pair","Tuple"),"nil","Nil"),"con","Con"),"true","True"),"false","False"),"zero","Zero"),"succ","Succ")
  +s1 = agy_zip_def(book,"self",3,agy_zip_pat_insert(),X198PWState{r0,missing()})
  +s2 = agy_zip_def(book,"fin",2,agy_zip_pat_fin_leaf(),s1)
  +s3 = agy_zip_def(book,"fin",2,agy_zip_pat_fin_node(),s2)
  +s4 = agy_zip_def(book,"up",2,agy_zip_pat_up_nil(),s3)
  +s5 = agy_zip_def(book,"up",2,agy_zip_pat_up_con("true","acc","other"),s4)
  +s6 = agy_zip_def(book,"up",2,agy_zip_pat_up_con("false","other","acc"),s5)
  +s7 = agy_zip_def(book,"down",3,agy_zip_pat_down_zero(),s6)
  +s8 = agy_zip_def(book,"down",3,agy_zip_pat_down_succ_leaf(),s7)
  +s9 = agy_zip_or(
    agy_zip_def(book,"down",3,agy_zip_pat_down_succ_node_let(),s8),
    agy_zip_def(book,"down",3,agy_zip_pat_down_succ_node_dir(),s8))
  +s10 = agy_zip_def(book,"pick",5,agy_zip_pat_pick("true","l","r"),s9)
  +s11 = agy_zip_def(book,"pick",5,agy_zip_pat_pick("false","r","l"),s10)
  agy_zip_finish(book,owner,ty,s11)

@unsafe
def agy_zip_try_ctors(+book: List<&2,KDef>, +owner: String, +ty: String, cs: List<&2,KDef>) -> AgyZipPlan:
  match cs:
    case Con{+a,Con{+b,Nil{}}}:
      nt_choose(AgyZipPlan,x198pw_ctor(a,dn(a),[],ty) && x198pw_ctor(b,dn(b),[ty,"U32",ty],ty),
        u => agy_zip_check_family(book,owner,ty,dn(a),dn(b)),
        u => nt_choose(AgyZipPlan,x198pw_ctor(b,dn(b),[],ty) && x198pw_ctor(a,dn(a),[ty,"U32",ty],ty),
          v => agy_zip_check_family(book,owner,ty,dn(b),dn(a)),
          v => AgyZipNone{}))
    case _: AgyZipNone{}

@unsafe
def agy_zip_checked_plan(+book: List<&2,KDef>, +d: KDef) -> AgyZipPlan:
  +t = dt(d)
  # Check Nat -> U32 -> T -> T
  +ty = nm(kid(kid(kid(t,1),1),0))
  +adt = lookup(book,ty)
  nt_choose(AgyZipPlan,x198pw_tel(t,["Nat","U32",ty],ty) &&
      String.eq(dk(adt),"ADT") && U32.is_eq(da(adt),0) && U32.is_eq(dx(adt),0) && Bool.not(db(adt)),
    u => agy_zip_try_ctors(book,dn(d),ty,dc(adt)),
    u => AgyZipNone{})

def agy_zip_add(p: AgyZipPlan, acc: List<&2,AgyZipPlan>) -> List<&2,AgyZipPlan>:
  match p:
    case AgyZipNone{}: acc
    case AgyZipPlan{o,l,n}: Con{AgyZipPlan{o,l,n},acc}

def agy_zip_key(owner: String) -> String: "$agy.zipper/" ++ owner

@unsafe
def agy_zip_owners(scope: List<&2,KDef>, +book: List<&2,KDef>, +acc: List<&2,AgyZipPlan>) -> List<&2,AgyZipPlan>:
  match scope:
    case Nil{}: acc
    case Con{+d,rest}:
      agy_zip_owners(rest,book,nt_choose(List<&2,AgyZipPlan>,
        String.eq(dk(d),"Def") && U32.is_eq(da(d),3) && Bool.not(db(d) || du(d)) &&
        String.eq(tg(dt(d)),"All") && String.eq(tg(kid(dt(d),1)),"All") && String.eq(tg(kid(kid(dt(d),1),1)),"All"),
        u => agy_zip_add(agy_zip_checked_plan(book,d),acc),u => acc))

@unsafe
def agy_zip_mark(plans: List<&2,AgyZipPlan>, ids: N111Ids) -> N111Ids:
  match plans ids:
    case Con{AgyZipPlan{owner,leaf,node},rest} N111Ids{+fs,cs}:
      +key = agy_zip_key("$direct." ++ owner)
      +entry : KDef = KDef{key,"AgyZipCertified",0,0,kt("Name",leaf,0,0,[]),kt("Name",node,0,0,[]),[],False{},False{}}
      agy_zip_mark(rest,N111Ids{nt_choose(KDef,String.eq(dk(p111v_get(fs,key)),"Absent"),
        u => index_set(fs,entry,index_hash(key,2166136261),32),u => fs),cs})
    case _ N111Ids{fs,cs}: N111Ids{fs,cs}

def agy_zip_context(+plans: List<&2,AgyZipPlan>, ctx: P134Context) -> P134Context:
  match ctx:
    case P134Context{ids,idx,direct,ready,view,lookups,heap,mode}:
      P134Context{agy_zip_mark(plans,ids),idx,direct,ready,view,lookups,heap,mode}

@unsafe
def agy_zip_cursor(+plans: List<&2,AgyZipPlan>, cursor: P134Cursor) -> P134Cursor:
  match cursor:
    case P134Private{fs,c,next}: P134Private{fs,agy_zip_context(plans,c),agy_zip_cursor(plans,next)}
    case P134Public{ss,c,next}: P134Public{ss,agy_zip_context(plans,c),agy_zip_cursor(plans,next)}
    case P134Legacy{es,c,next}: P134Legacy{es,agy_zip_context(plans,c),agy_zip_cursor(plans,next)}
    case p: p

@unsafe
def agy_zip_ready(+plans: List<&2,AgyZipPlan>, p: P169Prepared) -> P169Prepared:
  match p:
    case P169Prepared{forwards,+cursor,+error}:
      P169Prepared{forwards,nt_choose(P134Cursor,String.is_empty(error) && Bool.not(List.is_empty(&2,AgyZipPlan,plans)),
        u => agy_zip_cursor(plans,cursor),u => cursor),error}

@unsafe
def agy_zip_annotate(r: NR_Request, +prepared: P169Prepared) -> P169Prepared:
  match r:
    case NR_Request{source,+book,names,paths,scope,bound}:
      agy_zip_ready(agy_zip_owners(scope,book,[]),prepared)

@unsafe
def agy_zip_get_mark(name: String, ids: N111Ids) -> KDef:
  match ids:
    case N111Ids{fs,cs}: p111v_get(fs,agy_zip_key(name))

@unsafe
def agy_zip_machine(+prefix: String, +slow: String, +leaf_cid: U32, +node_cid: U32) -> X188Seq:
  +leaf_hi = U32.add(16777216,U32.mul(leaf_cid,256))
  +node_hi = U32.add(33554432,U32.mul(node_cid,256))
  +node_chk = U32.add(131072,node_cid)
  +l_loop = prefix ++ "_lp"
  +l_left = prefix ++ "_lt"
  +l_ins = prefix ++ "_in"
  +l_unch = prefix ++ "_un"
  +l_ret = prefix ++ "_rt"
  +l_bail = prefix ++ "_bl"
  x188_many([
    # Live descriptor checks before push %rbx (zero-cost bail on hot/cap-off)
    x188_i2("movq",X187Rip{"p111_program",88,0},x188_reg(0,64)),
    x188_i2("andl",X187Imm{9,0},x188_reg(0,32)),
    x188_i2("cmpl",X187Imm{9,0},x188_reg(0,32)),
    x188_i1("jne",X187Target{slow}),
    x188_i2("movq",X187Rip{"p111_program",136,0},x188_reg(0,64)),
    x188_i2("movl",X187Imm{node_cid,0},x188_reg(10,32)),
    x188_i2("movzbl",X187Indexed{0,10,1,0},x188_reg(0,32)),
    x188_i2("testl",x188_reg(0,32),x188_reg(0,32)),
    x188_i1("jnz",X187Target{slow}),
    # Save %rbx to hold HEAP_OFF in register (0-cycle check inside loop!)
    x188_i1("pushq",x188_reg(3,64)),
    x188_i2("movq",X187Rip{"p111_program",64,0},x188_reg(3,64)),
    x188_i2("addq",X187Imm{127,0},x188_reg(3,64)),
    x188_i2("andq",X187Imm{4294967168,4294967295},x188_reg(3,64)),
    x188_i2("addq",X187Imm{51413504,0},x188_reg(3,64)),
    x188_i2("movq",X187Mem{7,0},x188_reg(9,64)),
    x188_i2("movq",x188_reg(1,64),x188_reg(8,64)),
    x188_i2("xorl",x188_reg(10,32),x188_reg(10,32)),
    x188_i2("movq",x188_reg(6,64),x188_reg(11,64)),
    # Loop: %r8=cur, %r9=e.mem, %r10=slot_ptr (0=root), %r11=rem_fuel, %rbx=HEAP_OFF
    x188_label(l_loop),
    x188_i2("movabsq",X187Imm{0,leaf_hi},x188_reg(0,64)),
    x188_i2("cmpq",x188_reg(0,64),x188_reg(8,64)),
    x188_i1("je",X187Target{l_ins}),
    x188_i2("testq",x188_reg(11,64),x188_reg(11,64)),
    x188_i1("jz",X187Target{l_unch}),
    x188_i2("movq",x188_reg(8,64),x188_reg(0,64)),
    x188_i2("shrq",X187Imm{40,0},x188_reg(0,64)),
    x188_i2("cmpq",X187Imm{node_chk,0},x188_reg(0,64)),
    x188_i1("jne",X187Target{l_bail}),
    x188_i2("movq",x188_reg(8,64),x188_reg(0,64)),
    x188_i2("shlq",X187Imm{24,0},x188_reg(0,64)),
    x188_i2("shrq",X187Imm{24,0},x188_reg(0,64)),
    x188_i2("cmpq",x188_reg(3,64),x188_reg(0,64)),
    x188_i1("jb",X187Target{l_bail}),
    x188_i2("leaq",X187Indexed{9,0,8,0},x188_reg(10,64)),
    x188_i2("movl",X187Mem{10,8},x188_reg(0,32)),
    x188_i2("cmpl",x188_reg(0,32),x188_reg(2,32)),
    x188_i1("jb",X187Target{l_left}),
    x188_i2("addq",X187Imm{16,0},x188_reg(10,64)),
    x188_label(l_left),
    x188_i2("movq",X187Mem{10,0},x188_reg(8,64)),
    x188_i2("subq",X187Imm{1,0},x188_reg(11,64)),
    x188_i1("jmp",X187Target{l_loop}),
    # Return tree unchanged (fuel == 0 before reaching Leaf)
    x188_label(l_unch),
    x188_i2("movq",x188_reg(1,64),x188_reg(0,64)),
    x188_i1("popq",x188_reg(3,64)),
    x188_i0("ret"),
    # Insert new Node{Leaf, x, Leaf} from class-2 freelist
    x188_label(l_ins),
    x188_i2("movq",X187Mem{7,8},x188_reg(0,64)),
    x188_i2("movq",X187Mem{0,16},x188_reg(11,64)),
    x188_i2("testq",x188_reg(11,64),x188_reg(11,64)),
    x188_i1("jz",X187Target{l_bail}),
    x188_i2("leaq",X187Indexed{9,11,8,0},x188_reg(8,64)),
    x188_i2("movq",X187Mem{8,0},x188_reg(9,64)),
    x188_i2("movq",x188_reg(9,64),X187Mem{0,16}),
    x188_i2("subq",X187Imm{4,0},X187Mem{0,272}),
    x188_i2("movabsq",X187Imm{0,leaf_hi},x188_reg(0,64)),
    x188_i2("movq",x188_reg(0,64),X187Mem{8,0}),
    x188_i2("movl",x188_reg(2,32),x188_reg(2,32)),
    x188_i2("movq",x188_reg(2,64),X187Mem{8,8}),
    x188_i2("movq",x188_reg(0,64),X187Mem{8,16}),
    x188_i2("movabsq",X187Imm{0,node_hi},x188_reg(0,64)),
    x188_i2("orq",x188_reg(11,64),x188_reg(0,64)),
    x188_i2("testq",x188_reg(10,64),x188_reg(10,64)),
    x188_i1("jz",X187Target{l_ret}),
    x188_i2("movq",x188_reg(0,64),X187Mem{10,0}),
    x188_i2("movq",x188_reg(1,64),x188_reg(0,64)),
    x188_label(l_ret),
    x188_i1("popq",x188_reg(3,64)),
    x188_i0("ret"),
    # Clean bailout (zero heap mutations occurred; %rdi,%rsi,%rdx,%rcx intact!)
    x188_label(l_bail),
    x188_i1("popq",x188_reg(3,64)),
    x188_i1("jmp",X187Target{slow})])

@unsafe
def agy_zip_emit_wrapper(+symbol: String, +slow: String, leaf_cid: U32, node_cid: U32) -> X181Output:
  X181Output{[x188_many([
    X188One{PSection{1}},X188One{PGlobal{symbol}},X188One{PType{symbol,2}},X188One{PLabel{symbol}},
    agy_zip_machine(".Lagy_zip_" ++ symbol,slow,leaf_cid,node_cid),
    X188One{PSize{symbol}}])],""}

@unsafe
def agy_zip_wrap_direct(+name: String, +symbol: String, +ids: N111Ids, +orig: X181Output, +entry: KDef) -> X181Output:
  +leaf_id = x198pw_cid(nm(dt(entry)),ids)
  +node_id = x198pw_cid(nm(dv(entry)),ids)
  +slow = "agy_zip_slow_" ++ symbol
  nt_choose(X181Output,String.eq(dk(entry),"AgyZipCertified") &&
      x198pw_has_cid(leaf_id,0) && x198pw_has_cid(node_id,3) && U32.is_ne(da(leaf_id),da(node_id)),
    u => x181_program_join(agy_zip_emit_wrapper(symbol,slow,da(leaf_id),da(node_id)),orig),
    u => orig)

@unsafe
def agy_zip_target_sym(+name: String, +symbol: String, +ids: N111Ids) -> String:
  +entry = agy_zip_get_mark(name,ids)
  +leaf_id = x198pw_cid(nm(dt(entry)),ids)
  +node_id = x198pw_cid(nm(dv(entry)),ids)
  nt_choose(String,String.eq(dk(entry),"AgyZipCertified") &&
      x198pw_has_cid(leaf_id,0) && x198pw_has_cid(node_id,3) && U32.is_ne(da(leaf_id),da(node_id)),
    u => "agy_zip_slow_" ++ symbol,
    u => symbol)
"""

OLD_DIRECT = """@unsafe
def x181_direct(function,ids):
  match function:
    case P113DFunction{+name,+params,+result,public,+body}:
      +names : List<&2,String> = Con{"state",nt_choose(List<&2,String>,U32.is_eq(result,1),u => x181_param_names(params),u => Con{"__x181_result_out",x181_param_names(params)})}
      +error = p111_first(x181_hygiene_names(x181_param_names(params)),x181_hygiene_stmts(body))
      nt_choose(X181Output,String.is_empty(error),u =>
        nt_choose(X181Output,x198n_enabled() && U32.is_eq(result,1) && U32.is_le(nt_count(NC_Binding,params),8) && x185_late_enabled() && p114t_names(names) && p114t_body_names(body),v =>
          x198n_late(p113e_symbol(name),names,params,ids,x185_late_stmts(body,ids,0)),v =>
          x181_function(p113e_symbol(name),names,body,ids)),u => X181Output{[],error})"""

NEW_DIRECT = """law agy_zip_target_sym:
  for +name: String
  for +symbol: String
  for +ids: N111Ids
  String

law agy_zip_wrap_direct:
  for +name: String
  for +symbol: String
  for +ids: N111Ids
  for +orig: X181Output
  for +entry: KDef
  X181Output

law agy_zip_get_mark:
  for name: String
  for ids: N111Ids
  KDef

@unsafe
def x181_direct(function,ids):
  match function:
    case P113DFunction{+name,+params,+result,public,+body}:
      +names : List<&2,String> = Con{"state",nt_choose(List<&2,String>,U32.is_eq(result,1),u => x181_param_names(params),u => Con{"__x181_result_out",x181_param_names(params)})}
      +error = p111_first(x181_hygiene_names(x181_param_names(params)),x181_hygiene_stmts(body))
      +sym = p113e_symbol(name)
      +emit_sym = nt_choose(String,U32.is_eq(result,1) && U32.is_eq(nt_count(NC_Binding,params),3),
        u => agy_zip_target_sym(name,sym,ids),u => sym)
      +core = nt_choose(X181Output,String.is_empty(error),u =>
        nt_choose(X181Output,x198n_enabled() && U32.is_eq(result,1) && U32.is_le(nt_count(NC_Binding,params),8) && x185_late_enabled() && p114t_names(names) && p114t_body_names(body),v =>
          x198n_late(emit_sym,names,params,ids,x185_late_stmts(body,ids,0)),v =>
          x181_function(emit_sym,names,body,ids)),u => X181Output{[],error})
      nt_choose(X181Output,String.is_empty(error) && U32.is_eq(result,1) && U32.is_eq(nt_count(NC_Binding,params),3),
        u => agy_zip_wrap_direct(name,sym,ids,core,agy_zip_get_mark(name,ids)),u => core)"""

OLD_ANNOTATE_CALL = "nt_choose(P169Prepared,String.is_empty(error),u => x198pw_annotate(r,prepared),u => prepared)"
NEW_ANNOTATE_CALL = "nt_choose(P169Prepared,String.is_empty(error),u => agy_zip_annotate(r,x198pw_annotate(r,prepared)),u => prepared)"

def once(s: str, old: str, new: str, label: str) -> str:
    n = s.count(old)
    assert n == 1, f"{label}: expected 1 match, got {n}"
    return s.replace(old, new, 1)

def patch(text: str) -> str:
    text = once(text, OLD_DIRECT, NEW_DIRECT, "OLD_DIRECT")
    anchor = "@unsafe\ndef x198pw_annotate("
    zip_code = ZIPPER_CODE.replace(
        "def agy_zip_get_mark(name: String, ids: N111Ids) -> KDef:",
        "def agy_zip_get_mark(name,ids):",
    ).replace(
        "def agy_zip_wrap_direct(+name: String, +symbol: String, +ids: N111Ids, +orig: X181Output, +entry: KDef) -> X181Output:",
        "def agy_zip_wrap_direct(name,symbol,ids,orig,entry):",
    ).replace(
        "def agy_zip_target_sym(+name: String, +symbol: String, +ids: N111Ids) -> String:",
        "def agy_zip_target_sym(name,symbol,ids):",
    )
    text = once(text, anchor, zip_code + "\n\n" + anchor, "insert ZIPPER_CODE")
    text = once(text, OLD_ANNOTATE_CALL, NEW_ANNOTATE_CALL, "OLD_ANNOTATE_CALL")
    return text

def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--src", type=Path, default=DEFAULT_SRC)
    ap.add_argument("--dst", type=Path, default=DEFAULT_DST)
    a = ap.parse_args()
    out = patch(a.src.read_text())
    a.dst.parent.mkdir(parents=True, exist_ok=True)
    a.dst.write_text(out)
    print(f"Patched AGY-W2B-3 (certified BST zipper) -> {a.dst} ({len(out)} bytes)")

if __name__ == "__main__":
    main()
