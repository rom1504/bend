# Dependencies: inline-runtime-controls.bend supplies unchanged call fixtures.
# Full observations compare literal expected instructions, including order.

@unsafe
def p172is_controls() -> List<&2,String>:
  +ids = p172irt_ids()
  +text = p172irt_text(p172irt_ordinary(2,"hot2"),False{})
  [p113ft_row("sealed-cold1-admitted",p172is_admit("p111_rt_ctor","state","scratch","cold1",1,ids,0)),
   p113ft_row("sealed-cold2-admitted",p172is_admit("p111_rt_ctor","state","scratch","cold2",2,ids,0)),
   p113ft_row("sealed-cold3-admitted",p172is_admit("p111_rt_ctor","state","scratch","cold3",3,ids,0)),
   p113ft_row("sealed-cold4-admitted",p172is_admit("p111_rt_ctor","state","scratch","cold4",4,ids,0)),
   p113ft_row("sealed-hot-admitted",p172is_admit("p111_rt_ctor","state","scratch","hot2",2,ids,0)),
   p113ft_row("sealed-missing-refused",Bool.not(p172is_admit("p111_rt_ctor","state","scratch","absent",2,ids,0))),
   p113ft_row("sealed-wrong-width-refused",Bool.not(p172is_admit("p111_rt_ctor","state","scratch","cold2",3,ids,0))),
   p113ft_row("sealed-zero-refused",Bool.not(p172is_admit("p111_rt_ctor","state","scratch","cold2",0,ids,0))),
   p113ft_row("sealed-five-refused",Bool.not(p172is_admit("p111_rt_ctor","state","scratch","cold2",5,ids,0))),
   p113ft_row("sealed-counter-refused",Bool.not(p172is_admit("p111_rt_ctor","state","scratch","cold2",2,ids,4294967295))),
   p113ft_row("sealed-unknown-buffer-refused",Bool.not(p172is_admit("p111_rt_ctor","state","arbitrary","cold2",2,ids,0))),
   p113ft_row("sealed-state-alias-refused",Bool.not(p172is_admit("p111_rt_ctor","state","state","cold2",2,ids,0))),
   p113ft_row("sealed-wrong-width-byte-identical",p172irt_same(p172irt_ordinary(3,"cold2"))),
   p113ft_row("sealed-missing-byte-identical",p172irt_same(p172irt_ordinary(2,"absent"))),
   p113ft_row("sealed-zero-byte-identical",p172irt_same(p172irt_ordinary(0,"cold2"))),
   p113ft_row("sealed-large-byte-identical",p172irt_same(p172irt_ordinary(5,"cold2"))),
   p113ft_row("sealed-high-count-byte-identical",p172irt_same(p172irt_call(2,1,N111CtorId{"cold2"},"scratch","state","p111_rt_ctor",N111U64{}))),
   p113ft_row("sealed-numeric-cid-byte-identical",p172irt_same(p172irt_call(2,0,N111Const{1,0},"scratch","state","p111_rt_ctor",N111U64{}))),
   p113ft_row("sealed-other-state-byte-identical",p172irt_same(p172irt_call(2,0,N111CtorId{"cold2"},"scratch","other","p111_rt_ctor",N111U64{}))),
   p113ft_row("sealed-unknown-buffer-byte-identical",p172irt_same(p172irt_call(2,0,N111CtorId{"cold2"},"arbitrary","state","p111_rt_ctor",N111U64{}))),
   p113ft_row("sealed-other-import-byte-identical",p172irt_same(p172irt_call(2,0,N111CtorId{"cold2"},"scratch","state","other",N111U64{}))),
   p113ft_row("sealed-pointer-result-byte-identical",p172irt_same(p172irt_call(2,0,N111CtorId{"cold2"},"scratch","state","p111_rt_ctor",N111Ptr{}))),
   p113ft_row("sealed-no-cold-capability-required",Bool.not(String.contains(text,"$p111_program"))),
   p113ft_row("sealed-guarded-branch",String.contains(text,"jnz %v_p114t_0_p172_guard")),
   p113ft_row("sealed-top-byte-test",String.contains(text,"_p172_tag_0 =l shr ") && String.contains(text,"_p172_sealed_0 =w cnel ")),
   p113ft_row("sealed-original-fallback",String.contains(text,"call $p125_rt_ctor2(l %state, w 4, l %v_scratch)")),
   p113ft_row("sealed-return-preserved",String.contains(text,"ret %v_answer\n"))]

