

def p113ft_scalar(kind: N_WordKind) -> Bool:
  match kind:
    case N_W32{}: True{}
    case _: False{}


def p113ft_box(kind: N_WordKind) -> Bool:
  match kind:
    case N_Box{}: True{}
    case _: False{}


@unsafe
def p113ft_row(+name: String, good: Bool) -> String:
  nt_choose(String,good,u => "PASS " ++ name,u => "FAIL " ++ name)


@unsafe
def p113ft_op(+name: String, +arity: U32) -> Bool:
  p113ft_scalar(p113_value_kind([],kt("NOp",name,0,0,nc_prim_args(arity,0)),[]))


def p113ft_type(name: String) -> KTerm:
  kt("ADT",name,0,0,[])


def p113ft_owner(name: String, builtin: Bool) -> KDef:
  KDef{name,"ADT",0,0,{KTerm{"Data", "", 0, 0, Nil{}, Nil{}, 0, 0} : KTerm},{KTerm{"Absent", "", 0, 0, Nil{}, Nil{}, 0, 0} : KTerm},[],builtin,False{}}


@unsafe
def p113ft_book(+result: KTerm, builtin: Bool) -> List<&2,KDef>:
  [p113ft_owner("U32",builtin),p113ft_owner("F32",True{}),p113ft_owner("Bool",True{}),p113ft_owner("Char",True{}),
   KDef{"probe","Def",1,0,kt("All","x",7,1,[p113ft_type("U32"),result]),k_lam("x",7,1,[var("",7)],0,0,False{}),[],False{},False{}}]


@unsafe
def p113ft_call(+book: List<&2,KDef>, +arity: U32, +mode: U32) -> Bool:
  p113ft_scalar(p113_value_kind(book,nd_reapply(kt("Ref","probe",0,mode,[]),nc_prim_args(arity,0)),[]))


@unsafe
def p113ft_native(+builtin: Bool, +arity: U32, +mode: U32) -> Bool:
  +d : KDef = KDef{"U32.add","Def",2,0,
    kt("All","x",1,1,[p113ft_type("U32"),kt("All","y",2,1,[p113ft_type("U32"),p113ft_type("String")])]),
    k_lam("x",1,1,[k_lam("y",2,1,[var("",1)],0,0,False{})],0,0,False{}),[],builtin,False{}}
  p113ft_scalar(p113_value_kind([p113ft_owner("U32",True{}),d],nd_reapply(kt("Ref","U32.add",0,mode,[]),nc_prim_args(arity,0)),[]))


@unsafe
def p113ft_zero() -> Bool:
  +d : KDef = KDef{"constant","Def",0,0,p113ft_type("Bool"),kt("NWord","1",0,0,[]),[],False{},False{}}
  p113ft_scalar(p113_value_kind([p113ft_owner("Bool",True{}),d],kt("Ref","constant",0,0,[]),[]))


@unsafe
def p113ft_foreign() -> Bool:
  +d : KDef = KDef{"probe","Def",1,0,kt("All","x",7,1,[p113ft_type("U32"),p113ft_type("U32")]),{KTerm{"Foreign", "", 0, 0, Nil{}, Nil{}, 0, 0} : KTerm},[],False{},False{}}
  p113ft_call([p113ft_owner("U32",True{}),d],1,0)


@unsafe
def p113ft_keep(+value: KTerm) -> U32:
  nt_count(N111Stmt,p111_keep([p113_binding([],9,value,[])],nu_add(NU_Empty{},9)))


def p113ft_drop_count(parts: P111Partition) -> U32:
  match parts:
    case P111Partition{live,drop}: nt_count(N111Stmt,drop)


@unsafe
def p113ft_drop(+value: KTerm) -> U32:
  p113ft_drop_count(p111_partition([p113_binding([],9,value,[])],NU_Empty{}))


def p113ft_binding_shape(binding: NC_Binding) -> Bool:
  match binding:
    case NC_Binding{id,word,kind}: U32.is_eq(id,9) && String.eq(word,"v_9") && p113ft_scalar(kind)


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
    u => p113n_ctor_end(book,kid(head,1),U32.sub(left,1)),u => {KTerm{"Absent", "", 0, 0, Nil{}, Nil{}, 0, 0} : KTerm})


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


@unsafe
def p113nt_type() -> KTerm:
  kt("ADT","Nat",0,0,[])


@unsafe
def p113nt_book(+builtin: Bool) -> List<&2,KDef>:
  +nat = p113nt_type()
  +succ : KDef = KDef{"Succ","Ctr",1,0,kt("All","pred",7,1,[nat,nat]),{KTerm{"Absent", "", 0, 0, Nil{}, Nil{}, 0, 0} : KTerm},[],builtin,False{}}
  +zero : KDef = KDef{"Zero","Ctr",0,0,nat,{KTerm{"Absent", "", 0, 0, Nil{}, Nil{}, 0, 0} : KTerm},[],builtin,False{}}
  [KDef{"Nat","ADT",0,0,{KTerm{"Data", "", 0, 0, Nil{}, Nil{}, 0, 0} : KTerm},{KTerm{"Absent", "", 0, 0, Nil{}, Nil{}, 0, 0} : KTerm},[zero,succ],builtin,False{}},
   KDef{"probe","Def",1,0,kt("All","n",7,1,[nat,nat]),k_lam("n",7,1,[var("",7)],0,0,False{}),[],False{},False{}}]


@unsafe
def p113nt_kind(+name: String, +count: U32) -> N_WordKind:
  p113_value_kind([],kt("NOp",name,0,0,nc_prim_args(count,0)),[])


