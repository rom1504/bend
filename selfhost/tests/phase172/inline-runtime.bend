# Experimental post-verification warm-pool, cold-constructor template.
# ABI: P111Program11101, ordinary CPU runtime, one heap mutator, no GPU.
# Dynamic failure calls the unchanged helper before any mutation.

@unsafe
def p172ir_previous(+stmt: N111Stmt, +ids: N111Ids, +code: P111QCode) -> P111QCode:
  match code:
    case P111QCode{chunks,next,terminal,error}:
      nt_choose(P111QCode,Bool.not(terminal) && String.is_empty(error),
        u => p128bf_selected(stmt,p128bf_match(stmt,ids,next),ids,code),
        u => p128bf_previous(stmt,ids,code))

@unsafe
def p172ir_cold(+ctor: String, +count: U32, ids: N111Ids) -> Bool:
  match ids:
    case N111Ids{functions,constructors}:
      +entry = index_find(constructors,ctor,index_hash(ctor,2166136261),32)
      String.eq(dk(entry),"N111Id") && U32.is_lt(da(entry),65536) &&
        U32.is_eq(dx(entry),count) && du(entry) && Bool.not(db(entry))

@unsafe
def p172ir_admit(+symbol: String, +state: String, +buffer: String,
  +ctor: String, +count: U32, +ids: N111Ids, +site: U32) -> Bool:
  nt_choose(Bool,String.eq(symbol,"p111_rt_ctor") && String.eq(state,"state") &&
    U32.is_ge(count,1) && U32.is_le(count,4) && U32.is_le(site,4294967200),
    u => p114t_buffer(buffer) && p172ir_cold(ctor,count,ids),u => False{})

@unsafe
def p172ir_class(+count: U32) -> U32:
  nt_choose(U32,U32.is_eq(count,1),u => 0,
    u => nt_choose(U32,U32.is_eq(count,2),v => 1,v => 2))

@unsafe
def p172ir_words(+count: U32) -> U32:
  nt_choose(U32,U32.is_eq(count,1),u => 1,
    u => nt_choose(U32,U32.is_eq(count,2),v => 2,v => 4))

# Only descriptor, state and allocator loads occur before this guard. In
# particular H[head] is never loaded when the pool is empty.
@unsafe
def p172ir_guard(+count: U32, +site: U32) -> List<&2,N111Stmt>:
  [N111Load{p114t_name(site,"p172_caps"),N111U64{},N111Symbol{"p111_program"},88},
   N111Bin{p114t_name(site,"p172_cold_cap"),N111U64{},"and",p114t_local(site,"p172_caps"),N111Const{8,0}},
   N111Bin{p114t_name(site,"p172_cap_ok"),N111U64{},"ne",p114t_local(site,"p172_cold_cap"),N111Const{0,0}},
   N111Load{p114t_name(site,"p172_heap"),N111Ptr{},N111Local{"state"},0},
   N111Load{p114t_name(site,"p172_pool"),N111Ptr{},N111Local{"state"},8},
   N111Load{p114t_name(site,"p172_head"),N111U64{},p114t_local(site,"p172_pool"),U32.mul(p172ir_class(count),8)},
   N111Bin{p114t_name(site,"p172_pool_ok"),N111U64{},"ne",p114t_local(site,"p172_head"),N111Const{0,0}},
   N111Bin{p114t_name(site,"p172_guard"),N111U32{},"and",p114t_local(site,"p172_cap_ok"),p114t_local(site,"p172_pool_ok")}]

# Preserve the runtime's ordered field load/store pairs. The final verifier
# established that this is an authentic local alloca, disjoint from the heap.
@unsafe
def p172ir_fields(+buffer: String, +count: U32, +site: U32, +index: U32) -> List<&2,N111Stmt>:
  nt_choose(List<&2,N111Stmt>,U32.is_eq(index,count),u => [],u =>
    Con{N111Load{p114t_name(site,"p172_field_" ++ U32.show(index)),N111U64{},N111Local{buffer},U32.mul(index,8)},
    Con{N111Store{N111U64{},p114t_local(site,"p172_fields"),U32.mul(index,8),p114t_local(site,"p172_field_" ++ U32.show(index))},
      p172ir_fields(buffer,count,site,U32.inc(index))}})

