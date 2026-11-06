# Finite admission/rendering controls and full structured template observations.
# The two observations are independently compared by the host harness. Neither
# signatures nor these finite controls constitute a BendTT semantic theorem.

@unsafe
def p172irt_ids() -> N111Ids:
  N111Ids{missing(),p111q_constructor_ids([
    N_Constructor{"cold1",1,False{}},N_Constructor{"cold2",2,False{}},
    N_Constructor{"cold3",3,False{}},N_Constructor{"cold4",4,False{}},
    N_Constructor{"hot2",2,True{}}],0,missing())}

@unsafe
def p172irt_call(count: U32, high: U32, ctor: N111Value, buffer: String,
  state: String, symbol: String, typ: N111Type) -> N111Stmt:
  N111Call{"answer",typ,symbol,[N111Arg{N111Ptr{},N111Local{state}},
    N111Arg{N111U32{},ctor},N111Arg{N111Ptr{},N111Local{buffer}},
    N111Arg{N111U32{},N111Const{count,high}}]}

@unsafe
def p172irt_ordinary(count: U32, ctor: String) -> N111Stmt:
  p172irt_call(count,0,N111CtorId{ctor},"scratch","state","p111_rt_ctor",N111U64{})

@unsafe
def p172irt_text(+stmt: N111Stmt, +previous: Bool) -> String:
  +code : P111QCode = P111QCode{[],0,False{},""}
  +ids = p172irt_ids()
  p111q_body_text(p111q_stmt(N111Return{N111Local{"answer"}},ids,
    nt_choose(P111QCode,previous,u => p172ir_previous(stmt,ids,code),
      u => p111q_stmt(stmt,ids,code))))

@unsafe
def p172irt_same(+stmt: N111Stmt) -> Bool:
  String.eq(p172irt_text(stmt,True{}),p172irt_text(stmt,False{}))

@unsafe
def p172ir_controls() -> List<&2,String>:
  +ids = p172irt_ids()
  +text = p172irt_text(p172irt_ordinary(2,"cold2"),False{})
  +legacy : N111Ids = N111Ids{missing(),index_set(missing(),
    KDef{"cold2","N111Id",1,2,atom("Absent"),atom("Absent"),[],False{},False{}},index_hash("cold2",2166136261),32)}
  [p113ft_row("inline-cold1",p172ir_cold("cold1",1,ids)),
   p113ft_row("inline-cold2",p172ir_cold("cold2",2,ids)),
   p113ft_row("inline-cold3",p172ir_cold("cold3",3,ids)),
   p113ft_row("inline-cold4",p172ir_cold("cold4",4,ids)),
   p113ft_row("inline-hot-refused",Bool.not(p172ir_cold("hot2",2,ids))),
   p113ft_row("inline-missing-refused",Bool.not(p172ir_cold("absent",2,ids))),
   p113ft_row("inline-arity-refused",Bool.not(p172ir_cold("cold2",3,ids))),
   p113ft_row("inline-legacy-metadata-refused",Bool.not(p172ir_cold("cold2",2,legacy))),
   p113ft_row("inline-id-preserved",String.eq(p111q_value(N111CtorId{"cold4"},ids),"3")),
   p113ft_row("inline-class-rounded",U32.is_eq(p172ir_class(3),2) && U32.is_eq(p172ir_words(3),4)),
   p113ft_row("inline-counter-refused",Bool.not(p172ir_admit("p111_rt_ctor","state","scratch","cold2",2,ids,4294967295))),
   p113ft_row("inline-hot-byte-identical",p172irt_same(p172irt_ordinary(2,"hot2"))),
   p113ft_row("inline-wrong-width-byte-identical",p172irt_same(p172irt_ordinary(3,"cold2"))),
   p113ft_row("inline-missing-byte-identical",p172irt_same(p172irt_ordinary(2,"absent"))),
   p113ft_row("inline-zero-byte-identical",p172irt_same(p172irt_ordinary(0,"cold2"))),
   p113ft_row("inline-large-byte-identical",p172irt_same(p172irt_ordinary(5,"cold2"))),
   p113ft_row("inline-high-count-byte-identical",p172irt_same(p172irt_call(2,1,N111CtorId{"cold2"},"scratch","state","p111_rt_ctor",N111U64{}))),
   p113ft_row("inline-numeric-cid-byte-identical",p172irt_same(p172irt_call(2,0,N111Const{1,0},"scratch","state","p111_rt_ctor",N111U64{}))),
   p113ft_row("inline-other-state-byte-identical",p172irt_same(p172irt_call(2,0,N111CtorId{"cold2"},"scratch","other","p111_rt_ctor",N111U64{}))),
   p113ft_row("inline-alias-state-byte-identical",p172irt_same(p172irt_call(2,0,N111CtorId{"cold2"},"state","state","p111_rt_ctor",N111U64{}))),
   p113ft_row("inline-unknown-buffer-byte-identical",p172irt_same(p172irt_call(2,0,N111CtorId{"cold2"},"arbitrary","state","p111_rt_ctor",N111U64{}))),
   p113ft_row("inline-other-import-byte-identical",p172irt_same(p172irt_call(2,0,N111CtorId{"cold2"},"scratch","state","other",N111U64{}))),
   p113ft_row("inline-pointer-result-byte-identical",p172irt_same(p172irt_call(2,0,N111CtorId{"cold2"},"scratch","state","p111_rt_ctor",N111Ptr{}))),
   p113ft_row("inline-capability-guard",String.contains(text,"add $p111_program, 88\n") && String.contains(text,"_p172_cold_cap =l and ")),
   p113ft_row("inline-guarded-branch",String.contains(text,"jnz %v_p114t_0_p172_guard")),
   p113ft_row("inline-original-fallback",String.contains(text,"call $p125_rt_ctor2(l %state, w 1, l %v_scratch)")),
   p113ft_row("inline-return-preserved",String.contains(text,"ret %v_answer\n"))]

