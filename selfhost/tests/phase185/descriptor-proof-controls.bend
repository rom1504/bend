@unsafe
def p185bd_ids() -> N111Ids:
  N111Ids{missing(),p111q_constructor_ids([N_Constructor{"bound",2,False{}}],0,missing())}

@unsafe
def p185bd_tables(abi: U32, size: U32, caps: P111QDatum, arity: U32, hot: U32, count: U32) -> List<&2,P111QData>:
  [P111QData{"p111_program",8,True{},[
     P111QLong{abi,0},P111QLong{size,0},P111QLong{1,0},P111QLong{count,0},
     P111QLong{0,0},P111QLong{1,0},P111QLong{2,0},P111QLong{1,0},
     P111QLong{0,0},P111QLong{0,0},P111QLong{0,0},caps,
     P111QReloc{"p111_segments",0},P111QReloc{"p111_fid_arity",0},
     P111QReloc{"p111_fid_flags",0},P111QReloc{"p111_fid_results",0},
     P111QReloc{"p111_cid_arity",0},P111QReloc{"p111_cid_hot",0},
     P111QReloc{"p111_cid_names",0},P111QLong{0,0},P111QReloc{"p111_show_desc",0},
     P111QReloc{"p111_show_names",0},P111QLong{0,0},P111QReloc{"p111_effects",0}]},
   P111QData{"p111_cid_arity",1,False{},[P111QByte{arity}]},
   P111QData{"p111_cid_hot",1,False{},[P111QByte{hot}]}]

@unsafe
def p185bd_normal(caps: U32) -> List<&2,P111QData>:
  p185bd_tables(11102,192,P111QLong{caps,0},2,0,1)

@unsafe
def p185bd_proved(tables: List<&2,P111QData>) -> Bool:
  p185cb_known("bound",p185cb_bind(p185bd_ids(),tables))

@unsafe
def p185bd_foreign() -> N111Ids:
  N111Ids{missing(),index_set(missing(),KDef{"bound","N111Id",0,2,
    kt("P185Constructor","",0,11102,[]),kt("OtherMetadata","owned",17,19,[]),[],False{},False{}},
    index_hash("bound",2166136261),32)}

@unsafe
def p185bd_value(ids: N111Ids) -> KTerm:
  match ids:
    case N111Ids{functions,constructors}: dv(index_find(constructors,"bound",index_hash("bound",2166136261),32))

@unsafe
def p185bd_call() -> N111Stmt:
  N111Call{"value",N111U64{},"p111_rt_ctor",[p111_state(),N111Arg{N111U32{},N111CtorId{"bound"}},p111_scratch(),p111_u32(2)]}

@unsafe
def p185bd_text(+ids: N111Ids) -> String:
  p111q_body_text(p111q_stmt(N111Return{N111Local{"value"}},ids,
    p185cc_words(p185cb_construct(p185bd_call(),"value","bound","scratch",2,ids,0),ids,P111QCode{[],1,False{},""})))

@unsafe
def p185bd_row(name: String, +ok: Bool) -> String:
  name ++ nt_choose(String,ok,u => "=1",u => "=0")

@unsafe
def p185bd_controls() -> List<&2,String>:
  +tables = p185bd_normal(15)
  +bound = p185cb_bind(p185bd_ids(),tables)
  +foreign = p185cb_bind(p185bd_foreign(),tables)
  +text = p185bd_text(bound)
  [p185bd_row("caps-nine",p185bd_proved(p185bd_normal(9))),
   p185bd_row("caps-eleven",p185bd_proved(p185bd_normal(11))),
   p185bd_row("caps-thirteen",p185bd_proved(p185bd_normal(13))),
   p185bd_row("caps-fifteen",p185bd_proved(tables)),
   p185bd_row("caps-five-guarded",Bool.not(p185bd_proved(p185bd_normal(5)))),
   p185bd_row("caps-eight-guarded",Bool.not(p185bd_proved(p185bd_normal(8)))),
   p185bd_row("caps-unknown-guarded",Bool.not(p185bd_proved(p185bd_normal(25)))),
   p185bd_row("caps-high-guarded",Bool.not(p185bd_proved(p185bd_tables(11102,192,P111QLong{15,1},2,0,1)))),
   p185bd_row("abi-guarded",Bool.not(p185bd_proved(p185bd_tables(11101,192,P111QLong{15,0},2,0,1)))),
   p185bd_row("size-guarded",Bool.not(p185bd_proved(p185bd_tables(11102,184,P111QLong{15,0},2,0,1)))),
   p185bd_row("count-mismatch-guarded",Bool.not(p185bd_proved(p185bd_tables(11102,192,P111QLong{15,0},2,0,2)))),
   p185bd_row("arity-mismatch-guarded",Bool.not(p185bd_proved(p185bd_tables(11102,192,P111QLong{15,0},3,0,1)))),
   p185bd_row("hot-mismatch-guarded",Bool.not(p185bd_proved(p185bd_tables(11102,192,P111QLong{15,0},2,1,1)))),
   p185bd_row("invalid-hot-guarded",Bool.not(p185bd_proved(p185bd_tables(11102,192,P111QLong{15,0},2,2,1)))),
   p185bd_row("missing-tables-guarded",Bool.not(p185bd_proved([]))),
   p185bd_row("duplicate-header-guarded",Bool.not(p185bd_proved(nt_append(P111QData,tables,
     [P111QData{"p111_program",8,True{},p185cb_items(tables,"p111_program")}])))),
   p185bd_row("manual-ids-guarded",Bool.not(p185cb_known("bound",p185bd_ids()))),
   p185bd_row("old-proof-revalidated",p185cb_known("bound",p185cb_bind(bound,tables))),
   p185bd_row("old-proof-cleared",Bool.not(p185cb_known("bound",p185cb_bind(bound,p185bd_normal(5))))),
   p185bd_row("old-proof-missing-cleared",Bool.not(p185cb_known("bound",p185cb_bind(bound,[])))),
   p185bd_row("foreign-metadata-unqualified",Bool.not(p185cb_known("bound",foreign))),
   p185bd_row("foreign-metadata-preserved",String.eq(tg(p185bd_value(foreign)),"OtherMetadata") && String.eq(nm(p185bd_value(foreign)),"owned") && U32.is_eq(ix(p185bd_value(foreign)),17)),
   p185bd_row("paired-guard-eliminated",Bool.not(String.contains(text,"_cold_guard")) && Bool.not(String.contains(text,"$p111_program"))),
   p185bd_row("manual-guard-retained",String.contains(p185bd_text(p185bd_ids()),"_cold_guard") && String.contains(p185bd_text(p185bd_ids()),"$p111_program")),
   p185bd_row("cap-mismatch-guard-retained",String.contains(p185bd_text(p185cb_bind(bound,p185bd_normal(5))),"_cold_guard")),
   p185bd_row("allocation-miss-fallback-retained",String.contains(text,"call $p125_rt_ctor2(l %state, w 0, l %v_scratch)")),
   p185bd_row("ids-preserved",String.eq(p111q_value(N111CtorId{"bound"},bound),"0"))]

@unsafe
def p185bd_oracle_module() -> String:
  "export function l $p185bd_paired(l %state, l %v_scratch) {\n@entry\n" ++
    p185bd_text(p185cb_bind(p185bd_ids(),p185bd_normal(15))) ++ "}\n" ++
  "export function l $p185bd_raw(l %state, l %v_scratch) {\n@entry\n" ++
    p185bd_text(p185bd_ids()) ++ "}\n"
