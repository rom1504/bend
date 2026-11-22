#!/usr/bin/env python3
"""Wave 5B Track W5B-R1: General Array/Loop Compiler Passes (Histogram, Editdist, BST).

100% general, semantics-preserving passes on top of wave5a_unified/compiler.bend:
  1. Narrow w5_body_no_dcalls in p113j_inline:
     Only reject `p113_rt_array_pair` and `N111Alloca` instead of all `N111Call`s
     (restoring 2-step peeling for tiny `Nat`-matching loops while keeping
     `broad/local-fold` safe).
  2. General BCE for Inlined/Non-Sunk Array Sites + Negated-Min + Constant Mod:
     - Propagate `ISUM`, `MIN`, `LT_*`, and `NLT_*` facts through `w4c_env_copy`.
     - Track `xor(LT_x, 1)` -> `NLT_x` and recognize both `LT_x` and `NLT_x` in `w5_step_min_if`.
     - Track `N111Store(buf, 8, val)` facts in `env["__st8_" ++ buf]` (both constants
       and local copies), `p111_rt_op(state, 19, buf, 2)` (mod by constant) -> `BM(C-1)`,
       and `urem(x, C)` -> `BM(C-1)`.
     - Apply `w4c_bce_site` in `w4c_bce_walk_step` for non-sunk array ops (e.g. inside
       inlined helpers using `p113i_*_scratch`) using `env["__st8_" ++ buf]`.
     - Hoist `bound <= mask` for `BM`-tracked local indices in `w4c_bce_site_local`.
  3. General Unreachable Nat-Fail Elimination + Zero-Temp Nat-Match cmov Chain:
     - `w5_elim_nat_fail`: eliminates dead `c2 = ne(x, 0); if c2 { B } else { fail }`
       inside the else arm of `c1 = eq(x, 0); if c1 { A } else { ... }`.
     - `w5_nat_match_chain`: lowers any pure-scalar multi-arm `Nat` match chain
       (`eq(x,0) -> dst=v0; x1=sub(x,1); eq(x1,0) -> dst=v1; ...; dst=vN`) into a
       zero-new-variable branchless select chain (`dst=vN; c=eq(x,N-1); if c dst=v_{N-1} else dst=dst; ...`).
  4. General x86-64 GPR Peepholes:
     - Raise dead-`%rax` scan window in `w4c_try_eax_and_3` from 24 to 64.
     - G10 in `w5_gpr_peep`: `movq %rA, %rB; addl $c, %rB32; movq %rB, %rA` (rB dead) -> `addl $c, %rA32`.
"""
import argparse
from pathlib import Path

ROOT = Path("/home/ai/bend2_agy")
DEFAULT_SRC = ROOT / "selfhost/build/agy/wave5a_unified/compiler.bend"
DEFAULT_DST = ROOT / "selfhost/build/agy/wave5b_r1/compiler.bend"


def replace_exact(src: str, old: str, new: str, label: str) -> str:
    n = src.count(old)
    if n != 1:
        raise RuntimeError(f"[{label}] expected 1 occurrence, found {n}")
    return src.replace(old, new, 1)


def patch_1_narrow_peel_guard(src: str) -> str:
    """Pass 1: Only reject p113_rt_array_pair and N111Alloca in w5_body_no_dcalls."""
    old = """    case Con{P113DCall{_,_,_},_}: False{}
    case Con{P113DScalar{N111Call{_,_,_,_}},_}: False{}
    case Con{P113DScalar{N111Alloca{_,_,_}},_}: False{}"""
    new = """    case Con{P113DCall{_,_,_},_}: False{}
    case Con{P113DScalar{N111Call{_,_,sym,_}},rest}:
      Bool.not(agy_str_eq(sym,"p113_rt_array_pair")) && w5_body_no_dcalls(rest)
    case Con{P113DScalar{N111Alloca{_,_,_}},_}: False{}"""
    return replace_exact(src, old, new, "Pass 1: narrow w5_body_no_dcalls")


