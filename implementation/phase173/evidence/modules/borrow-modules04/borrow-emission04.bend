# Phase173 revision04: authenticated per-constructor hot publication.
# Exact CPU11101 single heap-mutator template. No runtime imports are added.
# Fast arm keeps a uniquely owned record and its preserved fields in place.
# Shared/static ownership, unknown effects and unproved layouts use original IR.

law p173b_replacement_step:
  for +slots: List<&2,P173BSlot>
  for +width: U32
  for +index: U32
  for +site: U32
  for origin: P173BOrigin
  List<&2,N111Stmt>

@unsafe
def p173b_name(+site: U32, role: String) -> String:
  p114t_name(site,"p173borrow_" ++ role)

@unsafe
def p173b_ref(site: U32, role: String) -> N111Value:
  N111Local{p173b_name(site,role)}

@unsafe
def p173b_original(body: List<&2,P113DStmt>) -> List<&2,N111Stmt>:
  match body:
    case Nil{}: []
    case Con{P113DScalar{stmt},rest}: Con{stmt,p173b_original(rest)}
    case Con{P113DResult{Con{value,Nil{}}},Nil{}}: [N111Return{value}]
    case _: []

@unsafe
def p173b_decode(+root: N111Value, +site: U32) -> List<&2,N111Stmt>:
  [N111Bin{p173b_name(site,"root_loc"),N111U64{},"and",root,N111Const{4294967295,255}},
   N111If{p173b_ref(site,"raw"),[
     N111Set{p173b_name(site,"source"),N111U64{},p173b_ref(site,"root_loc")},
     N111Set{p173b_name(site,"unique"),N111U32{},N111Const{1,0}}],[
     N111Bin{p173b_name(site,"rfc_bytes"),N111U64{},"shl",p173b_ref(site,"root_loc"),N111Const{3,0}},
     N111Offset{p173b_name(site,"rfc_at"),p173b_ref(site,"heap"),p173b_ref(site,"rfc_bytes")},
     N111Load{p173b_name(site,"rfc_cell"),N111U64{},p173b_ref(site,"rfc_at"),0},
     N111Bin{p173b_name(site,"source"),N111U64{},"shr",p173b_ref(site,"rfc_cell"),N111Const{24,0}},
     N111Bin{p173b_name(site,"rfc_count"),N111U64{},"and",p173b_ref(site,"rfc_cell"),N111Const{16777215,0}},
     N111Bin{p173b_name(site,"unique"),N111U64{},"eq",p173b_ref(site,"rfc_count"),N111Const{1,0}}]},
   N111Bin{p173b_name(site,"dynamic"),N111U64{},"uge",p173b_ref(site,"source"),p173b_ref(site,"heap_min")},
   N111Bin{p173b_name(site,"owned"),N111U32{},"and",p173b_ref(site,"dynamic"),p173b_ref(site,"unique")},
   N111Bin{p173b_name(site,"source_bytes"),N111U64{},"shl",p173b_ref(site,"source"),N111Const{3,0}},
   N111Offset{p173b_name(site,"fields"),p173b_ref(site,"heap"),p173b_ref(site,"source_bytes")}]