@unsafe
def p172ir_guard_observation() -> List<&2,N111Stmt> & List<&2,N111Stmt>:
  Tuple{p172ir_guard(3,9),[
    N111Load{"p114t_9_p172_caps",N111U64{},N111Symbol{"p111_program"},88},
    N111Bin{"p114t_9_p172_cold_cap",N111U64{},"and",N111Local{"p114t_9_p172_caps"},N111Const{8,0}},
    N111Bin{"p114t_9_p172_cap_ok",N111U64{},"ne",N111Local{"p114t_9_p172_cold_cap"},N111Const{0,0}},
    N111Load{"p114t_9_p172_heap",N111Ptr{},N111Local{"state"},0},
    N111Load{"p114t_9_p172_pool",N111Ptr{},N111Local{"state"},8},
    N111Load{"p114t_9_p172_head",N111U64{},N111Local{"p114t_9_p172_pool"},16},
    N111Bin{"p114t_9_p172_pool_ok",N111U64{},"ne",N111Local{"p114t_9_p172_head"},N111Const{0,0}},
    N111Bin{"p114t_9_p172_guard",N111U32{},"and",N111Local{"p114t_9_p172_cap_ok"},N111Local{"p114t_9_p172_pool_ok"}}]}

@unsafe
def p172ir_fast_observation() -> List<&2,N111Stmt> & List<&2,N111Stmt>:
  Tuple{p172ir_fast("answer","scratch","cold3",3,9),[
    N111Bin{"p114t_9_p172_bytes",N111U64{},"shl",N111Local{"p114t_9_p172_head"},N111Const{3,0}},
    N111Offset{"p114t_9_p172_fields",N111Local{"p114t_9_p172_heap"},N111Local{"p114t_9_p172_bytes"}},
    N111Load{"p114t_9_p172_next",N111U64{},N111Local{"p114t_9_p172_fields"},0},
    N111Store{N111U64{},N111Local{"p114t_9_p172_pool"},16,N111Local{"p114t_9_p172_next"}},
    N111Load{"p114t_9_p172_length",N111U64{},N111Local{"p114t_9_p172_pool"},272},
    N111Bin{"p114t_9_p172_length",N111U64{},"sub",N111Local{"p114t_9_p172_length"},N111Const{4,0}},
    N111Store{N111U64{},N111Local{"p114t_9_p172_pool"},272,N111Local{"p114t_9_p172_length"}},
    N111Load{"p114t_9_p172_field_0",N111U64{},N111Local{"scratch"},0},
    N111Store{N111U64{},N111Local{"p114t_9_p172_fields"},0,N111Local{"p114t_9_p172_field_0"}},
    N111Load{"p114t_9_p172_field_1",N111U64{},N111Local{"scratch"},8},
    N111Store{N111U64{},N111Local{"p114t_9_p172_fields"},8,N111Local{"p114t_9_p172_field_1"}},
    N111Load{"p114t_9_p172_field_2",N111U64{},N111Local{"scratch"},16},
    N111Store{N111U64{},N111Local{"p114t_9_p172_fields"},16,N111Local{"p114t_9_p172_field_2"}},
    N111Bin{"p114t_9_p172_meta",N111U64{},"shl",N111CtorId{"cold3"},N111Const{40,0}},
    N111Bin{"p114t_9_p172_meta",N111U64{},"or",N111Local{"p114t_9_p172_meta"},N111Const{0,33554432}},
    N111Bin{"answer",N111U64{},"or",N111Local{"p114t_9_p172_meta"},N111Local{"p114t_9_p172_head"}}]}

# This small module lets an independent C harness compare selected allocator
# states and payloads with the untouched runtime helper. Its descriptor must
# agree with p172irt_ids and must be the active p111_program.
@unsafe
def p172ir_oracle_function(+count: U32, +previous: Bool) -> String:
  +name = nt_choose(String,previous,u => "p172ir_base_",u => "p172ir_fast_") ++ U32.show(count)
  "export function l $" ++ name ++ "(l %state, l %v_scratch) {\n@entry\n" ++
    p172irt_text(p172irt_ordinary(count,"cold" ++ U32.show(count)),previous) ++ "}\n"

@unsafe
def p172ir_oracle_module() -> String:
  p172ir_oracle_function(1,False{}) ++ p172ir_oracle_function(1,True{}) ++
    p172ir_oracle_function(2,False{}) ++ p172ir_oracle_function(2,True{}) ++
    p172ir_oracle_function(3,False{}) ++ p172ir_oracle_function(3,True{}) ++
    p172ir_oracle_function(4,False{}) ++ p172ir_oracle_function(4,True{})