@unsafe
def p113nt_seed(+builtin: Bool, +arity: U32) -> N_WordKind:
  nk_kind(nc_id(10),nk_typed_bindings(nd_entry_params(arity,10),nf_worker_kinds(p113nt_book(builtin),"probe",arity)))


@unsafe
def p113nt_call(+builtin: Bool, +count: U32) -> N_WordKind:
  p113_value_kind(p113nt_book(builtin),nd_reapply(kt("Ref","probe",0,0,[]),nc_prim_args(count,0)),[])


@unsafe
def p113nt_captured() -> N_WordKind:
  nk_kind(7,nc_live_uses([NC_Binding{7,"v_7",N_Imm64{}}],nu_add(NU_Empty{},7)))


@unsafe
def p113nt_field(+builtin: Bool, +count: U32, +index: U32) -> N_WordKind:
  p113n_field_kind(p113nt_book(builtin),kt("Mat","Succ",2,0,[]),count,index)


@unsafe
def p113nt_keep(kind: N_WordKind) -> U32:
  nt_count(N111Stmt,p111_keep([NC_Binding{7,"v_7",kind}],nu_add(NU_Empty{},7)))


@unsafe
def p113nt_drop(kind: N_WordKind) -> U32:
  p113ft_drop_count(p111_partition([NC_Binding{7,"v_7",kind}],NU_Empty{}))

# The same full-width constant must survive each structured return unchanged.


@unsafe
def p113nt_u64(+lo: U32, +hi: U32) -> Bool:
  p113nt_return_shape(p111_return(N111Const{lo,hi},0),lo,hi)


@unsafe
def p113nt_return_shape(code: P111Code, +lo: U32, +hi: U32) -> Bool:
  match code:
    case P111Code{Con{N111Store{N111U64{},N111Local{base},0,N111Const{a,b}},rest},segments,fresh,error}:
      String.eq(base,"scratch") && U32.is_eq(a,lo) && U32.is_eq(b,hi)
    case _: False{}


@unsafe
def p113nm_eligible(+book: List<&2,KDef>, +mat: KTerm, +count: U32) -> Bool:
  p98_tag_eq(mat,"Mat") && String.eq(nm(mat),"Succ") && U32.is_eq(ix(mat),2) &&
    U32.is_eq(qt(mat),0) && U32.is_eq(terms_len(ks(mat)),2) && U32.is_eq(count,1) &&
    p113n_constructor(book,"Succ",1)


@unsafe
def p113nm_take(+book: List<&2,KDef>, +mat: KTerm, +word: N111Value, +count: U32, +n: U32) -> List<&2,N111Stmt>:
  nt_choose(List<&2,N111Stmt>,p113nm_eligible(book,mat,count),
    u => [N111Bin{"v_" ++ U32.show(nc_id(n)),N111U64{},"sub",word,N111Const{1,0}}],
    u => p111_take(nm(mat),word,count,n))


@unsafe
def p113k_bits(+value: U32, +bits: U32) -> U32:
  nt_choose(U32,U32.is_eq(value,0),u => bits,u => p113k_bits(U32.shr(value),U32.inc(bits)))


@unsafe
def p113k_exact(+lo: U32, +hi: U32) -> P113KFact:
  P113KFact{nt_choose(U32,U32.is_eq(hi,0),u => p113k_bits(lo,0),u => U32.add(32,p113k_bits(hi,0))),True{},lo,hi}


@unsafe
def p113k_bound(+bits: U32) -> P113KFact:
  nt_choose(P113KFact,U32.is_eq(bits,0),u => p113k_exact(0,0),u => P113KFact{U32.min(bits,64),False{},0,0})


@unsafe
def p113k_get(+facts: KDef, +name: String) -> P113KFact:
  +record = p111v_get(facts,name)
  nt_choose(P113KFact,String.eq(dk(record),"P113KFact"),
    u => P113KFact{da(record),U32.is_eq(dx(record),1),ix(dv(record)),qt(dv(record))},
    u => p113k_bound(64))


@unsafe
def p113k_put(+facts: KDef, +name: String, fact: P113KFact) -> KDef:
  match fact:
    case P113KFact{bits,exact,lo,hi}:
      index_set(facts,KDef{name,"P113KFact",bits,Bool.to_u32(exact),kt("Epoch","",U32.inc(p113l_version(facts,name)),0,[]),kt("P113KValue","",lo,hi,[]),[],False{},False{}},index_hash(name,2166136261),32)

@unsafe
def p113k_value(value: N111Value, +facts: KDef) -> P113KFact:
  match value:
    case N111Const{lo,hi}: p113k_exact(lo,hi)
    case N111Local{name}: p113k_get(facts,name)
    case _: p113k_bound(64)


@unsafe
def p113k_atom(+value: N111Value, fact: P113KFact) -> N111Value:
  match fact:
    case P113KFact{bits,+exact,lo,hi}: nt_choose(N111Value,exact,u => N111Const{lo,hi},u => value)


@unsafe
def p113k_replace(+value: N111Value, +facts: KDef) -> N111Value:
  p113k_atom(value,p113k_value(value,facts))


@unsafe
def p113k_values(values: List<&2,N111Value>, +facts: KDef) -> List<&2,N111Value>:
  match values:
    case Nil{}: []
    case Con{value,rest}: Con{p113k_replace(value,facts),p113k_values(rest,facts)}