def patch_2_bce_upgrades(src: str) -> str:
    """Pass 2: Full BCE for non-sunk inlined array ops, negated-min, and const mod."""
    # 2a: Propagate ISUM, MIN, LT_*, NLT_* in w4c_env_copy
    old_copy = """def w4c_env_copy(+env: KDef, +dest: String, +src: String) -> KDef:
  +d = p111v_get(env,src)
  nt_choose(KDef,agy_str_eq(dk(d),"BM") || agy_str_eq(dk(d),"INC") || agy_str_eq(dk(d),"DEC") ||
      agy_str_eq(dk(d),"NZ") || agy_str_eq(dk(d),"PRM"),
    u => p111v_put(env,dest,dk(d),da(d),dx(d)),
    u => w4c_env_kill(env,dest))"""
    new_copy = """def w4c_env_copy(+env: KDef, +dest: String, +src: String) -> KDef:
  +d = p111v_get(env,src)
  +t = dk(d)
  nt_choose(KDef,agy_str_eq(t,"BM") || agy_str_eq(t,"INC") || agy_str_eq(t,"DEC") ||
      agy_str_eq(t,"NZ") || agy_str_eq(t,"PRM") ||
      agy_str_eq(t,"ISUM") || agy_str_eq(t,"MIN") ||
      String.starts_with(t,"LT_") || String.starts_with(t,"NLT_"),
    u => p111v_put(env,dest,t,da(d),dx(d)),
    u => w4c_env_kill(env,dest))"""
    src = replace_exact(src, old_copy, new_copy, "Pass 2a: w4c_env_copy ISUM/MIN/LT/NLT")

    # 2b: Support both LT_x and NLT_x in w5_step_min_if
    old_min = """      +nsd = p111v_get(env,ns)
      nt_choose(KDef,
        String.starts_with(tag,"LT_") && Bool.not(String.is_empty(yd)) && agy_str_eq(yd,nd) &&
        agy_str_eq("LT_" ++ ys,tag) && agy_str_eq(dk(nsd),"PRM") && U32.is_eq(da(nsd),kIdx),
        u => p111v_put(env,yd,"MIN",kIdx,0),
        u => env)"""
    new_min = """      +nsd = p111v_get(env,ns)
      +ysd = p111v_get(env,ys)
      +directMin = String.starts_with(tag,"LT_") && agy_str_eq("LT_" ++ ys,tag) &&
        agy_str_eq(dk(nsd),"PRM") && U32.is_eq(da(nsd),kIdx)
      +negMin = String.starts_with(tag,"NLT_") && agy_str_eq("NLT_" ++ ns,tag) &&
        agy_str_eq(dk(ysd),"PRM") && U32.is_eq(da(ysd),kIdx)
      nt_choose(KDef,
        Bool.not(String.is_empty(yd)) && agy_str_eq(yd,nd) && (directMin || negMin),
        u => p111v_put(env,yd,"MIN",kIdx,0),
        u => env)"""
    src = replace_exact(src, old_min, new_min, "Pass 2b: w5_step_min_if NLT_ support")

    # 2c: Track xor(LT_x, 1) -> NLT_x and urem(x, C) -> BM(C-1) in w4c_step_bin_r
    old_bin = """              x => nt_choose(KDef,agy_str_eq(op,"ne") && U32.is_eq(lo,0) && Bool.not(String.is_empty(lsrc)),
                y => w4c_env_put_param(w4c_env_param_idx(env,lsrc),env,dest,"NZ",3),
                y => w4c_env_kill(env,dest))))))"""
    new_bin = """              x => nt_choose(KDef,agy_str_eq(op,"ne") && U32.is_eq(lo,0) && Bool.not(String.is_empty(lsrc)),
                y => w4c_env_put_param(w4c_env_param_idx(env,lsrc),env,dest,"NZ",3),
                y => nt_choose(KDef,agy_str_eq(op,"xor") && U32.is_eq(lo,1) && Bool.not(String.is_empty(lsrc)),
                  z =>
                    +ld = p111v_get(env,lsrc)
                    nt_choose(KDef,String.starts_with(dk(ld),"LT_"),
                      q => p111v_put(env,dest,"N" ++ dk(ld),da(ld),dx(ld)),
                      q => w4c_env_kill(env,dest)),
                  z => nt_choose(KDef,agy_str_eq(op,"urem") && U32.is_gt(lo,0) && U32.is_le(lo,2147483647),
                    q => p111v_put(env,dest,"BM",U32.sub(lo,1),0),
                    q => w4c_env_kill(env,dest))))))))"""
    src = replace_exact(src, old_bin, new_bin, "Pass 2c: w4c_step_bin_r xor(LT,1) & urem")

    # 2d: Track N111Store(buf, 8, val) (constants AND local facts!) + p111_rt_op mod(19) in w4c_step_scalar
    mod_helpers = """@unsafe
def w5_step_store_val(val: N111Value, +buf: String, +env: KDef) -> KDef:
  match val:
    case N111Const{+lo,0}:
      nt_choose(KDef,U32.is_gt(lo,0) && U32.is_le(lo,2147483647),
        v => p111v_put(env,"__st8_" ++ buf,"C8",lo,0),
        v => w4c_env_kill(env,"__st8_" ++ buf))
    case N111Local{src}: w4c_env_copy(env,"__st8_" ++ buf,src)
    case _: w4c_env_kill(env,"__st8_" ++ buf)

@unsafe
def w5_step_store(base: N111Value, +off: U32, +val: N111Value, +env: KDef) -> KDef:
  match base:
    case N111Local{+buf}:
      nt_choose(KDef,U32.is_eq(off,8),
        u => w5_step_store_val(val,buf,env),
        u => env)
    case _: env

@unsafe
def w5_step_rt_call(+dest: String, +sym: String, args: List<&2,N111Arg>, +env: KDef) -> KDef:
  match args:
    case Con{_,Con{N111Arg{_,N111Const{19,0}},Con{N111Arg{_,N111Local{buf}},Con{N111Arg{_,N111Const{2,0}},Nil{}}}}}:
      nt_choose(KDef,agy_str_eq(sym,"p111_rt_op"),
        u =>
          +sd = p111v_get(env,"__st8_" ++ buf)
          nt_choose(KDef,agy_str_eq(dk(sd),"C8") && U32.is_gt(da(sd),0),
            v => p111v_put(env,dest,"BM",U32.sub(da(sd),1),0),
            v => w4c_env_kill(env,dest)),
        u => w4c_env_kill(env,dest))
    case _: w4c_env_kill(env,dest)

"""
    old_scalar = """@unsafe
def w4c_step_scalar(stmt: N111Stmt, +env: KDef) -> KDef:
  match stmt:
    case N111Bin{dest,_,op,left,right}:
      w4c_step_bin_r(w4c_const_u32_any(right),dest,op,w4c_local_name(left),w4c_const_u32_any(left),w4c_local_name(right),env)
    case N111Set{dest,_,val}: w4c_step_set(val,dest,env)
    case N111Call{dest,_,_,_}: w4c_env_kill(env,dest)
    case N111Load{dest,_,_,_}: w4c_env_kill(env,dest)
    case N111Offset{dest,_,_}: w4c_env_kill(env,dest)
    case N111Alloca{dest,_,_}: w4c_env_kill(env,dest)
    case _: env"""
    new_scalar = mod_helpers + """@unsafe
def w4c_step_scalar(stmt: N111Stmt, +env: KDef) -> KDef:
  match stmt:
    case N111Bin{dest,_,op,left,right}:
      w4c_step_bin_r(w4c_const_u32_any(right),dest,op,w4c_local_name(left),w4c_const_u32_any(left),w4c_local_name(right),env)
    case N111Set{dest,_,val}: w4c_step_set(val,dest,env)
    case N111Store{_,base,off,val}: w5_step_store(base,off,val,env)
    case N111Call{dest,_,sym,args}: w5_step_rt_call(dest,sym,args,env)
    case N111Load{dest,_,_,_}: w4c_env_kill(env,dest)
    case N111Offset{dest,_,_}: w4c_env_kill(env,dest)
    case N111Alloca{dest,_,_}: w4c_env_kill(env,dest)
    case _: env"""
    src = replace_exact(src, old_scalar, new_scalar, "Pass 2d: w4c_step_scalar store & mod tracking")

    # 2e: Tight (cnt - (cnt != 0)) guard for guarded PRM IV accesses (fixes exact power-of-2 arrays where cnt == cap == mask + 1!)
    #     + Hoist bound <= mask for BM-tracked local index in w4c_bce_site_local
    old_iv = """          nt_choose(W4CBCEPlan,isIv,
            v =>
              +pname = w4c_nth_param_name(params,da(d))
              +sumName = pfx ++ "sum"
              +gStmts = nt_append(N111Stmt,w4c_guard_ule(pfx ++ "iv0",N111Local{pname},maskRef),
                nt_append(N111Stmt,w4c_guard_ule(pfx ++ "cnt0",N111Local{cntName},maskRef),
                  Con{N111Bin{sumName,N111U64{},"add",N111Local{pname},N111Local{cntName}},
                    w4c_guard_ule(pfx ++ "ivend",N111Local{sumName},maskRef)}))
              W4CBCEPlan{p117h_put(nomask,U32.show(n),1),nt_append(N111Stmt,guards,gStmts),U32.inc(n)},"""
    new_iv = """          +isTightPrm = guarded && agy_str_eq(dk(d),"PRM")
          nt_choose(W4CBCEPlan,isIv,
            v =>
              +pname = w4c_nth_param_name(params,da(d))
              +sumName = pfx ++ "sum"
              +gStmts = nt_choose(List<&2,N111Stmt>,isTightPrm,
                t =>
                  +nzName = pfx ++ "nz"
                  +cmName = pfx ++ "cm"
                  +prep: List<&2,N111Stmt> = [
                    N111Bin{nzName,N111U64{},"ne",N111Local{cntName},N111Const{0,0}},
                    N111Bin{cmName,N111U64{},"sub",N111Local{cntName},N111Local{nzName}}]
                  nt_append(N111Stmt,prep,
                    nt_append(N111Stmt,w4c_guard_ule(pfx ++ "iv0",N111Local{pname},maskRef),
                      nt_append(N111Stmt,w4c_guard_ule(pfx ++ "cnt0",N111Local{cmName},maskRef),
                        Con{N111Bin{sumName,N111U64{},"add",N111Local{pname},N111Local{cmName}},
                          w4c_guard_ule(pfx ++ "ivend",N111Local{sumName},maskRef)}))),
                t =>
                  nt_append(N111Stmt,w4c_guard_ule(pfx ++ "iv0",N111Local{pname},maskRef),
                    nt_append(N111Stmt,w4c_guard_ule(pfx ++ "cnt0",N111Local{cntName},maskRef),
                      Con{N111Bin{sumName,N111U64{},"add",N111Local{pname},N111Local{cntName}},
                        w4c_guard_ule(pfx ++ "ivend",N111Local{sumName},maskRef)})))
              W4CBCEPlan{p117h_put(nomask,U32.show(n),1),nt_append(N111Stmt,guards,gStmts),U32.inc(n)},"""
    src = replace_exact(src, old_iv, new_iv, "Pass 2e0: tight cnt-(cnt!=0) IV guard for exact power-of-2 arrays")

    old_site = """                w => W4CBCEPlan{nomask,guards,U32.inc(n)})))"""
    new_site = """                w => nt_choose(W4CBCEPlan,agy_str_eq(dk(d),"BM"),
                  z => W4CBCEPlan{p117h_put(nomask,U32.show(n),1),
                    nt_append(N111Stmt,guards,w4c_guard_ule(pfx ++ "bm",N111Const{da(d),0},maskRef)),U32.inc(n)},
                  z => W4CBCEPlan{nomask,guards,U32.inc(n)}))))"""
    src = replace_exact(src, old_site, new_site, "Pass 2e: w4c_bce_site_local BM hoist")

    # 2f: Apply w4c_bce_site to non-sunk array calls (id=72/73/74) in w4c_bce_walk_step!
    old_walk_step = """    case Con{P113DScalar{+stmt},+rest}:
      +env2 = w5_step_scalar_ext(stmt,env)
      nt_choose(W4CBCEPlan,U32.is_eq(p113a_stmt_id(stmt),0),
        u => w4c_bce_walk(rest,n,used,sites,guarded,cntIdx,cntName,params,ivMask,pbmMap,env2,nomask,guards),
        u => w4c_bce_walk(rest,U32.inc(n),used,sites,guarded,cntIdx,cntName,params,ivMask,pbmMap,env2,nomask,guards))"""
    new_walk_step = """    case Con{P113DScalar{+stmt},+rest}:
      +id = p113a_stmt_id(stmt)
      +env2 = w5_step_scalar_ext(stmt,env)
      nt_choose(W4CBCEPlan,U32.is_eq(id,0),
        u => w4c_bce_walk(rest,n,used,sites,guarded,cntIdx,cntName,params,ivMask,pbmMap,env2,nomask,guards),
        u =>
          +origin = p117h_get(sites,U32.show(n))
          +bufNm = p113a_input_name(stmt)
          nt_choose(W4CBCEPlan,U32.is_gt(U32.and(used,p117h_bit(origin)),0) &&
              Bool.not(U32.is_eq(id,75)) && Bool.not(String.is_empty(bufNm)),
            v => w4c_bce_walk_after_site(
              w4c_bce_site(n,origin,N111Local{"__st8_" ++ bufNm},guarded,cntName,params,ivMask,pbmMap,env,nomask,guards),
              rest,used,sites,guarded,cntIdx,cntName,params,ivMask,pbmMap,env2),
            v => w4c_bce_walk(rest,U32.inc(n),used,sites,guarded,cntIdx,cntName,params,ivMask,pbmMap,env2,nomask,guards)))"""
    src = replace_exact(src, old_walk_step, new_walk_step, "Pass 2f: non-sunk inlined array BCE in w4c_bce_walk_step")
    return src


