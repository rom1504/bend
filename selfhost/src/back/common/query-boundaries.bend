
@unsafe
def p137w_verifier_ids() -> N111Ids:
  N111Ids{missing(),p111v_put(p111v_put(p111v_put(p111v_put(missing(),
    "eight","constructor",8,0),"nine","constructor",9,0),
    "sixteen","constructor",16,0),"seventeen","constructor",17,0)}

@unsafe
def p137w_ids() -> N111Ids:
  N111Ids{missing(),p111q_constructor_ids([
    N_Constructor{"eight",8,False{}},N_Constructor{"nine",9,False{}},
    N_Constructor{"sixteen",16,False{}},N_Constructor{"seventeen",17,False{}}],0,missing())}

@unsafe
def p137w_project(ctor: String, count: U32, state: String, typ: N111Type) -> Bool:
  String.is_empty(p113d_error(p118b_project_borrow("result",typ,
    [N111Arg{N111Ptr{},N111Local{state}},p111_word(N111Local{"root"}),
     N111Arg{N111Ptr{},N111Local{"scratch"}},N111Arg{N111U32{},N111CtorId{ctor}},p111_u32(count)],p137w_verifier_ids())))

@unsafe
def p137w_controls() -> List<&2,String>:
  +args : List<&2,N111Arg> = [N111Arg{N111Ptr{},N111Local{"buffer"}}]
  +small = p111v_put(missing(),"buffer","alloca",3,64)
  +large = p111v_put(missing(),"buffer","alloca",3,128)
  [p128bs_control_row("wide-eight",p131rg_width(8)),
   p128bs_control_row("wide-nine",p131rg_width(9)),
   p128bs_control_row("wide-sixteen",p131rg_width(16)),
   p128bs_control_row("wide-seventeen-refused",Bool.not(p131rg_width(17))),
   p128bs_control_row("wide-packed-refused",Bool.not(p131rg_width(1))),
   p128bs_control_row("wide-import-eight",p137w_project("eight",8,"state",N111U64{})),
   p128bs_control_row("wide-import-nine",p137w_project("nine",9,"state",N111U64{})),
   p128bs_control_row("wide-import-sixteen",p137w_project("sixteen",16,"state",N111U64{})),
   p128bs_control_row("wide-import-seventeen-refused",Bool.not(p137w_project("seventeen",17,"state",N111U64{}))),
   p128bs_control_row("wide-import-mismatch-refused",Bool.not(p137w_project("nine",8,"state",N111U64{}))),
   p128bs_control_row("wide-import-unknown-refused",Bool.not(p137w_project("unknown",9,"state",N111U64{}))),
   p128bs_control_row("wide-import-state-refused",Bool.not(p137w_project("nine",9,"other",N111U64{}))),
   p128bs_control_row("wide-import-result-refused",Bool.not(p137w_project("nine",9,"state",N111Ptr{}))),
   p128bs_control_row("wide-buffer-nine-small-refused",Bool.not(p111v_buffer(args,0,9,small))),
   p128bs_control_row("wide-buffer-sixteen-128",p111v_buffer(args,0,16,large)),
   p128bs_control_row("wide-buffer-unknown-refused",Bool.not(p111v_buffer(args,0,9,missing()))),
   p128bs_control_row("wide-late-template-stays-refused",Bool.not(p128bf_test_admitted(p128bf_test_ordinary("nine",9),p137w_ids(),0)))]

@unsafe
def p137qi_wide_args(args: List<&2,N111Arg>) -> Bool:
  match args:
    case Con{N111Arg{N111Ptr{},state},Con{N111Arg{N111U64{},term},Con{N111Arg{N111Ptr{},buffer},Con{N111Arg{N111U32{},N111Const{+count,0}},Nil{}}}}}:
      U32.is_ge(count,9) && U32.is_le(count,16)
    case _: False{}


@unsafe
def p137qi_scalar(stmt: N111Stmt) -> Bool:
  match stmt:
    case N111Call{name,typ,symbol,args}:
      Bool.not(String.eq(symbol,"p111_rt_take") && p137qi_wide_args(args))
    case N111If{condition,yes,no}: p137qi_scalars(yes) && p137qi_scalars(no)
    case _: True{}


@unsafe
def p137qi_scalars(body: List<&2,N111Stmt>) -> Bool:
  match body:
    case Nil{}: True{}
    case Con{head,rest}: p137qi_scalar(head) && p137qi_scalars(rest)

# Same shape walk as p113j_plain/p113j_returns. Add the profitability test while
# visiting existing scalar nodes, rather than starting a second whole-body walk.

@unsafe
def p137qi_plain(body: List<&2,P113DStmt>) -> Bool:
  match body:
    case Nil{}: True{}
    case Con{P113DScalar{stmt},rest}: p137qi_scalar(stmt) && p137qi_plain(rest)
    case Con{P113DCall{destinations,target,args},rest}: p137qi_plain(rest)
    case Con{P113DIf{condition,yes,no},rest}: p137qi_plain(yes) && p137qi_plain(no) && p137qi_plain(rest)
    case _: False{}


@unsafe
def p137qi_returns(body: List<&2,P113DStmt>, +width: U32) -> Bool:
  match body:
    case Con{P113DResult{values},Nil{}}: U32.is_eq(nt_count(N111Value,values),width)
    case Con{P113DIf{condition,yes,no},Nil{}}: p137qi_returns(yes,width) && p137qi_returns(no,width)
    case Con{P113DIf{condition,yes,no},rest}: p137qi_plain(yes) && p137qi_plain(no) && p137qi_returns(rest,width)
    case Con{P113DScalar{stmt},rest}: p137qi_scalar(stmt) && p137qi_returns(rest,width)
    case Con{P113DCall{destinations,target,args},rest}: p137qi_returns(rest,width)
    case _: False{}