@unsafe
def p113k_args(args: List<&2,N111Arg>, +facts: KDef) -> List<&2,N111Arg>:
  match args:
    case Nil{}: []
    case Con{N111Arg{N111Ptr{},value},rest}: Con{N111Arg{N111Ptr{},value},p113k_args(rest,facts)}
    case Con{N111Arg{typ,value},rest}: Con{N111Arg{typ,p113k_replace(value,facts)},p113k_args(rest,facts)}


@unsafe
def p113k_kill(names: List<&2,String>, facts: KDef) -> KDef:
  match names:
    case Nil{}: facts
    case Con{name,rest}: p113k_kill(rest,p113k_put(facts,name,p113k_bound(64)))


@unsafe
def p113k_join_fact(left: P113KFact, right: P113KFact) -> P113KFact:
  match left right:
    case P113KFact{+lb,+le,+ll,+lh} P113KFact{+rb,+re,+rl,+rh}:
      nt_choose(P113KFact,le && re && U32.is_eq(ll,rl) && U32.is_eq(lh,rh),
        u => p113k_exact(ll,lh),u => P113KFact{U32.max(lb,rb),False{},U32.and(ll,rl),U32.and(lh,rh)})

@unsafe
def p113k_join_bucket(bucket: List<&2,KDef>, +right: KDef, out: KDef) -> KDef:
  match bucket:
    case Nil{}: out
    case Con{+head,rest}: p113k_join_bucket(rest,right,p113k_join_record(head,right,out))


@unsafe
def p113k_join_record(+record: KDef, +right: KDef, +out: KDef) -> KDef:
  +name = dn(record)
  +found = p111v_get(right,name)
  nt_choose(KDef,String.eq(dk(found),"P113KFact"),
    u => p113k_put(out,name,p113k_join_fact(P113KFact{da(record),U32.is_eq(dx(record),1),ix(dv(record)),qt(dv(record))},p113k_get(right,name))),
    u => out)


@unsafe
def p113k_join(left: KDef, +right: KDef, out: KDef) -> KDef:
  match left:
    case KIndexLeaf{hash,bucket}: p113k_join_bucket(bucket,right,out)
    case KIndexNode{hash,mask,a,b}: p113k_join(b,right,p113k_join(a,right,out))
    case _: out


@unsafe
def p113k_width(typ: N111Type) -> U32:
  match typ:
    case N111U32{}: 32
    case _: 64


@unsafe
def p113k_limit(fact: P113KFact, +width: U32) -> P113KFact:
  match fact:
    case P113KFact{+bits,+exact,+lo,+hi}:
      nt_choose(P113KFact,exact,u => p113k_exact(lo,nt_choose(U32,U32.is_eq(width,32),v => 0,v => hi)),
        u => P113KFact{U32.min(bits,width),False{},lo,nt_choose(U32,U32.is_eq(width,32),v => 0,v => hi)})

@unsafe
def p113k_shift(+left: P113KFact, +amount: U32, +right: Bool) -> P113KFact:
  match left:
    case P113KFact{+bits,+exact,+lo,+hi}:
      nt_choose(P113KFact,U32.is_eq(amount,0),u => left,u =>
      nt_choose(P113KFact,exact,
        u =>
      nt_choose(P113KFact,U32.is_lt(amount,32),
        u => nt_choose(P113KFact,right,
          v => p113k_exact(U32.or(U32.shrn(lo,U32.to_nat(amount)),U32.shln(hi,U32.to_nat(U32.sub(32,amount)))),U32.shrn(hi,U32.to_nat(amount))),
          v => p113k_exact(U32.shln(lo,U32.to_nat(amount)),U32.or(U32.shln(hi,U32.to_nat(amount)),U32.shrn(lo,U32.to_nat(U32.sub(32,amount)))))),
        u => nt_choose(P113KFact,right,
          v => p113k_exact(U32.shrn(hi,U32.to_nat(U32.sub(amount,32))),0),
          v => p113k_exact(0,U32.shln(lo,U32.to_nat(U32.sub(amount,32)))))),u => p113k_bound(nt_choose(U32,right,v => nt_choose(U32,U32.is_ge(amount,bits),w => 0,w => U32.sub(bits,amount)),v => U32.min(64,U32.add(bits,amount))))))


@unsafe
def p113k_unsigned(+op: String, +equal: Bool, +less: Bool) -> P113KFact:
  nt_choose(P113KFact,String.eq(op,"eq"),u => p113k_exact(Bool.to_u32(equal),0),u =>
  nt_choose(P113KFact,String.eq(op,"ne"),u => p113k_exact(Bool.to_u32(Bool.not(equal)),0),u =>
  nt_choose(P113KFact,String.eq(op,"ult"),u => p113k_exact(Bool.to_u32(less),0),u =>
  nt_choose(P113KFact,String.eq(op,"ule"),u => p113k_exact(Bool.to_u32(less || equal),0),u =>
  nt_choose(P113KFact,String.eq(op,"ugt"),u => p113k_exact(Bool.to_u32(Bool.not(less || equal)),0),u =>
  nt_choose(P113KFact,String.eq(op,"uge"),u => p113k_exact(Bool.to_u32(Bool.not(less)),0),u => p113k_bound(1)))))))


@unsafe
def p113k_compare(+op: String, +left: P113KFact, +right: P113KFact) -> P113KFact:
  nt_choose(P113KFact,p113k_zero(left) && p113l_ones(right),u => p113k_unsigned(op,False{},True{}),u =>
    nt_choose(P113KFact,p113l_ones(left) && p113k_zero(right),u => p113k_unsigned(op,False{},False{}),u => p113l_base_compare(op,left,right)))

@unsafe
def p113k_binary(+op: String, +left: P113KFact, +right: P113KFact, +width: U32) -> P113KFact:
  p113l_enrich(p113l_base_binary(op,left,right,width),op,left,right)

