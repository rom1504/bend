# Isolated v2 of P186-004: same guards and ordered field/cache writes as v1,
# with a single fallback call after the nested admission tests. Not hooked.
# The private flag starts at zero and changes only after the fast path has
# completed its writes. The final branch assigns status on success. Guard misses
# leave runtime storage and the
# destination untouched, then execute the original call with original operands.
# Reserved destination/word names decline; normal late hygiene reserves p114t_.
# Destination aliases of word, state, or scratch remain read-before-write:
# no original operand is read after the successful status assignment.

@unsafe
def p186uv_cache(+stmt: N111Stmt, dest: String, buffer: String, +count: U32, +site: U32) -> List<&2,N111Stmt>:
  [N111Load{p114t_name(site,"take_allocator"),N111Ptr{},N111Local{"state"},8},
   N111Load{p114t_name(site,"take_length"),N111U64{},p114t_local(site,"take_allocator"),U32.mul(U32.add(32,p185cc_class(count)),8)},
   N111Bin{p114t_name(site,"take_length_after"),N111U64{},"add",p114t_local(site,"take_length"),N111Const{nt_choose(U32,U32.is_le(count,2),u => count,u => 4),0}},
   N111Bin{p114t_name(site,"take_cached"),N111U64{},"ult",p114t_local(site,"take_length_after"),N111Const{32768,0}},
   N111If{p114t_local(site,"take_cached"),nt_append(N111Stmt,p186ut_fast(p114t_name(site,"take_result"),buffer,count,site),[N111Set{p114t_name(site,"take_succeeded"),N111U32{},N111Const{1,0}}]),[]}]

# HEAP_OFF is STAT_OFF + PAGE_UP(static_words); STAT_OFF=51413504,
# PAGE_LEN=128 for the selected runtime. Static locations are never freed.
@unsafe
def p186uv_heap(+stmt: N111Stmt, dest: String, buffer: String, count: U32, +site: U32) -> List<&2,N111Stmt>:
  [N111Bin{p114t_name(site,"take_loc"),N111U64{},"and",p114t_local(site,"take_word"),N111Const{4294967295,255}},
   N111Load{p114t_name(site,"take_static"),N111U64{},N111Symbol{"p111_program"},64},
   N111Bin{p114t_name(site,"take_rounded"),N111U64{},"add",p114t_local(site,"take_static"),N111Const{127,0}},
   N111Bin{p114t_name(site,"take_pages"),N111U64{},"and",p114t_local(site,"take_rounded"),N111Const{4294967168,4294967295}},
   N111Bin{p114t_name(site,"take_heap_start"),N111U64{},"add",p114t_local(site,"take_pages"),N111Const{51413504,0}},
   N111Bin{p114t_name(site,"take_dynamic"),N111U64{},"uge",p114t_local(site,"take_loc"),p114t_local(site,"take_heap_start")},
   N111If{p114t_local(site,"take_dynamic"),p186uv_cache(stmt,dest,buffer,count,site),[]}]

# N111 has no byte load. On AMD64, loading four in-bounds bytes ending at CID
# and shifting by 24 exactly reads its arity byte. CIDs 0..2 conservatively
# fall back; no byte after the constructor table is ever read.
@unsafe
def p186uv_arity(+stmt: N111Stmt, dest: String, buffer: String, +count: U32, +site: U32) -> List<&2,N111Stmt>:
  [N111Load{p114t_name(site,"take_arities"),N111Ptr{},N111Symbol{"p111_program"},128},
   N111Bin{p114t_name(site,"take_arity_start"),N111U64{},"sub",p114t_local(site,"take_cid"),N111Const{3,0}},
   N111Offset{p114t_name(site,"take_arity_address"),p114t_local(site,"take_arities"),p114t_local(site,"take_arity_start")},
   N111Load{p114t_name(site,"take_arity_word"),N111U32{},p114t_local(site,"take_arity_address"),0},
   N111Bin{p114t_name(site,"take_arity"),N111U32{},"shr",p114t_local(site,"take_arity_word"),N111Const{24,0}},
   N111Bin{p114t_name(site,"take_arity_ok"),N111U32{},"eq",p114t_local(site,"take_arity"),N111Const{count,0}},
   N111If{p114t_local(site,"take_arity_ok"),p186uv_heap(stmt,dest,buffer,count,site),[]}]

