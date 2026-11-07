# Finite controls for profitability only. No legality or runtime guard changes.
@unsafe
def p173bw_ids() -> N111Ids:
  N111Ids{missing(),p111q_constructor_ids([N_Constructor{"Record8",8,True{}}],0,missing())}

@unsafe
def p173bw_loads(+index: U32) -> List<&2,P113DStmt>:
  nt_choose(List<&2,P113DStmt>,U32.is_eq(index,8),u => [],u =>
    Con{P113DScalar{N111Load{"field" ++ U32.show(index),N111U64{},N111Local{"scratch"},U32.mul(index,8)}},
      p173bw_loads(U32.inc(index))})

@unsafe
def p173bw_stores(+index: U32, +preserved: U32) -> List<&2,P113DStmt>:
  nt_choose(List<&2,P113DStmt>,U32.is_eq(index,8),u => [],u =>
    Con{p173bt_store(index,N111Local{nt_choose(String,U32.is_lt(index,preserved),
      v => "field" ++ U32.show(index),v => "replacement" ++ U32.show(index))}),
      p173bw_stores(U32.inc(index),preserved)})

@unsafe
def p173bw_drops(+index: U32) -> List<&2,P113DStmt>:
  nt_choose(List<&2,P113DStmt>,U32.is_eq(index,8),u => [],u =>
    Con{p173bt_sink(index),p173bw_drops(U32.inc(index))})

@unsafe
def p173bw_body(prefix: List<&2,P113DStmt>, stores: List<&2,P113DStmt>) -> List<&2,P113DStmt>:
  Con{P113DScalar{N111Call{"ignored",N111U64{},"p111_rt_take",[
    p111_state(),p111_word(N111Local{"root"}),p111_scratch(),p111_u32(8)]}},
    nt_append(P113DStmt,p173bw_loads(0),nt_append(P113DStmt,prefix,nt_append(P113DStmt,stores,[
      P113DScalar{N111Call{"answer",N111U64{},"p111_rt_ctor",[
        p111_state(),N111Arg{N111U32{},N111CtorId{"Record8"}},p111_scratch(),p111_u32(8)]}},
      P113DResult{[N111Local{"answer"}]}])))}

@unsafe
def p173bw_plan(body: List<&2,P113DStmt>) -> P173BPlan:
  p173b_plan(body,p173bw_ids())

@unsafe
def p173bw_text(body: List<&2,P113DStmt>) -> String:
  p111q_body_text(p173b_stmts(body,[],p173bw_ids(),P111QCode{[],0,False{},""}))

@unsafe
def p173bw_changed(plan: P173BPlan) -> U32:
  match plan:
    case P173BNone{}: 0
    case P173BPlan{root,ctor,width,slots,drops}: p173b_changed(slots)

@unsafe
def p173b_wide_controls() -> List<&2,String>:
  +wide = p173bw_body(p173bw_drops(1),p173bw_stores(0,1))
  +text = p173bw_text(wide)
  +all = p173bw_body(p173bw_drops(0),p173bw_stores(0,0))
  +missing = p173bw_text(p173bw_body([],p173bw_stores(0,1)))
  [p113ft_row("wide-seven-replacements-legal",p173bt_has_plan(p173bw_plan(wide))),
   p113ft_row("wide-seven-replacements-count",U32.is_eq(p173bw_changed(p173bw_plan(wide)),7)),
   p113ft_row("wide-seven-replacements-profitable",p173b_profitable(p173bw_plan(wide))),
   p113ft_row("wide-all-fields-changed-legal",p173bt_has_plan(p173bw_plan(all))),
   p113ft_row("wide-all-fields-changed-profitable",p173b_profitable(p173bw_plan(all))),
   p113ft_row("wide-zero-changes-unprofitable",Bool.not(p173b_profitable(p173bw_plan(p173bw_body([],p173bw_stores(0,8)))))),
   p113ft_row("wide-shared-root-still-guarded",String.contains(text,"_rfc_count") && String.contains(text,"_unique")),
   p113ft_row("wide-preserved-field-still-sealed",String.contains(text,"_field_ok") && String.contains(text,"_old_0")),
   p113ft_row("wide-all-old-values-snapshotted",String.contains(text,"_old_1") && String.contains(text,"_old_7")),
   p113ft_row("wide-all-new-values-published",String.contains(text,"_sealed_1") && String.contains(text,"_sealed_7")),
   p113ft_row("wide-static-new-field-fallback",String.contains(text,"_new_dynamic") && String.contains(text,"_new_ok")),
   p113ft_row("wide-original-fallback-preserved",String.contains(text,"p125_rt_take8") || String.contains(text,"p111_rt_take")),
   p113ft_row("wide-omitted-sinks-still-trivial",String.contains(missing,"_old_hole") && String.contains(missing,"_old_static")),
   p113ft_row("wide-drop-preserved-refused",Bool.not(p173bt_has_plan(p173bw_plan(p173bw_body(p173bw_drops(0),p173bw_stores(0,1)))))),
   p113ft_row("wide-double-drop-refused",Bool.not(p173bt_has_plan(p173bw_plan(p173bw_body(Con{p173bt_sink(1),p173bw_drops(1)},p173bw_stores(0,1)))))),
   p113ft_row("wide-direct-root-replacement-refused",Bool.not(p173bt_has_plan(p173bw_plan(p173bw_body(p173bw_drops(0),
     Con{p173bt_store(0,N111Local{"root"}),p173bw_stores(1,0)}))))),
   p113ft_row("wide-consumed-old-field-replacement-refused",Bool.not(p173bt_has_plan(p173bw_plan(p173bw_body(p173bw_drops(0),
     Con{p173bt_store(0,N111Local{"field1"}),p173bw_stores(1,0)}))))),
   p113ft_row("wide-external-ownership-credit-preserved",p173bt_has_plan(p173bw_plan(p173bw_body(p173bw_drops(1),
     Con{p173bt_store(0,N111Local{"field0"}),Con{p173bt_store(1,N111Local{"independent_owned_alias"}),p173bw_stores(2,1)}}))))]

@unsafe
def p173b_wide_template_observation() -> String:
  p173bw_text(p173bw_body(p173bw_drops(1),p173bw_stores(0,1)))
