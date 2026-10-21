# Post-verification projection of exactly p111_rt_op(state,58,buffer,1).
# Preserve the runtime's low32 bitcast and guarded unsigned conversion. No
# generic N111 operator, runtime ABI, ownership rule or fast-math flag changes.

@unsafe
def p118f_to_u32(+dest: String, buffer: String, +site: U32, code: P111QCode) -> P111QCode:
  match code:
    case P111QCode{chunks,n,terminal,error}:
      +raw = p111q_local(p114t_name(site,"f_raw"))
      +bits = p111q_local(p114t_name(site,"f_bits"))
      +value = p111q_local(p114t_name(site,"f_value"))
      +nonnegative = p111q_local(p114t_name(site,"f_nonnegative"))
      +below_limit = p111q_local(p114t_name(site,"f_below_limit"))
      +valid = p111q_local(p114t_name(site,"f_valid"))
      +answer = p111q_local(p114t_name(site,"f_answer"))
      +target = p111q_local(dest)
      +yes = p111q_label(site)
      +no = p111q_label(U32.inc(site))
      +done = p111q_label(U32.add(site,2))
      text = raw ++ " =l loadl " ++ p111q_local(buffer) ++ "\n" ++
        bits ++ " =w copy " ++ raw ++ "\n" ++
        value ++ " =s cast " ++ bits ++ "\n" ++
        nonnegative ++ " =w cges " ++ value ++ ", s_0\n" ++
        below_limit ++ " =w clts " ++ value ++ ", s_4294967296\n" ++
        valid ++ " =w and " ++ nonnegative ++ ", " ++ below_limit ++ "\n" ++
        "jnz " ++ valid ++ ", " ++ yes ++ ", " ++ no ++ "\n" ++ yes ++ "\n" ++
        answer ++ " =w stoui " ++ value ++ "\n" ++
        target ++ " =l extuw " ++ answer ++ "\n" ++
        "jmp " ++ done ++ "\n" ++ no ++ "\n" ++
        target ++ " =l copy 0\n" ++
        "jmp " ++ done ++ "\n" ++ done ++ "\n"
      P111QCode{Con{text,chunks},U32.add(site,3),terminal,error}

@unsafe
def p114t_stmt(+stmt: N111Stmt, +ids: N111Ids, +code: P111QCode) -> P111QCode:
  match stmt code:
    case N111Call{+dest,N111U64{},+symbol,
      Con{N111Arg{N111Ptr{},N111Local{+state}},
      Con{N111Arg{N111U32{},N111Const{58,0}},
      Con{N111Arg{N111Ptr{},N111Local{+buffer}},
      Con{N111Arg{N111U32{},N111Const{1,0}},Nil{}}}}}}
      P111QCode{chunks,+next,terminal,error}:
        nt_choose(P111QCode,String.eq(symbol,"p111_rt_op") && String.eq(state,"state") &&
          p114t_buffer(buffer) && U32.is_le(next,4294967292),
          u => p118f_to_u32(dest,buffer,next,code),
          u => p118f_original_stmt(stmt,ids,code))
    case _ _: p118f_original_stmt(stmt,ids,code)
