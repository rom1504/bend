# Experimental constructor-ownership query preparation. The semantic key keeps
# ordered ADT ownership and ordered child name/kind observations, including
# non-constructors which shadow later children. Cached child books are refused.

type P135COField is Data:
  P135COField{+name: String, +constructor: Bool}

type P135CORow is Data:
  P135CORow{+owned: Bool, +fields: List<&2,P135COField>}

type P135COFields is Data:
  P135COFields{+fields: List<&2,P135COField>, +valid: Bool}

type P135COShape is Data:
  P135COShape{+rows: List<&2,P135CORow>, +valid: Bool}

type P135COCache is Data:
  P135COCache{+shape: P135COShape, +index: KDef}

type P135COReady is Data:
  P135COReady{+cache: P135COCache, +hit: Bool}

type P135COBook is Data:
  P135COBook{+book: List<&2,KDef>, +cache: P135COCache, +hit: Bool}

@unsafe
def p135co_fields(children: List<&2,KDef>, acc: List<&2,P135COField>) -> P135COFields:
  match children:
    case Nil{}: P135COFields{nt_reverse(P135COField,acc,[]),True{}}
    case Con{+head,+rest}:
      nt_choose(P135COFields,String.eq(dk(head),"BookCache"),
        u => P135COFields{[],False{}},
        u => p135co_fields(rest,Con{P135COField{dn(head),String.eq(dk(head),"Ctr")},acc}))

@unsafe
def p135co_rows(book: List<&2,KDef>, +acc: List<&2,P135CORow>) -> P135COShape:
  match book:
    case Nil{}: P135COShape{nt_reverse(P135CORow,acc,[]),True{}}
    case Con{+head,+rest}:
      nt_choose(P135COShape,String.eq(dk(head),"ADT"),
        u => p135co_row(rest,acc,db(head),p135co_fields(dc(head),[])),
        u => p135co_rows(rest,acc))

@unsafe
def p135co_row(+rest: List<&2,KDef>, +acc: List<&2,P135CORow>, +owned: Bool, fields: P135COFields) -> P135COShape:
  match fields:
    case P135COFields{+values,valid}:
      nt_choose(P135COShape,valid,u => p135co_rows(rest,Con{P135CORow{owned,values},acc}),
        u => P135COShape{[],False{}})

def p135co_field_eq(a: P135COField, b: P135COField) -> Bool:
  match a b:
    case P135COField{an,ac} P135COField{bn,bc}: String.eq(an,bn) && p134v_bool(ac,bc)

@unsafe
def p135co_row_eq(a: P135CORow, b: P135CORow) -> Bool:
  match a b:
    case P135CORow{ao,af} P135CORow{bo,bf}:
      p134v_bool(ao,bo) && p134v_list(P135COField,p135co_field_eq,af,bf)

@unsafe
def p135co_shape_eq(a: P135COShape, b: P135COShape) -> Bool:
  match a b:
    case P135COShape{ar,av} P135COShape{br,bv}:
      av && bv && p134v_list(P135CORow,p135co_row_eq,ar,br)

def p135co_record(name: String, kind: String, owned: Bool) -> KDef:
  KDef{name,kind,0,0,KTerm{"Absent","",0,0,[],[],0,0},KTerm{"Absent","",0,0,[],[],0,0},[],owned,False{}}

@unsafe
def p135co_lookup(+tree: KDef, +name: String) -> KDef:
  index_find(tree,name,index_hash(name,2166136261),32)

@unsafe
def p135co_add(+tree: KDef, +name: String, +owned: Bool) -> KDef:
  nt_choose(KDef,String.eq(dk(p135co_lookup(tree,name)),"P135Ownership"),u => tree,
    u => index_set(tree,p135co_record(name,"P135Ownership",owned),index_hash(name,2166136261),32))

@unsafe
def p135co_children(fields: List<&2,P135COField>, +owned: Bool, +seen: KDef, +tree: KDef) -> KDef:
  match fields:
    case Nil{}: tree
    case Con{P135COField{+name,+constructor},+rest}:
      nt_choose(KDef,String.eq(dk(p135co_lookup(seen,name)),"P135Seen"),
        u => p135co_children(rest,owned,seen,tree),
        u => p135co_children(rest,owned,
          index_set(seen,p135co_record(name,"P135Seen",False{}),index_hash(name,2166136261),32),
          nt_choose(KDef,constructor,v => p135co_add(tree,name,owned),v => tree)))

@unsafe
def p135co_index(rows: List<&2,P135CORow>, tree: KDef) -> KDef:
  match rows:
    case Nil{}: tree
    case Con{P135CORow{owned,fields},rest}: p135co_index(rest,p135co_children(fields,owned,missing(),tree))

@unsafe
def p135co_create(+shape: P135COShape) -> P135COCache:
  match shape:
    case P135COShape{+rows,valid}:
      P135COCache{shape,nt_choose(KDef,valid,u => p135co_index(rows,missing()),u => missing())}

@unsafe
def p135co_reuse_shape(+shape: P135COShape, +prior: P135COCache) -> P135COReady:
  match prior:
    case P135COCache{old,index}:
      nt_choose(P135COReady,p135co_shape_eq(shape,old),
        u => P135COReady{prior,True{}},u => P135COReady{p135co_create(shape),False{}})

@unsafe
def p135co_reuse(book: List<&2,KDef>, prior: P135COCache) -> P135COReady:
  p135co_reuse_shape(p135co_rows(book,[]),prior)

