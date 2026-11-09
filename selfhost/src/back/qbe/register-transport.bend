# Post-verification ABI11102 register transport. p111v_counted_call proves
# jump FID/arity/incoming and p111v_contract proves return width/capacity.
# The existing scratch-origin and reserved p114t_ namespace rules apply.
# Capability 4 is still checked dynamically: without it the exact original
# helper performs its required trailing-register clear.

@unsafe
def p186rt_fid(+name: String, ids: N111Ids) -> Bool:
  match ids:
    case N111Ids{functions,constructors}:
      +entry = index_find(functions,name,index_hash(name,2166136261),32)
      String.eq(dk(entry),"N111Id") && U32.is_lt(da(entry),65532)

# Snapshot every word before the first destination store, retaining memmove
# semantics even in isolated template controls with overlapping source/state.
@unsafe
def p186rt_reads(+buffer: String, +count: U32, +site: U32, +index: U32) -> List<&2,N111Stmt>:
  nt_choose(List<&2,N111Stmt>,U32.is_eq(index,count),u => [],u =>
    Con{N111Load{p114t_name(site,"transfer_word_" ++ U32.show(index)),N111U64{},N111Local{buffer},U32.mul(index,8)},
      p186rt_reads(buffer,count,site,U32.inc(index))})

@unsafe
def p186rt_writes(+count: U32, +site: U32, +index: U32) -> List<&2,N111Stmt>:
  nt_choose(List<&2,N111Stmt>,U32.is_eq(index,count),u => [],u =>
    Con{N111Store{N111U64{},N111Local{"state"},U32.add(40,U32.mul(index,8)),p114t_local(site,"transfer_word_" ++ U32.show(index))},
      p186rt_writes(count,site,U32.inc(index))})

@unsafe
def p186rt_jump(dest: String, fid: String) -> List<&2,N111Stmt>:
  [N111Store{N111U32{},N111Local{"state"},28,N111Const{0,0}},
   N111Store{N111U32{},N111Local{"state"},32,N111FuncId{fid}},
   N111Set{dest,N111U64{},N111Const{0,0}}]

@unsafe
def p186rt_return(dest: String, count: U32, +site: U32) -> List<&2,N111Stmt>:
  [N111Store{N111U32{},N111Local{"state"},28,N111Const{count,0}},
   N111Load{p114t_name(site,"transfer_sp"),N111Ptr{},N111Local{"state"},16},
   N111Offset{p114t_name(site,"transfer_previous"),p114t_local(site,"transfer_sp"),N111Const{4294967288,4294967295}},
   N111Store{N111Ptr{},N111Local{"state"},16,p114t_local(site,"transfer_previous")},
   N111Load{p114t_name(site,"transfer_next"),N111U64{},p114t_local(site,"transfer_previous"),0},
   N111Store{N111U32{},N111Local{"state"},32,p114t_local(site,"transfer_next")},
   N111Set{dest,N111U64{},N111Const{0,0}}]

@unsafe
def p186rt_guard(stmt: N111Stmt, buffer: String, +count: U32, +site: U32, finish: List<&2,N111Stmt>) -> P114TExpansion:
  P114TExpansion{[
    N111Load{p114t_name(site,"transfer_caps"),N111U64{},N111Symbol{"p111_program"},88},
    N111Bin{p114t_name(site,"transfer_live"),N111U64{},"and",p114t_local(site,"transfer_caps"),N111Const{4,0}},
    N111If{p114t_local(site,"transfer_live"),
      nt_append(N111Stmt,p186rt_reads(buffer,count,site,0),
        nt_append(N111Stmt,p186rt_writes(count,site,0),finish)),[stmt]}],True{}}

