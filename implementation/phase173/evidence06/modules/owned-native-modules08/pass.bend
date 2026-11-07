
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



# Bounded multi-argument specialization of existing one-replacement plans.
# Select alongside the original summary; this adds no backend IR or verifier.
type P173OMArg is Data:
  P173OMGetter{+name: String}
  P173OMValue{+value: KTerm}
  P173OMWork{+getter: String}



type P173OMSchema is Data:
  P173OMSchema{+fields: List<&2,U32>,+params: List<&2,U32>,+body: KTerm}



law p173om_at:
  for +ids: List<&2,U32>
  for +index: U32
  U32



law p173om_project_var:
  for +ids: List<&2,U32>
  for +targets: List<&2,U32>
  for +id: U32
  Maybe<&2,KTerm>



law p173om_project_fields:
  for +targets: List<&2,U32>
  for +bound: P173ODBind
  Maybe<&2,KTerm>



law p173om_project_cases:
  for +body: KTerm
  for +ctor: String
  for +count: U32
  for +mask: U32
  for +targets: List<&2,U32>
  for +fuel: U32
  Maybe<&2,KTerm>



law p173om_project_definition:
  for +book: List<&2,KDef>
  for +definition: KDef
  for +ctor: String
  for +count: U32
  for +mask: U32
  for +targets: List<&2,U32>
  Maybe<&2,KTerm>



law p173om_project:
  for +book: List<&2,KDef>
  for +name: String
  for +ctor: String
  for +count: U32
  for +mask: U32
  for +targets: List<&2,U32>
  Maybe<&2,KTerm>



law p173om_schema_params:
  for +fields: List<&2,U32>
  for +params: P173ODBind
  Maybe<&2,P173OMSchema>



law p173om_schema_fields:
  for +arity: U32
  for +fields: P173ODBind
  Maybe<&2,P173OMSchema>



law p173om_schema:
  for +body: KTerm
  for +arity: U32
  Maybe<&2,P173OMSchema>



law p173om_atom_safe:
  for +term: KTerm
  for +fields: List<&2,U32>
  for +replacement: U32
  Bool



law p173om_resolve_descriptor:
  for +book: List<&2,KDef>
  for +descriptor: P173OMArg
  for +fields: List<&2,U32>
  for +replacement: U32
  for +ctor: String
  for +count: U32
  for +mask: U32
  Maybe<&2,KTerm>



law p173om_resolve_param:
  for +book: List<&2,KDef>
  for +id: U32
  for +params: List<&2,U32>
  for +args: List<&2,P173OMArg>
  for +fields: List<&2,U32>
  for +replacement: U32
  for +ctor: String
  for +count: U32
  for +mask: U32
  Maybe<&2,KTerm>



law p173om_resolve:
  for +book: List<&2,KDef>
  for +value: KTerm
  for +params: List<&2,U32>
  for +args: List<&2,P173OMArg>
  for +fields: List<&2,U32>
  for +replacement: U32
  for +ctor: String
  for +count: U32
  for +mask: U32
  Maybe<&2,KTerm>



law p173om_values_cons:
  for +first: KTerm
  for +rest: Maybe<&2,List<&2,KTerm>>
  Maybe<&2,List<&2,KTerm>>



law p173om_values_first:
  for +book: List<&2,KDef>
  for +rest: List<&2,KTerm>
  for +params: List<&2,U32>
  for +args: List<&2,P173OMArg>
  for +fields: List<&2,U32>
  for +replacement: U32
  for +ctor: String
  for +count: U32
  for +mask: U32
  for +first: Maybe<&2,KTerm>
  Maybe<&2,List<&2,KTerm>>



law p173om_values:
  for +book: List<&2,KDef>
  for +values: List<&2,KTerm>
  for +params: List<&2,U32>
  for +args: List<&2,P173OMArg>
  for +fields: List<&2,U32>
  for +replacement: U32
  for +ctor: String
  for +count: U32
  for +mask: U32
  Maybe<&2,List<&2,KTerm>>



law p173om_work_name:
  for +args: List<&2,P173OMArg>
  for +index: U32
  String



law p173om_work_descriptor:
  for +arg: P173OMArg
  String



law p173om_row_projection:
  for +ctor: String
  for +count: U32
  for +mask: U32
  for +fields: List<&2,U32>
  for +body: KTerm
  for +projection: Maybe<&2,KTerm>
  Maybe<&2,P173ODRow>



law p173om_row_values:
  for +book: List<&2,KDef>
  for +mat: KTerm
  for +fields: List<&2,U32>
  for +body: KTerm
  for +getter: String
  for +replacement: U32
  for +values: Maybe<&2,List<&2,KTerm>>
  Maybe<&2,P173ODRow>



law p173om_row_built:
  for +book: List<&2,KDef>
  for +mat: KTerm
  for +fields: List<&2,U32>
  for +body: KTerm
  for +getter: String
  for +replacement: U32
  Maybe<&2,P173ODRow>



law p173om_row_schema:
  for +book: List<&2,KDef>
  for +mat: KTerm
  for +args: List<&2,P173OMArg>
  for +computed: U32
  for +replacement: U32
  for +schema: Maybe<&2,P173OMSchema>
  Maybe<&2,P173ODRow>



law p173om_rows_join:
  for +book: List<&2,KDef>
  for +rest: KTerm
  for +args: List<&2,P173OMArg>
  for +computed: U32
  for +replacement: U32
  for +fuel: U32
  for +seen: List<&2,String>
  for +acc: List<&2,P173ODRow>
  for +row: Maybe<&2,P173ODRow>
  Maybe<&2,P173ODSummary>



law p173om_rows:
  for +book: List<&2,KDef>
  for +body: KTerm
  for +args: List<&2,P173OMArg>
  for +computed: U32
  for +replacement: U32
  for +fuel: U32
  for +seen: List<&2,String>
  for +acc: List<&2,P173ODRow>
  Maybe<&2,P173ODSummary>



