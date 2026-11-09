# Post-verification cold-constructor allocation for the selected serial CPU
# runtime, ABI 11102. The constructor ID table is derived from the same
# verified P111Program as its descriptor: missing cold metadata is not cold.
# The runtime's bind still validates the program before any segment executes.

@unsafe
def p185cc_known(+ctor: String, +count: U32, ids: N111Ids) -> Bool:
  match ids:
    case N111Ids{functions,constructors}:
      +entry = index_find(constructors,ctor,index_hash(ctor,2166136261),32)
      +meta = dt(entry)
      String.eq(dk(entry),"N111Id") && U32.is_lt(da(entry),65536) && U32.is_eq(dx(entry),count) &&
        String.eq(tg(meta),"P185Constructor") && U32.is_eq(qt(meta),11102) && U32.is_eq(ix(meta),0)

@unsafe
def p185cc_class(+count: U32) -> U32:
  nt_choose(U32,U32.is_eq(count,1),u => 0,u => nt_choose(U32,U32.is_eq(count,2),v => 1,v => 2))

# p111_program is the immutable descriptor passed by the emitted main to
# p111_rt_main. Its fixed offsets are checked independently of the state
# layout. Capability 8 authorizes unsealed cold publication; bit 1 requires
# the selected sequential host ABI (LANE_STEP=1).
@unsafe
def p185cc_guard(+site: U32) -> List<&2,N111Stmt>:
  [N111Load{p114t_name(site,"cold_abi"),N111U64{},N111Symbol{"p111_program"},0},
   N111Load{p114t_name(site,"cold_descriptor"),N111U64{},N111Symbol{"p111_program"},8},
   N111Load{p114t_name(site,"cold_caps"),N111U64{},N111Symbol{"p111_program"},88},
   N111Bin{p114t_name(site,"cold_abi_ok"),N111U64{},"eq",p114t_local(site,"cold_abi"),N111Const{11102,0}},
   N111Bin{p114t_name(site,"cold_descriptor_ok"),N111U64{},"eq",p114t_local(site,"cold_descriptor"),N111Const{192,0}},
   N111Bin{p114t_name(site,"cold_caps_bits"),N111U64{},"and",p114t_local(site,"cold_caps"),N111Const{9,0}},
   N111Bin{p114t_name(site,"cold_caps_ok"),N111U64{},"eq",p114t_local(site,"cold_caps_bits"),N111Const{9,0}},
   N111Bin{p114t_name(site,"cold_layout_ok"),N111U32{},"and",p114t_local(site,"cold_abi_ok"),p114t_local(site,"cold_descriptor_ok")},
   N111Bin{p114t_name(site,"cold_guard"),N111U32{},"and",p114t_local(site,"cold_layout_ok"),p114t_local(site,"cold_caps_ok")}]

@unsafe
def p185cc_reads(+buffer: String, +count: U32, +site: U32, +index: U32) -> List<&2,N111Stmt>:
  nt_choose(List<&2,N111Stmt>,U32.is_eq(index,count),u => [],u =>
    Con{N111Load{p114t_name(site,"cold_field_" ++ U32.show(index)),N111U64{},N111Local{buffer},U32.mul(index,8)},
      p185cc_reads(buffer,count,site,U32.inc(index))})

@unsafe
def p185cc_writes(+count: U32, +site: U32, +index: U32) -> List<&2,N111Stmt>:
  nt_choose(List<&2,N111Stmt>,U32.is_eq(index,count),u => [],u =>
    Con{N111Store{N111U64{},p114t_local(site,"cold_fields"),U32.mul(index,8),p114t_local(site,"cold_field_" ++ U32.show(index))},
      p185cc_writes(count,site,U32.inc(index))})

# The nonempty heap_alloc branch is copied exactly: pop mem[head] and remove
# 2^class words from ALC_LEN. Snapshot verified stack scratch before mutation;
# no field is retained, sunk, sealed, or reordered relative to another field.
# No allocator miss, shared cell, or hot publication is admitted here.
@unsafe
def p185cc_fast(+dest: String, +ctor: String, +buffer: String, +count: U32, +site: U32) -> List<&2,N111Stmt>:
  +cls = p185cc_class(count)
  nt_append(N111Stmt,
    [N111Load{p114t_name(site,"cold_heap"),N111Ptr{},N111Local{"state"},0},
     N111Bin{p114t_name(site,"cold_bytes"),N111U64{},"shl",p114t_local(site,"cold_head"),N111Const{3,0}},
     N111Offset{p114t_name(site,"cold_fields"),p114t_local(site,"cold_heap"),p114t_local(site,"cold_bytes")},
     N111Load{p114t_name(site,"cold_next"),N111U64{},p114t_local(site,"cold_fields"),0},
     N111Load{p114t_name(site,"cold_length"),N111U64{},p114t_local(site,"cold_allocator"),U32.mul(U32.add(32,cls),8)}],
    nt_append(N111Stmt,p185cc_reads(buffer,count,site,0),
      nt_append(N111Stmt,
        [N111Store{N111U64{},p114t_local(site,"cold_allocator"),U32.mul(cls,8),p114t_local(site,"cold_next")},
         N111Bin{p114t_name(site,"cold_remaining"),N111U64{},"sub",p114t_local(site,"cold_length"),N111Const{nt_choose(U32,U32.is_le(count,2),u => count,u => 4),0}},
         N111Store{N111U64{},p114t_local(site,"cold_allocator"),U32.mul(U32.add(32,cls),8),p114t_local(site,"cold_remaining")}],
        nt_append(N111Stmt,p185cc_writes(count,site,0),
          [N111Bin{p114t_name(site,"cold_cid"),N111U64{},"shl",N111CtorId{ctor},N111Const{40,0}},
           N111Bin{p114t_name(site,"cold_tag"),N111U64{},"or",p114t_local(site,"cold_cid"),N111Const{0,33554432}},
           N111Bin{dest,N111U64{},"or",p114t_local(site,"cold_tag"),p114t_local(site,"cold_head")}]))))

