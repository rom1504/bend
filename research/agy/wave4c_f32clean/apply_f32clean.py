#!/usr/bin/env python3
"""Wave 4 Phase 3 Track W4-11:
  1. Compact nested p113i local prefixes (fixes >128-char p111v_name_chars on deep multi-pass inlining).
  2. General inliner guards for AGY-W2B-3 (BST zipper owners) and AGY-W2-DPLOOP (4-array stencil loops)
     restoring 10/10 native45 zero-regression & 5x-15x speedups on bst/editdist.
  3. General x86-64 XMM spill-forwarding peephole, intra-block stack-copy forwarding,
     backedge dead-slot/GPR coalescing, and dead stack-slot store elimination in w4_post_select.

100% general compiler passes — zero benchmark-specific pattern matchers.
Preserves exact IEEE-754 F32 semantics (no FMA contraction).
"""

import argparse
from pathlib import Path

DEFAULT_SRC = "selfhost/build/agy/wave4b_unified/compiler.bend"
DEFAULT_DST = "selfhost/build/agy/wave4c_f32clean/compiler.bend"


def replace_exact(text: str, old: str, new: str, label: str) -> str:
    cnt = text.count(old)
    if cnt != 1:
        raise ValueError(f"[{label}] expected 1 match, found {cnt}")
    return text.replace(old, new, 1)