law p173om_first:
  for +book: List<&2,KDef>
  for +body: KTerm
  for +args: List<&2,P173OMArg>
  for +computed: U32
  for +schema: Maybe<&2,P173OMSchema>
  Maybe<&2,P173ODSummary>



law p173om_body:
  for +book: List<&2,KDef>
  for +body: KTerm
  for +args: List<&2,P173OMArg>
  for +computed: U32
  Maybe<&2,P173ODSummary>



law p173om_definition:
  for +book: List<&2,KDef>
  for +definition: KDef
  for +args: List<&2,P173OMArg>
  for +computed: U32
  Maybe<&2,P173ODSummary>



law p173om_pair:
  for +book: List<&2,KDef>
  for +setter: String
  for +args: List<&2,P173OMArg>
  for +computed: U32
  Maybe<&2,P173ODSummary>



law p173om_descriptors:
  for +args: List<&2,P173OMArg>
  for +computed: U32
  for +index: U32
  Bool



law p173om_projection_valid:
  for +projection: Maybe<&2,KTerm>
  Bool



law p173om_arg_valid:
  for +book: List<&2,KDef>
  for +arg: P173OMArg
  for +fields: List<&2,U32>
  for +replacement: U32
  for +ctor: String
  for +count: U32
  for +mask: U32
  Bool



law p173om_all_args:
  for +book: List<&2,KDef>
  for +args: List<&2,P173OMArg>
  for +fields: List<&2,U32>
  for +replacement: U32
  for +ctor: String
  for +count: U32
  for +mask: U32
  Bool



law p173om_parameters:
  for +term: KTerm
  for +left: U32
  for +forbidden: List<&2,U32>
  for +seen: List<&2,U32>
  P173ODBind



@unsafe
def p173om_at(ids, index):
  match ids:
    case Nil{}: 0
    case Con{+head,+rest}: nt_choose(U32,U32.is_eq(index,0),u => head,u => p173om_at(rest,U32.sub(index,1)))



@unsafe
def p173om_project_var(ids, targets, id):
  match ids targets:
    case Con{+head,+rest} Con{+target,+tail}:
      nt_choose(Maybe<&2,KTerm>,U32.is_eq(head,id),u => Some{var("",target)},u => p173om_project_var(rest,tail,id))
    case _ _: None{}



@unsafe
def p173om_project_fields(targets, bound):
  match bound:
    case P173ODBind{+ids,+body,+valid}:
      nt_choose(Maybe<&2,KTerm>,valid && U32.is_eq(nt_count(U32,ids),nt_count(U32,targets)),u =>
        nt_choose(Maybe<&2,KTerm>,p98_tag_eq(body,"Var") && List.is_empty(&2,KTerm,ks(body)),
          v => p173om_project_var(ids,targets,ix(body)),v =>
          nt_choose(Maybe<&2,KTerm>,U32.is_le(p173od_constant(body,32),32),w => Some{body},w => None{})),u => None{})



@unsafe
def p173om_project_cases(body, ctor, count, mask, targets, fuel):
  nt_choose(Maybe<&2,KTerm>,U32.is_gt(fuel,0) && p98_tag_eq(body,"Mat") && U32.is_eq(terms_len(ks(body)),2),u =>
    nt_choose(Maybe<&2,KTerm>,p88_string_eq(nm(body),ctor),v =>
      nt_choose(Maybe<&2,KTerm>,U32.is_eq(ix(body),U32.inc(count)) && U32.is_eq(qt(body),mask),
        w => p173om_project_fields(targets,p173od_fields(kid(body,0),count,[0],[])),w => None{}),
      v => p173om_project_cases(kid(body,1),ctor,count,mask,targets,U32.sub(fuel,1))),u => None{})



@unsafe
def p173om_project_definition(book, definition, ctor, count, mask, targets):
  nt_choose(Maybe<&2,KTerm>,p88_string_eq(dk(definition),"Def") && U32.is_eq(dx(definition),0) &&
    Bool.not(nc_native_def(definition) || nc_foreign(definition)) && U32.is_eq(nd_arity(book,dn(definition)),1),
    u => p173om_project_cases(nc_definition(book,definition,0),ctor,count,mask,targets,8),u => None{})



@unsafe
def p173om_project(book, name, ctor, count, mask, targets):
  p173om_project_definition(book,lookup(book,name),ctor,count,mask,targets)



@unsafe
def p173om_schema_params(fields, params):
  match params:
    case P173ODBind{+ids,+body,+valid}:
      nt_choose(Maybe<&2,P173OMSchema>,valid,u => Some{P173OMSchema{fields,ids,body}},u => None{})



@unsafe
def p173om_schema_fields(arity, fields):
  match fields:
    case P173ODBind{+ids,+body,+valid}:
      nt_choose(Maybe<&2,P173OMSchema>,valid,
        u => p173om_schema_params(ids,p173om_parameters(body,arity,Con{0,ids},[])),u => None{})



@unsafe
def p173om_schema(body, arity):
  p173om_schema_fields(arity,p173od_fields(kid(body,0),U32.sub(ix(body),1),[0],[]))



# A caller atom must not accidentally share an ID with the helper field basis
# or symbolic replacement. Static markers are authenticated by the existing
# request/static-image gate and must be leaf nodes here.
@unsafe
def p173om_atom_safe(term, fields, replacement):
  List.is_empty(&2,KTerm,ks(term)) &&
    nt_choose(Bool,p98_tag_eq(term,"Var"),u => Bool.not(U32.is_eq(ix(term),replacement) || p173od_has(fields,ix(term))),
      u => p98_tag_eq(term,"NWord") || p98_tag_eq(term,"NStatic"))



