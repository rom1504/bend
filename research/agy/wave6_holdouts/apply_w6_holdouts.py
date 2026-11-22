#!/usr/bin/env python3
"""Wave 6 Holdouts Prototype: 2 General Compiler Passes on top of wave5c_unified/compiler.bend.

Pass 1 (W6-P1): Direct-Style Non-Tail Self-Recursion + Self-Recursive Inliner Guard
  - `p113d_call` and `p118t_original_call_result`: lower non-tail self-recursive calls
    to native `P113DCall` (calls=[]) instead of rejecting the entire function (and its
    callers!) to the CPS/continuation-allocating `p111_` trampoline. Tail self-calls
    continue to lower to `P113DAgain` tight native loops.
  - `p113d_pass_function`: ignore self-edges via `w6_p113d_deps_self`.
  - `p113e_function`: insert the function's own signature into `ready` before verifying
    its body so self-calls validate against exact parameter/result arity.
  - `p113i_eligible`: exclude functions containing a self `P113DCall` from the inliner
    table (`Bool.not(w6_body_calls_self(name, body))`) to prevent exponential inlining
    of multi-branch recursive functions (keeps compile time fast and code in L1 I-cache).

Pass 2 (W6-P2): Dead Array.swap Old-Value Load Elimination
  - `x185_d_scalar`: eliminate dead `N111Load` statements whose destination is an unused
    `p113a_*_old` array-cell load (from `Array.swap` on an already-validated in-bounds
    array cell whose returned old value is discarded).

100% general — zero benchmark matchers, zero runtime edits.
"""
import argparse
from pathlib import Path


def replace_once(src: str, old: str, new: str, label: str) -> str:
    n = src.count(old)
    if n != 1:
        raise RuntimeError(f"[{label}] expected 1 occurrence, found {n}")
    return src.replace(old, new, 1)


