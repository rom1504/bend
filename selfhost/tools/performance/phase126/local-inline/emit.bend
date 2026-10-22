# Exact full-U64 selector clamp. The existing whole-function projection emits
# the immutable table under this same injectively encoded function name.
@unsafe
def p126i_table_name(name: String) -> String:
  "p126s_table_" ++ nt_fid(name)

@unsafe
def p126i_room(code: P111QCode) -> Bool:
  match code:
    case P111QCode{chunks,next,terminal,error}: U32.is_le(next,4294967292)

@unsafe
def p126i_load(+dest: String, +target: String, +value: N111Value, +last: U32, +ids: N111Ids, code: P111QCode) -> P111QCode:
  match code:
    case P111QCode{chunks,+site,terminal,error}:
      +prefix = "%p126_inline_" ++ U32.show(site) ++ "_"
      +word = p111q_value(value,ids)
      +bound = U32.show(last)
      +text = prefix ++ "inside =w cultl " ++ word ++ ", " ++ bound ++ "\n" ++
        "jnz " ++ prefix ++ "inside, " ++ p111q_label(site) ++ ", " ++ p111q_label(U32.inc(site)) ++ "\n" ++
        p111q_label(site) ++ "\n" ++ prefix ++ "index =l copy " ++ word ++ "\n" ++
        "jmp " ++ p111q_label(U32.add(site,2)) ++ "\n" ++
        p111q_label(U32.inc(site)) ++ "\n" ++ prefix ++ "index =l copy " ++ bound ++ "\n" ++
        "jmp " ++ p111q_label(U32.add(site,2)) ++ "\n" ++
        p111q_label(U32.add(site,2)) ++ "\n" ++ prefix ++ "bytes =l shl " ++ prefix ++ "index, 3\n" ++
        prefix ++ "addr =l add $" ++ p126i_table_name(target) ++ ", " ++ prefix ++ "bytes\n" ++
        p111q_local(dest) ++ " =l loadl " ++ prefix ++ "addr\n"
      P111QCode{Con{text,chunks},U32.add(site,3),terminal,error}

@unsafe
def p126i_selected(+dest: String, +target: String, +value: N111Value, +ids: N111Ids, +code: P111QCode, found: Maybe<&2,U32>) -> P111QCode:
  match found:
    case Some{last}: nt_choose(P111QCode,p126i_room(code),
      u => p126i_load(dest,target,value,last,ids,code),
      u => p113e_call_emit([dest],target,[value],ids,code))
    case None{}: p113e_call_emit([dest],target,[value],ids,code)

@unsafe
def p126i_call(+names: List<&2,String>, +target: String, +values: List<&2,N111Value>, +tables: List<&2,P126ITable>, +ids: N111Ids, +code: P111QCode) -> P111QCode:
  match names values:
    case [dest] [value]: p126i_selected(dest,target,value,ids,code,p126i_lookup(tables,target))
    case _ _: p113e_call_emit(names,target,values,ids,code)