@unsafe
def p185cc_cached(+stmt: N111Stmt, dest: String, ctor: String, buffer: String, +count: U32, +site: U32) -> List<&2,N111Stmt>:
  [N111Load{p114t_name(site,"cold_allocator"),N111Ptr{},N111Local{"state"},8},
   N111Load{p114t_name(site,"cold_head"),N111U64{},p114t_local(site,"cold_allocator"),U32.mul(p185cc_class(count),8)},
   N111Bin{p114t_name(site,"cold_nonempty"),N111U64{},"ne",p114t_local(site,"cold_head"),N111Const{0,0}},
   N111If{p114t_local(site,"cold_nonempty"),p185cc_fast(dest,ctor,buffer,count,site),[stmt]}]

# This structured expansion is shared by QBE and direct x86. Its original
# call remains the slow branch at both guards. The caller renders each
# generated statement once, so that slow call is never recursively expanded.
@unsafe
def p185cc_expand(+stmt: N111Stmt, +ids: N111Ids, +site: U32) -> P114TExpansion:
  match stmt:
    case N111Call{+dest,N111U64{},+symbol,
      Con{N111Arg{N111Ptr{},N111Local{+state}},
      Con{N111Arg{N111U32{},N111CtorId{+ctor}},
      Con{N111Arg{N111Ptr{},N111Local{+buffer}},
      Con{N111Arg{N111U32{},N111Const{+count,+high}},Nil{}}}}}}:
        nt_choose(P114TExpansion,String.eq(symbol,"p111_rt_ctor") && String.eq(state,"state") &&
          U32.is_eq(high,0) && U32.is_ge(count,1) && U32.is_le(count,4) &&
          p114t_buffer(buffer) && p185cc_known(ctor,count,ids) && U32.is_le(site,4294967200),
          u => P114TExpansion{p185cb_construct(stmt,dest,ctor,buffer,count,ids,site),True{}},
          u => P114TExpansion{[stmt],False{}})
    case _: P114TExpansion{[stmt],False{}}

@unsafe
def p185cc_previous(+stmt: N111Stmt, +ids: N111Ids, +code: P111QCode) -> P111QCode:
  match code:
    case P111QCode{chunks,next,terminal,error}:
      nt_choose(P111QCode,Bool.not(terminal) && String.is_empty(error),
        u => p128bf_selected(stmt,p128bf_match(stmt,ids,next),ids,code),u => p128bf_previous(stmt,ids,code))

@unsafe
def p185cc_join(+label: U32, no: List<&2,N111Stmt>, ids: N111Ids, yes: P111QCode) -> P111QCode:
  match yes:
    case P111QCode{+chunks,n,+terminal,error}:
      +prefix = nt_choose(List<&2,String>,terminal,u => chunks,u => Con{"jmp " ++ p111q_label(U32.add(label,2)) ++ "\n",chunks})
      p111q_if_done(label,terminal,p185cc_words(no,ids,
        P111QCode{Con{p111q_label(U32.inc(label)) ++ "\n",prefix},n,False{},error}))

@unsafe
def p185cc_word(+stmt: N111Stmt, +ids: N111Ids, +code: P111QCode) -> P111QCode:
  match stmt code:
    case N111If{condition,yes,no} P111QCode{chunks,+n,terminal,error}:
      p185cc_join(n,no,ids,p185cc_words(yes,ids,
        P111QCode{Con{p111q_label(n) ++ "\n",Con{"jnz " ++ p111q_value(condition,ids) ++ ", " ++
          p111q_label(n) ++ ", " ++ p111q_label(U32.inc(n)) ++ "\n",chunks}},U32.add(n,3),False{},error}))
    case _ _: p185cc_previous(stmt,ids,code)

@unsafe
def p185cc_words(body: List<&2,N111Stmt>, +ids: N111Ids, code: P111QCode) -> P111QCode:
  match body:
    case Nil{}: code
    case Con{stmt,rest}: p185cc_words(rest,ids,p185cc_word(stmt,ids,code))

@unsafe
def p185cc_emitted(+stmt: N111Stmt, +ids: N111Ids, +code: P111QCode, expansion: P114TExpansion) -> P111QCode:
  match code expansion:
    case P111QCode{chunks,next,terminal,error} P114TExpansion{+body,+changed}:
      nt_choose(P111QCode,changed,
        u => p185cc_words(body,ids,P111QCode{chunks,U32.inc(next),terminal,error}),
        u => p185cc_previous(stmt,ids,code))

@unsafe
def p185cc_stmt(+stmt: N111Stmt, +ids: N111Ids, +code: P111QCode) -> P111QCode:
  match code:
    case P111QCode{chunks,+next,+terminal,+error}:
      nt_choose(P111QCode,Bool.not(terminal) && String.is_empty(error),
        u => p185cc_emitted(stmt,ids,code,p185cc_expand(stmt,ids,next)),
        u => p185cc_previous(stmt,ids,code))
