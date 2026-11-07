# Phase173 private render plan. Original P113D IR and final verifiers unchanged.
# Only an initial, fully recognized first-parameter tag dispatcher is eligible.
type P173DJArm is Data:
  P173DJArm{+tag: U32, +test: String, +body: List<&2,P113DStmt>}

type P173DJPlan is Data:
  P173DJPlan{+valid: Bool, +selector: String, +arms: List<&2,P173DJArm>, +otherwise: List<&2,P113DStmt>}

# Explicit helper interfaces for the pinned sequential source loader.
law p173dj_empty:
  P173DJPlan

law p173dj_valid:
  for +plan: P173DJPlan
  Bool

law p173dj_selector:
  for +params: List<&2,NC_Binding>
  String

law p173dj_tags:
  for +arms: List<&2,P173DJArm>
  for +tag: U32
  Bool

law p173dj_names:
  for +arms: List<&2,P173DJArm>
  List<&2,String>

law p173dj_strip:
  for +body: List<&2,P113DStmt>
  List<&2,P113DStmt>

law p173dj_parse:
  for +body: List<&2,P113DStmt>
  for +selector: String
  for +arms: List<&2,P173DJArm>
  for +depth: U32
  P173DJPlan

law p173dj_value:
  for +value: N111Value
  for +tests: List<&2,String>
  Bool

law p173dj_values:
  for +values: List<&2,N111Value>
  for +tests: List<&2,String>
  Bool

law p173dj_arguments:
  for +args: List<&2,N111Arg>
  for +tests: List<&2,String>
  Bool

law p173dj_destinations:
  for +names: List<&2,String>
  for +tests: List<&2,String>
  Bool

law p173dj_scalar:
  for +stmt: N111Stmt
  for +tests: List<&2,String>
  Bool

law p173dj_scalars:
  for +body: List<&2,N111Stmt>
  for +tests: List<&2,String>
  Bool

law p173dj_clear:
  for +body: List<&2,P113DStmt>
  for +tests: List<&2,String>
  for +arity: U32
  Bool

law p173dj_terminal:
  for +body: List<&2,P113DStmt>
  Bool

law p173dj_arms_clear:
  for +arms: List<&2,P173DJArm>
  for +tests: List<&2,String>
  for +arity: U32
  Bool

law p173dj_checked:
  for +params: List<&2,NC_Binding>
  for +plan: P173DJPlan
  P173DJPlan

law p173dj_plan:
  for +body: List<&2,P113DStmt>
  for +params: List<&2,NC_Binding>
  P173DJPlan

law p173dj_prefix:
  for +chunks: List<&2,String>
  Bool

law p173dj_initial:
  for +code: P111QCode
  Bool

law p173dj_namespace:
  for +code: P111QCode
  Bool

law p173dj_label:
  for +index: U32
  String

law p173dj_find:
  for +arms: List<&2,P173DJArm>
  for +tag: U32
  for +index: U32
  String

law p173dj_target:
  for +values: List<&2,N111Value>
  for +plan: P173DJPlan
  String

law p173dj_moves:
  for +params: List<&2,NC_Binding>
  for +index: U32
  for +label: String
  for +code: P111QCode
  P111QCode

law p173dj_one:
  for +head: P113DStmt
  for +params: List<&2,NC_Binding>
  for +ids: N111Ids
  for +plan: P173DJPlan
  for +code: P111QCode
  P111QCode

law p173dj_look:
  for +head: P113DStmt
  for +rest: List<&2,P113DStmt>
  for +params: List<&2,NC_Binding>
  for +ids: N111Ids
  for +plan: P173DJPlan
  for +code: P111QCode
  P111QCode

law p173dj_stmts:
  for +body: List<&2,P113DStmt>
  for +params: List<&2,NC_Binding>
  for +ids: N111Ids
  for +plan: P173DJPlan
  for +code: P111QCode
  P111QCode

