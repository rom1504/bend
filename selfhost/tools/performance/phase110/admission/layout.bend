# Canonical Base descriptor checks are structural and alpha-renaming invariant.
# The native bit is trusted ONLY because the mature checked loader gives it to
# Base definitions. Raw callers cannot turn arbitrary KDefs into provenance.
@unsafe
def nxe_base_meta(+definition: KDef, +name: String, +kind: String, +arity: U32) -> Bool:
  match definition:
    case KDef{actual,category,width,templates,typ,value,ctors,native,unsafe}:
      String.eq(actual,name) && String.eq(category,kind) && U32.is_eq(width,arity) && U32.is_eq(templates,0) &&
      native && Bool.not(unsafe) && String.eq(tg(value),"Absent")
    case _: False{}

@unsafe
def nxe_ctor_meta(+definition: KDef, +name: String, +arity: U32) -> Bool:
  nxe_base_meta(definition,name,"Ctr",arity) && List.is_empty(&2,KDef,nxe_children(definition))

@unsafe
def nxe_base_pair(+definition: KDef, +first: String, +first_arity: U32, +second: String, +second_arity: U32) -> Bool:
  nxe_base_pair_children(nxe_children(definition),first,first_arity,second,second_arity)

@unsafe
def nxe_base_pair_children(+children: List<&2,KDef>, +first: String, +first_arity: U32, +second: String, +second_arity: U32) -> Bool:
  match children:
    case Con{a,Con{b,Nil{}}}: nxe_ctor_meta(a,first,first_arity) && nxe_ctor_meta(b,second,second_arity)
    case _: False{}

@unsafe
def nxe_string_cons(+term: KTerm) -> Bool:
  +tail = kid(term,1)
  nxe_all(term,1) && nxe_named_type(kid(term,0),"Char") && nxe_all(tail,1) &&
  Bool.not(U32.is_eq(ix(term),ix(tail))) && nxe_named_type(kid(tail,0),"String") &&
  nxe_shape(kid(tail,1),"ADT",0) && nxe_named_type(kid(tail,1),"String")

@unsafe
def nxe_string_layout(+definition: KDef) -> Bool:
  nxe_base_meta(definition,"String","ADT",0) && nxe_universe(nxe_type(definition)) &&
  nxe_base_pair(definition,"SNil",0,"SCon",2) &&
  nxe_shape(nxe_type(nxe_lookup(nxe_children(definition),"SNil")),"ADT",0) &&
  nxe_named_type(nxe_type(nxe_lookup(nxe_children(definition),"SNil")),"String") &&
  nxe_string_cons(nxe_type(nxe_lookup(nxe_children(definition),"SCon")))

@unsafe
def nxe_type_var(+term: KTerm, +quantity: U32) -> Bool:
  nxe_shape(term,"Typ",1) && U32.is_eq(qt(term),0) && nxe_var(kid(term,0),quantity)

@unsafe
def nxe_list_type(+term: KTerm, +quantity: U32, +element: U32) -> Bool:
  nxe_shape(term,"ADT",2) && String.eq(nm(term),"List") && U32.is_eq(ix(term),0) && U32.is_eq(qt(term),1) &&
  nxe_var(kid(term,0),quantity) && nxe_var(kid(term,1),element)

@unsafe
def nxe_list_prefix(+term: KTerm) -> Bool:
  +element = kid(term,1)
  nxe_all(term,0) && nxe_leaf(kid(term,0),"Qnt","",0) && nxe_all(element,0) &&
  Bool.not(U32.is_eq(ix(term),ix(element))) && nxe_type_var(kid(element,0),ix(term))

@unsafe
def nxe_list_cons(+term: KTerm, +quantity: U32, +element: U32) -> Bool:
  +tail = kid(term,1)
  nxe_all(term,1) && nxe_var(kid(term,0),element) && nxe_all(tail,1) &&
  Bool.not(U32.is_eq(ix(term),quantity) || U32.is_eq(ix(term),element) || U32.is_eq(ix(tail),quantity) || U32.is_eq(ix(tail),element) || U32.is_eq(ix(term),ix(tail))) &&
  nxe_list_type(kid(tail,0),quantity,element) && nxe_list_type(kid(tail,1),quantity,element)

@unsafe
def nxe_list_ctor(+definition: KDef, +cons: Bool) -> Bool:
  +term = nxe_type(definition)
  +element = kid(term,1)
  nxe_list_prefix(term) && nx_choose(Bool,cons,
    u => nxe_list_cons(kid(element,1),ix(term),ix(element)),
    u => nxe_list_type(kid(element,1),ix(term),ix(element)))

@unsafe
def nxe_list_layout(+definition: KDef) -> Bool:
  +term = nxe_type(definition)
  nxe_base_meta(definition,"List","ADT",2) && nxe_list_prefix(term) && nxe_type_var(kid(kid(term,1),1),ix(term)) &&
  nxe_base_pair(definition,"Nil",0,"Con",2) &&
  nxe_list_ctor(nxe_lookup(nxe_children(definition),"Nil"),False{}) &&
  nxe_list_ctor(nxe_lookup(nxe_children(definition),"Con"),True{})

@unsafe
def nxe_char_layout(+definition: KDef) -> Bool:
  nxe_char_children(definition,nxe_children(definition))

@unsafe
def nxe_char_children(+definition: KDef, +children: List<&2,KDef>) -> Bool:
  match children:
    case Con{ctor,Nil{}}:
      +term = nxe_type(ctor)
      nxe_base_meta(definition,"Char","ADT",0) && nxe_universe(nxe_type(definition)) && nxe_ctor_meta(ctor,"Chr",1) &&
      nxe_all(term,1) && nxe_named_type(kid(term,0),"U32") && nxe_shape(kid(term,1),"ADT",0) && nxe_named_type(kid(term,1),"Char")
    case _: False{}

@unsafe
def nxe_layout_ok(+book: List<&2,KDef>) -> Bool:
  nxe_string_layout(nxe_lookup(book,"String")) && nxe_list_layout(nxe_lookup(book,"List")) && nxe_char_layout(nxe_lookup(book,"Char"))