@unsafe
def p173b_guard_start(+root: N111Value, +ctor: String, +site: U32, +hot: Bool) -> List<&2,N111Stmt>:
  [N111Set{p173b_name(site,"ok"),N111U32{},N111Const{0,0}},
   N111Load{p173b_name(site,"heap"),N111Ptr{},N111Local{"state"},0},
   N111Load{p173b_name(site,"static_words"),N111U64{},N111Symbol{"p111_program"},64},
   N111Bin{p173b_name(site,"heap_min"),N111U64{},"add",p173b_ref(site,"static_words"),N111Const{127,0}},
   N111Bin{p173b_name(site,"heap_min"),N111U64{},"and",p173b_ref(site,"heap_min"),N111Const{4294967168,4294967295}},
   N111Bin{p173b_name(site,"heap_min"),N111U64{},"add",p173b_ref(site,"heap_min"),N111Const{51413504,0}},
   N111Bin{p173b_name(site,"tag"),N111U64{},"shr",root,N111Const{56,0}},
   N111Bin{p173b_name(site,"raw"),N111U64{},"eq",p173b_ref(site,"tag"),N111Const{2,0}},
   N111Bin{p173b_name(site,"rfc"),N111U64{},"eq",p173b_ref(site,"tag"),N111Const{130,0}},
   N111Bin{p173b_name(site,"typed"),N111U32{},"or",p173b_ref(site,"raw"),p173b_ref(site,"rfc")},
   N111Bin{p173b_name(site,"cid"),N111U64{},"shr",root,N111Const{40,0}},
   N111Bin{p173b_name(site,"cid"),N111U64{},"and",p173b_ref(site,"cid"),N111Const{65535,0}},
   N111Bin{p173b_name(site,"cid_ok"),N111U64{},"eq",p173b_ref(site,"cid"),N111CtorId{ctor}},
   N111Bin{p173b_name(site,"typed"),N111U32{},"and",p173b_ref(site,"typed"),p173b_ref(site,"cid_ok")},
   N111Load{p173b_name(site,"capabilities"),N111U64{},N111Symbol{"p111_program"},88},
   N111Bin{p173b_name(site,"cold_mode"),N111U64{},"and",p173b_ref(site,"capabilities"),N111Const{8,0}},
   N111Bin{p173b_name(site,"ordinary_publication"),N111U64{},"eq",p173b_ref(site,"cold_mode"),N111Const{0,0}},
   N111Bin{p173b_name(site,"ordinary_publication"),N111U32{},"or",p173b_ref(site,"ordinary_publication"),N111Const{Bool.to_u32(hot),0}},
   N111Bin{p173b_name(site,"typed"),N111U32{},"and",p173b_ref(site,"typed"),p173b_ref(site,"ordinary_publication")} ]

@unsafe
def p173b_and_guard(+site: U32, role: String) -> N111Stmt:
  N111Bin{p173b_name(site,"ok"),N111U32{},"and",p173b_ref(site,"ok"),p173b_ref(site,role)}

# Guard every untouched field against a missing seal, independently of the
# program's optional cold-constructor publication policy.
@unsafe
def p173b_preserved_guard(+index: U32, +site: U32) -> List<&2,N111Stmt>:
  [N111Load{p173b_name(site,"old_" ++ U32.show(index)),N111U64{},p173b_ref(site,"fields"),U32.mul(index,8)},
   N111Bin{p173b_name(site,"field_tag"),N111U64{},"shr",p173b_ref(site,"old_" ++ U32.show(index)),N111Const{56,0}},
   N111Bin{p173b_name(site,"field_ok"),N111U64{},"ne",p173b_ref(site,"field_tag"),N111Const{2,0}},
   p173b_and_guard(site,"field_ok")]

# Original scalar drops can be omitted by ordinary lowering. Such a field may
# be overwritten only after proving that the omitted sink would be a no-op.
@unsafe
def p173b_trivial_guard(+index: U32, +site: U32) -> List<&2,N111Stmt>:
  +value = p173b_ref(site,"old_" ++ U32.show(index))
  [N111Load{p173b_name(site,"old_" ++ U32.show(index)),N111U64{},p173b_ref(site,"fields"),U32.mul(index,8)},
   N111Bin{p173b_name(site,"old_tag"),N111U64{},"shr",value,N111Const{56,0}},
   N111Bin{p173b_name(site,"old_tag"),N111U64{},"and",p173b_ref(site,"old_tag"),N111Const{127,0}},
   N111Bin{p173b_name(site,"old_small"),N111U64{},"ule",p173b_ref(site,"old_tag"),N111Const{1,0}},
   N111Bin{p173b_name(site,"old_hole"),N111U64{},"eq",value,N111Const{4294967295,4294967295}},
   N111Bin{p173b_name(site,"old_loc"),N111U64{},"and",value,N111Const{4294967295,255}},
   N111Bin{p173b_name(site,"old_static"),N111U64{},"ult",p173b_ref(site,"old_loc"),p173b_ref(site,"heap_min")},
   N111Bin{p173b_name(site,"old_ok"),N111U32{},"or",p173b_ref(site,"old_small"),p173b_ref(site,"old_hole")},
   N111Bin{p173b_name(site,"old_ok"),N111U32{},"or",p173b_ref(site,"old_ok"),p173b_ref(site,"old_static")},
   p173b_and_guard(site,"old_ok")]