@unsafe
def p113k_bin_fact(+typ: N111Type, +op: String, left: P113KFact, right: P113KFact) -> P113KFact:
  +width = p113k_width(typ)
  p113k_limit(p113k_binary(op,p113k_limit(left,width),p113k_limit(right,width),width),width)


@unsafe
def p113k_ones(+bits: U32) -> U32:
  nt_choose(U32,U32.is_eq(bits,32),u => 4294967295,u => U32.sub(U32.shln(1,U32.to_nat(bits)),1))


@unsafe
def p113k_mask_covers(+bits: U32, mask: P113KFact) -> Bool:
  match mask:
    case P113KFact{mb,+exact,+lo,+hi}:
      exact && nt_choose(Bool,U32.is_le(bits,32),
        u => U32.is_eq(U32.and(lo,p113k_ones(bits)),p113k_ones(bits)),
        u => U32.is_eq(lo,4294967295) && U32.is_eq(U32.and(hi,p113k_ones(U32.sub(bits,32))),p113k_ones(U32.sub(bits,32))))


@unsafe
def p113k_bits_of(fact: P113KFact) -> U32:
  match fact:
    case P113KFact{bits,exact,lo,hi}: bits


@unsafe
def p113k_zero(fact: P113KFact) -> Bool:
  match fact:
    case P113KFact{bits,exact,lo,hi}: U32.is_eq(bits,0)


@unsafe
def p113k_result_type(+typ: N111Type, +op: String) -> N111Type:
  nt_choose(N111Type,p111v_comparison(op),u => N111U32{},u => typ)


@unsafe
def p113k_bin_stmt(+name: String, +typ: N111Type, +op: String, +left: N111Value, +right: N111Value, +lf: P113KFact, +rf: P113KFact, answer: P113KFact) -> N111Stmt:
  match answer:
    case P113KFact{bits,+exact,lo,hi}:
      nt_choose(N111Stmt,exact,u => N111Set{name,p113k_result_type(typ,op),N111Const{lo,hi}},u =>
      nt_choose(N111Stmt,(String.eq(op,"and") && p113k_mask_covers(p113k_bits_of(lf),rf)) ||
          ((String.eq(op,"or") || String.eq(op,"xor") || String.eq(op,"add") || String.eq(op,"sub")) && p113k_zero(rf)),
        u => N111Set{name,typ,left},u =>
      nt_choose(N111Stmt,(String.eq(op,"and") && p113k_mask_covers(p113k_bits_of(rf),lf)) ||
          ((String.eq(op,"or") || String.eq(op,"xor") || String.eq(op,"add")) && p113k_zero(lf)),
        u => N111Set{name,typ,right},u => N111Bin{name,typ,op,left,right})))


@unsafe
def p113k_scalar_append(prefix: List<&2,N111Stmt>, result: P113KScalar) -> P113KScalar:
  match result:
    case P113KScalar{body,facts}: P113KScalar{nt_append(N111Stmt,prefix,body),facts}


@unsafe
def p113k_scalar_next(result: P113KScalar, rest: List<&2,N111Stmt>) -> P113KScalar:
  match result:
    case P113KScalar{body,facts}: p113k_scalar_append(body,p113k_scalars(rest,facts))


@unsafe
def p113k_scalars(body: List<&2,N111Stmt>, facts: KDef) -> P113KScalar:
  match body:
    case Nil{}: P113KScalar{[],facts}
    case Con{stmt,rest}: p113k_scalar_next(p113k_scalar(stmt,facts),rest)


@unsafe
def p113k_scalar_bin(+name: String, +typ: N111Type, +op: String, +left: N111Value, +right: N111Value, +facts: KDef, +lf: P113KFact, +rf: P113KFact) -> P113KScalar:
  p123p_bin(name,typ,op,left,right,facts,lf,rf,p123p_pick(op,left,right,facts))

@unsafe
def p113k_scalar_join(condition: N111Value, yes: P113KScalar, no: P113KScalar) -> P113KScalar:
  match yes no:
    case P113KScalar{yb,yf} P113KScalar{nb,nf}: P113KScalar{[N111If{condition,yb,nb}],p113k_join(yf,nf,missing())}


@unsafe
def p113k_scalar_if(+condition: N111Value, +yes: List<&2,N111Stmt>, +no: List<&2,N111Stmt>, +facts: KDef, fact: P113KFact) -> P113KScalar:
  match fact:
    case P113KFact{bits,+exact,+lo,hi}:
      nt_choose(P113KScalar,exact,
        u => nt_choose(P113KScalar,U32.is_eq(lo,0),v => p113k_scalars(no,facts),v => p113k_scalars(yes,facts)),
        u => p113k_scalar_join(condition,p113k_scalars(yes,p113l_assume(facts,condition,True{})),p113k_scalars(no,p113l_assume(facts,condition,False{}))))

@unsafe
def p113k_scalar(+stmt: N111Stmt, +facts: KDef) -> P113KScalar:
  p113l_scalar_done(stmt,facts,p113l_base_scalar(stmt,facts))

@unsafe
def p113k_body_append(prefix: List<&2,P113DStmt>, result: P113KBody) -> P113KBody:
  match result:
    case P113KBody{body,facts,terminal}: P113KBody{nt_append(P113DStmt,prefix,body),facts,terminal}


@unsafe
def p113k_body_next(+result: P113KBody, +rest: List<&2,P113DStmt>) -> P113KBody:
  match result:
    case P113KBody{+body,+facts,+terminal}:
      nt_choose(P113KBody,terminal,u => result,u => p113k_body_append(body,p113k_body(rest,facts)))


