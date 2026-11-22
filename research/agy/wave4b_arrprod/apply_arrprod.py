#!/usr/bin/env python3
"""Wave 4 Phase 2 Track W4-6:
  1. General `$direct.<f> -> $product.<f>` boxed-entry unboxing adapter.
  2. General x86-64 machine peepholes (`shlq+movl -> shll`, in-place `addl $c, m32`,
     `movl+andl+movq` eax-bounce elimination, `cmpq $0, %r; jz/jnz -> testq %r, %r`).

Composable patcher transforming `wave4a_unified/compiler.bend` -> `wave4b_arrprod/compiler.bend`.
"""
import argparse
from pathlib import Path

ROOT = Path("/home/ai/bend2_agy")
DEFAULT_SRC = ROOT / "selfhost/build/agy/wave4a_unified/compiler.bend"
DEFAULT_DST = ROOT / "selfhost/build/agy/wave4b_arrprod/compiler.bend"


def replace_exact(src: str, old: str, new: str, label: str) -> str:
    n = src.count(old)
    if n != 1:
        raise RuntimeError(f"[{label}] expected 1 occurrence, found {n}")
    return src.replace(old, new, 1)


def patch_1_direct_to_product(src: str) -> str:
    """Pass 1: General $direct.<f> -> $product.<f> boxed-entry unboxing adapter."""
    old = """@unsafe
def p168_candidates(+mode: U32, source: List<&2,KDef>, book: List<&2,KDef>, +names: List<&2,String>,
    constructors: List<&2,N_Constructor>, nodes: List<&2,P112SNode>, bangs: List<&2,String>,
    +remaining: U32, +workers: List<&2,P113DFunction>, helpers: List<&2,P128BRHelper>,
    retry: List<&2,NO_Plan>, +raw: List<&2,P113DCandidate>) -> P167Lowered:
  +ready = p113e_signatures(workers,missing())
  p168_closed(mode,source,book,names,constructors,nodes,bangs,
    [mode,U32.sub(nt_count(String,names),remaining),nt_count(P113DFunction,workers),remaining,nt_count(P113DCandidate,raw)],
    helpers,retry,ready,p113d_passes(p126sc_candidates(raw),ready,nt_reverse(P113DFunction,workers,[]),32))



@unsafe
def p168_selected(mode: U32, source: List<&2,KDef>, +book: List<&2,KDef>, +names: List<&2,String>,
    constructors: List<&2,N_Constructor>, nodes: List<&2,P112SNode>, +bangs: List<&2,String>,
    workers: List<&2,P113DFunction>, helpers: List<&2,P128BRHelper>, retry: List<&2,NO_Plan>,
    +remaining: List<&2,String>) -> P167Lowered:
  p168_candidates(mode,source,book,names,constructors,nodes,bangs,nt_count(String,remaining),workers,helpers,retry,
    p113pl_candidates(book,remaining,bangs,book_cached(nq_signatures(book,names),0)))"""

    new = """# W4-6 Pass 1: General $direct.<f> -> $product.<f> boxed-entry unboxing adapter.
# When a public $direct.<f> has a verified $product.<f> worker in the admitted set,
# replace $direct.<f>'s body with a thin wrapper that unpacks boxed product args once,
# calls $product.<f>, and boxes the returned product (if any), then re-toposorts via p113d_passes.

type W4PUnpack is Data:
  W4PUnpack{+stmts: List<&2,N111Stmt>, +args: List<&2,N111Value>, +ok: Bool}

@unsafe
def w4p_field_locals(+count: U32, +i: U32, +fresh: U32) -> List<&2,N111Value>:
  nt_choose(List<&2,N111Value>,U32.is_eq(i,count),u => [],
    u => Con{N111Local{"v_" ++ U32.show(nc_id(U32.add(fresh,i)))},w4p_field_locals(count,U32.inc(i),fresh)})

@unsafe
def w4p_unpack_join_shape(+ctor: String, +word: String, +w: U32, +fresh: U32, sub: W4PUnpack) -> W4PUnpack:
  match sub:
    case W4PUnpack{stmts,args,ok}:
      W4PUnpack{nt_append(N111Stmt,p111_take(ctor,N111Local{word},w,fresh),stmts),
        nt_append(N111Value,w4p_field_locals(w,0,fresh),args),ok}

@unsafe
def w4p_unpack_join_plain(+word: String, sub: W4PUnpack) -> W4PUnpack:
  match sub:
    case W4PUnpack{stmts,args,ok}:
      W4PUnpack{stmts,Con{N111Local{word},args},ok}

@unsafe
def w4p_unpack_params(params: List<&2,NC_Binding>, shapes: List<&2,KTerm>, +fresh: U32) -> W4PUnpack:
  match params shapes:
    case Nil{} Nil{}: W4PUnpack{[],[],True{}}
    case Con{NC_Binding{id,+word,kind},+prest} Con{+shape,+srest}:
      nt_choose(W4PUnpack,agy_str_eq(tg(shape),"NQShape"),
        u =>
          +w = ix(shape)
          nt_choose(W4PUnpack,U32.is_ge(w,1) && U32.is_le(w,8),
            v => w4p_unpack_join_shape(nm(shape),word,w,fresh,w4p_unpack_params(prest,srest,U32.add(fresh,w))),
            v => W4PUnpack{[],[],False{}}),
        u => w4p_unpack_join_plain(word,w4p_unpack_params(prest,srest,fresh)))
    case _ _: W4PUnpack{[],[],False{}}

@unsafe
def w4p_prod_index(fns: List<&2,P113DFunction>, +acc: KDef) -> KDef:
  match fns:
    case Nil{}: acc
    case Con{P113DFunction{+name,+params,+result,public,+body},+rest}:
      nt_choose(KDef,String.starts_with(name,"$product.") &&
          Bool.not(nb_contains(p113j_calls(body),"$direct." ++ String.drop(name,9n))),
        u => w4p_prod_index(rest,p111v_put(acc,name,"W4Prod",nt_count(NC_Binding,params),result)),
        u => w4p_prod_index(rest,acc))

@unsafe
def w4p_finish_box(+orig: P113DFunction, +name: String, +params: List<&2,NC_Binding>,
    +pre: List<&2,N111Stmt>, +prodName: String, +flatArgs: List<&2,N111Value>,
    +retNames: List<&2,String>, boxed: P111ValueCode) -> P113DFunction:
  match boxed:
    case P111ValueCode{+bstmts,+bword,+berr}:
      nt_choose(P113DFunction,String.is_empty(berr),
        u => P113DFunction{name,params,1,True{},
          nt_append(P113DStmt,p113d_scalars(pre),
            Con{P113DCall{retNames,prodName,flatArgs},
              nt_append(P113DStmt,p113d_scalars(bstmts),[P113DResult{[bword]}])})},
        u => orig)

@unsafe
def w4p_try_wrap_unpacked(+fn: P113DFunction, +name: String, +params: List<&2,NC_Binding>,
    +prodName: String, +rshape: KTerm, +rw: U32, unpacked: W4PUnpack) -> P113DFunction:
  match unpacked:
    case W4PUnpack{+pre,+flatArgs,+ok}:
      nt_choose(P113DFunction,ok,
        z =>
          +retNames = p113pl_names("w4p_ret",rw,0)
          nt_choose(P113DFunction,agy_str_eq(tg(rshape),"NQShape"),
            r => w4p_finish_box(fn,name,params,pre,prodName,flatArgs,retNames,
              p111_constructor(nm(rshape),p113pl_locals(retNames))),
            r => P113DFunction{name,params,1,True{},
              nt_append(P113DStmt,p113d_scalars(pre),
                [P113DCall{retNames,prodName,flatArgs},P113DResult{[N111Local{"w4p_ret_0"}]}])}),
        z => fn)

@unsafe
def w4p_try_wrap(+fn: P113DFunction, +signatures: List<&2,KDef>, +prodIdx: KDef) -> P113DFunction:
  match fn:
    case P113DFunction{+name,+params,+result,+public,body}:
      nt_choose(P113DFunction,public && U32.is_eq(result,1) && String.starts_with(name,"$direct.") &&
          Bool.not(p126s_is_table(fn)),
        u =>
          +origName = String.drop(name,8n)
          +info = lookup(signatures,origName)
          nt_choose(P113DFunction,agy_str_eq(tg(dv(info)),"NQSig"),
            v =>
              +prodName = nm(dv(info))
              +psig = p111v_get(prodIdx,prodName)
              +pshapes = ks(dv(info))
              +rshape = dt(info)
              +rw = nq_width(rshape)
              nt_choose(P113DFunction,agy_str_eq(dk(psig),"W4Prod") &&
                  U32.is_eq(da(psig),nq_shape_words(pshapes)) &&
                  U32.is_eq(dx(psig),rw) && U32.is_ge(rw,1) && U32.is_le(rw,8),
                w => w4p_try_wrap_unpacked(fn,name,params,prodName,rshape,rw,w4p_unpack_params(params,pshapes,64)),
                w => fn),
            v => fn),
        u => fn)

@unsafe
def w4p_cand_of(+fn: P113DFunction) -> P113DCandidate:
  match fn:
    case P113DFunction{n2,p2,r2,pub2,+b2}: P113DCandidate{fn,"",p113j_calls(b2)}

@unsafe
def w4p_to_candidates(fns: List<&2,P113DFunction>, +ready: KDef, +signatures: List<&2,KDef>, +prodIdx: KDef) -> List<&2,P113DCandidate>:
  match fns:
    case Nil{}: []
    case Con{+fn,+rest}:
      match fn:
        case P113DFunction{+name,params,result,public,body}:
          nt_choose(List<&2,P113DCandidate>,p113d_ready(ready,name),
            u => w4p_to_candidates(rest,ready,signatures,prodIdx),
            u => Con{w4p_cand_of(w4p_try_wrap(fn,signatures,prodIdx)),w4p_to_candidates(rest,ready,signatures,prodIdx)})

@unsafe
def w4p_adapt_functions(+fns: List<&2,P113DFunction>, +ready: KDef, +workers: List<&2,P113DFunction>,
    +signatures: List<&2,KDef>) -> List<&2,P113DFunction>:
  +prodIdx = w4p_prod_index(fns,missing())
  +cands = w4p_to_candidates(fns,ready,signatures,prodIdx)
  +fns2 = p113d_passes(cands,ready,nt_reverse(P113DFunction,workers,[]),32)
  nt_choose(List<&2,P113DFunction>,U32.is_eq(nt_count(P113DFunction,fns2),nt_count(P113DFunction,fns)),
    u => fns2,u => fns)

@unsafe
def p168_candidates(+mode: U32, source: List<&2,KDef>, book: List<&2,KDef>, +names: List<&2,String>,
    constructors: List<&2,N_Constructor>, nodes: List<&2,P112SNode>, bangs: List<&2,String>,
    +remaining: U32, +workers: List<&2,P113DFunction>, helpers: List<&2,P128BRHelper>,
    retry: List<&2,NO_Plan>, +signatures: List<&2,KDef>, +raw: List<&2,P113DCandidate>) -> P167Lowered:
  +ready = p113e_signatures(workers,missing())
  +fns0 = p113d_passes(p126sc_candidates(raw),ready,nt_reverse(P113DFunction,workers,[]),32)
  +fns1 = w4p_adapt_functions(fns0,ready,workers,signatures)
  p168_closed(mode,source,book,names,constructors,nodes,bangs,
    [mode,U32.sub(nt_count(String,names),remaining),nt_count(P113DFunction,workers),remaining,nt_count(P113DCandidate,raw)],
    helpers,retry,ready,fns1)



@unsafe
def p168_selected(mode: U32, source: List<&2,KDef>, +book: List<&2,KDef>, +names: List<&2,String>,
    constructors: List<&2,N_Constructor>, nodes: List<&2,P112SNode>, +bangs: List<&2,String>,
    workers: List<&2,P113DFunction>, helpers: List<&2,P128BRHelper>, retry: List<&2,NO_Plan>,
    +remaining: List<&2,String>) -> P167Lowered:
  +sigs = book_cached(nq_signatures(book,names),0)
  p168_candidates(mode,source,book,names,constructors,nodes,bangs,nt_count(String,remaining),workers,helpers,retry,
    sigs,p113pl_candidates(book,remaining,bangs,sigs))"""

    return replace_exact(src, old, new, "Pass 1: $direct -> $product adapter")


