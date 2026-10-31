
@unsafe
def p131p_parameter(+id: U32, params: List<&2,KTerm>) -> Bool:
  match params:
    case Nil{}: False{}
    case Con{p,rest}: U32.is_eq(ix(p),id) || p131p_parameter(id,rest)


@unsafe
def p131p_wrapper_fields(fields: List<&2,KTerm>, +params: List<&2,KTerm>, +result: U32, +depth: U32) -> Bool:
  match fields:
    case Nil{}: True{}
    case Con{head,rest}: p131p_wrapper_ok(head,params,result,depth) && p131p_wrapper_fields(rest,params,result,depth)


@unsafe
def p131p_wrapper_ok(+t: KTerm, +params: List<&2,KTerm>, +result: U32, +depth: U32) -> Bool:
  nt_choose(Bool,String.eq(tg(t),"Var"),u => U32.is_eq(ix(t),result) || p131p_parameter(ix(t),params),u =>
    String.eq(tg(t),"Ctr") && U32.is_lt(depth,2) && p131p_wrapper_fields(ks(t),params,result,U32.inc(depth)))


@unsafe
def p131p_argument(+id: U32, params: List<&2,KTerm>, args: List<&2,KTerm>) -> KTerm:
  match params args:
    case Con{p,rest} Con{arg,more}:
      nt_choose(KTerm,U32.is_eq(ix(p),id),u => arg,u => p131p_argument(id,rest,more))
    case _ _: atom("Absent")


@unsafe
def p131p_virtual_fields(fields: List<&2,KTerm>, +params: List<&2,KTerm>, +args: List<&2,KTerm>, +result: U32, +scalar: KTerm) -> List<&2,KTerm>:
  match fields:
    case Nil{}: []
    case Con{head,rest}: Con{p131p_virtual(head,params,args,result,scalar),p131p_virtual_fields(rest,params,args,result,scalar)}


@unsafe
def p131p_virtual(+t: KTerm, +params: List<&2,KTerm>, +args: List<&2,KTerm>, +result: U32, +scalar: KTerm) -> KTerm:
  nt_choose(KTerm,String.eq(tg(t),"Var"),u =>
    nt_choose(KTerm,U32.is_eq(ix(t),result),v => scalar,v => p131p_argument(ix(t),params,args)),u =>
    nt_choose(KTerm,String.eq(tg(t),"Ctr"),v => kt("OC",nm(t),0,0,p131p_virtual_fields(ks(t),params,args,result,scalar)),v => atom("Absent")))


@unsafe
def p131p_reader(+reader: String, +arity: U32, functions: List<&2,P113DFunction>) -> Bool:
  match functions:
    case Nil{}: False{}
    case Con{P113DFunction{name,params,result,public,body},rest}:
      nt_choose(Bool,String.eq(name,reader),u => Bool.not(public) && U32.is_eq(result,1) &&
        U32.is_eq(nt_count(NC_Binding,params),arity),u => p131p_reader(reader,arity,rest))


@unsafe
def p131p_controls() -> List<&2,String>:
  +a : KTerm = var("String",10)
  +b : KTerm = var("String",11)
  +r : KTerm = var("Cmp",12)
  +params : List<&2,KTerm> = [a,b]
  +left : KTerm = noa_atom("String",kt("OArg","",0,0,[]),var("",101))
  +right : KTerm = noa_atom("String",kt("OChild","",1,0,[kt("OArg","",1,0,[])]),var("",102))
  +scalar : KTerm = noa_atom("Cmp",kt("OUnique","",200,0,[]),var("",200))
  +roots : KTerm = kt("Ctr","Tuple",0,0,[a,b])
  +wrapper : KTerm = kt("Ctr","Tuple",0,0,[roots,r])
  +value : KTerm = p131p_virtual(wrapper,params,[left,right],12,scalar)
  [p128bs_control_row("projection-known-wrapper",p131p_wrapper_ok(wrapper,params,12,0)),
   p128bs_control_row("projection-scalar-wrapper",p131p_wrapper_ok(r,params,12,0)),
   p128bs_control_row("projection-unbound-refused",Bool.not(p131p_wrapper_ok(var("String",99),params,12,0))),
   p128bs_control_row("projection-effect-refused",Bool.not(p131p_wrapper_ok(kt("App","",0,0,[a,b]),params,12,0))),
   p128bs_control_row("projection-extra-shell-refused",Bool.not(p131p_wrapper_ok(kt("Ctr","Tuple",0,0,[wrapper,r]),params,12,0))),
   p128bs_control_row("projection-result-disjoint",Bool.not(p131p_parameter(12,params))),
   p128bs_control_row("projection-collision-detected",p131p_parameter(10,params)),
   p128bs_control_row("projection-outer-virtual",String.eq(tg(value),"OC") && String.eq(nm(value),"Tuple")),
   p128bs_control_row("projection-inner-virtual",String.eq(tg(kid(value,0)),"OC")),
   p128bs_control_row("projection-left-origin-preserved",norm_exact(kid(kid(value,0),0),left)),
   p128bs_control_row("projection-right-origin-preserved",norm_exact(kid(kid(value,0),1),right)),
   p128bs_control_row("projection-result-rebound",norm_exact(kid(value,1),scalar)),
   p128bs_control_row("projection-scalar-unchanged",norm_exact(p131p_virtual(r,params,[left,right],12,scalar),scalar)),
   p128bs_control_row("projection-missing-reader-refused",Bool.not(p131p_reader("missing",2,[])))]