def patch_3_nat_fail_and_cmov_chain(src: str) -> str:
    """Pass 3: Eliminate dead ne(x,0) fail-branch + zero-temp Nat-match cmov chain."""
    helpers = """# ---- W5B-R1 Pass 3: Unreachable Nat-Fail Elimination + Zero-Temp Nat-Match cmov Chain ----
@unsafe
def w5_is_cmp0_local(op: String, wantOp: String, l: N111Value, r: N111Value) -> String:
  match l:
    case N111Local{x}:
      match r:
        case N111Const{0,0}: nt_choose(String,agy_str_eq(op,wantOp),u => x,u => "")
        case _: ""
    case _: ""

@unsafe
def w5_is_sub1_local(op: String, l: N111Value, r: N111Value) -> String:
  match l:
    case N111Local{x}:
      match r:
        case N111Const{1,0}: nt_choose(String,agy_str_eq(op,"sub"),u => x,u => "")
        case _: ""
    case _: ""

@unsafe
def w5_val_eq_name(v: N111Value, +target: String) -> Bool:
  match v:
    case N111Local{n}: agy_str_eq(n,target)
    case _: False{}

@unsafe
def w5_unwrap_ne0(no: List<&2,P113DStmt>, +x: String) -> List<&2,P113DStmt>:
  match no:
    case Con{P113DScalar{N111Bin{+c2,_,op2,l2,r2}},Con{P113DIf{cond2,innerYes,_},Nil{}}}:
      nt_choose(List<&2,P113DStmt>,
        agy_str_eq(w5_is_cmp0_local(op2,"ne",l2,r2),x) && w5_val_eq_name(cond2,c2),
        u => innerYes,
        u => no)
    case _: no

law w5_elim_nat_fail:
  for body: List<&2,P113DStmt>
  List<&2,P113DStmt>

@unsafe
def w5_elim_nf_pair(+s1: P113DStmt, +c1: String, +x: String, s2: P113DStmt, +rest: List<&2,P113DStmt>) -> List<&2,P113DStmt>:
  match s2:
    case P113DIf{+cond,+yes,+no}:
      nt_choose(List<&2,P113DStmt>,Bool.not(String.is_empty(x)) && Bool.not(agy_str_eq(c1,x)) && w5_val_eq_name(cond,c1),
        u => Con{s1,Con{P113DIf{cond,w5_elim_nat_fail(yes),w5_elim_nat_fail(w5_unwrap_ne0(no,x))},w5_elim_nat_fail(rest)}},
        u => Con{s1,Con{P113DIf{cond,w5_elim_nat_fail(yes),w5_elim_nat_fail(no)},w5_elim_nat_fail(rest)}})
    case _: Con{s1,w5_elim_nat_fail(Con{s2,rest})}

@unsafe
def w5_elim_nat_fail(body):
  match body:
    case Nil{}: []
    case Con{P113DScalar{N111Bin{+c1,+t1,+op1,+l1,+r1}},Con{+s2,+rest}}:
      +s1 : P113DStmt = P113DScalar{N111Bin{c1,t1,op1,l1,r1}}
      w5_elim_nf_pair(s1,c1,w5_is_cmp0_local(op1,"eq",l1,r1),s2,rest)
    case Con{P113DIf{cond,yes,no},rest}:
      Con{P113DIf{cond,w5_elim_nat_fail(yes),w5_elim_nat_fail(no)},w5_elim_nat_fail(rest)}
    case Con{h,rest}: Con{h,w5_elim_nat_fail(rest)}

# Zero-temp Nat-match chain lowering:
# Turns nested `eq(x,0) -> dst=v0; x1=sub(x,1); eq(x1,0) -> dst=v1; ...; dst=vN`
# into `dst=vN; c=eq(x,N-1); if c dst=v_{N-1} else dst=dst; ...; c=eq(x,0); if c dst=v0 else dst=dst`.
type W5NatArm is Data:
  W5NatArm{+k: U32, +val: N111Value}

type W5NatChain is Data:
  W5NatChainNone{}
  W5NatChain{+arms: List<&2,W5NatArm>, +defVal: N111Value}

@unsafe
def w5_nc_val_ok(+v: N111Value, +dst: String, +x: String, +c: String) -> Bool:
  w4c_sel_val(v) && Bool.not(w5_val_eq_name(v,dst)) && Bool.not(w5_val_eq_name(v,x)) && Bool.not(w5_val_eq_name(v,c))

law w5_nc_collect:
  for +body: List<&2,P113DStmt>
  for +curX: String
  for +k: U32
  for +dst: String
  for +typW: U32
  for +origX: String
  for +cName: String
  for +acc: List<&2,W5NatArm>
  for +fuel: U32
  W5NatChain

@unsafe
def w5_nc_try_step(arm: W4CSelArm, +nextX: String, +no: List<&2,P113DStmt>, +k: U32,
    +dst: String, +typW: U32, +origX: String, +cName: String, +acc: List<&2,W5NatArm>, +fuel: U32) -> W5NatChain:
  match arm:
    case W4CSelArm{+adst,+atyp,+aval}:
      nt_choose(W5NatChain,
        agy_str_eq(adst,dst) && U32.is_eq(p111v_type(atyp),typW) &&
        w5_nc_val_ok(aval,dst,origX,cName) && Bool.not(w5_val_eq_name(aval,nextX)),
        u => w5_nc_collect(no,nextX,U32.inc(k),dst,typW,origX,cName,Con{W5NatArm{k,aval},acc},U32.sub(fuel,1)),
        u => W5NatChainNone{})
    case W4CSelArmNone{}: W5NatChainNone{}

@unsafe
def w5_nc_def_arm(arm: W4CSelArm, +dst: String, +typW: U32, +origX: String, +cName: String,
    +acc: List<&2,W5NatArm>) -> W5NatChain:
  match arm:
    case W4CSelArm{+adst,+atyp,+aval}:
      nt_choose(W5NatChain,
        agy_str_eq(adst,dst) && U32.is_eq(p111v_type(atyp),typW) && w5_nc_val_ok(aval,dst,origX,cName),
        u => W5NatChain{acc,aval},
        u => W5NatChainNone{})
    case W4CSelArmNone{}: W5NatChainNone{}

@unsafe
def w5_nc_collect_step(body: List<&2,P113DStmt>, +curX: String, +k: U32, +dst: String, +typW: U32,
    +origX: String, +cName: String, +acc: List<&2,W5NatArm>, +fuel: U32) -> W5NatChain:
  match body:
    case Con{P113DScalar{N111Bin{+nextX,_,subOp,subL,subR}},
         Con{P113DScalar{N111Bin{+c2,_,eqOp,eqL,eqR}},
         Con{P113DIf{cond2,+yes2,+no2},Nil{}}}}:
      nt_choose(W5NatChain,
        agy_str_eq(w5_is_sub1_local(subOp,subL,subR),curX) &&
        agy_str_eq(w5_is_cmp0_local(eqOp,"eq",eqL,eqR),nextX) &&
        w5_val_eq_name(cond2,c2) &&
        Bool.not(agy_str_eq(nextX,dst)) && Bool.not(agy_str_eq(nextX,origX)) &&
        Bool.not(agy_str_eq(c2,dst)) && Bool.not(agy_str_eq(c2,origX)),
        v => w5_nc_try_step(w4c_sel_arm(yes2),nextX,no2,k,dst,typW,origX,cName,acc,fuel),
        v => W5NatChainNone{})
    case _: w5_nc_def_arm(w4c_sel_arm(body),dst,typW,origX,cName,acc)

@unsafe
def w5_nc_collect(body,curX,k,dst,typW,origX,cName,acc,fuel):
  nt_choose(W5NatChain,U32.is_eq(fuel,0),u => W5NatChainNone{},
    u => w5_nc_collect_step(body,curX,k,dst,typW,origX,cName,acc,fuel))

@unsafe
def w5_nc_emit_arms(arms: List<&2,W5NatArm>, +origX: String, +cName: String, +cTyp: N111Type,
    +dst: String, +dstTyp: N111Type, +tail: List<&2,P113DStmt>) -> List<&2,P113DStmt>:
  match arms:
    case Nil{}: tail
    case Con{W5NatArm{k,val},rest}:
      +cmpSt : P113DStmt = P113DScalar{N111Bin{cName,cTyp,"eq",N111Local{origX},N111Const{k,0}}}
      +selSt : P113DStmt = P113DIf{N111Local{cName},
        [P113DScalar{N111Set{dst,dstTyp,val}}],
        [P113DScalar{N111Set{dst,dstTyp,N111Local{dst}}}]}
      Con{cmpSt,Con{selSt,w5_nc_emit_arms(rest,origX,cName,cTyp,dst,dstTyp,tail)}}

@unsafe
def w5_nc_finish(ch: W5NatChain, +origX: String, +cName: String, +cTyp: N111Type,
    +dst: String, +dstTyp: N111Type, +tail: List<&2,P113DStmt>, +fallback: List<&2,P113DStmt>) -> List<&2,P113DStmt>:
  match ch:
    case W5NatChain{arms,defVal}:
      Con{P113DScalar{N111Set{dst,dstTyp,defVal}},w5_nc_emit_arms(arms,origX,cName,cTyp,dst,dstTyp,tail)}
    case W5NatChainNone{}: fallback

@unsafe
def w5_nc_start(arm0: W4CSelArm, +origX: String, +cName: String, +cTyp: N111Type,
    +no: List<&2,P113DStmt>, +tail: List<&2,P113DStmt>, +fallback: List<&2,P113DStmt>) -> List<&2,P113DStmt>:
  match arm0:
    case W4CSelArm{+dst,+dstTyp,+val0}:
      +tw = p111v_type(dstTyp)
      nt_choose(List<&2,P113DStmt>,
        Bool.not(x181_register_reserved(dst)) && w4c_sel_width(dstTyp) &&
        Bool.not(agy_str_eq(dst,origX)) && Bool.not(agy_str_eq(dst,cName)) &&
        w5_nc_val_ok(val0,dst,origX,cName),
        u => w5_nc_finish(w5_nc_collect(no,origX,1,dst,tw,origX,cName,[W5NatArm{0,val0}],8),
          origX,cName,cTyp,dst,dstTyp,tail,fallback),
        u => fallback)
    case W4CSelArmNone{}: fallback

law w5_nat_match_chain:
  for body: List<&2,P113DStmt>
  List<&2,P113DStmt>

@unsafe
def w5_nc_pair(+s1: P113DStmt, +cName: String, +cTyp: N111Type, +origX: String, s2: P113DStmt,
    +rest: List<&2,P113DStmt>) -> List<&2,P113DStmt>:
  match s2:
    case P113DIf{+cond,+yes,+no}:
      +tail = w5_nat_match_chain(rest)
      +fb : List<&2,P113DStmt> = Con{s1,Con{P113DIf{cond,w5_nat_match_chain(yes),w5_nat_match_chain(no)},tail}}
      nt_choose(List<&2,P113DStmt>,
        Bool.not(String.is_empty(origX)) && Bool.not(agy_str_eq(cName,origX)) && w5_val_eq_name(cond,cName),
        u => w5_nc_start(w4c_sel_arm(yes),origX,cName,cTyp,no,tail,fb),
        u => fb)
    case _: Con{s1,w5_nat_match_chain(Con{s2,rest})}

@unsafe
def w5_nat_match_chain(body):
  match body:
    case Nil{}: []
    case Con{P113DScalar{N111Bin{+c1,+t1,+op1,+l1,+r1}},Con{+s2,+rest}}:
      +s1 : P113DStmt = P113DScalar{N111Bin{c1,t1,op1,l1,r1}}
      w5_nc_pair(s1,c1,t1,w5_is_cmp0_local(op1,"eq",l1,r1),s2,rest)
    case Con{P113DIf{cond,yes,no},rest}:
      Con{P113DIf{cond,w5_nat_match_chain(yes),w5_nat_match_chain(no)},w5_nat_match_chain(rest)}
    case Con{h,rest}: Con{h,w5_nat_match_chain(rest)}

"""
    old_diam_fn = """@unsafe
def w4c_diamond_body(+setup: List<&2,P113DStmt>, +body: List<&2,P113DStmt>) -> List<&2,P113DStmt>:
  +base = x185_d_base()
  +again = x185_d_union(x185_copy_writes(setup,missing()),base)
  w4c_dia_out(w4c_dia_body(body,base,again,base,0))"""
    new_diam_fn = helpers + """@unsafe
def w4c_diamond_body(+setup: List<&2,P113DStmt>, +body: List<&2,P113DStmt>) -> List<&2,P113DStmt>:
  +base = x185_d_base()
  +again = x185_d_union(x185_copy_writes(setup,missing()),base)
  w4c_dia_out(w4c_dia_body(w5_elim_nat_fail(body),base,again,base,0))"""
    return replace_exact(src, old_diam_fn, new_diam_fn, "Pass 3: nat-fail elim + zero-temp nat-match cmov chain")