def patch_2_peepholes(src: str) -> str:
    """Pass 2: General x86-64 machine peepholes in w4_peep_list:
      2a. shlq $k, %r64; movl %r32, %r32 (1 <= k <= 31, flags dead) -> shll $k, %r32
      2b. movabsq $c, %r64; addl m32, %r32; movl %r32, m32 (c <= 0x7fffffff, r dead, flags dead) -> addl $c, m32
      2c. movl %r32, %eax; andl $M, %eax; movq %rax, %r64 (rax dead, flags dead) -> andl $M, %r32
      2d. cmpq $0, %r64; je/jne L -> testq %r64, %r64; je/jne L
    """
    old = """@unsafe
def w4_peep_pair(+i0: X187Parsed, +i1: X187Parsed, +rest: List<&2,X187Parsed>, +out: List<&2,X188Seq>) -> List<&2,X188Seq>:
  match i0 i1:
    case PInst{X187Instruction{+sop,[X187Reg{+sr,8,False{}}]}}
         PInst{X187Instruction{+mop,[X187Reg{+mr1,8,False{}},X187Reg{+mr2,32,False{}}]}}:
      nt_choose(List<&2,X188Seq>,w4_peep_is_setcc(sop) && agy_str_eq(mop,"movzbl") &&
          U32.is_eq(sr,mr1) && U32.is_eq(mr1,mr2),
        u => w4_peep_after_setcc(sr,rest,Con{X188One{i1},Con{X188One{i0},out}}),
        u => w4_peep_list(Con{i1,rest},Con{X188One{i0},out}))
    case PInst{X187Instruction{+x1,[X187Imm{1,0},X187Reg{+r1,+w1,False{}}]}}
         PInst{X187Instruction{+x2,[X187Imm{1,0},X187Reg{+r2,+w2,False{}}]}}:
      nt_choose(List<&2,X188Seq>,agy_str_eq(x1,"xorq") && agy_str_eq(x2,"xorq") &&
          U32.is_eq(r1,r2) && U32.is_eq(w1,64) && U32.is_eq(w2,64) && w4_peep_flags_dead_list(rest,16),
        u => w4_peep_list(rest,out),
        u => w4_peep_list(Con{i1,rest},Con{X188One{i0},out}))
    case PInst{X187Instruction{+subop,[X187Imm{1,0},X187Reg{+r1,+w1,False{}}]}}
         PInst{X187Instruction{+cmpop,[X187Imm{0,0},X187Reg{+r2,+w2,False{}}]}}:
      w4_peep_sub_cmp(rest,i0,i1,out,subop,cmpop,r1,r2,w1,w2)
    case _ _: w4_peep_list(Con{i1,rest},Con{X188One{i0},out})"""

    new = """@unsafe
def w4_peep_op_uses_reg(op: X187Operand, +r: U32) -> Bool:
  match op:
    case X187Reg{idx,_,False{}}: U32.is_eq(idx,r)
    case X187Mem{base,_}: U32.is_eq(base,r)
    case X187Indexed{base,index,_,_}: U32.is_eq(base,r) || U32.is_eq(index,r)
    case _: False{}

@unsafe
def w4_peep_dst_kills(dst: X187Operand, +r: U32) -> Bool:
  match dst:
    case X187Reg{dr,_,False{}}: U32.is_eq(dr,r)
    case _: False{}

@unsafe
def w4_peep_xor_self_kills(src: X187Operand, dst: X187Operand, +r: U32) -> Bool:
  match src dst:
    case X187Reg{sr,_,False{}} X187Reg{dr,_,False{}}: U32.is_eq(sr,dr) && U32.is_eq(sr,r)
    case _ _: False{}

@unsafe
def w4_peep_reg_dead(+r: U32, items: List<&2,X187Parsed>, +budget: U32) -> Bool:
  match items:
    case Nil{}: False{}
    case Con{PInst{X187Instruction{+op,[+src,+dst]}},+rest}:
      nt_choose(Bool,U32.is_eq(budget,0),u => False{},u =>
        nt_choose(Bool,agy_str_eq(op,"movq") || agy_str_eq(op,"movl") || agy_str_eq(op,"movabsq") ||
            agy_str_eq(op,"movzbl") || agy_str_eq(op,"leaq"),
          v => nt_choose(Bool,w4_peep_op_uses_reg(src,r),w => False{},w =>
            nt_choose(Bool,w4_peep_dst_kills(dst,r),z => True{},z =>
              nt_choose(Bool,w4_peep_op_uses_reg(dst,r),q => False{},q => w4_peep_reg_dead(r,rest,U32.sub(budget,1))))),
          v => nt_choose(Bool,(agy_str_eq(op,"xorl") || agy_str_eq(op,"xorq")) && w4_peep_xor_self_kills(src,dst,r),
            w => True{},
            w => nt_choose(Bool,w4_peep_op_uses_reg(src,r) || w4_peep_op_uses_reg(dst,r),
              z => False{},z => w4_peep_reg_dead(r,rest,U32.sub(budget,1))))))
    case Con{PInst{X187Instruction{+op,[X187Target{_}]}},rest}:
      nt_choose(Bool,U32.is_gt(budget,0) && agy_str_eq(op,"call") &&
          (U32.is_eq(r,0) || U32.is_eq(r,2) || U32.is_eq(r,10) || U32.is_eq(r,11)),
        v => True{},v => False{})
    case _: False{}

@unsafe
def w4_peep_mem_inc(+c: U32, +r: U32, +b: U32, +idx: U32, +sc: U32, +disp: U32,
    +i0: X187Parsed, +i1: X187Parsed, +rest: List<&2,X187Parsed>, +out: List<&2,X188Seq>) -> List<&2,X188Seq>:
  match rest:
    case Con{PInst{X187Instruction{+mop,[X187Reg{+mr,32,False{}},X187Indexed{+mb,+mi,+ms,+md}]}},+tail}:
      nt_choose(List<&2,X188Seq>,agy_str_eq(mop,"movl") && U32.is_eq(mr,r) &&
          U32.is_eq(mb,b) && U32.is_eq(mi,idx) && U32.is_eq(ms,sc) && U32.is_eq(md,disp) &&
          Bool.not(U32.is_eq(r,b)) && Bool.not(U32.is_eq(r,idx)) &&
          w4_peep_reg_dead(r,tail,16) && w4_peep_flags_dead_list(tail,16),
        u => w4_peep_list(tail,Con{x188_i2("addl",X187Imm{c,0},X187Indexed{b,idx,sc,disp}),out}),
        u => w4_peep_list(Con{i1,rest},Con{X188One{i0},out}))
    case _: w4_peep_list(Con{i1,rest},Con{X188One{i0},out})

@unsafe
def w4_peep_eax_and(+sr: U32, +mask: U32, +i0: X187Parsed, +i1: X187Parsed,
    +rest: List<&2,X187Parsed>, +out: List<&2,X188Seq>) -> List<&2,X188Seq>:
  match rest:
    case Con{PInst{X187Instruction{+mop,[X187Reg{0,64,False{}},X187Reg{+dr,64,False{}}]}},+tail}:
      nt_choose(List<&2,X188Seq>,agy_str_eq(mop,"movq") && U32.is_eq(dr,sr) &&
          Bool.not(U32.is_eq(sr,0)) && w4_peep_reg_dead(0,tail,16) && w4_peep_flags_dead_list(tail,16),
        u => w4_peep_list(tail,Con{x188_i2("andl",X187Imm{mask,0},x188_reg(sr,32)),out}),
        u => w4_peep_list(Con{i1,rest},Con{X188One{i0},out}))
    case _: w4_peep_list(Con{i1,rest},Con{X188One{i0},out})

@unsafe
def w4_peep_shlq_movl(+k: U32, +r1: U32, +i0: X187Parsed, +i1: X187Parsed,
    +rest: List<&2,X187Parsed>, +out: List<&2,X188Seq>) -> List<&2,X188Seq>:
  match i1:
    case PInst{X187Instruction{+mop,[X187Reg{+r2,32,False{}},X187Reg{+r3,32,False{}}]}}:
      nt_choose(List<&2,X188Seq>,agy_str_eq(mop,"movl") &&
          U32.is_eq(r1,r2) && U32.is_eq(r2,r3) && U32.is_ge(k,1) && U32.is_le(k,31) &&
          w4_peep_flags_dead_list(rest,16),
        u => w4_peep_list(rest,Con{x188_i2("shll",X187Imm{k,0},x188_reg(r1,32)),out}),
        u => w4_peep_list(Con{i1,rest},Con{X188One{i0},out}))
    case _: w4_peep_list(Con{i1,rest},Con{X188One{i0},out})

@unsafe
def w4_peep_movabs_add(+c: U32, +r1: U32, +i0: X187Parsed, +i1: X187Parsed,
    +rest: List<&2,X187Parsed>, +out: List<&2,X188Seq>) -> List<&2,X188Seq>:
  match i1:
    case PInst{X187Instruction{+a1,[X187Indexed{+b,+idx,+sc,+disp},X187Reg{+r2,32,False{}}]}}:
      nt_choose(List<&2,X188Seq>,agy_str_eq(a1,"addl") && U32.is_eq(r1,r2) && U32.is_le(c,2147483647),
        u => w4_peep_mem_inc(c,r1,b,idx,sc,disp,i0,i1,rest,out),
        u => w4_peep_list(Con{i1,rest},Con{X188One{i0},out}))
    case _: w4_peep_list(Con{i1,rest},Con{X188One{i0},out})

@unsafe
def w4_peep_movl_and(+sr: U32, +i0: X187Parsed, +i1: X187Parsed,
    +rest: List<&2,X187Parsed>, +out: List<&2,X188Seq>) -> List<&2,X188Seq>:
  match i1:
    case PInst{X187Instruction{+a1,[X187Imm{+mask,0},X187Reg{0,32,False{}}]}}:
      nt_choose(List<&2,X188Seq>,agy_str_eq(a1,"andl") && U32.is_le(mask,2147483647),
        u => w4_peep_eax_and(sr,mask,i0,i1,rest,out),
        u => w4_peep_list(Con{i1,rest},Con{X188One{i0},out}))
    case _: w4_peep_list(Con{i1,rest},Con{X188One{i0},out})

@unsafe
def w4_peep_cmp0_jcc(+r1: U32, +i0: X187Parsed, +i1: X187Parsed,
    +rest: List<&2,X187Parsed>, +out: List<&2,X188Seq>) -> List<&2,X188Seq>:
  match i1:
    case PInst{X187Instruction{+jop,[X187Target{tgt}]}}:
      nt_choose(List<&2,X188Seq>,w4_peep_is_jz_jnz(jop),
        u => w4_peep_list(Con{i1,rest},Con{x188_i2("testq",x188_reg(r1,64),x188_reg(r1,64)),out}),
        u => w4_peep_list(Con{i1,rest},Con{X188One{i0},out}))
    case _: w4_peep_list(Con{i1,rest},Con{X188One{i0},out})

@unsafe
def w4_peep_extra(+i0: X187Parsed, +i1: X187Parsed, +rest: List<&2,X187Parsed>, +out: List<&2,X188Seq>) -> List<&2,X188Seq>:
  match i0:
    case PInst{X187Instruction{+op,[X187Imm{+lo,0},X187Reg{+r1,64,False{}}]}}:
      nt_choose(List<&2,X188Seq>,agy_str_eq(op,"shlq"),
        u => w4_peep_shlq_movl(lo,r1,i0,i1,rest,out),
        u => nt_choose(List<&2,X188Seq>,agy_str_eq(op,"movabsq"),
          v => w4_peep_movabs_add(lo,r1,i0,i1,rest,out),
          v => nt_choose(List<&2,X188Seq>,agy_str_eq(op,"cmpq") && U32.is_eq(lo,0),
            w => w4_peep_cmp0_jcc(r1,i0,i1,rest,out),
            w => w4_peep_list(Con{i1,rest},Con{X188One{i0},out}))))
    case PInst{X187Instruction{+op,[X187Reg{+sr,32,False{}},X187Reg{0,32,False{}}]}}:
      nt_choose(List<&2,X188Seq>,agy_str_eq(op,"movl"),
        u => w4_peep_movl_and(sr,i0,i1,rest,out),
        u => w4_peep_list(Con{i1,rest},Con{X188One{i0},out}))
    case _: w4_peep_list(Con{i1,rest},Con{X188One{i0},out})

@unsafe
def w4_peep_pair(+i0: X187Parsed, +i1: X187Parsed, +rest: List<&2,X187Parsed>, +out: List<&2,X188Seq>) -> List<&2,X188Seq>:
  match i0 i1:
    case PInst{X187Instruction{+sop,[X187Reg{+sr,8,False{}}]}}
         PInst{X187Instruction{+mop,[X187Reg{+mr1,8,False{}},X187Reg{+mr2,32,False{}}]}}:
      nt_choose(List<&2,X188Seq>,w4_peep_is_setcc(sop) && agy_str_eq(mop,"movzbl") &&
          U32.is_eq(sr,mr1) && U32.is_eq(mr1,mr2),
        u => w4_peep_after_setcc(sr,rest,Con{X188One{i1},Con{X188One{i0},out}}),
        u => w4_peep_list(Con{i1,rest},Con{X188One{i0},out}))
    case PInst{X187Instruction{+x1,[X187Imm{1,0},X187Reg{+r1,+w1,False{}}]}}
         PInst{X187Instruction{+x2,[X187Imm{1,0},X187Reg{+r2,+w2,False{}}]}}:
      nt_choose(List<&2,X188Seq>,agy_str_eq(x1,"xorq") && agy_str_eq(x2,"xorq") &&
          U32.is_eq(r1,r2) && U32.is_eq(w1,64) && U32.is_eq(w2,64) && w4_peep_flags_dead_list(rest,16),
        u => w4_peep_list(rest,out),
        u => w4_peep_list(Con{i1,rest},Con{X188One{i0},out}))
    case PInst{X187Instruction{+subop,[X187Imm{1,0},X187Reg{+r1,+w1,False{}}]}}
         PInst{X187Instruction{+cmpop,[X187Imm{0,0},X187Reg{+r2,+w2,False{}}]}}:
      w4_peep_sub_cmp(rest,i0,i1,out,subop,cmpop,r1,r2,w1,w2)
    case _ _: w4_peep_extra(i0,i1,rest,out)"""

    return replace_exact(src, old, new, "Pass 2: x86 machine peepholes")