@unsafe
def p113k_body(body: List<&2,P113DStmt>, facts: KDef) -> P113KBody:
  match body:
    case Nil{}: P113KBody{[],facts,False{}}
    case Con{stmt,rest}: p113k_body_next(p113k_stmt(stmt,facts),rest)


@unsafe
def p113k_scalar_body(result: P113KScalar) -> P113KBody:
  match result:
    case P113KScalar{body,facts}: P113KBody{p113d_scalars(body),facts,False{}}


@unsafe
def p113k_body_join(condition: N111Value, yes: P113KBody, no: P113KBody) -> P113KBody:
  match yes no:
    case P113KBody{yb,+yf,+yt} P113KBody{nb,+nf,+nt}:
      P113KBody{[P113DIf{condition,yb,nb}],
        nt_choose(KDef,yt,u => nf,u => nt_choose(KDef,nt,v => yf,v => p113k_join(yf,nf,missing()))),yt && nt}


@unsafe
def p113k_body_if(+condition: N111Value, +yes: List<&2,P113DStmt>, +no: List<&2,P113DStmt>, +facts: KDef, fact: P113KFact) -> P113KBody:
  match fact:
    case P113KFact{bits,+exact,+lo,hi}:
      nt_choose(P113KBody,exact,
        u => nt_choose(P113KBody,U32.is_eq(lo,0),v => p113k_body(no,facts),v => p113k_body(yes,facts)),
        u => p113k_body_join(condition,p113k_body(yes,p113l_assume(facts,condition,True{})),p113k_body(no,p113l_assume(facts,condition,False{}))))

@unsafe
def p113k_stmt(stmt: P113DStmt, +facts: KDef) -> P113KBody:
  match stmt:
    case P113DScalar{scalar}: p113k_scalar_body(p113k_scalar(scalar,facts))
    case P113DIf{+condition,yes,no}: p113k_body_if(condition,yes,no,facts,p113k_value(condition,facts))
    case P113DCall{+destinations,target,args}: P113KBody{[P113DCall{destinations,target,p113k_values(args,facts)}],p113k_kill(destinations,facts),False{}}
    case P113DResult{values}: P113KBody{[P113DResult{p113k_values(values,facts)}],facts,True{}}
    case P113DAgain{values}: P113KBody{[P113DAgain{p113k_values(values,facts)}],facts,True{}}


@unsafe
def p113k_function_done(name: String, params: List<&2,NC_Binding>, result: U32, public: Bool, scan: P113KBody) -> P113DFunction:
  match scan:
    case P113KBody{body,facts,terminal}: P113DFunction{name,params,result,public,body}


@unsafe
def p113k_function(+function: P113DFunction) -> P113DFunction:
  match function:
    case P113DFunction{+name,+params,+result,+public,+body}:
      nt_choose(P113DFunction,U32.is_lt(p113i_size(body),4096),
        u => p113k_function_done(name,params,result,public,p113k_body(body,missing())),u => function)


@unsafe
def p113k_functions(functions: List<&2,P113DFunction>) -> List<&2,P113DFunction>:
  match functions:
    case Nil{}: []
    case Con{function,rest}: Con{p113k_function(function),p113k_functions(rest)}


@unsafe
def p113k_admitted(program: P113DProgram) -> P113DProgram:
  match program:
    case P113DProgram{original,functions}: P113DProgram{original,p113k_functions(functions)}


@unsafe
def p113k_verified(+original: P113DProgram, +candidate: P113DProgram) -> P113DProgram:
  nt_choose(P113DProgram,String.is_empty(p113d_verify(candidate)),u => candidate,u => original)


@unsafe
def p113k_optimize(+program: P113DProgram) -> P113DProgram:
  nt_choose(P113DProgram,String.is_empty(p113d_verify(program)),
    u => p113k_verified(program,p113k_admitted(program)),u => program)


@unsafe
def p113k_lowered(+lowered: P113DLowering) -> P113DLowering:
  match lowered:
    case P113DLowered{program,+error}:
      nt_choose(P113DLowering,String.is_empty(error),u => P113DLowered{p113k_optimize(program),error},u => lowered)


@unsafe
def p113l_base_binary(+op: String, +left: P113KFact, +right: P113KFact, +width: U32) -> P113KFact:
  match left right:
    case P113KFact{+lb,+le,+ll,+lh} P113KFact{+rb,+re,+rl,+rh}:
      nt_choose(P113KFact,p111v_comparison(op),u => p113k_compare(op,left,right),u =>
      nt_choose(P113KFact,String.eq(op,"and"),
        u => nt_choose(P113KFact,le && re,v => p113k_exact(U32.and(ll,rl),U32.and(lh,rh)),v => p113k_bound(U32.min(lb,rb))),u =>
      nt_choose(P113KFact,String.eq(op,"or"),
        u => nt_choose(P113KFact,le && re,v => p113k_exact(U32.or(ll,rl),U32.or(lh,rh)),v => p113k_bound(U32.max(lb,rb))),u =>
      nt_choose(P113KFact,String.eq(op,"xor"),
        u => nt_choose(P113KFact,le && re,v => p113k_exact(U32.xor(ll,rl),U32.xor(lh,rh)),v => p113k_bound(U32.max(lb,rb))),u =>
      nt_choose(P113KFact,(String.eq(op,"shr") || String.eq(op,"shl")) && re && U32.is_eq(rh,0) && U32.is_lt(rl,width),
        u => p113k_shift(left,rl,String.eq(op,"shr")),u =>
      nt_choose(P113KFact,String.eq(op,"add"),u => p113k_bound(U32.min(width,U32.inc(U32.max(lb,rb)))),u =>
      nt_choose(P113KFact,String.eq(op,"mul"),u => p113k_bound(U32.min(width,U32.add(lb,rb))),
        u => p113k_bound(width))))))))


