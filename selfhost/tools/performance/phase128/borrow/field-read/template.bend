# Phase128 experiment: certified late expansion of an already verified readonly
# borrow import. The source IR, independent verifier and runtime stay unchanged.
# This template is bound to the sequential CPU P111State/RFC ABI only.
type P128BFRead is Data:
  P128BFSkip{}
  P128BFRead{+dest: String, +term: N111Value, +buffer: String, +ctor: String, +count: U32}

# Keep the existing numeric IDs; retain constructor arity in unused emitter
# metadata so this late template checks the same descriptor/count again.
@unsafe
def p111q_constructor_ids(constructors: List<&2,N_Constructor>, +next: U32, tree: KDef) -> KDef:
  match constructors:
    case Nil{}: tree
    case Con{N_Constructor{+name,arity,hot},rest}:
      p111q_constructor_ids(rest,U32.inc(next),
        index_set(tree,KDef{name,"N111Id",next,arity,atom("Absent"),atom("Absent"),[],False{},False{}},
          index_hash(name,2166136261),32))

@unsafe
def p128bf_known(+ctor: String, +count: U32, ids: N111Ids) -> Bool:
  match ids:
    case N111Ids{functions,constructors}:
      +entry = index_find(constructors,ctor,index_hash(ctor,2166136261),32)
      String.eq(dk(entry),"N111Id") && U32.is_lt(da(entry),65536) && U32.is_eq(dx(entry),count)

@unsafe
def p128bf_match(+stmt: N111Stmt, +ids: N111Ids, +site: U32) -> P128BFRead:
  match stmt:
    case N111Call{+dest,N111U64{},+symbol,
      Con{N111Arg{N111Ptr{},N111Local{+state}},
      Con{N111Arg{N111U64{},term},
      Con{N111Arg{N111Ptr{},N111Local{+buffer}},
      Con{N111Arg{N111U32{},N111CtorId{+ctor}},
      Con{N111Arg{N111U32{},N111Const{+count,+high}},Nil{}}}}}}}:
        nt_choose(P128BFRead,String.eq(symbol,"p118_rt_borrow_fields") && String.eq(state,"state") &&
          U32.is_eq(high,0) && U32.is_ge(count,2) && U32.is_le(count,8) &&
          p114t_buffer(buffer) && p128bf_known(ctor,count,ids) && U32.is_le(site,4294967200),
          u => P128BFRead{dest,term,buffer,ctor,count},u => P128BFSkip{})
    case _: P128BFSkip{}

@unsafe
def p128bf_guard(+term: N111Value, +ctor: String, +site: U32) -> List<&2,N111Stmt>:
  [N111Set{p114t_name(site,"borrow_word"),N111U64{},term},
   N111Bin{p114t_name(site,"borrow_tag_bits"),N111U64{},"shr",p114t_local(site,"borrow_word"),N111Const{56,0}},
   N111Bin{p114t_name(site,"borrow_tag"),N111U64{},"and",p114t_local(site,"borrow_tag_bits"),N111Const{127,0}},
   N111Bin{p114t_name(site,"borrow_is_ctr"),N111U64{},"eq",p114t_local(site,"borrow_tag"),N111Const{2,0}},
   N111Bin{p114t_name(site,"borrow_aux_bits"),N111U64{},"shr",p114t_local(site,"borrow_word"),N111Const{40,0}},
   N111Bin{p114t_name(site,"borrow_aux"),N111U64{},"and",p114t_local(site,"borrow_aux_bits"),N111Const{65535,0}},
   N111Bin{p114t_name(site,"borrow_is_ctor"),N111U64{},"eq",p114t_local(site,"borrow_aux"),N111CtorId{ctor}},
   N111Bin{p114t_name(site,"borrow_guard"),N111U32{},"and",p114t_local(site,"borrow_is_ctr"),p114t_local(site,"borrow_is_ctor")}]

# rfc_view's exact low/high word layout. The selected CPU runtime has no
# concurrent refcount mutation; this is not a concurrent/device template.
@unsafe
def p128bf_rfc(+site: U32) -> List<&2,N111Stmt>:
  [N111Bin{p114t_name(site,"borrow_header_bytes"),N111U64{},"shl",p114t_local(site,"borrow_location"),N111Const{3,0}},
   N111Offset{p114t_name(site,"borrow_header"),p114t_local(site,"borrow_heap"),p114t_local(site,"borrow_header_bytes")},
   N111Load{p114t_name(site,"borrow_low"),N111U32{},p114t_local(site,"borrow_header"),0},
   N111Load{p114t_name(site,"borrow_high"),N111U32{},p114t_local(site,"borrow_header"),4},
   N111Bin{p114t_name(site,"borrow_high_shift"),N111U64{},"shl",p114t_local(site,"borrow_high"),N111Const{32,0}},
   N111Bin{p114t_name(site,"borrow_header_word"),N111U64{},"or",p114t_local(site,"borrow_low"),p114t_local(site,"borrow_high_shift")},
   N111Bin{p114t_name(site,"borrow_location"),N111U64{},"shr",p114t_local(site,"borrow_header_word"),N111Const{24,0}}]

