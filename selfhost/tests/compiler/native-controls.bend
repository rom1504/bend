

def p113dft_scalar(kind: N_WordKind) -> Bool:
  match kind:
    case N_W32{}: True{}
    case _: False{}


def p113dft_box(kind: N_WordKind) -> Bool:
  match kind:
    case N_Box{}: True{}
    case _: False{}


@unsafe
def p113dft_row(+name: String, valid: Bool) -> String:
  nt_choose(String,valid,u => "PASS " ++ name,u => "FAIL " ++ name)


def p113dft_mat(name: String, count: U32, mask: U32) -> KTerm:
  kt("Mat",name,U32.inc(count),mask,[{KTerm{"Efq", "", 0, 0, Nil{}, Nil{}, 0, 0} : KTerm},{KTerm{"Efq", "", 0, 0, Nil{}, Nil{}, 0, 0} : KTerm}])


@unsafe
def p113dft_bits(bindings: List<&2,NC_Binding>, +i: U32) -> U32:
  match bindings:
    case Nil{}: 0
    case Con{NC_Binding{id,word,kind},rest}:
      U32.or(nt_choose(U32,p113dft_scalar(kind),u => U32.shln(1,U32.to_nat(i)),u => 0),p113dft_bits(rest,U32.inc(i)))


@unsafe
def p113dft_mask(+count: U32, +mask: U32) -> U32:
  p113dft_bits(p113df_field_env([],p113dft_mat("record",count,mask),count,0,7),0)


def p113dft_type(name: String) -> KTerm:
  kt("ADT",name,0,0,[])


def p113dft_owner(name: String, builtin: Bool) -> KDef:
  KDef{name,"ADT",0,0,{KTerm{"Data", "", 0, 0, Nil{}, Nil{}, 0, 0} : KTerm},{KTerm{"Absent", "", 0, 0, Nil{}, Nil{}, 0, 0} : KTerm},[],builtin,False{}}


def p113dft_book() -> List<&2,KDef>:
  [p113dft_owner("U32",True{}),p113dft_owner("F32",True{}),p113dft_owner("Char",True{}),
   p113dft_owner("Bool",True{}),p113dft_owner("String",True{})]


@unsafe
def p113dft_tele(+first: KTerm, +second: KTerm) -> KTerm:
  kt("All","first",1,1,[first,kt("All","second",2,1,[second,p113dft_type("record")])])


@unsafe
def p113dft_erased() -> U32:
  nh_field_mask(p113dft_book(),kt("All","erased",3,0,[p113dft_type("U32"),
    p113dft_tele(p113dft_type("String"),p113dft_type("F32"))]),3,0)


@unsafe
def p113dft_alias() -> U32:
  +alias : KDef = KDef{"FloatAlias","Def",0,0,{KTerm{"Typ", "", 0, 0, Nil{}, Nil{}, 0, 0} : KTerm},p113dft_type("F32"),[],False{},False{}}
  nh_field_mask(Con{alias,p113dft_book()},p113dft_tele(kt("Ref","FloatAlias",0,0,[]),p113dft_type("String")),2,0)


def p113dft_env() -> List<&2,NC_Binding>:
  [NC_Binding{11,"full_left",N_W64{}},NC_Binding{12,"full_right",N_Box{}}]


@unsafe
def p113dft_bundle(+mask: U32) -> List<&2,NC_Binding>:
  p113df_bundle_env(p113dft_mat("record",2,mask),kt("NQBundle","record",0,0,[var("",11),var("",12)]),p113dft_env())


@unsafe
def p113dft_names(bindings: List<&2,NC_Binding>) -> Bool:
  match bindings:
    case Con{NC_Binding{a,aw,ak},Con{NC_Binding{b,bw,bk},Nil{}}}:
      U32.is_eq(a,11) && U32.is_eq(b,12) && String.eq(aw,"full_left") && String.eq(bw,"full_right")
    case _: False{}


def p113dft_drop(parts: P111Partition) -> U32:
  match parts:
    case P111Partition{live,drop}: nt_count(N111Stmt,drop)


@unsafe
def p113nmt_mat(+name: String, +arity: U32, +mask: U32) -> KTerm:
  kt("Mat",name,arity,mask,[{KTerm{"Efq", "", 0, 0, Nil{}, Nil{}, 0, 0} : KTerm},{KTerm{"Efq", "", 0, 0, Nil{}, Nil{}, 0, 0} : KTerm}])


@unsafe
def p113nmt_shape(code: List<&2,N111Stmt>, +n: U32, +lo: U32, +hi: U32) -> Bool:
  match code:
    case Con{N111Bin{name,N111U64{},op,N111Const{a,b},N111Const{1,0}},Nil{}}:
      String.eq(name,"v_" ++ U32.show(nc_id(n))) && String.eq(op,"sub") && U32.is_eq(a,lo) && U32.is_eq(b,hi)
    case _: False{}


@unsafe
def p113nmt_word(+lo: U32, +hi: U32) -> Bool:
  p113nmt_shape(p113nm_take(p113nt_book(True{}),p113nmt_mat("Succ",2,0),N111Const{lo,hi},1,11),11,lo,hi)


@unsafe
def p113nmt_local(code: List<&2,N111Stmt>) -> Bool:
  match code:
    case Con{N111Bin{name,N111U64{},op,N111Local{word},N111Const{1,0}},Nil{}}:
      String.eq(name,"v_" ++ U32.show(nc_id(7))) && String.eq(op,"sub") && String.eq(word,"original_nat")
    case _: False{}


@unsafe
def p113nmt_fallback(code: List<&2,N111Stmt>, +expected: String) -> Bool:
  match code:
    case Con{N111Call{name,N111U64{},symbol,args},rest}: String.eq(name,"ignored") && String.eq(symbol,expected)
    case _: False{}


@unsafe
def p113dct_row(+name: String, valid: Bool) -> String:
  nt_choose(String,valid,u => "PASS " ++ name,u => "FAIL " ++ name)


def p113dct_lambda(id: U32, body: KTerm) -> KTerm:
  k_lam("argument",id,1,[body],0,0,False{})


def p113dct_identity() -> KTerm:
  p113dct_lambda(90,var("",90))


def p113dct_body() -> KTerm:
  app(var("",11),app(var("",10),var("",12)))


def p113dct_definition(body: KTerm) -> KDef:
  KDef{"combine","Def",3,0,{KTerm{"Typ", "", 0, 0, Nil{}, Nil{}, 0, 0} : KTerm},
    p113dct_lambda(10,p113dct_lambda(11,p113dct_lambda(12,body))),[],False{},False{}}


def p113dct_head(mode: U32) -> KTerm:
  kt("Ref","combine",0,mode,[])


@unsafe
def p113dct_plan(body: KTerm, args: List<&2,KTerm>, mode: U32, env: List<&2,NC_Binding>, n: U32) -> KTerm:
  p113dc_plan([p113dct_definition(body)],p113dct_head(mode),args,env,n)


def p113dct_valid(t: KTerm) -> Bool:
  Bool.not(String.eq(tg(t),"Absent"))


@unsafe
def p113dct_order(+t: KTerm) -> Bool:
  String.eq(tg(t),"Let") && String.eq(tg(kid(kid(t,0),0)),"Var") &&
  U32.is_eq(ix(kid(kid(t,0),0)),98) && String.eq(tg(kid(t,1)),"Let") &&
  U32.is_eq(ix(kid(kid(kid(t,1),0),0)),99)


@unsafe
def p113wt_row(+name: String, valid: Bool) -> String:
  nt_choose(String,valid,u => "PASS " ++ name,u => "FAIL " ++ name)


def p113wt_first(op: String) -> P113DStmt:
  P113DScalar{N111Bin{"value",N111U64{},op,N111Local{"a"},N111Local{"b"}}}


def p113wt_mask(destination: String, source: String, lo: U32, hi: U32) -> P113DStmt:
  P113DScalar{N111Bin{destination,N111U64{},"and",N111Local{source},N111Const{lo,hi}}}


@unsafe
def p113wt_accept(op: String) -> Bool:
  p113w_pair(p113wt_first(op),p113wt_mask("value","value",4294967295,0))


@unsafe
def p113wt_text(+body: List<&2,P113DStmt>) -> String:
  p111q_body_text(p113w_stmts(nt_append(P113DStmt,body,[P113DResult{[N111Const{0,0}]}]),[],N111Ids{missing(),missing()},P111QCode{[],7,False{},""}))


@unsafe
def p113wt_next(code: P111QCode, +expected: U32) -> Bool:
  match code:
    case P111QCode{chunks,next,terminal,error}: U32.is_eq(next,expected)


def p113wt_op(which: U32) -> String:
  match which:
    case 0: "add"
    case 1: "sub"
    case 2: "mul"
    case 3: "and"
    case 4: "or"
    case _: "xor"


@unsafe
def p113wt_case_body(+which: U32) -> List<&2,P113DStmt>:
  +a : N111Value = N111Local{"a"}
  +b : N111Value = N111Local{"b"}
  +value : N111Value = N111Local{"value"}
  +mask : P113DStmt = p113wt_mask("value","value",4294967295,0)
  nt_choose(List<&2,P113DStmt>,U32.is_lt(which,6),u =>
    [p113wt_first(p113wt_op(which)),mask,P113DResult{[value]}],u =>
  nt_choose(List<&2,P113DStmt>,U32.is_eq(which,6),u =>
    [p113wt_mask("value","a",4294967295,0),P113DResult{[value]}],u =>
  nt_choose(List<&2,P113DStmt>,U32.is_eq(which,7),u =>
    [P113DScalar{N111Bin{"a",N111U64{},"add",a,b}},p113wt_mask("a","a",4294967295,0),P113DResult{[a]}],u =>
  nt_choose(List<&2,P113DStmt>,U32.is_eq(which,8),u =>
    [P113DScalar{N111Bin{"a",N111U64{},"mul",a,a}},p113wt_mask("a","a",4294967295,0),P113DResult{[a]}],u =>
  nt_choose(List<&2,P113DStmt>,U32.is_eq(which,9),u =>
    [p113wt_first("add"),p113wt_mask("other","value",4294967295,0),P113DResult{[value]}],u =>
  nt_choose(List<&2,P113DStmt>,U32.is_eq(which,10),u =>
    [P113DScalar{N111Bin{"value",N111U64{},"shr",a,N111Const{32,0}}},mask,P113DResult{[value]}],u =>
  nt_choose(List<&2,P113DStmt>,U32.is_eq(which,11),u =>
    [P113DScalar{N111Bin{"value",N111U64{},"shl",a,N111Const{40,0}}},mask,P113DResult{[value]}],u =>
  nt_choose(List<&2,P113DStmt>,U32.is_eq(which,12),u =>
    [p113wt_first("add"),P113DScalar{N111Set{"saved",N111U64{},value}},mask,P113DResult{[N111Local{"saved"}]}],u =>
  nt_choose(List<&2,P113DStmt>,U32.is_eq(which,13),u =>
    [p113wt_first("add"),p113wt_mask("value","value",4294967294,0),P113DResult{[value]}],u =>
  nt_choose(List<&2,P113DStmt>,U32.is_eq(which,14),u =>
    [p113wt_first("add"),p113wt_mask("value","value",4294967295,1),P113DResult{[value]}],u =>
    [p113wt_first("mul"),mask,P113DScalar{N111Bin{"upper",N111U64{},"shr",value,N111Const{40,0}}},P113DResult{[N111Local{"upper"}]}]))))))))))


@unsafe
def p114st_row(+name: String, ok: Bool) -> String:
  nt_choose(String,ok,u => "PASS " ++ name,u => "FAIL " ++ name)


def p114st_original() -> P112StaticProgram:
  P112StaticProgram{P111Program{[N111Segment{"main",0,1,0,0,[N111Return{N111Const{0,0}}]}],[],[0],[],[],True{}},[]}


def p114st_identity() -> P113DFunction:
  P113DFunction{"p114_identity",[NC_Binding{0,"a",N_W64{}}],1,False{},[P113DResult{[N111Local{"a"}]}]}


def p114st_scalar() -> P113DFunction:
  P113DFunction{"p114_scalar",[NC_Binding{0,"a",N_W64{}}],1,False{},
    [P113DScalar{N111Bin{"sum",N111U64{},"add",N111Local{"a"},N111Const{1,0}}},
     P113DScalar{N111Bin{"sum",N111U64{},"and",N111Local{"sum"},N111Const{4294967295,0}}},
     P113DResult{[N111Local{"sum"}]}]}


def p114st_pair() -> P113DFunction:
  P113DFunction{"p114_pair",[NC_Binding{0,"a",N_W64{}},NC_Binding{1,"b",N_W64{}}],2,False{},
    [P113DResult{[N111Local{"b"},N111Local{"a"}]}]}


def p114st_caller() -> P113DFunction:
  P113DFunction{"p114_caller",[NC_Binding{0,"a",N_W64{}}],1,False{},
    [P113DCall{["first","second"],"p114_pair",[N111Local{"a"},N111Const{9,0}]},
     P113DCall{["answer"],"p114_scalar",[N111Local{"second"}]},
     P113DResult{[N111Local{"answer"}]}]}


def p114st_branch() -> P113DFunction:
  P113DFunction{"p114_branch",[NC_Binding{0,"a",N_W64{}}],1,False{},
    [P113DScalar{N111Bin{"is_zero",N111U64{},"eq",N111Local{"a"},N111Const{0,0}}},
     P113DIf{N111Local{"is_zero"},[P113DResult{[N111Const{1,0}]}],
       [P113DCall{["answer"],"p114_scalar",[N111Local{"a"}]},P113DResult{[N111Local{"answer"}]}]}]}


def p114st_loop() -> P113DFunction:
  P113DFunction{"p114_loop",[NC_Binding{0,"a",N_W64{}}],1,False{},
    [P113DScalar{N111Bin{"is_zero",N111U64{},"eq",N111Local{"a"},N111Const{0,0}}},
     P113DIf{N111Local{"is_zero"},[P113DResult{[N111Const{0,0}]}],
       [P113DScalar{N111Bin{"next",N111U64{},"sub",N111Local{"a"},N111Const{1,0}}},P113DAgain{[N111Local{"next"}]}]}]}


def p114st_public() -> P113DFunction:
  P113DFunction{"main",[],1,True{},[P113DResult{[N111Const{0,0}]}]}


def p114st_functions(which: U32) -> List<&2,P113DFunction>:
  match which:
    case 0: []
    case 1: [p114st_identity()]
    case 2: [p114st_scalar(),p114st_pair(),p114st_caller()]
    case 3: [p114st_scalar(),p114st_branch()]
    case 4: [p114st_loop()]
    case _: [p114st_public()]


def p114st_program(which: U32) -> P113DProgram:
  P113DProgram{p114st_original(),p114st_functions(which)}


def p114st_valid(boundary: P114SBoundary) -> Bool:
  match boundary:
    case P114SBoundary{original,ids,functions,valid}: valid


@unsafe
def p114st_equivalent(+program: P113DProgram) -> Bool:
  +baseline = p113k_optimize(p113i_optimize(program))
  +candidate = p114s_optimize(program)
  String.is_empty(p113d_verify(baseline)) && String.is_empty(p113d_verify(candidate)) &&
    String.eq(p113d_text(baseline),p113d_text(candidate))


@unsafe
def p114st_case(+which: U32, +label: String) -> List<&2,String>:
  +program = p114st_program(which)
  [p114st_row(label ++ "-original",String.is_empty(p113d_verify(program))),
   p114st_row(label ++ "-opened",p114st_valid(p114s_open(program))),
   p114st_row(label ++ "-exact-output",p114st_equivalent(program))]


@unsafe
def p118xs_original(+stmt: N111Stmt) -> N111Stmt:
  match stmt:
    case N111Call{+dest,N111U64{},+symbol,
      Con{N111Arg{N111Ptr{},N111Local{+state}},
      Con{N111Arg{N111U32{},N111CtorId{+cid}},
      Con{N111Arg{N111Ptr{},N111Local{+buffer}},
      Con{N111Arg{N111U32{},N111Const{+count,0}},Nil{}}}}}}:
      nt_choose(N111Stmt,String.eq(symbol,"p111_rt_ctor") && p125v_shape(state,buffer,count),
        u => N111Call{dest,N111U64{},"p125_rt_ctor" ++ U32.show(count),[
          p111_state(),N111Arg{N111U32{},N111CtorId{cid}},N111Arg{N111Ptr{},N111Local{buffer}}]},
        u => p125v_previous_sized(stmt))
    case N111Call{+dest,N111U64{},+symbol,
      Con{N111Arg{N111Ptr{},N111Local{+state}},
      Con{N111Arg{N111U64{},+term},
      Con{N111Arg{N111Ptr{},N111Local{+buffer}},
      Con{N111Arg{N111U32{},N111Const{+count,0}},Nil{}}}}}}:
      nt_choose(N111Stmt,String.eq(symbol,"p111_rt_take") && p125v_shape(state,buffer,count),
        u => N111Call{dest,N111U64{},"p125_rt_take" ++ U32.show(count),[
          p111_state(),p111_word(term),N111Arg{N111Ptr{},N111Local{buffer}}]},
        u => p125v_previous_sized(stmt))
    case _: p125v_previous_sized(stmt)

@unsafe
def p118xs_prefix(args: List<&2,N111Arg>) -> List<&2,N111Arg>:
  match args:
    case Con{a,Con{b,Con{c,Con{d,Con{count,Nil{}}}}}}: [a,b,c,d]
    case _: []


def p118xsc_call(count: U32) -> N111Stmt:
  N111Call{"node",N111U64{},"p118_rt_extend",[p111_state(),p111_word(N111Const{42,0}),
    N111Arg{N111U32{},N111CtorId{"Con"}},p111_scratch(),p111_u32(count)]}


@unsafe
def p118xsc_shape(stmt: N111Stmt, expected: String, arity: U32) -> Bool:
  match stmt:
    case N111Call{name,N111U64{},symbol,+args}:
      String.eq(name,"node") && String.eq(symbol,expected) && U32.is_eq(nt_count(N111Arg,args),arity) &&
        U32.is_eq(p111v_literal(p111v_arg(args,1)),42)
    case _: False{}