law p173dj_if:
  for +condition: N111Value
  for +yes: List<&2,P113DStmt>
  for +no: List<&2,P113DStmt>
  for +params: List<&2,NC_Binding>
  for +ids: N111Ids
  for +plan: P173DJPlan
  for +code: P111QCode
  P111QCode

law p173dj_if_start:
  for +condition: N111Value
  for +yes: List<&2,P113DStmt>
  for +no: List<&2,P113DStmt>
  for +params: List<&2,NC_Binding>
  for +ids: N111Ids
  for +plan: P173DJPlan
  for +code: P111QCode
  P111QCode

law p173dj_if_yes:
  for +label: U32
  for +no: List<&2,P113DStmt>
  for +params: List<&2,NC_Binding>
  for +ids: N111Ids
  for +plan: P173DJPlan
  for +yes: P111QCode
  P111QCode

law p173dj_tests:
  for +arms: List<&2,P173DJArm>
  for +selector: String
  for +index: U32
  for +ids: N111Ids
  for +code: P111QCode
  P111QCode

law p173dj_arm_start:
  for +body: List<&2,P113DStmt>
  for +index: U32
  for +params: List<&2,NC_Binding>
  for +ids: N111Ids
  for +plan: P173DJPlan
  for +code: P111QCode
  P111QCode

law p173dj_arm_end:
  for +remaining: List<&2,P173DJArm>
  for +otherwise: List<&2,P113DStmt>
  for +index: U32
  for +params: List<&2,NC_Binding>
  for +ids: N111Ids
  for +plan: P173DJPlan
  for +code: P111QCode
  P111QCode

law p173dj_arms:
  for +arms: List<&2,P173DJArm>
  for +otherwise: List<&2,P113DStmt>
  for +index: U32
  for +params: List<&2,NC_Binding>
  for +ids: N111Ids
  for +plan: P173DJPlan
  for +code: P111QCode
  P111QCode

law p173dj_render:
  for +params: List<&2,NC_Binding>
  for +ids: N111Ids
  for +code: P111QCode
  for +plan: P173DJPlan
  P111QCode

law p173dj_selected:
  for +body: List<&2,P113DStmt>
  for +params: List<&2,NC_Binding>
  for +ids: N111Ids
  for +code: P111QCode
  for +plan: P173DJPlan
  P111QCode

@unsafe
def p173dj_empty():
  P173DJPlan{False{},"",[],[]}

@unsafe
def p173dj_valid(plan):
  match plan:
    case P173DJPlan{valid,selector,arms,otherwise}: valid

@unsafe
def p173dj_selector(params):
  match params:
    case Con{NC_Binding{id,word,N_W64{}},rest}: word
    case _: ""

@unsafe
def p173dj_tags(arms,tag):
  match arms:
    case Nil{}: False{}
    case Con{P173DJArm{+at,+test,+body},+rest}: U32.is_eq(at,tag) || p173dj_tags(rest,tag)

@unsafe
def p173dj_names(arms):
  match arms:
    case Nil{}: []
    case Con{P173DJArm{tag,test,body},rest}: Con{test,p173dj_names(rest)}

@unsafe
def p173dj_strip(body):
  match body:
    case Con{P113DScalar{N111Alloca{name,bytes,align}},rest}: p173dj_strip(rest)
    case _: body

@unsafe
def p173dj_parse(body,selector,arms,depth):
  match body:
    case [P113DScalar{N111Bin{+test,N111U64{},+op,N111Local{+word},N111Const{+tag,+hi}}},P113DIf{N111Local{+condition},+yes,+no}]:
      nt_choose(P173DJPlan,U32.is_lt(depth,63) && String.eq(op,"eq") && String.eq(word,selector) && U32.is_eq(hi,0) &&
        String.eq(condition,test) && Bool.not(p173dj_tags(arms,tag) || nb_contains(p173dj_names(arms),test)),
        u => p173dj_parse(no,selector,Con{P173DJArm{tag,test,yes},arms},U32.inc(depth)),u => p173dj_empty())
    case _: P173DJPlan{U32.is_gt(depth,0),selector,nt_reverse(P173DJArm,arms,[]),body}