@unsafe
def p186uv_guard(+stmt: N111Stmt, +dest: String, word: N111Value, buffer: String, +count: U32, +site: U32) -> List<&2,N111Stmt>:
  [N111Set{p114t_name(site,"take_succeeded"),N111U32{},N111Const{0,0}},
   N111Set{p114t_name(site,"take_word"),N111U64{},word},
   N111Bin{p114t_name(site,"take_tag"),N111U64{},"shr",p114t_local(site,"take_word"),N111Const{56,0}},
   N111Bin{p114t_name(site,"take_unique"),N111U64{},"eq",p114t_local(site,"take_tag"),N111Const{2,0}},
   N111Bin{p114t_name(site,"take_aux"),N111U64{},"shr",p114t_local(site,"take_word"),N111Const{40,0}},
   N111Bin{p114t_name(site,"take_cid"),N111U64{},"and",p114t_local(site,"take_aux"),N111Const{65535,0}},
   N111Load{p114t_name(site,"take_ctor_count"),N111U64{},N111Symbol{"p111_program"},24},
   N111Bin{p114t_name(site,"take_cid_low"),N111U64{},"uge",p114t_local(site,"take_cid"),N111Const{3,0}},
   N111Bin{p114t_name(site,"take_cid_high"),N111U64{},"ult",p114t_local(site,"take_cid"),p114t_local(site,"take_ctor_count")},
   N111Bin{p114t_name(site,"take_cid_valid"),N111U32{},"and",p114t_local(site,"take_cid_low"),p114t_local(site,"take_cid_high")},
   N111Bin{p114t_name(site,"take_shape"),N111U32{},"and",p114t_local(site,"take_unique"),p114t_local(site,"take_cid_valid")},
   N111If{p114t_local(site,"take_shape"),p186uv_arity(stmt,dest,buffer,count,site),[]},
   N111If{p114t_local(site,"take_succeeded"),[N111Set{dest,N111U64{},N111Const{count,0}}],[stmt]}]

@unsafe
def p186uv_expand(+stmt: N111Stmt, +site: U32) -> P114TExpansion:
  match stmt:
    case N111Call{+dest,N111U64{},+symbol,
      Con{N111Arg{N111Ptr{},N111Local{+state}},
      Con{N111Arg{N111U64{},+word},
      Con{N111Arg{N111Ptr{},N111Local{+buffer}},
      Con{N111Arg{N111U32{},N111Const{+count,+high}},Nil{}}}}}}:
        nt_choose(P114TExpansion,String.eq(symbol,"p111_rt_take") && String.eq(state,"state") &&
          U32.is_eq(high,0) && U32.is_ge(count,1) && U32.is_le(count,4) &&
          Bool.not(String.starts_with(dest,"p114t_")) && p186ut_word(word) && p114t_buffer(buffer) && U32.is_le(site,4294967200),
          u => P114TExpansion{p186uv_guard(stmt,dest,word,buffer,count,site),True{}},
          u => P114TExpansion{[stmt],False{}})
    case _: P114TExpansion{[stmt],False{}}

# This optional wrapper is not installed by the prototype. The coordinator
# selects it after controls and a separate timing screen. Generated fallbacks
# bypass this recognizer through p186rt_words' previous renderer.
@unsafe
def p186uv_emitted(+stmt: N111Stmt, +ids: N111Ids, +code: P111QCode, expansion: P114TExpansion) -> P111QCode:
  match code expansion:
    case P111QCode{chunks,next,terminal,error} P114TExpansion{+body,+changed}:
      nt_choose(P111QCode,changed,u => p186rt_words(body,ids,P111QCode{chunks,U32.inc(next),terminal,error}),
        u => p186rt_stmt(stmt,ids,code))

@unsafe
def p186uv_stmt(+stmt: N111Stmt, +ids: N111Ids, +code: P111QCode) -> P111QCode:
  match code:
    case P111QCode{chunks,+next,+terminal,+error}:
      nt_choose(P111QCode,Bool.not(terminal) && String.is_empty(error),
        u => p186uv_emitted(stmt,ids,code,p186uv_expand(stmt,next)),u => p186rt_stmt(stmt,ids,code))