@unsafe
def p118xs_controls() -> List<&2,String>:
  [p113ft_row("extend-sized-one",p118xsc_shape(p118q_sized(p118xsc_call(1)),"p118_rt_extend1",4)),
   p113ft_row("extend-sized-three",p118xsc_shape(p118q_sized(p118xsc_call(3)),"p118_rt_extend3",4)),
   p113ft_row("extend-sized-seven",p118xsc_shape(p118q_sized(p118xsc_call(7)),"p118_rt_extend7",4)),
   p113ft_row("extend-sized-zero-fallback",p118xsc_shape(p118q_sized(p118xsc_call(0)),"p118_rt_extend",5)),
   p113ft_row("extend-sized-eight-fallback",p118xsc_shape(p118q_sized(p118xsc_call(8)),"p118_rt_extend",5))]


@unsafe
def p118nsc_segments(+n: U32, reversed: List<&2,N111Segment>) -> List<&2,N111Segment>:
  match n:
    case 0: reversed
    case _: p118nsc_segments(U32.sub(n,1),Con{N111Segment{"p118_segment_" ++ U32.show(n),0,1,0,0,[N111Return{N111Const{0,0}}]},reversed})


@unsafe
def p118nsc_functions(+n: U32, reversed: List<&2,P113DFunction>) -> List<&2,P113DFunction>:
  match n:
    case 0: reversed
    case _: p118nsc_functions(U32.sub(n,1),Con{P113DFunction{"p118_function_" ++ U32.show(n),[],1,False{},[P113DResult{[N111Const{0,0}]}]},reversed})


@unsafe
def p118nsc_names(+n: U32, reversed: List<&2,String>) -> List<&2,String>:
  match n:
    case 0: reversed
    case _: p118nsc_names(U32.sub(n,1),Con{"probe",reversed})


@unsafe
def p118nsc_scalars(+n: U32, reversed: List<&2,N111Stmt>) -> List<&2,N111Stmt>:
  match n:
    case 0: reversed
    case _: p118nsc_scalars(U32.sub(n,1),Con{N111Set{"value",N111U64{},N111Const{n,0}},reversed})


@unsafe
def p118nsc_order(functions: List<&2,P113DFunction>, +expected: U32, +valid: Bool) -> Bool:
  match functions:
    case Nil{}: valid
    case Con{P113DFunction{name,params,result,public,body},rest}:
      p118nsc_order(rest,U32.inc(expected),valid && String.eq(name,"p118_function_" ++ U32.show(expected)))


@unsafe
def p118nsc_count(functions: List<&2,P113DFunction>, count: U32) -> U32:
  match functions:
    case Nil{}: count
    case Con{head,rest}: p118nsc_count(rest,U32.inc(count))


@unsafe
def p118nsc_projected(workers: P118BWorkers, +count: U32) -> Bool:
  match workers:
    case P118BWorkers{+functions,+error}:
      String.is_empty(error) && U32.is_eq(p118nsc_count(functions,0),count) && p118nsc_order(functions,1,True{})


def p118nsc_definition(name: String, value: KTerm, trusted: Bool) -> KDef:
  KDef{name,"Def",0,0,{KTerm{"Typ", "", 0, 0, Nil{}, Nil{}, 0, 0} : KTerm},value,[],trusted,False{}}


@unsafe
def p118nsc_permission(+book: List<&2,KDef>, +names: List<&2,String>) -> Bool:
  U32.is_eq(Bool.to_u32(no_effect_definitions(book,names)),
    Bool.to_u32(p118ns_effect_definitions(True{},book,names)))

@unsafe
def p125pc_equation(+empty: String, +link: String, head: U32, tail: U32, suffix: U32, base: U32, target: String) -> KDef:
  +call = kt("App","",0,0,[kt("App","",0,0,[kt("Ref",target,0,1,[]),var("tail",tail)]),var("suffix",suffix)])
  +step = k_lam("head",1,1,[k_lam("tail",2,1,[k_lam("suffix",3,1,[kt("Ctr",link,0,1,[var("head",head),call])],0,0,False{})],0,0,False{})],0,0,False{})
  KDef{"join","Def",2,0,{KTerm{"Absent", "", 0, 0, Nil{}, Nil{}, 0, 0} : KTerm},kt("Mat",empty,0,1,[
    k_lam("suffix",4,1,[var("suffix",base)],0,0,False{}),
    kt("Mat",link,0,1,[step,{KTerm{"Efq", "", 0, 0, Nil{}, Nil{}, 0, 0} : KTerm}])]),[],False{},False{}}


@unsafe
def p125pc_forward(dest: String, returned: String) -> List<&2,P113DStmt>:
  [P113DCall{[dest],"private",[N111Local{"left"},N111Local{"right"},N111Const{0,0},N111Const{0,0}]},
   P113DResult{[N111Local{returned}]}]


@unsafe
def p125pc_controls() -> List<&2,String>:
  [p113ft_row("exact-append-equations",p125p_equations(p125pc_equation("End","Link",1,2,3,4,"join"),"End","Link")),
   p113ft_row("constructor-name-independent",p125p_equations(p125pc_equation("Empty","Pair",1,2,3,4,"join"),"Empty","Pair")),
   p113ft_row("changed-head-refused",Bool.not(p125p_equations(p125pc_equation("End","Link",2,2,3,4,"join"),"End","Link"))),
   p113ft_row("non-tail-recursion-refused",Bool.not(p125p_equations(p125pc_equation("End","Link",1,1,3,4,"join"),"End","Link"))),
   p113ft_row("changed-suffix-refused",Bool.not(p125p_equations(p125pc_equation("End","Link",1,2,2,4,"join"),"End","Link"))),
   p113ft_row("changed-base-refused",Bool.not(p125p_equations(p125pc_equation("End","Link",1,2,3,1,"join"),"End","Link"))),
   p113ft_row("different-callee-refused",Bool.not(p125p_equations(p125pc_equation("End","Link",1,2,3,4,"other"),"End","Link"))),
   p113ft_row("wrong-constructor-refused",Bool.not(p125p_equations(p125pc_equation("End","Other",1,2,3,4,"join"),"End","Link"))),
   p113ft_row("forwarding-factory",p125p_forward(p125pc_forward("old_result","old_result"))),
   p113ft_row("different-return-refused",Bool.not(p125p_forward(p125pc_forward("old_result","other")))),
   p113ft_row("namespace-collision-refused",Bool.not(p125p_forward(p125pc_forward("p125_concat_out","p125_concat_out")))),
   p113ft_row("extra-effect-refused",Bool.not(p125p_forward(Con{P113DScalar{N111Call{"effect",N111U64{},"foreign",[]}},p125pc_forward("old_result","old_result")})))]


@unsafe
def p125ic_copy(code: P111ValueCode, lo: U32, hi: U32) -> Bool:
  match code:
    case P111ValueCode{Con{N111Set{dest,N111U64{},N111Const{a,b}},Nil{}},N111Local{result},error}:
      String.eq(dest,"value") && String.eq(result,"value") && String.is_empty(error) && U32.is_eq(a,lo) && U32.is_eq(b,hi)
    case _: False{}


@unsafe
def p125ic_has_call(body: List<&2,N111Stmt>) -> Bool:
  match body:
    case Nil{}: False{}
    case Con{N111Call{dest,typ,symbol,args},rest}: String.eq(symbol,"p111_rt_op")
    case Con{head,rest}: p125ic_has_call(rest)


@unsafe
def p125ic_fallback(code: P111ValueCode) -> Bool:
  match code:
    case P111ValueCode{body,value,error}: p125ic_has_call(body)


@unsafe
def p125ic_controls() -> List<&2,String>:
  [p113ft_row("u32-to-nat-zero",p125ic_copy(p112_intrinsic_fallback("u32_to_nat",[N111Const{0,0}]),0,0)),
   p113ft_row("u32-to-nat-max",p125ic_copy(p112_intrinsic_fallback("u32_to_nat",[N111Const{4294967295,0}]),4294967295,0)),
   p113ft_row("full-u64-identity",p125ic_copy(p112_intrinsic_fallback("u32_to_nat",[N111Const{17,4294967295}]),17,4294967295)),
   p113ft_row("f32-bits-payload",p125ic_copy(p112_intrinsic_fallback("f32_bits",[N111Const{2143289345,0}]),2143289345,0)),
   p113ft_row("f32-bits-signed-zero",p125ic_copy(p112_intrinsic_fallback("f32_bits",[N111Const{2147483648,0}]),2147483648,0)),
   p113ft_row("u32-from-nat-not-identity",p125ic_fallback(p112_intrinsic_fallback("u32_from_nat",[N111Const{0,1}]))),
   p113ft_row("numeric-conversion-not-identity",p125ic_fallback(p112_intrinsic_fallback("u32_to_f32",[N111Const{1,0}]))),
   p113ft_row("missing-argument-original-path",p125ic_fallback(p112_intrinsic_fallback("u32_to_nat",[]))),
   p113ft_row("extra-argument-original-path",p125ic_fallback(p112_intrinsic_fallback("f32_bits",[N111Const{0,0},N111Const{1,0}])))]


@unsafe
def p125vc_call(symbol: String, second: N111Arg, count: U32, high: U32, state: String, buffer: String) -> N111Stmt:
  N111Call{"answer",N111U64{},symbol,[N111Arg{N111Ptr{},N111Local{state}},second,
    N111Arg{N111Ptr{},N111Local{buffer}},N111Arg{N111U32{},N111Const{count,high}}]}


@unsafe
def p125vc_shape(stmt: N111Stmt, expected: String) -> Bool:
  match stmt:
    case N111Call{dest,N111U64{},symbol,args}:
      String.eq(dest,"answer") && String.eq(symbol,expected) && U32.is_eq(nt_count(N111Arg,args),3)
    case _: False{}


@unsafe
def p125vc_refused(stmt: N111Stmt) -> Bool:
  match stmt:
    case N111Call{dest,typ,symbol,args}: Bool.not(String.starts_with(symbol,"p125_rt_"))
    case _: True{}


@unsafe
def p125vc_controls() -> List<&2,String>:
  [p113ft_row("ctor1",p125vc_shape(p118xs_original(p125vc_call("p111_rt_ctor",N111Arg{N111U32{},N111CtorId{"One"}},1,0,"state","scratch")),"p125_rt_ctor1")),
   p113ft_row("ctor4",p125vc_shape(p118xs_original(p125vc_call("p111_rt_ctor",N111Arg{N111U32{},N111CtorId{"Four"}},4,0,"state","scratch")),"p125_rt_ctor4")),
   p113ft_row("take1",p125vc_shape(p118xs_original(p125vc_call("p111_rt_take",p111_word(N111Local{"owner"}),1,0,"state","scratch")),"p125_rt_take1")),
   p113ft_row("take4",p125vc_shape(p118xs_original(p125vc_call("p111_rt_take",p111_word(N111Local{"owner"}),4,0,"state","scratch")),"p125_rt_take4")),
   p113ft_row("zero-count-fallback",p125vc_refused(p118xs_original(p125vc_call("p111_rt_ctor",N111Arg{N111U32{},N111CtorId{"Zero"}},0,0,"state","scratch")))),
   p113ft_row("large-count-fallback",p125vc_refused(p118xs_original(p125vc_call("p111_rt_take",p111_word(N111Local{"owner"}),5,0,"state","scratch")))),
   p113ft_row("high-count-fallback",p125vc_refused(p118xs_original(p125vc_call("p111_rt_take",p111_word(N111Local{"owner"}),1,1,"state","scratch")))),
   p113ft_row("wrong-state-fallback",p125vc_refused(p118xs_original(p125vc_call("p111_rt_take",p111_word(N111Local{"owner"}),1,0,"other","scratch")))),
   p113ft_row("state-as-buffer-fallback",p125vc_refused(p118xs_original(p125vc_call("p111_rt_take",p111_word(N111Local{"owner"}),1,0,"state","state")))),
   p113ft_row("non-CID-ctor-fallback",p125vc_refused(p118xs_original(p125vc_call("p111_rt_ctor",p111_u32(7),1,0,"state","scratch")))),
   p113ft_row("different-import-fallback",p125vc_refused(p118xs_original(p125vc_call("p111_rt_op",p111_u32(24),1,0,"state","scratch"))))]


@unsafe
def p126rc_tail(+target: String, +count: U32) -> List<&2,N111Stmt>:
  [N111Store{N111U64{},N111Local{"scratch"},0,N111Local{"x"}},
   N111Call{"reply",N111U64{},"p111_rt_jump",[p111_state(),N111Arg{N111U32{},N111FuncId{target}},p111_scratch(),p111_u32(count)]},
   N111Return{N111Local{"reply"}}]


@unsafe
def p126rc_shift() -> N111Stmt:
  N111If{N111Local{"small"},[
    N111Bin{"shift",N111U64{},"shl",N111Const{1,0},N111Local{"n"}},
    N111Bin{"shift",N111U64{},"and",N111Local{"shift"},N111Const{4294967295,0}}],[
    N111Set{"shift",N111U64{},N111Const{0,0}}]}


@unsafe
def p126rc_row(+label: String, +body: List<&2,N111Stmt>, +old_expected: Bool, +new_expected: Bool) -> String:
  +old = p114r_arguments(body,"owner",1)
  +new = p126r_arguments(body,"owner",1)
  nt_choose(String,U32.is_eq(Bool.to_u32(old),Bool.to_u32(old_expected)) && U32.is_eq(Bool.to_u32(new),Bool.to_u32(new_expected)),
    u => label ++ ":pass",u => label ++ ":FAIL")


@unsafe
def p126rc_branch(stmt: N111Stmt) -> List<&2,N111Stmt>:
  Con{N111If{N111Local{"condition"},[stmt],[]},p126rc_tail("owner",1)}


@unsafe
def p126rc_preserved() -> String:
  +body : List<&2,N111Stmt> = Con{p126rc_shift(),p126rc_tail("owner",1)}
  +kept = p114r_without_transition(body)
  nt_choose(String,U32.is_eq(nt_count(N111Stmt,kept),2),u => "branch-and-stores-retained:pass",u => "branch-and-stores-retained:FAIL")


@unsafe
def p126rc_controls() -> List<&2,String>:
  [p126rc_row("old-tail",p126rc_tail("owner",1),True{},True{}),
   p126rc_row("old-scalar-prefix",Con{N111Set{"x",N111U64{},N111Const{3,0}},p126rc_tail("owner",1)},True{},True{}),
   p126rc_row("shift-diamond",Con{p126rc_shift(),p126rc_tail("owner",1)},False{},True{}),
   p126rc_row("nested-diamond",p126rc_branch(p126rc_shift()),False{},True{}),
   p126rc_row("wrong-target",Con{p126rc_shift(),p126rc_tail("other",1)},False{},False{}),
   p126rc_row("wrong-arity",Con{p126rc_shift(),p126rc_tail("owner",2)},False{},False{}),
   p126rc_row("branch-return",p126rc_branch(N111Return{N111Const{0,0}}),False{},False{}),
   p126rc_row("unknown-call",p126rc_branch(N111Call{"x",N111U64{},"external",[]}),False{},False{}),
   p126rc_row("bank-read",p126rc_branch(N111Call{"x",N111U64{},"p111_rt_reg_get",[p111_state(),p111_u32(0)]}),False{},False{}),
   p126rc_row("frame-change",p126rc_branch(N111Call{"x",N111U64{},"p111_rt_frame",[p111_state(),N111Arg{N111U32{},N111FuncId{"cont"}},p111_scratch(),p111_u32(0)]}),False{},False{}),
   p126rc_row("state-store",p126rc_branch(N111Store{N111U64{},N111Local{"state"},0,N111Const{0,0}}),False{},False{}),
   p126rc_row("pointer-write",p126rc_branch(N111Set{"scratch",N111Ptr{},N111Local{"state"}}),False{},False{}),
   p126rc_preserved()]

@unsafe
def p126lc_call(+name: String, +symbol: String, +count: U32) -> N111Stmt:
  N111Call{name,N111U64{},symbol,[p111_state(),p111_u32(58),p111_scratch(),p111_u32(count)]}


@unsafe
def p126lc_yes(group: P114SOGroup) -> Bool:
  match group:
    case P114SOYes{buffer,name,id,left,right,rest}: True{}
    case P114SONo{}: False{}


@unsafe
def p126lc_row(+label: String, actual: Bool, expected: Bool) -> String:
  nt_choose(String,U32.is_eq(Bool.to_u32(actual),Bool.to_u32(expected)),u => label ++ ":pass",u => label ++ ":FAIL")


@unsafe
def p126lc_group(+name: String, symbol: String, +count: U32, left: N111Value) -> Bool:
  p126lc_yes(p114so_group_call(p126lc_call(name,symbol,count),"scratch",left,N111Const{0,0},count,[]))


@unsafe
def p126lc_float_result() -> Bool:
  +facts = p114fl_result([P114FLFact{"x","%old"},P114FLFact{"other","%kept"}],"x",58,0)
  String.is_empty(p114fl_find(facts,"x")) && String.eq(p114fl_find(facts,"other"),"%kept")


@unsafe
def p126lc_text() -> Bool:
  String.eq(p126l_to_u32("x",0,P114FLOperand{"","%lane"}),
    "%t_2 =w cges %lane, s_0\n%t_3 =w clts %lane, s_4294967296\n%t_4 =w and %t_2, %t_3\njnz %t_4, @b_0, @b_1\n@b_0\n%t_5 =w stoui %lane\n%v_x =l extuw %t_5\njmp @b_2\n@b_1\n%v_x =l copy 0\njmp @b_2\n@b_2\n")


@unsafe
def p126lc_buffers(+extra: List<&2,P113DStmt>) -> Bool:
  +body : List<&2,P113DStmt> = nt_append(P113DStmt,[
    P113DScalar{N111Store{N111U64{},N111Local{"scratch"},0,N111Local{"input"}}},
    P113DScalar{p126lc_call("answer","p111_rt_op",1)}],extra)
  p114so_member(p114so_buffers(body),"scratch")


@unsafe
def p126lc_controls() -> List<&2,String>:
  [p126lc_row("unary58",p126lc_group("x","p111_rt_op",1,N111Local{"input"}),True{}),
   p126lc_row("wrong-arity",p126lc_group("x","p111_rt_op",2,N111Local{"input"}),False{}),
   p126lc_row("wrong-symbol",p126lc_group("x","other",1,N111Local{"input"}),False{}),
   p126lc_row("destination-alias",p126lc_group("scratch","p111_rt_op",1,N111Local{"input"}),False{}),
   p126lc_row("operand-alias",p126lc_group("x","p111_rt_op",1,N111Local{"scratch"}),False{}),
   p126lc_row("result-is-word",p126lc_float_result(),True{}),
   p126lc_row("exact-guarded-conversion",p126lc_text(),True{}),
   p126lc_row("whole-buffer-admitted",p126lc_buffers([P113DResult{[N111Local{"answer"}]}]),True{}),
   p126lc_row("whole-buffer-observed",p126lc_buffers([P113DScalar{N111Load{"raw",N111U64{},N111Local{"scratch"},0}}]),False{})]


