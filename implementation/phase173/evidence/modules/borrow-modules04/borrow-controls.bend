# Finite compiler-data controls only, not a claim of a semantic proof.

@unsafe
def p173bt_ids() -> N111Ids:
  N111Ids{missing(),p111q_constructor_ids([N_Constructor{"Record3",3,True{}}],0,missing())}

@unsafe
def p173bt_sink(index: U32) -> P113DStmt:
  P113DScalar{N111Call{"ignored",N111U64{},"p111_rt_sink",[
    p111_state(),p111_word(N111Local{"field" ++ U32.show(index)})]}}

@unsafe
def p173bt_store(index: U32, value: N111Value) -> P113DStmt:
  P113DScalar{N111Store{N111U64{},N111Local{"scratch"},U32.mul(index,8),value}}

@unsafe
def p173bt_stores(middle: N111Value) -> List<&2,P113DStmt>:
  [p173bt_store(0,N111Local{"field0"}),p173bt_store(1,middle),p173bt_store(2,N111Local{"field2"})]

@unsafe
def p173bt_body(prefix: List<&2,P113DStmt>, stores: List<&2,P113DStmt>) -> List<&2,P113DStmt>:
  nt_append(P113DStmt,[
    P113DScalar{N111Call{"ignored",N111U64{},"p111_rt_take",[
      p111_state(),p111_word(N111Local{"root"}),p111_scratch(),p111_u32(3)]}},
    P113DScalar{N111Load{"field0",N111U64{},N111Local{"scratch"},0}},
    P113DScalar{N111Load{"field1",N111U64{},N111Local{"scratch"},8}},
    P113DScalar{N111Load{"field2",N111U64{},N111Local{"scratch"},16}}],
    nt_append(P113DStmt,prefix,nt_append(P113DStmt,stores,[
      P113DScalar{N111Call{"answer",N111U64{},"p111_rt_ctor",[
        p111_state(),N111Arg{N111U32{},N111CtorId{"Record3"}},p111_scratch(),p111_u32(3)]}},
      P113DResult{[N111Local{"answer"}]}])))

@unsafe
def p173bt_has_plan(plan: P173BPlan) -> Bool:
  match plan:
    case P173BNone{}: False{}
    case _: True{}

@unsafe
def p173bt_accepted(body: List<&2,P113DStmt>) -> Bool:
  p173bt_has_plan(p173b_plan(body,p173bt_ids()))

@unsafe
def p173bt_text(body: List<&2,P113DStmt>) -> String:
  p111q_body_text(p173b_stmts(body,[],p173bt_ids(),P111QCode{[],0,False{},""}))

@unsafe
def p173b_controls() -> List<&2,String>:
  +normal = p173bt_body([p173bt_sink(1)],p173bt_stores(N111Local{"replacement"}))
  +text = p173bt_text(normal)
  +scalar = p173bt_text(p173bt_body([],p173bt_stores(N111Local{"replacement"})))
  [p113ft_row("record-complete-owned-result",p173bt_accepted(normal)),
   p113ft_row("record-profitable",p173b_profitable(p173b_plan(normal,p173bt_ids()))),
   p113ft_row("record-unchanged-legality",p173bt_accepted(p173bt_body([],p173bt_stores(N111Local{"field1"})))),
   p113ft_row("record-unchanged-unprofitable",Bool.not(p173b_profitable(p173b_plan(p173bt_body([],p173bt_stores(N111Local{"field1"})),p173bt_ids())))),
   p113ft_row("record-scalar-drop-dynamically-trivial",String.contains(scalar,"_old_hole") && String.contains(scalar,"_old_static")),
   p113ft_row("record-original-take-fallback",String.contains(text,"p125_rt_take3") || String.contains(text,"p111_rt_take")),
   p113ft_row("record-original-constructor-fallback",String.contains(text,"p125_rt_ctor3") || String.contains(text,"p111_rt_ctor")),
   p113ft_row("record-unique-rfc-guard",String.contains(text,"_rfc_count") && String.contains(text,"_unique")),
   p113ft_row("record-dynamic-static-boundary",String.contains(text,"51413504") && String.contains(text,"_heap_min")),
   p113ft_row("record-owned-result-retains-root",String.contains(text,"ret %v_root\n")),
   p113ft_row("record-new-seal-keep-drop",String.contains(text,"p111_rt_keep") && String.contains(text,"_unkeep")),
   p113ft_row("record-same-layout-cid-guard",String.contains(text,"_cid_ok")),
   p113ft_row("record-drop-preserved-refused",Bool.not(p173bt_accepted(p173bt_body([p173bt_sink(0)],p173bt_stores(N111Local{"replacement"}))))),
   p113ft_row("record-double-drop-refused",Bool.not(p173bt_accepted(p173bt_body([p173bt_sink(1),p173bt_sink(1)],p173bt_stores(N111Local{"replacement"}))))),
   p113ft_row("record-root-cycle-refused",Bool.not(p173bt_accepted(p173bt_body([p173bt_sink(1)],p173bt_stores(N111Local{"root"}))))),
   p113ft_row("record-field-permutation-refused",Bool.not(p173bt_accepted(p173bt_body([p173bt_sink(1)],[
     p173bt_store(0,N111Local{"field2"}),p173bt_store(1,N111Local{"replacement"}),p173bt_store(2,N111Local{"field0"})])))),
   p113ft_row("record-missing-field-refused",Bool.not(p173bt_accepted(p173bt_body([p173bt_sink(1)],[p173bt_store(0,N111Local{"field0"}),p173bt_store(1,N111Local{"replacement"})])))),
   p113ft_row("record-duplicate-store-refused",Bool.not(p173bt_accepted(p173bt_body([p173bt_sink(1)],nt_append(P113DStmt,p173bt_stores(N111Local{"replacement"}),[p173bt_store(0,N111Local{"field0"})]))))),
   p113ft_row("record-effect-refused",Bool.not(p173bt_accepted(p173bt_body([
     P113DScalar{N111Call{"effect",N111U64{},"unknown_effect",[p111_state()]}},p173bt_sink(1)],p173bt_stores(N111Local{"replacement"}))))),
   p113ft_row("record-direct-call-refused",Bool.not(p173bt_accepted(p173bt_body([
     P113DCall{["changed"],"unknown",[N111Local{"replacement"}]},p173bt_sink(1)],p173bt_stores(N111Local{"changed"}))))),
   p113ft_row("record-live-external-overwrite-refused",Bool.not(p173bt_accepted(p173bt_body([
     P113DScalar{N111Set{"alias",N111U64{},N111Local{"replacement"}}},
     P113DScalar{N111Set{"replacement",N111U64{},N111Const{1,0}}},p173bt_sink(1)],p173bt_stores(N111Local{"alias"}))))),
   p113ft_row("record-copy-chain",p173bt_accepted(p173bt_body([
     P113DScalar{N111Set{"alias",N111U64{},N111Local{"replacement"}}},p173bt_sink(1)],p173bt_stores(N111Local{"alias"}))))]

@unsafe
def p173b_template_observation() -> String:
  p173bt_text(p173bt_body([p173bt_sink(1)],p173bt_stores(N111Local{"replacement"})))