@unsafe
def p186rt_expand(+stmt: N111Stmt, +ids: N111Ids, +site: U32) -> P114TExpansion:
  match stmt:
    case N111Call{+dest,N111U64{},+symbol,
      Con{N111Arg{N111Ptr{},N111Local{+state}},
      Con{N111Arg{N111U32{},N111FuncId{+fid}},
      Con{N111Arg{N111Ptr{},N111Local{+buffer}},
      Con{N111Arg{N111U32{},N111Const{+count,+high}},Nil{}}}}}}:
        nt_choose(P114TExpansion,String.eq(symbol,"p111_rt_jump") && String.eq(state,"state") &&
          U32.is_eq(high,0) && U32.is_le(count,8) && p114t_buffer(buffer) &&
          p186rt_fid(fid,ids) && U32.is_le(site,4294967200),
          u => p186rt_guard(stmt,buffer,count,site,p186rt_jump(dest,fid)),
          u => P114TExpansion{[stmt],False{}})
    case N111Call{+dest,N111U64{},+symbol,
      Con{N111Arg{N111Ptr{},N111Local{+state}},
      Con{N111Arg{N111Ptr{},N111Local{+buffer}},
      Con{N111Arg{N111U32{},N111Const{+count,+high}},Nil{}}}}}:
        nt_choose(P114TExpansion,String.eq(symbol,"p111_rt_return") && String.eq(state,"state") &&
          U32.is_eq(high,0) && U32.is_le(count,8) && p114t_buffer(buffer) && U32.is_le(site,4294967200),
          u => p186rt_guard(stmt,buffer,count,site,p186rt_return(dest,count,site)),
          u => P114TExpansion{[stmt],False{}})
    case _: P114TExpansion{[stmt],False{}}

@unsafe
def p186rt_previous(+stmt: N111Stmt, +ids: N111Ids, +code: P111QCode) -> P111QCode:
  match code:
    case P111QCode{chunks,next,terminal,error}:
      nt_choose(P111QCode,Bool.not(terminal) && String.is_empty(error),
        u => p128bf_selected(stmt,p128bf_match(stmt,ids,next),ids,code),u => p128bf_previous(stmt,ids,code))

@unsafe
def p186rt_join(+label: U32, no: List<&2,N111Stmt>, ids: N111Ids, yes: P111QCode) -> P111QCode:
  match yes:
    case P111QCode{+chunks,n,+terminal,error}:
      +prefix = nt_choose(List<&2,String>,terminal,u => chunks,u => Con{"jmp " ++ p111q_label(U32.add(label,2)) ++ "\n",chunks})
      p111q_if_done(label,terminal,p186rt_words(no,ids,
        P111QCode{Con{p111q_label(U32.inc(label)) ++ "\n",prefix},n,False{},error}))

# Generated slow calls bypass this recognizer, preserving exactly one fallback.
@unsafe
def p186rt_word(+stmt: N111Stmt, +ids: N111Ids, +code: P111QCode) -> P111QCode:
  match stmt code:
    case N111If{condition,yes,no} P111QCode{chunks,+n,terminal,error}:
      p186rt_join(n,no,ids,p186rt_words(yes,ids,
        P111QCode{Con{p111q_label(n) ++ "\n",Con{"jnz " ++ p111q_value(condition,ids) ++ ", " ++
          p111q_label(n) ++ ", " ++ p111q_label(U32.inc(n)) ++ "\n",chunks}},U32.add(n,3),False{},error}))
    case _ _: p186rt_previous(stmt,ids,code)

@unsafe
def p186rt_words(body: List<&2,N111Stmt>, +ids: N111Ids, code: P111QCode) -> P111QCode:
  match body:
    case Nil{}: code
    case Con{stmt,rest}: p186rt_words(rest,ids,p186rt_word(stmt,ids,code))

@unsafe
def p186rt_emitted(+stmt: N111Stmt, +ids: N111Ids, +code: P111QCode, expansion: P114TExpansion) -> P111QCode:
  match code expansion:
    case P111QCode{chunks,next,terminal,error} P114TExpansion{+body,+changed}:
      nt_choose(P111QCode,changed,
        u => p186rt_words(body,ids,P111QCode{chunks,U32.inc(next),terminal,error}),
        u => p186rt_previous(stmt,ids,code))

@unsafe
def p186rt_stmt(+stmt: N111Stmt, +ids: N111Ids, +code: P111QCode) -> P111QCode:
  match code:
    case P111QCode{chunks,+next,+terminal,+error}:
      nt_choose(P111QCode,Bool.not(terminal) && String.is_empty(error),
        u => p186rt_emitted(stmt,ids,code,p186rt_expand(stmt,ids,next)),
        u => p186rt_previous(stmt,ids,code))
