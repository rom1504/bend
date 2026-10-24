# Experimental, request-local reuse of the range pass already run by inlining.
# A memo is evidence of output = p113k_function(input), produced below only.
# The outer range pass compares its actual input to memo.input, NEVER output.
# There is no idempotence assumption, cross-request key, or verifier change.

type P134RKMemo is Data:
  P134RKEmpty{}
  P134RKMemo{+input: P113DFunction, +output: P113DFunction}

type P134RKUnit is Data:
  P134RKUnit{+function: P113DFunction, +memo: P134RKMemo}

type P134RKBatch is Data:
  P134RKBatch{+functions: List<&2,P113DFunction>, +memos: List<&2,P134RKMemo>}

type P134RKPrepared is Data:
  P134RKPrepared{+boundary: P114SBoundary, +memos: List<&2,P134RKMemo>}

@unsafe
def p134rk_ranged(+input: P113DFunction) -> P134RKUnit:
  +output = p113k_function(input)
  P134RKUnit{output,P134RKMemo{input,output}}

@unsafe
def p134rk_done(+original: P113DFunction, +name: String, +params: List<&2,NC_Binding>, +result: U32, +public: Bool, scan: P113IScan) -> P134RKUnit:
  match scan:
    case P113IScan{+body,next,budget}:
      nt_choose(P134RKUnit,U32.is_le(p113i_stack(body),16384),
        u => p134rk_ranged(P113DFunction{name,params,result,public,body}),
        u => P134RKUnit{original,P134RKEmpty{}})

@unsafe
def p134rk_function(+function: P113DFunction, +table: P113ITable) -> P134RKUnit:
  match function:
    case P113DFunction{+name,+params,+result,+public,+body}:
      nt_choose(P134RKUnit,p113i_params(params) && p113i_clean(body) && U32.is_le(p113i_size(body),2048),
        u => p134rk_done(function,name,params,result,public,p113i_scan(body,table,0,1024)),
        u => P134RKUnit{function,P134RKEmpty{}})

@unsafe
def p134rk_functions(functions: List<&2,P113DFunction>, +table: P113ITable, acc: List<&2,P113DFunction>, memos: List<&2,P134RKMemo>) -> P134RKBatch:
  match functions:
    case Nil{}: P134RKBatch{nt_reverse(P113DFunction,acc,[]),nt_reverse(P134RKMemo,memos,[])}
    case Con{+head,rest}: p134rk_step(head,rest,table,acc,memos,p134rk_function(head,table))

@unsafe
def p134rk_step(+original: P113DFunction, +rest: List<&2,P113DFunction>, +table: P113ITable, +acc: List<&2,P113DFunction>, +memos: List<&2,P134RKMemo>, unit: P134RKUnit) -> P134RKBatch:
  match unit:
    case P134RKUnit{+function,memo}:
      p134rk_functions(rest,
        nt_choose(P113ITable,p113i_original_clean(original),
          u => p113i_table_function(function,table),u => table),
        Con{function,acc},Con{memo,memos})

@unsafe
def p134rk_use(+current: P113DFunction, memo: P134RKMemo) -> P113DFunction:
  match memo:
    case P134RKEmpty{}: p113k_function(current)
    case P134RKMemo{input,+output}:
      nt_choose(P113DFunction,p134v_function(current,input),
        u => output,u => p113k_function(current))

@unsafe
def p134rk_hit(current: P113DFunction, memo: P134RKMemo) -> Bool:
  match memo:
    case P134RKEmpty{}: False{}
    case P134RKMemo{input,output}: p134v_function(current,input)

@unsafe
def p134rk_range_functions(functions: List<&2,P113DFunction>, memos: List<&2,P134RKMemo>) -> List<&2,P113DFunction>:
  match functions memos:
    case Nil{} _: []
    case Con{function,rest} Con{memo,more}:
      Con{p134rk_use(function,memo),p134rk_range_functions(rest,more)}
    case _ Nil{}: p113k_functions(functions)

@unsafe
def p134rk_commit_inline(boundary: P114SBoundary, batch: P134RKBatch) -> P134RKPrepared:
  match batch:
    case P134RKBatch{functions,memos}: P134RKPrepared{p134v_commit(boundary,functions),memos}

@unsafe
def p134rk_inline(+boundary: P114SBoundary) -> P134RKPrepared:
  match boundary:
    case P114SBoundary{original,ids,functions,valid}:
      nt_choose(P134RKPrepared,valid,
        u => p134rk_commit_inline(boundary,p134rk_functions(functions,P113IEmpty{},[],[])),
        u => P134RKPrepared{boundary,[]})

@unsafe
def p134rk_finish(prepared: P134RKPrepared) -> P114SBoundary:
  match prepared:
    case P134RKPrepared{+boundary,+memos}:
      match boundary:
        case P114SBoundary{original,ids,+functions,valid}:
          nt_choose(P114SBoundary,valid,
            u => p134v_commit(boundary,p134rk_range_functions(functions,memos)),
            u => boundary)

@unsafe
def p134rk_lowered(lowered: P114SLowered) -> P113DLowering:
  match lowered:
    case P114SLowered{boundary,error}:
      P113DLowered{p114s_close(p134rk_finish(p134rk_inline(boundary))),error}

@unsafe
def p134rk_session(request: NR_Request, certificate: P113ACertificate, session: P128RawLowering) -> P111Emission:
  match session:
    case P128RawLowering{lowered,raw}:
      p128raw_lowered(request,raw,p113a_finish(certificate,
        p134rk_lowered(p114s_open_lowered(lowered))))

@unsafe
def p134rk_emit(+request: NR_Request, +error: String) -> P111Emission:
  nt_choose(P111Emission,String.is_empty(error),u =>
    p134e_collect(p134rk_session(request,p113a_certificate(request),p128raw_lower_request(request))),
    u => P111Emission{[],"compile: " ++ error})