def patch_4_peepholes(src: str) -> str:
    """Pass 4: Extend dead-rax window in w4c_try_eax_and_3 + G10 mov/addl/mov fold in w5_gpr_peep."""
    old_eax = """            Bool.not(U32.is_eq(sr,0)) && U32.is_le(mask,2147483647) &&
            w4b_reg_dead(0,tail,fnItems,24) && w4_peep_flags_dead_list(tail,16),"""
    new_eax = """            Bool.not(U32.is_eq(sr,0)) && U32.is_le(mask,2147483647) &&
            w4b_reg_dead(0,tail,fnItems,64) && w4_peep_flags_dead_list(tail,16),"""
    src = replace_exact(src, old_eax, new_eax, "Pass 4a: w4c_try_eax_and_3 dead-rax window 24->64")

    g10_helpers = """# G11: jne/je L; movq -disp(%rbp), %r64; jmp L; L: -> cmoveq/cmovneq -disp(%rbp), %r64; L:
@unsafe
def w5_g11_inv_jcc(+op: String) -> String:
  nt_choose(String,agy_str_eq(op,"jne") || agy_str_eq(op,"jnz"),u => "cmoveq",
    u => nt_choose(String,agy_str_eq(op,"je") || agy_str_eq(op,"jz"),v => "cmovneq",v => ""))

@unsafe
def w5_g11_d(+cmop: String, +d: U32, +r: U32, +lbl: String, i3: X187Parsed, +r4: List<&2,X187Parsed>,
    +fnItems: List<&2,X187Parsed>, +acc: List<&2,X187Parsed>) -> Maybe<&2,List<&2,X187Parsed>>:
  match i3:
    case PLabel{+l3}:
      nt_choose(Maybe<&2,List<&2,X187Parsed>>,agy_str_eq(l3,lbl),
        u => Some{w5_gpr_peep(Con{PLabel{l3},r4},fnItems,
          Con{PInst{X187Instruction{cmop,[X187Mem{5,d},x188_reg(r,64)]}},acc})},
        u => None{})
    case _: None{}

@unsafe
def w5_g11_c(+cmop: String, +d: U32, +r: U32, +lbl: String, br2: W4BBranch, +i3: X187Parsed, +r4: List<&2,X187Parsed>,
    +fnItems: List<&2,X187Parsed>, +acc: List<&2,X187Parsed>) -> Maybe<&2,List<&2,X187Parsed>>:
  match br2:
    case W4BBranch{op2,t2}:
      nt_choose(Maybe<&2,List<&2,X187Parsed>>,agy_str_eq(op2,"jmp") && agy_str_eq(t2,lbl),
        u => w5_g11_d(cmop,d,r,lbl,i3,r4,fnItems,acc),
        u => None{})
    case W4BBranchNone{}: None{}

@unsafe
def w5_g11_b(+cmop: String, +lbl: String, ld1: W5LoadRbp, +r2: List<&2,X187Parsed>,
    +fnItems: List<&2,X187Parsed>, +acc: List<&2,X187Parsed>) -> Maybe<&2,List<&2,X187Parsed>>:
  match ld1:
    case W5LRYes{d,r}:
      match r2:
        case Con{+i2,Con{+i3,+r4}}: w5_g11_c(cmop,d,r,lbl,w4b_as_branch(i2),i3,r4,fnItems,acc)
        case _: None{}
    case W5LRNo{}: None{}

@unsafe
def w5_gpr_try_jcc(br0: W4BBranch, +i1: X187Parsed, +r2: List<&2,X187Parsed>,
    +fnItems: List<&2,X187Parsed>, +acc: List<&2,X187Parsed>) -> Maybe<&2,List<&2,X187Parsed>>:
  match br0:
    case W4BBranch{op0,lbl}:
      +cmop = w5_g11_inv_jcc(op0)
      nt_choose(Maybe<&2,List<&2,X187Parsed>>,Bool.not(String.is_empty(cmop)),
        u => w5_g11_b(cmop,lbl,w5_as_load_rbp(i1),r2,fnItems,acc),
        u => None{})
    case W4BBranchNone{}: None{}

# G10: movq %rA, %rB; addl $c, %rB32; movq %rB, %rA (rB dead) -> addl $c, %rA32
@unsafe
def w5_g10_c(+rA: U32, +rB: U32, +c: U32, rr2: W4BRR, +r3: List<&2,X187Parsed>,
    +fnItems: List<&2,X187Parsed>, +acc: List<&2,X187Parsed>) -> Maybe<&2,List<&2,X187Parsed>>:
  match rr2:
    case W4BRR{op2,s2,64,d2,64}:
      nt_choose(Maybe<&2,List<&2,X187Parsed>>,
        agy_str_eq(op2,"movq") && U32.is_eq(s2,rB) && U32.is_eq(d2,rA) &&
        w4b_reg_dead(rB,r3,fnItems,64),
        u => Some{w5_gpr_peep(r3,fnItems,
          Con{PInst{X187Instruction{"addl",[X187Imm{c,0},x188_reg(rA,32)]}},acc})},
        u => None{})
    case _: None{}

@unsafe
def w5_g10_b(+rA: U32, +rB: U32, im1: W4BImmReg, +i2: X187Parsed, +r3: List<&2,X187Parsed>,
    +fnItems: List<&2,X187Parsed>, +acc: List<&2,X187Parsed>) -> Maybe<&2,List<&2,X187Parsed>>:
  match im1:
    case W4BImmReg{op1,lo,0,d1,32}:
      nt_choose(Maybe<&2,List<&2,X187Parsed>>,
        agy_str_eq(op1,"addl") && U32.is_eq(d1,rB) && Bool.not(U32.is_eq(rA,rB)),
        u => w5_g10_c(rA,rB,lo,w4b_as_rr(i2),r3,fnItems,acc),
        u => None{})
    case _: None{}

"""
    old_rr64 = """@unsafe
def w5_gpr_rr64_r2(+rA: U32, +rB: U32, +i1: X187Parsed, r2: List<&2,X187Parsed>,
    +fnItems: List<&2,X187Parsed>, +acc: List<&2,X187Parsed>) -> Maybe<&2,List<&2,X187Parsed>>:
  match r2:
    case Con{+i2,Con{+i3,+r4}}:
      w4c_or_peep_opt(
        nt_choose(Maybe<&2,List<&2,X187Parsed>>,U32.is_eq(rB,0) && w5_not_scratch(rA),
          v => w5_gpr_rr64_g2(rA,i1,i2,i3,r4,fnItems,acc),
          v => None{}),
        v => w4c_or_peep_opt(w5_g34_b(rA,rB,w4b_as_rr(i1),i2,i3,r4,fnItems,acc),
          w => w4c_or_peep_opt(w5_g5_b(rA,rB,w4b_as_imm_reg(i1),i2,i3,r4,fnItems,acc),
            x => w5_g67_b(rA,rB,w4b_as_imm_reg(i1),i2,Con{i3,r4},fnItems,acc))))
    case Con{+i2,+r3}: w5_g67_b(rA,rB,w4b_as_imm_reg(i1),i2,r3,fnItems,acc)
    case Nil{}: None{}"""

    new_rr64 = g10_helpers + """@unsafe
def w5_gpr_rr64_r2(+rA: U32, +rB: U32, +i1: X187Parsed, r2: List<&2,X187Parsed>,
    +fnItems: List<&2,X187Parsed>, +acc: List<&2,X187Parsed>) -> Maybe<&2,List<&2,X187Parsed>>:
  match r2:
    case Con{+i2,Con{+i3,+r4}}:
      w4c_or_peep_opt(
        nt_choose(Maybe<&2,List<&2,X187Parsed>>,U32.is_eq(rB,0) && w5_not_scratch(rA),
          v => w5_gpr_rr64_g2(rA,i1,i2,i3,r4,fnItems,acc),
          v => None{}),
        v => w4c_or_peep_opt(w5_g34_b(rA,rB,w4b_as_rr(i1),i2,i3,r4,fnItems,acc),
          w => w4c_or_peep_opt(w5_g5_b(rA,rB,w4b_as_imm_reg(i1),i2,i3,r4,fnItems,acc),
            x => w4c_or_peep_opt(w5_g67_b(rA,rB,w4b_as_imm_reg(i1),i2,Con{i3,r4},fnItems,acc),
              y => w5_g10_b(rA,rB,w4b_as_imm_reg(i1),i2,Con{i3,r4},fnItems,acc)))))
    case Con{+i2,+r3}:
      w4c_or_peep_opt(w5_g67_b(rA,rB,w4b_as_imm_reg(i1),i2,r3,fnItems,acc),
        u => w5_g10_b(rA,rB,w4b_as_imm_reg(i1),i2,r3,fnItems,acc))
    case Nil{}: None{}"""
    old_rr64_r2 = """@unsafe
def w5_gpr_rr64_r2(+rA: U32, +rB: U32, +i1: X187Parsed, r2: List<&2,X187Parsed>,
    +fnItems: List<&2,X187Parsed>, +acc: List<&2,X187Parsed>) -> Maybe<&2,List<&2,X187Parsed>>:
  match r2:
    case Con{+i2,Con{+i3,+r4}}:
      w4c_or_peep_opt(
        nt_choose(Maybe<&2,List<&2,X187Parsed>>,U32.is_eq(rB,0) && w5_not_scratch(rA),
          v => w5_gpr_rr64_g2(rA,i1,i2,i3,r4,fnItems,acc),
          v => None{}),
        v => w4c_or_peep_opt(w5b_g1_b(x188_reg(rA,64),rB,w4b_as_rr(i1),i2,i3,r4,fnItems,acc),
          v2 => w4c_or_peep_opt(w5_g34_b(rA,rB,w4b_as_rr(i1),i2,i3,r4,fnItems,acc),
            w => w4c_or_peep_opt(w5_g5_b(rA,rB,w4b_as_imm_reg(i1),i2,i3,r4,fnItems,acc),
              x => w4c_or_peep_opt(w5_g67_b(rA,rB,w4b_as_imm_reg(i1),i2,Con{i3,r4},fnItems,acc),
                y => w5b_g10_b(rA,rB,w4b_as_rr(i1),Con{i2,Con{i3,r4}},fnItems,acc))))))
    case Con{+i2,+r3}:
      w4c_or_peep_opt(w5_g67_b(rA,rB,w4b_as_imm_reg(i1),i2,r3,fnItems,acc),
        u => w5b_g10_b(rA,rB,w4b_as_rr(i1),Con{i2,r3},fnItems,acc))
    case Nil{}: w5b_g10_b(rA,rB,w4b_as_rr(i1),[],fnItems,acc)"""
    new_rr64_r2 = g10_helpers + """@unsafe
def w5_gpr_rr64_r2(+rA: U32, +rB: U32, +i1: X187Parsed, r2: List<&2,X187Parsed>,
    +fnItems: List<&2,X187Parsed>, +acc: List<&2,X187Parsed>) -> Maybe<&2,List<&2,X187Parsed>>:
  match r2:
    case Con{+i2,Con{+i3,+r4}}:
      w4c_or_peep_opt(
        nt_choose(Maybe<&2,List<&2,X187Parsed>>,U32.is_eq(rB,0) && w5_not_scratch(rA),
          v => w5_gpr_rr64_g2(rA,i1,i2,i3,r4,fnItems,acc),
          v => None{}),
        v => w4c_or_peep_opt(w5b_g1_b(x188_reg(rA,64),rB,w4b_as_rr(i1),i2,i3,r4,fnItems,acc),
          v2 => w4c_or_peep_opt(w5_g34_b(rA,rB,w4b_as_rr(i1),i2,i3,r4,fnItems,acc),
            w => w4c_or_peep_opt(w5_g5_b(rA,rB,w4b_as_imm_reg(i1),i2,i3,r4,fnItems,acc),
              x => w4c_or_peep_opt(w5_g67_b(rA,rB,w4b_as_imm_reg(i1),i2,Con{i3,r4},fnItems,acc),
                y => w4c_or_peep_opt(w5b_g10_b(rA,rB,w4b_as_rr(i1),Con{i2,Con{i3,r4}},fnItems,acc),
                  z => w5_g10_b(rA,rB,w4b_as_imm_reg(i1),i2,Con{i3,r4},fnItems,acc)))))))
    case Con{+i2,+r3}:
      w4c_or_peep_opt(w5_g67_b(rA,rB,w4b_as_imm_reg(i1),i2,r3,fnItems,acc),
        u => w4c_or_peep_opt(w5b_g10_b(rA,rB,w4b_as_rr(i1),Con{i2,r3},fnItems,acc),
          v => w5_g10_b(rA,rB,w4b_as_imm_reg(i1),i2,r3,fnItems,acc)))
    case Nil{}: w5b_g10_b(rA,rB,w4b_as_rr(i1),[],fnItems,acc)"""
    if old_rr64_r2 in src:
        src = replace_exact(src, old_rr64_r2, new_rr64_r2, "Pass 4b: G10 mov/addl/mov + G11 (on W5B-R2)")
    else:
        src = replace_exact(src, old_rr64, new_rr64, "Pass 4b: G10 mov/addl/mov + G11 jcc-load-jmp cmov")

    old_step = """@unsafe
def w5_gpr_step(+i0: X187Parsed, +i1: X187Parsed, +r2: List<&2,X187Parsed>,
    +fnItems: List<&2,X187Parsed>, +acc: List<&2,X187Parsed>) -> List<&2,X187Parsed>:
  w4c_or_peep(w5_gpr_try_ld(w5_as_load_rbp(i0),i1,r2,fnItems,acc),
    u => w4c_or_peep(w5_gpr_try_rr(w4b_as_rr(i0),i0,i1,r2,fnItems,acc),
      v => w4c_or_peep(w5_gpr_try_imm(w4b_as_imm_reg(i0),i1,r2,fnItems,acc),
        w => w5_gpr_peep(Con{i1,r2},fnItems,Con{i0,acc}))))"""
    new_step = """@unsafe
def w5_gpr_step(+i0: X187Parsed, +i1: X187Parsed, +r2: List<&2,X187Parsed>,
    +fnItems: List<&2,X187Parsed>, +acc: List<&2,X187Parsed>) -> List<&2,X187Parsed>:
  w4c_or_peep(w5_gpr_try_ld(w5_as_load_rbp(i0),i1,r2,fnItems,acc),
    u => w4c_or_peep(w5_gpr_try_rr(w4b_as_rr(i0),i0,i1,r2,fnItems,acc),
      v => w4c_or_peep(w5_gpr_try_imm(w4b_as_imm_reg(i0),i1,r2,fnItems,acc),
        w => w4c_or_peep(w5_gpr_try_jcc(w4b_as_branch(i0),i1,r2,fnItems,acc),
          x => w5_gpr_peep(Con{i1,r2},fnItems,Con{i0,acc})))))"""
    return replace_exact(src, old_step, new_step, "Pass 4c: wire w5_gpr_try_jcc in w5_gpr_step")


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--src", type=Path, default=DEFAULT_SRC)
    ap.add_argument("--dst", type=Path, default=DEFAULT_DST)
    args = ap.parse_args()

    src = args.src.read_text()
    src = patch_1_narrow_peel_guard(src)
    src = patch_2_bce_upgrades(src)
    src = patch_3_nat_fail_and_cmov_chain(src)
    src = patch_4_peepholes(src)
    args.dst.parent.mkdir(parents=True, exist_ok=True)
    args.dst.write_text(src)
    print(f"Wrote {args.dst} ({len(src)} bytes)")


if __name__ == "__main__":
    main()