@unsafe
def p173om_resolve_descriptor(book, descriptor, fields, replacement, ctor, count, mask):
  match descriptor:
    case P173OMGetter{+name}: p173om_project(book,name,ctor,count,mask,fields)
    case P173OMValue{+value}: nt_choose(Maybe<&2,KTerm>,p173om_atom_safe(value,fields,replacement),u => Some{value},u => None{})
    case P173OMWork{getter}: Some{var("",replacement)}



@unsafe
def p173om_resolve_param(book, id, params, args, fields, replacement, ctor, count, mask):
  match params args:
    case Con{+param,+rest} Con{+arg,+tail}:
      nt_choose(Maybe<&2,KTerm>,U32.is_eq(id,param),
        u => p173om_resolve_descriptor(book,arg,fields,replacement,ctor,count,mask),
        u => p173om_resolve_param(book,id,rest,tail,fields,replacement,ctor,count,mask))
    case _ _: None{}



@unsafe
def p173om_resolve(book, value, params, args, fields, replacement, ctor, count, mask):
  nt_choose(Maybe<&2,KTerm>,p98_tag_eq(value,"Var") && List.is_empty(&2,KTerm,ks(value)),u =>
    nt_choose(Maybe<&2,KTerm>,p173od_has(fields,ix(value)),v => Some{value},
      v => p173om_resolve_param(book,ix(value),params,args,fields,replacement,ctor,count,mask)),u => None{})



@unsafe
def p173om_values_cons(first, rest):
  match rest:
    case None{}: None{}
    case Some{+values}: Some{Con{first,values}}



@unsafe
def p173om_values_first(book, rest, params, args, fields, replacement, ctor, count, mask, first):
  match first:
    case None{}: None{}
    case Some{+value}: p173om_values_cons(value,p173om_values(book,rest,params,args,fields,replacement,ctor,count,mask))



@unsafe
def p173om_values(book, values, params, args, fields, replacement, ctor, count, mask):
  match values:
    case Nil{}: Some{[]}
    case Con{+value,+rest}:
      p173om_values_first(book,rest,params,args,fields,replacement,ctor,count,mask,
        p173om_resolve(book,value,params,args,fields,replacement,ctor,count,mask))



@unsafe
def p173om_work_name(args, index):
  match args:
    case Nil{}: ""
    case Con{+head,+rest}:
      nt_choose(String,U32.is_eq(index,0),u => p173om_work_descriptor(head),u => p173om_work_name(rest,U32.sub(index,1)))



@unsafe
def p173om_work_descriptor(arg):
  match arg:
    case P173OMWork{+name}: name
    case _: ""



@unsafe
def p173om_row_projection(ctor, count, mask, fields, body, projection):
  match projection:
    case None{}: None{}
    case Some{+value}: Some{P173ODRow{ctor,count,mask,fields,value,fields,body}}



@unsafe
def p173om_row_values(book, mat, fields, body, getter, replacement, values):
  match values:
    case None{}: None{}
    case Some{+terms}:
      p173om_row_built(book,mat,fields,k_with_children(body,terms),getter,replacement)



@unsafe
def p173om_row_built(book, mat, fields, body, getter, replacement):
  nt_choose(Maybe<&2,P173ODRow>,U32.is_eq(nq_uses(body,replacement),1),
    u => p173om_row_projection(nm(mat),U32.sub(ix(mat),1),qt(mat),fields,body,
      p173om_project(book,getter,nm(mat),U32.sub(ix(mat),1),qt(mat),fields)),u => None{})



# All body fields must originate from a constructor field or a formal argument.
# Unused computed arguments deliberately yield no row: original fallback then
# performs ALL original argument evaluation, including the ignored call.
@unsafe
def p173om_row_schema(book, mat, args, computed, replacement, schema):
  match schema:
    case None{}: None{}
    case Some{P173OMSchema{+fields,+params,+body}}:
      nt_choose(Maybe<&2,P173ODRow>,p98_tag_eq(body,"Ctr") && p88_string_eq(nm(body),nm(mat)) &&
        U32.is_eq(terms_len(ks(body)),U32.sub(ix(mat),1)) && Bool.not(p173od_has(fields,replacement)) &&
        U32.is_eq(nq_uses(body,p173om_at(params,computed)),1),
        u => nt_choose(Maybe<&2,P173ODRow>,p173om_all_args(book,args,fields,replacement,nm(mat),U32.sub(ix(mat),1),qt(mat)),
          v => p173om_row_values(book,mat,fields,body,p173om_work_name(args,computed),replacement,
            p173om_values(book,ks(body),params,args,fields,replacement,nm(mat),U32.sub(ix(mat),1),qt(mat))),v => None{}),u => None{})



@unsafe
def p173om_rows_join(book, rest, args, computed, replacement, fuel, seen, acc, row):
  match row:
    case None{}: p173om_rows(book,rest,args,computed,replacement,fuel,seen,acc)
    case Some{+value}: p173om_rows(book,rest,args,computed,replacement,fuel,seen,Con{value,acc})



@unsafe
def p173om_rows(book, body, args, computed, replacement, fuel, seen, acc):
  nt_choose(Maybe<&2,P173ODSummary>,p173od_efq(body),u =>
    nt_choose(Maybe<&2,P173ODSummary>,List.is_empty(&2,P173ODRow,acc),v => None{},v => Some{P173ODSummary{0,0,replacement,nt_reverse(P173ODRow,acc,[])}}),u =>
    nt_choose(Maybe<&2,P173ODSummary>,U32.is_gt(fuel,0) && p98_tag_eq(body,"Mat") &&
      U32.is_eq(terms_len(ks(body)),2) && U32.is_gt(ix(body),0) && U32.is_le(ix(body),17) &&
      Bool.not(nb_contains(seen,nm(body))) && p173od_ctor(book,nm(body),U32.sub(ix(body),1)),
      v => p173om_rows_join(book,kid(body,1),args,computed,replacement,U32.sub(fuel,1),Con{nm(body),seen},acc,
        p173om_row_schema(book,body,args,computed,replacement,p173om_schema(body,nt_count(P173OMArg,args)))),v => None{}))



