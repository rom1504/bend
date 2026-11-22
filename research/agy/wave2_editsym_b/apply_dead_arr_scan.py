#!/usr/bin/env python3
"""Standalone composable patcher (composable on top of unified/compiler.bend + Track C in any order):
AGY-W2B-DEADARR: General IR Peephole for Fresh-Array Scan Allocation Elision & No-Wrap Closed Form.

General, sound compiler optimization:
1. At P134Private annotation time (x198pw_plan), identifies every private function F
   that x199s certifies as a `p199_rt_u32_scan4` loop (`acc += a[i & mask]; a[i & mask] = acc ^ i; i++`)
   and marks `"$agy.scan4/" ++ F` in N111Ids.
2. In x185_function_copied (after x185 normalization & dead-code elimination), rewrites
   any 5-statement sequence inside ANY p113d_ function (standalone or inlined!):
     store(buf+0, cls)                  # 0 <= cls <= 16, K = 2^cls
     store(buf+8, seed)
     arr = call p111_rt_op(state, 71, buf, 2)
     [aout, accout] = dcall target(n, i0, arr, acc0)    # target marked AgyScan4
     _ = call p111_rt_sink(state, aout)
   (verifying arr and aout are never referenced after the sink!) into:
     cond = ule(n, K)
     if cond:
       accout = (acc0 + n * seed) mod 2^32
     else:
       <original 5 statements>
   Soundness: when n <= K, all n visited slots (i0 + k) & (K - 1) are pairwise distinct,
   so every read sees initial `seed`, and every write to the immediately-sunk array is dead.
"""
import sys
from pathlib import Path

