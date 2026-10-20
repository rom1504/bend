# Reflected-data controls test consumption of the existing checked certificate.
# They are not a route for admitting caller-supplied masks as source proofs.
def p113dft_scalar(kind: N_WordKind) -> Bool:
  match kind:
    case N_W32{}: True{}
    case _: False{}

def p113dft_box(kind: N_WordKind) -> Bool:
  match kind:
    case N_Box{}: True{}
    case _: False{}

@unsafe
def p113dft_row(+name: String, valid: Bool) -> String:
  nt_choose(String,valid,u => "PASS " ++ name,u => "FAIL " ++ name)

def p113dft_mat(name: String, count: U32, mask: U32) -> KTerm:
  kt("Mat",name,U32.inc(count),mask,[atom("Efq"),atom("Efq")])

@unsafe
def p113dft_bits(bindings: List<&2,NC_Binding>, +i: U32) -> U32:
  match bindings:
    case Nil{}: 0
    case Con{NC_Binding{id,word,kind},rest}:
      U32.or(nt_choose(U32,p113dft_scalar(kind),u => U32.shln(1,U32.to_nat(i)),u => 0),p113dft_bits(rest,U32.inc(i)))

@unsafe
def p113dft_mask(+count: U32, +mask: U32) -> U32:
  p113dft_bits(p113df_field_env([],p113dft_mat("record",count,mask),count,0,7),0)

def p113dft_type(name: String) -> KTerm:
  kt("ADT",name,0,0,[])

def p113dft_owner(name: String, builtin: Bool) -> KDef:
  KDef{name,"ADT",0,0,atom("Data"),atom("Absent"),[],builtin,False{}}

def p113dft_book() -> List<&2,KDef>:
  [p113dft_owner("U32",True{}),p113dft_owner("F32",True{}),p113dft_owner("Char",True{}),
   p113dft_owner("Bool",True{}),p113dft_owner("String",True{})]

@unsafe
def p113dft_tele(+first: KTerm, +second: KTerm) -> KTerm:
  kt("All","first",1,1,[first,kt("All","second",2,1,[second,p113dft_type("record")])])

@unsafe
def p113dft_erased() -> U32:
  nh_field_mask(p113dft_book(),kt("All","erased",3,0,[p113dft_type("U32"),
    p113dft_tele(p113dft_type("String"),p113dft_type("F32"))]),3,0)

@unsafe
def p113dft_alias() -> U32:
  +alias : KDef = KDef{"FloatAlias","Def",0,0,atom("Typ"),p113dft_type("F32"),[],False{},False{}}
  nh_field_mask(Con{alias,p113dft_book()},p113dft_tele(kt("Ref","FloatAlias",0,0,[]),p113dft_type("String")),2,0)

def p113dft_env() -> List<&2,NC_Binding>:
  [NC_Binding{11,"full_left",N_W64{}},NC_Binding{12,"full_right",N_Box{}}]

@unsafe
def p113dft_bundle(+mask: U32) -> List<&2,NC_Binding>:
  p113df_bundle_env(p113dft_mat("record",2,mask),kt("NQBundle","record",0,0,[var("",11),var("",12)]),p113dft_env())

@unsafe
def p113dft_names(bindings: List<&2,NC_Binding>) -> Bool:
  match bindings:
    case Con{NC_Binding{a,aw,ak},Con{NC_Binding{b,bw,bk},Nil{}}}:
      U32.is_eq(a,11) && U32.is_eq(b,12) && String.eq(aw,"full_left") && String.eq(bw,"full_right")
    case _: False{}

def p113dft_drop(parts: P111Partition) -> U32:
  match parts:
    case P111Partition{live,drop}: nt_count(N111Stmt,drop)

@unsafe
def p113_field_control_report() -> List<&2,String>:
  [
    p113dft_row("field-one-scalar",U32.is_eq(p113dft_mask(1,1),1)),
    p113dft_row("field-mixed-slots",U32.is_eq(p113dft_mask(4,5),5)),
    p113dft_row("field-eight-scalars",U32.is_eq(p113dft_mask(8,255),255)),
    p113dft_row("field-all-unknown",U32.is_eq(p113dft_mask(4,0),0)),
    p113dft_row("field-outside-mask-fallback",U32.is_eq(p113dft_mask(3,8),0)),
    p113dft_row("field-width-nine-fallback",U32.is_eq(p113dft_mask(9,511),0)),
    p113dft_row("field-empty",U32.is_eq(p113dft_mask(0,0),0)),
    p113dft_row("field-legacy-arity-fallback",U32.is_eq(p113df_mask(kt("Mat","record",0,3,[]),2),0)),
    p113dft_row("field-mismatched-arity-fallback",U32.is_eq(p113df_mask(p113dft_mat("record",3,3),2),0)),
    p113dft_row("field-wrong-tag-fallback",U32.is_eq(p113df_mask(kt("Ctr","record",3,3,[]),2),0)),
    p113dft_row("field-erased-slot-does-not-shift",U32.is_eq(p113dft_erased(),2)),
    p113dft_row("field-U32-string",U32.is_eq(nh_field_mask(p113dft_book(),p113dft_tele(p113dft_type("U32"),p113dft_type("String")),2,0),1)),
    p113dft_row("field-bool-char",U32.is_eq(nh_field_mask(p113dft_book(),p113dft_tele(p113dft_type("Bool"),p113dft_type("Char")),2,0),3)),
    p113dft_row("field-transparent-alias",U32.is_eq(p113dft_alias(),1)),
    p113dft_row("field-shadow-F32",U32.is_eq(nh_field_mask([p113dft_owner("F32",False{})],p113dft_tele(p113dft_type("F32"),atom("Absent")),2,0),0)),
    p113dft_row("field-dependent-stays-unknown",U32.is_eq(nh_field_mask(p113dft_book(),p113dft_tele(var("",99),p113dft_type("U32")),2,0),2)),
    p113dft_row("field-Nat-stays-unknown",U32.is_eq(nh_field_mask(Con{p113dft_owner("Nat",True{}),p113dft_book()},p113dft_tele(p113dft_type("Nat"),p113dft_type("U32")),2,0),2)),
    p113dft_row("bundle-refines-first-only",U32.is_eq(p113dft_bits(p113dft_bundle(1),0),1)),
    p113dft_row("bundle-keeps-word-and-id",p113dft_names(p113dft_bundle(3))),
    p113dft_row("bundle-preserves-old-opaque-kind",p113dft_box(nk_kind(12,p113dft_bundle(1)))),
    p113dft_row("bundle-constructor-mismatch",U32.is_eq(p113dft_bits(p113df_bundle_env(p113dft_mat("different",2,3),kt("NQBundle","record",0,0,[var("",11),var("",12)]),p113dft_env()),0),0)),
    p113dft_row("bundle-nonvariable-refusal",U32.is_eq(p113dft_bits(p113df_bundle_env(p113dft_mat("record",2,3),kt("NQBundle","record",0,0,[var("",11),atom("NWord")]),p113dft_env()),0),0)),
    p113dft_row("bundle-keep-only-owner",U32.is_eq(nt_count(N111Stmt,p111_keep(p113dft_bundle(1),nu_add(nu_add(NU_Empty{},11),12))),1)),
    p113dft_row("bundle-drop-only-owner",U32.is_eq(p113dft_drop(p111_partition(p113dft_bundle(1),NU_Empty{})),1))
  ]