@unsafe
def p131p_has_product(helpers: List<&2,P128BRHelper>) -> Bool:
  match helpers:
    case Nil{}: False{}
    case Con{P128BRHelper{owner,params,roots,result,reader,wrapper,resultId},rest}:
      String.eq(tg(wrapper),"Ctr") || p131p_has_product(rest)


@unsafe
def p131p_scalar_helpers(helpers: List<&2,P128BRHelper>) -> List<&2,P128BRHelper>:
  match helpers:
    case Nil{}: []
    case Con{+head,+rest}:
      match head:
        case P128BRHelper{owner,params,roots,result,reader,wrapper,resultId}:
          nt_choose(List<&2,P128BRHelper>,String.eq(tg(wrapper),"Var"),
            u => Con{head,p131p_scalar_helpers(rest)},u => p131p_scalar_helpers(rest))


@unsafe
def p131p_retry(+book: List<&2,KDef>, +retry: List<&2,NO_Plan>, +closed: List<&2,P113DFunction>, +helpers: List<&2,P128BRHelper>) -> P128BRPatches:
  p128br_retry_plans(book,retry,closed,helpers)


@unsafe
def p131p_complete(+static: P112StaticProgram, +certificate: P113ACertificate, +closed: List<&2,P113DFunction>, patches: P128BRPatches) -> P111Emission:
  match patches:
    case P128BRPatches{edits,+error}:
      nt_choose(P111Emission,String.is_empty(error),
        u => p126bp_complete(static,certificate,p128br_apply(closed,edits)),
        u => P111Emission{[],"product projection retry: " ++ error})


@unsafe
def p131p_close(+raw: List<&2,P113DCandidate>, +book: List<&2,KDef>, original: P113AProgram, +added: List<&2,P113DFunction>, +helpers: List<&2,P128BRHelper>, +retry: List<&2,NO_Plan>) -> P111Emission:
  match original:
    case P113AProgram{P113DProgram{+static,+functions},+certificate}:
      +checked = p128br_check_added(static,added)
      nt_choose(P111Emission,String.is_empty(checked),u =>
        p131p_closed(raw,book,static,certificate,helpers,retry,
          nt_append(P113DFunction,added,p118b_without(functions,p113e_signatures(added,missing())))),
        u => P111Emission{[],"product projection helpers: " ++ checked})


@unsafe
def p131p_closed(+raw: List<&2,P113DCandidate>, +book: List<&2,KDef>, +static: P112StaticProgram, +certificate: P113ACertificate, +helpers: List<&2,P128BRHelper>, +retry: List<&2,NO_Plan>, +merged: List<&2,P113DFunction>) -> P111Emission:
  +closed = p113d_passes(raw,p113e_signatures(merged,missing()),nt_reverse(P113DFunction,merged,[]),32)
  p131p_complete(static,certificate,closed,p131p_retry(book,retry,closed,helpers))