@unsafe
def p173om_first(book, body, args, computed, schema):
  match schema:
    case None{}: None{}
    case Some{P173OMSchema{fields,+params,value}}:
      nt_choose(Maybe<&2,P173ODSummary>,U32.is_gt(p173om_at(params,computed),0),
        u => p173om_rows(book,body,args,computed,p173om_at(params,computed),8,[],[]),u => None{})



@unsafe
def p173om_body(book, body, args, computed):
  nt_choose(Maybe<&2,P173ODSummary>,p98_tag_eq(body,"Mat") && U32.is_eq(terms_len(ks(body)),2) &&
    U32.is_gt(ix(body),0) && U32.is_le(ix(body),17),
    u => p173om_first(book,body,args,computed,p173om_schema(body,nt_count(P173OMArg,args))),u => None{})



@unsafe
def p173om_definition(book, definition, args, computed):
  nt_choose(Maybe<&2,P173ODSummary>,p88_string_eq(dk(definition),"Def") && U32.is_eq(dx(definition),0) &&
    Bool.not(nc_native_def(definition) || nc_foreign(definition)) &&
    U32.is_eq(nd_arity(book,dn(definition)),U32.inc(nt_count(P173OMArg,args))),
    u => p173om_body(book,nc_definition(book,definition,0),args,computed),u => None{})



@unsafe
def p173om_pair(book, setter, args, computed):
  nt_choose(Maybe<&2,P173ODSummary>,U32.is_gt(nt_count(P173OMArg,args),1) && U32.is_le(nt_count(P173OMArg,args),7) &&
    U32.is_lt(computed,nt_count(P173OMArg,args)) && p173om_descriptors(args,computed,0) && Bool.not(String.is_empty(p173om_work_name(args,computed))),
    u => p173om_definition(book,lookup(book,setter),args,computed),u => None{})



# Do not trust a caller-supplied descriptor vector to contain only one work slot.
@unsafe
def p173om_descriptors(args, computed, index):
  match args:
    case Nil{}: True{}
    case Con{P173OMWork{getter},+rest}:
      U32.is_eq(index,computed) && p173om_descriptors(rest,computed,U32.inc(index))
    case Con{P173OMGetter{name},+rest}:
      Bool.not(U32.is_eq(index,computed)) && p173om_descriptors(rest,computed,U32.inc(index))
    case Con{P173OMValue{value},+rest}:
      Bool.not(U32.is_eq(index,computed)) && p173om_descriptors(rest,computed,U32.inc(index))



# Every erased getter call must be certified, including an argument the setter
# ignores. Otherwise strict divergent/error/effectful getter work could vanish.
@unsafe
def p173om_projection_valid(projection):
  match projection:
    case None{}: False{}
    case Some{value}: True{}



@unsafe
def p173om_arg_valid(book, arg, fields, replacement, ctor, count, mask):
  match arg:
    case P173OMGetter{+name}: p173om_projection_valid(p173om_project(book,name,ctor,count,mask,fields))
    case P173OMWork{+name}: p173om_projection_valid(p173om_project(book,name,ctor,count,mask,fields))
    case P173OMValue{+value}: p173om_atom_safe(value,fields,replacement)



@unsafe
def p173om_all_args(book, args, fields, replacement, ctor, count, mask):
  match args:
    case Nil{}: True{}
    case Con{+arg,+rest}:
      nt_choose(Bool,p173om_arg_valid(book,arg,fields,replacement,ctor,count,mask),
        u => p173om_all_args(book,rest,fields,replacement,ctor,count,mask),u => False{})



# Formal arguments have already been evaluated at the call. Their original
# affine/unrestricted quantities both admit, unlike decomposed fields whose
# quantity2 contract is needed for observation plus retained-field use.
@unsafe
def p173om_parameters(term, left, forbidden, seen):
  nt_choose(P173ODBind,U32.is_eq(left,0),u => P173ODBind{nt_reverse(U32,seen,[]),term,True{}},u =>
    nt_choose(P173ODBind,p98_tag_eq(term,"Lam") && U32.is_eq(terms_len(ks(term)),1) &&
      (U32.is_eq(qt(term),1) || U32.is_eq(qt(term),2)) &&
      Bool.not(p173od_has(forbidden,ix(term)) || p173od_has(seen,ix(term))),
      v => p173om_parameters(kid(term,0),U32.sub(left,1),forbidden,Con{ix(term),seen}),
      v => P173ODBind{[],term,False{}}))



# Multi-argument entry variant; original two-argument transform is unchanged.
# Select this module IN PLACE OF owned-decomposition.bend, never alongside it.
# Experimental ordinary owned-field decomposition before QBE ownership lowering.
# Pair summaries are authenticated by owned-decomposition-summary.bend.
type P173OAResult is Data:
  P173OAResult{+term: KTerm, +next: U32, +hits: U32}



type P173OAList is Data:
  P173OAList{+terms: List<&2,KTerm>, +next: U32, +hits: U32}



type P173OABook is Data:
  P173OABook{+index: KDef, +next: U32, +hits: U32}



law p173om_application:
  for +book: List<&2,KDef>
  for +term: KTerm
  for +next: U32
  for +setter: KTerm
  for +args: List<&2,KTerm>
  P173OAResult



# Hoisted contracts keep the pinned sequential loader deterministic.
law p173oa_var:
  for +term: KTerm
  for +id: U32
  Bool



law p173oa_atom:
  for +term: KTerm
  for +root: U32
  Bool



law p173oa_atoms:
  for terms: List<&2,KTerm>
  for +root: U32
  Bool



law p173oa_user:
  for +book: List<&2,KDef>
  for +head: KTerm
  for +arity: U32
  Bool



