# Experimental, syntax-authenticated summaries before ownership insertion.
# This module does not transform code, certify arbitrary functions, or replace
# source checking. Bounds are local: 8 variants, 16 fields, 32 constant nodes.
# Ordinary closed Data ADTs with quantity2 field binders only.
# Unknown/parametric/effectful forms and other field quantities refuse.
type P173ODRow is Data:
  P173ODRow{+ctor: String,+count: U32,+mask: U32,+getterFields: List<&2,U32>,+getterValue: KTerm,+setterFields: List<&2,U32>,+setterValue: KTerm}

type P173ODSummary is Data:
  P173ODSummary{+getterRoot: U32,+setterRoot: U32,+replacement: U32,+rows: List<&2,P173ODRow>}

type P173ODBind is Data:
  P173ODBind{+ids: List<&2,U32>,+body: KTerm,+valid: Bool}

# Forward contracts for bounded mutually recursive syntax inspection.
law p173od_has:
  for +ids: List<&2,U32>
  for +id: U32
  Bool

law p173od_isvar:
  for +term: KTerm
  for +id: U32
  Bool

law p173od_efq:
  for +term: KTerm
  Bool

law p173od_constant:
  for +term: KTerm
  for +left: U32
  U32

law p173od_constants:
  for +terms: List<&2,KTerm>
  for +left: U32
  U32

law p173od_fields:
  for +term: KTerm
  for +left: U32
  for +forbidden: List<&2,U32>
  for +seen: List<&2,U32>
  P173ODBind

law p173od_ctor_result:
  for +term: KTerm
  for +left: U32
  KTerm

law p173od_data:
  for +owner: KDef
  Bool

law p173od_ctor_checked:
  for +book: List<&2,KDef>
  for +name: String
  for +count: U32
  for +ctor: KDef
  for +result: KTerm
  Bool

law p173od_ctor_found:
  for +book: List<&2,KDef>
  for +name: String
  for +count: U32
  for +ctor: KDef
  Bool

law p173od_ctor:
  for +book: List<&2,KDef>
  for +name: String
  for +count: U32
  Bool

law p173od_getter_value:
  for +value: KTerm
  for +fields: List<&2,U32>
  Bool

law p173od_origins:
  for +values: List<&2,KTerm>
  for +fields: List<&2,U32>
  for +replacement: U32
  for +used: Bool
  Bool

law p173od_origin_field:
  for +value: KTerm
  for +rest: List<&2,KTerm>
  for +fields: List<&2,U32>
  for +replacement: U32
  for +used: Bool
  Bool

law p173od_setter_value:
  for +value: KTerm
  for +fields: List<&2,U32>
  for +root: U32
  for +replacement: U32
  for +ctor: String
  for +count: U32
  Bool

law p173od_row_setter:
  for +book: List<&2,KDef>
  for +get: KTerm
  for +set: KTerm
  for +getterRoot: U32
  for +setterRoot: U32
  for +replacement: U32
  for +seen: List<&2,String>
  for +left: U32
  for +acc: List<&2,P173ODRow>
  for +getterFields: List<&2,U32>
  for +getterValue: KTerm
  for +getterValid: Bool
  for +setter: P173ODBind
  Maybe<&2,List<&2,P173ODRow>>

law p173od_row_getter:
  for +book: List<&2,KDef>
  for +get: KTerm
  for +set: KTerm
  for +getterRoot: U32
  for +setterRoot: U32
  for +replacement: U32
  for +seen: List<&2,String>
  for +left: U32
  for +acc: List<&2,P173ODRow>
  for +getter: P173ODBind
  Maybe<&2,List<&2,P173ODRow>>

law p173od_rows:
  for +book: List<&2,KDef>
  for +get: KTerm
  for +set: KTerm
  for +getterRoot: U32
  for +setterRoot: U32
  for +replacement: U32
  for +seen: List<&2,String>
  for +left: U32
  for +acc: List<&2,P173ODRow>
  Maybe<&2,List<&2,P173ODRow>>

law p173od_finish:
  for +getterRoot: U32
  for +setterRoot: U32
  for +replacement: U32
  for +rows: Maybe<&2,List<&2,P173ODRow>>
  Maybe<&2,P173ODSummary>