@unsafe
def p131p_scanned(+raw: List<&2,P113DCandidate>, +book: List<&2,KDef>, +helpers: List<&2,P128BRHelper>, +retry: List<&2,NO_Plan>, +functions: List<&2,P113DFunction>, +original: P113AProgram) -> P111Emission:
  nt_choose(P111Emission,p131p_has_product(helpers) && Bool.not(List.is_empty(&2,NO_Plan,retry)),
    u => p131p_close(raw,book,original,functions,helpers,retry),
    u => p128raw_br_finish(raw,original,P118BWorkers{functions,""},p128br_retry_plans(book,retry,p128bs_original(original),helpers)))

@unsafe
def p131rg_opaque() -> String:
  "$p131.borrowed.opaque"


@unsafe
def p131rg_symbol_available(book: List<&2,KDef>) -> Bool:
  String.eq(dk(lookup(book,p131rg_opaque())),"Absent")


@unsafe
def p131rg_width(+width: U32) -> Bool:
  U32.is_eq(width,0) || (U32.is_ge(width,2) && U32.is_le(width,16))


@unsafe
def p131rg_visible(+book: List<&2,KDef>, +ty: KTerm) -> Bool:
  nol_scalar(book,ty) || Bool.not(List.is_empty(&2,NO_Spec,nol_root_specs(book,ty)))


@unsafe
def p131rg_names(+book: List<&2,KDef>, fields: List<&2,KTerm>) -> List<&2,String>:
  match fields:
    case Nil{}: []
    case Con{+field,rest}:
      Con{nt_choose(String,p131rg_visible(book,field),u => nm(field),u => p131rg_opaque()),
        p131rg_names(book,rest)}


@unsafe
def p131rg_children(+book: List<&2,KDef>, fields: List<&2,KTerm>) -> List<&2,KTerm>:
  match fields:
    case Nil{}: []
    case Con{+field,+rest}:
      nt_choose(List<&2,KTerm>,p131rg_visible(book,field) && Bool.not(nol_scalar(book,field)),
        u => Con{field,p131rg_children(book,rest)},u => p131rg_children(book,rest))


@unsafe
def p131rg_join(first: P128BLNode, tail: P128BLNode) -> P128BLNode:
  match first tail:
    case P128BLNode{a,ac,+ae} P128BLNode{b,bc,be}:
      P128BLNode{nt_append(NO_Spec,a,b),nt_append(KTerm,ac,bc),p111_first(ae,be)}


@unsafe
def p131rg_case(+book: List<&2,KDef>, +ty: KTerm, +ctor: KDef, +fields: KTerm) -> P128BLNode:
  +width = terms_len(ks(fields))
  +key = nc_ctor_identity(book,dn(ctor))
  nt_choose(P128BLNode,String.eq(tg(fields),"NO_Types") && U32.is_eq(width,da(ctor)) && p131rg_width(width),
    u => P128BLNode{[NO_Spec{NO_Layout{key,key,
      nt_choose(String,U32.is_eq(width,0),v => "Nullary",v => "Boxed"),width},nm(ty),p131rg_names(book,ks(fields))}],
      p131rg_children(book,ks(fields)),""},
    u => P128BLNode{[],[],"shallow observer: unsupported constructor fields/width"})


@unsafe
def p131rg_ctors(+book: List<&2,KDef>, +ty: KTerm, ctors: List<&2,KDef>, +fuel: U32) -> P128BLNode:
  match ctors:
    case Nil{}: P128BLNode{[],[],""}
    case Con{+ctor,+rest}:
      nt_choose(P128BLNode,U32.is_eq(fuel,0),u => P128BLNode{[],[],"shallow observer: constructor budget"},
        u => p131rg_join(p131rg_case(book,ty,ctor,nol_ctor_fields(book,ty,ctor)),
          p131rg_ctors(book,ty,rest,U32.sub(fuel,1))))


@unsafe
def p131rg_node(+book: List<&2,KDef>, +ty: KTerm) -> P128BLNode:
  +owner = lookup(book,nm(ty))
  nt_choose(P128BLNode,p131rg_symbol_available(book) && nol_plain(ty) && nol_owner(book,ty) &&
    Bool.not(db(owner)) && Bool.not(List.is_empty(&2,KDef,dc(owner))),
    u => p131rg_ctors(book,ty,dc(owner),8),
    u => P128BLNode{[],[],"shallow observer: nonplain/native/unknown owner"})


@unsafe
def p131rg_fallback(+book: List<&2,KDef>, +ty: KTerm, +original: P128BLNode) -> P128BLNode:
  match original:
    case P128BLNode{specs,children,+error}:
      nt_choose(P128BLNode,String.is_empty(error),u => original,u => p131rg_node(book,ty))

