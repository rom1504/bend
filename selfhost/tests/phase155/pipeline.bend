# Isolated Phase155 backend-analysis kernels. No production entry replacement.
# ID14 is a source-level rejection; see experiments/phase155/pipeline/README.md.

@unsafe
def p155b_kind_text(kind: N_WordKind) -> String:
  match kind:
    case N_W32{}: "w32"
    case N_W64{}: "w64"
    case N_Box{}: "box"
    case N_Imm64{}: "imm64"

@unsafe
def p155b_env_text(env: List<&2,NC_Binding>) -> String:
  match env:
    case Nil{}: ""
    case Con{NC_Binding{id,word,kind},rest}:
      U32.show(id) ++ ":" ++ word ++ ":" ++ p155b_kind_text(kind) ++ ";" ++ p155b_env_text(rest)

@unsafe
def p155b_keep_text(stmts: List<&2,N111Stmt>) -> String:
  match stmts:
    case Nil{}: ""
    case Con{N111Call{name,typ,symbol,args},rest}:
      name ++ ":" ++ p111q_type(typ) ++ ":" ++ symbol ++ "(" ++
        nt_text_finish(p111q_args(args,N111Ids{missing(),missing()},True{},[]),"") ++ ");" ++ p155b_keep_text(rest)
    case _: "unexpected-keep-statement"

@unsafe
def p155b_15_observe(keeps: List<&2,N111Stmt>, live: List<&2,NC_Binding>) -> String:
  p155b_keep_text(keeps) ++ "|live|" ++ p155b_env_text(live)

@unsafe
def p155b_15_before(+body: KTerm, +env: List<&2,NC_Binding>, value_env: List<&2,NC_Binding>) -> String:
  p155b_15_observe(p111_keep(value_env,nc_uses(body)),nc_live_env(env,body))

@unsafe
def p155b_15_after(+body: KTerm, +env: List<&2,NC_Binding>, value_env: List<&2,NC_Binding>) -> String:
  +uses = nc_uses(body)
  p155b_15_observe(p111_keep(value_env,uses),nc_live_uses(env,uses))

@unsafe
def p155b_15_env() -> List<&2,NC_Binding>:
  [NC_Binding{0,"owned",N_Box{}},NC_Binding{1,"word",N_W32{}},
   NC_Binding{2,"opaque",N_W64{}},NC_Binding{3,"packed",N_Imm64{}},
   NC_Binding{4,"unused",N_Box{}},NC_Binding{4294967295,"wide",N_W64{}},
   NC_Binding{2,"shadow",N_Box{}}]

@unsafe
def p155b_15_terms(n: U32) -> List<&2,KTerm>:
  match n:
    case 0: []
    case _: Con{kt("Branch","",0,0,[var("",0),var("",1),var("",2),var("",3),var("",4294967295)]),p155b_15_terms(U32.sub(n,1))}

@unsafe
def p155b_15_old(n: U32) -> String:
  +env = p155b_15_env()
  p155b_15_before(kt("Body","",0,0,p155b_15_terms(n)),env,env)

@unsafe
def p155b_15_new(n: U32) -> String:
  +env = p155b_15_env()
  p155b_15_after(kt("Body","",0,0,p155b_15_terms(n)),env,env)

type P155BStats is Data:
  P155BStats{+clean: Bool, +size: U32, +stack: U32}

@unsafe
def p155b_16_join(left: P155BStats, right: P155BStats) -> P155BStats:
  match left right:
    case P155BStats{lc,ls,la} P155BStats{rc,rs,ra}:
      P155BStats{lc && rc,p113i_add(ls,rs),p113i_stack_add(la,ra)}

@unsafe
def p155b_16_node(clean: Bool, more: P155BStats) -> P155BStats:
  match more:
    case P155BStats{ok,size,stack}: P155BStats{clean && ok,p113i_add(1,size),stack}

@unsafe
def p155b_16_scalar(+stmt: N111Stmt) -> P155BStats:
  match stmt:
    case N111If{condition,yes,no}:
      p155b_16_node(p113i_value(condition),p155b_16_join(p155b_16_scalars(yes),p155b_16_scalars(no)))
    case _: P155BStats{p113i_scalar_clean(stmt),p113i_scalar_size(stmt),p113i_scalar_stack(stmt)}

@unsafe
def p155b_16_scalars(body: List<&2,N111Stmt>) -> P155BStats:
  match body:
    case Nil{}: P155BStats{True{},0,0}
    case Con{head,rest}: p155b_16_join(p155b_16_scalar(head),p155b_16_scalars(rest))