law p173od_matched:
  for +book: List<&2,KDef>
  for +get: KTerm
  for +set: KTerm
  for +getterRoot: U32
  for +setterRoot: U32
  for +replacement: U32
  Maybe<&2,P173ODSummary>

law p173od_replacement:
  for +book: List<&2,KDef>
  for +get: KTerm
  for +set: KTerm
  for +getterRoot: U32
  for +setterRoot: U32
  Maybe<&2,P173ODSummary>

law p173od_bodies:
  for +book: List<&2,KDef>
  for +get: KTerm
  for +set: KTerm
  Maybe<&2,P173ODSummary>

law p173od_definitions:
  for +book: List<&2,KDef>
  for +getter: KDef
  for +setter: KDef
  Maybe<&2,P173ODSummary>

law p173od_pair:
  for +book: List<&2,KDef>
  for +getterName: String
  for +setterName: String
  Maybe<&2,P173ODSummary>

law p173od_row_ready:
  for +book: List<&2,KDef>
  for +get: KTerm
  for +set: KTerm
  for +getterRoot: U32
  for +setterRoot: U32
  for +replacement: U32
  for +seen: List<&2,String>
  for +left: U32
  for +acc: List<&2,P173ODRow>
  for +getterFields: List<&2,U32>
  for +getterValue: KTerm
  for +getterValid: Bool
  for +setterFields: List<&2,U32>
  for +setterValue: KTerm
  for +setterValid: Bool
  Maybe<&2,List<&2,P173ODRow>>

law p173od_replace_values:
  for +values: List<&2,KTerm>
  for +old: U32
  for +fresh: U32
  List<&2,KTerm>

law p173od_row_direct:
  for +book: List<&2,KDef>
  for +get: KTerm
  for +set: KTerm
  for +replacement: U32
  for +seen: List<&2,String>
  for +left: U32
  for +acc: List<&2,P173ODRow>
  for +getterFields: List<&2,U32>
  for +getterValue: KTerm
  for +getterValid: Bool
  for +setterFields: List<&2,U32>
  for +setterValue: KTerm
  for +setterValid: Bool
  Maybe<&2,List<&2,P173ODRow>>

law p173od_direct_first:
  for +book: List<&2,KDef>
  for +get: KTerm
  for +set: KTerm
  for +fields: P173ODBind
  Maybe<&2,P173ODSummary>

law p173od_entry_bodies:
  for +book: List<&2,KDef>
  for +get: KTerm
  for +set: KTerm
  Maybe<&2,P173ODSummary>

@unsafe
def p173od_has(ids, id):
  match ids:
    case Nil{}: False{}
    case Con{+head,+rest}: U32.is_eq(head,id) || p173od_has(rest,id)

@unsafe
def p173od_isvar(term, id):
  p98_tag_eq(term,"Var") && U32.is_eq(ix(term),id) && List.is_empty(&2,KTerm,ks(term))

@unsafe
def p173od_efq(term):
  p98_tag_eq(term,"Efq") && List.is_empty(&2,KTerm,ks(term))

# Sentinel33 means refusal. A successful answer is the remaining node budget.
@unsafe
def p173od_constant(term, left):
  nt_choose(U32,U32.is_eq(left,0) || U32.is_gt(left,32),u => 33,u =>
    nt_choose(U32,p98_tag_eq(term,"NWord") && List.is_empty(&2,KTerm,ks(term)),
      v => U32.sub(left,1),v =>
      nt_choose(U32,p98_tag_eq(term,"Ctr"),w => p173od_constants(ks(term),U32.sub(left,1)),w => 33)))

@unsafe
def p173od_constants(terms, left):
  match terms:
    case Nil{}: left
    case Con{+head,+rest}:
      nt_choose(U32,U32.is_gt(left,32),u => 33,u => p173od_constants(rest,p173od_constant(head,left)))

