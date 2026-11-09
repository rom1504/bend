# Append to the checked extracted compiler API. Admission controls never
# execute malformed runtime calls. Every row must end in =1. The oracle
# module is separately assembled and linked with cold-ctor-oracle.c.

@unsafe
def p185ct_ids() -> N111Ids:
  N111Ids{missing(),p111q_constructor_ids(
    [N_Constructor{"cold1",1,False{}},N_Constructor{"cold2",2,False{}},
     N_Constructor{"cold3",3,False{}},N_Constructor{"cold4",4,False{}},
     N_Constructor{"hot",2,True{}},N_Constructor{"zero",0,False{}},
     N_Constructor{"large",5,False{}}],17,missing())}

@unsafe
def p185ct_call(symbol: String, state: String, buffer: String, ctor: N111Value, count: N111Value, typ: N111Type) -> N111Stmt:
  N111Call{"value",typ,symbol,[N111Arg{N111Ptr{},N111Local{state}},
    N111Arg{N111U32{},ctor},N111Arg{N111Ptr{},N111Local{buffer}},N111Arg{N111U32{},count}]}

@unsafe
def p185ct_ordinary(ctor: String, count: U32) -> N111Stmt:
  p185ct_call("p111_rt_ctor","state","scratch",N111CtorId{ctor},N111Const{count,0},N111U64{})

@unsafe
def p185ct_changed(expansion: P114TExpansion) -> Bool:
  match expansion:
    case P114TExpansion{body,changed}: changed

@unsafe
def p185ct_admitted(stmt: N111Stmt, ids: N111Ids, site: U32) -> Bool:
  p185ct_changed(p185cc_expand(stmt,ids,site))

@unsafe
def p185ct_text(+stmt: N111Stmt, +previous: Bool) -> String:
  +ids = p185ct_ids()
  +code : P111QCode = P111QCode{[],0,False{},""}
  p111q_body_text(p111q_stmt(N111Return{N111Local{"value"}},ids,
    nt_choose(P111QCode,previous,u => p185cc_previous(stmt,ids,code),u => p111q_stmt(stmt,ids,code))))

@unsafe
def p185ct_same(+stmt: N111Stmt) -> Bool:
  String.eq(p185ct_text(stmt,True{}),p185ct_text(stmt,False{}))

@unsafe
def p185ct_calls(body: List<&2,N111Stmt>) -> U32:
  match body:
    case Nil{}: 0
    case Con{N111Call{name,typ,symbol,args},rest}: U32.inc(p185ct_calls(rest))
    case Con{N111If{condition,yes,no},rest}: U32.add(p185ct_calls(yes),U32.add(p185ct_calls(no),p185ct_calls(rest)))
    case Con{head,rest}: p185ct_calls(rest)

@unsafe
def p185ct_expanded_calls(expansion: P114TExpansion) -> U32:
  match expansion:
    case P114TExpansion{body,changed}: p185ct_calls(body)

@unsafe
def p185ct_old_ids() -> N111Ids:
  N111Ids{missing(),index_set(missing(),KDef{"cold2","N111Id",18,2,
    atom("Absent"),atom("Absent"),[],False{},False{}},index_hash("cold2",2166136261),32)}

@unsafe
def p185ct_row(name: String, +ok: Bool) -> String:
  name ++ nt_choose(String,ok,u => "=1",u => "=0")