@unsafe
def p126ntc_call(+symbol: String, +kind: U32, +kindhi: U32, +count: U32, +counthi: U32, +state: String, +buffer: String, +dest: String, +term: N111Value) -> N111Stmt:
  N111Call{dest,N111U64{},symbol,[N111Arg{N111Ptr{},N111Local{state}},
    N111Arg{N111U32{},N111Const{kind,kindhi}},p111_word(term),
    N111Arg{N111Ptr{},N111Local{buffer}},N111Arg{N111U32{},N111Const{count,counthi}}]}


@unsafe
def p126ntc_valid(+term: N111Value, +dest: String, +buffer: String) -> N111Stmt:
  p126ntc_call("p111_rt_special_take",4,0,1,0,"state",buffer,dest,term)


@unsafe
def p126ntc_changed(value: P114TExpansion) -> Bool:
  match value:
    case P114TExpansion{body,changed}: changed


@unsafe
def p126ntc_order(value: P114TExpansion, +lo: U32, +hi: U32) -> Bool:
  match value:
    case P114TExpansion{Con{N111Bin{temp,N111U64{},op,N111Const{a,b},N111Const{1,0}},
      Con{N111Store{N111U64{},N111Local{buffer},0,N111Local{read}},
      Con{N111Set{dest,N111U64{},N111Const{1,0}},Nil{}}}},True{}}:
        String.eq(temp,"p114t_7_nat_pred") && String.eq(read,temp) && String.eq(op,"sub") &&
          String.eq(buffer,"scratch") && String.eq(dest,"answer") && U32.is_eq(a,lo) && U32.is_eq(b,hi)
    case _: False{}


@unsafe
def p126ntc_word(+lo: U32, +hi: U32) -> Bool:
  p126ntc_order(p126nt_expand(p126ntc_valid(N111Const{lo,hi},"answer","scratch"),7),lo,hi)


@unsafe
def p126ntc_refused(+stmt: N111Stmt) -> Bool:
  Bool.not(p126ntc_changed(p126nt_expand(stmt,7)))


@unsafe
def p126ntc_row(+name: String, +result: Bool) -> String:
  nt_choose(String,result,u => name ++ ":pass",u => name ++ ":FAIL")


@unsafe
def p126bpc_info(+shape: KTerm, +inputs: List<&2,KTerm>) -> KDef:
  KDef{"observe","NQSignature",2,0,shape,kt("NQSig","$product.observe",0,0,inputs),[],False{},False{}}


@unsafe
def p126bpc_params() -> List<&2,NC_Binding>:
  [NC_Binding{1,"a",N_W64{}},NC_Binding{2,"b",N_W64{}}]


@unsafe
def p126bpc_tuple() -> KTerm:
  kt("NQShape","Tuple",2,0,[])


@unsafe
def p126bpc_wrapper() -> KTerm:
  kt("NCtr","Tuple",0,0,[var("",1),var("",3)])


@unsafe
def p126bpc_allowed(+shape: KTerm, +inputs: List<&2,KTerm>, +wrapper: KTerm) -> Bool:
  p126bp_shape(p126bpc_info(shape,inputs),p126bpc_params(),wrapper)


@unsafe
def p126bpc_schema() -> NO_Schema:
  NO_Schema{[var("",1),var("",2)],[0],p126bpc_wrapper(),3,"Bool",[],4,""}


@unsafe
def p126bpc_verify() -> String:
  +reader : P113DFunction = P113DFunction{p118b_read_name("observe"),p126bpc_params(),1,False{},[P113DResult{[N111Const{1,0}]}]}
  p113e_functions(Con{reader,p126bp_flat("observe",p126bpc_params(),p126bpc_schema(),
    p126bpc_info(p126bpc_tuple(),[{KTerm{"Absent", "", 0, 0, Nil{}, Nil{}, 0, 0} : KTerm},{KTerm{"Absent", "", 0, 0, Nil{}, Nil{}, 0, 0} : KTerm}]))},N111Ids{missing(),missing()},missing())


@unsafe
def p126bpc_wrong_result() -> String:
  +reader : P113DFunction = P113DFunction{p118b_read_name("observe"),p126bpc_params(),2,False{},[P113DResult{[N111Const{1,0},N111Const{2,0}]}]}
  p113e_functions(Con{reader,p126bp_flat("observe",p126bpc_params(),p126bpc_schema(),
    p126bpc_info(p126bpc_tuple(),[{KTerm{"Absent", "", 0, 0, Nil{}, Nil{}, 0, 0} : KTerm},{KTerm{"Absent", "", 0, 0, Nil{}, Nil{}, 0, 0} : KTerm}]))},N111Ids{missing(),missing()},missing())


@unsafe
def p126bpc_row(+name: String, +ok: Bool) -> String:
  nt_choose(String,ok,u => name ++ ":pass",u => name ++ ":FAIL")


@unsafe
def p126dpc_tuple() -> KTerm:
  kt("NQShape","Tuple",2,0,[])


@unsafe
def p126dpc_args(+output: String) -> List<&2,N111Arg>:
  [p111_state(),p111_word(N111Local{"a"}),p111_word(N111Local{"b"}),N111Arg{N111Ptr{},N111Local{output}}]


@unsafe
def p126dpc_verified(body: List<&2,P113DStmt>, values: List<&2,N111Value>) -> String:
  p113e_functions([P113DFunction{"$p126.divmod.control",[NC_Binding{1,"a",N_W64{}},NC_Binding{2,"b",N_W64{}}],2,False{},
    nt_append(P113DStmt,body,[P113DResult{values}])}],N111Ids{missing(),missing()},missing())


@unsafe
def p126dpc_code(code: P113PValueCode) -> String:
  match code:
    case P113PValueCode{body,values,+error}:
      nt_choose(String,String.is_empty(error),u => p126dpc_verified(p113d_scalars(body),values),u => error)


@unsafe
def p126dpc_import(+bytes: U32, +output: String, +typ: N111Type) -> String:
  p126dpc_verified([P113DScalar{N111Alloca{"out",bytes,8}},
    P113DScalar{N111Call{"status",typ,"p126_rt_nat_divmod",p126dpc_args(output)}}],
    [N111Local{"a"},N111Local{"b"}])


@unsafe
def p126dpc_row(+name: String, +ok: Bool) -> String:
  nt_choose(String,ok,u => name ++ ":pass",u => name ++ ":FAIL")


@unsafe
def p126dpc_shape(value: KTerm) -> Bool:
  p113p_known(p126dp_value_shape([],value,NC_Scheduler{}))


@unsafe
def p128rfc_reference(book: List<&2,KDef>, +live: List<&2,String>) -> List<&2,KDef>:
  match book:
    case Nil{}: []
    case Con{+d,+rest}:
      kc(List<&2,KDef>,has_name(live,dn(d)),
        u => Con{d,p128rfc_reference(rest,live)},u => p128rfc_reference(rest,live))


@unsafe
def p128rfc_def(+name: String, +id: U32) -> KDef:
  KDef{name,"P128Fixture",id,U32.add(id,17),
    kt_span("Type",name,id,2,[],id,U32.add(id,1)),
    kt_span("Value",name,U32.add(id,3),1,[],U32.add(id,2),U32.add(id,4)),
    [KDef{"child","Ctr",id,0,{KTerm{"Data", "", 0, 0, Nil{}, Nil{}, 0, 0} : KTerm},{KTerm{"Absent", "", 0, 0, Nil{}, Nil{}, 0, 0} : KTerm},[],False{},True{}}],
    U32.is_eq(U32.and(id,1),1),U32.is_eq(U32.and(id,2),2)}


@unsafe
def p128rfc_bool(+a: Bool, +b: Bool) -> Bool:
  (a && b) || (Bool.not(a) && Bool.not(b))


@unsafe
def p128rfc_term(+a: KTerm, +b: KTerm) -> Bool:
  norm_exact(a,b) && U32.is_eq(kb(a),kb(b)) && U32.is_eq(ke(a),ke(b))


@unsafe
def p128rfc_defs(a: List<&2,KDef>, b: List<&2,KDef>) -> Bool:
  match a b:
    case Nil{} Nil{}: True{}
    case Con{+x,xs} Con{+y,ys}:
      String.eq(dn(x),dn(y)) && String.eq(dk(x),dk(y)) &&
      U32.is_eq(da(x),da(y)) && U32.is_eq(dx(x),dx(y)) &&
      p128rfc_term(dt(x),dt(y)) && p128rfc_term(dv(x),dv(y)) &&
      p128rfc_bool(db(x),db(y)) && p128rfc_bool(du(x),du(y)) &&
      p128rfc_defs(dc(x),dc(y)) && p128rfc_defs(xs,ys)
    case Nil{} Con{y,ys}: False{}
    case Con{x,xs} Nil{}: False{}


@unsafe
def p128rfc_equal(+book: List<&2,KDef>, +live: List<&2,String>) -> Bool:
  p128rfc_defs(kr_filter(book,live),p128rfc_reference(book,live))


@unsafe
def p128rfc_range(+left: U32, +key: String) -> List<&2,KDef>:
  kc(List<&2,KDef>,U32.is_eq(left,0),u => [],
    u => Con{p128rfc_def(key,left),p128rfc_range(U32.sub(left,1),key)})


@unsafe
def p128rfc_rows(+left: U32) -> List<&2,KDef>:
  kc(List<&2,KDef>,U32.is_eq(left,0),u => [],
    u => Con{p128rfc_def("name." ++ U32.show(left),left),p128rfc_rows(U32.sub(left,1))})


@unsafe
def p128rfc_names(+left: U32) -> List<&2,String>:
  kc(List<&2,String>,U32.is_eq(left,0),u => [],
    u => Con{"name." ++ U32.show(left),p128rfc_names(U32.sub(left,1))})


@unsafe
def p128rfc_row(+label: String, good: Bool) -> String:
  label ++ kc(String,good,u => ":pass",u => ":FAIL")

def p128rawc_request() -> NR_Request:
  NR_Request{[],[],[],[],[],None{}}


def p128rawc_original() -> P113AProgram:
  P113AProgram{P113DProgram{P112StaticProgram{p111_empty(),[]},[]},P113ACertificate{False{},False{}}}


@unsafe
def p128rawc_same(left: P111Emission, right: P111Emission) -> Bool:
  p134e_same(p134e_collect(left),p134e_collect(right))

@unsafe
def p128rawc_error(lowering: P128RawLowering) -> String:
  match lowering:
    case P128RawLowering{P113DLowered{program,error},raw}: error


@unsafe
def p128rawc_counts(lowering: P128RawLowering, +expected_raw: U32, +expected_functions: U32) -> Bool:
  match lowering:
    case P128RawLowering{P113DLowered{P113DProgram{original,functions},error},raw}:
      String.is_empty(error) && U32.is_eq(nt_count(P113DCandidate,raw),expected_raw) &&
        U32.is_eq(nt_count(P113DFunction,functions),expected_functions)


@unsafe
def p128rawc_text(functions: List<&2,P113DFunction>) -> String:
  nt_join(p113e_private_chunks(functions,N111Ids{missing(),missing()},[]),"")


@unsafe
def p128rawc_late(+caller: P113DCandidate, +helper: P113DFunction, +expected: P113DFunction) -> Bool:
  String.eq(p128rawc_text(p113d_passes([caller],p113e_signatures([helper],missing()),[helper],32)),
    p128rawc_text([helper,expected]))


@unsafe
def p130mc_word(+value: U32) -> String:
  SCon{Chr{U32.add(65536,U32.and(value,65535))},SCon{Chr{U32.add(65536,U32.div(value,65536))},SNil{}}}


@unsafe
def p130mc_number(read: P88Number, mode: U32, value: U32, tail: String) -> Bool:
  match read:
    case P88Number{P88Cursor{actual_text,actual_mode},actual_value}:
      U32.is_eq(mode,actual_mode) && U32.is_eq(value,actual_value) && String.eq(tail,actual_text)


@unsafe
def p130mc_text(read: P88TextRead, mode: U32, text: String, tail: String) -> Bool:
  match read:
    case P88TextRead{P88Cursor{actual_tail,actual_mode},actual_text}:
      U32.is_eq(mode,actual_mode) && String.eq(text,actual_text) && String.eq(tail,actual_tail)


@unsafe
def p130mc_next(read: P88Number) -> Bool:
  match read:
    case P88Number{cursor,value}: p130mc_number(p88_u32(cursor),0,0,"")


@unsafe
def p130mc_after_text(read: P88TextRead) -> Bool:
  match read:
    case P88TextRead{cursor,value}: p130mc_number(p88_u32(cursor),0,0,"")


@unsafe
def p130mc_error(result: P88Decoded, expected: String) -> Bool:
  match result:
    case P88DecodeError{error}: String.eq(error,expected)
    case other: False{}


@unsafe
def p130mc_row(valid: Bool, name: String) -> String:
  match valid:
    case True{}: name ++ ":pass"
    case False{}: name ++ ":fail"


@unsafe
def p131ic_record(+key: U32, +version: U32) -> KDef:
  KDef{"identity." ++ U32.show(key), "P131Identity", key, version,
    kt("ProbeType", "type", key, version, []),
    kt("ProbeValue", "value", version, key, [atom("nested")]),
    [KDef{"payload", "P131Child", version, key, atom("Type"), atom("Value"), [], False{}, True{}}],
    U32.is_eq(U32.mod(version, 2), 0), U32.is_eq(U32.mod(version, 3), 0)}


@unsafe
def p131ic_hash(+key: U32, +mode: U32) -> U32:
  kc(U32, U32.is_eq(mode, 0), u => index_hash("identity." ++ U32.show(key), 2166136261), u =>
  kc(U32, U32.is_eq(mode, 1), u => 0, u =>
  kc(U32, U32.is_eq(mode, 2), u => 4294967295, u =>
  kc(U32, U32.is_eq(mode, 3), u => U32.mul(key, 2147483648), u =>
  kc(U32, U32.is_eq(mode, 4), u => U32.mul(key, 65536), u =>
  kc(U32, U32.is_eq(mode, 5), u => key, u =>
    U32.add(U32.mul(key, 2654435761), 2246822519)))))))


@unsafe
def p131ic_sequence(+tree: KDef, +seed: U32, +count: U32, +mode: U32, +old: Bool) -> KDef:
  kc(KDef, U32.is_eq(count, 0), u => tree, u =>
    p131ic_sequence_step(tree, seed, count, mode, old, U32.mod(seed, 31)))


@unsafe
def p131ic_sequence_step(+tree: KDef, +seed: U32, +count: U32, +mode: U32,
                        +old: Bool, +key: U32) -> KDef:
  +record = p131ic_record(key, count)
  +hash = p131ic_hash(key, mode)
  +next = kc(KDef, old,
    u => p131i_original_set(tree, record, hash, 32),
    u => p131i_insert(tree, record, hash))
  p131ic_sequence(next, U32.add(U32.mul(seed, 1664525), 1013904223),
    U32.sub(count, 1), mode, old)


@unsafe
def p131ic_case(+seed: U32, +count: U32, +mode: U32, +old: Bool) -> KDef:
  p131ic_sequence(missing(), seed, count, mode, old)


@unsafe
def p131ic_queries(+tree: KDef, +key: U32, +left: U32, +mode: U32) -> List<&2,KDef>:
  kc(List<&2,KDef>, U32.is_eq(left, 0), u => [], u =>
    Con{index_find(tree, "identity." ++ U32.show(key), p131ic_hash(key, mode), 32),
      p131ic_queries(tree, U32.inc(key), U32.sub(left, 1), mode)})


@unsafe
def p131ic_legacy(+tree: KDef) -> KDef:
  match tree:
    case KDef{name, kind, arity, templates, typ, value, ctors, native, unsafe}: tree
    case KIndexLeaf{hash, bucket}:
      KDef{"", "IndexLeaf", hash, 0, atom("Absent"), atom("Absent"), bucket, False{}, False{}}
    case KIndexNode{hash, mask, left, right}:
      KDef{"", "IndexNode", hash, mask, atom("Absent"), atom("Absent"),
        [p131ic_legacy(left), p131ic_legacy(right)], False{}, False{}}


@unsafe
def p131ic_legacy_case(+seed: U32, +count: U32, +mode: U32, +old: Bool) -> KDef:
  +prefix = p131ic_case(seed, 17, mode, True{})
  p131ic_sequence(p131ic_legacy(prefix), U32.add(seed, 91), count, mode, old)

@unsafe
def p131sc_definition_body(+body: KTerm, +args: List<&2,KTerm>, +env: List<&2,NC_Binding>, +n: U32, +count: U32) -> KTerm:
  nt_choose(KTerm, U32.is_gt(nq_layout_remaining([body],33),0) && nbc_closed(body,[]),
    u => nbc_select(nc_compact(body),args,env,n,count),
    u => atom("Absent"))


@unsafe
def p131sc_row(+name: String, pass: Bool) -> String:
  name ++ nt_choose(String,pass,u => ":pass",u => ":FAIL")

# Structural admission controls. These do not replace ordinary independent
# output checking, strictness/failure controls, or native machine inspection.

@unsafe
def p131sc_controls() -> List<&2,String>:
  +word = kt("NWord","0",0,0,[])
  +literal = kl_make("U32",0,"")
  +unit = kt("Ctr","Unit",0,0,[])
  +closed = k_lam("v",1,1,[k_lam("tail",2,1,[
    kt("Mat","LT",1,0,[app(var("",2),unit),
      kt("Mat","EQ",1,0,[var("",1),
        kt("Mat","GT",1,0,[literal,atom("Efq")])])])],0,0,False{})],0,0,False{})
  +args : List<&2,KTerm> = [kl_make("U32",7,""),k_lam("u",8,1,[kl_make("U32",9,"")],0,0,False{}),kt("Ctr","EQ",0,0,[])]
  +expanded = p131sc_definition_body(closed,args,[],100,3)
  [p131sc_row("selector-canonical-zero",nbc_closed(word,[])),
   p131sc_row("selector-canonical-max",nbc_closed(kt("NWord","4294967295",0,0,[]),[])),
   p131sc_row("selector-negative-refused",Bool.not(nbc_closed(kt("NWord","-1",0,0,[]),[]))),
   p131sc_row("selector-overflow-refused",Bool.not(nbc_closed(kt("NWord","4294967296",0,0,[]),[]))),
   p131sc_row("selector-noncanonical-refused",Bool.not(nbc_closed(kt("NWord","00",0,0,[]),[]))),
   p131sc_row("selector-word-child-refused",Bool.not(nbc_closed(kt("NWord","0",0,0,[unit]),[]))),
   p131sc_row("selector-reference-refused",Bool.not(nbc_closed(kt("Ref","arbitrary",0,0,[]),[]))),
   p131sc_row("selector-operation-refused",Bool.not(nbc_closed(kt("NOp","u32_add",0,0,[word,word]),[]))),
   p131sc_row("selector-free-variable-refused",Bool.not(nbc_closed(var("",7),[]))),
   p131sc_row("selector-data-field-refused",Bool.not(nbc_closed(kt("Ctr","Tuple",0,0,[word,word]),[]))),
   p131sc_row("selector-compact-scalar",nbc_closed(nc_compact(literal),[])),
   p131sc_row("selector-mixed-callback-admitted",Bool.not(p98_tag_eq(expanded,"Absent"))),
   p131sc_row("selector-first-actual-still-strict",p98_tag_eq(expanded,"NSeqLet") || p98_tag_eq(expanded,"Let")),
   p131sc_row("selector-fresh-collision-refused",p98_tag_eq(p131sc_definition_body(closed,args,[nc_binding(nc_id(100))],100,3),"Absent"))]