law p173oa_definition:
  for +book: List<&2,KDef>
  for +definition: KDef
  for +arity: U32
  Bool



law p173oa_rename:
  for +term: KTerm
  for ids: List<&2,U32>
  for +next: U32
  KTerm



law p173oa_lambdas:
  for +count: U32
  for +next: U32
  for +body: KTerm
  KTerm



law p173oa_result_fields:
  for +summary: P173ODSummary
  for +row: P173ODRow
  for +next: U32
  for +result: U32
  KTerm



law p173oa_row_body:
  for +summary: P173ODSummary
  for +row: P173ODRow
  for +call: KTerm
  for +other: List<&2,KTerm>
  for +next: U32
  KTerm



law p173oa_row_changed:
  for +summary: P173ODSummary
  for +row: P173ODRow
  Bool



law p173oa_row_width:
  for row: P173ODRow
  U32



law p173oa_row_join:
  for +row: P173ODRow
  for +summary: P173ODSummary
  for +call: KTerm
  for +other: List<&2,KTerm>
  for +start: U32
  for tail: P173OAResult
  P173OAResult



law p173oa_pair_result:
  for +term: KTerm
  for +root: KTerm
  for +call: KTerm
  for +other: List<&2,KTerm>
  for +next: U32
  for pair: Maybe<&2,P173ODSummary>
  P173OAResult



law p173oa_summary_result:
  for +term: KTerm
  for +root: KTerm
  for +call: KTerm
  for +other: List<&2,KTerm>
  for +next: U32
  for +summary: P173ODSummary
  P173OAResult



law p173oa_ids_fresh:
  for ids: List<&2,U32>
  for +next: U32
  Bool



law p173oa_rows_fresh:
  for rows: List<&2,P173ODRow>
  for +next: U32
  Bool



law p173oa_apply_rows:
  for +original: KTerm
  for +root: KTerm
  for +start: U32
  for built: P173OAResult
  P173OAResult



law p173oa_getter:
  for +book: List<&2,KDef>
  for +term: KTerm
  for +setter: KTerm
  for +root: KTerm
  for +call: KTerm
  for +getter: KTerm
  for +other: List<&2,KTerm>
  for +next: U32
  P173OAResult



law p173oa_call:
  for +book: List<&2,KDef>
  for +term: KTerm
  for +setter: KTerm
  for +root: KTerm
  for +value: KTerm
  for +next: U32
  P173OAResult



law p173oa_getter_args:
  for +book: List<&2,KDef>
  for +term: KTerm
  for +setter: KTerm
  for +root: KTerm
  for +call: KTerm
  for +head: KTerm
  for +other: List<&2,KTerm>
  for +next: U32
  for args: List<&2,KTerm>
  P173OAResult



law p173oa_call_args:
  for +book: List<&2,KDef>
  for +term: KTerm
  for +setter: KTerm
  for +root: KTerm
  for +head: KTerm
  for +next: U32
  for +args: List<&2,KTerm>
  P173OAResult



law p173oa_try:
  for +book: List<&2,KDef>
  for +term: KTerm
  for +next: U32
  P173OAResult



law p173oa_application:
  for +book: List<&2,KDef>
  for +term: KTerm
  for +next: U32
  for +setter: KTerm
  for args: List<&2,KTerm>
  P173OAResult



law p173oa_tried:
  for +book: List<&2,KDef>
  for +term: KTerm
  for +fuel: U32
  for +tried: P173OAResult
  P173OAResult



law p173oa_rebuild:
  for +term: KTerm
  for children: P173OAList
  P173OAResult



law p173oa_first:
  for +book: List<&2,KDef>
  for +rest: List<&2,KTerm>
  for +fuel: U32
  for first: P173OAResult
  P173OAList



law p173oa_cons:
  for term: KTerm
  for hits: U32
  for rest: P173OAList
  P173OAList



law p173oa_definition_done:
  for +book: List<&2,KDef>
  for +prepared: List<&2,KDef>
  for +rest: List<&2,String>
  for +index: KDef
  for +hits: U32
  for +fact: KDef
  for result: P173OAResult
  P173OABook



law p173oa_context:
  for +context: KDef
  for index: KDef
  KDef



law p173oa_publish:
  for +prepared: List<&2,KDef>
  for changed: P173OABook
  List<&2,KDef>



law p173oa_walk:
  for +book: List<&2,KDef>
  for +term: KTerm
  for +next: U32
  for +fuel: U32
  P173OAResult



law p173oa_terms:
  for +book: List<&2,KDef>
  for terms: List<&2,KTerm>
  for +next: U32
  for +fuel: U32
  P173OAList



law p173oa_rows:
  for rows: List<&2,P173ODRow>
  for +summary: P173ODSummary
  for +call: KTerm
  for +other: List<&2,KTerm>
  for +fallback: KTerm
  for +next: U32
  P173OAResult



law p173oa_definitions:
  for +book: List<&2,KDef>
  for +prepared: List<&2,KDef>
  for names: List<&2,String>
  for +index: KDef
  for +next: U32
  for +hits: U32
  P173OABook



@unsafe
def p173oa_var(term, id):
  p98_tag_eq(term,"Var") && U32.is_eq(ix(term),id) && List.is_empty(&2,KTerm,ks(term))



# The initial composition accepts only already evaluated external arguments.
# Root identity may not occur in another argument or in a call head.
@unsafe
def p173oa_atom(term, root):
  nt_choose(Bool,p98_tag_eq(term,"Var"),u => List.is_empty(&2,KTerm,ks(term)) && Bool.not(U32.is_eq(ix(term),root)),
    u => p98_tag_eq(term,"NWord") || p98_tag_eq(term,"NStatic"))



@unsafe
def p173oa_atoms(terms, root):
  match terms:
    case Nil{}: True{}
    case Con{head,rest}: p173oa_atom(head,root) && p173oa_atoms(rest,root)