# keep(raw dynamic CTR) creates RFC count2; sinking that returned wrapper
# decrements it to1 and therefore implements seal without a new runtime import.
# keep(raw static CTR) is a no-op, so that case deliberately uses the original.
@unsafe
def p173b_new_guard(+value: N111Value, +site: U32) -> List<&2,N111Stmt>:
  [N111Bin{p173b_name(site,"new_tag"),N111U64{},"shr",value,N111Const{56,0}},
   N111Bin{p173b_name(site,"new_sealed"),N111U64{},"ne",p173b_ref(site,"new_tag"),N111Const{2,0}},
   N111Bin{p173b_name(site,"new_loc"),N111U64{},"and",value,N111Const{4294967295,255}},
   N111Bin{p173b_name(site,"new_dynamic"),N111U64{},"uge",p173b_ref(site,"new_loc"),p173b_ref(site,"heap_min")},
   N111Bin{p173b_name(site,"new_ok"),N111U32{},"or",p173b_ref(site,"new_sealed"),p173b_ref(site,"new_dynamic")},
   p173b_and_guard(site,"new_ok")]

@unsafe
def p173b_slot_guards(slots: List<&2,P173BSlot>, +drops: List<&2,U32>, +site: U32) -> List<&2,N111Stmt>:
  match slots:
    case Nil{}: []
    case Con{P173BSlot{+index,origin},rest}:
      match origin:
        case P173BField{old}:
          nt_append(N111Stmt,p173b_preserved_guard(index,site),p173b_slot_guards(rest,drops,site))
        case P173BExternal{value}:
          nt_append(N111Stmt,nt_choose(List<&2,N111Stmt>,p173b_has(index,drops),
            u => [N111Load{p173b_name(site,"old_" ++ U32.show(index)),N111U64{},p173b_ref(site,"fields"),U32.mul(index,8)}],
            u => p173b_trivial_guard(index,site)),
            nt_append(N111Stmt,p173b_new_guard(value,site),p173b_slot_guards(rest,drops,site)))
        case P173BInvalid{}: []

@unsafe
def p173b_guard(+root: N111Value, +ctor: String, +slots: List<&2,P173BSlot>,
  +drops: List<&2,U32>, +site: U32, +hot: Bool) -> List<&2,N111Stmt>:
  nt_append(N111Stmt,p173b_guard_start(root,ctor,site,hot),[
    N111If{p173b_ref(site,"typed"),nt_append(N111Stmt,p173b_decode(root,site),[
      N111If{p173b_ref(site,"owned"),Con{N111Set{p173b_name(site,"ok"),N111U32{},N111Const{1,0}},
        p173b_slot_guards(slots,drops,site)},[]}]),[]}])

@unsafe
def p173b_sinks(drops: List<&2,U32>, +site: U32) -> List<&2,N111Stmt>:
  match drops:
    case Nil{}: []
    case Con{index,rest}:
      Con{N111Call{p173b_name(site,"sink"),N111U64{},"p111_rt_sink",[
        p111_state(),p111_word(p173b_ref(site,"old_" ++ U32.show(index)))]},p173b_sinks(rest,site)}