@unsafe
def p131sc_controls_v02() -> List<&2,String>:
  List.append(&2,String,p131sc_controls(),
    [p131sc_row("selector-source-u32-closed",nbc_closed(kl_make("U32",0,""),[])),
     p131sc_row("selector-source-nat-closed",nbc_closed(kl_make("Nat",7,""),[])),
     p131sc_row("selector-source-float-closed",nbc_closed(kl_make("F32",0,""),[])),
     p131sc_row("selector-source-string-refused",Bool.not(nbc_closed(kl_make("String",0,"large strings must never expand here"),[]))),
     p131sc_row("selector-unknown-literal-refused",Bool.not(nbc_closed(kl_make("not-a-scalar-kind",0,""),[])))])

@unsafe
def p134v_list(~A: Data, ~eq: A -> A -> Bool, a: List<&2,A>, b: List<&2,A>) -> Bool:
  match a b:
    case Nil{} Nil{}: True{}
    case Con{x,xs} Con{y,ys}: eq(x,y) && p134v_list(~A,~eq,xs,ys)
    case _ _: False{}

def p134v_bool(a: Bool, b: Bool) -> Bool:
  Bool.not(Bool.xor(a,b))


def p134v_type(a: N111Type, b: N111Type) -> Bool:
  match a b:
    case N111U32{} N111U32{}: True{}
    case N111U64{} N111U64{}: True{}
    case N111Ptr{} N111Ptr{}: True{}
    case _ _: False{}


def p134v_kind(a: N_WordKind, b: N_WordKind) -> Bool:
  match a b:
    case N_W32{} N_W32{}: True{}
    case N_W64{} N_W64{}: True{}
    case N_Box{} N_Box{}: True{}
    case N_Imm64{} N_Imm64{}: True{}
    case _ _: False{}


def p134v_value(a: N111Value, b: N111Value) -> Bool:
  match a b:
    case N111Local{x} N111Local{y}: String.eq(x,y)
    case N111Const{xl,xh} N111Const{yl,yh}: U32.is_eq(xl,yl) && U32.is_eq(xh,yh)
    case N111Symbol{x} N111Symbol{y}: String.eq(x,y)
    case N111FuncId{x} N111FuncId{y}: String.eq(x,y)
    case N111CtorId{x} N111CtorId{y}: String.eq(x,y)
    case _ _: False{}


def p134v_arg(a: N111Arg, b: N111Arg) -> Bool:
  match a b:
    case N111Arg{at,av} N111Arg{bt,bv}: p134v_type(at,bt) && p134v_value(av,bv)


def p134v_binding(a: NC_Binding, b: NC_Binding) -> Bool:
  match a b:
    case NC_Binding{ai,an,ak} NC_Binding{bi,bn,bk}: U32.is_eq(ai,bi) && String.eq(an,bn) && p134v_kind(ak,bk)


@unsafe
def p134v_scalar(a: N111Stmt, b: N111Stmt) -> Bool:
  match a b:
    case N111Set{an,at,av} N111Set{bn,bt,bv}: String.eq(an,bn) && p134v_type(at,bt) && p134v_value(av,bv)
    case N111Bin{an,at,ao,al,ar} N111Bin{bn,bt,bo,bl,br}:
      String.eq(an,bn) && p134v_type(at,bt) && String.eq(ao,bo) && p134v_value(al,bl) && p134v_value(ar,br)
    case N111Call{an,at,as,aa} N111Call{bn,bt,bs,ba}:
      String.eq(an,bn) && p134v_type(at,bt) && String.eq(as,bs) && p134v_list(~N111Arg,~p134v_arg,aa,ba)
    case N111If{ac,ay,an} N111If{bc,by,bn}:
      p134v_value(ac,bc) && p134v_list(~N111Stmt,~p134v_scalar,ay,by) && p134v_list(~N111Stmt,~p134v_scalar,an,bn)
    case N111Return{av} N111Return{bv}: p134v_value(av,bv)
    case N111Load{an,at,ab,ao} N111Load{bn,bt,bb,bo}:
      String.eq(an,bn) && p134v_type(at,bt) && p134v_value(ab,bb) && U32.is_eq(ao,bo)
    case N111Store{at,ab,ao,av} N111Store{bt,bb,bo,bv}:
      p134v_type(at,bt) && p134v_value(ab,bb) && U32.is_eq(ao,bo) && p134v_value(av,bv)
    case N111Offset{an,ab,ax} N111Offset{bn,bb,bx}:
      String.eq(an,bn) && p134v_value(ab,bb) && p134v_value(ax,bx)
    case N111Alloca{an,ab,aa} N111Alloca{bn,bb,ba}: String.eq(an,bn) && U32.is_eq(ab,bb) && U32.is_eq(aa,ba)
    case _ _: False{}

@unsafe
def p134v_stmt(a: P113DStmt, b: P113DStmt) -> Bool:
  match a b:
    case P113DScalar{as} P113DScalar{bs}: p134v_scalar(as,bs)
    case P113DIf{ac,ay,an} P113DIf{bc,by,bn}:
      p134v_value(ac,bc) && p134v_list(~P113DStmt,~p134v_stmt,ay,by) && p134v_list(~P113DStmt,~p134v_stmt,an,bn)
    case P113DCall{ad,at,aa} P113DCall{bd,bt,ba}:
      p134v_list(~String,~String.eq,ad,bd) && String.eq(at,bt) && p134v_list(~N111Value,~p134v_value,aa,ba)
    case P113DResult{av} P113DResult{bv}: p134v_list(~N111Value,~p134v_value,av,bv)
    case P113DAgain{av} P113DAgain{bv}: p134v_list(~N111Value,~p134v_value,av,bv)
    case _ _: False{}

@unsafe
def p134v_header(a: P113DFunction, b: P113DFunction) -> Bool:
  match a b:
    case P113DFunction{an,ap,ar,au,ab} P113DFunction{bn,bp,br,bu,bb}:
      String.eq(an,bn) && p134v_list(~NC_Binding,~p134v_binding,ap,bp) && U32.is_eq(ar,br) && p134v_bool(au,bu)

@unsafe
def p134v_function(a: P113DFunction, b: P113DFunction) -> Bool:
  match a b:
    case P113DFunction{an,ap,ar,au,ab} P113DFunction{bn,bp,br,bu,bb}:
      String.eq(an,bn) && p134v_list(~NC_Binding,~p134v_binding,ap,bp) && U32.is_eq(ar,br) && p134v_bool(au,bu) && p134v_list(~P113DStmt,~p134v_stmt,ab,bb)

@unsafe
def p134v_check(original: List<&2,P113DFunction>, candidate: List<&2,P113DFunction>, +ids: N111Ids, +ready: KDef) -> String:
  match original candidate:
    case Nil{} Nil{}: ""
    case Con{old,olds} Con{+new,news}:
      +error = nt_choose(String,p134v_function(old,new),u => "",u => p147d_function(new,ids,ready))
      nt_choose(String,String.is_empty(error),u => p134v_check(olds,news,ids,p113e_insert(ready,p113e_signature(new))),u => error)
    case _ _: "verification reuse: mismatched function count"


@unsafe
def p134v_commit(+boundary: P114SBoundary, +candidate: List<&2,P113DFunction>) -> P114SBoundary:
  match boundary:
    case P114SBoundary{+original,+ids,+functions,+valid}:
      nt_choose(P114SBoundary,valid,
        u => nt_choose(P114SBoundary,p134v_list(~P113DFunction,~p134v_header,functions,candidate),
          v => nt_choose(P114SBoundary,String.is_empty(p134v_check(functions,candidate,ids,missing())),
            w => P114SBoundary{original,ids,candidate,True{}},w => boundary),
          v => p114s_commit(boundary,candidate)),u => boundary)

@unsafe
def p134v_boundary_same(a: P114SBoundary, b: P114SBoundary) -> Bool:
  match a b:
    case P114SBoundary{ao,ai,af,av} P114SBoundary{bo,bi,bf,bv}:
      p134v_bool(av,bv) && p134v_list(~P113DFunction,~p134v_function,af,bf)

@unsafe
def p134v_control(+original: P113DProgram, +candidate: List<&2,P113DFunction>) -> Bool:
  +boundary = p114s_open(original)
  p134v_boundary_same(p114s_commit(boundary,candidate),p134v_commit(boundary,candidate))

@unsafe
def p134v_controls() -> List<&2,String>:
  +identity = p114st_identity()
  +bad : P113DFunction = P113DFunction{"p114_identity",[NC_Binding{0,"a",N_W64{}}],1,False{},[P113DResult{[N111Local{"undefined"}]}]}
  +changed : P113DFunction = P113DFunction{"p114_identity",[NC_Binding{0,"a",N_W64{}}],1,False{},[P113DResult{[N111Const{9,0}]}]}
  +arity : P113DFunction = P113DFunction{"p114_identity",[],1,False{},[P113DResult{[N111Const{9,0}]}]}
  +scalar_good : P113DFunction = P113DFunction{"p114_scalar",[NC_Binding{0,"a",N_W64{}}],1,False{},[P113DResult{[N111Const{7,0}]}]}
  +scalar_bad : P113DFunction = P113DFunction{"p114_scalar",[NC_Binding{0,"a",N_W64{}}],1,False{},[P113DResult{[N111Local{"undefined"}]}]}
  +published : P113DFunction = P113DFunction{"p114_identity",[NC_Binding{0,"a",N_W64{}}],1,True{},[P113DResult{[N111Local{"a"}]}]}
  +invalid : P113DProgram = P113DProgram{p114st_original(),[bad]}
  [p114st_row("reuse-empty",p134v_control(p114st_program(0),[])),
   p114st_row("reuse-identical",p134v_control(p114st_program(1),[identity])),
   p114st_row("reuse-changed-valid",p134v_control(p114st_program(1),[changed])),
   p114st_row("reuse-changed-invalid",p134v_control(p114st_program(1),[bad])),
   p114st_row("reuse-header-fallback",p134v_control(p114st_program(1),[arity])),
   p114st_row("reuse-length-fallback",p134v_control(p114st_program(1),[])),
   p114st_row("reuse-duplicate-fallback",p134v_control(p114st_program(1),[identity,identity])),
   p114st_row("reuse-invalid-boundary",p134v_control(invalid,[identity])),
   p114st_row("reuse-forward-call-fallback",p134v_control(p114st_program(2),[p114st_caller(),p114st_scalar(),p114st_pair()])),
   p114st_row("reuse-call-context",p134v_control(p114st_program(2),p114st_functions(2))),
   p114st_row("reuse-branch-context",p134v_control(p114st_program(3),p114st_functions(3))),
   p114st_row("reuse-loop-context",p134v_control(p114st_program(4),p114st_functions(4))),
   p114st_row("reuse-public-context",p134v_control(p114st_program(5),p114st_functions(5))),
   p114st_row("reuse-const-high-word",Bool.not(p134v_value(N111Const{1,0},N111Const{1,1}))),
   p114st_row("reuse-local-symbol",Bool.not(p134v_value(N111Local{"x"},N111Symbol{"x"}))),
   p114st_row("reuse-width",Bool.not(p134v_scalar(N111Set{"x",N111U32{},N111Const{0,0}},N111Set{"x",N111U64{},N111Const{0,0}}))),
   p114st_row("reuse-store-offset",Bool.not(p134v_scalar(N111Store{N111U64{},N111Local{"x"},0,N111Const{0,0}},N111Store{N111U64{},N111Local{"x"},8,N111Const{0,0}}))),
   p114st_row("reuse-alloca-alignment",Bool.not(p134v_scalar(N111Alloca{"x",8,8},N111Alloca{"x",8,16}))),
   p114st_row("reuse-terminal-kind",Bool.not(p134v_stmt(P113DResult{[N111Const{0,0}]},P113DAgain{[N111Const{0,0}]}))),
   p114st_row("reuse-callee-body-changed-valid",p134v_control(p114st_program(2),[scalar_good,p114st_pair(),p114st_caller()])),
   p114st_row("reuse-callee-body-changed-invalid",p134v_control(p114st_program(2),[scalar_bad,p114st_pair(),p114st_caller()])),
   p114st_row("reuse-public-change-fallback",p134v_control(p114st_program(1),[published])),
   p114st_row("reuse-runtime-symbol",Bool.not(p134v_scalar(N111Call{"x",N111U64{},"first",[]},N111Call{"x",N111U64{},"second",[]}))),
   p114st_row("reuse-call-arg-type",Bool.not(p134v_scalar(N111Call{"x",N111U64{},"first",[N111Arg{N111U32{},N111Const{0,0}}]},N111Call{"x",N111U64{},"first",[N111Arg{N111U64{},N111Const{0,0}}]}))),
   p114st_row("reuse-call-target",Bool.not(p134v_stmt(P113DCall{["x"],"first",[]},P113DCall{["x"],"second",[]}))),
   p114st_row("reuse-binding-kind",Bool.not(p134v_binding(NC_Binding{0,"a",N_W32{}},NC_Binding{0,"a",N_W64{}})))]


@unsafe
def p140eqc_row(name: String, +a: KDef, +b: KDef, +expected: Bool) -> String:
  p114st_row(name,p134v_bool(p140eq_old_def(a,b),expected) && p134v_bool(p140eq_def(a,b),expected))


def p140eqc_def(name: String, value: U32) -> KDef:
  KDef{name,"Def",0,0,atom("Data"),KLiteral{"U32",value,"",0,0},[],False{},False{}}


def p140eqc_wrap(term: KTerm) -> KDef:
  KDef{"value","Def",0,0,atom("Data"),term,[],False{},False{}}


@unsafe
def p140eqc_book(+left: U32) -> List<&2,KDef>:
  nt_choose(List<&2,KDef>,U32.is_eq(left,0),u => [],
    u => Con{p140eqc_def("entry" ++ U32.show(left),left),p140eqc_book(U32.sub(left,1))})


@unsafe
def p140eqc_controls() -> List<&2,String>:
  +a = p140eqc_def("a",1)
  +b = p140eqc_def("b",2)
  +leaf : KDef = KIndexLeaf{7,[a,b]}
  +right : KDef = KIndexLeaf{9,[p140eqc_def("c",3)]}
  +tree : KDef = KIndexNode{0,8,leaf,right}
  +fake : KDef = KDef{"","IndexLeaf",7,0,atom("Absent"),atom("Absent"),[a,b],True{},False{}}
  +parent : KDef = KDef{"Owner","ADT",0,0,atom("Data"),atom("Absent"),[a,b],False{},False{}}
  +term : KTerm = KTerm{"Var","x",3,2,[],["gone"],10,20}
  +lambda : KTerm = KLambda{"x",3,2,[term],[],10,20,True{}}
  +literal : KTerm = KLiteral{"U32",7,"seven",10,20}
  +built = index_build(p140eqc_book(32))
  [p140eqc_row("eq-empty",missing(),missing(),True{}),
   p140eqc_row("eq-ordinary",a,p140eqc_def("a",1),True{}),
   p140eqc_row("eq-name",a,p140eqc_def("b",1),False{}),
   p140eqc_row("eq-value",a,p140eqc_def("a",2),False{}),
   p140eqc_row("eq-kind",a,KDef{"a","Ctr",0,0,atom("Data"),KLiteral{"U32",1,"",0,0},[],False{},False{}},False{}),
   p140eqc_row("eq-arity",a,KDef{"a","Def",1,0,atom("Data"),KLiteral{"U32",1,"",0,0},[],False{},False{}},False{}),
   p140eqc_row("eq-templates",a,KDef{"a","Def",0,1,atom("Data"),KLiteral{"U32",1,"",0,0},[],False{},False{}},False{}),
   p140eqc_row("eq-native",a,KDef{"a","Def",0,0,atom("Data"),KLiteral{"U32",1,"",0,0},[],True{},False{}},False{}),
   p140eqc_row("eq-unsafe",a,KDef{"a","Def",0,0,atom("Data"),KLiteral{"U32",1,"",0,0},[],False{},True{}},False{}),
   p140eqc_row("eq-type",a,KDef{"a","Def",0,0,atom("Set"),KLiteral{"U32",1,"",0,0},[],False{},False{}},False{}),
   p140eqc_row("eq-leaf",leaf,KIndexLeaf{7,[a,b]},True{}),
   p140eqc_row("eq-leaf-hash",leaf,KIndexLeaf{8,[a,b]},False{}),
   p140eqc_row("eq-collision-order",leaf,KIndexLeaf{7,[b,a]},False{}),
   p140eqc_row("eq-collision-length",leaf,KIndexLeaf{7,[a]},False{}),
   p140eqc_row("eq-collision-body",leaf,KIndexLeaf{7,[a,p140eqc_def("b",3)]},False{}),
   p140eqc_row("eq-index-variant",fake,leaf,False{}),
   p140eqc_row("eq-node",tree,KIndexNode{0,8,leaf,right},True{}),
   p140eqc_row("eq-node-hash",tree,KIndexNode{1,8,leaf,right},False{}),
   p140eqc_row("eq-node-mask",tree,KIndexNode{0,16,leaf,right},False{}),
   p140eqc_row("eq-node-left",tree,KIndexNode{0,8,KIndexLeaf{7,[a]},right},False{}),
   p140eqc_row("eq-node-right",tree,KIndexNode{0,8,leaf,KIndexLeaf{9,[]}},False{}),
   p140eqc_row("eq-node-order",tree,KIndexNode{0,8,right,leaf},False{}),
   p140eqc_row("eq-child-order",parent,KDef{"Owner","ADT",0,0,atom("Data"),atom("Absent"),[b,a],False{},False{}},False{}),
   p140eqc_row("eq-child-length",parent,KDef{"Owner","ADT",0,0,atom("Data"),atom("Absent"),[a],False{},False{}},False{}),
   p140eqc_row("eq-nested-variant",KDef{"Owner","ADT",0,0,atom("Data"),atom("Absent"),[fake],False{},False{}},KDef{"Owner","ADT",0,0,atom("Data"),atom("Absent"),[leaf],False{},False{}},False{}),
   p140eqc_row("eq-term",p140eqc_wrap(term),p140eqc_wrap(term),True{}),
   p140eqc_row("eq-term-begin",p140eqc_wrap(term),p140eqc_wrap(KTerm{"Var","x",3,2,[],["gone"],11,20}),False{}),
   p140eqc_row("eq-term-end",p140eqc_wrap(term),p140eqc_wrap(KTerm{"Var","x",3,2,[],["gone"],10,21}),False{}),
   p140eqc_row("eq-term-removed",p140eqc_wrap(term),p140eqc_wrap(KTerm{"Var","x",3,2,[],[],10,20}),False{}),
   p140eqc_row("eq-lambda",p140eqc_wrap(lambda),p140eqc_wrap(lambda),True{}),
   p140eqc_row("eq-lambda-present",p140eqc_wrap(lambda),p140eqc_wrap(KLambda{"x",3,2,[term],[],10,20,False{}}),False{}),
   p140eqc_row("eq-lambda-variant",p140eqc_wrap(lambda),p140eqc_wrap(KTerm{"Lam","x",3,2,[term],[],10,20}),False{}),
   p140eqc_row("eq-literal",p140eqc_wrap(literal),p140eqc_wrap(literal),True{}),
   p140eqc_row("eq-literal-number",p140eqc_wrap(literal),p140eqc_wrap(KLiteral{"U32",8,"seven",10,20}),False{}),
   p140eqc_row("eq-literal-text",p140eqc_wrap(literal),p140eqc_wrap(KLiteral{"U32",7,"SEVEN",10,20}),False{}),
   p140eqc_row("eq-literal-variant",p140eqc_wrap(literal),p140eqc_wrap(KTerm{"U32","seven",7,0,[],[],10,20}),False{}),
   p140eqc_row("eq-built-index",built,index_build(p140eqc_book(32)),True{}),
   p140eqc_row("eq-built-edited",built,index_set(built,p140eqc_def("entry16",99),index_hash("entry16",2166136261),32),False{}),
   p114st_row("eq-list-identical",p140eq_list([a,b],[a,b])),
   p114st_row("eq-list-order",Bool.not(p140eq_list([a,b],[b,a])))]