@unsafe
def p185ct_controls() -> List<&2,String>:
  +ids = p185ct_ids()
  +pair = p185ct_ordinary("cold2",2)
  +text = p185ct_text(pair,False{})
  [p185ct_row("one",p185ct_admitted(p185ct_ordinary("cold1",1),ids,0)),
   p185ct_row("two",p185ct_admitted(pair,ids,0)),
   p185ct_row("three",p185ct_admitted(p185ct_ordinary("cold3",3),ids,0)),
   p185ct_row("four",p185ct_admitted(p185ct_ordinary("cold4",4),ids,0)),
   p185ct_row("class-one",U32.is_eq(p185cc_class(1),0)),
   p185ct_row("class-two",U32.is_eq(p185cc_class(2),1)),
   p185ct_row("class-three",U32.is_eq(p185cc_class(3),2)),
   p185ct_row("class-four",U32.is_eq(p185cc_class(4),2)),
   p185ct_row("hot-refused",Bool.not(p185ct_admitted(p185ct_ordinary("hot",2),ids,0))),
   p185ct_row("zero-refused",Bool.not(p185ct_admitted(p185ct_ordinary("zero",0),ids,0))),
   p185ct_row("large-refused",Bool.not(p185ct_admitted(p185ct_ordinary("large",5),ids,0))),
   p185ct_row("wrong-count-refused",Bool.not(p185ct_admitted(p185ct_ordinary("cold2",3),ids,0))),
   p185ct_row("absent-ctor-refused",Bool.not(p185ct_admitted(p185ct_ordinary("absent",2),ids,0))),
   p185ct_row("missing-marker-refused",Bool.not(p185ct_admitted(pair,p185ct_old_ids(),0))),
   p185ct_row("counter-limit-refused",Bool.not(p185ct_admitted(pair,ids,4294967295))),
   p185ct_row("numeric-cid-refused",Bool.not(p185ct_admitted(p185ct_call("p111_rt_ctor","state","scratch",N111Const{18,0},N111Const{2,0},N111U64{}),ids,0))),
   p185ct_row("high-count-refused",Bool.not(p185ct_admitted(p185ct_call("p111_rt_ctor","state","scratch",N111CtorId{"cold2"},N111Const{2,1},N111U64{}),ids,0))),
   p185ct_row("state-refused",Bool.not(p185ct_admitted(p185ct_call("p111_rt_ctor","other","scratch",N111CtorId{"cold2"},N111Const{2,0},N111U64{}),ids,0))),
   p185ct_row("buffer-refused",Bool.not(p185ct_admitted(p185ct_call("p111_rt_ctor","state","arbitrary",N111CtorId{"cold2"},N111Const{2,0},N111U64{}),ids,0))),
   p185ct_row("result-type-refused",Bool.not(p185ct_admitted(p185ct_call("p111_rt_ctor","state","scratch",N111CtorId{"cold2"},N111Const{2,0},N111Ptr{}),ids,0))),
   p185ct_row("hot-byte-identical",p185ct_same(p185ct_ordinary("hot",2))),
   p185ct_row("other-import-byte-identical",p185ct_same(p185ct_call("other","state","scratch",N111CtorId{"cold2"},N111Const{2,0},N111U64{}))),
   p185ct_row("exact-two-fallbacks",U32.is_eq(p185ct_expanded_calls(p185cc_expand(pair,ids,0)),2)),
   p185ct_row("descriptor-guard",String.contains(text,"_cold_abi_ok =w ceql") && String.contains(text,"_cold_descriptor_ok =w ceql") && String.contains(text,"_cold_caps_bits =l and")),
   p185ct_row("bin-guard",String.contains(text,"jnz %v_p114t_0_cold_nonempty")),
   p185ct_row("field-snapshot",String.contains(text,"_cold_field_0 =l loadl %v_scratch") && String.contains(text,"_cold_field_1 =l loadl")),
   p185ct_row("sized-fallback",String.contains(text,"call $p125_rt_ctor2(l %state, w 18, l %v_scratch)")),
   p185ct_row("tag-preserved",String.contains(text,"144115188075855872")),
   p185ct_row("ids-preserved",String.eq(p111q_value(N111CtorId{"cold4"},ids),"20")),
   p185ct_row("maximum-cid",p185ct_admitted(p185ct_ordinary("cold2",2),N111Ids{missing(),p111q_constructor_ids([N_Constructor{"cold2",2,False{}}],65535,missing())},0)),
   p185ct_row("oversize-cid-refused",Bool.not(p185ct_admitted(p185ct_ordinary("cold2",2),N111Ids{missing(),p111q_constructor_ids([N_Constructor{"cold2",2,False{}}],65536,missing())},0))),
   p185ct_row("memory-verifier-unchanged",Bool.not(p111v_memory(N111Local{"arbitrary"},0,2,missing(),ids)))]

@unsafe
def p185ct_oracle_function(+name: String, +count: U32, +cid: U32, +hot: Bool) -> String:
  +ids : N111Ids = N111Ids{missing(),p111q_constructor_ids([N_Constructor{"oracle",count,hot}],cid,missing())}
  "export function l $" ++ name ++ "(l %state, l %v_scratch) {\n@entry\n" ++
    p111q_body_text(p111q_stmts([p185ct_ordinary("oracle",count),N111Return{N111Local{"value"}}],ids,P111QCode{[],0,False{},""})) ++ "}\n"

@unsafe
def p185ct_oracle_twice() -> String:
  +ids : N111Ids = N111Ids{missing(),p111q_constructor_ids([N_Constructor{"oracle",2,False{}}],42,missing())}
  "export function l $p185ct_twice(l %state, l %v_scratch) {\n@entry\n" ++
    p111q_body_text(p111q_stmts([p185ct_ordinary("oracle",2),p185ct_ordinary("oracle",2),N111Return{N111Local{"value"}}],ids,P111QCode{[],0,False{},""})) ++ "}\n"

@unsafe
def p185ct_oracle_module() -> String:
  p185ct_oracle_function("p185ct_width1",1,65535,False{}) ++
  p185ct_oracle_function("p185ct_width2",2,65534,False{}) ++
  p185ct_oracle_function("p185ct_width3",3,65533,False{}) ++
  p185ct_oracle_function("p185ct_width4",4,65532,False{}) ++
  p185ct_oracle_function("p185ct_hot",2,41,True{}) ++ p185ct_oracle_twice()