@unsafe
def p173oa_user(book, head, arity):
  nt_choose(Bool,p98_tag_eq(head,"Ref") && List.is_empty(&2,KTerm,ks(head)) && Bool.not(U32.is_eq(qt(head),3)),
    u => p173oa_definition(book,lookup(book,nm(head)),arity),u => False{})



@unsafe
def p173oa_definition(book, definition, arity):
  String.eq(dk(definition),"Def") && Bool.not(nc_native_def(definition) || nc_foreign(definition)) &&
    U32.is_eq(nd_arity(book,dn(definition)),arity)



# Replace only field-variable identities. Fresh replacements are disjoint from
# every source binder; no beta reduction or normalization is performed.
@unsafe
def p173oa_rename(term, ids, next):
  match ids:
    case Nil{}: term
    case Con{id,rest}: p173oa_rename(nq_layout_subst(term,id,var("",next)),rest,U32.inc(next))



@unsafe
def p173oa_lambdas(count, next, body):
  nt_choose(KTerm,U32.is_eq(count,0),u => body,
    u => k_lam("",next,2,[p173oa_lambdas(U32.sub(count,1),U32.inc(next),body)],0,0,False{}))



@unsafe
def p173oa_result_fields(summary, row, next, result):
  match summary row:
    case P173ODSummary{getterRoot,setterRoot,replacement,rows}
      P173ODRow{ctor,count,mask,getterFields,getterValue,setterFields,setterValue}:
      nq_layout_subst(p173oa_rename(setterValue,setterFields,next),replacement,var("",result))



@unsafe
def p173oa_row_body(summary, row, call, other, next):
  match row:
    case P173ODRow{ctor,+count,mask,getterFields,getterValue,setterFields,setterValue}:
      +result = U32.add(next,count)
      nc_mklet(result,nd_reapply(call,Con{p173oa_rename(getterValue,getterFields,next),other}),
        p173oa_result_fields(summary,row,next,result))



@unsafe
def p173oa_row_changed(summary, row):
  match summary row:
    case P173ODSummary{getterRoot,setterRoot,replacement,rows}
      P173ODRow{ctor,count,mask,getterFields,getterValue,setterFields,+setterValue}:
      Bool.not(p173oa_var(setterValue,setterRoot)) && nu_has(nc_uses(setterValue),replacement)



@unsafe
def p173oa_rows(rows, summary, call, other, fallback, next):
  match rows:
    case Nil{}: P173OAResult{fallback,next,0}
    case Con{+row,+rest}:
      nt_choose(P173OAResult,p173oa_row_changed(summary,row),
        u => p173oa_row_join(row,summary,call,other,next,
          p173oa_rows(rest,summary,call,other,fallback,U32.add(next,U32.inc(p173oa_row_width(row))))),
        u => p173oa_rows(rest,summary,call,other,fallback,next))



@unsafe
def p173oa_row_width(row):
  match row:
    case P173ODRow{ctor,count,mask,getterFields,getterValue,setterFields,setterValue}: count



@unsafe
def p173oa_row_join(row, summary, call, other, start, tail):
  match row tail:
    case P173ODRow{ctor,+count,mask,getterFields,getterValue,setterFields,setterValue}
      P173OAResult{rest,next,hits}:
      P173OAResult{kt("Mat",ctor,U32.inc(count),mask,
        [p173oa_lambdas(count,start,p173oa_row_body(summary,row,call,other,start)),rest]),next,U32.inc(hits)}



@unsafe
def p173oa_pair_result(term, root, call, other, next, pair):
  match pair:
    case None{}: P173OAResult{term,next,0}
    case Some{+summary}:
      p173oa_summary_result(term,root,call,other,next,summary)



@unsafe
def p173oa_summary_result(term, root, call, other, next, summary):
  match summary:
    case P173ODSummary{getterRoot,setterRoot,replacement,+rows}:
      nt_choose(P173OAResult,U32.is_lt(norm_max_term(term),next) && U32.is_lt(getterRoot,next) && U32.is_lt(setterRoot,next) &&
        U32.is_lt(replacement,next) && p173oa_rows_fresh(rows,next),
        u => p173oa_apply_rows(term,root,next,p173oa_rows(rows,summary,call,other,
          k_lam("",next,2,[nq_layout_subst(term,ix(root),var("",next))],0,0,False{}),U32.inc(next))),
        u => P173OAResult{term,next,0})



@unsafe
def p173oa_ids_fresh(ids, next):
  match ids:
    case Nil{}: True{}
    case Con{id,rest}: U32.is_lt(id,next) && p173oa_ids_fresh(rest,next)



@unsafe
def p173oa_rows_fresh(rows, next):
  match rows:
    case Nil{}: True{}
    case Con{P173ODRow{ctor,count,mask,getterFields,getterValue,setterFields,setterValue},rest}:
      p173oa_ids_fresh(getterFields,next) && p173oa_ids_fresh(setterFields,next) &&
        U32.is_lt(norm_max_term(getterValue),next) && U32.is_lt(norm_max_term(setterValue),next) &&
        p173oa_rows_fresh(rest,next)



@unsafe
def p173oa_apply_rows(original, root, start, built):
  match built:
    case P173OAResult{matcher,next,+hits}:
      nt_choose(P173OAResult,U32.is_gt(hits,0),
        u => P173OAResult{app(matcher,root),next,hits},u => P173OAResult{original,start,0})



@unsafe
def p173oa_getter(book, term, setter, root, call, getter, other, next):
  p173oa_getter_args(book,term,setter,root,call,nd_head(getter),other,next,nd_args(getter,[]))