@unsafe
def p140gmc_index(a: P112FusionIndex, b: P112FusionIndex) -> Bool:
  match a b:
    case P112FusionEmpty{} P112FusionEmpty{}: True{}
    case P112FusionLeaf{ah,ab} P112FusionLeaf{bh,bb}: U32.is_eq(ah,bh) && p134v_list(~N111Segment,~p140r_segment,ab,bb)
    case P112FusionNode{am,al,ar} P112FusionNode{bm,bl,br}: U32.is_eq(am,bm) && p140gmc_index(al,bl) && p140gmc_index(ar,br)
    case _ _: False{}

@unsafe
def p140gmc_update(+old: List<&2,N111Segment>, +current: List<&2,N111Segment>) -> Bool:
  p140gmc_index(p112f_index(current),p140gm_changed(current,old,current,p112f_index(old),[],0))


@unsafe
def p140gmc_program(segments: List<&2,N111Segment>) -> P111Program:
  P111Program{segments,[],[],[],[],True{}}


@unsafe
def p140gmc_prepared(+program: P111Program, result: P140GPrepared) -> Bool:
  match result:
    case P140GPrepared{cursor,cache,hits,misses}: p140gmc_cursor(P134Raw{program},p140g_prepare(P134Raw{program},cache))


@unsafe
def p140gmc_emit(+old: P111Program, current: P111Program) -> Bool:
  p140gmc_prepared(current,p140g_prepare(P134Raw{old},P140GCache{[]}))


@unsafe
def p140gmc_headers(+old: P111Program, current: P111Program, +expected: Bool) -> Bool:
  p134v_bool(p140gm_headers(old,current),expected)


@unsafe
def p140gmc_leaf(name: String, value: U32) -> N111Segment:
  N111Segment{name,0,1,0,0,[N111Alloca{"scratch",2048,8},
    N111Store{N111U64{},N111Local{"scratch"},0,N111Const{value,0}},
    N111Call{"reply",N111U64{},"p111_rt_return",[N111Arg{N111Ptr{},N111Local{"state"}},N111Arg{N111Ptr{},N111Local{"scratch"}},N111Arg{N111U32{},N111Const{1,0}}]},
    N111Return{N111Local{"reply"}}]}


@unsafe
def p140gmc_cursor(+plan: P134EmissionPlan, prepared: P140GPrepared) -> Bool:
  match prepared:
    case P140GPrepared{cursor,cache,hits,misses}:
      p140o_strings(p134e_collect_cursor(cursor,[],[]),p134e_collect_cursor(p134e_begin(plan),[],[]))

def p140nbc_count(parsed: P140NBJobs) -> U32:
  match parsed:
    case P140NBError{error}: 4294967295
    case P140NBReady{jobs}: nt_count(P140NBJob,jobs)


def p140nbc_outputs(parsed: P140NBJobs) -> Bool:
  match parsed:
    case P140NBError{error}: False{}
    case P140NBReady{+jobs}: p140nb_outputs(jobs,p140nb_inputs(jobs,["/logical","/base","/carrier","/jobs"]),[])

@unsafe
def p140oc_def(+name: String, +value: KTerm) -> KDef:
  KDef{name,"Def",0,0,kt("ADT","U32",0,0,[]),value,[],False{},False{}}


@unsafe
def p140oc_book(+leaf: U32, +unused: U32) -> List<&2,KDef>:
  book_cached([p140oc_def("main",ref("reader")),p140oc_def("reader",ref("leaf")),
    p140oc_def("leaf",kt("Lit","U32",leaf,0,[])),p140oc_def("unused",kt("Lit","U32",unused,0,[]))],40)


@unsafe
def p140oc_analysis(+old: List<&2,KDef>, +current: List<&2,KDef>) -> P140OAnalysis:
  p140o_analyze(old,current,p140o_edges(p140o_plain(old)))


@unsafe
def p140oc_ready(analysis: P140OAnalysis) -> Bool:
  match analysis:
    case P140OAnalysis{ready,dirty,edges,count}: ready


@unsafe
def p140oc_count(analysis: P140OAnalysis, expected: U32) -> Bool:
  match analysis:
    case P140OAnalysis{ready,dirty,edges,count}: ready && U32.is_eq(count,expected)


@unsafe
def p140oc_cycle(+value: U32) -> List<&2,KDef>:
  book_cached([p140oc_def("main",ref("a")),p140oc_def("a",ref("b")),
    p140oc_def("b",kt("App","",0,0,[ref("a"),kt("Lit","U32",value,0,[])])),
    p140oc_def("other",kt("Lit","U32",99,0,[]))],40)


@unsafe
def p140oc_change_edge(+to: String, +leaf: U32) -> List<&2,KDef>:
  book_cached([p140oc_def("main",ref("reader")),p140oc_def("reader",ref(to)),
    p140oc_def("leaf",kt("Lit","U32",leaf,0,[])),p140oc_def("unused",kt("Lit","U32",22,0,[]))],40)


@unsafe
def p140oc_refresh() -> Bool:
  +a = p140oc_change_edge("unused",1)
  +b = p140oc_change_edge("leaf",1)
  +c = p140oc_change_edge("leaf",2)
  p140oc_refresh_step(b,c,p140oc_analysis(a,b))


@unsafe
def p140oc_refresh_step(+b: List<&2,KDef>, +c: List<&2,KDef>, state: P140OAnalysis) -> Bool:
  match state:
    case P140OAnalysis{ready,dirty,edges,count}:
      +next = p140o_analyze(b,c,edges)
      p140oc_count(next,3) && Bool.not(p140o_clean(next,"main")) && p140o_clean(next,"unused")


@unsafe
def p140oc_row(+name: String, ok: Bool) -> String:
  nt_choose(String,ok,u => name ++ ":pass",u => name ++ ":fail")

@unsafe
def p140qc_subset(names: List<&2,String>, +index: KDef) -> Bool:
  match names:
    case Nil{}: True{}
    case Con{name,rest}: p140o_has(index,name) && p140qc_subset(rest,index)


@unsafe
def p140qc_equal(left: P140ODirty, right: P140ODirty) -> Bool:
  match left right:
    case P140ODirty{+a,ac} P140ODirty{+b,bc}:
      U32.is_eq(ac,bc) && p140qc_subset(p140oq_names([a],[]),b) && p140qc_subset(p140oq_names([b],[]),a)


@unsafe
def p140qc_same(+edges: List<&2,P140OEdge>, +initial: P140ODirty) -> Bool:
  p140qc_equal(p140o_fix(edges,initial,U32.inc(nt_count(P140OEdge,edges))),p140oq_fix(edges,initial))


@unsafe
def p140qc_refs(+bits: U32) -> List<&2,String>:
  +tail: List<&2,String> = nt_choose(List<&2,String>,U32.is_ne(U32.and(bits,4),0),u => ["c"],u => [])
  +tail: List<&2,String> = nt_choose(List<&2,String>,U32.is_ne(U32.and(bits,2),0),u => Con{"b",tail},u => tail)
  nt_choose(List<&2,String>,U32.is_ne(U32.and(bits,1),0),u => Con{"a",tail},u => tail)


@unsafe
def p140qc_graph(+bits: U32) -> List<&2,P140OEdge>:
  [P140OEdge{"a",p140qc_refs(bits)},P140OEdge{"b",p140qc_refs(U32.shrn(bits,3n))},P140OEdge{"c",p140qc_refs(U32.shrn(bits,6n))}]


@unsafe
def p140qc_seed(names: List<&2,String>, dirty: P140ODirty) -> P140ODirty:
  match names:
    case Nil{}: dirty
    case Con{name,rest}: p140qc_seed(rest,p140o_mark(name,dirty))


@unsafe
def p140qc_initial(+edges: List<&2,P140OEdge>, +bits: U32) -> Bool:
  nt_choose(Bool,U32.is_eq(bits,8),u => True{},u =>
    p140qc_same(edges,p140qc_seed(p140qc_refs(bits),P140ODirty{missing(),0})) && p140qc_initial(edges,U32.inc(bits)))


@unsafe
def p140qc_graphs(+bits: U32) -> Bool:
  nt_choose(Bool,U32.is_eq(bits,512),u => True{},u => p140qc_initial(p140qc_graph(bits),0) && p140qc_graphs(U32.inc(bits)))


@unsafe
def p140qc_case(+edges: List<&2,P140OEdge>, names: List<&2,String>) -> Bool:
  p140qc_same(edges,p140qc_seed(names,P140ODirty{missing(),0}))


@unsafe
def p140qc_no_alias(dirty: P140ODirty) -> Bool:
  match dirty:
    case P140ODirty{+names,count}: U32.is_eq(count,2) && p140o_has(names,"b") && Bool.not(p140o_has(names,"a"))

@unsafe
def p140gc_book(target: String) -> List<&2,KDef>:
  book_cached([
    p140oc_def("main",KLiteral{"U32",0,"",0,0}),
    KDef{"Alias","Def",0,0,atom("Data"),kt("ADT",target,0,0,[]),[],False{},False{}},
    KDef{"Hidden","ADT",0,0,atom("Data"),atom("Absent"),
      [KDef{"Hidden0","Ctr",1,0,kt("All","field",1,1,[ref("Alias"),kt("ADT","Hidden",0,0,[])]),atom("Absent"),[],False{},False{}}],False{},False{}}],40)


@unsafe
def p140gc_preserved(analysis: P140OAnalysis) -> Bool:
  match analysis:
    case P140OAnalysis{ready,+dirty,edges,count}:
      Bool.not(ready) && U32.is_eq(count,2) && p140o_has(dirty,"Alias") && p140o_has(dirty,"Hidden") && Bool.not(p140o_has(dirty,"main"))


@unsafe
def p140gc_controls() -> List<&2,String>:
  +a = p140gc_book("U32")
  +b = p140gc_book("F32")
  +edges = p140o_edges(p140o_plain(a))
  +reverse = p140oq_build(edges)
  +analysis = p140oq_analyze(a,b,edges,reverse)
  [p140oc_row("global-alias-identical-declaration-headers",p140o_headers(p140o_plain(a),p140o_plain(b))),
   p140oc_row("global-alias-dirty-ADT-refuses-core",p140gc_preserved(p140o_analyze(a,b,edges))),
   p140oc_row("global-alias-dirty-ADT-refuses-reverse",p140gc_preserved(analysis)),
   p140oc_row("global-alias-independent-main-misses",Bool.not(p140o_clean(analysis,"main"))),
   p140oc_row("global-alias-fact-refusal-retains-diagnostics",p140gc_preserved(p140oq_fact_analysis(a,b,["main","Alias","Hidden"],reverse,analysis))),
   p140oc_row("global-alias-refusal-refreshes-current-graph",p140qc_equal(
     p140oq_with(p140oq_refresh(edges,reverse,analysis),p140qc_seed(["F32"],P140ODirty{missing(),0})),
     p140o_fix(p140o_edges(p140o_plain(b)),p140qc_seed(["F32"],P140ODirty{missing(),0}),4))),
   p140oc_row("global-numeric-edit-remains-admitted",p140oc_ready(p140oq_analyze(p140oc_book(1,8),p140oc_book(2,8),p140o_edges(p140o_plain(p140oc_book(1,8))),p140oq_build(p140o_edges(p140o_plain(p140oc_book(1,8)))))))]

@unsafe
def p140ec_equal(left: NR_Closure, right: NR_Closure) -> Bool:
  match left right:
    case NR_Closure{a,af} NR_Closure{b,bf}:
      p140o_strings(a,b) && f_fresh_prefix_exact_defs(af,bf)


@unsafe
def p140ec_result(result: P140OEResult) -> NR_Closure:
  match result:
    case P140OEResult{closure,entries,hits,misses}: closure


@unsafe
def p140ec_case(+book: List<&2,KDef>) -> Bool:
  p140ec_after(book,p140oe_apply(book,P140OAnalysis{False{},missing(),[],0},[]))


@unsafe
def p140ec_after(+book: List<&2,KDef>, +cold: P140OEResult) -> Bool:
  match cold:
    case P140OEResult{closure,entries,hits,misses}:
      p140ec_equal(closure,nr_walk(book,["main"],[],[])) &&
        p140ec_equal(p140ec_result(p140oe_apply(book,P140OAnalysis{True{},missing(),[],0},entries)),nr_walk(book,["main"],[],[]))


@unsafe
def p140ec_controls() -> List<&2,String>:
  [p140oc_row("erasure-index-chain-cold-and-warm-exact",p140ec_case(p140oc_book(1,8))),
   p140oc_row("erasure-index-cycle-cold-and-warm-exact",p140ec_case(p140oc_cycle(1))),
   p140oc_row("erasure-index-duplicates-preserve-order",p140ec_case(book_cached([
     p140oc_def("main",kt("App","",0,0,[ref("a"),ref("b"),ref("a")])),p140oc_def("a",ref("b")),p140oc_def("b",KLiteral{"U32",0,"",0,0})],40))),
   p140oc_row("erasure-index-missing-name-matches-original",p140ec_case(book_cached([p140oc_def("main",ref("missing"))],40))),
   p140oc_row("erasure-index-real-hash-collision",p140ec_case(book_cached([
     p140oc_def("main",kt("App","",0,0,[ref("costarring"),ref("liquid")])),p140oc_def("costarring",KLiteral{"U32",0,"",0,0}),p140oc_def("liquid",KLiteral{"U32",1,"",0,0})],40)))]

@unsafe
def p140spc_pair(value: U32) -> KTerm:
  kt("Ctr","Pair",0,0,[kt("NWord",U32.show(value),0,0,[]),kt("NWord","9",0,0,[])])


def p140spc_def(name: String) -> KDef:
  KDef{name,"Def",0,0,atom("Data"),KLiteral{"U32",0,"",0,0},[],False{},False{}}


def p140spc_fact(name: String, body: KTerm) -> KDef:
  KDef{name,"NativeErasedBody",7,11,atom("Absent"),body,[],False{},False{}}


@unsafe
def p140spc_book(a: U32, b: U32, c: KTerm) -> List<&2,KDef>:
  ns_attach_book(book_cached([p140spc_def("a"),p140spc_def("b"),p140spc_def("c")],40),
    [p140spc_fact("a",p140spc_pair(a)),p140spc_fact("b",p140spc_pair(b)),p140spc_fact("c",c)],0,[])


@unsafe
def p140spc_equal(a: P112SPrepared, b: P112SPrepared) -> Bool:
  match a b:
    case P112SPrepared{ab,an,ae} P112SPrepared{bb,bn,be}:
      p140eq_list(ab,bb) && p140or_nodes(an,bn) && String.eq(ae,be)


@unsafe
def p140spc_cache(result: P140SPResult) -> P140SPCache:
  match result:
    case P140SPResult{prepared,cache,stats}: cache


@unsafe
def p140spc_check(+book: List<&2,KDef>, +names: List<&2,String>, +constructors: List<&2,N_Constructor>, previous: P140SPCache, counts: List<&2,U32>) -> Bool:
  p140spc_checked(p112s_prepare(book,names,constructors),p140sp_prepare(book,names,constructors,previous),counts)


@unsafe
def p140spc_checked(fresh: P112SPrepared, candidate: P140SPResult, counts: List<&2,U32>) -> Bool:
  match candidate:
    case P140SPResult{prepared,cache,stats}: p140spc_equal(fresh,prepared) && p134v_list(~U32,~U32.is_eq,stats,counts)

@unsafe
def p140spc_error(result: P140SPResult) -> Bool:
  match result:
    case P140SPResult{P112SPrepared{book,nodes,error},P140SPCache{constructors,blocked,entries},stats}:
      String.eq(error,"static atom present before fresh preparation") && List.is_empty(&2,P140SPEntry,entries)