@unsafe
def p173od_fields(term, left, forbidden, seen):
  nt_choose(P173ODBind,U32.is_eq(left,0),u => P173ODBind{nt_reverse(U32,seen,[]),term,True{}},u =>
    nt_choose(P173ODBind,p98_tag_eq(term,"Lam") && U32.is_eq(terms_len(ks(term)),1) &&
      U32.is_eq(qt(term),2) &&
      Bool.not(p173od_has(forbidden,ix(term)) || p173od_has(seen,ix(term))),
      v => p173od_fields(kid(term,0),U32.sub(left,1),forbidden,Con{ix(term),seen}),
      v => P173ODBind{[],term,False{}}))

# No erased constructor fields or type parameters in this initial catalogue.
@unsafe
def p173od_ctor_result(term, left):
  nt_choose(KTerm,U32.is_eq(left,0),u => atom("Absent"),u =>
    nt_choose(KTerm,p98_tag_eq(term,"All"),v =>
      nt_choose(KTerm,U32.is_eq(terms_len(ks(term)),2) && Bool.not(U32.is_eq(qt(term),0)),
        w => p173od_ctor_result(kid(term,1),U32.sub(left,1)),w => atom("Absent")),v => term))

@unsafe
def p173od_data(owner):
  p88_string_eq(dk(owner),"ADT") && U32.is_eq(da(owner),0) && U32.is_eq(dx(owner),0) && Bool.not(db(owner)) &&
  p98_tag_eq(dt(owner),"Typ") && U32.is_eq(terms_len(ks(dt(owner))),1) &&
  p98_tag_eq(kid(dt(owner),0),"Qua") && U32.is_eq(qt(kid(dt(owner),0)),2)

@unsafe
def p173od_ctor_checked(book, name, count, ctor, result):
  p88_string_eq(dk(ctor),"Ctr") && U32.is_eq(da(ctor),count) && U32.is_eq(dx(ctor),0) && Bool.not(db(ctor)) &&
  p88_string_eq(name,nc_ctor_encode(dn(ctor))) && p98_tag_eq(result,"ADT") && List.is_empty(&2,KTerm,ks(result)) &&
  p173od_data(lookup(book,nm(result)))

@unsafe
def p173od_ctor_found(book, name, count, ctor):
  p173od_ctor_checked(book,name,count,ctor,p173od_ctor_result(dt(ctor),32))

@unsafe
def p173od_ctor(book, name, count):
  p173od_ctor_found(book,name,count,nc_find_ctor(book,nc_ctor_display(name)))

@unsafe
def p173od_getter_value(value, fields):
  nt_choose(Bool,p98_tag_eq(value,"Var"),
    u => List.is_empty(&2,KTerm,ks(value)) && p173od_has(fields,ix(value)),
    u => U32.is_le(p173od_constant(value,32),32))

# Positional field preservation: no swaps, omitted fields, extra expressions,
# or duplicated replacement. Identity constructors and original-root returns
# are retained as rows, never permission to skip strict replacement evaluation.
@unsafe
def p173od_origins(values, fields, replacement, used):
  match values:
    case Nil{}: List.is_empty(&2,U32,fields)
    case Con{+value,+rest}: p173od_origin_field(value,rest,fields,replacement,used)

@unsafe
def p173od_origin_field(value, rest, fields, replacement, used):
  match fields:
    case Nil{}: False{}
    case Con{+field,+tail}:
      nt_choose(Bool,p173od_isvar(value,field),u => p173od_origins(rest,tail,replacement,used),u =>
        Bool.not(used) && p173od_isvar(value,replacement) && p173od_origins(rest,tail,replacement,True{}))

@unsafe
def p173od_setter_value(value, fields, root, replacement, ctor, count):
  p173od_isvar(value,root) || (p98_tag_eq(value,"Ctr") && p88_string_eq(nm(value),ctor) &&
    U32.is_eq(terms_len(ks(value)),count) && p173od_origins(ks(value),fields,replacement,False{}))

@unsafe
def p173od_row_setter(book, get, set, getterRoot, setterRoot, replacement, seen, left, acc, getterFields, getterValue, getterValid, setter):
  match setter:
    case P173ODBind{+setterFields,+setterValue,+setterValid}:
      nt_choose(Maybe<&2,List<&2,P173ODRow>>,U32.is_eq(getterRoot,0) && U32.is_eq(setterRoot,0),
        u => p173od_row_direct(book,get,set,replacement,seen,left,acc,getterFields,getterValue,getterValid,setterFields,setterValue,setterValid),
        u => p173od_row_ready(book,get,set,getterRoot,setterRoot,replacement,seen,left,acc,getterFields,getterValue,getterValid,setterFields,setterValue,setterValid))

