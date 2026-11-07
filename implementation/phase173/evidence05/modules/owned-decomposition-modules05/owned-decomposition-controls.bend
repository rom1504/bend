# Independent structural controls. Synthetic summaries test transformation
# construction; they do not bypass or establish source-summary admission.
# Exact comparison supplements norm_exact with spans and runtime variants.
law p173odc_meta:
  for +a: KTerm
  for +b: KTerm
  Bool

law p173odc_metas:
  for +as: List<&2,KTerm>
  for +bs: List<&2,KTerm>
  Bool

@unsafe
def p173odc_variant(term: KTerm) -> U32:
  match term:
    case KTerm{tag,name,id,quant,kids,removed,begin,end}: 0
    case KLambda{name,id,quant,kids,removed,begin,end,present}: 1
    case KLiteral{kind,number,text,begin,end}: 2

@unsafe
def p173odc_meta(a,b):
  U32.is_eq(kb(a),kb(b)) && U32.is_eq(ke(a),ke(b)) &&
    U32.is_eq(p173odc_variant(a),p173odc_variant(b)) &&
    U32.is_eq(Bool.to_u32(k_quantity_present(a)),Bool.to_u32(k_quantity_present(b))) &&
    p173odc_metas(ks(a),ks(b))

@unsafe
def p173odc_metas(as,bs):
  match as bs:
    case Nil{} Nil{}: True{}
    case Con{a,ar} Con{b,br}: p173odc_meta(a,b) && p173odc_metas(ar,br)
    case _ _: False{}

@unsafe
def p173odc_exact(+a: KTerm, +b: KTerm) -> Bool:
  norm_exact(a,b) && p173odc_meta(a,b)

@unsafe
def p173odc_ref(name: String) -> KTerm:
  kt("Ref",name,0,0,[])

@unsafe
def p173odc_root() -> KTerm:
  KTerm{"Var","root",50,0,[],["root-origin"],4,8}

@unsafe
def p173odc_work(value: KTerm) -> KTerm:
  app(app(app(p173odc_ref("worker"),value),var("",51)),var("",52))

@unsafe
def p173odc_source(+root: KTerm) -> KTerm:
  KTerm{"App","",0,0,
    [app(p173odc_ref("setter"),root),p173odc_work(app(p173odc_ref("getter"),root))],
    ["kept-note"],31,47}

@unsafe
def p173odc_record() -> P173ODRow:
  P173ODRow{"Record",2,0,[10,11],var("",10),[20,21],
    kt("Ctr","Record",0,0,[var("",20),var("",3)])}

@unsafe
def p173odc_other() -> P173ODRow:
  P173ODRow{"Other",1,0,[30],kt("NWord","",7,0,[]),[31],
    kt("Ctr","Other",0,0,[var("",3)])}

@unsafe
def p173odc_identity() -> P173ODRow:
  P173ODRow{"Opaque",1,0,[40],kt("Ctr","Nil",0,0,[]),[41],var("",2)}

@unsafe
def p173odc_reconstructed_identity() -> P173ODRow:
  P173ODRow{"Opaque",1,0,[40],kt("Ctr","Nil",0,0,[]),[41],kt("Ctr","Opaque",0,0,[var("",41)])}

@unsafe
def p173odc_summary() -> P173ODSummary:
  P173ODSummary{1,2,3,[p173odc_record(),p173odc_identity(),p173odc_other()]}

# Literal expected graph, independent of p173oa_rows/row_body/rename.
@unsafe
def p173odc_expected() -> KTerm:
  app(kt("Mat","Record",3,0,[
    k_lam("",101,2,[k_lam("",102,2,[
      nc_mklet(103,p173odc_work(var("",101)),kt("Ctr","Record",0,0,[var("",101),var("",103)]))
    ],0,0,False{})],0,0,False{}),
    kt("Mat","Other",2,0,[
      k_lam("",104,2,[nc_mklet(105,p173odc_work(kt("NWord","",7,0,[])),kt("Ctr","Other",0,0,[var("",105)]))],0,0,False{}),
      k_lam("",100,2,[p173odc_source(var("",100))],0,0,False{})])]),p173odc_root())