@unsafe
def p140spc_inactive() -> List<&2,KDef>:
  ns_attach_book(book_cached([
    KDef{"a","Control",0,0,atom("Data"),KLiteral{"U32",0,"",0,0},[],False{},False{}},
    p140spc_def("b"),p140spc_def("c")],40),
    [p140spc_fact("a",p140spc_pair(1)),p140spc_fact("b",p140spc_pair(2)),p140spc_fact("c",p140spc_pair(3))],0,[])


@unsafe
def p140spc_terms(a: KTerm, b: KTerm, c: KTerm) -> List<&2,KDef>:
  ns_attach_book(book_cached([p140spc_def("a"),p140spc_def("b"),p140spc_def("c")],40),
    [p140spc_fact("a",a),p140spc_fact("b",b),p140spc_fact("c",c)],0,[])


@unsafe
def p140spc_words(a: U32, b: U32, c: U32) -> List<&2,KDef>:
  p140spc_terms(kt("NWord",U32.show(a),0,0,[]),kt("NWord",U32.show(b),0,0,[]),kt("NWord",U32.show(c),0,0,[]))


@unsafe
def p140spc_preserved(state: P112SDefs) -> Bool:
  match state:
    case P112SDefs{facts,image}: p140eq_list(facts,[p140spc_fact("c",p140spc_pair(3)),p140spc_fact("b",p140spc_pair(4))])


@unsafe
def p140spc_inactive_words() -> List<&2,KDef>:
  ns_attach_book(book_cached([
    KDef{"a","Control",0,0,atom("Data"),KLiteral{"U32",0,"",0,0},[],False{},False{}},
    p140spc_def("b"),p140spc_def("c")],40),
    [p140spc_fact("a",kt("NWord","1",0,0,[])),p140spc_fact("b",kt("NWord","2",0,0,[])),p140spc_fact("c",kt("NWord","3",0,0,[]))],0,[])


@unsafe
def p140spc_controls() -> List<&2,String>:
  +inactive_words = p140spc_inactive_words()
  +inactive_word_cache = p140spc_cache(p140sp_prepare(inactive_words,["a","b","c"],[N_Constructor{"Pair",2,True{}},N_Constructor{"Leaf",1,True{}}],p140sp_empty()))
  +words = p140spc_words(1,2,3)
  +word_cache = p140spc_cache(p140sp_prepare(words,["a","b","c"],[N_Constructor{"Pair",2,True{}},N_Constructor{"Leaf",1,True{}}],p140sp_empty()))
  +word_next = p140spc_cache(p140sp_prepare(p140spc_words(1,4,3),["a","b","c"],[N_Constructor{"Pair",2,True{}},N_Constructor{"Leaf",1,True{}}],word_cache))
  +mixed = p140spc_terms(p140spc_pair(1),kt("NWord","2",0,0,[]),p140spc_pair(3))
  +mixed_cache = p140spc_cache(p140sp_prepare(mixed,["a","b","c"],[N_Constructor{"Pair",2,True{}},N_Constructor{"Leaf",1,True{}}],p140sp_empty()))
  +image : P112SImage = P112SImage{2,[P112SNode{0,"Pair",[P112SRaw{1},P112SRaw{9}]}],missing(),""}
  +names : List<&2,String> = ["a","b","c"]
  +ctors : List<&2,N_Constructor> = [N_Constructor{"Pair",2,True{}},N_Constructor{"Leaf",1,True{}}]
  +book = p140spc_book(1,2,p140spc_pair(3))
  +prior = p140spc_cache(p140sp_prepare(book,names,ctors,p140sp_empty()))
  +last = p140spc_book(1,2,p140spc_pair(4))
  +next = p140spc_cache(p140sp_prepare(last,names,ctors,prior))
  +bad = p140spc_book(1,2,kt("NStatic","Pair",0,0,[]))
  +raw = book_cached([p140spc_def("a"),p140spc_def("b"),p140spc_def("c")],40)
  +inactive = p140spc_inactive()
  +inactive_cache = p140spc_cache(p140sp_prepare(inactive,names,ctors,p140sp_empty()))
  +raw_cache = p140spc_cache(p140sp_prepare(raw,names,ctors,p140sp_empty()))
  [p114st_row("static-convergence-removes-inactive-fact",p140spc_check(inactive_words,names,ctors,word_cache,[2,1,2,0])),
   p114st_row("static-convergence-adds-active-fact",p140spc_check(words,names,ctors,inactive_word_cache,[2,1,2,1])),
   p114st_row("static-convergence-first-word-edit",p140spc_check(p140spc_words(4,2,3),names,ctors,word_cache,[2,1,2,1])),
   p114st_row("static-convergence-middle-word-edit",p140spc_check(p140spc_words(1,4,3),names,ctors,word_cache,[2,1,2,1])),
   p114st_row("static-convergence-two-word-edits",p140spc_check(p140spc_words(4,5,3),names,ctors,word_cache,[1,2,1,2])),
   p114st_row("static-convergence-reverted-word-edit",p140spc_check(words,names,ctors,word_next,[2,1,2,1])),
   p114st_row("static-convergence-retains-current-word",p140spc_check(p140spc_words(1,4,3),names,ctors,word_next,[3,0,3,0])),
   p114st_row("static-convergence-reuses-box-after-word",p140spc_check(p140spc_terms(p140spc_pair(1),kt("NWord","4",0,0,[]),p140spc_pair(3)),names,ctors,mixed_cache,[2,1,2,1])),
   p114st_row("static-convergence-global-gate-stays-closed",p140spc_check(p140spc_words(1,4,3),names,[N_Constructor{"Leaf",1,True{}},N_Constructor{"Pair",2,True{}}],word_cache,[0,3,0,3])),
   p114st_row("static-convergence-image-identical",p140sp_image_equal(image,image)),
   p114st_row("static-convergence-image-size",Bool.not(p140sp_image_equal(image,P112SImage{3,[P112SNode{0,"Pair",[P112SRaw{1},P112SRaw{9}]}],missing(),""}))),
   p114st_row("static-convergence-image-node",Bool.not(p140sp_image_equal(image,P112SImage{2,[P112SNode{0,"Pair",[P112SRaw{2},P112SRaw{9}]}],missing(),""}))),
   p114st_row("static-convergence-image-index",Bool.not(p140sp_image_equal(image,P112SImage{2,[P112SNode{0,"Pair",[P112SRaw{1},P112SRaw{9}]}],p140spc_def("different"),""}))),
   p114st_row("static-convergence-image-error",Bool.not(p140sp_image_equal(image,P112SImage{2,[P112SNode{0,"Pair",[P112SRaw{1},P112SRaw{9}]}],missing(),"error"}))),
   p114st_row("static-convergence-preserves-current-fact-prefix",p140spc_preserved(p140sp_restore(P112SDefs{[p140spc_fact("b",p140spc_pair(4))],image},True{},P112SDefs{[p140spc_fact("c",p140spc_pair(3)),p140spc_fact("b",p140spc_pair(2))],image}))),
   p114st_row("static-prefix-active-to-inactive",p140spc_check(inactive,names,ctors,prior,[0,3,0,2])),
   p114st_row("static-prefix-inactive-to-active",p140spc_check(book,names,ctors,inactive_cache,[0,3,0,3])),
   p114st_row("static-prefix-fact-disappeared",p140spc_check(raw,names,ctors,prior,[0,3,0,3])),
   p114st_row("static-prefix-ctor-arity-refuses",p140spc_check(book,names,[N_Constructor{"Pair",1,True{}},N_Constructor{"Leaf",1,True{}}],prior,[0,3,0,3])),
   p114st_row("static-prefix-cold-exact",p140spc_check(book,names,ctors,p140sp_empty(),[0,3,0,3])),
   p114st_row("static-prefix-noop-exact",p140spc_check(book,names,ctors,prior,[3,0,3,0])),
   p114st_row("static-prefix-last-edit-exact",p140spc_check(last,names,ctors,prior,[2,1,2,1])),
   p114st_row("static-prefix-first-edit-rebuilds-suffix",p140spc_check(p140spc_book(5,2,p140spc_pair(3)),names,ctors,prior,[0,3,0,3])),
   p114st_row("static-prefix-middle-edit-rebuilds-suffix",p140spc_check(p140spc_book(1,5,p140spc_pair(3)),names,ctors,prior,[1,2,1,2])),
   p114st_row("static-prefix-suffix-dedup-exact",p140spc_check(p140spc_book(1,2,p140spc_pair(2)),names,ctors,prior,[2,1,2,1])),
   p114st_row("static-prefix-reverted-edit-exact",p140spc_check(book,names,ctors,next,[2,1,2,1])),
   p114st_row("static-prefix-truncated-names-exact",p140spc_check(book,["a","b"],ctors,prior,[2,0,2,0])),
   p114st_row("static-prefix-reordered-names-exact",p140spc_check(book,["b","a","c"],ctors,prior,[0,3,0,3])),
   p114st_row("static-prefix-inserted-inactive-exact",p140spc_check(book,["missing","a","b","c"],ctors,prior,[0,4,0,3])),
   p114st_row("static-prefix-ctor-order-refuses",p140spc_check(book,names,[N_Constructor{"Leaf",1,True{}},N_Constructor{"Pair",2,True{}}],prior,[0,3,0,3])),
   p114st_row("static-prefix-ctor-hot-refuses",p140spc_check(book,names,[N_Constructor{"Pair",2,False{}},N_Constructor{"Leaf",1,True{}}],prior,[0,3,0,3])),
   p114st_row("static-prefix-no-fact-refuses",p140spc_check(raw,names,ctors,raw_cache,[0,3,0,3])),
   p114st_row("static-prefix-stale-exact",p140spc_check(bad,names,ctors,prior,[2,1,2,1])),
   p114st_row("static-prefix-error-not-published",p140spc_error(p140sp_prepare(bad,names,ctors,p140sp_empty()))),
   p114st_row("static-prefix-noncached-book-error-exact",p140spc_check([],names,ctors,prior,[]))]

@unsafe
def p140drc_def(name: String, native: Bool, unsafe: Bool) -> KDef:
  KDef{name,"Def",0,0,atom("Typ"),atom("Typ"),[],native,unsafe}


@unsafe
def p140drc_seed(names: List<&2,String>, seen: KDef) -> KDef:
  match names:
    case Nil{}: seen
    case Con{name,rest}: p140drc_seed(rest,p140dr_mark(seen,name))


@unsafe
def p140drc_names(+book: List<&2,KDef>, +seen: List<&2,String>, expected: List<&2,String>) -> Bool:
  +actual = p140dr_names(book,p140drc_seed(seen,missing()))
  p140o_strings(actual,dr_own_names(book,seen)) && p140o_strings(actual,expected)


@unsafe
def p140drc_reports(a: DR_Report, b: DR_Report) -> Bool:
  match a b:
    case DR_Report{av,an} DR_Report{bv,bn}: String.eq(av,bv) && p140o_strings(an,bn)


@unsafe
def p140drc_report(+book: List<&2,KDef>) -> Bool:
  p140drc_reports(driver_report_data(book),p140dr_report_data(book))

def p140vt_cache(value: P140VChecked) -> P140VCache:
  match value:
    case P140VChecked{cache,ids,static_ok,error,counts}: cache


def p140vt_error(value: P140VChecked) -> String:
  match value:
    case P140VChecked{cache,ids,static_ok,error,counts}: error


def p140vt_counts(value: P140VChecked) -> List<&2,U32>:
  match value:
    case P140VChecked{cache,ids,static_ok,error,counts}: counts


def p140vt_empty(value: P140VCache) -> Bool:
  match value:
    case P140VEmpty{}: True{}
    case P140VCache{program,metadata}: False{}


def p140vt_opened(value: P140VOpened) -> P114SBoundary:
  match value:
    case P140VOpened{boundary,cache,counts}: boundary


def p140vt_array_error(value: P140VArrayChecked) -> String:
  match value:
    case P140VArrayChecked{cache,error,counts}: error


@unsafe
def p140vt_equal(+old: P113DProgram, +now: P113DProgram) -> Bool:
  String.eq(p113e_verify(now),p140vt_error(p140v_check(now,p140vt_cache(p140v_check(old,P140VEmpty{})))))


@unsafe
def p140vt_open_equal(+old: P113DProgram, +now: P113DProgram) -> Bool:
  p134v_boundary_same(p114s_open(now),p140vt_opened(p140v_open(now,p140vt_cache(p140v_check(old,P140VEmpty{})))))


@unsafe
def p140vt_count_equal(+old: P113DProgram, +now: P113DProgram, counts: List<&2,U32>) -> Bool:
  p134v_list(~U32,~U32.is_eq,counts,p140vt_counts(p140v_check(now,p140vt_cache(p140v_check(old,P140VEmpty{})))))

def p140vt_program(body: List<&2,N111Stmt>, functions: List<&2,P113DFunction>) -> P113DProgram:
  P113DProgram{P112StaticProgram{P111Program{[N111Segment{"main",0,1,0,0,body}],[],[0],[],[],True{}},[]},functions}


def p140vt_bad_direct() -> P113DFunction:
  P113DFunction{"p114_identity",[NC_Binding{0,"a",N_W64{}}],1,False{},[P113DResult{[N111Local{"undefined"}]}]}


def p140vt_changed_direct() -> P113DFunction:
  P113DFunction{"p114_identity",[NC_Binding{0,"a",N_W64{}}],1,False{},[P113DResult{[N111Const{9,0}]}]}


@unsafe
def p140vt_controls() -> List<&2,String>:
  +plain = p114st_program(1)
  +changed = p140vt_program([N111Return{N111Const{9,0}}],[p114st_identity()])
  +badraw = p140vt_program([N111Return{N111Local{"undefined"}}],[p114st_identity()])
  +badfn = p140vt_program([N111Return{N111Const{0,0}}],[p140vt_bad_direct()])
  +newfn = p140vt_program([N111Return{N111Const{0,0}}],[p140vt_changed_direct()])
  +badboth = p140vt_program([N111Return{N111Local{"raw_missing"}}],[p140vt_bad_direct()])
  +badmain : P113DProgram = P113DProgram{P112StaticProgram{P111Program{[N111Segment{"main",1,1,0,0,[N111Return{N111Const{0,0}}]}],[],[],[],[],True{}},[]},[p114st_identity()]}
  +dupraw : P113DProgram = P113DProgram{P112StaticProgram{P111Program{[N111Segment{"main",0,1,0,0,[N111Return{N111Const{0,0}}]},N111Segment{"main",0,1,0,0,[N111Return{N111Const{0,0}}]}],[],[],[],[],True{}},[]},[]}
  +dupctor : P113DProgram = P113DProgram{P112StaticProgram{P111Program{[N111Segment{"main",0,1,0,0,[N111Return{N111Const{0,0}}]}],[N_Constructor{"Dup",0,True{}},N_Constructor{"Dup",0,True{}}],[],[],[],True{}},[]},[]}
  +badimage : P113DProgram = P113DProgram{P112StaticProgram{P111Program{[N111Segment{"main",0,1,0,0,[N111Return{N111Const{0,0}}]}],[],[],[],[],True{}},[P112SNode{0,"missing",[]}]},[p114st_identity()]}
  +arity : P113DFunction = P113DFunction{"p114_scalar",[],1,False{},[P113DResult{[N111Const{7,0}]}]}
  +callee : P113DFunction = P113DFunction{"p114_scalar",[NC_Binding{0,"a",N_W64{}}],1,False{},[P113DResult{[N111Const{7,0}]}]}
  +forward : P113DProgram = P113DProgram{p114st_original(),[p114st_caller(),p114st_pair(),p114st_scalar()]}
  +public : P113DProgram = P113DProgram{p114st_original(),[P113DFunction{"p114_identity",[NC_Binding{0,"a",N_W64{}}],1,True{},[P113DResult{[N111Local{"a"}]}]}]}
  +array : P113AProgram = P113AProgram{changed,P113ACertificate{False{},False{}}}
  [p114st_row("v-cold-original",p140vt_equal(p114st_program(0),plain)),
   p114st_row("v-identical",p140vt_equal(plain,plain)),
   p114st_row("v-count-identical",p140vt_count_equal(plain,plain,[1,0,1,0])),
   p114st_row("v-valid-raw-edit",p140vt_equal(plain,changed)),
   p114st_row("v-count-raw-edit",p140vt_count_equal(plain,changed,[0,1,1,0])),
   p114st_row("v-invalid-raw-edit",p140vt_equal(plain,badraw)),
   p114st_row("v-valid-direct-edit",p140vt_equal(plain,newfn)),
   p114st_row("v-count-direct-edit",p140vt_count_equal(plain,newfn,[1,0,0,1])),
   p114st_row("v-invalid-direct-edit",p140vt_equal(plain,badfn)),
   p114st_row("v-first-error",p140vt_equal(plain,badboth)),
   p114st_row("v-main-header",p140vt_equal(plain,badmain)),
   p114st_row("v-duplicate-raw",p140vt_equal(plain,dupraw)),
   p114st_row("v-duplicate-constructor",p140vt_equal(plain,dupctor)),
   p114st_row("v-static-image-rechecked",p140vt_equal(plain,badimage)),
   p114st_row("v-callee-body-edit",p140vt_equal(p114st_program(2),P113DProgram{p114st_original(),[callee,p114st_pair(),p114st_caller()]})),
   p114st_row("v-callee-header-edit",p140vt_equal(p114st_program(2),P113DProgram{p114st_original(),[arity,p114st_pair(),p114st_caller()]})),
   p114st_row("v-forward-order",p140vt_equal(p114st_program(2),forward)),
   p114st_row("v-public-flag",p140vt_equal(plain,public)),
   p114st_row("v-invalid-cache-not-published",p140vt_empty(p140vt_cache(p140v_check(badfn,P140VEmpty{})))),
   p114st_row("v-invalid-prior-recomputed",p140vt_equal(badfn,plain)),
   p114st_row("v-open-valid",p140vt_open_equal(plain,changed)),
   p114st_row("v-open-invalid-raw",p140vt_open_equal(plain,badraw)),
   p114st_row("v-open-invalid-direct",p140vt_open_equal(plain,badfn)),
   p114st_row("v-array-wrapper",String.eq(p113a_verify(array),p140vt_array_error(p140v_array(array,p140vt_cache(p140v_check(plain,P140VEmpty{})))))),
   p114st_row("v-constant-highword",Bool.not(p140v_segment(N111Segment{"main",0,1,0,0,[N111Return{N111Const{1,0}}]},N111Segment{"main",0,1,0,0,[N111Return{N111Const{1,1}}]})))]