# heap_alloc's warm arm, then exactly the capability8/cold publication arm.
# There is no free, refcount operation, allocation miss, heap_hand or error
# operation on this path. All such behavior remains in the unchanged fallback.
@unsafe
def p172ir_fast(+dest: String, +buffer: String, +ctor: String, +count: U32, +site: U32) -> List<&2,N111Stmt>:
  nt_append(N111Stmt,
    [N111Bin{p114t_name(site,"p172_bytes"),N111U64{},"shl",p114t_local(site,"p172_head"),N111Const{3,0}},
     N111Offset{p114t_name(site,"p172_fields"),p114t_local(site,"p172_heap"),p114t_local(site,"p172_bytes")},
     N111Load{p114t_name(site,"p172_next"),N111U64{},p114t_local(site,"p172_fields"),0},
     N111Store{N111U64{},p114t_local(site,"p172_pool"),U32.mul(p172ir_class(count),8),p114t_local(site,"p172_next")},
     N111Load{p114t_name(site,"p172_length"),N111U64{},p114t_local(site,"p172_pool"),U32.mul(U32.add(32,p172ir_class(count)),8)},
     N111Bin{p114t_name(site,"p172_length"),N111U64{},"sub",p114t_local(site,"p172_length"),N111Const{p172ir_words(count),0}},
     N111Store{N111U64{},p114t_local(site,"p172_pool"),U32.mul(U32.add(32,p172ir_class(count)),8),p114t_local(site,"p172_length")}],
    nt_append(N111Stmt,p172ir_fields(buffer,count,site,0),
      [N111Bin{p114t_name(site,"p172_meta"),N111U64{},"shl",N111CtorId{ctor},N111Const{40,0}},
       N111Bin{p114t_name(site,"p172_meta"),N111U64{},"or",p114t_local(site,"p172_meta"),N111Const{0,33554432}},
       N111Bin{dest,N111U64{},"or",p114t_local(site,"p172_meta"),p114t_local(site,"p172_head")}]))

# Keep fallback rendering out of p111q_stmt so it cannot re-expand itself.
@unsafe
def p172ir_join(+stmt: N111Stmt, +ids: N111Ids, +label: U32, fast: P111QCode) -> P111QCode:
  match fast:
    case P111QCode{+chunks,n,terminal,error}:
      +prefix = nt_choose(List<&2,String>,terminal,u => chunks,
        u => Con{"jmp " ++ p111q_label(U32.add(label,2)) ++ "\n",chunks})
      p111q_if_done(label,terminal,p172ir_previous(stmt,ids,
        P111QCode{Con{p111q_label(U32.inc(label)) ++ "\n",prefix},n,False{},error}))

@unsafe
def p172ir_branch(+stmt: N111Stmt, +dest: String, +buffer: String, +ctor: String,
  +count: U32, +ids: N111Ids, +site: U32, code: P111QCode) -> P111QCode:
  match code:
    case P111QCode{chunks,n,terminal,error}:
      p172ir_join(stmt,ids,n,p111q_stmts(p172ir_fast(dest,buffer,ctor,count,site),ids,
        P111QCode{Con{p111q_label(n) ++ "\n",Con{"jnz " ++
          p111q_value(p114t_local(site,"p172_guard"),ids) ++ ", " ++ p111q_label(n) ++ ", " ++
          p111q_label(U32.inc(n)) ++ "\n",chunks}},U32.add(n,3),False{},error}))

@unsafe
def p172ir_constructor(+stmt: N111Stmt, +dest: String, +buffer: String, +ctor: String,
  +count: U32, +ids: N111Ids, +code: P111QCode) -> P111QCode:
  match code:
    case P111QCode{chunks,next,terminal,error}:
      p172ir_branch(stmt,dest,buffer,ctor,count,ids,next,
        p111q_stmts(p172ir_guard(count,next),ids,P111QCode{chunks,U32.inc(next),terminal,error}))

@unsafe
def p172ir_emit(stmt, ids, code):
  match stmt code:
    case N111Call{+dest,N111U64{},+symbol,
      Con{N111Arg{N111Ptr{},N111Local{+state}},
      Con{N111Arg{N111U32{},N111CtorId{+ctor}},
      Con{N111Arg{N111Ptr{},N111Local{+buffer}},
      Con{N111Arg{N111U32{},N111Const{+count,0}},Nil{}}}}}} P111QCode{chunks,next,terminal,error}:
      nt_choose(P111QCode,Bool.not(terminal) && String.is_empty(error) &&
        p172ir_admit(symbol,state,buffer,ctor,count,ids,next),
        u => p172ir_constructor(stmt,dest,buffer,ctor,count,ids,code),
        u => p172ir_previous(stmt,ids,code))
    case _ _: p172ir_previous(stmt,ids,code)
