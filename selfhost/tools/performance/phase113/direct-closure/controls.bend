@unsafe
def p113dct_row(+name: String, valid: Bool) -> String:
  nt_choose(String,valid,u => "PASS " ++ name,u => "FAIL " ++ name)

def p113dct_lambda(id: U32, body: KTerm) -> KTerm:
  k_lam("argument",id,1,[body],0,0,False{})

def p113dct_identity() -> KTerm:
  p113dct_lambda(90,var("",90))

def p113dct_body() -> KTerm:
  app(var("",11),app(var("",10),var("",12)))

def p113dct_definition(body: KTerm) -> KDef:
  KDef{"combine","Def",3,0,atom("Typ"),
    p113dct_lambda(10,p113dct_lambda(11,p113dct_lambda(12,body))),[],False{},False{}}

def p113dct_head(mode: U32) -> KTerm:
  kt("Ref","combine",0,mode,[])

@unsafe
def p113dct_plan(body: KTerm, args: List<&2,KTerm>, mode: U32, env: List<&2,NC_Binding>, n: U32) -> KTerm:
  p113dc_plan([p113dct_definition(body)],p113dct_head(mode),args,env,n)

def p113dct_valid(t: KTerm) -> Bool:
  Bool.not(String.eq(tg(t),"Absent"))

@unsafe
def p113dct_order(+t: KTerm) -> Bool:
  String.eq(tg(t),"Let") && String.eq(tg(kid(kid(t,0),0)),"Var") &&
  U32.is_eq(ix(kid(kid(t,0),0)),98) && String.eq(tg(kid(t,1)),"Let") &&
  U32.is_eq(ix(kid(kid(kid(t,1),0),0)),99)

@unsafe
def p113_closure_control_report() -> List<&2,String>:
  +literal = p113dct_identity()
  +body = p113dct_body()
  [
    p113dct_row("closure-partial-residual-lambda",String.eq(tg(p113dct_plan(body,[literal,literal],0,[],100)),"Lam")),
    p113dct_row("closure-one-argument-residual-lambda",String.eq(tg(p113dct_plan(body,[literal],0,[],100)),"Lam")),
    p113dct_row("closure-saturated-linear",p113dct_valid(p113dct_plan(body,[literal,literal,var("",99)],0,[nc_binding(99)],100))),
    p113dct_row("closure-ordered-nonliteral-actuals",p113dct_order(p113dct_plan(body,[var("",98),literal,var("",99)],0,[nc_binding(98),nc_binding(99)],100))),
    p113dct_row("closure-captured-owner",p113dct_valid(p113dct_plan(body,[p113dct_lambda(90,app(var("",98),var("",90))),literal],0,[nc_binding(98)],100))),
    p113dct_row("closure-no-literal-fallback",Bool.not(p113dct_valid(p113dct_plan(body,[var("",98),var("",99)],0,[nc_binding(98),nc_binding(99)],100)))),
    p113dct_row("closure-bang-fallback",Bool.not(p113dct_valid(p113dct_plan(body,[literal,literal],3,[],100)))),
    p113dct_row("closure-zero-actuals-fallback",Bool.not(p113dct_valid(p113dct_plan(body,[],0,[],100)))),
    p113dct_row("closure-overapplication-fallback",Bool.not(p113dct_valid(p113dct_plan(body,[literal,literal,literal,literal],0,[],100)))),
    p113dct_row("closure-repeated-formal-fallback",Bool.not(p113dct_valid(p113dct_plan(app(var("",11),app(var("",10),app(var("",10),var("",12)))),[literal,literal],0,[],100)))),
    p113dct_row("closure-unused-formal-fallback",Bool.not(p113dct_valid(p113dct_plan(app(var("",10),var("",12)),[literal,literal],0,[],100)))),
    p113dct_row("closure-free-body-variable-fallback",Bool.not(p113dct_valid(p113dct_plan(app(var("",11),app(var("",10),var("",98))),[literal,literal],0,[nc_binding(98)],100)))),
    p113dct_row("closure-reference-body-fallback",Bool.not(p113dct_valid(p113dct_plan(app(kt("Ref","external",0,0,[]),body),[literal,literal],0,[],100)))),
    p113dct_row("closure-reserved-argument-id-fallback",Bool.not(p113dct_valid(p113dct_plan(body,[literal,var("",nc_id(100))],0,[nc_binding(nc_id(100))],100)))),
    p113dct_row("closure-reserved-capture-id-fallback",Bool.not(p113dct_valid(p113dct_plan(body,[p113dct_lambda(90,app(var("",nc_id(101)),var("",90))),literal],0,[nc_binding(nc_id(101))],100)))),
    p113dct_row("closure-fresh-overflow-fallback",Bool.not(p113dct_valid(p113dct_plan(body,[literal,literal],0,[],4294967295)))),
    p113dct_row("closure-missing-definition-fallback",Bool.not(p113dct_valid(p113dc_plan([],p113dct_head(0),[literal],[],100)))),
    p113dct_row("closure-dynamic-head-fallback",Bool.not(p113dct_valid(p113dc_plan([p113dct_definition(body)],var("",11),[literal],[],100))))
  ]
