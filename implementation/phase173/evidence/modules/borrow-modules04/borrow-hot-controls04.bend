# Finite metadata/policy controls. Unknown metadata must not enable a fast arm.
@unsafe
def p173bh_ids() -> N111Ids:
  N111Ids{missing(),p111q_constructor_ids([
    N_Constructor{"hotRecord",3,True{}},N_Constructor{"coldRecord",3,False{}}],0,missing())}

@unsafe
def p173bh_legacy() -> N111Ids:
  N111Ids{missing(),index_set(missing(),
    KDef{"hotRecord","N111Id",0,3,KTerm{"Absent","",0,0,[],[],0,0},
      KTerm{"Absent","",0,0,[],[],0,0},[],True{},False{}},index_hash("hotRecord",2166136261),32)}

@unsafe
def p173bh_guard_text(+hot: Bool) -> String:
  p111q_body_text(p111q_stmts(nt_append(N111Stmt,
    p173b_guard_start(N111Local{"root"},"hotRecord",0,hot),
    [N111Return{p173b_ref(0,"typed")}]),p173bh_ids(),P111QCode{[],1,False{},""}))

@unsafe
def p173b_hot_controls() -> List<&2,String>:
  +ids = p173bh_ids()
  [p113ft_row("record-hot-metadata-admitted",p173bh_hot("hotRecord",3,ids)),
   p113ft_row("record-cold-metadata-no-exemption",Bool.not(p173bh_hot("coldRecord",3,ids))),
   p113ft_row("record-missing-metadata-no-exemption",Bool.not(p173bh_hot("missing",3,ids))),
   p113ft_row("record-wrong-arity-no-exemption",Bool.not(p173bh_hot("hotRecord",4,ids))),
   p113ft_row("record-legacy-hot-no-exemption",Bool.not(p173bh_hot("hotRecord",3,p173bh_legacy()))),
   p113ft_row("record-numeric-identities-unchanged",String.eq(p111q_value(N111CtorId{"hotRecord"},ids),"0") && String.eq(p111q_value(N111CtorId{"coldRecord"},ids),"1")),
   p113ft_row("record-hot-policy-allows-capability8",String.contains(p173bh_guard_text(True{}),"_ordinary_publication =w or %v_p114t_0_p173borrow_ordinary_publication, 1\n")),
   p113ft_row("record-cold-policy-retains-capability8-refusal",String.contains(p173bh_guard_text(False{}),"_ordinary_publication =w or %v_p114t_0_p173borrow_ordinary_publication, 0\n"))]