@unsafe
def p173od_row_getter(book, get, set, getterRoot, setterRoot, replacement, seen, left, acc, getter):
  match getter:
    case P173ODBind{+getterFields,+getterValue,+getterValid}:
      p173od_row_setter(book,get,set,getterRoot,setterRoot,replacement,seen,left,acc,getterFields,getterValue,getterValid,
        p173od_fields(kid(set,0),U32.sub(ix(set),1),[setterRoot,replacement],[]))

@unsafe
def p173od_rows(book, get, set, getterRoot, setterRoot, replacement, seen, left, acc):
  nt_choose(Maybe<&2,List<&2,P173ODRow>>,p173od_efq(get) && p173od_efq(set),
    u => nt_choose(Maybe<&2,List<&2,P173ODRow>>,List.is_empty(&2,P173ODRow,acc),v => None{},v => Some{nt_reverse(P173ODRow,acc,[])}),u =>
    nt_choose(Maybe<&2,List<&2,P173ODRow>>,U32.is_gt(left,0) && p98_tag_eq(get,"Mat") && p98_tag_eq(set,"Mat") &&
      U32.is_eq(terms_len(ks(get)),2) && U32.is_eq(terms_len(ks(set)),2) && p88_string_eq(nm(get),nm(set)) &&
      U32.is_eq(ix(get),ix(set)) && U32.is_gt(ix(get),0) && U32.is_le(ix(get),17) && U32.is_eq(qt(get),qt(set)) &&
      Bool.not(nb_contains(seen,nm(set))) && p173od_ctor(book,nm(set),U32.sub(ix(set),1)),
      v => p173od_row_getter(book,get,set,getterRoot,setterRoot,replacement,seen,left,acc,
        p173od_fields(kid(get,0),U32.sub(ix(get),1),nt_choose(List<&2,U32>,U32.is_eq(getterRoot,0),w => [0,replacement],w => [getterRoot]),[])),v => None{}))

@unsafe
def p173od_finish(getterRoot, setterRoot, replacement, rows):
  match rows:
    case None{}: None{}
    case Some{+values}: Some{P173ODSummary{getterRoot,setterRoot,replacement,values}}

@unsafe
def p173od_matched(book, get, set, getterRoot, setterRoot, replacement):
  nt_choose(Maybe<&2,P173ODSummary>,p98_tag_eq(get,"App") && p98_tag_eq(set,"App") &&
    U32.is_eq(terms_len(ks(get)),2) && U32.is_eq(terms_len(ks(set)),2) &&
    p173od_isvar(kid(get,1),getterRoot) && p173od_isvar(kid(set,1),setterRoot),
    u => p173od_finish(getterRoot,setterRoot,replacement,
      p173od_rows(book,kid(get,0),kid(set,0),getterRoot,setterRoot,replacement,[],8,[])),u => None{})

@unsafe
def p173od_replacement(book, get, set, getterRoot, setterRoot):
  nt_choose(Maybe<&2,P173ODSummary>,p98_tag_eq(set,"Lam") && U32.is_eq(terms_len(ks(set)),1) &&
    (U32.is_eq(qt(set),1) || U32.is_eq(qt(set),2)) && Bool.not(U32.is_eq(ix(set),setterRoot)),
    u => p173od_matched(book,get,kid(set,0),getterRoot,setterRoot,ix(set)),u => None{})

@unsafe
def p173od_bodies(book, get, set):
  nt_choose(Maybe<&2,P173ODSummary>,p98_tag_eq(get,"Lam") && p98_tag_eq(set,"Lam") &&
    U32.is_eq(terms_len(ks(get)),1) && U32.is_eq(terms_len(ks(set)),1) &&
    (U32.is_eq(qt(get),1) || U32.is_eq(qt(get),2)) && (U32.is_eq(qt(set),1) || U32.is_eq(qt(set),2)),
    u => p173od_replacement(book,kid(get,0),kid(set,0),ix(get),ix(set)),u => None{})

