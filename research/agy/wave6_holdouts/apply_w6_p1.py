#!/usr/bin/env python3
"""Wave 6 Pass 1 Prototype: Direct-Style Non-Tail Self-Recursion.

Enables direct-style (`p113d_` and `$product.`) x86-64 native codegen for
functions containing non-tail self-recursive calls (`P113DCall` to `owner`)
instead of rejecting them to the CPS/continuation-allocating `p111_` trampoline.

Tail self-recursive calls continue to lower to `P113DAgain` (tight native loop).
Non-tail self-recursive calls lower to a native `P113DCall` with no external
dependency edge, and `p113d_pass_function` ignores self-edges when checking
topological readiness (e.g. during `$product.` re-toposorting).

100% general — zero benchmark matchers, zero runtime edits.
"""
import argparse
from pathlib import Path


def replace_once(src: str, old: str, new: str, label: str) -> str:
    n = src.count(old)
    if n != 1:
        raise RuntimeError(f"[{label}] expected 1 occurrence, found {n}")
    return src.replace(old, new, 1)


def apply_pass1(src: str) -> str:
    # 1. p113d_call: lower non-tail self-calls to P113DCall instead of failing.
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

    # 2. p113d_pass_function: ignore self-edges in dependency readiness check.
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

    old_pass = '        nt_choose(P113DPass,p113d_deps(calls,index),\n'
    new_pass = '        nt_choose(P113DPass,w6_p113d_deps_self(calls,index,name),\n'
    src = replace_once(src, old_pass, new_pass, "p113d_pass_function")

    # 3. p118t_original_call_result: allow non-tail self-calls in $product. functions too.
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

    # 4. p113e_function: insert function's own signature into `ready` before verifying body
    #    so self-calls validate against exact parameter/result arity.
    old_e = '        u => p113e_seeded(body,ids,ready,nt_count(NC_Binding,params),result,p113e_seed(params)))))\n'
    new_e = '        u => p113e_seeded(body,ids,p113e_insert(ready,p113e_signature(function)),nt_count(NC_Binding,params),result,p113e_seed(params)))))\n'
    src = replace_once(src, old_e, new_e, "p113e_function")
    return src


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--src", type=Path, required=True)
    ap.add_argument("--dst", type=Path, required=True)
    args = ap.parse_args()
    out = apply_pass1(args.src.read_text())
    args.dst.parent.mkdir(parents=True, exist_ok=True)
    args.dst.write_text(out)
    print(f"[W6-P1] Wrote {args.dst} ({len(out)} bytes)")


if __name__ == "__main__":
    main()