@unsafe
def p173b_replace(+index: U32, +value: N111Value, +site: U32) -> List<&2,N111Stmt>:
  +sealed = p173b_ref(site,"sealed_" ++ U32.show(index))
  [N111Bin{p173b_name(site,"replace_tag"),N111U64{},"shr",value,N111Const{56,0}},
   N111Bin{p173b_name(site,"replace_raw"),N111U64{},"eq",p173b_ref(site,"replace_tag"),N111Const{2,0}},
   N111If{p173b_ref(site,"replace_raw"),[
     N111Call{p173b_name(site,"sealed_" ++ U32.show(index)),N111U64{},"p111_rt_keep",[p111_state(),p111_word(value)]},
     N111Call{p173b_name(site,"unkeep"),N111U64{},"p111_rt_sink",[p111_state(),p111_word(sealed)]}],
     [N111Set{p173b_name(site,"sealed_" ++ U32.show(index)),N111U64{},value}]},
   N111Store{N111U64{},p173b_ref(site,"fields"),U32.mul(index,8),sealed}]

@unsafe
def p173b_replacements(+slots: List<&2,P173BSlot>, +width: U32, +index: U32, +site: U32) -> List<&2,N111Stmt>:
  nt_choose(List<&2,N111Stmt>,U32.is_eq(index,width),u => [],u =>
    p173b_replacement_step(slots,width,index,site,p173b_slot(index,slots)))

@unsafe
def p173b_replacement_step(slots, width, index, site, origin):
  match origin:
    case P173BExternal{value}:
      nt_append(N111Stmt,p173b_replace(index,value,site),p173b_replacements(slots,width,U32.inc(index),site))
    case _: p173b_replacements(slots,width,U32.inc(index),site)

# N111Id.native carries the checked constructor hot bit; unsafe is presence.
# Numeric identity and arity retain their original meanings. Unknown/legacy
# metadata never grants the hot exemption. Both tables originate in the same
# independently verified P111Program constructor list.
@unsafe
def p173bh_hot(+ctor: String, +width: U32, ids: N111Ids) -> Bool:
  match ids:
    case N111Ids{functions,constructors}:
      +entry = index_find(constructors,ctor,index_hash(ctor,2166136261),32)
      String.eq(dk(entry),"N111Id") && U32.is_lt(da(entry),65536) &&
        U32.is_eq(dx(entry),width) && du(entry) && db(entry)

@unsafe
def p173b_template(plan: P173BPlan, original: List<&2,P113DStmt>, +ids: N111Ids, +site: U32) -> List<&2,N111Stmt>:
  match plan:
    case P173BPlan{+root,+ctor,+width,+slots,+drops}:
      nt_append(N111Stmt,p173b_guard(root,ctor,slots,drops,site,p173bh_hot(ctor,width,ids)),[
        N111If{p173b_ref(site,"ok"),nt_append(N111Stmt,p173b_sinks(drops,site),
          nt_append(N111Stmt,p173b_replacements(slots,width,0,site),[N111Return{root}])),p173b_original(original)}])
    case P173BNone{}: p173b_original(original)

# Exact previous dispatcher; its recursive calls enter the selected dispatcher
# again, allowing a guarded update at a nested tail without changing other code.
@unsafe
def p173b_previous(+body: List<&2,P113DStmt>, +params: List<&2,NC_Binding>, +ids: N111Ids, +code: P111QCode) -> P111QCode:
  match body code:
    case Nil{} _: code
    case Con{head,rest} P111QCode{chunks,next,terminal,+error}:
      nt_choose(P111QCode,String.is_empty(error),u =>
        nt_choose(P111QCode,terminal,u => p111q_problem("statement follows direct transfer",code),
          u => p113w_look(head,rest,params,ids,code)),u => code)

@unsafe
def p173b_selected(+body: List<&2,P113DStmt>, +params: List<&2,NC_Binding>, +ids: N111Ids,
  +code: P111QCode, +plan: P173BPlan) -> P111QCode:
  match code:
    case P111QCode{chunks,+next,terminal,error}:
      nt_choose(P111QCode,Bool.not(terminal) && String.is_empty(error) &&
        U32.is_le(next,4294966200) && p173b_profitable(plan),
        u => p111q_stmts(p173b_template(plan,body,ids,next),ids,P111QCode{chunks,U32.inc(next),terminal,error}),
        u => p173b_previous(body,params,ids,code))

@unsafe
def p173b_stmts(body, params, ids, code):
  p173b_selected(body,params,ids,code,p173b_plan(body,ids))