@unsafe
def p173dj_value(value,tests):
  match value:
    case N111Local{name}: Bool.not(nb_contains(tests,name))
    case _: True{}

@unsafe
def p173dj_values(values,tests):
  match values:
    case Nil{}: True{}
    case Con{head,rest}: p173dj_value(head,tests) && p173dj_values(rest,tests)

@unsafe
def p173dj_arguments(args,tests):
  match args:
    case Nil{}: True{}
    case Con{N111Arg{typ,value},rest}: p173dj_value(value,tests) && p173dj_arguments(rest,tests)

@unsafe
def p173dj_destinations(names,tests):
  match names:
    case Nil{}: True{}
    case Con{name,rest}: Bool.not(nb_contains(tests,name)) && p173dj_destinations(rest,tests)

@unsafe
def p173dj_scalar(stmt,tests):
  match stmt:
    case N111Set{name,typ,value}: Bool.not(nb_contains(tests,name)) && p173dj_value(value,tests)
    case N111Bin{name,typ,op,left,right}: Bool.not(nb_contains(tests,name)) && p173dj_value(left,tests) && p173dj_value(right,tests)
    case N111Call{name,typ,symbol,args}: Bool.not(nb_contains(tests,name)) && p173dj_arguments(args,tests)
    case N111If{condition,yes,no}: p173dj_value(condition,tests) && p173dj_scalars(yes,tests) && p173dj_scalars(no,tests)
    case N111Return{value}: False{}
    case N111Load{name,typ,base,offset}: Bool.not(nb_contains(tests,name)) && p173dj_value(base,tests)
    case N111Store{typ,base,offset,value}: p173dj_value(base,tests) && p173dj_value(value,tests)
    case N111Offset{name,base,bytes}: Bool.not(nb_contains(tests,name)) && p173dj_value(base,tests) && p173dj_value(bytes,tests)
    case N111Alloca{name,bytes,align}: Bool.not(nb_contains(tests,name))

@unsafe
def p173dj_scalars(body,tests):
  match body:
    case Nil{}: True{}
    case Con{head,rest}: p173dj_scalar(head,tests) && p173dj_scalars(rest,tests)

@unsafe
def p173dj_clear(body,tests,arity):
  match body:
    case Nil{}: True{}
    case Con{P113DScalar{stmt},rest}: p173dj_scalar(stmt,tests) && p173dj_clear(rest,tests,arity)
    case Con{P113DIf{condition,yes,no},rest}: p173dj_value(condition,tests) && p173dj_clear(yes,tests,arity) && p173dj_clear(no,tests,arity) && p173dj_clear(rest,tests,arity)
    case Con{P113DCall{names,target,values},rest}: p173dj_destinations(names,tests) && p173dj_values(values,tests) && p173dj_clear(rest,tests,arity)
    case Con{P113DResult{values},rest}: p173dj_values(values,tests) && p173dj_clear(rest,tests,arity)
    case Con{P113DAgain{values},rest}: U32.is_eq(nt_count(N111Value,values),arity) && p173dj_values(values,tests) && p173dj_clear(rest,tests,arity)

@unsafe
def p173dj_terminal(body):
  match body:
    case [P113DResult{values}]: True{}
    case [P113DAgain{values}]: True{}
    case [P113DIf{condition,yes,no}]: p173dj_terminal(yes) && p173dj_terminal(no)
    case Con{P113DScalar{stmt},rest}: p173dj_terminal(rest)
    case Con{P113DCall{names,target,values},rest}: p173dj_terminal(rest)
    case _: False{}

@unsafe
def p173dj_arms_clear(arms,tests,arity):
  match arms:
    case Nil{}: True{}
    case Con{P173DJArm{tag,test,body},rest}: p173dj_terminal(body) && p173dj_clear(body,tests,arity) && p173dj_arms_clear(rest,tests,arity)