@unsafe
def p113l_base_compare(+op: String, left: P113KFact, right: P113KFact) -> P113KFact:
  match left right:
    case P113KFact{+lb,+le,+ll,+lh} P113KFact{+rb,+re,+rl,+rh}:
      nt_choose(P113KFact,le && re,
        u => p113k_unsigned(op,U32.is_eq(ll,rl) && U32.is_eq(lh,rh),U32.is_lt(lh,rh) || (U32.is_eq(lh,rh) && U32.is_lt(ll,rl))),u =>
      nt_choose(P113KFact,re && U32.is_lt(lb,rb),u => p113k_unsigned(op,False{},True{}),u =>
      nt_choose(P113KFact,le && U32.is_lt(rb,lb),u => p113k_unsigned(op,False{},False{}),u => p113k_bound(1))))


# The admitted direct IR reserves a non-reassignable 2048-byte scratch pointer.
# Restrict this fact to that buffer and the exact primitive ABI; arbitrary local
# pointers need capacity facts that this scalar pass deliberately does not track.
# These runtime primitives return raw 0/1 even for NaNs or packed Bool inputs.
@unsafe
def p185k_bool_primitive(+id: U32, +count: U32) -> Bool:
  (U32.is_eq(count,1) && U32.is_eq(id,21)) ||
    (U32.is_eq(count,2) && ((U32.is_ge(id,7) && U32.is_le(id,12)) ||
      (U32.is_ge(id,30) && U32.is_le(id,35)) || (U32.is_ge(id,67) && U32.is_le(id,69))))


@unsafe
def p185k_call_fact(typ: N111Type, +symbol: String, args: List<&2,N111Arg>) -> P113KFact:
  match typ args:
    case N111U64{} Con{N111Arg{N111Ptr{},N111Local{state}},
      Con{N111Arg{N111U32{},N111Const{id,0}},
      Con{N111Arg{N111Ptr{},N111Local{buffer}},
      Con{N111Arg{N111U32{},N111Const{count,0}},Nil{}}}}}:
      p113k_bound(nt_choose(U32,String.eq(symbol,"p111_rt_op") && String.eq(state,"state") &&
        String.eq(buffer,"scratch") && p185k_bool_primitive(id,count),u => 1,u => 64))
    case _ _: p113k_bound(64)


@unsafe
def p113l_base_scalar(stmt: N111Stmt, +facts: KDef) -> P113KScalar:
  match stmt:
    case N111Set{+name,+typ,+value}:
      P113KScalar{[N111Set{name,typ,p113k_replace(value,facts)}],p113k_put(facts,name,p113k_limit(p113k_value(value,facts),p113k_width(typ)))}
    case N111Bin{name,typ,op,+left,+right}: p113k_scalar_bin(name,typ,op,left,right,facts,p113k_value(left,facts),p113k_value(right,facts))
    case N111Call{+name,+typ,+symbol,+args}: P113KScalar{[N111Call{name,typ,symbol,p113k_args(args,facts)}],p113k_put(facts,name,p185k_call_fact(typ,symbol,args))}
    case N111If{+condition,yes,no}: p113k_scalar_if(condition,yes,no,facts,p113k_value(condition,facts))
    case N111Load{+name,typ,base,offset}: P113KScalar{[N111Load{name,typ,base,offset}],p113k_put(facts,name,p113k_bound(64))}
    case N111Store{typ,base,offset,value}: P113KScalar{[N111Store{typ,base,offset,p113k_replace(value,facts)}],facts}
    case N111Offset{+name,base,bytes}: P113KScalar{[N111Offset{name,base,bytes}],p113k_put(facts,name,p113k_bound(64))}
    case N111Alloca{+name,bytes,align}: P113KScalar{[N111Alloca{name,bytes,align}],p113k_put(facts,name,p113k_bound(64))}
    case N111Return{value}: P113KScalar{[N111Return{value}],facts}


@unsafe
def p113w_ring(+op: String) -> Bool:
  String.eq(op,"add") || String.eq(op,"sub") || String.eq(op,"mul") ||
    String.eq(op,"and") || String.eq(op,"or") || String.eq(op,"xor")


@unsafe
def p113w_mask_of(stmt: P113DStmt, +source: String) -> Bool:
  match stmt:
    case P113DScalar{N111Bin{destination,N111U64{},op,N111Local{word},N111Const{4294967295,0}}}:
      String.eq(destination,source) && String.eq(word,source) && String.eq(op,"and")
    case _: False{}


@unsafe
def p113w_pair(first: P113DStmt, +second: P113DStmt) -> Bool:
  match first:
    case P113DScalar{N111Bin{name,N111U64{},op,left,right}}:
      p113w_ring(op) && p113w_mask_of(second,name)
    case _: False{}


def p113w_mask(stmt: P113DStmt) -> Bool:
  match stmt:
    case P113DScalar{N111Bin{name,N111U64{},op,left,N111Const{4294967295,0}}}: String.eq(op,"and")
    case _: False{}


@unsafe
def p113w_room(code: P111QCode) -> Bool:
  match code:
    case P111QCode{chunks,next,terminal,error}: U32.is_lt(next,4294967295)