def apply_w6(src: str) -> str:
    # === PASS 1: Direct-Style Non-Tail Self-Recursion + Self-Recursive Inliner Guard ===
    old_call = (
        '@unsafe\n'
        'def p113d_call(+name: String, +args: List<&2,N111Value>, +owner: String, +target: P113DTarget, +n: U32) -> P113DCode:\n'
        '  nt_choose(P113DCode,agy_str_eq(name,owner),\n'
        '    u => nt_choose(P113DCode,p113d_tail(target),u => P113DCode{[P113DAgain{args}],n,"",[]},u => p113d_fail("direct: non-tail self call",n)),\n'
        '    u => p113d_call_target(name,args,target,n))\n'
    )
    new_call = (
        '@unsafe\n'
        'def w6_p113d_self_nontail(+name: String, args: List<&2,N111Value>, target: P113DTarget, n: U32) -> P113DCode:\n'
        '  match target:\n'
        '    case P113DReturn{}: P113DCode{[P113DAgain{args}],n,"",[]}\n'
        '    case P113DLocal{dest}: P113DCode{[P113DCall{[dest],name,args}],n,"",[]}\n'
        '\n'
        '@unsafe\n'
        'def p113d_call(+name: String, +args: List<&2,N111Value>, +owner: String, +target: P113DTarget, +n: U32) -> P113DCode:\n'
        '  nt_choose(P113DCode,agy_str_eq(name,owner),\n'
        '    u => nt_choose(P113DCode,p113d_tail(target),u => P113DCode{[P113DAgain{args}],n,"",[]},u => w6_p113d_self_nontail(name,args,target,n)),\n'
        '    u => p113d_call_target(name,args,target,n))\n'
    )
    src = replace_once(src, old_call, new_call, "p113d_call")

    old_deps = (
        '@unsafe\n'
        'def p113d_deps(calls: List<&2,String>, +index: KDef) -> Bool:\n'
        '  match calls:\n'
        '    case Nil{}: True{}\n'
        '    case Con{head,rest}: p113d_ready(index,head) && p113d_deps(rest,index)\n'
    )
    new_deps = (
        '@unsafe\n'
        'def p113d_deps(calls: List<&2,String>, +index: KDef) -> Bool:\n'
        '  match calls:\n'
        '    case Nil{}: True{}\n'
        '    case Con{head,rest}: p113d_ready(index,head) && p113d_deps(rest,index)\n'
        '\n'
        '@unsafe\n'
        'def w6_p113d_deps_self(calls: List<&2,String>, +index: KDef, +owner: String) -> Bool:\n'
        '  match calls:\n'
        '    case Nil{}: True{}\n'
        '    case Con{+head,rest}: (agy_str_eq(head,owner) || p113d_ready(index,head)) && w6_p113d_deps_self(rest,index,owner)\n'
    )
    src = replace_once(src, old_deps, new_deps, "p113d_deps")

    src = replace_once(
        src,
        '        nt_choose(P113DPass,p113d_deps(calls,index),\n',
        '        nt_choose(P113DPass,w6_p113d_deps_self(calls,index,name),\n',
        "p113d_pass_function",
    )

    old_prod = (
        '@unsafe\n'
        'def p118t_original_call_result(+name: String, +args: List<&2,N111Value>, +shape: KTerm, +target: P113PTarget, +n: U32) -> P113DCode:\n'
        '  +names = p113pl_names("p113p_call_" ++ U32.show(n),nq_width(shape),0)\n'
        '  nt_choose(P113DCode,agy_str_eq(name,p113pl_owner(target)),\n'
        '    u => nt_choose(P113DCode,p113pl_tail(target) && nq_same(shape,p113pl_shape(target)),\n'
        '      v => P113DCode{[P113DAgain{args}],n,"",[]},v => p113d_fail("product non-tail self call",n)),\n'
        '    u => p113d_join(P113DCode{[P113DCall{names,name,args}],U32.inc(n),"",[name]},\n'
        '      p113pl_output(shape,p113pl_locals(names),target,U32.inc(n))))\n'
    )
    new_prod = (
        '@unsafe\n'
        'def p118t_original_call_result(+name: String, +args: List<&2,N111Value>, +shape: KTerm, +target: P113PTarget, +n: U32) -> P113DCode:\n'
        '  +names = p113pl_names("p113p_call_" ++ U32.show(n),nq_width(shape),0)\n'
        '  nt_choose(P113DCode,agy_str_eq(name,p113pl_owner(target)),\n'
        '    u => nt_choose(P113DCode,p113pl_tail(target) && nq_same(shape,p113pl_shape(target)),\n'
        '      v => P113DCode{[P113DAgain{args}],n,"",[]},\n'
        '      v => p113d_join(P113DCode{[P113DCall{names,name,args}],U32.inc(n),"",[]},\n'
        '        p113pl_output(shape,p113pl_locals(names),target,U32.inc(n)))),\n'
        '    u => p113d_join(P113DCode{[P113DCall{names,name,args}],U32.inc(n),"",[name]},\n'
        '      p113pl_output(shape,p113pl_locals(names),target,U32.inc(n))))\n'
    )
    src = replace_once(src, old_prod, new_prod, "p118t_original_call_result")

    src = replace_once(
        src,
        '        u => p113e_seeded(body,ids,ready,nt_count(NC_Binding,params),result,p113e_seed(params)))))\n',
        '        u => p113e_seeded(body,ids,p113e_insert(ready,p113e_signature(function)),nt_count(NC_Binding,params),result,p113e_seed(params)))))\n',
        "p113e_function",
    )

    old_elig = (
        '@unsafe\n'
        'def p113i_eligible(+function: P113DFunction) -> Bool:\n'
        '  match function:\n'
        '    case P113DFunction{name,+params,+result,public,+body}:\n'
        '      +sz = p113i_size(body)\n'
        '      +arity = nt_count(NC_Binding,params)\n'
        '      Bool.not(p126s_is_table(function)) && U32.is_ge(result,1) && U32.is_le(result,8) && U32.is_le(arity,64) &&\n'
        '        U32.is_le(p113i_stack(body),8192) && p113i_params(params) &&\n'
        '        ((U32.is_le(sz,1024) && p137qi_returns(body,result)) ||\n'
        '         (U32.is_le(sz,120) && w4i_returns_or_again(body,result,arity)))\n'
    )
    new_elig = (
        '@unsafe\n'
        'def w6_body_calls_self(+owner: String, body: List<&2,P113DStmt>) -> Bool:\n'
        '  match body:\n'
        '    case Nil{}: False{}\n'
        '    case Con{P113DCall{_,target,_},rest}: agy_str_eq(target,owner) || w6_body_calls_self(owner,rest)\n'
        '    case Con{P113DIf{_,yes,no},rest}: w6_body_calls_self(owner,yes) || w6_body_calls_self(owner,no) || w6_body_calls_self(owner,rest)\n'
        '    case Con{_,rest}: w6_body_calls_self(owner,rest)\n'
        '\n'
        '@unsafe\n'
        'def p113i_eligible(+function: P113DFunction) -> Bool:\n'
        '  match function:\n'
        '    case P113DFunction{+name,+params,+result,public,+body}:\n'
        '      +sz = p113i_size(body)\n'
        '      +arity = nt_count(NC_Binding,params)\n'
        '      Bool.not(p126s_is_table(function)) && Bool.not(w6_body_calls_self(name,body)) &&\n'
        '        U32.is_ge(result,1) && U32.is_le(result,8) && U32.is_le(arity,64) &&\n'
        '        U32.is_le(p113i_stack(body),8192) && p113i_params(params) &&\n'
        '        ((U32.is_le(sz,1024) && p137qi_returns(body,result)) ||\n'
        '         (U32.is_le(sz,120) && w4i_returns_or_again(body,result,arity)))\n'
    )
    src = replace_once(src, old_elig, new_elig, "p113i_eligible")

    # === PASS 2: Dead Array.swap Old-Value Load Elimination ===
    old_dead_load = (
        '    case N111Load{+name,typ,base,offset} X185Dead{body,live}:\n'
        '      X185Dead{Con{P113DScalar{stmt},body},x185_d_value(base,x185_d_kill(live,name))}\n'
    )
    new_dead_load = (
        '    case N111Load{+name,typ,base,offset} X185Dead{+body,+live}:\n'
        '      nt_choose(X185Dead,\n'
        '        U32.is_eq(da(p111v_get(live,name)),0) && String.starts_with(name,"p113a_") && String.ends_with(name,"_old"),\n'
        '        u => X185Dead{body,live},\n'
        '        u => X185Dead{Con{P113DScalar{stmt},body},x185_d_value(base,x185_d_kill(live,name))})\n'
    )
    src = replace_once(src, old_dead_load, new_dead_load, "x185_d_scalar_dead_old_load")

    return src


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--src", type=Path, required=True)
    ap.add_argument("--dst", type=Path, required=True)
    args = ap.parse_args()
    out = apply_w6(args.src.read_text())
    args.dst.parent.mkdir(parents=True, exist_ok=True)
    args.dst.write_text(out)
    print(f"[W6-P1+P2] Wrote {args.dst} ({len(out)} bytes)")


if __name__ == "__main__":
    main()
