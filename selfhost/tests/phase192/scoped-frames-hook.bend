# Exact four replacement definitions from scoped-frames-integration.patch.
# Use only through prepare-api --replace; maintained production stays unchanged.
@unsafe
def x185_function_setup(+symbol: String, +params: List<&2,String>, +setup: List<&2,P113DStmt>,
    +body: List<&2,P113DStmt>, +ids: N111Ids) -> X181Output:
  x192hf_function_setup(symbol,params,setup,body,ids,[])

@unsafe
def x185_late_stmts(body: List<&2,P113DStmt>, +ids: N111Ids, +site: U32) -> P113ABody:
  x192hf_late_stmts(body,ids,site,[])

@unsafe
def x185_late_yes(condition: N111Value, no: List<&2,P113DStmt>, rest: List<&2,P113DStmt>,
    +ids: N111Ids, yes: P113ABody) -> P113ABody:
  x192hf_late_yes(condition,no,rest,ids,yes,[])

@unsafe
def x185_late_no(condition: N111Value, yes: List<&2,P113DStmt>, rest: List<&2,P113DStmt>,
    +ids: N111Ids, no: P113ABody) -> P113ABody:
  x192hf_late_no(condition,yes,rest,ids,no,[])
