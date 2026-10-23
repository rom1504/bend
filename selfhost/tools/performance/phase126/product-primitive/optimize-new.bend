# Reuse the established bounded inliner/range pass only on late admissions.
# Existing original/borrowed workers are never rewritten by this experiment.

@unsafe
def p126bo_index(functions: List<&2,P113DFunction>, +table: P113ITable) -> P113ITable:
  match functions:
    case Nil{}: table
    case Con{+head,rest}:
      p126bo_index(rest,nt_choose(P113ITable,p113i_original_clean(head),
        u => p113i_table_function(head,table),u => table))

@unsafe
def p126bo_one(+function: P113DFunction, +old: KDef, +table: P113ITable) -> P113DFunction:
  match function:
    case P113DFunction{+name,params,result,public,body}:
      nt_choose(P113DFunction,String.eq(dk(p111v_get(old,name)),"Absent"),
        u => p113i_function(function,table),u => function)

@unsafe
def p126bo_functions(functions: List<&2,P113DFunction>, +old: KDef, +table: P113ITable, acc: List<&2,P113DFunction>) -> List<&2,P113DFunction>:
  match functions:
    case Nil{}: nt_reverse(P113DFunction,acc,[])
    case Con{head,rest}: p126bo_functions(rest,old,table,Con{p126bo_one(head,old,table),acc})

@unsafe
def p126bo_result(+static: P112StaticProgram, +certificate: P113ACertificate, +closed: List<&2,P113DFunction>, candidate: P111Emission) -> P111Emission:
  match candidate:
    case P111Emission{chunks,+error}:
      nt_choose(P111Emission,String.is_empty(error),u => candidate,u => p126bp_complete(static,certificate,closed))

@unsafe
def p126bo_finish(+static: P112StaticProgram, +certificate: P113ACertificate, +old: KDef, +closed: List<&2,P113DFunction>) -> P111Emission:
  p126bo_result(static,certificate,closed,p126bp_complete(static,certificate,
    p126bo_functions(closed,old,p126bo_index(closed,P113IEmpty{}),[])))

@unsafe
def p126bp_close(+request: NR_Request, original: P113AProgram, +added: List<&2,P113DFunction>) -> P111Emission:
  match original:
    case P113AProgram{P113DProgram{+static,+functions},+certificate}:
      +merged = nt_append(P113DFunction,added,p118b_without(functions,p113e_signatures(added,missing())))
      +old = p113e_signatures(merged,missing())
      p126bo_finish(static,certificate,old,
        p113d_passes(p113pl_inspect_request(request),old,nt_reverse(P113DFunction,merged,[]),32))
