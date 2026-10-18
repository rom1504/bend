# Entry representation evidence, separate from ownership/body admission.
# These factories consume typed and erased books from ONE checked request.
type NxeRole is Data:
  NxeString{}
  NxeListString{}
  NxeUnknown{}

type NxeSignature is Data:
  NxeSignature{+params: List<&2,NxeRole>, +result: NxeRole, +error: String}

type NxeCertificate is Data:
  NxeCertificate{+source: KDef, +erased: KDef, +params: List<&2,NxeRole>, +result: NxeRole, +constructors: List<&2,NxoCtor>, +abi: String}

type NxeResult is Data:
  NxeResult{+certificate: Maybe<&2,NxeCertificate>, +error: String}

def nxe_missing() -> KDef:
  KDef{"","Absent",0,0,atom("Absent"),atom("Absent"),[],False{},False{}}

@unsafe
def nxe_has(+book: List<&2,KDef>, +name: String) -> Bool:
  match book:
    case Nil{}: False{}
    case Con{head,rest}: String.eq(dn(head),name) || nxe_has(rest,name)

@unsafe
def nxe_lookup(+book: List<&2,KDef>, +name: String) -> KDef:
  match book:
    case Nil{}: nxe_missing()
    case Con{head,rest}:
      nx_choose(KDef,String.eq(dn(head),name),u =>
        nx_choose(KDef,Bool.not(nxe_has(rest,name)),v => head,v => nxe_missing()),u => nxe_lookup(rest,name))

def nxe_type(definition: KDef) -> KTerm:
  match definition:
    case KDef{name,kind,arity,templates,typ,value,ctors,native,unsafe}: typ
    case _: atom("Absent")

def nxe_children(definition: KDef) -> List<&2,KDef>:
  match definition:
    case KDef{name,kind,arity,templates,typ,value,ctors,native,unsafe}: ctors
    case _: []

def nxe_no_removed(term: KTerm) -> Bool:
  match term:
    case KTerm{tag,name,id,quant,kids,removed,begin,end}: List.is_empty(&2,String,removed)
    case _: False{}

@unsafe
def nxe_shape(+term: KTerm, +tag: String, +count: U32) -> Bool:
  String.eq(tg(term),tag) && U32.is_eq(nxo_size(KTerm,ks(term)),count) && nxe_no_removed(term)

@unsafe
def nxe_leaf(+term: KTerm, +tag: String, +name: String, +quant: U32) -> Bool:
  nxe_shape(term,tag,0) && String.eq(nm(term),name) && U32.is_eq(ix(term),0) && U32.is_eq(qt(term),quant)

@unsafe
def nxe_named_type(+term: KTerm, +name: String) -> Bool:
  (nxe_shape(term,"Ref",0) || nxe_shape(term,"ADT",0)) && String.eq(nm(term),name) && U32.is_eq(ix(term),0) && U32.is_le(qt(term),1)

@unsafe
def nxe_all(+term: KTerm, +quantity: U32) -> Bool:
  nxe_shape(term,"All",2) && U32.is_eq(qt(term),quantity)

@unsafe
def nxe_var(+term: KTerm, +id: U32) -> Bool:
  nxe_shape(term,"Var",0) && U32.is_eq(ix(term),id) && U32.is_eq(qt(term),1)

@unsafe
def nxe_universe(+term: KTerm) -> Bool:
  nxe_shape(term,"Typ",1) && U32.is_eq(qt(term),0) && nxe_leaf(kid(term,0),"Qua","",2)

def nxe_role_known(role: NxeRole) -> Bool:
  match role:
    case NxeUnknown{}: False{}
    case _: True{}

@unsafe
def nxe_role(+term: KTerm) -> NxeRole:
  nx_choose(NxeRole,nxe_named_type(term,"String"),u => NxeString{},u =>
    nx_choose(NxeRole,nxe_shape(term,"ADT",2) && String.eq(nm(term),"List") && U32.is_eq(ix(term),0) && U32.is_le(qt(term),1) &&
      nxe_leaf(kid(term,0),"Qua","",2) && nxe_named_type(kid(term,1),"String"),v => NxeListString{},v => NxeUnknown{}))

def nxe_constructors() -> List<&2,NxoCtor>:
  [NxoCtor{"Nil",0,0},NxoCtor{"Con",1,2},NxoCtor{"SNil",2,0},NxoCtor{"SCon",3,2}]
