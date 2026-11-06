# Generated forward signatures. Types precede this file.

law p171d_info:
  for +name: String
  for env: List<&2,P171DLocal>
  P171DInfo

law p171d_value:
  for value: N111Value
  for +env: List<&2,P171DLocal>
  P171DInfo

law p171d_known:
  for info: P171DInfo
  Bool

law p171d_path:
  for info: P171DInfo
  String

law p171d_args:
  for values: List<&2,N111Value>
  for +env: List<&2,P171DLocal>
  Bool

law p171d_env:
  for params: List<&2,NC_Binding>
  for args: List<&2,N111Value>
  for +env: List<&2,P171DLocal>
  List<&2,P171DLocal>

law p171d_decline:
  for +n: U32
  P171DCode

law p171d_prefix:
  for prefix: List<&2,P113DStmt>
  for code: P171DCode
  P171DCode

law p171d_next:
  for code: P171DCode
  U32

law p171d_find:
  for +name: String
  for functions: List<&2,P113DFunction>
  Maybe<&2,P113DFunction>

law p171d_context_find:
  for ctx: P171DContext
  for name: String
  Maybe<&2,P113DFunction>

law p171d_case:
  for +path: String
  for cases: List<&2,P171DCase>
  String

law p171d_cases:
  for info: P171DInfo
  for +yes: Bool
  for +cases: List<&2,P171DCase>
  List<&2,P171DCase>

law p171d_bin_info:
  for +op: String
  for left: P171DInfo
  for right: N111Value
  P171DInfo

law p171d_result:
  for values: List<&2,N111Value>
  for +env: List<&2,P171DLocal>
  for +n: U32
  P171DCode

law p171d_result_info:
  for +value: N111Value
  for +n: U32
  for info: P171DInfo
  P171DCode

law p171d_branch:
  for condition: N111Value
  for yes: P171DCode
  for no: P171DCode
  P171DCode

law p171d_branch_yes:
  for +ctx: P171DContext
  for +condition: N111Value
  for +no: List<&2,P113DStmt>
  for +env: List<&2,P171DLocal>
  for +cases: List<&2,P171DCase>
  for +view: P171DView
  for +yes: P171DCode
  P171DCode

law p171d_walk:
  for +ctx: P171DContext
  for body: List<&2,P113DStmt>
  for +env: List<&2,P171DLocal>
  for +cases: List<&2,P171DCase>
  for +view: P171DView
  for +n: U32
  P171DCode

law p171d_continue:
  for +ctx: P171DContext
  for stmt: N111Stmt
  for +rest: List<&2,P113DStmt>
  for +env: List<&2,P171DLocal>
  for +cases: List<&2,P171DCase>
  for +view: P171DView
  for +n: U32
  for name: String
  for info: P171DInfo
  P171DCode

law p171d_scalar:
  for +ctx: P171DContext
  for +stmt: N111Stmt
  for +rest: List<&2,P113DStmt>
  for +env: List<&2,P171DLocal>
  for +cases: List<&2,P171DCase>
  for +view: P171DView
  for +n: U32
  P171DCode

law p171d_load:
  for +ctx: P171DContext
  for +stmt: N111Stmt
  for +name: String
  for +typ: N111Type
  for base: N111Value
  for +offset: U32
  for +rest: List<&2,P113DStmt>
  for +env: List<&2,P171DLocal>
  for +cases: List<&2,P171DCase>
  for view: P171DView
  for +n: U32
  P171DCode

law p171d_ctor_ok:
  for ctx: P171DContext
  for +ctor: String
  for +count: U32
  Bool

law p171d_take:
  for +ctx: P171DContext
  for +name: String
  for +typ: N111Type
  for +word: N111Value
  for +count: U32
  for +buffer: N111Value
  for +rest: List<&2,P113DStmt>
  for +env: List<&2,P171DLocal>
  for +cases: List<&2,P171DCase>
  for +n: U32
  P171DCode

law p171d_tag:
  for +ctx: P171DContext
  for +name: String
  for +typ: N111Type
  for +word: N111Value
  for +rest: List<&2,P113DStmt>
  for +env: List<&2,P171DLocal>
  for +cases: List<&2,P171DCase>
  for +view: P171DView
  for +n: U32
  P171DCode

law p171d_runtime:
  for +ctx: P171DContext
  for +name: String
  for +typ: N111Type
  for +symbol: String
  for +args: List<&2,N111Arg>
  for +rest: List<&2,P113DStmt>
  for +env: List<&2,P171DLocal>
  for +cases: List<&2,P171DCase>
  for +view: P171DView
  for +n: U32
  P171DCode

law p171d_worker_done:
  for +name: String
  for +params: List<&2,NC_Binding>
  for code: P171DCode
  P171DWorker

law p171d_worker:
  for +ctx: P171DContext
  for +function: P113DFunction
  for +args: List<&2,N111Value>
  for +env: List<&2,P171DLocal>
  for +n: U32
  P171DWorker

