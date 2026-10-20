@unsafe
def p113n_canonical(+book: List<&2,KDef>, +ty: KTerm) -> Bool:
  +head = nq_layout_type(book,ty)
  +owner = lookup(book,"Nat")
  p98_tag_eq(head,"ADT") && String.eq(nm(head),"Nat") && String.eq(dk(owner),"ADT") && db(owner) && U32.is_eq(da(owner),0) &&
    List.is_empty(&2,String,rm(head)) && List.is_empty(&2,KTerm,ks(head))

@unsafe
def p113n_type_kind(+book: List<&2,KDef>, +ty: KTerm) -> N_WordKind:
  nt_choose(N_WordKind,p113n_canonical(book,ty),u => N_Imm64{},u => nf_scalar_kind(book,ty))

@unsafe
def p113n_primitive(+name: String) -> Bool:
  nb_contains(["u32_to_nat","nat_add","nat_sub","nat_mul","nat_double"],name)

@unsafe
def p113n_constructor(+book: List<&2,KDef>, +name: String, +arity: U32) -> Bool:
  p113n_canonical(book,kt("ADT","Nat",0,0,[])) && j_u32_native_ctor(book,"Nat",name) &&
    ((String.eq(name,"Zero") && U32.is_eq(arity,0)) || (String.eq(name,"Succ") && U32.is_eq(arity,1)))

# Only a closed, unparameterized constructor telescope is used for additional
# field facts. Generic/dependent specialization remains the mature mask's job.
@unsafe
def p113n_ctor_end(+book: List<&2,KDef>, +ty: KTerm, +left: U32) -> KTerm:
  nt_choose(KTerm,U32.is_eq(left,0),u => nq_layout_type(book,ty),
    u => p113n_ctor_end_head(book,nq_layout_type(book,ty),left))

@unsafe
def p113n_ctor_end_head(+book: List<&2,KDef>, +head: KTerm, +left: U32) -> KTerm:
  nt_choose(KTerm,p98_tag_eq(head,"All") && U32.is_eq(terms_len(ks(head)),2),
    u => p113n_ctor_end(book,kid(head,1),U32.sub(left,1)),u => atom("Absent"))

@unsafe
def p113n_closed_owner(+book: List<&2,KDef>, +end: KTerm) -> Bool:
  +owner = lookup(book,nm(end))
  p98_tag_eq(end,"ADT") && String.eq(dk(owner),"ADT") && U32.is_eq(da(owner),0) &&
    List.is_empty(&2,String,rm(end)) && List.is_empty(&2,KTerm,ks(end))

@unsafe
def p113n_field_kinds(+book: List<&2,KDef>, +name: String, +count: U32) -> List<&2,N_WordKind>:
  +d = nc_find_ctor(book,nc_ctor_display(name))
  nt_choose(List<&2,N_WordKind>,String.eq(dk(d),"Ctr") && U32.is_le(da(d),8),
    u => nt_choose(List<&2,N_WordKind>,String.eq(name,nc_ctor_identity(book,dn(d))) &&
      U32.is_eq(count,nc_live_count(book,dt(d),da(d))) && p113n_closed_owner(book,p113n_ctor_end(book,dt(d),da(d))),
      v => nf_kind_tele(book,dt(d),count,32),v => nf_opaque_kinds(count)),
    u => nf_opaque_kinds(count))

def p113n_at(kinds: List<&2,N_WordKind>, +index: U32) -> N_WordKind:
  match kinds:
    case Nil{}: N_W64{}
    case Con{head,rest}: nt_choose(N_WordKind,U32.is_eq(index,0),u => head,u => p113n_at(rest,U32.sub(index,1)))

def p113n_is_imm(kind: N_WordKind) -> Bool:
  match kind:
    case N_Imm64{}: True{}
    case _: False{}

@unsafe
def p113n_field_kind(+book: List<&2,KDef>, +mat: KTerm, +count: U32, +index: U32) -> N_WordKind:
  nt_choose(N_WordKind,p98_tag_eq(mat,"Mat") && U32.is_eq(ix(mat),U32.inc(count)) && U32.is_le(count,8) && U32.is_lt(index,count) && U32.is_lt(qt(mat),U32.shln(1,U32.to_nat(count))),
    u => p113n_at(p113n_field_kinds(book,nm(mat),count),index),u => N_W64{})

# Preserve the mature scalar mask for every field not proved Imm64. This
# helper does not promote an unknown ordinary Term to a nonowning value.
@unsafe
def p113n_field_binding(+book: List<&2,KDef>, +mat: KTerm, +count: U32, +index: U32, +n: U32) -> NC_Binding:
  nt_choose(NC_Binding,p113n_is_imm(p113n_field_kind(book,mat,count,index)),
    u => NC_Binding{nc_id(U32.add(n,index)),"v_" ++ U32.show(nc_id(U32.add(n,index))),N_Imm64{}},
    u => nk_field_binding(nc_id(U32.add(n,index)),p113df_mask(mat,count),index))

# Exact incumbent classifier, used after the two Nat constructor cases.
@unsafe
def p113n_original_value_kind(+book: List<&2,KDef>, +value: KTerm, +env: List<&2,NC_Binding>) -> N_WordKind:
  nt_choose(N_WordKind, p98_tag_eq(value,"Var") || p98_tag_eq(value,"NWord"),
    u => nk_value(value,env),
    u => nt_choose(N_WordKind, p98_tag_eq(value,"NOp"),
      v => p113_primitive_kind(nm(value),terms_len(ks(value))),
      v => nt_choose(N_WordKind, p98_tag_eq(value,"App"),
        w => p113_application_kind(book,value,nd_native_call(book,value)),
        w => nt_choose(N_WordKind, p98_tag_eq(value,"Ref"),
          z => p113_callee_kind(book,value,0), z => N_W64{}))))