def p140tc_values() -> List<&2,N111Value>:
  [N111Local{"x"},N111Local{"y"},N111Const{0,0},N111Const{1,0},N111Const{0,1},N111Symbol{"x"},N111FuncId{"x"},N111CtorId{"x"}]


def p140tc_args() -> List<&2,N111Arg>:
  [N111Arg{N111U32{},N111Local{"x"}},N111Arg{N111U64{},N111Local{"x"}},N111Arg{N111Ptr{},N111Symbol{"x"}},N111Arg{N111U32{},N111Const{7,0}}]


def p140tc_bindings() -> List<&2,NC_Binding>:
  [NC_Binding{0,"a",N_W32{}},NC_Binding{0,"a",N_W64{}},NC_Binding{0,"a",N_Box{}},NC_Binding{0,"a",N_Imm64{}},NC_Binding{1,"a",N_W32{}},NC_Binding{0,"b",N_W32{}}]


def p140tc_scalars() -> List<&2,N111Stmt>:
  [N111Set{"x",N111U64{},N111Const{0,0}},
   N111Bin{"x",N111U32{},"eq",N111Local{"a"},N111Const{1,0}},
   N111Call{"x",N111U64{},"helper",p140tc_args()},
   N111If{N111Local{"c"},[N111Return{N111Const{1,0}}],[N111Return{N111Const{0,0}}]},
   N111Return{N111Const{0,0}},N111Load{"x",N111U64{},N111Local{"p"},8},
   N111Store{N111U64{},N111Local{"p"},8,N111Local{"x"}},
   N111Offset{"x",N111Local{"p"},N111Const{8,0}},N111Alloca{"p",16,8},
   N111If{N111Local{"c"},[N111If{N111Local{"d"},[N111Return{N111Const{1,0}}],[]}],[]},
   N111If{N111Local{"c"},[N111If{N111Local{"d"},[N111Return{N111Const{2,0}}],[]}],[]}]


def p140tc_stmts() -> List<&2,P113DStmt>:
  [P113DScalar{N111Return{N111Const{0,0}}},
   P113DIf{N111Local{"c"},[P113DResult{[N111Const{1,0}]}],[P113DResult{[N111Const{0,0}]}]},
   P113DCall{["x","y"],"helper",p140tc_values()},
   P113DResult{[N111Const{0,0}]},P113DAgain{[N111Local{"x"}]},
   P113DIf{N111Local{"c"},[P113DIf{N111Local{"d"},[P113DResult{[N111Const{1,0}]}],[]}],[]},
   P113DIf{N111Local{"c"},[P113DIf{N111Local{"d"},[P113DResult{[N111Const{2,0}]}],[]}],[]}]


def p140tc_functions() -> List<&2,P113DFunction>:
  [P113DFunction{"f",p140tc_bindings(),1,False{},p140tc_stmts()},
   P113DFunction{"f",p140tc_bindings(),1,True{},p140tc_stmts()},
   P113DFunction{"g",p140tc_bindings(),1,False{},p140tc_stmts()},
   P113DFunction{"f",p140tc_bindings(),2,False{},p140tc_stmts()},
   P113DFunction{"f",p140tc_bindings(),1,False{},[]}]


def p140tc_raw_headers() -> List<&2,N111Segment>:
  [N111Segment{"a",1,1,0,0,[]},N111Segment{"a",1,1,0,1,[]},
   N111Segment{"a",1,1,1,0,[]},N111Segment{"a",1,2,0,0,[]},
   N111Segment{"b",1,1,0,0,[]},N111Segment{"a",2,1,0,0,[]},
   N111Segment{"a",1,1,0,0,p140tc_scalars()}]


def p140tc_ctors() -> List<&2,N_Constructor>:
  [N_Constructor{"A",1,False{}},N_Constructor{"A",2,False{}},N_Constructor{"A",1,True{}},N_Constructor{"B",1,False{}}]

@unsafe
def p140tc_controls() -> List<&2,String>:
  [p128bs_control_row("typed-values-all-pairs",p141sf_matrix(~N111Value,~p134v_value,p140tc_values(),p140tc_values(),0,0)),
   p128bs_control_row("typed-args-all-pairs",p141sf_matrix(~N111Arg,~p134v_arg,p140tc_args(),p140tc_args(),0,0)),
   p128bs_control_row("typed-bindings-all-pairs",p141sf_matrix(~NC_Binding,~p134v_binding,p140tc_bindings(),p140tc_bindings(),0,0)),
   p128bs_control_row("typed-scalars-all-pairs",p141sf_matrix(~N111Stmt,~p134v_scalar,p140tc_scalars(),p140tc_scalars(),0,0)),
   p128bs_control_row("typed-stmts-all-pairs",p141sf_matrix(~P113DStmt,~p134v_stmt,p140tc_stmts(),p140tc_stmts(),0,0)),
   p128bs_control_row("typed-functions-all-pairs",p141sf_matrix(~P113DFunction,~p134v_function,p140tc_functions(),p140tc_functions(),0,0)),
   p128bs_control_row("typed-headers-all-pairs",p141sf_matrix(~P113DFunction,~p134v_header,p140tc_functions(),p140tc_functions(),0,4)),
   p128bs_control_row("typed-raw_headers-all-pairs",p141sf_matrix(~N111Segment,~p140v_header,p140tc_raw_headers(),p140tc_raw_headers(),0,6)),
   p128bs_control_row("typed-ctors-all-pairs",p141sf_matrix(~N_Constructor,~p140v_ctor,p140tc_ctors(),p140tc_ctors(),0,0)),
   p128bs_control_row("typed-values-list",p134v_list(~N111Value,~p134v_value,p140tc_values(),p140tc_values()) && Bool.not(p134v_list(~N111Value,~p134v_value,[],p140tc_values())) && Bool.not(p134v_list(~N111Value,~p134v_value,p140tc_values(),[])) && p134v_list(~N111Value,~p134v_value,[],[])),
   p128bs_control_row("typed-args-list",p134v_list(~N111Arg,~p134v_arg,p140tc_args(),p140tc_args()) && Bool.not(p134v_list(~N111Arg,~p134v_arg,[],p140tc_args())) && Bool.not(p134v_list(~N111Arg,~p134v_arg,p140tc_args(),[])) && p134v_list(~N111Arg,~p134v_arg,[],[])),
   p128bs_control_row("typed-bindings-list",p134v_list(~NC_Binding,~p134v_binding,p140tc_bindings(),p140tc_bindings()) && Bool.not(p134v_list(~NC_Binding,~p134v_binding,[],p140tc_bindings())) && Bool.not(p134v_list(~NC_Binding,~p134v_binding,p140tc_bindings(),[])) && p134v_list(~NC_Binding,~p134v_binding,[],[])),
   p128bs_control_row("typed-scalars-list",p134v_list(~N111Stmt,~p134v_scalar,p140tc_scalars(),p140tc_scalars()) && Bool.not(p134v_list(~N111Stmt,~p134v_scalar,[],p140tc_scalars())) && Bool.not(p134v_list(~N111Stmt,~p134v_scalar,p140tc_scalars(),[])) && p134v_list(~N111Stmt,~p134v_scalar,[],[])),
   p128bs_control_row("typed-stmts-list",p134v_list(~P113DStmt,~p134v_stmt,p140tc_stmts(),p140tc_stmts()) && Bool.not(p134v_list(~P113DStmt,~p134v_stmt,[],p140tc_stmts())) && Bool.not(p134v_list(~P113DStmt,~p134v_stmt,p140tc_stmts(),[])) && p134v_list(~P113DStmt,~p134v_stmt,[],[])),
   p128bs_control_row("typed-headers-list",p134v_list(~P113DFunction,~p134v_header,p140tc_functions(),p140tc_functions()) && Bool.not(p134v_list(~P113DFunction,~p134v_header,[],p140tc_functions())) && Bool.not(p134v_list(~P113DFunction,~p134v_header,p140tc_functions(),[])) && p134v_list(~P113DFunction,~p134v_header,[],[])),
   p128bs_control_row("typed-raw_headers-list",p134v_list(~N111Segment,~p140v_header,p140tc_raw_headers(),p140tc_raw_headers()) && Bool.not(p134v_list(~N111Segment,~p140v_header,[],p140tc_raw_headers())) && Bool.not(p134v_list(~N111Segment,~p140v_header,p140tc_raw_headers(),[])) && p134v_list(~N111Segment,~p140v_header,[],[])),
   p128bs_control_row("typed-ctors-list",p134v_list(~N_Constructor,~p140v_ctor,p140tc_ctors(),p140tc_ctors()) && Bool.not(p134v_list(~N_Constructor,~p140v_ctor,[],p140tc_ctors())) && Bool.not(p134v_list(~N_Constructor,~p140v_ctor,p140tc_ctors(),[])) && p134v_list(~N_Constructor,~p140v_ctor,[],[])),
   p128bs_control_row("typed-strings-list",p134v_list(~String,~String.eq,["a","b"],["a","b"]) && Bool.not(p134v_list(~String,~String.eq,["a","b"],["a","c"])) && Bool.not(p134v_list(~String,~String.eq,["a"],[])) && p134v_list(~String,~String.eq,[],[])),
   p128bs_control_row("typed-u32-list",p134v_list(~U32,~U32.is_eq,[0,1,4294967295],[0,1,4294967295]) && Bool.not(p134v_list(~U32,~U32.is_eq,[0,1],[0,2])) && Bool.not(p134v_list(~U32,~U32.is_eq,[],[0])) && p134v_list(~U32,~U32.is_eq,[],[]))]

def p144pc_def(name: String, kind: String, +version: U32) -> KDef:
  KDef{name,kind,version,0,typ(1),KLiteral{"U32",version,"",0,0},[],False{},False{}}


@unsafe
def p144pc_query(+name: String, +prior: List<&2,KDef>) -> Bool:
  p140eq_def(f_find(name,prior),p144p_find(name,prior,Some{index_build(prior)})) &&
    p140eq_def(f_find(name,prior),p144p_find(name,prior,None{}))


@unsafe
def p144pc_scope(scope: FParseScope, +names: List<&2,String>) -> Bool:
  match scope:
    case FParseScope{+prior,index,ctors,ns,aliases,+view}: p144pc_queries(names,prior,view)


@unsafe
def p144pc_queries(names: List<&2,String>, +prior: List<&2,KDef>, +view: Maybe<&2,KDef>) -> Bool:
  match names:
    case Nil{}: True{}
    case Con{+name,rest}: p140eq_def(f_find(name,prior),p144p_find(name,prior,view)) &&
      p144pc_queries(rest,prior,view)


@unsafe
def p144pc_seed(+prior: List<&2,KDef>, ns: String) -> FParseScope:
  p144p_ready_scope(FParseScope{prior,index_build(List.reverse(&2,KDef,prior)),
    f_ctor_index(prior,missing()),ns,[],None{}})


@unsafe
def p144pc_legacy_index_opposite(+prior: List<&2,KDef>) -> Bool:
  Bool.not(p140eq_def(f_find("same",prior),index_find(index_build(List.reverse(&2,KDef,prior)),
    "same",index_hash("same",2166136261),32))) && p144pc_query("same",prior)


@unsafe
def p144pc_controls() -> List<&2,String>:
  +a = p144pc_def("same","Def",1)
  +b = p144pc_def("same","ADT",2)
  +unit = p144pc_def("Unit","ADT",3)
  +collision = p144pc_def("p143CollisionlrXlHP","Def",4)
  +child = p144pc_def("inside","Ctr",5)
  +parent : KDef = KDef{"Parent","ADT",1,0,typ(1),atom("Absent"),[child],False{},False{}}
  +scope = p144pc_seed([a,b,unit,collision,parent],"")
  [p131u_row(p144pc_query("missing",[]),"prior-empty"),
   p131u_row(p144pc_query("same",[a,b]),"prior-first-duplicate"),
   p131u_row(p144pc_query("same",[b,a]),"prior-reversed-duplicate"),
   p131u_row(p144pc_legacy_index_opposite([a,b]),"existing-reversed-index-is-not-oracle"),
   p131u_row(p144pc_query("missing",[a,b]),"prior-missing-name"),
   p131u_row(p144pc_query("",[a]),"prior-empty-name-miss"),
   p131u_row(p144pc_query("",[p144pc_def("","Odd",7),a]),"prior-empty-name-hit-fallback"),
   p131u_row(p144pc_query("absent",[p144pc_def("absent","Absent",8)]),"prior-real-absent-kind"),
   p131u_row(p144pc_query("missing",[p144pc_def("missing","Missing",9)]),"prior-real-missing-kind"),
   p131u_row(U32.is_eq(index_hash("Unit",2166136261),index_hash("p143CollisionlrXlHP",2166136261)),"prior-actual-hash-collision"),
   p131u_row(p144pc_query("Unit",[collision,unit]),"prior-collision-left"),
   p131u_row(p144pc_query("p143CollisionlrXlHP",[unit,collision]),"prior-collision-right"),
   p131u_row(p144pc_query("inside",[parent]),"prior-does-not-descend-children"),
   p131u_row(p144pc_query("inside",[parent,child]),"prior-flat-child-entry"),
   p131u_row(p144pc_query("λ.猫",[p144pc_def("λ.猫","Def",10)]),"prior-unicode"),
   p131u_row(p144pc_query("$kernel.cache",book_cached([a,b],19)),"prior-book-cache-is-ordinary-row"),
   p131u_row(p144pc_query("same",book_cached([a,b],19)),"prior-past-book-cache-flat"),
   p131u_row(p144pc_query("",[KIndexLeaf{13,[a]},a]),"prior-index-leaf-empty-name"),
   p131u_row(p144pc_query("",[KIndexNode{13,1,a,b},a]),"prior-index-node-empty-name"),
   p131u_row(p144pc_query("same",[KIndexLeaf{13,[b]},a]),"prior-index-value-not-child-search"),
   p131u_row(p144pc_scope(scope,["same","Unit","p143CollisionlrXlHP","Parent","inside","unknown"]),"prior-prepared-scope"),
   p131u_row(p144pc_scope(f_context_declare(b,scope),["same","Unit","Parent","unknown"]),"prior-update-new-header-wins"),
   p131u_row(p144pc_scope(f_context_declare(a,f_context_declare(b,scope)),["same","Unit","Parent"]),"prior-two-updates"),
   p131u_row(p144pc_scope(f_context_declare(a,p144pc_seed([],"Mod")),["same","Mod:same","unknown"]),"prior-qualified-header"),
   p131u_row(p144pc_scope(f_context_declare(a,f_parse_scope_empty()),["same","unknown"]),"prior-unprepared-scope-fallback"),
   p131u_row(p144p_view_same(None{},None{}),"prior-view-none-equality"),
   p131u_row(Bool.not(p144p_view_same(None{},Some{missing()})),"prior-view-readiness-distinct")]

def p144ot_def(name: String, kind: String, owned: Bool, children: List<&2,KDef>) -> KDef:
  KDef{name,kind,0,0,KTerm{"Absent","",0,0,[],[],0,0},KTerm{"Absent","",0,0,[],[],0,0},children,owned,False{}}


def p144ot_ctor(name: String) -> KDef:
  p144ot_def(name,"Ctr",False{},[])


@unsafe
def p144ot_ready(facts: P144OFacts, expected: Bool) -> Bool:
  match facts:
    case P144OFacts{names,valid}: p134v_bool(valid,expected)


@unsafe
def p144ot_indexed(+book: List<&2,KDef>, facts: P144OFacts, +name: String, expected: Bool) -> Bool:
  match facts:
    case P144OFacts{names,valid}:
      p134v_bool(p144o_index_query(book,valid,p144o_index(names,missing()),name),expected)


@unsafe
def p144ot_expected(+book: List<&2,KDef>, +name: String, +expected: Bool, ready: Bool) -> Bool:
  +facts = p144o_build(book)
  p134v_bool(p144o_original(book,name),expected) && p144ot_ready(facts,ready) &&
    p134v_bool(p144o_query(book,facts,name),expected) && p144ot_indexed(book,facts,name,expected)


@unsafe
def p144ot_carry_checked(+source: List<&2,KDef>, +name: String, prepared: P112SPrepared) -> Bool:
  match prepared:
    case P112SPrepared{book,nodes,error}:
      p134v_bool(p144o_owned(book,name),p144o_original(source,name)) &&
        p144ot_ready(p144o_payload(nc_ctor_context(book)),True{})


@unsafe
def p144ot_carry(+raw: List<&2,KDef>, +name: String) -> Bool:
  +source = book_cached(raw,0)
  +view = p144o_view(source,p144o_build(source))
  +again = ns_attach_book(view,[],0,[])
  p134v_bool(p144o_owned(view,name),p144o_original(source,name)) &&
    p134v_bool(p144o_owned(again,name),p144o_original(source,name)) &&
    p144ot_carry_checked(source,name,p112s_attach_book(again,[],0,[],missing(),""))


@unsafe
def p144ot_catalogue(+book: List<&2,KDef>) -> Bool:
  p134v_list(~N_Constructor,~p140v_ctor,p144o_original_constructors(book,book),p144o_constructors(book,book,p144o_build(book)))


@unsafe
def p144ot_bad_metadata(+book: List<&2,KDef>, +name: String, term: KTerm) -> Bool:
  p134v_bool(p144o_owned_term(book,name,term),p144o_original(book,name))

# Query workload helpers. For a complete comparison include p144o_build and,
# for the index version, p144o_index, in the measured acquisition boundary.

@unsafe
def p144ot_original_batch(+book: List<&2,KDef>, names: List<&2,String>) -> List<&2,Bool>:
  match names:
    case Nil{}: []
    case Con{+name,rest}: Con{p144o_original(book,name),p144ot_original_batch(book,rest)}


@unsafe
def p144ot_list_batch(+book: List<&2,KDef>, +facts: P144OFacts, names: List<&2,String>) -> List<&2,Bool>:
  match names:
    case Nil{}: []
    case Con{+name,rest}: Con{p144o_query(book,facts,name),p144ot_list_batch(book,facts,rest)}


@unsafe
def p144ot_index_batch(+book: List<&2,KDef>, +valid: Bool, +tree: KDef, names: List<&2,String>) -> List<&2,Bool>:
  match names:
    case Nil{}: []
    case Con{+name,rest}: Con{p144o_index_query(book,valid,tree,name),p144ot_index_batch(book,valid,tree,rest)}

# Exact native timing/control flow, without retaining the obsolete complete
# session across p140b_session solely to construct an unobservable rollback.