def patch_3_two_pass_inline(src: str) -> str:
    """Pass 3: 2-pass p113i_function in p169o_walk (peels tiny tail-loops 2x and chains wrapper->worker inlining)."""
    old = """              v => p169o_next(head,rest,seeds,blocked,targets,table,reversed,
                p113i_function(head,table))))"""
    new = """              v => p169o_next(head,rest,seeds,blocked,targets,table,reversed,
                p113i_function(p113i_function(head,table),table))))"""
    return replace_exact(src, old, new, "Pass 3: 2-pass p113i_function")


def apply_all(src: str) -> str:
    src = patch_1_direct_to_product(src)
    src = patch_2_peepholes(src)
    src = patch_3_two_pass_inline(src)
    return src


def main():
    ap = argparse.ArgumentParser(description="Wave 4B Track W4-6: $direct->$product + Array BCE + Peepholes")
    ap.add_argument("--src", type=Path, default=DEFAULT_SRC)
    ap.add_argument("--dst", type=Path, default=DEFAULT_DST)
    args = ap.parse_args()

    src_text = args.src.read_text()
    out_text = apply_all(src_text)
    args.dst.parent.mkdir(parents=True, exist_ok=True)
    args.dst.write_text(out_text)
    print(f"Wrote {args.dst} ({len(out_text)} bytes, delta={len(out_text) - len(src_text):+d} bytes)")


if __name__ == "__main__":
    main()