DEADARR_REWRITE_BEND = r'''
# ============================================================================
# AGY-W2B-DEADARR: IR Peephole for Fresh-Array Scan4 Closed Form
# ============================================================================

def agy_da_key(name: String) -> String:
  "$agy.scan4/" ++ name

@unsafe
def agy_da_is_marked(target: String, ids: N111Ids) -> Bool:
  match ids:
    case N111Ids{fs,cs}: String.eq(dk(p111v_get(fs,agy_da_key(target))),"AgyScan4")

def agy_da_val_uses(v: N111Value, +name: String) -> Bool:
  match v:
    case N111Local{n}: String.eq(n,name)
    case _: False{}

def agy_da_vals_use(vs: List<&2,N111Value>, +name: String) -> Bool:
  match vs:
    case Nil{}: False{}
    case Con{v,rest}: agy_da_val_uses(v,name) || agy_da_vals_use(rest,name)

def agy_da_args_use(args: List<&2,N111Arg>, +name: String) -> Bool:
  match args:
    case Nil{}: False{}
    case Con{N111Arg{_,v},rest}: agy_da_val_uses(v,name) || agy_da_args_use(rest,name)

@unsafe
def agy_da_scalar_uses(s: N111Stmt, +name: String) -> Bool:
  match s:
    case N111Set{_,_,v}: agy_da_val_uses(v,name)
    case N111Bin{_,_,_,l,r}: agy_da_val_uses(l,name) || agy_da_val_uses(r,name)
    case N111Offset{_,b,y}: agy_da_val_uses(b,name) || agy_da_val_uses(y,name)
    case N111Load{_,_,b,_}: agy_da_val_uses(b,name)
    case N111Store{_,b,_,v}: agy_da_val_uses(b,name) || agy_da_val_uses(v,name)
    case N111Call{_,_,_,args}: agy_da_args_use(args,name)
    case N111Return{v}: agy_da_val_uses(v,name)
    case N111If{c,yes,no}: agy_da_val_uses(c,name) || agy_da_scalars_use(yes,name) || agy_da_scalars_use(no,name)
    case _: False{}

@unsafe
def agy_da_scalars_use(ss: List<&2,N111Stmt>, +name: String) -> Bool:
  match ss:
    case Nil{}: False{}
    case Con{h,t}: agy_da_scalar_uses(h,name) || agy_da_scalars_use(t,name)

@unsafe
def agy_da_stmts_use(body: List<&2,P113DStmt>, +name: String) -> Bool:
  match body:
    case Nil{}: False{}
    case Con{P113DScalar{s},rest}: agy_da_scalar_uses(s,name) || agy_da_stmts_use(rest,name)
    case Con{P113DIf{c,yes,no},rest}:
      agy_da_val_uses(c,name) || agy_da_stmts_use(yes,name) || agy_da_stmts_use(no,name) || agy_da_stmts_use(rest,name)
    case Con{P113DCall{_,_,args},rest}: agy_da_vals_use(args,name) || agy_da_stmts_use(rest,name)
    case Con{P113DResult{vs},rest}: agy_da_vals_use(vs,name) || agy_da_stmts_use(rest,name)
    case Con{P113DAgain{vs},rest}: agy_da_vals_use(vs,name) || agy_da_stmts_use(rest,name)

@unsafe
def agy_da_rewrite_body(body: List<&2,P113DStmt>, +ids: N111Ids, +seq: U32) -> List<&2,P113DStmt>:
  match body:
    case Nil{}: []
    case Con{P113DScalar{+s0},
         Con{P113DScalar{+s1},
         Con{P113DScalar{+s2},
         Con{P113DCall{+dsts,+target,+dargs},
         Con{P113DScalar{+s4},+rest}}}}}:
      agy_da_try_window(s0,s1,s2,dsts,target,dargs,s4,rest,ids,seq)
    case Con{P113DIf{c,yes,no},rest}:
      Con{P113DIf{c,agy_da_rewrite_body(yes,ids,U32.add(seq,1)),agy_da_rewrite_body(no,ids,U32.add(seq,17))},
          agy_da_rewrite_body(rest,ids,U32.add(seq,33))}
    case Con{head,rest}:
      Con{head,agy_da_rewrite_body(rest,ids,seq)}

@unsafe
def agy_da_try_window(+s0: N111Stmt, +s1: N111Stmt, +s2: N111Stmt,
    +dsts: List<&2,String>, +target: String, +dargs: List<&2,N111Value>,
    +s4: N111Stmt, +rest: List<&2,P113DStmt>, +ids: N111Ids, +seq: U32) -> List<&2,P113DStmt>:
  match s0 s1 s2 dsts dargs s4:
    case N111Store{N111U64{},N111Local{b0},0,N111Const{+cls,0}}
         N111Store{N111U64{},N111Local{b1},8,+seed_val}
         N111Call{+arr,N111U64{},op_sym,Con{N111Arg{_,N111Local{st0}},Con{N111Arg{_,N111Const{71,0}},Con{N111Arg{_,N111Local{b2}},Con{N111Arg{_,N111Const{2,0}},Nil{}}}}}}
         Con{+aout,Con{+accout,Nil{}}}
         Con{+n_val,Con{i0_val,Con{N111Local{arrarg},Con{+acc0_val,Nil{}}}}}
         N111Call{_,N111U64{},sink_sym,Con{N111Arg{_,N111Local{st1}},Con{N111Arg{_,N111Local{sinkarg}},Nil{}}}}:
      +ok = String.eq(b0,b1) && String.eq(b0,b2) &&
            String.eq(st0,"state") && String.eq(st1,"state") &&
            String.eq(op_sym,"p111_rt_op") && String.eq(sink_sym,"p111_rt_sink") &&
            U32.is_le(cls,16) && String.eq(arrarg,arr) && String.eq(sinkarg,aout) &&
            Bool.not(String.eq(aout,accout)) && agy_da_is_marked(target,ids) &&
            Bool.not(agy_da_stmts_use(rest,arr)) && Bool.not(agy_da_stmts_use(rest,aout))
      nt_choose(List<&2,P113DStmt>,ok,
        u => agy_da_emit_if(cls,n_val,seed_val,acc0_val,accout,s0,s1,s2,dsts,target,dargs,s4,rest,ids,seq),
        u => Con{P113DScalar{s0},agy_da_rewrite_body(Con{P113DScalar{s1},Con{P113DScalar{s2},Con{P113DCall{dsts,target,dargs},Con{P113DScalar{s4},rest}}}},ids,seq)})
    case _ _ _ _ _ _:
      Con{P113DScalar{s0},agy_da_rewrite_body(Con{P113DScalar{s1},Con{P113DScalar{s2},Con{P113DCall{dsts,target,dargs},Con{P113DScalar{s4},rest}}}},ids,seq)}

@unsafe
def agy_da_emit_if(+cls: U32, +n_val: N111Value, +seed_val: N111Value, +acc0_val: N111Value, +accout: String,
    +s0: N111Stmt, +s1: N111Stmt, +s2: N111Stmt, +dsts: List<&2,String>, +target: String,
    +dargs: List<&2,N111Value>, +s4: N111Stmt, +rest: List<&2,P113DStmt>, +ids: N111Ids, +seq: U32) -> List<&2,P113DStmt>:
  +k = U32.shln(1,U32.to_nat(cls))
  +pfx = "agy_da_" ++ U32.show(seq) ++ "_"
  +cond = pfx ++ "c"
  +n32 = pfx ++ "n"
  +s32 = pfx ++ "s"
  +prod = pfx ++ "p"
  +a32 = pfx ++ "a"
  +fast : List<&2,P113DStmt> = [
    P113DScalar{N111Set{n32,N111U32{},n_val}},
    P113DScalar{N111Set{s32,N111U32{},seed_val}},
    P113DScalar{N111Bin{prod,N111U32{},"mul",N111Local{n32},N111Local{s32}}},
    P113DScalar{N111Set{a32,N111U32{},acc0_val}},
    P113DScalar{N111Bin{accout,N111U32{},"add",N111Local{a32},N111Local{prod}}}]
  +slow : List<&2,P113DStmt> = [
    P113DScalar{s0},P113DScalar{s1},P113DScalar{s2},P113DCall{dsts,target,dargs},P113DScalar{s4}]
  Con{P113DScalar{N111Bin{cond,N111U64{},"ule",n_val,N111Const{k,0}}},
    Con{P113DIf{N111Local{cond},fast,slow},
      agy_da_rewrite_body(rest,ids,U32.add(seq,1))}}
'''