@unsafe
def p155b_16_walk(body: List<&2,P113DStmt>) -> P155BStats:
  match body:
    case Nil{}: P155BStats{True{},0,0}
    case Con{P113DScalar{stmt},rest}: p155b_16_join(p155b_16_scalar(stmt),p155b_16_walk(rest))
    case Con{P113DIf{condition,yes,no},rest}:
      p155b_16_node(p113i_value(condition),p155b_16_join(p155b_16_walk(yes),p155b_16_join(p155b_16_walk(no),p155b_16_walk(rest))))
    case Con{P113DCall{destinations,target,args},rest}:
      p155b_16_node(p113i_names(destinations) && p113i_values(args),p155b_16_walk(rest))
    case Con{P113DResult{values},rest}: p155b_16_node(p113i_values(values),p155b_16_walk(rest))
    case Con{P113DAgain{values},rest}: p155b_16_node(p113i_values(values),p155b_16_walk(rest))

@unsafe
def p155b_16_text(stats: P155BStats) -> String:
  match stats:
    case P155BStats{clean,size,stack}:
      nt_choose(String,clean,u => "clean",u => "dirty") ++ ":" ++ U32.show(size) ++ ":" ++ U32.show(stack)

@unsafe
def p155b_16_before(+body: List<&2,P113DStmt>) -> String:
  p155b_16_text(P155BStats{p113i_clean(body),p113i_size(body),p113i_stack(body)})

@unsafe
def p155b_16_after(body: List<&2,P113DStmt>) -> String:
  p155b_16_text(p155b_16_walk(body))

@unsafe
def p155b_16_body(n: U32) -> List<&2,P113DStmt>:
  match n:
    case 0: [P113DResult{[N111Local{"out"}]}]
    case _:
      Con{P113DScalar{N111If{N111Local{"condition"},
        [N111Alloca{"scratch",64,8},N111Set{"out",N111U64{},N111Const{17,0}}],
        [N111Bin{"out",N111U64{},"add",N111Const{1,0},N111Const{2,0}}]}},
      Con{P113DIf{N111Local{"condition"},[P113DScalar{N111Alloca{"other",32,8}}],
        [P113DCall{["out"],"callee",[N111Const{3,0}]}]},p155b_16_body(U32.sub(n,1))}}

@unsafe
def p155b_16_old(n: U32) -> String:
  p155b_16_before(p155b_16_body(n))

@unsafe
def p155b_16_new(n: U32) -> String:
  p155b_16_after(p155b_16_body(n))

@unsafe
def p155b_15_equal(+body: KTerm, +env: List<&2,NC_Binding>, +value_env: List<&2,NC_Binding>) -> Bool:
  String.eq(p155b_15_before(body,env,value_env),p155b_15_after(body,env,value_env))

@unsafe
def p155b_16_equal(+body: List<&2,P113DStmt>) -> Bool:
  String.eq(p155b_16_before(body),p155b_16_after(body))

@unsafe
def p155b_controls() -> Bool:
  +env = p155b_15_env()
  String.eq(p155b_15_old(0),"|live|") &&
  String.eq(p155b_16_old(1),"clean:8:96") &&
  String.eq(p155b_16_new(1),"clean:8:96") &&
  p155b_15_equal(kt("Var","",0,0,[var("",4)]),env,env) &&
  p155b_15_equal(var("",4294967295),env,env) &&
  p155b_15_equal(kt("Empty","",0,0,[]),[],env) &&
  p155b_15_equal(kt("Mixed","",0,0,p155b_15_terms(7)),env,[]) &&
  p155b_16_equal([]) && p155b_16_equal(p155b_16_body(1)) &&
  p155b_16_equal([P113DScalar{N111Alloca{"p113i_reserved",4294967295,8}},P113DAgain{[N111Local{"bad"}]}]) &&
  p155b_16_equal([P113DScalar{N111Return{N111Const{0,0}}}]) &&
  p155b_16_equal([P113DCall{["p113i_bad"],"callee",[N111Local{"p113i_input"}]}]) &&
  p155b_16_equal([P113DScalar{N111Load{"x",N111U64{},N111Local{"base"},8}},
    P113DScalar{N111Store{N111U64{},N111Local{"base"},0,N111Const{1,0}}},
    P113DScalar{N111Offset{"x",N111Local{"base"},N111Const{8,0}}},
    P113DScalar{N111Call{"x",N111U64{},"external",[N111Arg{N111U64{},N111Local{"base"}}]}}]) &&
  p155b_16_equal(p155b_16_body(586)) &&
  p155b_16_equal([P113DScalar{N111Alloca{"a",40000,8}},P113DScalar{N111Alloca{"b",40000,8}}])
