# Exact post-verification projection of U32.div/mod. The original p111_rt_op
# signature and scratch capacity remain independently checked. A nonzero low32
# divisor guards each native division; modulo-by-zero preserves the full input.
# No new generic verified IR operator is admitted. This bounded template uses
# the already reserved p114t_ local namespace and advances the label supply.

@unsafe
def p118u_divmod(+dest: String, +buffer: String, +op: U32, +site: U32, code: P111QCode) -> P111QCode:
  match code:
    case P111QCode{chunks,n,terminal,error}:
      +raw = p111q_local(p114t_name(site,"u_raw"))
      +left = p111q_local(p114t_name(site,"u_left"))
      +right = p111q_local(p114t_name(site,"u_right"))
      +right_word = p111q_local(p114t_name(site,"u_right_word"))
      +ptr = p111q_local(p114t_name(site,"u_ptr"))
      +ok = p111q_local(p114t_name(site,"u_nonzero"))
      +answer = p111q_local(p114t_name(site,"u_answer"))
      +target = p111q_local(dest)
      +yes = p111q_label(site)
      +no = p111q_label(U32.inc(site))
      +done = p111q_label(U32.add(site,2))
      text = raw ++ " =l loadl " ++ p111q_local(buffer) ++ "\n" ++
        left ++ " =w copy " ++ raw ++ "\n" ++
        ptr ++ " =l add " ++ p111q_local(buffer) ++ ", 8\n" ++
        right_word ++ " =l loadl " ++ ptr ++ "\n" ++
        right ++ " =w copy " ++ right_word ++ "\n" ++
        ok ++ " =w cnew " ++ right ++ ", 0\n" ++
        "jnz " ++ ok ++ ", " ++ yes ++ ", " ++ no ++ "\n" ++ yes ++ "\n" ++
        answer ++ " =w " ++ nt_choose(String,U32.is_eq(op,18),u => "udiv",u => "urem") ++
          " " ++ left ++ ", " ++ right ++ "\n" ++
        target ++ " =l extuw " ++ answer ++ "\n" ++
        "jmp " ++ done ++ "\n" ++ no ++ "\n" ++
        target ++ " =l copy " ++ nt_choose(String,U32.is_eq(op,18),u => "0",u => raw) ++ "\n" ++
        "jmp " ++ done ++ "\n" ++ done ++ "\n"
      P111QCode{Con{text,chunks},U32.add(site,3),terminal,error}

@unsafe
def p114t_stmt(+stmt: N111Stmt, +ids: N111Ids, +code: P111QCode) -> P111QCode:
  match stmt code:
    case N111Call{+dest,N111U64{},+symbol,
      Con{N111Arg{N111Ptr{},N111Local{+state}},
      Con{N111Arg{N111U32{},N111Const{+op,0}},
      Con{N111Arg{N111Ptr{},N111Local{+buffer}},
      Con{N111Arg{N111U32{},N111Const{2,0}},Nil{}}}}}}
      P111QCode{chunks,+next,terminal,error}:
        nt_choose(P111QCode,String.eq(symbol,"p111_rt_op") && String.eq(state,"state") &&
          (U32.is_eq(op,18) || U32.is_eq(op,19)) && p114t_buffer(buffer),
          u => p118u_divmod(dest,buffer,op,next,code),
          u => p114t_expanded(p114t_expand(p118q_sized(stmt),ids,next),ids,code))
    case _ P111QCode{chunks,next,terminal,error}:
      p114t_expanded(p114t_expand(p118q_sized(stmt),ids,next),ids,code)