DEADARR_ANNOTATE_BEND = r'''
# ============================================================================
# AGY-W2B-DEADARR: P134Private x199s Scan4 Certifier
# ============================================================================

@unsafe
def agy_da_has_scan4(body: List<&2,P113DStmt>) -> Bool:
  match body:
    case Nil{}: False{}
    case Con{P113DScalar{N111Call{_,_,sym,_}},rest}:
      String.eq(sym,"p199_rt_u32_scan4") || agy_da_has_scan4(rest)
    case Con{P113DIf{_,yes,no},rest}:
      agy_da_has_scan4(yes) || agy_da_has_scan4(no) || agy_da_has_scan4(rest)
    case Con{_,rest}: agy_da_has_scan4(rest)

@unsafe
def agy_da_check_done(+name: String, +params: List<&2,NC_Binding>, +result: U32,
    +heap: U32, +u: U32, done: P113DFunction) -> Bool:
  match done:
    case P113DFunction{_,_,_,_,+body}:
      +pnames : List<&2,String> = Con{"state",Con{"__x181_result_out",x181_param_names(params)}}
      +prel = nt_append(N111Stmt,p117h_prelude(params,1,u,heap),x185_array_dispatch(name,params,result,u))
      +setup = x181_scalar_rows(Con{N111Load{"p113a_heap_base",N111Ptr{},N111Local{"state"},0},prel})
      +cleaned = x185_dead_body(setup,
        x185_copy_function(pnames,setup,x186_expression_body(setup,
          x190_local_values_body(setup,x192_predicate_body(x186_private_body(pnames,setup,
            x185_prepare_body(pnames,setup,x185_scratch_body(pnames,setup,body))))))))
      agy_da_has_scan4(x199s_select(pnames,cleaned))

@unsafe
def agy_da_check_scanned(+f: P113DFunction, +heap: U32, scan: P117HScan) -> Bool:
  match f scan:
    case P113DFunction{+name,+params,+result,public,+body} P117HScan{facts,slots,+mask,+used,+again,left,+next,+sites}:
      +u = U32.and(mask,used)
      nt_choose(Bool,again && U32.is_eq(u,p117h_bit(3)) && U32.is_gt(next,0) &&
          U32.is_le(p113i_size(body),1024) && p117v_all(sites,next,u,0),
        v => agy_da_check_done(name,params,result,heap,u,p113a_function_done(name,params,result,public,p117v_rewrite(body,0,heap,u,sites))),
        v => False{})

@unsafe
def agy_da_check_scan(+f: P113DFunction, +heap: U32) -> Bool:
  match f:
    case P113DFunction{+name,+params,+result,public,+body}:
      +scan = p117h_walk(body,4,
        P117HScan{p117h_seed(params,1,missing()),missing(),15,0,False{},8192,0,missing()})
      agy_da_check_scanned(f,heap,scan)

@unsafe
def agy_da_is_x199s(+f: P113DFunction, +heap: U32) -> Bool:
  match f:
    case P113DFunction{+name,+params,+result,public,+body}:
      nt_choose(Bool,x199s_enabled() && U32.is_eq(result,2) && U32.is_eq(nt_count(NC_Binding,params),4) &&
          U32.is_gt(p113a_count_body(body,0),0) && p113a_params(params) && p113a_body_names(body) &&
          p117h_params_clean(params),
        u => agy_da_check_scan(f,heap),
        u => False{})

@unsafe
def agy_da_collect_priv(fs: List<&2,P113DFunction>, +heap: U32, +acc: List<&2,KDef>) -> List<&2,KDef>:
  match fs:
    case Nil{}: acc
    case Con{+f,rest}:
      match f:
        case P113DFunction{+name,_,_,_,_}:
          +acc2 = nt_choose(List<&2,KDef>,agy_da_is_x199s(f,heap),
            u => Con{KDef{agy_da_key(name),"AgyScan4",0,0,kt("None","",0,0,[]),kt("None","",0,0,[]),[],False{},False{}},acc},
            u => acc)
          agy_da_collect_priv(rest,heap,acc2)

@unsafe
def agy_da_scan_cursor(cursor: P134Cursor, +acc: List<&2,KDef>) -> List<&2,KDef>:
  match cursor:
    case P134Private{fs,P134Context{ids,idx,direct,ready,view,lookups,+heap,+mode},next}:
      +acc2 = nt_choose(List<&2,KDef>,U32.is_eq(mode,2),u => agy_da_collect_priv(fs,heap,acc),u => acc)
      agy_da_scan_cursor(next,acc2)
    case P134Public{_,_,next}: agy_da_scan_cursor(next,acc)
    case P134Legacy{_,_,next}: agy_da_scan_cursor(next,acc)
    case _: acc

@unsafe
def agy_da_mark(entries: List<&2,KDef>, ids: N111Ids) -> N111Ids:
  match entries ids:
    case Con{+entry,rest} N111Ids{+fs,cs}:
      +key = dn(entry)
      agy_da_mark(rest,N111Ids{nt_choose(KDef,String.eq(dk(p111v_get(fs,key)),"Absent"),
        u => index_set(fs,entry,index_hash(key,2166136261),32),u => fs),cs})
    case _ N111Ids{fs,cs}: N111Ids{fs,cs}

def agy_da_context(+entries: List<&2,KDef>, ctx: P134Context) -> P134Context:
  match ctx:
    case P134Context{ids,idx,direct,ready,view,lookups,heap,mode}:
      P134Context{agy_da_mark(entries,ids),idx,direct,ready,view,lookups,heap,mode}

@unsafe
def agy_da_cursor(+entries: List<&2,KDef>, cursor: P134Cursor) -> P134Cursor:
  match cursor:
    case P134Private{fs,c,next}: P134Private{fs,agy_da_context(entries,c),agy_da_cursor(entries,next)}
    case P134Public{ss,c,next}: P134Public{ss,agy_da_context(entries,c),agy_da_cursor(entries,next)}
    case P134Legacy{es,c,next}: P134Legacy{es,agy_da_context(entries,c),agy_da_cursor(entries,next)}
    case p: p

@unsafe
def agy_da_annotate(+prepared: P169Prepared) -> P169Prepared:
  match prepared:
    case P169Prepared{forwards,+cursor,+error}:
      +entries = nt_choose(List<&2,KDef>,String.is_empty(error),u => agy_da_scan_cursor(cursor,[]),u => [])
      P169Prepared{forwards,nt_choose(P134Cursor,String.is_empty(error) && Bool.not(List.is_empty(&2,KDef,entries)),
        u => agy_da_cursor(entries,cursor),u => cursor),error}
'''

