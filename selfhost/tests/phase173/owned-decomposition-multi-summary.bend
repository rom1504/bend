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