@unsafe
def p173oa_getter_args(book, term, setter, root, call, head, other, next, args):
  match args:
    case Con{arg,Nil{}}:
      nt_choose(P173OAResult,p173oa_var(arg,ix(root)) && p173oa_user(book,head,1),
        u => p173oa_pair_result(term,root,call,other,next,p173od_pair(book,nm(head),nm(setter))),
        u => P173OAResult{term,next,0})
    case _: P173OAResult{term,next,0}



@unsafe
def p173oa_call(book, term, setter, root, value, next):
  p173oa_call_args(book,term,setter,root,nd_head(value),next,nd_args(value,[]))



@unsafe
def p173oa_call_args(book, term, setter, root, head, next, args):
  match args:
    case Con{getter,+other}:
      nt_choose(P173OAResult,p173oa_user(book,head,terms_len(args)) && p173oa_atoms(other,ix(root)),
        u => p173oa_getter(book,term,setter,root,head,getter,other,next),
        u => P173OAResult{term,next,0})
    case _: P173OAResult{term,next,0}



@unsafe
def p173oa_try(book, term, next):
  nt_choose(P173OAResult,p98_tag_eq(term,"App") && U32.is_lt(next,3999999000),
    u => p173oa_application(book,term,next,nd_head(term),nd_args(term,[])),
    u => P173OAResult{term,next,0})



@unsafe
def p173oa_application(book, term, next, setter, args):
  match args:
    case Con{+root,Con{value,Nil{}}}:
      nt_choose(P173OAResult,p173oa_var(root,ix(root)) && p173oa_user(book,setter,2),
        u => p173oa_call(book,term,setter,root,value,next),u => P173OAResult{term,next,0})
    case _: p173om_application(book,term,next,setter,args)



@unsafe
def p173oa_walk(book, term, next, fuel):
  nt_choose(P173OAResult,U32.is_eq(fuel,0),u => P173OAResult{term,next,0},
    u => p173oa_tried(book,term,fuel,p173oa_try(book,term,next)))



@unsafe
def p173oa_tried(book, term, fuel, tried):
  match tried:
    case P173OAResult{result,next,+hits}:
      nt_choose(P173OAResult,U32.is_gt(hits,0),u => tried,
        u => p173oa_rebuild(term,p173oa_terms(book,ks(term),next,U32.sub(fuel,1))))



@unsafe
def p173oa_rebuild(term, children):
  match children:
    case P173OAList{terms,next,+hits}:
      P173OAResult{nt_choose(KTerm,U32.is_gt(hits,0),u => k_with_children(term,terms),u => term),next,hits}



@unsafe
def p173oa_terms(book, terms, next, fuel):
  match terms:
    case Nil{}: P173OAList{[],next,0}
    case Con{head,rest}: p173oa_first(book,rest,fuel,p173oa_walk(book,head,next,fuel))



@unsafe
def p173oa_first(book, rest, fuel, first):
  match first:
    case P173OAResult{term,next,hits}: p173oa_cons(term,hits,p173oa_terms(book,rest,next,fuel))



@unsafe
def p173oa_cons(term, hits, rest):
  match rest:
    case P173OAList{terms,next,more}: P173OAList{Con{term,terms},next,U32.add(hits,more)}



# The input book is the original checked/erased request; summaries cannot be
# influenced by an earlier rewrite in this traversal. Static data is unchanged.
@unsafe
def p173oa_definitions(book, prepared, names, index, next, hits):
  match names:
    case Nil{}: P173OABook{index,next,hits}
    case Con{+name,+rest}:
      +fact = ns_body(prepared,name)
      nt_choose(P173OABook,String.eq(dk(fact),"NativeStaticBody"),
        u => p173oa_definition_done(book,prepared,rest,index,hits,fact,p173oa_walk(book,dv(fact),next,4096)),
        u => p173oa_definitions(book,prepared,rest,index,next,hits))



@unsafe
def p173oa_definition_done(book, prepared, rest, index, hits, fact, result):
  match result:
    case P173OAResult{term,next,+more}:
      p173oa_definitions(book,prepared,rest,
        nt_choose(KDef,U32.is_gt(more,0),u => index_set(index,
          KDef{dn(fact),dk(fact),da(fact),dx(fact),dt(fact),term,dc(fact),db(fact),du(fact)},
          index_hash(dn(fact),2166136261),32),u => index),next,U32.add(hits,more))



@unsafe
def p173oa_context(context, index):
  match context:
    case KDef{name,kind,arity,templates,typ,value,Con{old,rest},native,unsafe}:
      KDef{name,kind,arity,templates,typ,value,Con{index,rest},native,unsafe}
    case _: context



@unsafe
def p173oa_publish(prepared, changed):
  match prepared changed:
    case Con{KDef{name,kind,arity,templates,typ,value,Con{source,Con{context,tail}},native,unsafe},rest}
      P173OABook{index,next,+hits}:
      nt_choose(List<&2,KDef>,U32.is_gt(hits,0),
        u => Con{KDef{name,kind,U32.max(arity,next),templates,typ,value,
          Con{source,Con{p173oa_context(context,index),tail}},native,unsafe},rest},u => prepared)
    case _ _: prepared



# Call-site recognition only; actual helper semantics come from the independent
# bounded summaries. All unchanged arguments are projections or evaluated atoms.
type P173OMCall is Data:
  P173OMCall{+valid: Bool,+args: List<&2,P173OMArg>,+computed: U32,+call: KTerm,+other: List<&2,KTerm>}



law p173om_bad:
  P173OMCall



law p173om_collect:
  for +book: List<&2,KDef>
  for +root: U32
  for +args: List<&2,KTerm>
  for +index: U32
  for +acc: List<&2,P173OMArg>
  for +found: U32
  for +computed: U32
  for +call: KTerm
  for +other: List<&2,KTerm>
  P173OMCall



law p173om_collect_call:
  for +book: List<&2,KDef>
  for +root: U32
  for +arg: KTerm
  for +rest: List<&2,KTerm>
  for +index: U32
  for +acc: List<&2,P173OMArg>
  for +found: U32
  for +computed: U32
  for +call: KTerm
  for +other: List<&2,KTerm>
  for +head: KTerm
  for +args: List<&2,KTerm>
  P173OMCall