@unsafe
def p137qi_take(symbol: String, count: N111Value) -> N111Stmt:
  N111Call{"ignored",N111U64{},symbol,[p111_state(),p111_word(N111Local{"owner"}),p111_scratch(),N111Arg{N111U32{},count}]}


@unsafe
def p137qi_done(stmt: N111Stmt) -> List<&2,P113DStmt>:
  [P113DScalar{stmt},P113DResult{[N111Const{1,0}]}]


@unsafe
def p137qi_function(stmt: N111Stmt) -> P113DFunction:
  P113DFunction{"policy-control",[],1,False{},p137qi_done(stmt)}

# These malformed-IR fixtures test only retention of the old profitability
# choice. They are not admitted programs; independent verification is unchanged.

@unsafe
def p137qi_malformed_count() -> N111Stmt:
  N111Call{"ignored",N111U64{},"p111_rt_take",[p111_state(),p111_word(N111Local{"owner"}),p111_scratch(),N111Arg{N111U64{},N111Const{9,0}}]}


@unsafe
def p137qi_controls() -> List<&2,String>:
  +wide = p137qi_take("p111_rt_take",N111Const{9,0})
  +small = p137qi_take("p111_rt_take",N111Const{8,0})
  +result : List<&2,P113DStmt> = [P113DResult{[N111Const{1,0}]}]
  [p113ft_row("retain-8-unchanged",p137qi_scalar(small)),
   p113ft_row("retain-9-deferred",Bool.not(p137qi_scalar(wide))),
   p113ft_row("retain-16-deferred",Bool.not(p137qi_scalar(p137qi_take("p111_rt_take",N111Const{16,0})))),
   p113ft_row("retain-17-unchanged",p137qi_scalar(p137qi_take("p111_rt_take",N111Const{17,0}))),
   p113ft_row("retain-highword-unchanged",p137qi_scalar(p137qi_take("p111_rt_take",N111Const{9,1}))),
   p113ft_row("retain-dynamic-unchanged",p137qi_scalar(p137qi_take("p111_rt_take",N111Local{"count"}))),
   p113ft_row("retain-other-import-unchanged",p137qi_scalar(p137qi_take("p111_rt_ctor",N111Const{9,0}))),
   p113ft_row("retain-nested-scalar",Bool.not(p137qi_scalar(N111If{N111Const{1,0},[wide],[]}))),
   p113ft_row("retain-straight-return",Bool.not(p137qi_returns(p137qi_done(wide),1))),
   p113ft_row("retain-small-return",p137qi_returns(p137qi_done(small),1)),
   p113ft_row("retain-nested-direct",Bool.not(p137qi_returns([P113DIf{N111Const{1,0},p137qi_done(wide),result}],1))),
   p113ft_row("retain-shared-suffix",Bool.not(p137qi_returns([P113DIf{N111Const{1,0},[P113DScalar{wide}],[]},P113DResult{[N111Const{1,0}]}],1))),
   p113ft_row("retain-original-return-shape-unchanged",p113j_returns(p137qi_done(wide),1)),
   p113ft_row("retain-original-loop-refused",Bool.not(p137qi_returns([P113DAgain{[N111Const{1,0}]}],1))),
   p113ft_row("retain-wrong-result-count-refused",Bool.not(p137qi_returns(result,2))),
   p113ft_row("retain-actual-eligible-8",p113i_eligible(p137qi_function(small))),
   p113ft_row("retain-actual-refused-9",Bool.not(p113i_eligible(p137qi_function(wide)))),
   p113ft_row("retain-actual-refused-16",Bool.not(p113i_eligible(p137qi_function(p137qi_take("p111_rt_take",N111Const{16,0}))))),
   p113ft_row("retain-malformed-count-type-old-policy",p113i_eligible(p137qi_function(p137qi_malformed_count()))),
   p113ft_row("retain-short-arguments-old-policy",p113i_eligible(p137qi_function(N111Call{"ignored",N111U64{},"p111_rt_take",[p111_state()]})))]

@unsafe
def p137q_name_eq(key: String, record: KDef) -> Bool:
  match record:
    case KDef{name,kind,arity,templates,typ,value,ctors,native,unsafe}: p88_string_eq(name,key)
    case KIndexLeaf{hash,bucket}: p88_string_eq("",key)
    case KIndexNode{hash,mask,left,right}: p88_string_eq("",key)


@unsafe
def p137q_key_eq(key: String, record: KDef) -> Bool:
  match record:
    case KDef{name,kind,arity,templates,typ,value,ctors,native,unsafe}: p88_string_eq(key,name)
    case KIndexLeaf{hash,bucket}: p88_string_eq(key,"")
    case KIndexNode{hash,mask,left,right}: p88_string_eq(key,"")


@unsafe
def p137q_is_cache(record: KDef) -> Bool:
  match record:
    case KDef{name,kind,arity,templates,typ,value,ctors,native,unsafe}: p88_string_eq(kind,"BookCache")
    case KIndexLeaf{hash,bucket}: False{}
    case KIndexNode{hash,mask,left,right}: False{}


@unsafe
def p137q_is_adt(record: KDef) -> Bool:
  match record:
    case KDef{name,kind,arity,templates,typ,value,ctors,native,unsafe}: p88_string_eq(kind,"ADT")
    case KIndexLeaf{hash,bucket}: False{}
    case KIndexNode{hash,mask,left,right}: False{}


@unsafe
def p137q_is_ctr(record: KDef) -> Bool:
  match record:
    case KDef{name,kind,arity,templates,typ,value,ctors,native,unsafe}: p88_string_eq(kind,"Ctr")
    case KIndexLeaf{hash,bucket}: False{}
    case KIndexNode{hash,mask,left,right}: False{}