@unsafe
def p173dj_checked(params,plan):
  match plan:
    case P173DJPlan{+valid,+selector,+arms,+otherwise}:
      +tests = p173dj_names(arms)
      +arity = nt_count(NC_Binding,params)
      nt_choose(P173DJPlan,valid && Bool.not(String.is_empty(selector)) && U32.is_le(arity,32) &&
        p173dj_destinations(nc_words(params),tests) && p173dj_arms_clear(arms,tests,arity) &&
        p173dj_terminal(otherwise) && p173dj_clear(otherwise,tests,arity),
        u => plan,u => p173dj_empty())

@unsafe
def p173dj_plan(body,params):
  p173dj_checked(params,p173dj_parse(p173dj_strip(body),p173dj_selector(params),[],0))

@unsafe
def p173dj_prefix(chunks):
  match chunks:
    case Nil{}: True{}
    case Con{head,rest}: Bool.not(String.contains(head,"@p173dj_")) && p173dj_prefix(rest)

@unsafe
def p173dj_initial(code):
  match code:
    case P111QCode{Con{head,rest},site,terminal,error}:
      String.eq(head,"@p113_loop\n") && Bool.not(terminal) && String.is_empty(error)
    case _: False{}

@unsafe
def p173dj_namespace(code):
  match code:
    case P111QCode{chunks,site,terminal,error}: p173dj_prefix(chunks)

@unsafe
def p173dj_label(index):
  "@p173dj_arm_" ++ U32.show(index)

@unsafe
def p173dj_find(arms,tag,index):
  match arms:
    case Nil{}: p173dj_label(index)
    case Con{P173DJArm{+at,+test,+body},+rest}:
      nt_choose(String,U32.is_eq(tag,at),u => p173dj_label(index),u => p173dj_find(rest,tag,U32.inc(index)))

@unsafe
def p173dj_target(values,plan):
  match values plan:
    case Con{N111Const{tag,0},rest} P173DJPlan{valid,selector,arms,otherwise}: p173dj_find(arms,tag,0)
    case _ _: "@p113_loop"

@unsafe
def p173dj_moves(params,index,label,code):
  match params code:
    case Nil{} P111QCode{chunks,site,terminal,error}: P111QCode{Con{"jmp " ++ label ++ "\n",chunks},site,True{},error}
    case Con{NC_Binding{id,word,kind},rest} _:
      p173dj_moves(rest,U32.inc(index),label,p111q_line(p111q_local(word) ++ " =l copy %p113_again_" ++ U32.show(index) ++ "\n",code))

@unsafe
def p173dj_one(head,params,ids,plan,code):
  match head:
    case P113DAgain{+values}: p173dj_moves(params,0,p173dj_target(values,plan),p113e_snapshot(values,ids,0,code))
    case P113DIf{condition,yes,no}: p173dj_if(condition,yes,no,params,ids,plan,code)
    case _: p113w_one(head,params,ids,code)

@unsafe
def p173dj_look(head,rest,params,ids,plan,code):
  match rest:
    case Con{+second,+more}:
      nt_choose(P111QCode,p113w_pair(head,second) && p113w_room(code),
        u => p173dj_stmts(more,params,ids,plan,p113w_pair_emit(head,ids,code)),
        u => p173dj_stmts(rest,params,ids,plan,p173dj_one(head,params,ids,plan,code)))
    case Nil{}: p173dj_one(head,params,ids,plan,code)

@unsafe
def p173dj_stmts(body,params,ids,plan,code):
  match body code:
    case Nil{} _: code
    case Con{+head,+rest} P111QCode{chunks,site,terminal,+error}:
      nt_choose(P111QCode,String.is_empty(error),u =>
        nt_choose(P111QCode,terminal,u => p111q_problem("statement follows direct transfer",code),
          u => p173dj_look(head,rest,params,ids,plan,code)),u => code)