@unsafe
def p113w_word(+name: String, +operation: String, +ids: N111Ids, code: P111QCode) -> P111QCode:
  match code:
    case P111QCode{chunks,+next,terminal,error}:
      +temporary = "%p113_width_" ++ U32.show(next)
      P111QCode{Con{p111q_local(name) ++ " =l extuw " ++ temporary ++ "\n",
        Con{temporary ++ " =w " ++ operation ++ "\n",chunks}},U32.inc(next),terminal,error}


@unsafe
def p113w_pair_emit(first: P113DStmt, +ids: N111Ids, +code: P111QCode) -> P111QCode:
  match first:
    case P113DScalar{N111Bin{name,N111U64{},op,left,right}}:
      p113w_word(name,op ++ " " ++ p111q_value(left,ids) ++ ", " ++ p111q_value(right,ids),ids,code)
    case _: p111q_problem("invalid private width pair",code)


@unsafe
def p113w_mask_emit(stmt: P113DStmt, +ids: N111Ids, +code: P111QCode) -> P111QCode:
  match stmt:
    case P113DScalar{N111Bin{name,N111U64{},op,left,mask}}:
      p113w_word(name,"copy " ++ p111q_value(left,ids),ids,code)
    case _: p111q_problem("invalid private width mask",code)


@unsafe
def p113w_one(+head: P113DStmt, +params: List<&2,NC_Binding>, +ids: N111Ids, +code: P111QCode) -> P111QCode:
  nt_choose(P111QCode,p113w_mask(head) && p113w_room(code),
    u => p113w_mask_emit(head,ids,code),u => p113e_stmt_emit(head,params,ids,code))


@unsafe
def p113w_look(+head: P113DStmt, +rest: List<&2,P113DStmt>, +params: List<&2,NC_Binding>, +ids: N111Ids, +code: P111QCode) -> P111QCode:
  match rest:
    case Con{second,more}:
      nt_choose(P111QCode,p113w_pair(head,second) && p113w_room(code),
        u => p113w_stmts(more,params,ids,p113w_pair_emit(head,ids,code)),
        u => p113w_stmts(rest,params,ids,p113w_one(head,params,ids,code)))
    case Nil{}: p113w_one(head,params,ids,code)


@unsafe
def p113w_stmts(body: List<&2,P113DStmt>, +params: List<&2,NC_Binding>, +ids: N111Ids, +code: P111QCode) -> P111QCode:
  match body code:
    case Nil{} _: code
    case Con{head,rest} P111QCode{chunks,next,terminal,+error}:
      nt_choose(P111QCode,String.is_empty(error),u =>
        nt_choose(P111QCode,terminal,u => p111q_problem("statement follows direct transfer",code),
          u => p113w_look(head,rest,params,ids,code)),u => code)


@unsafe
def p113bq_scalar(yes: List<&2,N111Stmt>, no: List<&2,N111Stmt>) -> P113BQDiamond:
  match yes no:
    case Con{N111Set{+a,N111U64{},N111Const{1,0}},Nil{}} Con{N111Set{b,N111U64{},N111Const{0,0}},Nil{}}:
      nt_choose(P113BQDiamond,String.eq(a,b),u => P113BQYes{a,False{}},u => P113BQNo{})
    case Con{N111Set{+a,N111U64{},N111Const{0,0}},Nil{}} Con{N111Set{b,N111U64{},N111Const{1,0}},Nil{}}:
      nt_choose(P113BQDiamond,String.eq(a,b),u => P113BQYes{a,True{}},u => P113BQNo{})
    case _ _: P113BQNo{}


@unsafe
def p113bq_direct(yes: List<&2,P113DStmt>, no: List<&2,P113DStmt>) -> P113BQDiamond:
  match yes no:
    case Con{P113DScalar{a},Nil{}} Con{P113DScalar{b},Nil{}}: p113bq_scalar([a],[b])
    case _ _: P113BQNo{}


@unsafe
def p113bq_ready(diamond: P113BQDiamond, code: P111QCode) -> Bool:
  match diamond code:
    case P113BQYes{name,invert} P111QCode{chunks,n,terminal,error}: U32.is_lt(n,4294967295) && Bool.not(terminal) && String.is_empty(error)
    case _ _: False{}


@unsafe
def p113bq_emit(+condition: N111Value, diamond: P113BQDiamond, +ids: N111Ids, code: P111QCode) -> P111QCode:
  match diamond code:
    case P113BQYes{name,+invert} P111QCode{chunks,+n,terminal,error}:
      +temporary = "%p113_bool_" ++ U32.show(n)
      P111QCode{Con{p111q_local(name) ++ " =l extuw " ++ temporary ++ "\n",
        Con{temporary ++ " =w " ++ nt_choose(String,invert,u => "ceqw",u => "cnew") ++ " " ++ p111q_value(condition,ids) ++ ", 0\n",chunks}},U32.inc(n),terminal,error}
    case P113BQNo{} _: p111q_problem("invalid private Boolean diamond",code)


@unsafe
def p113bq_scalar_original(+condition: N111Value, +yes: List<&2,N111Stmt>, +no: List<&2,N111Stmt>, +ids: N111Ids, +code: P111QCode) -> P111QCode:
  match code:
    case P111QCode{chunks,n,terminal,error}:
      p111q_if_yes(n,no,ids,p111q_stmts(yes,ids,
        P111QCode{Con{p111q_label(n) ++ "\n",Con{"jnz " ++ p111q_value(condition,ids) ++ ", " ++ p111q_label(n) ++ ", " ++ p111q_label(U32.inc(n)) ++ "\n",chunks}},U32.add(n,3),False{},error}))


