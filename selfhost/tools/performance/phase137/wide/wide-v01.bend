# Bounded wider borrowed records. Runtime, late field template and all
# protected verifier declarations remain unchanged. Exact-width import
# projection delegates pointer/capacity checks to the original final verifier.

@unsafe
def nol_fields(+book: List<&2, KDef>, +ty: KTerm, +tel: KTerm, +left: U32, +seen: List<&2, U32>) -> KTerm:
  +head = nq_layout_type(book, tel)
  nt_choose(KTerm, U32.is_eq(left, 0),
    u => nt_choose(KTerm, p98_tag_eq(head, "ADT") && p88_string_eq(nm(head), nm(ty)) && List.is_empty(&2, String, rm(head)) && Bool.not(nq_layout_dep(head, seen)) && norm_exact_lists(ks(head), ks(ty)), v => kt("NO_Types", "", 0, 0, Nil{}), v => nol_error("indexed constructor result")),
    u => nt_choose(KTerm, p98_tag_eq(head, "All") && Bool.not(U32.is_eq(qt(head), 0)) && U32.is_le(left, 16),
      v => nol_field(book, ty, head, nq_layout_type(book, kid(head, 0)), left, seen), v => nol_error("constructor telescope")))

# Module: src/back/native/observer-layout.bend:41

@unsafe
def nol_ctor_fields(+book: List<&2, KDef>, +ty: KTerm, +ctr: KDef) -> KTerm:
  nt_choose(KTerm, nol_owner(book, ty) && p88_string_eq(dk(ctr), "Ctr") && U32.is_eq(dx(ctr), 0) && U32.is_le(da(ctr), 16),
    u => nol_fields(book, ty, nq_layout_specialize(dt(ctr), ks(ty), 64), da(ctr), Nil{}),
    u => nol_error("constructor descriptor"))

# Module: src/back/native/observer-layout.bend:57

@unsafe
def p131rg_width(+width: U32) -> Bool:
  U32.is_eq(width,0) || (U32.is_ge(width,2) && U32.is_le(width,16))



@unsafe
def p118b_project_borrow(+name: String, +typ: N111Type, +args: List<&2,N111Arg>, +ids: N111Ids) -> P113DCode:
  +ctor = p111v_target(p111v_arg(args,3),ids,True{})
  +count = p111v_literal(p111v_arg(args,4))
  +ok = p118b_arg_types(args,[3,2,3,1,1]) && U32.is_eq(p111v_type(typ),2) &&
    Bool.not(String.eq(dk(ctor),"Absent")) && U32.is_eq(da(ctor),count) &&
    U32.is_ge(count,2) && U32.is_le(count,16)
  +projected : N111Stmt = N111Call{name,typ,"p111_rt_take",[
    p111_state(),p111_word(p111v_arg(args,1)),N111Arg{N111Ptr{},p111v_arg(args,2)},p111_u32(count)]}
  nt_choose(P113DCode,ok && p111v_state_argument(args),
    u => P113DCode{[P113DScalar{projected}],0,"",[]},
    u => p113d_fail("borrowed import: constructor/count contract",0))