@unsafe
def p172is_guard_observation() -> List<&2,N111Stmt> & List<&2,N111Stmt>:
  Tuple{p172is_guard("scratch",2,9),[
    N111Set{"p114t_9_p172_fields_ok",N111U32{},N111Const{1,0}},
    N111Load{"p114t_9_p172_field_0",N111U64{},N111Local{"scratch"},0},
    N111Bin{"p114t_9_p172_tag_0",N111U64{},"shr",N111Local{"p114t_9_p172_field_0"},N111Const{56,0}},
    N111Bin{"p114t_9_p172_sealed_0",N111U64{},"ne",N111Local{"p114t_9_p172_tag_0"},N111Const{2,0}},
    N111Bin{"p114t_9_p172_fields_ok",N111U32{},"and",N111Local{"p114t_9_p172_fields_ok"},N111Local{"p114t_9_p172_sealed_0"}},
    N111Load{"p114t_9_p172_field_1",N111U64{},N111Local{"scratch"},8},
    N111Bin{"p114t_9_p172_tag_1",N111U64{},"shr",N111Local{"p114t_9_p172_field_1"},N111Const{56,0}},
    N111Bin{"p114t_9_p172_sealed_1",N111U64{},"ne",N111Local{"p114t_9_p172_tag_1"},N111Const{2,0}},
    N111Bin{"p114t_9_p172_fields_ok",N111U32{},"and",N111Local{"p114t_9_p172_fields_ok"},N111Local{"p114t_9_p172_sealed_1"}},
    N111Load{"p114t_9_p172_heap",N111Ptr{},N111Local{"state"},0},
    N111Load{"p114t_9_p172_pool",N111Ptr{},N111Local{"state"},8},
    N111Load{"p114t_9_p172_head",N111U64{},N111Local{"p114t_9_p172_pool"},8},
    N111Bin{"p114t_9_p172_pool_ok",N111U64{},"ne",N111Local{"p114t_9_p172_head"},N111Const{0,0}},
    N111Bin{"p114t_9_p172_guard",N111U32{},"and",N111Local{"p114t_9_p172_fields_ok"},N111Local{"p114t_9_p172_pool_ok"}}]}

@unsafe
def p172is_fast_observation() -> List<&2,N111Stmt> & List<&2,N111Stmt>:
  Tuple{p172is_fast("answer","hot2",2,9),[
    N111Bin{"p114t_9_p172_bytes",N111U64{},"shl",N111Local{"p114t_9_p172_head"},N111Const{3,0}},
    N111Offset{"p114t_9_p172_fields",N111Local{"p114t_9_p172_heap"},N111Local{"p114t_9_p172_bytes"}},
    N111Load{"p114t_9_p172_next",N111U64{},N111Local{"p114t_9_p172_fields"},0},
    N111Store{N111U64{},N111Local{"p114t_9_p172_pool"},8,N111Local{"p114t_9_p172_next"}},
    N111Load{"p114t_9_p172_length",N111U64{},N111Local{"p114t_9_p172_pool"},264},
    N111Bin{"p114t_9_p172_length",N111U64{},"sub",N111Local{"p114t_9_p172_length"},N111Const{2,0}},
    N111Store{N111U64{},N111Local{"p114t_9_p172_pool"},264,N111Local{"p114t_9_p172_length"}},
    N111Store{N111U64{},N111Local{"p114t_9_p172_fields"},0,N111Local{"p114t_9_p172_field_0"}},
    N111Store{N111U64{},N111Local{"p114t_9_p172_fields"},8,N111Local{"p114t_9_p172_field_1"}},
    N111Bin{"p114t_9_p172_meta",N111U64{},"shl",N111CtorId{"hot2"},N111Const{40,0}},
    N111Bin{"p114t_9_p172_meta",N111U64{},"or",N111Local{"p114t_9_p172_meta"},N111Const{0,33554432}},
    N111Bin{"answer",N111U64{},"or",N111Local{"p114t_9_p172_meta"},N111Local{"p114t_9_p172_head"}}]}