@unsafe
def p173odc_result(result: P173OAResult, +expected: KTerm, +next: U32, +hits: U32) -> Bool:
  match result:
    case P173OAResult{actual,end,count}:
      p173odc_exact(actual,expected) && U32.is_eq(end,next) && U32.is_eq(count,hits)

@unsafe
def p173odc_run(+summary: P173ODSummary, +next: U32) -> P173OAResult:
  p173oa_pair_result(p173odc_source(p173odc_root()),p173odc_root(),p173odc_ref("worker"),
    [var("",51),var("",52)],next,Some{summary})

@unsafe
def p173odc_row(name: String, ok: Bool) -> String:
  name ++ nt_choose(String,ok,u => ":pass",u => ":FAIL")

@unsafe
def p173oa_controls() -> List<&2,String>:
  +source = p173odc_source(p173odc_root())
  +summary = p173odc_summary()
  +plain = var("",0)
  +lambda = k_lam("same-name",70,1,[var("same-name",70)],5,8,True{})
  +application = KTerm{"App","",0,0,[lambda,p173odc_root()],["preserve-redex"],9,12}
  +renamed = KTerm{"App","",0,0,[lambda,var("",100)],["preserve-redex"],9,12}
  [p173odc_row("owned-two-rows-exact-graph",p173odc_result(p173odc_run(summary,100),p173odc_expected(),106,2)),
   p173odc_row("owned-identity-only-exact-fallback",p173odc_result(
     p173odc_run(P173ODSummary{1,2,3,[p173odc_identity()]},100),source,100,0)),
   p173odc_row("owned-reconstructed-identity-exact-fallback",p173odc_result(
     p173odc_run(P173ODSummary{1,2,3,[p173odc_reconstructed_identity()]},100),source,100,0)),
   p173odc_row("owned-missing-summary-exact-fallback",p173odc_result(
     p173oa_pair_result(source,p173odc_root(),p173odc_ref("worker"),[var("",51),var("",52)],100,None{}),source,100,0)),
   p173odc_row("owned-source-id-collision-refused",p173odc_result(p173odc_run(summary,52),source,52,0)),
   p173odc_row("owned-helper-id-collision-refused",p173odc_result(
     p173oa_summary_result(plain,plain,p173odc_ref("worker"),[],21,summary),plain,21,0)),
   p173odc_row("owned-replacement-id-collision-refused",p173odc_result(
     p173odc_run(P173ODSummary{1,2,100,[p173odc_record()]},100),source,100,0)),
   p173odc_row("owned-reserved-id-limit-refused",p173odc_result(p173oa_try([],source,3999999000),source,3999999000,0)),
   p173odc_row("owned-unknown-worker-refused",Bool.not(p173oa_user([],p173odc_ref("worker"),3))),
   p173odc_row("owned-root-in-extra-argument-refused",Bool.not(p173oa_atoms([p173odc_root()],50))),
   p173odc_row("owned-effectful-extra-expression-refused",Bool.not(p173oa_atom(app(p173odc_ref("effect"),var("",1)),50))),
   p173odc_row("owned-distinct-atomic-alias-not-assumed-unique",p173oa_atoms([var("alias",51),var("alias2",52)],50)),
   p173odc_row("owned-rename-preserves-unreduced-application",p173odc_exact(p173oa_rename(application,[50],100),renamed)),
   p173odc_row("owned-rename-simultaneous-freshness-example",p173odc_exact(
     p173oa_rename(kt("Ctr","Pair",0,0,[var("",10),var("",11)]),[10,11],100),
     kt("Ctr","Pair",0,0,[var("",100),var("",101)]))),
   p173odc_row("owned-control-equality-observes-spans",Bool.not(p173odc_exact(
     KTerm{"Var","",1,0,[],[],1,2},KTerm{"Var","",1,0,[],[],1,3}))),
   p173odc_row("owned-control-equality-observes-lambda-present",Bool.not(p173odc_exact(
     k_lam("",1,1,[var("",1)],0,0,True{}),k_lam("",1,1,[var("",1)],0,0,False{}))))]