@unsafe
def p173od_definitions(book, getter, setter):
  nt_choose(Maybe<&2,P173ODSummary>,p88_string_eq(dk(getter),"Def") && p88_string_eq(dk(setter),"Def") &&
    Bool.not(nc_native_def(getter) || nc_native_def(setter) || nc_foreign(getter) || nc_foreign(setter)) &&
    U32.is_eq(dx(getter),0) && U32.is_eq(dx(setter),0),
    u => p173od_entry_bodies(book,nc_definition(book,getter,0),nc_definition(book,setter,0)),u => None{})

@unsafe
def p173od_pair(book, getterName, setterName):
  p173od_definitions(book,lookup(book,getterName),lookup(book,setterName))

# Direct erased matchers have each replacement lambda after their field lambdas.
# Root IDs0 are absent-binder sentinels; actual direct-matcher binders must differ.
@unsafe
def p173od_row_ready(book, get, set, getterRoot, setterRoot, replacement, seen, left, acc, getterFields, getterValue, getterValid, setterFields, setterValue, setterValid):
      nt_choose(Maybe<&2,List<&2,P173ODRow>>,getterValid && setterValid &&
        p173od_getter_value(getterValue,getterFields) &&
        p173od_setter_value(setterValue,setterFields,setterRoot,replacement,nm(set),U32.sub(ix(set),1)),
        u => p173od_rows(book,kid(get,1),kid(set,1),getterRoot,setterRoot,replacement,
          Con{nm(set),seen},U32.sub(left,1),Con{P173ODRow{nm(set),U32.sub(ix(set),1),qt(set),getterFields,getterValue,setterFields,setterValue},acc}),
        u => None{})

@unsafe
def p173od_replace_values(values, old, fresh):
  match values:
    case Nil{}: []
    case Con{+value,+rest}:
      Con{nt_choose(KTerm,p173od_isvar(value,old),u => var(nm(value),fresh),u => value),p173od_replace_values(rest,old,fresh)}

@unsafe
def p173od_row_direct(book, get, set, replacement, seen, left, acc, getterFields, getterValue, getterValid, setterFields, setterValue, setterValid):
  nt_choose(Maybe<&2,List<&2,P173ODRow>>,setterValid && p98_tag_eq(setterValue,"Lam") &&
    U32.is_eq(terms_len(ks(setterValue)),1) && (U32.is_eq(qt(setterValue),1) || U32.is_eq(qt(setterValue),2)) &&
    Bool.not(U32.is_eq(ix(setterValue),0) || p173od_has(setterFields,ix(setterValue))) &&
    p98_tag_eq(kid(setterValue,0),"Ctr") && p173od_setter_value(kid(setterValue,0),setterFields,0,ix(setterValue),nm(set),U32.sub(ix(set),1)),
    u => p173od_row_ready(book,get,set,0,0,replacement,seen,left,acc,getterFields,getterValue,getterValid,setterFields,
      k_with_children(kid(setterValue,0),p173od_replace_values(ks(kid(setterValue,0)),ix(setterValue),replacement)),True{}),
    u => None{})

@unsafe
def p173od_direct_first(book, get, set, fields):
  match fields:
    case P173ODBind{+ids,+body,+valid}:
      nt_choose(Maybe<&2,P173ODSummary>,valid && p98_tag_eq(body,"Lam") &&
        U32.is_eq(terms_len(ks(body)),1) && U32.is_gt(ix(body),0) && Bool.not(p173od_has(ids,ix(body))),
        u => p173od_finish(0,0,ix(body),p173od_rows(book,get,set,0,0,ix(body),[],8,[])),u => None{})

@unsafe
def p173od_entry_bodies(book, get, set):
  nt_choose(Maybe<&2,P173ODSummary>,p98_tag_eq(get,"Mat") && p98_tag_eq(set,"Mat") &&
    U32.is_gt(ix(set),0) && U32.is_le(ix(set),17) && U32.is_eq(terms_len(ks(set)),2),
    u => p173od_direct_first(book,get,set,p173od_fields(kid(set,0),U32.sub(ix(set),1),[0],[])),
    u => p173od_bodies(book,get,set))