# Exact previous behavior is tried first. Opaque fields have no layout or
# scalar type; matching, arithmetic, borrowed-helper passing, root escape and
# recursive promotion are refused by the unchanged observer evaluator.

@unsafe
def p131rg_control_context() -> NO_Context:
  NO_Context{[],"reader",NO_Schema{[var("String",10)],[0],var("Bool",11),11,"Bool",[],12,""},[]}


@unsafe
def p131rg_control_opaque() -> KTerm:
  noa_atom(p131rg_opaque(),kt("OField","Record",1,0,[kt("OArg","",0,0,[]),ref("Record")]),var("",13))


@unsafe
def p131rg_control_match() -> Bool:
  +fn = kt("OM","",0,0,[kt("Mat","SCon",3,0,[]),atom("Env"),atom("Stack")])
  +spec : Maybe<&2,NO_Spec> = Some{NO_Spec{NO_Layout{"SCon","SCon","Boxed",2},"String",["Char","String"]}}
  Bool.not(String.is_empty(noa_error(noa_match_spec(p131rg_control_context(),fn,p131rg_control_opaque(),[],0,32,NO_KFinish{},spec))))


@unsafe
def p131rg_controls() -> List<&2,String>:
  +opaque = p131rg_control_opaque()
  +ctx = p131rg_control_context()
  +reserved : KDef = KDef{p131rg_opaque(),"ADT",0,0,atom("Absent"),atom("Absent"),[],False{},False{}}
  [p128bs_control_row("region-width-zero",p131rg_width(0)),
   p128bs_control_row("region-width-two",p131rg_width(2)),
   p128bs_control_row("region-width-eight",p131rg_width(8)),
   p128bs_control_row("region-packed-single-refused",Bool.not(p131rg_width(1))),
   p128bs_control_row("region-width-seventeen-refused",Bool.not(p131rg_width(17))),
   p128bs_control_row("region-empty-symbol-available",p131rg_symbol_available([])),
   p128bs_control_row("region-symbol-collision-refused",Bool.not(p131rg_symbol_available([reserved]))),
   p128bs_control_row("region-opaque-not-scalar",String.eq(tg(noa_scalar(ctx,opaque)),"Absent")),
   p128bs_control_row("region-opaque-not-readable",p131rg_control_match()),
   p128bs_control_row("region-opaque-not-string-helper",Bool.not(p128br_arguments(ctx,[var("String",20)],[0],[opaque],0))),
   p128bs_control_row("region-opaque-cannot-escape",String.eq(tg(noa_finish_value(ctx,opaque,var("Bool",11),[])),"Absent")),
   p128bs_control_row("region-opaque-cannot-recur",Bool.not(noa_loop_valid(ctx,[var("String",10)],[opaque],0,False{}))),
   p128bs_control_row("region-valid-held-string-retained",p128br_test_accept(p128br_test_arg("OA","String",kt("OArg","",0,0,[]))))]

law p131rv_value:
  for +ctx: NO_Context
  for +value: KTerm
  for +wanted: String
  for +fuel: U32
  Bool

@unsafe
def p131rv_value(ctx,value,wanted,fuel):
  nt_choose(Bool,U32.is_eq(fuel,0),u => False{},u =>
    nt_choose(Bool,String.eq(tg(value),"OC"),
      v => p131rv_constructor(ctx,value,wanted,U32.sub(fuel,1),noa_spec(nm(value),no_schema_specs(noa_schema(ctx)))),
      v => String.eq(tg(value),"OA") && String.eq(nm(value),wanted) &&
        (Bool.not(String.eq(tg(noa_scalar(ctx,value)),"Absent")) ||
          p128br_held(noa_origin(value),no_schema_params(noa_schema(ctx)),no_schema_roots(noa_schema(ctx)),0))))


@unsafe
def p131rv_fields(+ctx: NO_Context, values: List<&2,KTerm>, types: List<&2,String>, +fuel: U32) -> Bool:
  match values types:
    case Nil{} Nil{}: True{}
    case Con{value,rest} Con{ty,more}:
      p131rv_value(ctx,value,ty,fuel) && p131rv_fields(ctx,rest,more,fuel)
    case _ _: False{}


