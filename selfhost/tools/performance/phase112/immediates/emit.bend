# Expose only the common immediate subset of runtime04 keep/sink. The original
# owning statement is verified and remains visible until final QBE rendering.
# unsigned term < 2^57 implies RFC clear and term_tag <= TAG_PAK. In particular,
# do not use term_triv alone for keep: runtime checks the RFC bit first.
type P112IEmission is Data:
  P112IEmission{+expanded: Bool, +code: P111QCode}

@unsafe
def p112i_supported(+symbol: String) -> Bool:
  String.eq(symbol,"p111_rt_keep") || String.eq(symbol,"p111_rt_sink")

@unsafe
def p112i_text(+name: String, +symbol: String, +word: String, +n: U32) -> String:
  p111q_tmp(n) ++ " =w cultl " ++ word ++ ", 144115188075855872\n" ++
  "jnz " ++ p111q_tmp(n) ++ ", " ++ p111q_label(n) ++ ", " ++ p111q_label(U32.inc(n)) ++ "\n" ++
  p111q_label(n) ++ "\n" ++ p111q_local(name) ++ " =l copy " ++
  nt_choose(String,String.eq(symbol,"p111_rt_keep"),u => word,u => "0") ++ "\n" ++
  "jmp " ++ p111q_label(U32.add(n,2)) ++ "\n" ++ p111q_label(U32.inc(n)) ++ "\n" ++
  p111q_local(name) ++ " =l call $" ++ symbol ++ "(l %state, l " ++ word ++ ")\n" ++
  "jmp " ++ p111q_label(U32.add(n,2)) ++ "\n" ++ p111q_label(U32.add(n,2)) ++ "\n"

@unsafe
def p112i_emit(name: String, symbol: String, word: N111Value, ids: N111Ids, code: P111QCode) -> P112IEmission:
  match code:
    case P111QCode{chunks,+n,terminal,error}:
      P112IEmission{True{},P111QCode{Con{p112i_text(name,symbol,p111q_value(word,ids),n),chunks},U32.add(n,3),terminal,error}}

@unsafe
def p112i_expand(stmt: N111Stmt, +ids: N111Ids, +code: P111QCode) -> P112IEmission:
  match stmt:
    case N111Call{name,N111U64{},+symbol,
        Con{N111Arg{N111Ptr{},N111Local{+context}},Con{N111Arg{N111U64{},word},Nil{}}}}:
      nt_choose(P112IEmission,String.eq(context,"state") && p112i_supported(symbol),
        u => p112i_emit(name,symbol,word,ids,code),u => P112IEmission{False{},code})
    case _: P112IEmission{False{},code}
