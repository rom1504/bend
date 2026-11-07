# Finite syntax controls supplement the source-backed real-request query below.
# They do not authenticate fabricated books or replace semantic qualification.
@unsafe
def p173omc_term(+got: Maybe<&2,KTerm>, +want: KTerm) -> Bool:
  match got:
    case None{}: False{}
    case Some{value}: p173odc_exact(value,want)

@unsafe
def p173omc_none(+got: Maybe<&2,KTerm>) -> Bool:
  match got:
    case None{}: True{}
    case Some{value}: False{}

@unsafe
def p173omc_terms(+got: Maybe<&2,List<&2,KTerm>>, +want: List<&2,KTerm>) -> Bool:
  match got:
    case None{}: False{}
    case Some{values}: norm_exact_lists(values,want) && p173odc_metas(values,want)

@unsafe
def p173omc_row_none(+row: Maybe<&2,P173ODRow>) -> Bool:
  match row:
    case None{}: True{}
    case Some{value}: False{}

# These are inert compiler-data fixtures. The bad function body is inspected
# and rejected; it is never executed or compiled as a target program.
@unsafe
def p173omc_getter_book() -> List<&2,KDef>:
  +typ = kt("All","root",1,2,[kt("ADT","Record",0,0,[]),kt("ADT","Record",0,0,[])])
  +good = kt("Mat","Record",3,0,[k_lam("a",10,2,[k_lam("b",11,2,[var("",10)],0,0,False{})],0,0,False{}),atom("Efq")])
  +bad = k_lam("root",8,2,[app(kt("Ref","unexecuted_call",0,0,[]),var("",8))],0,0,False{})
  [KDef{"om_good","Def",1,0,typ,good,[],False{},True{}},
   KDef{"om_ignored","Def",1,0,typ,bad,[],False{},True{}}]

@unsafe
def p173omc_bound(+bound: P173ODBind) -> Bool:
  match bound:
    case P173ODBind{ids,body,valid}: valid