law p171d_called:
  for +ctx: P171DContext
  for +destination: String
  for +args: List<&2,N111Value>
  for +rest: List<&2,P113DStmt>
  for +env: List<&2,P171DLocal>
  for +cases: List<&2,P171DCase>
  for +n: U32
  for worker: P171DWorker
  P171DCode

law p171d_called_tail:
  for reader: String
  for destination: String
  for args: List<&2,N111Value>
  for helpers: List<&2,P113DFunction>
  for +n: U32
  for tail: P171DCode
  P171DCode

law p171d_call:
  for +ctx: P171DContext
  for destinations: List<&2,String>
  for +target: String
  for +args: List<&2,N111Value>
  for +rest: List<&2,P113DStmt>
  for +env: List<&2,P171DLocal>
  for +cases: List<&2,P171DCase>
  for view: P171DView
  for +n: U32
  P171DCode

law p171d_call_found:
  for +ctx: P171DContext
  for +destination: String
  for +args: List<&2,N111Value>
  for +rest: List<&2,P113DStmt>
  for +env: List<&2,P171DLocal>
  for +cases: List<&2,P171DCase>
  for +n: U32
  for found: Maybe<&2,P113DFunction>
  P171DCode

law p171d_runtime_args:
  for args: List<&2,N111Arg>
  for +env: List<&2,P171DLocal>
  for +i: U32
  Bool

law p171d_shape:
  for +book: List<&2,KDef>
  for +ty: KTerm
  for +i: U32
  for +roots: List<&2,U32>
  for +fuel: U32
  P171DShape

law p171d_type:
  for +book: List<&2,KDef>
  for +ty: KTerm
  Bool

law p171d_shape_head:
  for +book: List<&2,KDef>
  for +head: KTerm
  for +i: U32
  for +roots: List<&2,U32>
  for +fuel: U32
  P171DShape

law p171d_shape_param:
  for +book: List<&2,KDef>
  for +head: KTerm
  for +ty: KTerm
  for +i: U32
  for +roots: List<&2,U32>
  for +fuel: U32
  P171DShape

law p171d_entry_env:
  for params: List<&2,NC_Binding>
  for +roots: List<&2,U32>
  for +i: U32
  List<&2,P171DLocal>

law p171d_fallback:
  for name: String
  for args: List<&2,N111Value>
  List<&2,P113DStmt>

law p171d_wrapper:
  for +name: String
  for +params: List<&2,NC_Binding>
  for +reader: String
  for +roots: List<&2,U32>
  P113DFunction

law p171d_proposal_done:
  for +owner: String
  for +original: P113DFunction
  for +roots: List<&2,U32>
  for +ids: N111Ids
  for +dependencies: List<&2,P113DFunction>
  for worker: P171DWorker
  P171DProposal

law p171d_proposal_checked:
  for owner: String
  for original: P113DFunction
  for reader: String
  for functions: List<&2,P113DFunction>
  for +accepted: U32
  for declined: U32
  for +ids: N111Ids
  for +dependencies: List<&2,P113DFunction>
  for projected: P118BWorkers
  P171DProposal

law p171d_select:
  for +owner: String
  for +book: List<&2,KDef>
  for +functions: List<&2,P113DFunction>
  for +ids: N111Ids
  for shape: P171DShape
  for found: Maybe<&2,P113DFunction>
  P171DProposal

law p171d_refuse:
  for owner: String
  for error: String
  P171DProposal

law p171d_checked:
  for +owner: String
  for +book: List<&2,KDef>
  for +base: P113DProgram
  for +adapters: KDef
  for +error: String
  P171DProposal

law p171d_lowered:
  for +request: NR_Request
  for +owner: String
  for lowered: P167Lowered
  P171DProposal

law p171d_request:
  for +request: NR_Request
  for owner: String
  P171DProposal

law p171d_summary:
  for proposal: P171DProposal
  List<&2,String>

law p171d_view_checked:
  for +owner: String
  for +book: List<&2,KDef>
  for +functions: List<&2,P113DFunction>
  for +ids: N111Ids
  for +error: String
  P171DProposal

law p171dc_context:
  P171DContext

law p171dc_env:
  List<&2,P171DLocal>

law p171dc_body:
  for +count: U32
  for +offset: U32
  List<&2,P113DStmt>

law p171dc_run:
  for body: List<&2,P113DStmt>
  for cases: List<&2,P171DCase>
  P171DCode

law p171dc_accept:
  for code: P171DCode
  Bool

law p171dc_exact:
  for code: P171DCode
  Bool

law p171dc_row:
  for +name: String
  for good: Bool
  String

law p171d_controls:
  List<&2,String>

law p171d_step:
  for +ctx: P171DContext
  for body: List<&2,P113DStmt>
  for +env: List<&2,P171DLocal>
  for +cases: List<&2,P171DCase>
  for +view: P171DView
  for +n: U32
  P171DCode

law p171d_nullary_args:
  for args: List<&2,N111Arg>
  Bool
