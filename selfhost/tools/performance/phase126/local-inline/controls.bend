# Pure emission/admission controls. These small reflected functions are not
# native runtime fixtures; ordinary checked source cases are separately pinned.
@unsafe
def p126i_control_text(code: P111QCode) -> String:
  match code:
    case P111QCode{chunks,next,terminal,error}: nt_text_finish(chunks,"")

@unsafe
def p126i_control_next(code: P111QCode, +expected: U32) -> Bool:
  match code:
    case P111QCode{chunks,next,terminal,error}:
      U32.is_eq(next,expected) && Bool.not(terminal) && String.is_empty(error)

@unsafe
def p126i_control_row(+name: String, result: Bool) -> String:
  nt_choose(String,result,u => name ++ ":pass",u => name ++ ":FAIL")

@unsafe
def p126i_controls() -> List<&2,String>:
  +ids: N111Ids = N111Ids{missing(),missing()}
  +params: List<&2,NC_Binding> = [NC_Binding{0,"p",N_Imm64{}}]
  +function: P113DFunction = P113DFunction{"selector",params,1,False{},p126s_decision("p",[0,2147483648,1065353216,4294967295],0)}
  +tables = p126i_catalogue([function],[])
  +start: P111QCode = P111QCode{[],7,False{},""}
  +call = p126i_call(["p"],"selector",[N111Local{"p"}],tables,ids,start)
  +text = p126i_control_text(call)
  +unknown = p126i_call(["out"],"unknown",[N111Local{"p"}],tables,ids,start)
  +wide = p126i_control_text(p126i_call(["out"],"selector",[N111Const{0,256}],tables,ids,start))
  +two: List<&2,N111Value> = [N111Const{1,0},N111Const{2,0}]
  +caller: P113DFunction = P113DFunction{"caller",params,1,False{},[P113DCall{["out"],"selector",[N111Local{"p"}]},P113DResult{[N111Local{"out"}]}]}
  [p126i_control_row("table-catalogue",p126i_present(p126i_lookup(tables,"selector"))),
   p126i_control_row("unknown-target",Bool.not(p126i_present(p126i_lookup(tables,"unknown")))),
   p126i_control_row("call-shape",p126i_recognized(["out"],"selector",[N111Local{"p"}],tables)),
   p126i_control_row("wrong-arity",Bool.not(p126i_recognized(["out"],"selector",two,tables))),
   p126i_control_row("multi-result",Bool.not(p126i_recognized(["a","b"],"selector",[N111Local{"p"}],tables))),
   p126i_control_row("full-word-clamp",String.contains(wide,"cultl 1099511627776, 3\n")),
   p126i_control_row("alias-input-before-write",String.contains(text,"%p126_inline_7_index =l copy %v_p\n") && String.contains(text,"%v_p =l loadl %p126_inline_7_addr\n")),
   p126i_control_row("counter-three",p126i_control_next(call,10)),
   p126i_control_row("exact-unknown-fallback",String.eq(p126i_control_text(unknown),p126i_control_text(p113e_call_emit(["out"],"unknown",[N111Local{"p"}],ids,start)))),
   p126i_control_row("exact-arity-fallback",String.eq(p126i_control_text(p126i_call(["out"],"selector",two,tables,ids,start)),p126i_control_text(p113e_call_emit(["out"],"selector",two,ids,start)))),
   p126i_control_row("table-global-retained",String.eq(p126i_emit_one(function,tables,ids,0),p126s_emit(function))),
   p126i_control_row("nonfloat-caller-selected",String.contains(p126i_emit_one(caller,tables,ids,0),"%p126_inline_0_addr =l add $" ++ p126i_table_name("selector")))]
