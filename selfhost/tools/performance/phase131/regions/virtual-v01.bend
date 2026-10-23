# A virtual constructor is not a borrowed pointer. When a verified reader has
# such an argument, interpret its unchanged body with the existing NO evaluator.
# This preserves constructor elimination, call order and all residual gates.
# Ordinary held-pointer calls continue through p128br_call unchanged.

law p131rv_value:
  for +ctx: NO_Context
  for +value: KTerm
  for +wanted: String
  for +fuel: U32
  Bool

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
def p131rv_value(ctx,value,wanted,fuel):
  nt_choose(Bool,U32.is_eq(fuel,0),u => False{},u =>
    nt_choose(Bool,String.eq(tg(value),"OC"),
      v => p131rv_constructor(ctx,value,wanted,U32.sub(fuel,1),noa_spec(nm(value),no_schema_specs(noa_schema(ctx)))),
      v => String.eq(tg(value),"OA") && String.eq(nm(value),wanted) &&
        (Bool.not(String.eq(tg(noa_scalar(ctx,value)),"Absent")) ||
          p128br_held(noa_origin(value),no_schema_params(noa_schema(ctx)),no_schema_roots(noa_schema(ctx)),0))))

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
    case P128BRHelper{owner,+params,+roots,result,reader}:
      nt_choose(NO_Analysis,p128br_arguments(ctx,params,roots,args,0),
        u => p128br_call(ctx,helper,args,facts,n,fuel,k),
        u => nt_choose(NO_Analysis,p131rv_arguments(ctx,params,roots,args,0,False{}) && U32.is_lt(nt_count(String,stack),16),
          v => noa_eval(ctx,nc_source_body(noa_book(ctx),lookup(noa_book(ctx),name),n),[],facts,Con{name,stack},n,fuel,NO_KApplyArgs{args,k}),
          v => p128br_call(ctx,helper,args,facts,n,fuel,k)))

@unsafe
def p128br_reference(+ctx: NO_Context, +name: String, +args: List<&2,KTerm>, +facts: List<&2,KTerm>, +stack: List<&2,String>, +n: U32, +fuel: U32, +k: NO_Cont, helper: Maybe<&2,P128BRHelper>) -> NO_Analysis:
  match helper:
    case Some{ready}: p131rv_reference(ctx,name,args,facts,stack,n,fuel,k,ready)
    case None{}:
      +d = lookup(noa_book(ctx),name)
      nt_choose(NO_Analysis,String.eq(dk(d),"Def") && Bool.not(nc_foreign(d) || nc_native_def(d) || nb_contains(stack,name)) && U32.is_lt(nt_count(String,stack),8),
        u => noa_eval(ctx,nc_source_body(noa_book(ctx),d,n),[],facts,Con{name,stack},n,fuel,NO_KApplyArgs{args,k}),
        u => noa_fail("observer: helper effect, cycle or depth",n,fuel))

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