def p135co_empty() -> P135COCache:
  P135COCache{P135COShape{[],False{}},missing()}

# Independent exact legacy query, also the fallback for unsupported contexts.
@unsafe
def p135co_legacy(book: List<&2,KDef>, +name: String) -> Bool:
  match book:
    case Nil{}: False{}
    case Con{+d,+rest}:
      nt_choose(Bool,String.eq(dk(d),"ADT"),
        u => nt_choose(Bool,String.eq(dk(lookup(dc(d),name)),"Ctr"),
          v => db(d),v => p135co_legacy(rest,name)),u => p135co_legacy(rest,name))

@unsafe
def p135co_query(+book: List<&2,KDef>, cache: P135COCache, +name: String) -> Bool:
  match cache:
    case P135COCache{P135COShape{rows,valid},+tree}:
      nt_choose(Bool,valid,u => db(p135co_lookup(tree,name)),u => p135co_legacy(book,name))

# Add one private sidecar under the existing NativeCtorIndex. The original
# constructor index is first and all unknown trailing context fields survive.
@unsafe
def p135co_sidecar(cache: P135COCache) -> KDef:
  match cache:
    case P135COCache{P135COShape{rows,valid},tree}:
      KDef{"$native.ctor.ownership","P135CtorOwnership",1,0,
        KTerm{"Absent","",0,0,[],[],0,0},KTerm{"Absent","",0,0,[],[],0,0},[tree],valid,False{}}

@unsafe
def p135co_sidecar_tail(+children: List<&2,KDef>, +sidecar: KDef) -> List<&2,KDef>:
  match children:
    case Con{+old,+rest}:
      nt_choose(List<&2,KDef>,String.eq(dk(old),"P135CtorOwnership") && String.eq(dn(old),"$native.ctor.ownership"),
        u => Con{sidecar,rest},u => Con{sidecar,children})
    case Nil{}: [sidecar]

@unsafe
def p135co_ctor_children(children: List<&2,KDef>, sidecar: KDef) -> List<&2,KDef>:
  match children:
    case Con{tree,rest}: Con{tree,p135co_sidecar_tail(rest,sidecar)}
    case Nil{}: []

@unsafe
def p135co_ctor(+ctor: KDef, +sidecar: KDef) -> KDef:
  match ctor:
    case KDef{+name,+kind,arity,templates,ty,value,+children,bang,uns}:
      nt_choose(KDef,String.eq(kind,"NativeCtorIndex"),
        u => KDef{name,kind,arity,templates,ty,value,p135co_ctor_children(children,sidecar),bang,uns},u => ctor)
    case _: ctor

@unsafe
def p135co_context_children(children: List<&2,KDef>, sidecar: KDef) -> List<&2,KDef>:
  match children:
    case Con{bodies,Con{ctors,rest}}: Con{bodies,Con{p135co_ctor(ctors,sidecar),rest}}
    case _: children

@unsafe
def p135co_context(+context: KDef, +sidecar: KDef) -> KDef:
  match context:
    case KDef{+name,+kind,arity,templates,ty,value,+children,bang,uns}:
      nt_choose(KDef,String.eq(kind,"NativeStaticContext") && String.eq(name,"$native.static"),
        u => KDef{name,kind,arity,templates,ty,value,p135co_context_children(children,sidecar),bang,uns},u => context)
    case _: context

@unsafe
def p135co_book_children(children: List<&2,KDef>, sidecar: KDef) -> List<&2,KDef>:
  match children:
    case Con{source,Con{context,rest}}: Con{source,Con{p135co_context(context,sidecar),rest}}
    case _: children

@unsafe
def p135co_header(+header: KDef, +sidecar: KDef) -> KDef:
  match header:
    case KDef{name,+kind,arity,templates,ty,value,+children,bang,uns}:
      nt_choose(KDef,String.eq(kind,"BookCache"),
        u => KDef{name,kind,arity,templates,ty,value,p135co_book_children(children,sidecar),bang,uns},u => header)
    case _: header

@unsafe
def p135co_attach(book: List<&2,KDef>, cache: P135COCache) -> List<&2,KDef>:
  match book:
    case Con{header,rest}: Con{p135co_header(header,p135co_sidecar(cache)),rest}
    case Nil{}: []

@unsafe
def p135co_book_ready(+book: List<&2,KDef>, ready: P135COReady) -> P135COBook:
  match ready:
    case P135COReady{+cache,hit}: P135COBook{p135co_attach(book,cache),cache,hit}

@unsafe
def p135co_prepare_book(+book: List<&2,KDef>, prior: P135COCache) -> P135COBook:
  p135co_book_ready(book,p135co_reuse(book,prior))

@unsafe
def p135co_payload(children: List<&2,KDef>) -> KDef:
  match children:
    case Con{tree,Con{+sidecar,rest}}:
      nt_choose(KDef,String.eq(dn(sidecar),"$native.ctor.ownership") &&
        String.eq(dk(sidecar),"P135CtorOwnership") && U32.is_eq(da(sidecar),1),u => sidecar,u => missing())
    case _: missing()

@unsafe
def p135co_owned(+book: List<&2,KDef>, +name: String) -> Bool:
  +sidecar = p135co_payload(dc(nc_ctor_context(book)))
  nt_choose(Bool,db(sidecar),u => db(p135co_lookup(index_first(dc(sidecar)),name)),
    u => p135co_legacy(book,name))