@unsafe
def p128bf_fields(+buffer: String, +count: U32, +site: U32, +index: U32) -> List<&2,N111Stmt>:
  nt_choose(List<&2,N111Stmt>,U32.is_eq(index,count),u => [],u =>
    Con{N111Load{p114t_name(site,"borrow_field_" ++ U32.show(index)),N111U64{},p114t_local(site,"borrow_fields"),U32.mul(index,8)},
    Con{N111Store{N111U64{},N111Local{buffer},U32.mul(index,8),p114t_local(site,"borrow_field_" ++ U32.show(index))},
      p128bf_fields(buffer,count,site,U32.inc(index))}})

@unsafe
def p128bf_fast(+dest: String, +buffer: String, +count: U32, +site: U32) -> List<&2,N111Stmt>:
  nt_append(N111Stmt,
    [N111Load{p114t_name(site,"borrow_heap"),N111Ptr{},N111Local{"state"},0},
     N111Bin{p114t_name(site,"borrow_location"),N111U64{},"and",p114t_local(site,"borrow_word"),N111Const{4294967295,255}},
     N111Bin{p114t_name(site,"borrow_rfc_bit"),N111U64{},"shr",p114t_local(site,"borrow_word"),N111Const{63,0}},
     N111Bin{p114t_name(site,"borrow_is_rfc"),N111U64{},"ne",p114t_local(site,"borrow_rfc_bit"),N111Const{0,0}},
     N111If{p114t_local(site,"borrow_is_rfc"),p128bf_rfc(site),[]},
     N111Bin{p114t_name(site,"borrow_field_bytes"),N111U64{},"shl",p114t_local(site,"borrow_location"),N111Const{3,0}},
     N111Offset{p114t_name(site,"borrow_fields"),p114t_local(site,"borrow_heap"),p114t_local(site,"borrow_field_bytes")}],
    nt_append(N111Stmt,p128bf_fields(buffer,count,site,0),[N111Set{dest,N111U64{},N111Const{count,0}}]))

# Preserve the complete previous rendering path, including Phase126 Nat and
# Phase114 transport templates. Calling this directly on the fallback prevents
# recursively expanding the same import inside its own slow branch.
@unsafe
def p128bf_previous(+stmt: N111Stmt, +ids: N111Ids, +code: P111QCode) -> P111QCode:
  match code:
    case P111QCode{chunks,next,terminal,error}:
      nt_choose(P111QCode,Bool.not(terminal) && String.is_empty(error),
        u => p126nt_emit(stmt,ids,code,p126nt_expand(stmt,next)),u => p126nt_previous_stmt(stmt,ids,code))

@unsafe
def p128bf_join(+stmt: N111Stmt, +ids: N111Ids, +label: U32, fast: P111QCode) -> P111QCode:
  match fast:
    case P111QCode{+chunks,n,terminal,error}:
      +prefix = nt_choose(List<&2,String>,terminal,u => chunks,u => Con{"jmp " ++ p111q_label(U32.add(label,2)) ++ "\n",chunks})
      p111q_if_done(label,terminal,p128bf_previous(stmt,ids,
        P111QCode{Con{p111q_label(U32.inc(label)) ++ "\n",prefix},n,False{},error}))

@unsafe
def p128bf_branch(+stmt: N111Stmt, +read: P128BFRead, +ids: N111Ids, +site: U32, +code: P111QCode) -> P111QCode:
  match read code:
    case P128BFRead{dest,term,buffer,ctor,count} P111QCode{chunks,n,terminal,error}:
      p128bf_join(stmt,ids,n,p111q_stmts(p128bf_fast(dest,buffer,count,site),ids,
        P111QCode{Con{p111q_label(n) ++ "\n",Con{"jnz " ++ p111q_value(p114t_local(site,"borrow_guard"),ids) ++ ", " ++
          p111q_label(n) ++ ", " ++ p111q_label(U32.inc(n)) ++ "\n",chunks}},U32.add(n,3),False{},error}))
    case _ _: p128bf_previous(stmt,ids,code)

@unsafe
def p128bf_selected(+stmt: N111Stmt, +read: P128BFRead, +ids: N111Ids, +code: P111QCode) -> P111QCode:
  match read code:
    case P128BFRead{dest,term,buffer,ctor,count} P111QCode{chunks,next,terminal,error}:
      p128bf_branch(stmt,read,ids,next,
        p111q_stmts(p128bf_guard(term,ctor,next),ids,P111QCode{chunks,U32.inc(next),terminal,error}))
    case _ _: p128bf_previous(stmt,ids,code)

@unsafe
def p111q_stmt(+stmt: N111Stmt, +ids: N111Ids, +code: P111QCode) -> P111QCode:
  match code:
    case P111QCode{chunks,next,terminal,error}:
      nt_choose(P111QCode,Bool.not(terminal) && String.is_empty(error),
        u => p128bf_selected(stmt,p128bf_match(stmt,ids,next),ids,code),u => p128bf_previous(stmt,ids,code))