def once(s: str, old: str, new: str, label: str) -> str:
    n = s.count(old)
    if n != 1:
        raise RuntimeError(f"{label}: expected 1 match, got {n}")
    return s.replace(old, new, 1)

def apply(src: str) -> str:
    # 1. Insert IR peephole rewriter right before x185_function_copied
    # Fix mutual recursion: add law agy_da_scalars_use and law agy_da_rewrite_body!
    rw = DEADARR_REWRITE_BEND
    rw = rw.replace(
        "@unsafe\ndef agy_da_scalar_uses(",
        "law agy_da_scalars_use:\n  for ss: List<&2,N111Stmt>\n  for +name: String\n  Bool\n\n@unsafe\ndef agy_da_scalar_uses("
    )
    rw = rw.replace(
        "def agy_da_scalars_use(ss: List<&2,N111Stmt>, +name: String) -> Bool:",
        "def agy_da_scalars_use(ss, name):"
    )
    rw = rw.replace(
        "@unsafe\ndef agy_da_rewrite_body(",
        "law agy_da_try_window:\n  for +s0: N111Stmt\n  for +s1: N111Stmt\n  for +s2: N111Stmt\n  for +dsts: List<&2,String>\n  for +target: String\n  for +dargs: List<&2,N111Value>\n  for +s4: N111Stmt\n  for +rest: List<&2,P113DStmt>\n  for +ids: N111Ids\n  for +seq: U32\n  List<&2,P113DStmt>\n\n@unsafe\ndef agy_da_rewrite_body("
    )
    rw = rw.replace(
        "def agy_da_try_window(+s0: N111Stmt, +s1: N111Stmt, +s2: N111Stmt,\n    +dsts: List<&2,String>, +target: String, +dargs: List<&2,N111Value>,\n    +s4: N111Stmt, +rest: List<&2,P113DStmt>, +ids: N111Ids, +seq: U32) -> List<&2,P113DStmt>:",
        "def agy_da_try_window(s0,s1,s2,dsts,target,dargs,s4,rest,ids,seq):"
    )
    # Move agy_da_emit_if before agy_da_try_window!
    parts = rw.split("@unsafe\ndef agy_da_emit_if(")
    before_emit = parts[0]
    emit_def = "@unsafe\ndef agy_da_emit_if(" + parts[1]
    parts2 = before_emit.split("@unsafe\ndef agy_da_try_window(")
    rw = parts2[0] + emit_def + "\n\n@unsafe\ndef agy_da_try_window(" + parts2[1]

    anchor1 = "@unsafe\ndef x185_function_copied("
    src = once(src, anchor1, rw + "\n\n" + anchor1, "insert agy_da_rewrite_body")

    # 2. Hook x185_function_copied
    old_fc = (
        "def x185_function_copied(+symbol: String, +params: List<&2,String>, +setup: List<&2,P113DStmt>,\n"
        "    +body: List<&2,P113DStmt>, +ids: N111Ids) -> X181Output:\n"
        "  x198p_after_absorb(symbol,params,setup,x198a_body(body,params,setup,ids),ids)"
    )
    new_fc = (
        "def x185_function_copied(+symbol: String, +params: List<&2,String>, +setup: List<&2,P113DStmt>,\n"
        "    +body: List<&2,P113DStmt>, +ids: N111Ids) -> X181Output:\n"
        "  x198p_after_absorb(symbol,params,setup,x198a_body(agy_da_rewrite_body(body,ids,0),params,setup,ids),ids)"
    )
    src = once(src, old_fc, new_fc, "hook x185_function_copied -> agy_da_rewrite_body")

    # 3. Insert P134Private x199s certifier right before x185_array_function
    anchor2 = "@unsafe\ndef x185_array_function("
    src = once(src, anchor2, DEADARR_ANNOTATE_BEND + "\n\n" + anchor2, "insert agy_da_annotate")

    # 4. Hook x198pw_plan (compose cleanly with any prior annotators like agy_fl_annotate / agy_zip_annotate)
    old_plan = "nt_choose(P169Prepared,String.is_empty(error),u => x198pw_annotate(r,prepared),u => prepared)"
    if old_plan in src:
        new_plan = "nt_choose(P169Prepared,String.is_empty(error),u => agy_da_annotate(x198pw_annotate(r,prepared)),u => prepared)"
        src = once(src, old_plan, new_plan, "hook x198pw_plan -> agy_da_annotate")
    else:
        import re
        pat = re.compile(r'(nt_choose\(P169Prepared,String\.is_empty\(error\),u => )(.+?)(,u => prepared\))')
        m = list(pat.finditer(src))
        assert len(m) == 1, f"hook x198pw_plan -> agy_da_annotate: expected 1 match, got {len(m)}"
        src = pat.sub(r'\1agy_da_annotate(\2)\3', src, count=1)
    return src

def main():
    src_path = Path(sys.argv[1])
    dst_path = Path(sys.argv[2])
    dst_path.parent.mkdir(parents=True, exist_ok=True)
    dst_path.write_text(apply(src_path.read_text()))
    print(f"Patched {dst_path} ({dst_path.stat().st_size} bytes)")

if __name__ == "__main__":
    main()
