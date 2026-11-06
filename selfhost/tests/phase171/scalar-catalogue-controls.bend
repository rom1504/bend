# Complete structural observations of actual schema/analysis builders.

@unsafe
def p171sct_schema(a: NO_Schema, b: NO_Schema) -> Bool:
  match a b:
    case NO_Schema{ap,ar,aw,ai,ao,as_,af,ae} NO_Schema{bp,br,bw,bi,bo,bs,bf,be}:
      f_fresh_prefix_exact_terms(ap,bp) && p134v_list(~U32,~U32.is_eq,ar,br) &&
        f_fresh_prefix_exact_terms([aw],[bw]) && U32.is_eq(ai,bi) && String.eq(ao,bo) &&
        p134v_list(~NO_Spec,~p140l_spec,as_,bs) && U32.is_eq(af,bf) && String.eq(ae,be)

@unsafe
def p171sct_analysis(a: NO_Analysis, b: NO_Analysis) -> Bool:
  match a b:
    case NO_Analysis{ab,af,au,ae} NO_Analysis{bb,bf,bu,be}:
      f_fresh_prefix_exact_terms([ab],[bb]) && U32.is_eq(af,bf) && U32.is_eq(au,bu) && String.eq(ae,be)

@unsafe
def p171sct_plan(a: NO_Plan, b: NO_Plan) -> Bool:
  match a b:
    case NO_Plan{an,as_,aa,ae} NO_Plan{bn,bs,ba,be}:
      String.eq(an,bn) && p171sct_schema(as_,bs) && p171sct_analysis(aa,ba) && String.eq(ae,be)

@unsafe
def p171sct_value(state: P171SCPlan) -> NO_Plan:
  match state:
    case P171SCPlan{plan,catalogue}: plan

@unsafe
def p171sct_catalogue(state: P171SCPlan) -> Maybe<&2,List<&2,NO_Spec>>:
  match state:
    case P171SCPlan{plan,catalogue}: catalogue

@unsafe
def p171sct_count(state: P171SCPlan) -> U32:
  match state:
    case P171SCPlan{plan,None{}}: 0
    case P171SCPlan{plan,Some{specs}}: nt_count(NO_Spec,specs)

@unsafe
def p171sct_ctor(name: String, arity: U32, ty: KTerm) -> KDef:
  KDef{name,"Ctr",arity,0,ty,atom("Absent"),[],False{},False{}}

@unsafe
def p171sct_spine(+name: String, +field: String) -> KDef:
  +ty = kt("ADT",name,0,0,[])
  KDef{name,"ADT",0,0,typ(1),atom("Absent"),[
    p171sct_ctor(name ++ "Nil",0,ty),
    p171sct_ctor(name ++ "Con",2,all(2,"head",10,kt("ADT",field,0,0,[]),all(2,"tail",11,ty,ty)))],False{},False{}}

@unsafe
def p171sct_observer(name: String, root: String) -> KDef:
  KDef{name,"Def",1,0,all(2,"root",100,kt("ADT",root,0,0,[]),kt("ADT","Flag",0,0,[])),
    kt("Efq","",0,0,[]),[],False{},True{}}

@unsafe
def p171sct_book() -> List<&2,KDef>:
  +flag = kt("ADT","Flag",0,0,[])
  [KDef{"Flag","ADT",0,0,typ(1),atom("Absent"),[
      p171sct_ctor("Off",0,flag),p171sct_ctor("On",0,flag)],False{},False{}},
   p171sct_spine("Inner","Flag"),p171sct_spine("Outer","Inner"),
   p171sct_observer("observe","Outer"),p171sct_observer("ordinary","Inner")]

@unsafe
def p171sct_refused(name: String) -> NO_Plan:
  NO_Plan{name,nol_failure("unsupported or dependent parameter",0),noa_fail("prior",0,4096),"prior"}

@unsafe
def p171sct_empty(patches: P128BRPatches) -> Bool:
  match patches:
    case P128BRPatches{Nil{},error}: String.is_empty(error)
    case _: False{}

@unsafe
def p171sc_controls() -> List<&2,String>:
  +book = p171sct_book()
  +plan = p171sct_refused("observe")
  +first = p171sc_replan(book,plan,[],None{})
  +again = p171sc_replan(book,plan,[],p171sct_catalogue(first))
  +failed = p171sc_replan(book,p171sct_refused("missing"),[],None{})
  +after = p171sc_replan(book,p171sct_refused("missing"),[],p171sct_catalogue(first))
  +ordinary = p171sc_replan(book,p171sct_refused("ordinary"),[],None{})
  +extra : KDef = KDef{"Extra","ADT",0,0,typ(1),atom("Absent"),[
    p171sct_ctor("Only",0,kt("ADT","Extra",0,0,[]))],False{},False{}}
  +changed : List<&2,KDef> = Con{extra,book}
  +fresh = p171sc_replan(changed,plan,[],None{})
  [p126sc_row("catalogue-two-enum-constructors",U32.is_eq(nt_count(NO_Spec,nol_scalar_specs(book,book)),2)),
   p126sc_row("nested-takes-actual-fallback",Bool.not(String.is_empty(no_schema_error(no_schema(book,lookup(book,"observe"),0))))),
   p126sc_row("nested-schema-accepted",String.is_empty(no_schema_error(p128bl_schema(book,"observe")))),
   p126sc_row("complete-schema-exact",p171sct_schema(p128bl_schema(book,"observe"),p171sc_attach(p171sc_schema(book,"observe"),nol_scalar_specs(book,book)))),
   p126sc_row("first-complete-plan-exact",p171sct_plan(p128br_replan(book,plan,[]),p171sct_value(first))),
   p126sc_row("reused-complete-plan-exact",p171sct_plan(p128br_replan(book,plan,[]),p171sct_value(again))),
   p126sc_row("catalogue-retained",U32.is_eq(p171sct_count(first),2) && U32.is_eq(p171sct_count(again),2)),
   p126sc_row("failed-schema-does-not-initialize",U32.is_eq(p171sct_count(failed),0) && p171sct_plan(p128br_replan(book,p171sct_refused("missing"),[]),p171sct_value(failed))),
   p126sc_row("failed-schema-keeps-prior",U32.is_eq(p171sct_count(after),2) && p171sct_plan(p171sct_value(failed),p171sct_value(after))),
   p126sc_row("ordinary-path-unchanged",U32.is_eq(p171sct_count(ordinary),0) && p171sct_plan(p128br_replan(book,p171sct_refused("ordinary"),[]),p171sct_value(ordinary))),
   p126sc_row("new-request-new-book-catalogue",U32.is_eq(p171sct_count(fresh),3) && p171sct_plan(p128br_replan(changed,plan,[]),p171sct_value(fresh))),
   p126sc_row("empty-retry-completes",p171sct_empty(p171sc_retry(book,[],[],[],None{})))]