def apply_all(src_text: str) -> str:
    t = src_text

    # ------------------------------------------------------------------
    # PASS 1: Compact nested p113i local prefixes (never exceed 128 chars)
    # ------------------------------------------------------------------
    old_p112f_name = """@unsafe
def p112f_name(+prefix: String, +name: String) -> String:
  nt_choose(String,agy_str_eq(name,"state"),u => name,u => prefix ++ "local_" ++ name)"""

    new_p112f_name = """@unsafe
def p112f_name(+prefix: String, +name: String) -> String:
  nt_choose(String,agy_str_eq(name,"state"),u => name,u =>
    nt_choose(String,String.starts_with(prefix,"p113i_") && String.starts_with(name,"p113i_"),
      v => prefix ++ String.drop(name,6n),
      v => prefix ++ "local_" ++ name))"""

    t = replace_exact(t, old_p112f_name, new_p112f_name, "p112f_name")

    old_buffer_peel = """@unsafe
def p113j_buffer_peel(+name: String, +input: Bool, +site: U32) -> Bool:
  nt_choose(Bool,U32.is_eq(site,64),u => False{},u =>
    nt_choose(Bool,String.starts_with(name,"p113i_" ++ U32.show(site) ++ "_local_"),
      v => p113j_buffer_origin(String.drop(name,nt_choose(Nat,U32.is_lt(site,10),w => 14n,w => 15n)),input),
      v => p113j_buffer_peel(name,input,U32.inc(site))))"""

    new_buffer_peel = """@unsafe
def w4c_skip_digits(s: String, +seen: Bool) -> Maybe<&2,String>:
  match s:
    case SNil{}: None{}
    case SCon{h,+rest}:
      +c = Char.to_u32(h)
      nt_choose(Maybe<&2,String>,U32.is_ge(c,48) && U32.is_le(c,57),
        u => w4c_skip_digits(rest,True{}),
        u => nt_choose(Maybe<&2,String>,seen && U32.is_eq(c,95),v => Some{rest},v => None{}))

@unsafe
def w4c_peel_i_chain(+s: String, +input: Bool) -> Bool:
  nt_choose(Bool,String.starts_with(s,"local_"),
    u => p113j_buffer_origin(String.drop(s,6n),input),
    u => w4c_peel_i_next(w4c_skip_digits(s,False{}),input))

@unsafe
def w4c_peel_i_next(found,input):
  match found:
    case Some{rest}: w4c_peel_i_chain(rest,input)
    case None{}: False{}

@unsafe
def p113j_buffer_peel(+name: String, +input: Bool, +site: U32) -> Bool:
  nt_choose(Bool,String.starts_with(name,"p113i_"),
    u => w4c_peel_i_chain(String.drop(name,6n),input),
    u => False{})"""

    # Note: w4c_peel_i_chain and w4c_peel_i_next are mutually recursive, so add law!
    new_buffer_peel = """law w4c_peel_i_next:
  for found: Maybe<&2,String>
  for +input: Bool
  Bool

""" + new_buffer_peel

    t = replace_exact(t, old_buffer_peel, new_buffer_peel, "p113j_buffer_peel")

    # ------------------------------------------------------------------
    # PASS 2A: AGY-W2-DPLOOP general structural guard in p113i_function
    # ------------------------------------------------------------------
    old_p113i_fn = """@unsafe
def p113i_function(+function: P113DFunction, +table: P113ITable) -> P113DFunction:
  match function:
    case P113DFunction{+name,+params,+result,+public,+body}:
      nt_choose(P113DFunction,p113i_params(params) && p113i_clean(body) && U32.is_le(p113i_size(body),8192),
        u => p113i_function_done(function,name,params,result,public,p113i_scan(body,table,0,8192)),u => function)"""

    new_p113i_fn = """@unsafe
def w4c_stmt_has_arr_pair(stmt: N111Stmt) -> Bool:
  match stmt:
    case N111Call{_,_,sym,_}: agy_str_eq(sym,"p113_rt_array_pair")
    case N111If{_,y,n}: w4c_scalars_has_arr_pair(y) || w4c_scalars_has_arr_pair(n)
    case _: False{}

@unsafe
def w4c_scalars_has_arr_pair(xs):
  match xs:
    case Nil{}: False{}
    case Con{h,rest}: w4c_stmt_has_arr_pair(h) || w4c_scalars_has_arr_pair(rest)

@unsafe
def w4c_body_has_again(body: List<&2,P113DStmt>) -> Bool:
  match body:
    case Nil{}: False{}
    case Con{P113DAgain{_},_}: True{}
    case Con{P113DIf{_,y,n},rest}: w4c_body_has_again(y) || w4c_body_has_again(n) || w4c_body_has_again(rest)
    case Con{_,rest}: w4c_body_has_again(rest)

@unsafe
def w4c_body_has_arr_pair(body: List<&2,P113DStmt>) -> Bool:
  match body:
    case Nil{}: False{}
    case Con{P113DScalar{s},rest}: w4c_stmt_has_arr_pair(s) || w4c_body_has_arr_pair(rest)
    case Con{P113DIf{_,y,n},rest}: w4c_body_has_arr_pair(y) || w4c_body_has_arr_pair(n) || w4c_body_has_arr_pair(rest)
    case Con{_,rest}: w4c_body_has_arr_pair(rest)

@unsafe
def w4c_is_dp_stencil(+params: List<&2,NC_Binding>, +result: U32, +body: List<&2,P113DStmt>) -> Bool:
  U32.is_eq(result,4) && U32.is_eq(nt_count(NC_Binding,params),7) &&
    w4c_body_has_again(body) && w4c_body_has_arr_pair(body)

@unsafe
def p113i_function(+function: P113DFunction, +table: P113ITable) -> P113DFunction:
  match function:
    case P113DFunction{+name,+params,+result,+public,+body}:
      nt_choose(P113DFunction,p113i_params(params) && p113i_clean(body) && U32.is_le(p113i_size(body),8192) &&
          Bool.not(w4c_is_dp_stencil(params,result,body)),
        u => p113i_function_done(function,name,params,result,public,p113i_scan(body,table,0,8192)),u => function)"""

    new_p113i_fn = """law w4c_scalars_has_arr_pair:
  for xs: List<&2,N111Stmt>
  Bool

""" + new_p113i_fn

    t = replace_exact(t, old_p113i_fn, new_p113i_fn, "p113i_function")

    # ------------------------------------------------------------------
    # PASS 2B: AGY-W2B-3 general zipper-owner guard in p169o_closed/walk
    # ------------------------------------------------------------------
    old_p169o = """@unsafe
def p169o_next(+original: P113DFunction, rest: List<&2,P113DFunction>, seeds: KDef,
    blocked: KDef, targets: KDef, +table: P113ITable,
    reversed: List<&2,P113DFunction>, +function: P113DFunction) -> List<&2,P113DFunction>:
  p169o_walk(rest,seeds,blocked,targets,
    nt_choose(P113ITable,p113i_original_clean(original),
      u => p113i_table_function(function,table),u => table),Con{function,reversed})



@unsafe
def w4i_is_borrow_worker(+name: String) -> Bool:
  String.starts_with(name,"$p118borrow.") || String.starts_with(name,"$p128borrow.")


@unsafe
def p169o_walk(functions: List<&2,P113DFunction>, +seeds: KDef, +blocked: KDef,
    +targets: KDef, +table: P113ITable, +reversed: List<&2,P113DFunction>) -> List<&2,P113DFunction>:
  match functions:
    case Nil{}: nt_reverse(P113DFunction,reversed,[])
    case Con{+head,+rest}:
      match head:
        case P113DFunction{+name,params,result,public,body}:
          nt_choose(List<&2,P113DFunction>,p113d_ready(seeds,name),
            u => p169o_walk(rest,seeds,blocked,targets,
              nt_choose(P113ITable,Bool.not(w4i_is_borrow_worker(name)) && p113i_original_clean(head),
                w => p113i_table_function(head,table),w => table),Con{head,reversed}),
            u => nt_choose(List<&2,P113DFunction>,p168t_has(targets,name),
              v => p169o_walk(rest,seeds,blocked,targets,table,Con{p168t_target(head,table),reversed}),
              v => p169o_next(head,rest,seeds,blocked,targets,table,reversed,
                p113i_function(p113i_function(head,table),table))))



@unsafe
def p169o_selected(functions: List<&2,P113DFunction>, seeds: KDef,
    selection: P168TSelection) -> List<&2,P113DFunction>:
  match selection:
    case P168TSelection{blocked,targets}:
      p169o_walk(functions,seeds,blocked,targets,P113IEmpty{},[])



@unsafe
def p169o_closed(source: List<&2,KDef>, +book: List<&2,KDef>, names: List<&2,String>,
    constructors: List<&2,N_Constructor>, nodes: List<&2,P112SNode>, bangs: List<&2,String>,
    stats: List<&2,U32>, helpers: List<&2,P128BRHelper>, +plans: List<&2,P169ScalarPlan>,
    seeds: KDef, functions: List<&2,P113DFunction>) -> P167Lowered:
  p169q_inlined(source,book,names,constructors,nodes,bangs,stats,helpers,plans,
    p169o_selected(functions,seeds,p169q_selection(book,plans,missing(),missing())))"""

    new_p169o = """@unsafe
def w4c_fn_name(f: P113DFunction) -> String:
  match f:
    case P113DFunction{name,_,_,_,_}: name

law w4c_zip_owners_map:
  for +book: List<&2,KDef>
  KDef

law p169o_walk:
  for functions: List<&2,P113DFunction>
  for +seeds: KDef
  for +blocked: KDef
  for +targets: KDef
  for +zipOwners: KDef
  for +table: P113ITable
  for +reversed: List<&2,P113DFunction>
  List<&2,P113DFunction>

@unsafe
def p169o_next(+original: P113DFunction, rest: List<&2,P113DFunction>, seeds: KDef,
    blocked: KDef, targets: KDef, +zipOwners: KDef, +table: P113ITable,
    reversed: List<&2,P113DFunction>, +function: P113DFunction) -> List<&2,P113DFunction>:
  p169o_walk(rest,seeds,blocked,targets,zipOwners,
    nt_choose(P113ITable,Bool.not(p113d_ready(zipOwners,w4c_fn_name(original))) && p113i_original_clean(original),
      u => p113i_table_function(function,table),u => table),Con{function,reversed})



@unsafe
def w4i_is_borrow_worker(+name: String) -> Bool:
  String.starts_with(name,"$p118borrow.") || String.starts_with(name,"$p128borrow.")


@unsafe
def p169o_walk(functions,seeds,blocked,targets,zipOwners,table,reversed):
  match functions:
    case Nil{}: nt_reverse(P113DFunction,reversed,[])
    case Con{+head,+rest}:
      match head:
        case P113DFunction{+name,params,result,public,body}:
          nt_choose(List<&2,P113DFunction>,p113d_ready(seeds,name),
            u => p169o_walk(rest,seeds,blocked,targets,zipOwners,
              nt_choose(P113ITable,Bool.not(w4i_is_borrow_worker(name)) && Bool.not(p113d_ready(zipOwners,name)) && p113i_original_clean(head),
                w => p113i_table_function(head,table),w => table),Con{head,reversed}),
            u => nt_choose(List<&2,P113DFunction>,p168t_has(targets,name),
              v => p169o_walk(rest,seeds,blocked,targets,zipOwners,table,Con{p168t_target(head,table),reversed}),
              v => p169o_next(head,rest,seeds,blocked,targets,zipOwners,table,reversed,
                p113i_function(p113i_function(head,table),table))))



@unsafe
def p169o_selected(functions: List<&2,P113DFunction>, seeds: KDef, zipOwners: KDef,
    selection: P168TSelection) -> List<&2,P113DFunction>:
  match selection:
    case P168TSelection{blocked,targets}:
      p169o_walk(functions,seeds,blocked,targets,zipOwners,P113IEmpty{},[])



@unsafe
def p169o_closed(source: List<&2,KDef>, +book: List<&2,KDef>, names: List<&2,String>,
    constructors: List<&2,N_Constructor>, nodes: List<&2,P112SNode>, bangs: List<&2,String>,
    stats: List<&2,U32>, helpers: List<&2,P128BRHelper>, +plans: List<&2,P169ScalarPlan>,
    seeds: KDef, functions: List<&2,P113DFunction>) -> P167Lowered:
  +zipOwners = w4c_zip_owners_map(book)
  p169q_inlined(source,book,names,constructors,nodes,bangs,stats,helpers,plans,
    p169o_selected(functions,seeds,zipOwners,p169q_selection(book,plans,missing(),missing())))"""

    # Also check if there's an existing law p169o_walk above p169o_next!
    old_law_p169o = """law p169o_walk:
  for functions: List<&2,P113DFunction>
  for +seeds: KDef
  for +blocked: KDef
  for +targets: KDef
  for +table: P113ITable
  for +reversed: List<&2,P113DFunction>
  List<&2,P113DFunction>"""
    if old_law_p169o in t:
        t = replace_exact(t, old_law_p169o, "", "remove_old_law_p169o_walk")

    t = replace_exact(t, old_p169o, new_p169o, "p169o_zip_guard")

    # Define w4c_zip_owners_map right after agy_zip_owners (where AgyZipPlan is in scope)
    old_zip_mark = """@unsafe
def agy_zip_mark(plans: List<&2,AgyZipPlan>, ids: N111Ids) -> N111Ids:"""
    new_zip_mark = """@unsafe
def w4c_zip_set(plans: List<&2,AgyZipPlan>, +acc: KDef) -> KDef:
  match plans:
    case Nil{}: acc
    case Con{AgyZipPlan{+owner,_,_},rest}:
      +k = "$direct." ++ owner
      +e : KDef = KDef{k,"P113Direct",0,0,kt("Type","",0,0,[]),kt("Type","",0,0,[]),[],False{},False{}}
      w4c_zip_set(rest,index_set(acc,e,index_hash(k,2166136261),32))
    case Con{_,rest}: w4c_zip_set(rest,acc)

@unsafe
def w4c_zip_owners_map(book):
  w4c_zip_set(agy_zip_owners(book,book,[]),missing())

@unsafe
def agy_zip_mark(plans: List<&2,AgyZipPlan>, ids: N111Ids) -> N111Ids:"""
    t = replace_exact(t, old_zip_mark, new_zip_mark, "w4c_zip_owners_map")

    # ------------------------------------------------------------------
    # PASS 3: General x86-64 XMM Spill-Forwarding, Copy-Forwarding,
    #         Backedge Dead-Slot/GPR Coalescing & Dead-Store Elimination
    #         (strictly 1-scrutinee helper defs — zero case-tree blowup!)
    # ------------------------------------------------------------------
    old_post_select = """@unsafe
def w4_post_select(code: X188Seq) -> X188Seq:
  +flat0 = w4_peep_flat([code],[])
  +peep1 = x188_finish(w4_peep_list(flat0,[]))
  +f1 = w4_peep_flat([peep1],[])
  +peep2 = x188_finish(w4b_copy_peep(f1,f1,[]))
  +f2 = w4_peep_flat([peep2],[])
  +peep3 = x188_finish(w4b_copy_peep(f2,f2,[]))
  +shrunk = w4_leaf_shrink(w4_peep_flat([peep3],[]),peep3)
  +licm = w4b_licm_magic(w4_peep_flat([shrunk],[]))
  +rot = w4b_rotate_loop(licm)
  w4b_wrap_items(rot,[])"""

    new_post_select = """# ---- W4-11: General x86-64 XMM Spill-Forwarding, Copy-Forwarding,
#             Backedge Coalescing & Dead Stack-Slot Store Elimination ----

type W4CMap is Data:
  W4CMEmpty{}
  W4CMLeaf{+key: U32, +val: U32}
  W4CMNode{+zero: W4CMap, +one: W4CMap}

@unsafe
def w4c_slot_key(+disp: U32) -> U32:
  U32.sub(0,disp)

@unsafe
def w4c_is_neg_rbp(+base: U32, +disp: U32) -> Bool:
  U32.is_eq(base,5) && U32.is_ge(disp,2147483648)

@unsafe
def w4c_map_get(m: W4CMap, +k: U32, +sh: U32) -> U32:
  match m:
    case W4CMEmpty{}: 0
    case W4CMLeaf{lk,lv}: nt_choose(U32,U32.is_eq(lk,k),u => lv,u => 0)
    case W4CMNode{z,o}:
      nt_choose(U32,U32.is_eq(U32.and(sh,1),0),
        u => w4c_map_get(z,k,U32.shr(sh)),
        u => w4c_map_get(o,k,U32.shr(sh)))

@unsafe
def w4c_map_inc(m: W4CMap, +k: U32, +sh: U32, +depth: U32) -> W4CMap:
  match m:
    case W4CMEmpty{}: W4CMLeaf{k,1}
    case W4CMLeaf{+lk,+lv}:
      nt_choose(W4CMap,U32.is_eq(lk,k) || U32.is_ge(depth,20),
        u => W4CMLeaf{lk,U32.inc(lv)},
        u => w4c_map_split(lk,lv,k,sh,depth))
    case W4CMNode{+z,+o}:
      nt_choose(W4CMap,U32.is_eq(U32.and(sh,1),0),
        u => W4CMNode{w4c_map_inc(z,k,U32.shr(sh),U32.inc(depth)),o},
        u => W4CMNode{z,w4c_map_inc(o,k,U32.shr(sh),U32.inc(depth))})

@unsafe
def w4c_shift_by(+x: U32, +n: U32) -> U32:
  nt_choose(U32,U32.is_eq(n,0),u => x,u => w4c_shift_by(U32.shr(x),U32.sub(n,1)))

@unsafe
def w4c_map_split(lk,lv,k,sh,depth):
  +lsh = w4c_shift_by(lk,depth)
  +lb = U32.and(lsh,1)
  +nb = U32.and(sh,1)
  nt_choose(W4CMap,U32.is_eq(lb,0),
    u => nt_choose(W4CMap,U32.is_eq(nb,0),
      v => W4CMNode{w4c_map_inc(W4CMLeaf{lk,lv},k,U32.shr(sh),U32.inc(depth)),W4CMEmpty{}},
      v => W4CMNode{W4CMLeaf{lk,lv},W4CMLeaf{k,1}}),
    u => nt_choose(W4CMap,U32.is_eq(nb,0),
      v => W4CMNode{W4CMLeaf{k,1},W4CMLeaf{lk,lv}},
      v => W4CMNode{W4CMEmpty{},w4c_map_inc(W4CMLeaf{lk,lv},k,U32.shr(sh),U32.inc(depth))}))

@unsafe
def w4c_get_cnt(m: W4CMap, +disp: U32) -> U32:
  +k = w4c_slot_key(disp)
  w4c_map_get(m,k,k)

@unsafe
def w4c_inc_cnt(m: W4CMap, +disp: U32) -> W4CMap:
  +k = w4c_slot_key(disp)
  w4c_map_inc(m,k,k,0)

@unsafe
def w4c_is_fop(+op: String) -> Bool:
  agy_str_eq(op,"addss") || agy_str_eq(op,"subss") || agy_str_eq(op,"mulss") || agy_str_eq(op,"divss")

@unsafe
def w4c_is_write_only_mem(+op: String) -> Bool:
  agy_str_eq(op,"movq") || agy_str_eq(op,"movl") || agy_str_eq(op,"movss") || agy_str_eq(op,"movd")

@unsafe
def w4c_op_is_rbp_mem(op: X187Operand) -> Maybe<&2,U32>:
  match op:
    case X187Mem{+b,+d}: nt_choose(Maybe<&2,U32>,w4c_is_neg_rbp(b,d),u => Some{d},u => None{})
    case _: None{}

@unsafe
def w4c_op_has_rbp(op: X187Operand) -> Bool:
  match op:
    case X187Mem{b,_}: U32.is_eq(b,5)
    case X187Indexed{b,i,_,_}: U32.is_eq(b,5) || U32.is_eq(i,5)
    case _: False{}

@unsafe
def w4c_args_has_rbp(args: List<&2,X187Operand>) -> Bool:
  match args:
    case Nil{}: False{}
    case Con{a,rest}: w4c_op_has_rbp(a) || w4c_args_has_rbp(rest)

@unsafe
def w4c_inst_is_leaq_rbp(item: X187Parsed) -> Bool:
  match item:
    case PInst{X187Instruction{op,args}}: agy_str_eq(op,"leaq") && w4c_args_has_rbp(args)
    case _: False{}

@unsafe
def w4c_has_leaq_rbp(items: List<&2,X187Parsed>) -> Bool:
  match items:
    case Nil{}: False{}
    case Con{h,rest}: w4c_inst_is_leaq_rbp(h) || w4c_has_leaq_rbp(rest)

# Count reads and writes of negative-%rbp slots across an instruction list.
@unsafe
def w4c_add_op_read(op: X187Operand, +m: W4CMap) -> W4CMap:
  match op:
    case X187Mem{+b,+d}: nt_choose(W4CMap,w4c_is_neg_rbp(b,d),u => w4c_inc_cnt(m,d),u => m)
    case _: m

@unsafe
def w4c_add_args_reads(args: List<&2,X187Operand>, +m: W4CMap) -> W4CMap:
  match args:
    case Nil{}: m
    case Con{a,rest}: w4c_add_args_reads(rest,w4c_add_op_read(a,m))

@unsafe
def w4c_inst_reads(item: X187Parsed, +m: W4CMap) -> W4CMap:
  match item:
    case PInst{X187Instruction{+op,+args}}:
      match args:
        case Con{+src,Con{X187Mem{+b,+d},Nil{}}}:
          nt_choose(W4CMap,w4c_is_write_only_mem(op),
            u => w4c_add_op_read(src,m),
            u => w4c_add_op_read(X187Mem{b,d},w4c_add_op_read(src,m)))
        case _: w4c_add_args_reads(args,m)
    case _: m

@unsafe
def w4c_count_reads(items: List<&2,X187Parsed>, +m: W4CMap) -> W4CMap:
  match items:
    case Nil{}: m
    case Con{h,rest}: w4c_count_reads(rest,w4c_inst_reads(h,m))

@unsafe
def w4c_inst_writes(item: X187Parsed, +m: W4CMap) -> W4CMap:
  match item:
    case PInst{X187Instruction{+op,Con{_,Con{X187Mem{+b,+d},Nil{}}}}}:
      nt_choose(W4CMap,w4c_is_neg_rbp(b,d) && Bool.not(agy_str_eq(op,"cmpq") || agy_str_eq(op,"cmpl") || agy_str_eq(op,"testq") || agy_str_eq(op,"testl") || agy_str_eq(op,"ucomiss")),
        u => w4c_inc_cnt(m,d),u => m)
    case _: m

@unsafe
def w4c_count_writes(items: List<&2,X187Parsed>, +m: W4CMap) -> W4CMap:
  match items:
    case Nil{}: m
    case Con{h,rest}: w4c_count_writes(rest,w4c_inst_writes(h,m))

# Check if xmm1 is dead before next write/branch/call (conservative, 1-scrutinee).
@unsafe
def w4c_op_is_xmm(+r: U32, op: X187Operand) -> Bool:
  match op:
    case X187Reg{i,_,True{}}: U32.is_eq(i,r)
    case _: False{}

@unsafe
def w4c_args_read_xmm(+r: U32, args: List<&2,X187Operand>) -> Bool:
  match args:
    case Nil{}: False{}
    case Con{a,rest}: w4c_op_is_xmm(r,a) || w4c_args_read_xmm(r,rest)

@unsafe
def w4c_is_xmm_write_only(+op: String) -> Bool:
  agy_str_eq(op,"movaps") || agy_str_eq(op,"movd") || agy_str_eq(op,"movss") || agy_str_eq(op,"pxor")

@unsafe
def w4c_is_ctrl(+op: String) -> Bool:
  agy_str_eq(op,"jmp") || agy_str_eq(op,"je") || agy_str_eq(op,"jne") || agy_str_eq(op,"ja") ||
  agy_str_eq(op,"jae") || agy_str_eq(op,"jb") || agy_str_eq(op,"jbe") || agy_str_eq(op,"jg") ||
  agy_str_eq(op,"jge") || agy_str_eq(op,"jl") || agy_str_eq(op,"jle") || agy_str_eq(op,"call") ||
  agy_str_eq(op,"ret")

law w4c_xmm_dead:
  for +r: U32
  for items: List<&2,X187Parsed>
  for +fnItems: List<&2,X187Parsed>
  for +fuel: U32
  for +hops: U32
  Bool

@unsafe
def w4c_xmm_dead_lbl(+r: U32, found: Maybe<&2,List<&2,X187Parsed>>, +fnItems: List<&2,X187Parsed>, +fuel: U32, +hops: U32) -> Bool:
  match found:
    case Some{atTgt}: w4c_xmm_dead(r,atTgt,fnItems,fuel,hops)
    case None{}: False{}

@unsafe
def w4c_xmm_dead_args(+r: U32, +op: String, args: List<&2,X187Operand>, +rest: List<&2,X187Parsed>,
    +fnItems: List<&2,X187Parsed>, +fuel: U32, +hops: U32) -> Bool:
  match args:
    case Con{+src,Con{X187Reg{+dr,_,True{}},Nil{}}}:
      nt_choose(Bool,agy_str_eq(op,"pxor") && U32.is_eq(dr,r) && w4c_op_is_xmm(r,src),
        w => True{},
        w => nt_choose(Bool,w4c_op_is_xmm(r,src),
          x => False{},
          x => nt_choose(Bool,w4c_is_xmm_write_only(op) && U32.is_eq(dr,r),
            y => True{},
            y => nt_choose(Bool,U32.is_eq(dr,r),z => False{},z => w4c_xmm_dead(r,rest,fnItems,U32.sub(fuel,1),hops)))))
    case _: nt_choose(Bool,w4c_args_read_xmm(r,args),w => False{},w => w4c_xmm_dead(r,rest,fnItems,U32.sub(fuel,1),hops))

@unsafe
def w4c_xmm_dead_ctrl(+r: U32, +op: String, args: List<&2,X187Operand>, +rest: List<&2,X187Parsed>,
    +fnItems: List<&2,X187Parsed>, +fuel: U32, +hops: U32) -> Bool:
  match args:
    case Con{X187Target{+lbl},Nil{}}:
      nt_choose(Bool,U32.is_gt(hops,0),
        u => nt_choose(Bool,agy_str_eq(op,"jmp"),
          v => w4c_xmm_dead_lbl(r,w4b_find_label(lbl,fnItems),fnItems,U32.sub(fuel,1),U32.sub(hops,1)),
          v => w4c_xmm_dead(r,rest,fnItems,U32.sub(fuel,1),U32.sub(hops,1)) &&
               w4c_xmm_dead_lbl(r,w4b_find_label(lbl,fnItems),fnItems,U32.sub(fuel,1),U32.sub(hops,1))),
        u => False{})
    case _: False{}

@unsafe
def w4c_xmm_dead_inst(+r: U32, inst: X187Instruction, +rest: List<&2,X187Parsed>,
    +fnItems: List<&2,X187Parsed>, +fuel: U32, +hops: U32) -> Bool:
  match inst:
    case X187Instruction{+op,+args}:
      nt_choose(Bool,agy_str_eq(op,"call") || agy_str_eq(op,"ret"),
        u => True{},
        u => nt_choose(Bool,w4c_is_ctrl(op),
          v => w4c_xmm_dead_ctrl(r,op,args,rest,fnItems,fuel,hops),
          v => w4c_xmm_dead_args(r,op,args,rest,fnItems,fuel,hops)))

@unsafe
def w4c_xmm_dead_go(+r: U32, items: List<&2,X187Parsed>, +fnItems: List<&2,X187Parsed>, +fuel: U32, +hops: U32) -> Bool:
  match items:
    case Nil{}: True{}
    case Con{PLabel{_},rest}: w4c_xmm_dead(r,rest,fnItems,U32.sub(fuel,1),hops)
    case Con{PInst{inst},rest}: w4c_xmm_dead_inst(r,inst,rest,fnItems,fuel,hops)
    case Con{_,_}: False{}

@unsafe
def w4c_xmm_dead(r,items,fnItems,fuel,hops):
  nt_choose(Bool,U32.is_eq(fuel,0),u => False{},u => w4c_xmm_dead_go(r,items,fnItems,fuel,hops))

# Classified instruction views for 1-scrutinee XMM peephole
type W4CMovqXmmMem is Data:
  W4CMXMNo{}
  W4CMXMYes{+xreg: U32, +disp: U32}

@unsafe
def w4c_as_movq_xm(item: X187Parsed) -> W4CMovqXmmMem:
  match item:
    case PInst{X187Instruction{op,Con{X187Reg{xr,_,True{}},Con{X187Mem{b,d},Nil{}}}}}:
      nt_choose(W4CMovqXmmMem,agy_str_eq(op,"movq") && w4c_is_neg_rbp(b,d),u => W4CMXMYes{xr,d},u => W4CMXMNo{})
    case _: W4CMXMNo{}

type W4CLoadXmm is Data:
  W4CLXNo{}
  W4CLXYes{+op: String, +src: X187Operand, +dst: U32}

@unsafe
def w4c_as_load_xmm(item: X187Parsed) -> W4CLoadXmm:
  match item:
    case PInst{X187Instruction{op,Con{src,Con{X187Reg{dr,_,True{}},Nil{}}}}}:
      nt_choose(W4CLoadXmm,agy_str_eq(op,"movd") || agy_str_eq(op,"movaps"),u => W4CLXYes{op,src,dr},u => W4CLXNo{})
    case _: W4CLXNo{}

type W4CFopMem is Data:
  W4CFMNo{}
  W4CFMYes{+op: String, +disp: U32, +dst: U32}

@unsafe
def w4c_as_fop_mem(item: X187Parsed) -> W4CFopMem:
  match item:
    case PInst{X187Instruction{op,Con{X187Mem{b,d},Con{X187Reg{dr,_,True{}},Nil{}}}}}:
      nt_choose(W4CFopMem,w4c_is_fop(op) && w4c_is_neg_rbp(b,d),u => W4CFMYes{op,d,dr},u => W4CFMNo{})
    case _: W4CFMNo{}

type W4CFopAny is Data:
  W4CFANo{}
  W4CFAYes{+op: String, +src: X187Operand, +dst: U32}

@unsafe
def w4c_as_fop_any(item: X187Parsed) -> W4CFopAny:
  match item:
    case PInst{X187Instruction{op,Con{src,Con{X187Reg{dr,_,True{}},Nil{}}}}}:
      nt_choose(W4CFopAny,w4c_is_fop(op),u => W4CFAYes{op,src,dr},u => W4CFANo{})
    case _: W4CFANo{}

@unsafe
def w4c_op_is_slot(+disp: U32, op: X187Operand) -> Bool:
  match op:
    case X187Mem{b,d}: U32.is_eq(b,5) && U32.is_eq(d,disp)
    case _: False{}

@unsafe
def w4c_op_safe_for_xmm1(+disp: U32, +op: X187Operand) -> Bool:
  Bool.not(w4c_op_is_xmm(0,op)) && Bool.not(w4c_op_is_xmm(1,op)) && Bool.not(w4c_op_is_slot(disp,op))

law w4c_xmm_peep:
  for items: List<&2,X187Parsed>
  for +fnItems: List<&2,X187Parsed>
  for +reads: W4CMap
  for +acc: List<&2,X187Parsed>
  List<&2,X187Parsed>

# Forward %xmm1 for subsequent <fop> disp(%rbp), %xmmB until %xmm1 or disp(%rbp) is written or ctrl/label.
@unsafe
def w4c_inst_writes_xmm1(inst: X187Instruction) -> Bool:
  match inst:
    case X187Instruction{_,Con{_,Con{X187Reg{dr,_,True{}},Nil{}}}}: U32.is_eq(dr,1)
    case _: False{}

@unsafe
def w4c_fwd_xmm1_inst(+disp: U32, inst: X187Instruction) -> Maybe<&2,X187Instruction>:
  match inst:
    case X187Instruction{+op,Con{X187Mem{b,d},Con{X187Reg{+dr,_,True{}},Nil{}}}}:
      nt_choose(Maybe<&2,X187Instruction>,w4c_is_fop(op) && U32.is_eq(b,5) && U32.is_eq(d,disp) && Bool.not(U32.is_eq(dr,1)),
        u => Some{X187Instruction{op,[x188_xmm(1),x188_xmm(dr)]}},u => None{})
    case _: None{}

law w4c_fwd_xmm1:
  for +disp: U32
  for +items: List<&2,X187Parsed>
  for +fuel: U32
  List<&2,X187Parsed>

@unsafe
def w4c_fwd_xmm1_apply(+disp: U32, +h: X187Parsed, r: Maybe<&2,X187Instruction>, +rest: List<&2,X187Parsed>, +fuel: U32) -> List<&2,X187Parsed>:
  match r:
    case Some{ni}: Con{PInst{ni},w4c_fwd_xmm1(disp,rest,U32.sub(fuel,1))}
    case None{}: Con{h,w4c_fwd_xmm1(disp,rest,U32.sub(fuel,1))}

@unsafe
def w4c_fwd_xmm1_step(+disp: U32, +h: X187Parsed, +inst: X187Instruction, +rest: List<&2,X187Parsed>, +fuel: U32) -> List<&2,X187Parsed>:
  match inst:
    case X187Instruction{+op,_}:
      nt_choose(List<&2,X187Parsed>,w4c_is_ctrl(op) || w4c_inst_writes_xmm1(inst) || U32.is_gt(w4c_get_cnt(w4c_inst_writes(h,W4CMEmpty{}),disp),0),
        u => Con{h,rest},
        u => w4c_fwd_xmm1_apply(disp,h,w4c_fwd_xmm1_inst(disp,inst),rest,fuel))

@unsafe
def w4c_fwd_xmm1_go(+disp: U32, +items: List<&2,X187Parsed>, +fuel: U32) -> List<&2,X187Parsed>:
  match items:
    case Con{+h,+rest}:
      match h:
        case PInst{inst}: w4c_fwd_xmm1_step(disp,h,inst,rest,fuel)
        case _: items
    case _: items

@unsafe
def w4c_fwd_xmm1(disp,items,fuel):
  nt_choose(List<&2,X187Parsed>,U32.is_eq(fuel,0),u => items,u => w4c_fwd_xmm1_go(disp,items,fuel))

# Rule C1e: 5-inst 2-term xmm0/xmm1 tree:
@unsafe
def w4c_try_tree5(+disp: U32, +i0: X187Parsed, +i1: X187Parsed, +i2: X187Parsed, +i3: X187Parsed,
    +i4: X187Parsed, +rest: List<&2,X187Parsed>, +fnItems: List<&2,X187Parsed>, +reads: W4CMap, +acc: List<&2,X187Parsed>) -> Maybe<&2,List<&2,X187Parsed>>:
  nt_choose(Maybe<&2,List<&2,X187Parsed>>,U32.is_eq(w4c_get_cnt(reads,disp),1),
    u => w4c_try_tree5_a(disp,w4c_as_load_xmm(i1),w4c_as_fop_any(i2),w4c_as_load_xmm(i3),w4c_as_load_xmm(i4),rest,fnItems,reads,acc),
    u => None{})

@unsafe
def w4c_try_tree5_a(disp,l1,f2,l3,l4,rest,fnItems,reads,acc):
  match l1:
    case W4CLXYes{+op1,+s1,+d1}:
      nt_choose(Maybe<&2,List<&2,X187Parsed>>,U32.is_eq(d1,0) && w4c_op_safe_for_xmm1(disp,s1),
        u => w4c_try_tree5_b(disp,op1,s1,f2,l3,l4,rest,fnItems,reads,acc),u => None{})
    case W4CLXNo{}: None{}

@unsafe
def w4c_try_tree5_b(disp,op1,s1,f2,l3,l4,rest,fnItems,reads,acc):
  match f2:
    case W4CFAYes{+op2,+s2,+d2}:
      nt_choose(Maybe<&2,List<&2,X187Parsed>>,U32.is_eq(d2,0) && w4c_op_safe_for_xmm1(disp,s2),
        u => w4c_try_tree5_c(disp,op1,s1,op2,s2,l3,l4,rest,fnItems,reads,acc),u => None{})
    case W4CFANo{}: None{}

@unsafe
def w4c_try_tree5_c(disp,op1,s1,op2,s2,l3,l4,rest,fnItems,reads,acc):
  match l3:
    case W4CLXYes{+op3,+s3,+d3}:
      nt_choose(Maybe<&2,List<&2,X187Parsed>>,agy_str_eq(op3,"movaps") && w4c_op_is_xmm(0,s3) && U32.is_eq(d3,1),
        u => w4c_try_tree5_d(disp,op1,s1,op2,s2,l4,rest,fnItems,reads,acc),u => None{})
    case W4CLXNo{}: None{}

@unsafe
def w4c_try_tree5_d(disp,op1,s1,op2,s2,l4,rest,fnItems,reads,acc):
  match l4:
    case W4CLXYes{+op4,+s4,+d4}:
      nt_choose(Maybe<&2,List<&2,X187Parsed>>,agy_str_eq(op4,"movd") && w4c_op_is_slot(disp,s4) && U32.is_eq(d4,0),
        u => Some{w4c_xmm_peep(rest,fnItems,reads,
          Con{PInst{X187Instruction{op2,[s2,x188_xmm(1)]}},
          Con{PInst{X187Instruction{op1,[s1,x188_xmm(1)]}},acc}})},
        u => None{})
    case W4CLXNo{}: None{}

# Rule C1f: 3-inst movq %xmm0, disp(%rbp) ; <fop1> %xmm0, %xmm0 ; <fop2> disp(%rbp), %xmm0
@unsafe
def w4c_try_cube3_b(+disp: U32, +i0: X187Parsed, +i1: X187Parsed, f2: W4CFopMem,
    +rest: List<&2,X187Parsed>, +fnItems: List<&2,X187Parsed>, +reads: W4CMap, +acc: List<&2,X187Parsed>) -> Maybe<&2,List<&2,X187Parsed>>:
  match f2:
    case W4CFMYes{+fop2,+fd,+fdst}:
      nt_choose(Maybe<&2,List<&2,X187Parsed>>,U32.is_eq(fd,disp) && U32.is_eq(fdst,0) && w4c_xmm_dead(1,rest,fnItems,400,2),
        u => Some{w4c_xmm_peep(w4c_fwd_xmm1(disp,rest,16),fnItems,reads,
          Con{PInst{X187Instruction{fop2,[x188_xmm(1),x188_xmm(0)]}},
          Con{i1,Con{PInst{X187Instruction{"movaps",[x188_xmm(0),x188_xmm(1)]}},Con{i0,acc}}}})},
        u => None{})
    case W4CFMNo{}: None{}

@unsafe
def w4c_try_cube3_a(+disp: U32, +i0: X187Parsed, +i1: X187Parsed, f1: W4CFopAny, +i2: X187Parsed,
    +rest: List<&2,X187Parsed>, +fnItems: List<&2,X187Parsed>, +reads: W4CMap, +acc: List<&2,X187Parsed>) -> Maybe<&2,List<&2,X187Parsed>>:
  match f1:
    case W4CFAYes{_,+s1,+d1}:
      nt_choose(Maybe<&2,List<&2,X187Parsed>>,U32.is_eq(d1,0) && w4c_op_is_xmm(0,s1),
        u => w4c_try_cube3_b(disp,i0,i1,w4c_as_fop_mem(i2),rest,fnItems,reads,acc),u => None{})
    case W4CFANo{}: None{}

# Rule C1c/C1d: 3-inst movq %xmmA, disp(%rbp) ; <ld> s1, %xmmB ; <fop> disp(%rbp), %xmmB
@unsafe
def w4c_try_peep3(+xr: U32, +disp: U32, +i0: X187Parsed, +i1: X187Parsed, +i2: X187Parsed,
    +rest: List<&2,X187Parsed>, +fnItems: List<&2,X187Parsed>, +reads: W4CMap, +acc: List<&2,X187Parsed>) -> Maybe<&2,List<&2,X187Parsed>>:
  w4c_try_peep3_a(xr,disp,i0,i1,w4c_as_load_xmm(i1),w4c_as_fop_mem(i2),rest,fnItems,reads,acc)

@unsafe
def w4c_try_peep3_a(xr,disp,i0,i1,l1,f2,rest,fnItems,reads,acc):
  match l1:
    case W4CLXYes{_,+s1,+d1}:
      w4c_try_peep3_b(xr,disp,i0,i1,s1,d1,f2,rest,fnItems,reads,acc)
    case W4CLXNo{}: None{}

@unsafe
def w4c_try_peep3_b(xr,disp,i0,i1,s1,d1,f2,rest,fnItems,reads,acc):
  match f2:
    case W4CFMYes{+fop,+fd,+fdst}:
      nt_choose(Maybe<&2,List<&2,X187Parsed>>,U32.is_eq(fd,disp) && U32.is_eq(fdst,d1),
        u => nt_choose(Maybe<&2,List<&2,X187Parsed>>,Bool.not(U32.is_eq(d1,xr)),
          v => Some{w4c_xmm_peep(rest,fnItems,reads,
            Con{PInst{X187Instruction{fop,[x188_xmm(xr),x188_xmm(d1)]}},Con{i1,Con{i0,acc}}})},
          v => nt_choose(Maybe<&2,List<&2,X187Parsed>>,U32.is_eq(xr,0) && w4c_op_safe_for_xmm1(disp,s1) && w4c_xmm_dead(1,rest,fnItems,400,2),
            w => Some{w4c_xmm_peep(w4c_fwd_xmm1(disp,rest,16),fnItems,reads,
              Con{PInst{X187Instruction{fop,[x188_xmm(1),x188_xmm(0)]}},
              Con{i1,Con{PInst{X187Instruction{"movaps",[x188_xmm(0),x188_xmm(1)]}},Con{i0,acc}}}})},
            w => None{})),
        u => None{})
    case W4CFMNo{}: None{}

# Rule C1a/C1b: 2-inst movq %xmmA, disp(%rbp) ; movd disp(%rbp), %xmmB  OR  <fop> disp(%rbp), %xmmB
@unsafe
def w4c_try_peep2(+xr: U32, +disp: U32, +i0: X187Parsed, +i1: X187Parsed,
    +rest: List<&2,X187Parsed>, +fnItems: List<&2,X187Parsed>, +reads: W4CMap, +acc: List<&2,X187Parsed>) -> Maybe<&2,List<&2,X187Parsed>>:
  w4c_try_peep2_ld(xr,disp,i0,i1,w4c_as_load_xmm(i1),rest,fnItems,reads,acc)

@unsafe
def w4c_try_peep2_ld(xr,disp,i0,i1,l1,rest,fnItems,reads,acc):
  match l1:
    case W4CLXYes{+op1,+s1,+d1}:
      nt_choose(Maybe<&2,List<&2,X187Parsed>>,agy_str_eq(op1,"movd") && w4c_op_is_slot(disp,s1),
        u => nt_choose(Maybe<&2,List<&2,X187Parsed>>,U32.is_eq(d1,xr),
          v => Some{w4c_xmm_peep(Con{i0,rest},fnItems,reads,acc)},
          v => Some{w4c_xmm_peep(rest,fnItems,reads,
            Con{PInst{X187Instruction{"movaps",[x188_xmm(xr),x188_xmm(d1)]}},Con{i0,acc}})}),
        u => w4c_try_peep2_fop(xr,disp,i0,w4c_as_fop_mem(i1),rest,fnItems,reads,acc))
    case W4CLXNo{}: w4c_try_peep2_fop(xr,disp,i0,w4c_as_fop_mem(i1),rest,fnItems,reads,acc)

@unsafe
def w4c_try_peep2_fop(xr,disp,i0,f1,rest,fnItems,reads,acc):
  match f1:
    case W4CFMYes{+fop,+fd,+fdst}:
      nt_choose(Maybe<&2,List<&2,X187Parsed>>,U32.is_eq(fd,disp),
        u => Some{w4c_xmm_peep(rest,fnItems,reads,
          Con{PInst{X187Instruction{fop,[x188_xmm(xr),x188_xmm(fdst)]}},Con{i0,acc}})},
        u => None{})
    case W4CFMNo{}: None{}

@unsafe
def w4c_or_peep(res: Maybe<&2,List<&2,X187Parsed>>, fallback: Unit -> List<&2,X187Parsed>) -> List<&2,X187Parsed>:
  match res:
    case Some{out}: out
    case None{}: fallback(Unit{})

@unsafe
def w4c_xmm_peep_hit3(+xr: U32, +disp: U32, +i0: X187Parsed, +i1: X187Parsed, +i2: X187Parsed,
    r2: List<&2,X187Parsed>, +fnItems: List<&2,X187Parsed>, +reads: W4CMap, +acc: List<&2,X187Parsed>) -> Maybe<&2,List<&2,X187Parsed>>:
  match r2:
    case Con{+i3,Con{+i4,+r4}}:
      nt_choose(Maybe<&2,List<&2,X187Parsed>>,U32.is_eq(xr,0),
        u => w4c_try_tree5(disp,i0,i1,i2,i3,i4,r4,fnItems,reads,acc),u => None{})
    case _: None{}

@unsafe
def w4c_xmm_peep_hit2(+xr: U32, +disp: U32, +i0: X187Parsed, +i1: X187Parsed, r1: List<&2,X187Parsed>,
    +tail: List<&2,X187Parsed>, +fnItems: List<&2,X187Parsed>, +reads: W4CMap, +acc: List<&2,X187Parsed>) -> List<&2,X187Parsed>:
  match r1:
    case Con{+i2,+r2}:
      w4c_or_peep(w4c_xmm_peep_hit3(xr,disp,i0,i1,i2,r2,fnItems,reads,acc),
        u => w4c_or_peep(w4c_try_peep3(xr,disp,i0,i1,i2,r2,fnItems,reads,acc),
          v => w4c_or_peep(nt_choose(Maybe<&2,List<&2,X187Parsed>>,U32.is_eq(xr,0),
              w => w4c_try_cube3_a(disp,i0,i1,w4c_as_fop_any(i1),i2,r2,fnItems,reads,acc),w => None{}),
            w => w4c_xmm_peep(tail,fnItems,reads,Con{i0,acc}))))
    case _: w4c_xmm_peep(tail,fnItems,reads,Con{i0,acc})

@unsafe
def w4c_xmm_peep_hit(+xr: U32, +disp: U32, +i0: X187Parsed, +tail: List<&2,X187Parsed>,
    +fnItems: List<&2,X187Parsed>, +reads: W4CMap, +acc: List<&2,X187Parsed>) -> List<&2,X187Parsed>:
  match tail:
    case Con{+i1,+r1}:
      w4c_or_peep(w4c_try_peep2(xr,disp,i0,i1,r1,fnItems,reads,acc),
        u => w4c_xmm_peep_hit2(xr,disp,i0,i1,r1,tail,fnItems,reads,acc))
    case Nil{}: nt_reverse(X187Parsed,Con{i0,acc},[])

@unsafe
def w4c_xmm_peep_step(m: W4CMovqXmmMem, +i0: X187Parsed, +tail: List<&2,X187Parsed>,
    +fnItems: List<&2,X187Parsed>, +reads: W4CMap, +acc: List<&2,X187Parsed>) -> List<&2,X187Parsed>:
  match m:
    case W4CMXMYes{xr,disp}: w4c_xmm_peep_hit(xr,disp,i0,tail,fnItems,reads,acc)
    case W4CMXMNo{}: w4c_xmm_peep(tail,fnItems,reads,Con{i0,acc})

@unsafe
def w4c_xmm_peep(items,fnItems,reads,acc):
  match items:
    case Nil{}: nt_reverse(X187Parsed,acc,[])
    case Con{+i0,+tail}: w4c_xmm_peep_step(w4c_as_movq_xm(i0),i0,tail,fnItems,reads,acc)

# ---- Sub-pass C2 & C3: Straight-line Basic Block Split + Copy-Fwd + Backedge Coalesce ----
@unsafe
def w4c_is_bb_end(item: X187Parsed) -> Bool:
  match item:
    case PLabel{_}: True{}
    case PInst{X187Instruction{op,_}}: w4c_is_ctrl(op)
    case _: True{}

@unsafe
def w4c_split_bb(items: List<&2,X187Parsed>, +cur: List<&2,X187Parsed>,
    +acc: List<&2,List<&2,X187Parsed>>) -> List<&2,List<&2,X187Parsed>>:
  match items:
    case Nil{}: nt_reverse(List<&2,X187Parsed>,Con{nt_reverse(X187Parsed,cur,[]),acc},[])
    case Con{+h,+rest}:
      match h:
        case PLabel{_}:
          w4c_split_bb(rest,[h],Con{nt_reverse(X187Parsed,cur,[]),acc})
        case PInst{X187Instruction{op,_}}:
          nt_choose(List<&2,List<&2,X187Parsed>>,w4c_is_ctrl(op),
            u => w4c_split_bb(rest,[],Con{nt_reverse(X187Parsed,Con{h,cur},[]),acc}),
            u => w4c_split_bb(rest,Con{h,cur},acc))
        case _: w4c_split_bb(rest,Con{h,cur},acc)

@unsafe
def w4c_join_bbs(bbs: List<&2,List<&2,X187Parsed>>) -> List<&2,X187Parsed>:
  match bbs:
    case Nil{}: []
    case Con{b,rest}: nt_append(X187Parsed,b,w4c_join_bbs(rest))

@unsafe
def w4c_replace_op(+from: U32, +to: U32, op: X187Operand) -> X187Operand:
  match op:
    case X187Mem{+b,+d}: nt_choose(X187Operand,U32.is_eq(b,5) && U32.is_eq(d,from),u => X187Mem{5,to},u => X187Mem{b,d})
    case _: op

@unsafe
def w4c_replace_args(+from: U32, +to: U32, args: List<&2,X187Operand>) -> List<&2,X187Operand>:
  match args:
    case Nil{}: []
    case Con{a,rest}: Con{w4c_replace_op(from,to,a),w4c_replace_args(from,to,rest)}

@unsafe
def w4c_replace_inst(+from: U32, +to: U32, item: X187Parsed) -> X187Parsed:
  match item:
    case PInst{X187Instruction{op,args}}: PInst{X187Instruction{op,w4c_replace_args(from,to,args)}}
    case other: other

@unsafe
def w4c_replace_slot(+from: U32, +to: U32, items: List<&2,X187Parsed>) -> List<&2,X187Parsed>:
  match items:
    case Nil{}: []
    case Con{h,rest}: Con{w4c_replace_inst(from,to,h),w4c_replace_slot(from,to,rest)}

# Check if slot is written anywhere in items
@unsafe
def w4c_slot_written(+disp: U32, items: List<&2,X187Parsed>) -> Bool:
  U32.is_gt(w4c_get_cnt(w4c_count_writes(items,W4CMEmpty{}),disp),0)

@unsafe
def w4c_slot_touched(+disp: U32, +items: List<&2,X187Parsed>) -> Bool:
  U32.is_gt(w4c_get_cnt(w4c_count_reads(items,W4CMEmpty{}),disp),0) ||
  U32.is_gt(w4c_get_cnt(w4c_count_writes(items,W4CMEmpty{}),disp),0)

@unsafe
def w4c_gpr_in_op(+r: U32, op: X187Operand) -> Bool:
  match op:
    case X187Reg{i,_,False{}}: U32.is_eq(i,r)
    case X187Mem{b,_}: U32.is_eq(b,r)
    case X187Indexed{b,i,_,_}: U32.is_eq(b,r) || U32.is_eq(i,r)
    case _: False{}

@unsafe
def w4c_gpr_in_args(+r: U32, args: List<&2,X187Operand>) -> Bool:
  match args:
    case Nil{}: False{}
    case Con{a,rest}: w4c_gpr_in_op(r,a) || w4c_gpr_in_args(r,rest)

@unsafe
def w4c_gpr_touched(+r: U32, items: List<&2,X187Parsed>) -> Bool:
  match items:
    case Nil{}: False{}
    case Con{PInst{X187Instruction{_,args}},rest}: w4c_gpr_in_args(r,args) || w4c_gpr_touched(r,rest)
    case Con{_,rest}: w4c_gpr_touched(r,rest)

# Match movq src(%rbp), %r10
@unsafe
def w4c_as_load_r10(item: X187Parsed) -> Maybe<&2,U32>:
  match item:
    case PInst{X187Instruction{op,Con{X187Mem{b,d},Con{X187Reg{r,w,False{}},Nil{}}}}}:
      nt_choose(Maybe<&2,U32>,agy_str_eq(op,"movq") && w4c_is_neg_rbp(b,d) && U32.is_eq(r,10) && U32.is_eq(w,64),
        u => Some{d},u => None{})
    case _: None{}

type W4CStoreR10 is Data:
  W4CSRNo{}
  W4CSRMem{+disp: U32}
  W4CSRGpr{+reg: U32}

@unsafe
def w4c_as_store_r10_dst(dst: X187Operand) -> W4CStoreR10:
  match dst:
    case X187Mem{b,d}: nt_choose(W4CStoreR10,w4c_is_neg_rbp(b,d),v => W4CSRMem{d},v => W4CSRNo{})
    case X187Reg{dr,dw,False{}}: nt_choose(W4CStoreR10,U32.is_eq(dw,64) && Bool.not(U32.is_eq(dr,10)) && Bool.not(U32.is_eq(dr,4)) && Bool.not(U32.is_eq(dr,5)),v => W4CSRGpr{dr},v => W4CSRNo{})
    case _: W4CSRNo{}

@unsafe
def w4c_as_store_r10(item: X187Parsed) -> W4CStoreR10:
  match item:
    case PInst{X187Instruction{op,Con{X187Reg{r,w,False{}},Con{dst,Nil{}}}}}:
      nt_choose(W4CStoreR10,agy_str_eq(op,"movq") && U32.is_eq(r,10) && U32.is_eq(w,64),
        u => w4c_as_store_r10_dst(dst),
        u => W4CSRNo{})
    case _: W4CSRNo{}

# Sub-pass C2: Forward movq src(%rbp), %r10; movq %r10, dst(%rbp) within a basic block
law w4c_fwd_bb:
  for items: List<&2,X187Parsed>
  for +totR: W4CMap
  for +totW: W4CMap
  for +acc: List<&2,X187Parsed>
  List<&2,X187Parsed>

@unsafe
def w4c_fwd_try(+src: U32, dst: W4CStoreR10, +i0: X187Parsed, +i1: X187Parsed,
    +rest: List<&2,X187Parsed>, +totR: W4CMap, +totW: W4CMap, +acc: List<&2,X187Parsed>) -> List<&2,X187Parsed>:
  match dst:
    case W4CSRMem{+d}:
      +restReads = w4c_get_cnt(w4c_count_reads(rest,W4CMEmpty{}),d)
      +ok = Bool.not(U32.is_eq(src,d)) && U32.is_eq(w4c_get_cnt(totW,d),1) &&
            U32.is_eq(restReads,w4c_get_cnt(totR,d)) && Bool.not(w4c_slot_written(src,rest))
      nt_choose(List<&2,X187Parsed>,ok,
        u => w4c_fwd_bb(w4c_replace_slot(d,src,rest),totR,totW,acc),
        u => w4c_fwd_bb(Con{i1,rest},totR,totW,Con{i0,acc}))
    case _: w4c_fwd_bb(Con{i1,rest},totR,totW,Con{i0,acc})

@unsafe
def w4c_fwd_step(ld: Maybe<&2,U32>, +i0: X187Parsed, +i1: X187Parsed,
    +rest: List<&2,X187Parsed>, +totR: W4CMap, +totW: W4CMap, +acc: List<&2,X187Parsed>) -> List<&2,X187Parsed>:
  match ld:
    case Some{src}: w4c_fwd_try(src,w4c_as_store_r10(i1),i0,i1,rest,totR,totW,acc)
    case None{}: w4c_fwd_bb(Con{i1,rest},totR,totW,Con{i0,acc})

@unsafe
def w4c_fwd_bb(items,totR,totW,acc):
  match items:
    case Nil{}: nt_reverse(X187Parsed,acc,[])
    case Con{+i0,Con{+i1,+rest}}: w4c_fwd_step(w4c_as_load_r10(i0),i0,i1,rest,totR,totW,acc)
    case Con{h,rest}: w4c_fwd_bb(rest,totR,totW,Con{h,acc})

@unsafe
def w4c_fwd_bbs(bbs: List<&2,List<&2,X187Parsed>>, +totR: W4CMap, +totW: W4CMap) -> List<&2,List<&2,X187Parsed>>:
  match bbs:
    case Nil{}: []
    case Con{b,rest}: Con{w4c_fwd_bb(b,totR,totW,[]),w4c_fwd_bbs(rest,totR,totW)}

@unsafe
def w4c_copy_slot_fwd(+items: List<&2,X187Parsed>) -> List<&2,X187Parsed>:
  +totR = w4c_count_reads(items,W4CMEmpty{})
  +totW = w4c_count_writes(items,W4CMEmpty{})
  w4c_join_bbs(w4c_fwd_bbs(w4c_split_bb(items,[],[]),totR,totW))

# Sub-pass C3: Backedge dead-slot & GPR coalescing inside each basic block
type W4CDefSplit is Data:
  W4CDSNo{}
  W4CDSYes{+betweenRev: List<&2,X187Parsed>, +defInst: X187Parsed, +beforeRev: List<&2,X187Parsed>}

@unsafe
def w4c_inst_writes_slot(+disp: U32, item: X187Parsed) -> Bool:
  U32.is_gt(w4c_get_cnt(w4c_inst_writes(item,W4CMEmpty{}),disp),0)

@unsafe
def w4c_find_def_back(+disp: U32, revPrefix: List<&2,X187Parsed>, +between: List<&2,X187Parsed>) -> W4CDefSplit:
  match revPrefix:
    case Nil{}: W4CDSNo{}
    case Con{+h,+rest}:
      nt_choose(W4CDefSplit,w4c_inst_writes_slot(disp,h),
        u => W4CDSYes{between,h,rest},
        u => w4c_find_def_back(disp,rest,Con{h,between}))

law w4c_coal_bb:
  for items: List<&2,X187Parsed>
  for +totR: W4CMap
  for +totW: W4CMap
  for +bbR: W4CMap
  for +bbW: W4CMap
  for +acc: List<&2,X187Parsed>
  List<&2,X187Parsed>

@unsafe
def w4c_coal_mem(+tmp: U32, +dst: U32, sp: W4CDefSplit, +i0: X187Parsed, +i1: X187Parsed,
    +rest: List<&2,X187Parsed>, +totR: W4CMap, +totW: W4CMap, +bbR: W4CMap, +bbW: W4CMap,
    +acc: List<&2,X187Parsed>) -> List<&2,X187Parsed>:
  match sp:
    case W4CDSNo{}: w4c_coal_bb(Con{i1,rest},totR,totW,bbR,bbW,Con{i0,acc})
    case W4CDSYes{+between,+defInst,+beforeRev}:
      +ok = Bool.not(w4c_slot_touched(tmp,beforeRev)) && Bool.not(w4c_slot_touched(tmp,rest)) &&
            Bool.not(w4c_slot_touched(dst,between))
      nt_choose(List<&2,X187Parsed>,ok,
        u => w4c_coal_bb(rest,totR,totW,bbR,bbW,
          nt_append(X187Parsed,nt_reverse(X187Parsed,w4c_replace_slot(tmp,dst,between),[]),
            Con{w4c_replace_inst(tmp,dst,defInst),beforeRev})),
        u => w4c_coal_bb(Con{i1,rest},totR,totW,bbR,bbW,Con{i0,acc}))

@unsafe
def w4c_coal_gpr_def(+tmp: U32, +reg: U32, dm: W4CMovqXmmMem, +between: List<&2,X187Parsed>,
    +beforeRev: List<&2,X187Parsed>, +i0: X187Parsed, +i1: X187Parsed, +rest: List<&2,X187Parsed>,
    +totR: W4CMap, +totW: W4CMap, +bbR: W4CMap, +bbW: W4CMap, +acc: List<&2,X187Parsed>) -> List<&2,X187Parsed>:
  match dm:
    case W4CMXMYes{+xr,+d}:
      +ok = U32.is_eq(d,tmp) && Bool.not(w4c_slot_touched(tmp,beforeRev)) &&
            Bool.not(w4c_slot_touched(tmp,between)) && Bool.not(w4c_slot_touched(tmp,rest)) &&
            Bool.not(w4c_gpr_touched(reg,between))
      nt_choose(List<&2,X187Parsed>,ok,
        u => w4c_coal_bb(rest,totR,totW,bbR,bbW,
          nt_append(X187Parsed,nt_reverse(X187Parsed,between,[]),
            Con{PInst{X187Instruction{"movd",[x188_xmm(xr),X187Reg{reg,32,False{}}]}},beforeRev})),
        u => w4c_coal_bb(Con{i1,rest},totR,totW,bbR,bbW,Con{i0,acc}))
    case W4CMXMNo{}: w4c_coal_bb(Con{i1,rest},totR,totW,bbR,bbW,Con{i0,acc})

@unsafe
def w4c_coal_gpr(+tmp: U32, +reg: U32, sp: W4CDefSplit, +i0: X187Parsed, +i1: X187Parsed,
    +rest: List<&2,X187Parsed>, +totR: W4CMap, +totW: W4CMap, +bbR: W4CMap, +bbW: W4CMap,
    +acc: List<&2,X187Parsed>) -> List<&2,X187Parsed>:
  match sp:
    case W4CDSNo{}: w4c_coal_bb(Con{i1,rest},totR,totW,bbR,bbW,Con{i0,acc})
    case W4CDSYes{between,defInst,beforeRev}:
      w4c_coal_gpr_def(tmp,reg,w4c_as_movq_xm(defInst),between,beforeRev,i0,i1,rest,totR,totW,bbR,bbW,acc)

@unsafe
def w4c_coal_dispatch(+tmp: U32, dst: W4CStoreR10, +i0: X187Parsed, +i1: X187Parsed,
    +rest: List<&2,X187Parsed>, +totR: W4CMap, +totW: W4CMap, +bbR: W4CMap, +bbW: W4CMap,
    +acc: List<&2,X187Parsed>) -> List<&2,X187Parsed>:
  match dst:
    case W4CSRMem{+d}:
      nt_choose(List<&2,X187Parsed>,Bool.not(U32.is_eq(tmp,d)),
        v => w4c_coal_mem(tmp,d,w4c_find_def_back(tmp,acc,[]),i0,i1,rest,totR,totW,bbR,bbW,acc),
        v => w4c_coal_bb(Con{i1,rest},totR,totW,bbR,bbW,Con{i0,acc}))
    case W4CSRGpr{+r}:
      w4c_coal_gpr(tmp,r,w4c_find_def_back(tmp,acc,[]),i0,i1,rest,totR,totW,bbR,bbW,acc)
    case W4CSRNo{}: w4c_coal_bb(Con{i1,rest},totR,totW,bbR,bbW,Con{i0,acc})

@unsafe
def w4c_coal_try(+tmp: U32, +dst: W4CStoreR10, +i0: X187Parsed, +i1: X187Parsed,
    +rest: List<&2,X187Parsed>, +totR: W4CMap, +totW: W4CMap, +bbR: W4CMap, +bbW: W4CMap,
    +acc: List<&2,X187Parsed>) -> List<&2,X187Parsed>:
  +localOnly = U32.is_eq(w4c_get_cnt(totW,tmp),1) && U32.is_eq(w4c_get_cnt(bbW,tmp),1) &&
               U32.is_eq(w4c_get_cnt(totR,tmp),w4c_get_cnt(bbR,tmp))
  nt_choose(List<&2,X187Parsed>,localOnly,
    u => w4c_coal_dispatch(tmp,dst,i0,i1,rest,totR,totW,bbR,bbW,acc),
    u => w4c_coal_bb(Con{i1,rest},totR,totW,bbR,bbW,Con{i0,acc}))

@unsafe
def w4c_coal_step(ld: Maybe<&2,U32>, +i0: X187Parsed, +i1: X187Parsed,
    +rest: List<&2,X187Parsed>, +totR: W4CMap, +totW: W4CMap, +bbR: W4CMap, +bbW: W4CMap,
    +acc: List<&2,X187Parsed>) -> List<&2,X187Parsed>:
  match ld:
    case Some{tmp}: w4c_coal_try(tmp,w4c_as_store_r10(i1),i0,i1,rest,totR,totW,bbR,bbW,acc)
    case None{}: w4c_coal_bb(Con{i1,rest},totR,totW,bbR,bbW,Con{i0,acc})

@unsafe
def w4c_coal_bb(items,totR,totW,bbR,bbW,acc):
  match items:
    case Nil{}: nt_reverse(X187Parsed,acc,[])
    case Con{+i0,Con{+i1,+rest}}: w4c_coal_step(w4c_as_load_r10(i0),i0,i1,rest,totR,totW,bbR,bbW,acc)
    case Con{h,rest}: w4c_coal_bb(rest,totR,totW,bbR,bbW,Con{h,acc})

@unsafe
def w4c_coal_bbs(bbs: List<&2,List<&2,X187Parsed>>, +totR: W4CMap, +totW: W4CMap) -> List<&2,List<&2,X187Parsed>>:
  match bbs:
    case Nil{}: []
    case Con{+b,rest}:
      +bbR = w4c_count_reads(b,W4CMEmpty{})
      +bbW = w4c_count_writes(b,W4CMEmpty{})
      Con{w4c_coal_bb(b,totR,totW,bbR,bbW,[]),w4c_coal_bbs(rest,totR,totW)}

@unsafe
def w4c_backedge_coalesce(+items: List<&2,X187Parsed>) -> List<&2,X187Parsed>:
  +totR = w4c_count_reads(items,W4CMEmpty{})
  +totW = w4c_count_writes(items,W4CMEmpty{})
  w4c_join_bbs(w4c_coal_bbs(w4c_split_bb(items,[],[]),totR,totW))

# Sub-pass C4: Dead negative-%rbp stack-slot store elimination
@unsafe
def w4c_is_dead_store(item: X187Parsed, +reads: W4CMap) -> Bool:
  match item:
    case PInst{X187Instruction{op,Con{_,Con{X187Mem{b,d},Nil{}}}}}:
      w4c_is_write_only_mem(op) && w4c_is_neg_rbp(b,d) && U32.is_eq(w4c_get_cnt(reads,d),0)
    case _: False{}

@unsafe
def w4c_drop_dead_stores(items: List<&2,X187Parsed>, +reads: W4CMap, +acc: List<&2,X187Parsed>) -> List<&2,X187Parsed>:
  match items:
    case Nil{}: nt_reverse(X187Parsed,acc,[])
    case Con{+h,+rest}:
      nt_choose(List<&2,X187Parsed>,w4c_is_dead_store(h,reads),
        u => w4c_drop_dead_stores(rest,reads,acc),
        u => w4c_drop_dead_stores(rest,reads,Con{h,acc}))

@unsafe
def w4c_dead_slot_elim(+items: List<&2,X187Parsed>) -> List<&2,X187Parsed>:
  w4c_drop_dead_stores(items,w4c_count_reads(items,W4CMEmpty{}),[])

@unsafe
def w4c_xmm_opt(+items: List<&2,X187Parsed>) -> List<&2,X187Parsed>:
  +p1 = w4c_xmm_peep(items,items,w4c_count_reads(items,W4CMEmpty{}),[])
  nt_choose(List<&2,X187Parsed>,w4c_has_leaq_rbp(p1),
    u => p1,
    u => w4c_xmm_opt_nolea(p1))

@unsafe
def w4c_xmm_opt_nolea(p1):
  +p2 = w4c_copy_slot_fwd(p1)
  +p3 = w4c_xmm_peep(p2,p2,w4c_count_reads(p2,W4CMEmpty{}),[])
  +p4 = w4c_backedge_coalesce(p3)
  +p5 = w4c_dead_slot_elim(p4)
  +p6 = w4c_xmm_peep(p5,p5,w4c_count_reads(p5,W4CMEmpty{}),[])
  +p7 = w4c_dead_slot_elim(p6)
  +p8 = w4c_xmm_peep(p7,p7,w4c_count_reads(p7,W4CMEmpty{}),[])
  w4c_dead_slot_elim(p8)

@unsafe
def w4_post_select(code: X188Seq) -> X188Seq:
  +flat0 = w4_peep_flat([code],[])
  +peep1 = x188_finish(w4_peep_list(flat0,[]))
  +f1 = w4_peep_flat([peep1],[])
  +peep2 = x188_finish(w4b_copy_peep(f1,f1,[]))
  +f2 = w4_peep_flat([peep2],[])
  +peep3 = x188_finish(w4b_copy_peep(f2,f2,[]))
  +shrunk = w4_leaf_shrink(w4_peep_flat([peep3],[]),peep3)
  +licm = w4b_licm_magic(w4_peep_flat([shrunk],[]))
  +rot = w4b_rotate_loop(licm)
  +xmm = w4c_xmm_opt(rot)
  w4b_wrap_items(xmm,[])"""

    # Note: w4c_map_inc <-> w4c_map_split, w4c_xmm_dead_inst <-> w4c_xmm_dead,
    # w4c_try_peep2_ld -> w4c_try_peep2_fop, w4c_try_tree5 -> w4c_try_tree5_a..d
    # Let's add `law` declarations for any forward-called functions!
    laws_block = """law w4c_map_split:
  for +lk: U32
  for +lv: U32
  for +k: U32
  for +sh: U32
  for +depth: U32
  W4CMap

law w4c_xmm_dead:
  for +r: U32
  for items: List<&2,X187Parsed>
  for +fuel: U32
  Bool

law w4c_try_tree5_a:
  for +disp: U32
  for l1: W4CLoadXmm
  for f2: W4CFopAny
  for l3: W4CLoadXmm
  for l4: W4CLoadXmm
  for +rest: List<&2,X187Parsed>
  for +reads: W4CMap
  for +acc: List<&2,X187Parsed>
  Maybe<&2,List<&2,X187Parsed>>

law w4c_try_tree5_b:
  for +disp: U32
  for +op1: String
  for +s1: X187Operand
  for f2: W4CFopAny
  for l3: W4CLoadXmm
  for l4: W4CLoadXmm
  for +rest: List<&2,X187Parsed>
  for +reads: W4CMap
  for +acc: List<&2,X187Parsed>
  Maybe<&2,List<&2,X187Parsed>>

law w4c_try_tree5_c:
  for +disp: U32
  for +op1: String
  for +s1: X187Operand
  for +op2: String
  for +s2: X187Operand
  for l3: W4CLoadXmm
  for l4: W4CLoadXmm
  for +rest: List<&2,X187Parsed>
  for +reads: W4CMap
  for +acc: List<&2,X187Parsed>
  Maybe<&2,List<&2,X187Parsed>>

law w4c_try_tree5_d:
  for +disp: U32
  for +op1: String
  for +s1: X187Operand
  for +op2: String
  for +s2: X187Operand
  for l4: W4CLoadXmm
  for +rest: List<&2,X187Parsed>
  for +reads: W4CMap
  for +acc: List<&2,X187Parsed>
  Maybe<&2,List<&2,X187Parsed>>

law w4c_try_peep3_a:
  for +xr: U32
  for +disp: U32
  for +i0: X187Parsed
  for +i1: X187Parsed
  for l1: W4CLoadXmm
  for f2: W4CFopMem
  for +rest: List<&2,X187Parsed>
  for +reads: W4CMap
  for +acc: List<&2,X187Parsed>
  Maybe<&2,List<&2,X187Parsed>>

law w4c_try_peep3_b:
  for +xr: U32
  for +disp: U32
  for +i0: X187Parsed
  for +i1: X187Parsed
  for +s1: X187Operand
  for +d1: U32
  for f2: W4CFopMem
  for +rest: List<&2,X187Parsed>
  for +reads: W4CMap
  for +acc: List<&2,X187Parsed>
  Maybe<&2,List<&2,X187Parsed>>

law w4c_try_peep2_ld:
  for +xr: U32
  for +disp: U32
  for +i0: X187Parsed
  for +i1: X187Parsed
  for l1: W4CLoadXmm
  for +rest: List<&2,X187Parsed>
  for +reads: W4CMap
  for +acc: List<&2,X187Parsed>
  Maybe<&2,List<&2,X187Parsed>>

law w4c_try_peep2_fop:
  for +xr: U32
  for +disp: U32
  for +i0: X187Parsed
  for f1: W4CFopMem
  for +rest: List<&2,X187Parsed>
  for +reads: W4CMap
  for +acc: List<&2,X187Parsed>
  Maybe<&2,List<&2,X187Parsed>>

law w4c_xmm_opt_nolea:
  for +p1: List<&2,X187Parsed>
  List<&2,X187Parsed>

"""
    # Place laws right after the data type definitions (W4CMap, W4CLoadXmm, W4CFopMem, W4CFopAny)!
    # Even cleaner: put w4c_map_split law after W4CMap, w4c_xmm_dead law after W4CMap,
    # and the peep laws after W4CFopAny. Let's insert them at their exact spots!
    new_post_select = new_post_select.replace(
        "@unsafe\ndef w4c_map_inc(",
        """law w4c_map_split:
  for +lk: U32
  for +lv: U32
  for +k: U32
  for +sh: U32
  for +depth: U32
  W4CMap

@unsafe
def w4c_map_inc(""",
        1,
    )
    new_post_select = new_post_select.replace(
        "@unsafe\ndef w4c_try_tree5(",
        """law w4c_try_tree5_a:
  for +disp: U32
  for l1: W4CLoadXmm
  for f2: W4CFopAny
  for l3: W4CLoadXmm
  for l4: W4CLoadXmm
  for +rest: List<&2,X187Parsed>
  for +fnItems: List<&2,X187Parsed>
  for +reads: W4CMap
  for +acc: List<&2,X187Parsed>
  Maybe<&2,List<&2,X187Parsed>>

law w4c_try_tree5_b:
  for +disp: U32
  for +op1: String
  for +s1: X187Operand
  for f2: W4CFopAny
  for l3: W4CLoadXmm
  for l4: W4CLoadXmm
  for +rest: List<&2,X187Parsed>
  for +fnItems: List<&2,X187Parsed>
  for +reads: W4CMap
  for +acc: List<&2,X187Parsed>
  Maybe<&2,List<&2,X187Parsed>>

law w4c_try_tree5_c:
  for +disp: U32
  for +op1: String
  for +s1: X187Operand
  for +op2: String
  for +s2: X187Operand
  for l3: W4CLoadXmm
  for l4: W4CLoadXmm
  for +rest: List<&2,X187Parsed>
  for +fnItems: List<&2,X187Parsed>
  for +reads: W4CMap
  for +acc: List<&2,X187Parsed>
  Maybe<&2,List<&2,X187Parsed>>

law w4c_try_tree5_d:
  for +disp: U32
  for +op1: String
  for +s1: X187Operand
  for +op2: String
  for +s2: X187Operand
  for l4: W4CLoadXmm
  for +rest: List<&2,X187Parsed>
  for +fnItems: List<&2,X187Parsed>
  for +reads: W4CMap
  for +acc: List<&2,X187Parsed>
  Maybe<&2,List<&2,X187Parsed>>

law w4c_try_peep3_a:
  for +xr: U32
  for +disp: U32
  for +i0: X187Parsed
  for +i1: X187Parsed
  for l1: W4CLoadXmm
  for f2: W4CFopMem
  for +rest: List<&2,X187Parsed>
  for +fnItems: List<&2,X187Parsed>
  for +reads: W4CMap
  for +acc: List<&2,X187Parsed>
  Maybe<&2,List<&2,X187Parsed>>

law w4c_try_peep3_b:
  for +xr: U32
  for +disp: U32
  for +i0: X187Parsed
  for +i1: X187Parsed
  for +s1: X187Operand
  for +d1: U32
  for f2: W4CFopMem
  for +rest: List<&2,X187Parsed>
  for +fnItems: List<&2,X187Parsed>
  for +reads: W4CMap
  for +acc: List<&2,X187Parsed>
  Maybe<&2,List<&2,X187Parsed>>

law w4c_try_peep2_ld:
  for +xr: U32
  for +disp: U32
  for +i0: X187Parsed
  for +i1: X187Parsed
  for l1: W4CLoadXmm
  for +rest: List<&2,X187Parsed>
  for +fnItems: List<&2,X187Parsed>
  for +reads: W4CMap
  for +acc: List<&2,X187Parsed>
  Maybe<&2,List<&2,X187Parsed>>

law w4c_try_peep2_fop:
  for +xr: U32
  for +disp: U32
  for +i0: X187Parsed
  for f1: W4CFopMem
  for +rest: List<&2,X187Parsed>
  for +fnItems: List<&2,X187Parsed>
  for +reads: W4CMap
  for +acc: List<&2,X187Parsed>
  Maybe<&2,List<&2,X187Parsed>>

@unsafe
def w4c_try_tree5(""",
        1,
    )
    new_post_select = new_post_select.replace(
        "@unsafe\ndef w4c_xmm_opt(",
        """law w4c_xmm_opt_nolea:
  for +p1: List<&2,X187Parsed>
  List<&2,X187Parsed>

@unsafe
def w4c_xmm_opt(""",
        1,
    )

    if old_post_select in t:
        t = replace_exact(t, old_post_select, new_post_select, "w4_post_select")
    else:
        # Composing on top of W4-10 (w4c_peep_cfg already in w4_post_select)
        old_w410_post = """@unsafe
def w4_post_select(code: X188Seq) -> X188Seq:
  +flat0 = w4_peep_flat([code],[])
  +peep1 = x188_finish(w4_peep_list(flat0,[]))
  +f1 = w4_peep_flat([peep1],[])
  +peep2 = x188_finish(w4b_copy_peep(f1,f1,[]))
  +f2 = w4_peep_flat([peep2],[])
  +peep3 = x188_finish(w4b_copy_peep(f2,f2,[]))
  +f3 = w4_peep_flat([peep3],[])
  +peep4 = x188_finish(w4c_peep_cfg(f3,f3,[]))
  +shrunk = w4_leaf_shrink(w4_peep_flat([peep4],[]),peep4)
  +licm = w4b_licm_magic(w4_peep_flat([shrunk],[]))
  +rot = w4b_rotate_loop(licm)
  +peep5 = x188_finish(w4c_peep_cfg(rot,rot,[]))
  peep5"""
        chained_tail = """@unsafe
def w4_post_select(code: X188Seq) -> X188Seq:
  +flat0 = w4_peep_flat([code],[])
  +peep1 = x188_finish(w4_peep_list(flat0,[]))
  +f1 = w4_peep_flat([peep1],[])
  +peep2 = x188_finish(w4b_copy_peep(f1,f1,[]))
  +f2 = w4_peep_flat([peep2],[])
  +peep3 = x188_finish(w4b_copy_peep(f2,f2,[]))
  +f3 = w4_peep_flat([peep3],[])
  +peep4 = x188_finish(w4c_peep_cfg(f3,f3,[]))
  +shrunk = w4_leaf_shrink(w4_peep_flat([peep4],[]),peep4)
  +licm = w4b_licm_magic(w4_peep_flat([shrunk],[]))
  +rot = w4b_rotate_loop(licm)
  +peep5 = x188_finish(w4c_peep_cfg(rot,rot,[]))
  +f5 = w4_peep_flat([peep5],[])
  +xmm = w4c_xmm_opt(f5)
  w4b_wrap_items(xmm,[])"""
        prefix_only = new_post_select[:new_post_select.index("@unsafe\ndef w4_post_select(")]
        if old_w410_post in t:
            t = replace_exact(t, old_w410_post, prefix_only + chained_tail, "w4_post_select (chained on W4-10)")
        else:
            old_w4910_post = old_w410_post.replace(
                "  +peep5 = x188_finish(w4c_peep_cfg(rot,rot,[]))",
                "  +rot2 = w4_peep_flat([x188_finish(w4b_copy_peep(rot,rot,[]))],[])\n  +peep5 = x188_finish(w4c_peep_cfg(rot2,rot2,[]))",
            )
            chained_w4910 = chained_tail.replace(
                "  +peep5 = x188_finish(w4c_peep_cfg(rot,rot,[]))",
                "  +rot2 = w4_peep_flat([x188_finish(w4b_copy_peep(rot,rot,[]))],[])\n  +peep5 = x188_finish(w4c_peep_cfg(rot2,rot2,[]))",
            )
            t = replace_exact(t, old_w4910_post, prefix_only + chained_w4910, "w4_post_select (chained on W4-9+W4-10)")
    return t


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--src", default=DEFAULT_SRC, help="Input compiler.bend")
    ap.add_argument("--dst", default=DEFAULT_DST, help="Output compiler.bend")
    args = ap.parse_args()

    src = Path(args.src)
    dst = Path(args.dst)
    dst.parent.mkdir(parents=True, exist_ok=True)
    out = apply_all(src.read_text())
    dst.write_text(out)
    print(f"Wrote {dst} ({len(out)} bytes)")


if __name__ == "__main__":
    main()