law p173om_collect_work:
  for +book: List<&2,KDef>
  for +root: U32
  for +rest: List<&2,KTerm>
  for +index: U32
  for +acc: List<&2,P173OMArg>
  for +found: U32
  for +head: KTerm
  for +args: List<&2,KTerm>
  P173OMCall



law p173om_collect_getter:
  for +book: List<&2,KDef>
  for +root: U32
  for +rest: List<&2,KTerm>
  for +index: U32
  for +acc: List<&2,P173OMArg>
  for +call: KTerm
  for +other: List<&2,KTerm>
  for +head: KTerm
  for +args: List<&2,KTerm>
  P173OMCall



law p173om_collected:
  for +book: List<&2,KDef>
  for +term: KTerm
  for +setter: KTerm
  for +root: KTerm
  for +next: U32
  for +collected: P173OMCall
  P173OAResult



@unsafe
def p173om_bad():
  P173OMCall{False{},[],0,atom("Absent"),[]}



@unsafe
def p173om_collect(book, root, args, index, acc, found, computed, call, other):
  match args:
    case Nil{}: P173OMCall{U32.is_eq(found,1),nt_reverse(P173OMArg,acc,[]),computed,call,other}
    case Con{+arg,+rest}:
      nt_choose(P173OMCall,U32.is_lt(index,7),u =>
        nt_choose(P173OMCall,p173oa_atom(arg,root) && List.is_empty(&2,KTerm,ks(arg)),
          v => p173om_collect(book,root,rest,U32.inc(index),Con{P173OMValue{arg},acc},found,computed,call,other),
          v => p173om_collect_call(book,root,arg,rest,index,acc,found,computed,call,other,nd_head(arg),nd_args(arg,[]))),u => p173om_bad())



@unsafe
def p173om_collect_call(book, root, arg, rest, index, acc, found, computed, call, other, head, args):
  match args:
    case Con{+first,Nil{}}:
      nt_choose(P173OMCall,p173oa_var(first,root) && p173oa_user(book,head,1),
        u => p173om_collect(book,root,rest,U32.inc(index),Con{P173OMGetter{nm(head)},acc},found,computed,call,other),
        u => p173om_collect_work(book,root,rest,index,acc,found,head,args))
    case _: p173om_collect_work(book,root,rest,index,acc,found,head,args)



@unsafe
def p173om_collect_work(book, root, rest, index, acc, found, head, args):
  match args:
    case Con{+getter,+other}:
      nt_choose(P173OMCall,U32.is_eq(found,0) && p173oa_user(book,head,terms_len(args)) && p173oa_atoms(other,root),
        u => p173om_collect_getter(book,root,rest,index,acc,head,other,nd_head(getter),nd_args(getter,[])),u => p173om_bad())
    case _: p173om_bad()



@unsafe
def p173om_collect_getter(book, root, rest, index, acc, call, other, head, args):
  match args:
    case Con{+arg,Nil{}}:
      nt_choose(P173OMCall,p173oa_var(arg,root) && p173oa_user(book,head,1),
        u => p173om_collect(book,root,rest,U32.inc(index),Con{P173OMWork{nm(head)},acc},1,index,call,other),u => p173om_bad())
    case _: p173om_bad()



@unsafe
def p173om_collected(book, term, setter, root, next, collected):
  match collected:
    case P173OMCall{+valid,+args,+computed,+call,+other}:
      nt_choose(P173OAResult,valid,
        u => nt_choose(P173OAResult,p173oa_user(book,setter,U32.inc(nt_count(P173OMArg,args))),
          v => p173oa_pair_result(term,root,call,other,next,p173om_pair(book,nm(setter),args,computed)),
          v => P173OAResult{term,next,0}),
        u => P173OAResult{term,next,0})



@unsafe
def p173om_application(book, term, next, setter, args):
  match args:
    case Con{+root,+rest}:
      nt_choose(P173OAResult,p173oa_var(root,ix(root)) && U32.is_gt(terms_len(rest),1) && U32.is_le(terms_len(rest),7) &&
        p98_tag_eq(setter,"Ref") && List.is_empty(&2,KTerm,ks(setter)) && Bool.not(U32.is_eq(qt(setter),3)),
        u => p173om_collected(book,term,setter,root,next,p173om_collect(book,ix(root),rest,0,[],0,0,atom("Absent"),[])),
        u => P173OAResult{term,next,0})
    case _: P173OAResult{term,next,0}



# Separate QBE-only permission variant; frozen pure v2 remains unchanged.
# Preconditions: source checked by p86_plan; selected fixed QBE runtime/provider
# bytes authenticated by acquisition/build receipts; p169np_plan runtime gate;
# p168_request_mode checked source/layout/observer admission. These internal
# helpers do not authenticate a forged book or a caller-provided permission.

# This conservative extra certificate permits known IO/File effects while
# excluding arbitrary foreign code and Rwt. It is NOT a purity proof. Its
# whole-body walk is charged as additional experimental compilation cost.
# The broader fixed-runtime gate already ran; do not repeat it on this path.
@unsafe
def p173op_prepared(book, names, prepared):
  match prepared:
    case P112SPrepared{+ready,nodes,+error}:
      nt_choose(P112SPrepared,String.is_empty(error) &&
        String.eq(dk(ns_context(ready)),"NativeStaticContext") &&
        U32.is_lt(norm_book_bound(book),3999998000) && p118ns_effect_definitions(True{},book,names),
        u => P112SPrepared{p173oa_publish(ready,p173oa_definitions(book,ready,names,
          index_first(dc(ns_context(ready))),U32.inc(norm_book_bound(book)),0)),nodes,error},
        u => prepared)
