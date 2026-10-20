# Byte-load is deliberately a QBE intrinsic: N111 has no byte scalar type.
# Bounds precede loadub, so the compact arity table is never read as a wide word.
@unsafe
def p114pk_header(+site: U32, word: N111Value, ids: N111Ids) -> String:
  p114pk_local(site,"term") ++ " =l copy " ++ p111q_value(word,ids) ++ "\n" ++
  p114pk_local(site,"tag") ++ " =l shr " ++ p114pk_local(site,"term") ++ ", 56\n" ++
  p114pk_local(site,"tag") ++ " =l and " ++ p114pk_local(site,"tag") ++ ", 127\n" ++
  p114pk_local(site,"packed") ++ " =w ceql " ++ p114pk_local(site,"tag") ++ ", 1\n" ++
  "jnz " ++ p114pk_local(site,"packed") ++ ", " ++ p114pk_label(site,"metadata") ++ ", " ++ p114pk_label(site,"fallback") ++ "\n" ++
  p114pk_label(site,"metadata") ++ "\n" ++
  p114pk_local(site,"cid") ++ " =l shr " ++ p114pk_local(site,"term") ++ ", 40\n" ++
  p114pk_local(site,"cid") ++ " =l and " ++ p114pk_local(site,"cid") ++ ", 65535\n" ++
  p114pk_local(site,"count_ptr") ++ " =l add $p111_program, 24\n" ++
  p114pk_local(site,"count") ++ " =l loadl " ++ p114pk_local(site,"count_ptr") ++ "\n" ++
  p114pk_local(site,"bounded") ++ " =w cultl " ++ p114pk_local(site,"cid") ++ ", " ++ p114pk_local(site,"count") ++ "\n" ++
  "jnz " ++ p114pk_local(site,"bounded") ++ ", " ++ p114pk_label(site,"arity") ++ ", " ++ p114pk_label(site,"fallback") ++ "\n" ++
  p114pk_label(site,"arity") ++ "\n" ++
  p114pk_local(site,"arity_ptr") ++ " =l add $p111_cid_arity, " ++ p114pk_local(site,"cid") ++ "\n" ++
  p114pk_local(site,"arity") ++ " =w loadub " ++ p114pk_local(site,"arity_ptr") ++ "\n" ++
  p114pk_local(site,"unary") ++ " =w ceqw " ++ p114pk_local(site,"arity") ++ ", 1\n" ++
  "jnz " ++ p114pk_local(site,"unary") ++ ", " ++ p114pk_label(site,"hit") ++ ", " ++ p114pk_label(site,"fallback") ++ "\n"

@unsafe
def p114pk_hit(+site: U32, destination: String, output: String) -> String:
  p114pk_label(site,"hit") ++ "\n" ++
  p114pk_local(site,"payload") ++ " =l and " ++ p114pk_local(site,"term") ++ ", 1099511627775\n" ++
  "storel " ++ p114pk_local(site,"payload") ++ ", " ++ p111q_local(output) ++ "\n" ++
  p111q_local(destination) ++ " =l copy 1\n" ++
  "jmp " ++ p114pk_label(site,"join") ++ "\n" ++ p114pk_label(site,"fallback") ++ "\n"

@unsafe
def p114pk_finish(+site: U32, code: P111QCode) -> P111QCode:
  p111q_line("jmp " ++ p114pk_label(site,"join") ++ "\n" ++ p114pk_label(site,"join") ++ "\n",code)

# Reserve one site from the same counter used by all other statement emitters.
# Both paths assign the original U64 destination after the output store.
@unsafe
def p114pk_emit(original: N111Stmt, +ids: N111Ids, take: P114PKTake, code: P111QCode) -> P111QCode:
  match take code:
    case P114PKTake{destination,word,output} P111QCode{chunks,+site,terminal,error}:
      p114pk_finish(site,p114t_stmt(original,ids,
        P111QCode{Con{p114pk_header(site,word,ids) ++ p114pk_hit(site,destination,output),chunks},
          U32.inc(site),False{},error}))

@unsafe
def p114pk_selected(+original: N111Stmt, +ids: N111Ids, +code: P111QCode, shape: Maybe<&2,P114PKTake>) -> P111QCode:
  match shape:
    case Some{take}: p114pk_emit(original,ids,take,code)
    case None{}: p114t_stmt(original,ids,code)

@unsafe
def p114pk_stmt(+stmt: N111Stmt, +ids: N111Ids, +code: P111QCode) -> P111QCode:
  nt_choose(P111QCode,p114pk_ready(code),
    u => p114pk_selected(stmt,ids,code,p114pk_shape(stmt)),u => p114t_stmt(stmt,ids,code))