@unsafe
def p144ap_source_definition(+d: KDef) -> Bool:
  String.eq(dk(d),"Def") && U32.is_eq(da(d),2) && U32.is_eq(dx(d),0) &&
    Bool.not(nc_native_def(d)) && Bool.not(nc_foreign(d))


@unsafe
def p144ap_definition(name: String, kind: String, arity: U32, templates: U32,
    native: Bool, body: KTerm) -> KDef:
  KDef{name,kind,arity,templates,atom("Absent"),body,[],native,False{}}


@unsafe
def p144ap_args(left: N111Arg, empty: String, link: String) -> List<&2,N111Arg>:
  [p111_state(),left,p111_word(N111Local{"b"}),
   N111Arg{N111U32{},N111CtorId{empty}},N111Arg{N111U32{},N111CtorId{link}}]


@unsafe
def p144ap_verified(symbol: String, typ: N111Type, args: List<&2,N111Arg>,
    empty_arity: U32, link_arity: U32) -> String:
  p113e_functions([
    P113DFunction{"$p144.append.control",[NC_Binding{1,"a",N_W64{}},NC_Binding{2,"b",N_W64{}}],1,False{},
      [P113DScalar{N111Call{"answer",typ,symbol,args}},P113DResult{[N111Local{"answer"}]}]}],
    N111Ids{missing(),ns_ctor_index([N_Constructor{"End",empty_arity,False{}},N_Constructor{"Link",link_arity,False{}}],missing())},missing())


@unsafe
def p144ap_controls() -> List<&2,String>:
  +body = dv(p125pc_equation("End","Link",1,2,3,4,"join"))
  +args = p144ap_args(p111_word(N111Local{"a"}),"End","Link")
  [p113ft_row("append-ordinary-source-definition",p144ap_source_definition(p144ap_definition("join","Def",2,0,False{},body))),
   p113ft_row("append-native-library-source-definition",p144ap_source_definition(p144ap_definition("library.join","Def",2,0,True{},body))),
   p113ft_row("append-intrinsic-substitution-refused",Bool.not(p144ap_source_definition(p144ap_definition("U32.add","Def",2,0,True{},body)))),
   p113ft_row("append-ordinary-intrinsic-spelling-source",p144ap_source_definition(p144ap_definition("U32.add","Def",2,0,False{},body))),
   p113ft_row("append-foreign-body-refused",Bool.not(p144ap_source_definition(p144ap_definition("join","Def",2,0,True{},atom("Foreign"))))),
   p113ft_row("append-absent-body-refused",Bool.not(p144ap_source_definition(p144ap_definition("join","Def",2,0,False{},atom("Absent"))))),
   p113ft_row("append-templates-refused",Bool.not(p144ap_source_definition(p144ap_definition("join","Def",2,1,False{},body)))),
   p113ft_row("append-arity-refused",Bool.not(p144ap_source_definition(p144ap_definition("join","Def",3,0,False{},body)))),
   p113ft_row("append-nondefinition-refused",Bool.not(p144ap_source_definition(p144ap_definition("join","Ctr",2,0,False{},body)))),
   p113ft_row("append-global-js-fusion-policy-unchanged",Bool.not(j_fusion_def(p144ap_definition("library.join","Def",2,0,True{},body),2))),
   p113ft_row("append-full-verifier-valid",String.is_empty(p144ap_verified("p125_rt_concat_typed",N111U64{},args,0,2))),
   p113ft_row("append-full-verifier-empty-arity",Bool.not(String.is_empty(p144ap_verified("p125_rt_concat_typed",N111U64{},args,1,2)))),
   p113ft_row("append-full-verifier-link-arity",Bool.not(String.is_empty(p144ap_verified("p125_rt_concat_typed",N111U64{},args,0,1)))),
   p113ft_row("append-full-verifier-result-width",Bool.not(String.is_empty(p144ap_verified("p125_rt_concat_typed",N111U32{},args,0,2)))),
   p113ft_row("append-full-verifier-operand-width",Bool.not(String.is_empty(p144ap_verified("p125_rt_concat_typed",N111U64{},p144ap_args(N111Arg{N111U32{},N111Local{"a"}},"End","Link"),0,2)))),
   p113ft_row("append-full-verifier-state-as-word",Bool.not(String.is_empty(p144ap_verified("p125_rt_concat_typed",N111U64{},p144ap_args(p111_word(N111Local{"state"}),"End","Link"),0,2)))),
   p113ft_row("append-full-verifier-missing-constructor",Bool.not(String.is_empty(p144ap_verified("p125_rt_concat_typed",N111U64{},p144ap_args(p111_word(N111Local{"a"}),"Missing","Link"),0,2)))),
   p113ft_row("append-full-verifier-constructor-alias",Bool.not(String.is_empty(p144ap_verified("p125_rt_concat_typed",N111U64{},p144ap_args(p111_word(N111Local{"a"}),"End","End"),0,2)))),
   p113ft_row("append-full-verifier-argument-count",Bool.not(String.is_empty(p144ap_verified("p125_rt_concat_typed",N111U64{},[p111_state(),p111_word(N111Local{"a"})],0,2)))),
   p113ft_row("append-full-verifier-unknown-import",Bool.not(String.is_empty(p144ap_verified("p144_unknown_concat",N111U64{},args,0,2)))),
   p113ft_row("append-transport-valid",p118z_scalar(N111Call{"answer",N111U64{},"p125_rt_concat_typed",args},True{})),
   p113ft_row("append-transport-wrong-result",Bool.not(p118z_scalar(N111Call{"answer",N111U32{},"p125_rt_concat_typed",args},True{}))),
   p113ft_row("append-transport-unknown-import",Bool.not(p118z_scalar(N111Call{"answer",N111U64{},"p144_unknown_concat",args},True{})))]

@unsafe
def p144cet_ready(facts: P144CEFacts, expected: Bool) -> Bool:
  match facts:
    case P144CEFacts{members,valid}: p134v_bool(valid,expected)


@unsafe
def p144cet_query(+book: List<&2,KDef>, +name: String, +expected: Bool, ready: Bool) -> Bool:
  +facts = p144ce_build(book)
  p134v_bool(constructor_exists(book,name),expected) &&
    p134v_bool(p144ce_query(book,facts,name),expected) && p144cet_ready(facts,ready)


@unsafe
def p144cet_names(+book: List<&2,KDef>, +ctors: List<&2,KDef>, +seen: List<&2,String>, +expected: String) -> Bool:
  p88_string_eq(constructor_names(book,ctors,seen),expected) &&
    p88_string_eq(p144ce_names(book,ctors,seen),expected)


@unsafe
def p144cet_disjoint(+book: List<&2,KDef>, +defs: List<&2,KDef>, +expected: Bool) -> Bool:
  p134v_bool(p144ce_original_disjoint(defs,book),expected) &&
    p134v_bool(p144ce_disjoint(defs,book),expected) &&
    p134v_bool(base_prefix_ctor_disjoint(defs,book),expected)

# Sole override. The original open/inline/ranges decisions remain unchanged.

@unsafe
def p146ct_judgment(+program: P113AProgram, +ids: N111Ids, +valid: Bool,
    want_open: Bool, want_ok: Bool) -> Bool:
  +original = p113a_verify(program)
  +held = nt_choose(String,valid,u => p146c_verify(program,ids),u => p113a_verify(program))
  +raw = nt_choose(String,valid,u => p146c_verify_raw(program),u => p113a_verify(program))
  String.eq(original,held) && String.eq(original,raw) &&
    nt_choose(Bool,want_open,u => valid,u => Bool.not(valid)) &&
    nt_choose(Bool,want_ok,u => String.is_empty(original),u => Bool.not(String.is_empty(original)))


@unsafe
def p146ct_opened(opened: P114SBoundary, functions: List<&2,P113DFunction>,
    certificate: P113ACertificate, want_open: Bool, want_ok: Bool) -> Bool:
  match opened:
    case P114SBoundary{original,ids,old,valid}:
      p146ct_judgment(P113AProgram{P113DProgram{original,functions},certificate},ids,valid,want_open,want_ok)


@unsafe
def p146ct_case(first: P113DProgram, functions: List<&2,P113DFunction>,
    certificate: P113ACertificate, want_open: Bool, want_ok: Bool) -> Bool:
  p146ct_opened(p114s_open(first),functions,certificate,want_open,want_ok)


@unsafe
def p146ct_optimized(opened: P114SBoundary) -> Bool:
  match opened:
    case P114SBoundary{original,ids,functions,valid}:
      p146ct_judgment(P113AProgram{P113DProgram{original,functions},P113ACertificate{False{},False{}}},ids,valid,True{},True{})


@unsafe
def p146ct_optimization(which: U32) -> Bool:
  p146ct_optimized(p114s_ranges(p114s_inline(p114s_open(p114st_program(which)))))


def p146ct_bad_direct() -> P113DFunction:
  P113DFunction{"bad",[],1,False{},[P113DResult{[N111Local{"undefined"}]}]}


def p146ct_reserved(+name: String) -> P113DFunction:
  P113DFunction{"reserved",[NC_Binding{0,name,N_W64{}}],1,False{},[P113DResult{[N111Local{name}]}]}


def p146ct_raw(body: List<&2,N111Stmt>, constructors: List<&2,N_Constructor>,
    nodes: List<&2,P112SNode>, effects: List<&2,String>) -> P113DProgram:
  P113DProgram{P112StaticProgram{P111Program{[N111Segment{"main",0,1,0,0,body}],constructors,[0],[],effects,True{}},nodes},[]}


def p146ct_failure(result: P111Emission) -> Bool:
  match result:
    case P111Emission{pieces,error}: String.eq(error,"array native lowering: prior failure")
    case _: False{}


@unsafe
def p146ct_lowering_failure() -> Bool:
  p146ct_failure(p128raw_session_finish(NR_Request{[],[],[],[],[],None{}},P113ACertificate{True{},True{}},
    P128RawLowering{P113DLowered{p114st_program(1),"prior failure"},[]}))


@unsafe
def p146ct_controls() -> List<&2,String>:
  +off : P113ACertificate = P113ACertificate{False{},False{}}
  +on : P113ACertificate = P113ACertificate{True{},True{}}
  +first : P113DProgram = p114st_program(2)
  +bad : P113DFunction = p146ct_bad_direct()
  +raw_bad : P113DProgram = p146ct_raw([N111Return{N111Local{"undefined"}}],[],[],[])
  +static_bad : P113DProgram = p146ct_raw([N111Return{N111Const{0,0}}],[N_Constructor{"Box",1,False{}}],
    [P112SNode{1,"Box",[P112SRaw{7}]}],[])
  +both_bad : P113DProgram = p146ct_raw([N111Return{N111Local{"undefined"}}],[],[P112SNode{1,"Missing",[]}],[])
  +effect_bad : P113DProgram = p146ct_raw([N111Return{N111Const{0,0}}],[N_Constructor{"Box",1,False{}}],
    [P112SNode{0,"Box",[P112SRaw{7}]}],["Box"])
  +duplicate_raw : P113DProgram = P113DProgram{P112StaticProgram{P111Program{
    [N111Segment{"main",0,1,0,0,[N111Return{N111Const{0,0}}]},N111Segment{"main",0,1,0,0,[N111Return{N111Const{0,0}}]}],
    [],[0],[],[],True{}},[]},[]}
  +ctor_bad : P113DProgram = p146ct_raw([N111Return{N111Const{0,0}}],[N_Constructor{"Huge",256,False{}}],[],[])
  +public_bad : P113DFunction = P113DFunction{"main",[NC_Binding{0,"x",N_W64{}}],1,True{},[P113DResult{[N111Local{"x"}]}]}
  +unknown_call : P113DFunction = P113DFunction{"caller",[],1,False{},[P113DCall{["answer"],"missing",[]},P113DResult{[N111Local{"answer"}]}]}
  +duplicate_direct : List<&2,P113DFunction> = [p114st_identity(),p114st_identity()]
  +raw_namespace : P113DProgram = p146ct_raw([N111Set{"p114t_reserved",N111U64{},N111Const{0,0}},N111Return{N111Local{"p114t_reserved"}}],[],[],[])
  [p114st_row("p146-context-empty",p146ct_optimization(0)),
   p114st_row("p146-context-identity",p146ct_optimization(1)),
   p114st_row("p146-context-calls",p146ct_optimization(2)),
   p114st_row("p146-context-branches",p146ct_optimization(3)),
   p114st_row("p146-context-loop",p146ct_optimization(4)),
   p114st_row("p146-context-public",p146ct_optimization(5)),
   p114st_row("p146-context-changed-invalid-body",p146ct_case(first,[bad],off,True{},False{})),
   p114st_row("p146-context-forward-callee",p146ct_case(first,[p114st_caller(),p114st_pair(),p114st_scalar()],off,True{},False{})),
   p114st_row("p146-context-public-arity",p146ct_case(first,[public_bad],off,True{},False{})),
   p114st_row("p146-context-unknown-callee",p146ct_case(first,[unknown_call],off,True{},False{})),
   p114st_row("p146-context-duplicate-direct",p146ct_case(first,duplicate_direct,off,True{},False{})),
   p114st_row("p146-context-array-namespace-on",p146ct_case(first,[p146ct_reserved("p113a_reserved")],on,True{},False{})),
   p114st_row("p146-context-array-namespace-off",p146ct_case(first,[p146ct_reserved("p113a_reserved")],off,True{},True{})),
   p114st_row("p146-context-transport-namespace",p146ct_case(first,[p146ct_reserved("p114t_reserved")],off,True{},False{})),
   p114st_row("p146-context-raw-namespace",p146ct_case(raw_namespace,[],off,True{},False{})),
   p114st_row("p146-context-invalid-raw-fallback",p146ct_case(raw_bad,[bad],on,False{},False{})),
   p114st_row("p146-context-invalid-static-fallback",p146ct_case(static_bad,[bad],on,False{},False{})),
   p114st_row("p146-context-raw-static-error-order",p146ct_case(both_bad,[bad],on,False{},False{})),
   p114st_row("p146-context-effect-static-fallback",p146ct_case(effect_bad,[bad],off,False{},False{})),
   p114st_row("p146-context-duplicate-header-fallback",p146ct_case(duplicate_raw,[bad],off,False{},False{})),
   p114st_row("p146-context-constructor-ABI-fallback",p146ct_case(ctor_bad,[],off,False{},False{})),
   p114st_row("p146-context-first-direct-failure",p146ct_case(P113DProgram{p114st_original(),[bad]},[],off,False{},True{})),
   p114st_row("p146-context-lowering-error-prefix",p146ct_lowering_failure()),
   p114st_row("p146-context-independent-factories",p146ct_optimization(1) && p146ct_case(static_bad,[],off,False{},False{}) && p146ct_optimization(5))]

def p146cf_emission(result: P111Emission, expected: String) -> Bool:
  match result:
    case P111Emission{Nil{},error}: String.eq(error,expected)
    case _: False{}


@unsafe
def p146cf_opened(opened: P114SBoundary, want_open: Bool) -> Bool:
  match opened:
    case P114SBoundary{original,ids,functions,+valid}:
      nt_choose(Bool,want_open,u => valid,u => Bool.not(valid))


@unsafe
def p146cf_case(+program: P113DProgram, +certificate: P113ACertificate,
    +expected: String, want_open: Bool) -> Bool:
  +baseline = p113a_verify(P113AProgram{program,certificate})
  Bool.not(String.is_empty(expected)) && String.eq(baseline,expected) &&
    p146cf_opened(p114s_open(program),want_open) &&
    p146cf_emission(p128raw_session_finish(NR_Request{[],[],[],[],[],None{}},certificate,
      P128RawLowering{P113DLowered{program,""},[]}),"array structured IR: " ++ expected)


@unsafe
def p146cf_prior(+program: P113DProgram) -> Bool:
  String.eq(p113a_verify(P113AProgram{program,P113ACertificate{True{},True{}}}),
    "main: segment return must be U64") &&
    p146cf_emission(p128raw_session_finish(NR_Request{[],[],[],[],[],None{}},P113ACertificate{True{},True{}},
      P128RawLowering{P113DLowered{program,"prior failure"},[]}),"array native lowering: prior failure")


@unsafe
def p146cf_controls() -> List<&2,String>:
  +off : P113ACertificate = P113ACertificate{False{},False{}}
  +on : P113ACertificate = P113ACertificate{True{},True{}}
  +raw_bad : P113DProgram = p146ct_raw([N111Return{N111Local{"undefined"}}],[],[],[])
  +static_bad : P113DProgram = p146ct_raw([N111Return{N111Const{0,0}}],[N_Constructor{"Box",1,False{}}],
    [P112SNode{1,"Box",[P112SRaw{7}]}],[])
  +direct_bad : P113DProgram = P113DProgram{p114st_original(),[p146ct_bad_direct()]}
  +priority_bad : P113DProgram = p146ct_raw([
    N111Set{"p114t_reserved",N111U64{},N111Const{0,0}},N111Return{N111Local{"undefined"}}],
    [],[P112SNode{1,"Missing",[]}],[])
  +effect_bad : P113DProgram = p146ct_raw([N111Return{N111Const{0,0}}],[N_Constructor{"Box",1,False{}}],
    [P112SNode{0,"Box",[P112SRaw{7}]}],["Box"])
  +array_bad : P113DProgram = P113DProgram{p114st_original(),[p146ct_reserved("p113a_reserved")]}
  +transport_bad : P113DProgram = p146ct_raw([
    N111Set{"p114t_reserved",N111U64{},N111Const{0,0}},N111Return{N111Local{"p114t_reserved"}}],[],[],[])
  [p114st_row("p146-factory-invalid-raw",p146cf_case(raw_bad,off,"main: segment return must be U64",False{})),
   p114st_row("p146-factory-invalid-static",p146cf_case(static_bad,off,"static image offset or word budget invalid",False{})),
   p114st_row("p146-factory-first-direct-invalid",p146cf_case(direct_bad,off,"direct terminal vector has wrong arity/type or undefined value",False{})),
   p114st_row("p146-factory-raw-before-static-and-namespace",p146cf_case(priority_bad,on,"main: segment return must be U64",False{})),
   p114st_row("p146-factory-effect-static",p146cf_case(effect_bad,off,"static image constructor or arity invalid",False{})),
   p114st_row("p146-factory-array-namespace-valid-open",p146cf_case(array_bad,on,"reserved private array-template local",True{})),
   p114st_row("p146-factory-transport-namespace-valid-open",p146cf_case(transport_bad,off,"reserved transport-template local",True{})),
   p114st_row("p146-factory-lowering-error-before-invalid-raw",p146cf_prior(raw_bad))]