@unsafe
def p173om_controls() -> List<&2,String>:
  +word = kt("NWord","9",0,0,[])
  +work : P173OMArg = P173OMWork{"getter"}
  +source : KTerm = kt("Mat",nc_ctor_encode("Record"),3,0,[atom("Absent"),atom("Efq")])
  [p173odc_row("multi-one-computed-slot",p173om_descriptors([P173OMGetter{"name"},work,P173OMGetter{"stamp"}],1,0)),
   p173odc_row("multi-no-computed-slot-refused",Bool.not(p173om_descriptors([P173OMGetter{"name"},P173OMValue{word}],1,0))),
   p173odc_row("multi-two-computed-slots-refused",Bool.not(p173om_descriptors([work,work],0,0))),
   p173odc_row("multi-wrong-computed-position-refused",Bool.not(p173om_descriptors([work,P173OMGetter{"name"}],1,0))),
   p173odc_row("multi-field-atom-id-collision-refused",Bool.not(p173om_atom_safe(var("",20),[20,21],50))),
   p173odc_row("multi-result-atom-id-collision-refused",Bool.not(p173om_atom_safe(var("",50),[20,21],50))),
   p173odc_row("multi-distinct-atom-allowed",p173om_atom_safe(var("",70),[20,21],50)),
   p173odc_row("multi-static-leaf-allowed",p173om_atom_safe(kt("NStatic","s",7,0,[]),[20,21],50)),
   p173odc_row("multi-static-nonleaf-refused",Bool.not(p173om_atom_safe(kt("NStatic","s",7,0,[var("",20)]),[20,21],50))),
   p173odc_row("multi-reference-is-not-atom",Bool.not(p173om_atom_safe(kt("Ref","effect",0,0,[]),[20,21],50))),
   p173odc_row("multi-projection-field-basis",p173omc_term(p173om_project_var([10,11],[20,21],11),var("",21))),
   p173odc_row("multi-projection-missing-field-refused",p173omc_none(p173om_project_var([10,11],[20,21],12))),
   p173odc_row("multi-projection-width-mismatch-refused",p173omc_none(p173om_project_fields([20],P173ODBind{[10,11],var("",10),True{}}))),
   p173odc_row("multi-projection-closed-constructor",p173omc_term(p173om_project_fields([20],P173ODBind{[10],kt("Ctr","Nil",0,0,[]),True{}}),kt("Ctr","Nil",0,0,[]))),
   p173odc_row("multi-projection-call-refused",p173omc_none(p173om_project_fields([20],P173ODBind{[10],app(kt("Ref","effect",0,0,[]),var("",10)),True{}}))),
   p173odc_row("multi-argument-origin-one-pass",p173omc_terms(
     p173om_values([],[var("",20),var("",30),var("",31)],[30,31],[work,P173OMValue{word}],[20],50,"Record",3,0),
     [var("",20),var("",50),word])),
   p173odc_row("multi-unknown-origin-refused",p173omc_none(p173om_resolve([],var("",99),[30,31],[work,P173OMValue{word}],[20],50,"Record",3,0))),
   p173odc_row("multi-duplicated-computed-value-refused",p173omc_row_none(p173om_row_schema([],source,[work,P173OMValue{word}],0,50,
     Some{P173OMSchema{[20,21],[30,31],kt("Ctr",nc_ctor_encode("Record"),0,0,[var("",30),var("",30)])}}))),
   p173odc_row("multi-unused-call-keeps-fallback",p173omc_row_none(p173om_row_schema([],source,[work,P173OMValue{word}],0,50,
     Some{P173OMSchema{[20,21],[30,31],kt("Ctr",nc_ctor_encode("Record"),0,0,[var("",20),var("",21)])}}))),
   p173odc_row("multi-existing-root-extra-refusal",Bool.not(p173oa_atoms([var("",50)],50))),
   p173odc_row("multi-source-projection-fixture-ready",p173omc_term(p173om_project(p173omc_getter_book(),"om_good",nc_ctor_encode("Record"),2,0,[20,21]),var("",20))),
   p173odc_row("multi-unused-projection-getter-certified",Bool.not(p173omc_row_none(p173om_row_schema(p173omc_getter_book(),source,
     [P173OMWork{"om_good"},P173OMGetter{"om_good"}],0,50,
     Some{P173OMSchema{[20,21],[30,31],kt("Ctr",nc_ctor_encode("Record"),0,0,[var("",30),var("",21)])}})))),
   p173odc_row("multi-unused-computing-getter-refused",p173omc_row_none(p173om_row_schema(p173omc_getter_book(),source,
     [P173OMWork{"om_good"},P173OMGetter{"om_ignored"}],0,50,
     Some{P173OMSchema{[20,21],[30,31],kt("Ctr",nc_ctor_encode("Record"),0,0,[var("",30),var("",21)])}}))),
   p173odc_row("multi-affine-formal-allowed",p173omc_bound(p173om_parameters(k_lam("a",30,1,[var("",30)],0,0,False{}),1,[0,20],[]))),
   p173odc_row("multi-erased-formal-refused",Bool.not(p173omc_bound(p173om_parameters(k_lam("a",30,0,[var("",30)],0,0,False{}),1,[0,20],[])))),
   p173odc_row("multi-formal-field-collision-refused",Bool.not(p173omc_bound(p173om_parameters(k_lam("a",20,1,[var("",20)],0,0,False{}),1,[0,20],[])))),
   p173odc_row("multi-unrestricted-formal-allowed",p173omc_bound(p173om_parameters(k_lam("a",30,2,[var("",30)],0,0,False{}),1,[0,20],[]))),
   p173odc_row("multi-foreign-quantity-formal-refused",Bool.not(p173omc_bound(p173om_parameters(k_lam("a",30,3,[var("",30)],0,0,False{}),1,[0,20],[])))),
   p173odc_row("multi-duplicate-formal-refused",Bool.not(p173omc_bound(p173om_parameters(
     k_lam("a",30,1,[k_lam("b",30,2,[var("",30)],0,0,False{})],0,0,False{}),2,[0,20],[])))),
   p173odc_row("multi-unused-getter-before-call-refused",p173omc_row_none(p173om_row_schema(p173omc_getter_book(),source,
     [P173OMGetter{"om_ignored"},P173OMWork{"om_good"}],1,50,
     Some{P173OMSchema{[20,21],[30,31],kt("Ctr",nc_ctor_encode("Record"),0,0,[var("",31),var("",21)])}})))]

# This is an explicit diagnostic query, not a recognizer or implementation rule.
# The actual source-backed setter/getters are still independently summarized.
@unsafe
def p173om_layout_summary(request: NR_Request) -> Maybe<&2,P173ODSummary>:
  match request:
    case NR_Request{source,book,names,paths,scope,bound}:
      p173om_pair(book,"k_rebuild",[P173OMGetter{"nm"},P173OMGetter{"ix"},P173OMGetter{"qt"},
        P173OMWork{"ks"},P173OMGetter{"rm"},P173OMGetter{"kb"},P173OMGetter{"ke"}],3)