@unsafe
def p131rv_constructor(+ctx: NO_Context, +value: KTerm, +wanted: String, +fuel: U32, spec: Maybe<&2,NO_Spec>) -> Bool:
  match spec:
    case None{}: False{}
    case Some{NO_Spec{NO_Layout{key,ctor,storage,+width},owner,+fields}}:
      String.eq(owner,wanted) && U32.is_eq(width,terms_len(ks(value))) &&
        U32.is_eq(width,nt_count(String,fields)) && p131rv_fields(ctx,ks(value),fields,fuel)


@unsafe
def p131rv_arguments(+ctx: NO_Context, params: List<&2,KTerm>, +roots: List<&2,U32>, args: List<&2,KTerm>, +i: U32, +virtual: Bool) -> Bool:
  match params args:
    case Nil{} Nil{}: virtual
    case Con{+param,rest} Con{+arg,more}:
      String.eq(noa_value_type(ctx,arg),nm(param)) &&
        nt_choose(Bool,no_root_index(roots,i),
          u => p131rv_value(ctx,arg,nm(param),16),
          u => Bool.not(String.eq(tg(noa_scalar(ctx,arg)),"Absent"))) &&
        p131rv_arguments(ctx,rest,roots,more,U32.inc(i),virtual || (no_root_index(roots,i) && String.eq(tg(arg),"OC")))
    case _ _: False{}


@unsafe
def p131rv_reference(+ctx: NO_Context, +name: String, +args: List<&2,KTerm>, +facts: List<&2,KTerm>, +stack: List<&2,String>, +n: U32, +fuel: U32, +k: NO_Cont, +helper: P128BRHelper) -> NO_Analysis:
  match helper:
    case P128BRHelper{owner,+params,+roots,result,reader,wrapper,resultId}:
      nt_choose(NO_Analysis,p128br_arguments(ctx,params,roots,args,0),
        u => p128br_call(ctx,helper,args,facts,n,fuel,k),
        u => nt_choose(NO_Analysis,p131rv_arguments(ctx,params,roots,args,0,False{}) && U32.is_lt(nt_count(String,stack),16),
          v => noa_eval(ctx,nc_source_body(noa_book(ctx),lookup(noa_book(ctx),name),n),[],facts,Con{name,stack},n,fuel,NO_KApplyArgs{args,k}),
          v => p128br_call(ctx,helper,args,facts,n,fuel,k)))


@unsafe
def p131rv_context() -> NO_Context:
  NO_Context{[],"outer",NO_Schema{[var("String",10)],[0],var("Bool",11),11,"Bool",
    [NO_Spec{NO_Layout{"SNil","SNil","Nullary",0},"String",[]},
     NO_Spec{NO_Layout{"SCon","SCon","Boxed",2},"String",["Char","String"]}],12,""},[]}


@unsafe
def p131rv_controls() -> List<&2,String>:
  +ctx = p131rv_context()
  +empty = kt("OC","SNil",0,0,[])
  +held = noa_atom("String",kt("OArg","",0,0,[]),var("",10))
  [p128bs_control_row("virtual-empty-string-specializes",p131rv_arguments(ctx,[var("String",20)],[0],[empty],0,False{})),
   p128bs_control_row("virtual-not-raw-borrowed-pointer",Bool.not(p128br_arguments(ctx,[var("String",20)],[0],[empty],0))),
   p128bs_control_row("held-only-does-not-specialize",Bool.not(p131rv_arguments(ctx,[var("String",20)],[0],[held],0,False{}))),
   p128bs_control_row("virtual-unheld-atom-refused",Bool.not(p131rv_value(ctx,noa_atom("String",kt("OUnique","",0,0,[]),var("",10)),"String",16))),
   p128bs_control_row("virtual-wrong-type-refused",Bool.not(p131rv_value(ctx,empty,"KTerm",16))),
   p128bs_control_row("virtual-wrong-arity-refused",Bool.not(p131rv_value(ctx,kt("OC","SNil",0,0,[held]),"String",16))),
   p128bs_control_row("virtual-unknown-constructor-refused",Bool.not(p131rv_value(ctx,kt("OC","Unknown",0,0,[]),"String",16))),
   p128bs_control_row("virtual-fuel-refused",Bool.not(p131rv_value(ctx,empty,"String",0))),
   p128bs_control_row("virtual-opaque-field-refused",Bool.not(p131rv_value(ctx,p131rg_control_opaque(),"String",16)))]