@unsafe
def p173dj_if(condition,yes,no,params,ids,plan,code):
  +diamond = p113bq_direct(yes,no)
  nt_choose(P111QCode,p113bq_ready(diamond,code),u => p113bq_emit(condition,diamond,ids,code),
    u => p173dj_if_start(condition,yes,no,params,ids,plan,code))

@unsafe
def p173dj_if_start(condition,yes,no,params,ids,plan,code):
  match code:
    case P111QCode{chunks,+site,terminal,error}:
      p173dj_if_yes(site,no,params,ids,plan,p173dj_stmts(yes,params,ids,plan,P111QCode{
        Con{p111q_label(site) ++ "\n",Con{"jnz " ++ p111q_value(condition,ids) ++ ", " ++ p111q_label(site) ++ ", " ++ p111q_label(U32.inc(site)) ++ "\n",chunks}},U32.add(site,3),False{},error}))

@unsafe
def p173dj_if_yes(label,no,params,ids,plan,yes):
  match yes:
    case P111QCode{chunks,site,+terminal,error}:
      +prefix = nt_choose(List<&2,String>,terminal,u => chunks,u => Con{"jmp " ++ p111q_label(U32.add(label,2)) ++ "\n",chunks})
      p111q_if_done(label,terminal,p173dj_stmts(no,params,ids,plan,P111QCode{Con{p111q_label(U32.inc(label)) ++ "\n",prefix},site,False{},error}))

@unsafe
def p173dj_tests(arms,selector,index,ids,code):
  match arms:
    case Nil{}: p111q_line("jmp " ++ p173dj_label(index) ++ "\n",code)
    case Con{P173DJArm{+tag,+test,+body},+rest}:
      +next = "@p173dj_test_" ++ U32.show(U32.inc(index))
      +compared = p111q_stmt(N111Bin{test,N111U64{},"eq",N111Local{selector},N111Const{tag,0}},ids,code)
      p173dj_tests(rest,selector,U32.inc(index),ids,
        p111q_line("jnz " ++ p111q_local(test) ++ ", " ++ p173dj_label(index) ++ ", " ++ next ++ "\n" ++ next ++ "\n",compared))

@unsafe
def p173dj_arm_start(body,index,params,ids,plan,code):
  match code:
    case P111QCode{chunks,site,terminal,error}:
      p173dj_stmts(body,params,ids,plan,P111QCode{Con{p173dj_label(index) ++ "\n",chunks},site,False{},error})

@unsafe
def p173dj_arm_end(remaining,otherwise,index,params,ids,plan,code):
  match code:
    case P111QCode{chunks,site,+terminal,error}:
      nt_choose(P111QCode,terminal,u => p173dj_arms(remaining,otherwise,index,params,ids,plan,code),
        u => p111q_problem("dispatcher arm has no terminal",code))

@unsafe
def p173dj_arms(arms,otherwise,index,params,ids,plan,code):
  match arms:
    case Nil{}: p173dj_arm_start(otherwise,index,params,ids,plan,code)
    case Con{P173DJArm{tag,test,body},rest}:
      p173dj_arm_end(rest,otherwise,U32.inc(index),params,ids,plan,p173dj_arm_start(body,index,params,ids,plan,code))

@unsafe
def p173dj_render(params,ids,code,plan):
  match plan:
    case P173DJPlan{valid,selector,+arms,otherwise}:
      p173dj_arms(arms,otherwise,0,params,ids,plan,p173dj_tests(arms,selector,0,ids,code))

@unsafe
def p173dj_selected(body,params,ids,code,plan):
  nt_choose(P111QCode,p173dj_valid(plan) && p173dj_namespace(code),u => p173dj_render(params,ids,code,plan),u => p113w_stmts(body,params,ids,code))

@unsafe
def p173dj_entry(body,params,ids,code):
  nt_choose(P111QCode,p173dj_initial(code),
    u => p173dj_selected(body,params,ids,code,p173dj_plan(body,params)),
    u => p113w_stmts(body,params,ids,code))
