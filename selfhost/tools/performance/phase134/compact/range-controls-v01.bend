# Controls compare the new orchestration to the original, fully verifying path.
# This file deliberately names p114s_commit directly, so caller overrides cannot
# accidentally make the reference use verification reuse as well.
@unsafe
def p134rkt_reference_inline(+boundary: P114SBoundary) -> P114SBoundary:
  match boundary:
    case P114SBoundary{original,ids,functions,valid}:
      nt_choose(P114SBoundary,valid,
        u => p114s_commit(boundary,p113i_functions(functions,P113IEmpty{},[])),u => boundary)

@unsafe
def p134rkt_reference_ranges(+boundary: P114SBoundary) -> P114SBoundary:
  match boundary:
    case P114SBoundary{original,ids,functions,valid}:
      nt_choose(P114SBoundary,valid,
        u => p114s_commit(boundary,p113k_functions(functions)),u => boundary)

@unsafe
def p134rkt_same_boundary(a: P114SBoundary, b: P114SBoundary) -> Bool:
  match a b:
    case P114SBoundary{ao,ai,af,av} P114SBoundary{bo,bi,bf,bv}:
      p134v_bool(av,bv) && p134v_list(P113DFunction,p134v_function,af,bf)

@unsafe
def p134rkt_pipeline(+program: P113DProgram) -> Bool:
  +boundary = p114s_open(program)
  p134rkt_same_boundary(p134rkt_reference_ranges(p134rkt_reference_inline(boundary)),
    p134rk_finish(p134rk_inline(boundary)))

def p134rkt_fold() -> P113DFunction:
  P113DFunction{"p134_range_fold",[],1,False{},
    [P113DScalar{N111Bin{"x",N111U64{},"add",N111Const{1,0},N111Const{2,0}}},
     P113DResult{[N111Local{"x"}]}]}

def p134rkt_dirty() -> P113DFunction:
  P113DFunction{"p134_range_dirty",[NC_Binding{0,"p113i_existing",N_W64{}}],1,False{},
    [P113DResult{[N111Local{"p113i_existing"}]}]}

def p134rkt_stack() -> P113DFunction:
  P113DFunction{"p134_range_stack",[],1,False{},
    [P113DScalar{N111Alloca{"large",16392,8}},P113DResult{[N111Const{0,0}]}]}

@unsafe
def p134rkt_inline_same(+functions: List<&2,P113DFunction>) -> Bool:
  match p134rk_functions(functions,P113IEmpty{},[],[]):
    case P134RKBatch{result,memos}:
      p134v_list(P113DFunction,p134v_function,result,p113i_functions(functions,P113IEmpty{},[]))

@unsafe
def p134rkt_memo_exact(+input: P113DFunction) -> Bool:
  match p134rk_ranged(input):
    case P134RKUnit{output,+memo}:
      p134rk_hit(input,memo) && p134v_function(p134rk_use(input,memo),output)

@unsafe
def p134rkt_changed_fallback(+input: P113DFunction, +other: P113DFunction) -> Bool:
  match p134rk_ranged(input):
    case P134RKUnit{output,+memo}:
      Bool.not(p134rk_hit(other,memo)) &&
        p134v_function(p134rk_use(other,memo),p113k_function(other))

@unsafe
def p134rkt_not_idempotence(+input: P113DFunction) -> Bool:
  match p134rk_ranged(input):
    case P134RKUnit{+output,+memo}:
      Bool.not(p134v_function(input,output)) && Bool.not(p134rk_hit(output,memo)) &&
        p134v_function(p134rk_use(output,memo),p113k_function(output))

@unsafe
def p134rkt_refused(+function: P113DFunction) -> Bool:
  match p134rk_function(function,P113IEmpty{}):
    case P134RKUnit{output,memo}:
      p134v_function(function,output) && Bool.not(p134rk_hit(function,memo))

@unsafe
def p134rk_controls() -> List<&2,String>:
  +identity = p114st_identity()
  +fold = p134rkt_fold()
  +bad : P113DFunction = P113DFunction{"bad",[],1,False{},[P113DResult{[N111Local{"undefined"}]}]}
  [p114st_row("range-pipeline-empty",p134rkt_pipeline(p114st_program(0))),
   p114st_row("range-pipeline-identity",p134rkt_pipeline(p114st_program(1))),
   p114st_row("range-pipeline-prior-callees",p134rkt_pipeline(p114st_program(2))),
   p114st_row("range-pipeline-branch",p134rkt_pipeline(p114st_program(3))),
   p114st_row("range-pipeline-loop",p134rkt_pipeline(p114st_program(4))),
   p114st_row("range-pipeline-public",p134rkt_pipeline(p114st_program(5))),
   p114st_row("range-pipeline-invalid",p134rkt_pipeline(P113DProgram{p114st_original(),[bad]})),
   p114st_row("range-inline-table-order",p134rkt_inline_same(p114st_functions(2))),
   p114st_row("range-inline-forward-call",p134rkt_inline_same([p114st_caller(),p114st_scalar(),p114st_pair()])),
   p114st_row("range-inline-repeated-name",p134rkt_inline_same([identity,identity])),
   p114st_row("range-memo-identity",p134rkt_memo_exact(identity)),
   p114st_row("range-memo-changing-pass",p134rkt_memo_exact(fold)),
   p114st_row("range-memo-other-input",p134rkt_changed_fallback(identity,fold)),
   p114st_row("range-output-is-not-key",p134rkt_not_idempotence(fold)),
   p114st_row("range-empty-memo-fallback",p134v_function(p134rk_use(fold,P134RKEmpty{}),p113k_function(fold))),
   p114st_row("range-missing-memos-fallback",p134v_list(P113DFunction,p134v_function,p134rk_range_functions([identity,fold],[]),p113k_functions([identity,fold]))),
   p114st_row("range-dirty-original-refused",p134rkt_refused(p134rkt_dirty())),
   p114st_row("range-stack-refused",p134rkt_refused(p134rkt_stack())),
   p114st_row("range-invalid-commit-restores-input",p134rkt_same_boundary(
     p134rkt_reference_ranges(p114s_open(p114st_program(1))),
     p134rk_finish(p134rk_commit_inline(p114s_open(p114st_program(1)),P134RKBatch{[bad],[P134RKEmpty{}]})))),
   p114st_row("range-high-word-key-differs",Bool.not(p134rk_hit(
     P113DFunction{"high",[],1,False{},[P113DResult{[N111Const{0,1}]}]},
     P134RKMemo{P113DFunction{"high",[],1,False{},[P113DResult{[N111Const{0,0}]}]},identity})))]

@unsafe
def p134rk_count(functions: List<&2,P113DFunction>, memos: List<&2,P134RKMemo>, +hits: U32, +misses: U32) -> List<&2,U32>:
  match functions memos:
    case Nil{} _: [hits,misses]
    case Con{function,+rest} Con{memo,+more}:
      nt_choose(List<&2,U32>,p134rk_hit(function,memo),
        u => p134rk_count(rest,more,U32.inc(hits),misses),
        u => p134rk_count(rest,more,hits,U32.inc(misses)))
    case Con{function,rest} Nil{}: p134rk_count(rest,[],hits,U32.inc(misses))

@unsafe
def p134rk_counts(prepared: P134RKPrepared) -> List<&2,U32>:
  match prepared:
    case P134RKPrepared{boundary,memos}:
      match boundary:
        case P114SBoundary{original,ids,functions,valid}: p134rk_count(functions,memos,0,0)