@unsafe
def p113bq_direct_original(+condition: N111Value, +yes: List<&2,P113DStmt>, +no: List<&2,P113DStmt>, +params: List<&2,NC_Binding>, +ids: N111Ids, code: P111QCode) -> P111QCode:
  match code:
    case P111QCode{chunks,n,terminal,error}:
      p113e_if_yes(n,no,params,ids,p113e_stmts(yes,params,ids,
        P111QCode{Con{p111q_label(n) ++ "\n",Con{"jnz " ++ p111q_value(condition,ids) ++ ", " ++ p111q_label(n) ++ ", " ++ p111q_label(U32.inc(n)) ++ "\n",chunks}},U32.add(n,3),False{},error}))


@unsafe
def p113l_ones(fact: P113KFact) -> Bool:
  match fact:
    case P113KFact{bits,exact,lo,hi}: U32.is_ne(lo,0) || U32.is_ne(hi,0)


@unsafe
def p113l_enrich(+answer: P113KFact, op: String, left: P113KFact, right: P113KFact) -> P113KFact:
  match answer left right:
    case P113KFact{+bits,+exact,lo,hi} P113KFact{lb,le,ll,lh} P113KFact{rb,re,rl,rh}:
      nt_choose(P113KFact,Bool.not(exact) && String.eq(op,"or"),
        u => P113KFact{bits,False{},U32.or(ll,rl),U32.or(lh,rh)},u => answer)


@unsafe
def p113l_version(+facts: KDef, +name: String) -> U32:
  ix(dt(p111v_get(facts,name)))


@unsafe
def p113l_relation(+facts: KDef, +name: String) -> KDef:
  +found = p111v_get(facts,"@condition:" ++ name)
  nt_choose(KDef,String.eq(dk(found),"P113LRelation") &&
    U32.is_eq(ix(dt(found)),p113l_version(facts,nm(dv(found)))) &&
    U32.is_eq(qt(dt(found)),p113l_version(facts,name)),u => found,u => missing())


@unsafe
def p113l_relate(+facts: KDef, +name: String, subject: String, version: U32, truth: U32) -> KDef:
  +key = "@condition:" ++ name
  index_set(facts,KDef{key,"P113LRelation",truth,0,kt("Epoch","",version,p113l_version(facts,name),[]),kt("Subject",subject,0,0,[]),[],False{},False{}},index_hash(key,2166136261),32)


@unsafe
def p113l_copy_relation(+before: KDef, +after: KDef, +name: String, value: N111Value, +invert: Bool) -> KDef:
  match value:
    case N111Local{source}:
      +record = p113l_relation(before,source)
      nt_choose(KDef,String.eq(dk(record),"P113LRelation"),u =>
        p113l_relate(after,name,nm(dv(record)),ix(dt(record)),U32.xor(da(record),Bool.to_u32(invert))),u => after)
    case _: after


@unsafe
def p113l_comparison(+before: KDef, +after: KDef, +name: String, +op: String, left: N111Value, right: N111Value) -> KDef:
  match left right:
    case N111Local{+subject} N111Const{+lo,+hi}:
      nt_choose(KDef,(String.eq(op,"eq") || String.eq(op,"ne")) && U32.is_eq(hi,0) && U32.is_le(lo,1) && U32.is_le(p113k_bits_of(p113k_get(before,subject)),1),
        u => p113l_relate(after,name,subject,p113l_version(before,subject),U32.xor(lo,Bool.to_u32(String.eq(op,"ne")))),u => after)
    case _ _: after


@unsafe
def p113l_bin_relation(+before: KDef, +after: KDef, +name: String, +op: String, +left: N111Value, +right: N111Value) -> KDef:
  nt_choose(KDef,(String.eq(op,"or") || String.eq(op,"xor") || String.eq(op,"add")) && p113k_zero(p113k_value(right,before)),
    u => p113l_copy_relation(before,after,name,left,False{}),u =>
  nt_choose(KDef,(String.eq(op,"or") || String.eq(op,"xor") || String.eq(op,"add")) && p113k_zero(p113k_value(left,before)),
    u => p113l_copy_relation(before,after,name,right,False{}),u =>
  nt_choose(KDef,String.eq(op,"xor") && p113l_exact_one(p113k_value(right,before)),
    u => p113l_copy_relation(before,after,name,left,True{}),u =>
    p113l_comparison(before,after,name,op,p113k_replace(left,before),p113k_replace(right,before)))))


@unsafe
def p113l_exact_one(fact: P113KFact) -> Bool:
  match fact:
    case P113KFact{bits,exact,lo,hi}: exact && U32.is_eq(lo,1) && U32.is_eq(hi,0)


@unsafe
def p113l_record(+stmt: N111Stmt, +before: KDef, after: KDef) -> KDef:
  p123p_record(stmt,before,p123p_old_record(stmt,before,after))

@unsafe
def p113l_scalar_done(stmt: N111Stmt, before: KDef, result: P113KScalar) -> P113KScalar:
  match result:
    case P113KScalar{body,facts}: P113KScalar{body,p113l_record(stmt,before,facts)}


@unsafe
def p113l_assume(+facts: KDef, condition: N111Value, +truth: Bool) -> KDef:
  match condition:
    case N111Local{name}:
      +record = p113l_relation(facts,name)
      nt_choose(KDef,String.eq(dk(record),"P113LRelation") && U32.is_le(p113k_bits_of(p113k_get(facts,nm(dv(record)))),1),
        u => p113k_put(facts,nm(dv(record)),p113k_exact(U32.xor(da(record),Bool.to_u32(Bool.not(truth))),0)),u => facts)
    case _: facts
