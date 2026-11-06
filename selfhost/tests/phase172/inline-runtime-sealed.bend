# The cold-only hypothesis has zero coverage on the installed compiler.
# This variant admits any verified ordinary constructor whose fields need no
# rfc_seal work. It needs neither capability8 nor a cold constructor table.
# Dependencies p172ir_previous/class/words are shared with the retained variant.

@unsafe
def p172is_admit(+symbol: String, +state: String, +buffer: String,
  +ctor: String, +count: U32, +ids: N111Ids, +site: U32) -> Bool:
  nt_choose(Bool,String.eq(symbol,"p111_rt_ctor") && String.eq(state,"state") &&
    U32.is_ge(count,1) && U32.is_le(count,4) && U32.is_le(site,4294967200),
    u => p114t_buffer(buffer) && p128bf_known(ctor,count,ids),u => False{})

# rfc_seal returns unchanged iff tag!=TAG_CTR or RFC. Equivalently, the upper
# byte is not2. It is130 for an RFC constructor, not2. Read each authenticated
# local payload once and retain it until the allocation guard resolves.
@unsafe
def p172is_field_guard(+buffer: String, +count: U32, +site: U32, +index: U32) -> List<&2,N111Stmt>:
  nt_choose(List<&2,N111Stmt>,U32.is_eq(index,count),u => [],u =>
    nt_append(N111Stmt,
      [N111Load{p114t_name(site,"p172_field_" ++ U32.show(index)),N111U64{},N111Local{buffer},U32.mul(index,8)},
       N111Bin{p114t_name(site,"p172_tag_" ++ U32.show(index)),N111U64{},"shr",p114t_local(site,"p172_field_" ++ U32.show(index)),N111Const{56,0}},
       N111Bin{p114t_name(site,"p172_sealed_" ++ U32.show(index)),N111U64{},"ne",p114t_local(site,"p172_tag_" ++ U32.show(index)),N111Const{2,0}},
       N111Bin{p114t_name(site,"p172_fields_ok"),N111U32{},"and",p114t_local(site,"p172_fields_ok"),p114t_local(site,"p172_sealed_" ++ U32.show(index))}],
      p172is_field_guard(buffer,count,site,U32.inc(index))))

@unsafe
def p172is_guard(+buffer: String, +count: U32, +site: U32) -> List<&2,N111Stmt>:
  nt_append(N111Stmt,[N111Set{p114t_name(site,"p172_fields_ok"),N111U32{},N111Const{1,0}}],
    nt_append(N111Stmt,p172is_field_guard(buffer,count,site,0),
      [N111Load{p114t_name(site,"p172_heap"),N111Ptr{},N111Local{"state"},0},
       N111Load{p114t_name(site,"p172_pool"),N111Ptr{},N111Local{"state"},8},
       N111Load{p114t_name(site,"p172_head"),N111U64{},p114t_local(site,"p172_pool"),U32.mul(p172ir_class(count),8)},
       N111Bin{p114t_name(site,"p172_pool_ok"),N111U64{},"ne",p114t_local(site,"p172_head"),N111Const{0,0}},
       N111Bin{p114t_name(site,"p172_guard"),N111U32{},"and",p114t_local(site,"p172_fields_ok"),p114t_local(site,"p172_pool_ok")}]))

@unsafe
def p172is_stores(+count: U32, +site: U32, +index: U32) -> List<&2,N111Stmt>:
  nt_choose(List<&2,N111Stmt>,U32.is_eq(index,count),u => [],u =>
    Con{N111Store{N111U64{},p114t_local(site,"p172_fields"),U32.mul(index,8),p114t_local(site,"p172_field_" ++ U32.show(index))},
      p172is_stores(count,site,U32.inc(index))})

@unsafe
def p172is_fast(+dest: String, +ctor: String, +count: U32, +site: U32) -> List<&2,N111Stmt>:
  nt_append(N111Stmt,
    [N111Bin{p114t_name(site,"p172_bytes"),N111U64{},"shl",p114t_local(site,"p172_head"),N111Const{3,0}},
     N111Offset{p114t_name(site,"p172_fields"),p114t_local(site,"p172_heap"),p114t_local(site,"p172_bytes")},
     N111Load{p114t_name(site,"p172_next"),N111U64{},p114t_local(site,"p172_fields"),0},
     N111Store{N111U64{},p114t_local(site,"p172_pool"),U32.mul(p172ir_class(count),8),p114t_local(site,"p172_next")},
     N111Load{p114t_name(site,"p172_length"),N111U64{},p114t_local(site,"p172_pool"),U32.mul(U32.add(32,p172ir_class(count)),8)},
     N111Bin{p114t_name(site,"p172_length"),N111U64{},"sub",p114t_local(site,"p172_length"),N111Const{p172ir_words(count),0}},
     N111Store{N111U64{},p114t_local(site,"p172_pool"),U32.mul(U32.add(32,p172ir_class(count)),8),p114t_local(site,"p172_length")}],
    nt_append(N111Stmt,p172is_stores(count,site,0),
      [N111Bin{p114t_name(site,"p172_meta"),N111U64{},"shl",N111CtorId{ctor},N111Const{40,0}},
       N111Bin{p114t_name(site,"p172_meta"),N111U64{},"or",p114t_local(site,"p172_meta"),N111Const{0,33554432}},
       N111Bin{dest,N111U64{},"or",p114t_local(site,"p172_meta"),p114t_local(site,"p172_head")}]))

@unsafe
def p172is_branch(+stmt: N111Stmt, +dest: String, +ctor: String,
  +count: U32, +ids: N111Ids, +site: U32, code: P111QCode) -> P111QCode:
  match code:
    case P111QCode{chunks,n,terminal,error}:
      p172ir_join(stmt,ids,n,p111q_stmts(p172is_fast(dest,ctor,count,site),ids,
        P111QCode{Con{p111q_label(n) ++ "\n",Con{"jnz " ++
          p111q_value(p114t_local(site,"p172_guard"),ids) ++ ", " ++ p111q_label(n) ++ ", " ++
          p111q_label(U32.inc(n)) ++ "\n",chunks}},U32.add(n,3),False{},error}))

@unsafe
def p172is_constructor(+stmt: N111Stmt, +dest: String, +buffer: String, +ctor: String,
  +count: U32, +ids: N111Ids, +code: P111QCode) -> P111QCode:
  match code:
    case P111QCode{chunks,next,terminal,error}:
      p172is_branch(stmt,dest,ctor,count,ids,next,
        p111q_stmts(p172is_guard(buffer,count,next),ids,P111QCode{chunks,U32.inc(next),terminal,error}))

@unsafe
def p172is_emit(stmt, ids, code):
  match stmt code:
    case N111Call{+dest,N111U64{},+symbol,
      Con{N111Arg{N111Ptr{},N111Local{+state}},
      Con{N111Arg{N111U32{},N111CtorId{+ctor}},
      Con{N111Arg{N111Ptr{},N111Local{+buffer}},
      Con{N111Arg{N111U32{},N111Const{+count,0}},Nil{}}}}}} P111QCode{chunks,next,terminal,error}:
      nt_choose(P111QCode,Bool.not(terminal) && String.is_empty(error) &&
        p172is_admit(symbol,state,buffer,ctor,count,ids,next),
        u => p172is_constructor(stmt,dest,buffer,ctor,count,ids,code),
        u => p172ir_previous(stmt,ids,code))
    case _ _: p172ir_previous(stmt,ids,code)
