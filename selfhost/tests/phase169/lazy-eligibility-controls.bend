# Exact renamed maintained predicate. The preparation script authenticates this
# body against borrowed-regions.bend before using it as a finite reference.
@unsafe
def p169e_reference(+book: List<&2,KDef>, +plan: NO_Plan) -> Bool:
  +schema = no_plan_schema(plan)
  +wrapper = no_schema_wrapper(schema)
  +params = no_plan_params(no_schema_params(schema))
  +roots = no_schema_roots(schema)
  String.is_empty(no_plan_error(plan)) && String.eq(tg(wrapper),"Var") &&
    U32.is_eq(ix(wrapper),no_schema_result(schema)) &&
    String.eq(nm(wrapper),no_schema_observation(schema)) &&
    nol_scalar(book,kt("ADT",nm(wrapper),0,0,[])) &&
    U32.is_ge(nt_count(U32,roots),1) && U32.is_le(nt_count(U32,roots),2) &&
    String.eq(dk(lookup(book,p118b_read_name(no_plan_owner(plan)))),"Absent") &&
    String.eq(dk(lookup(book,p128bs_owned(no_plan_owner(plan)))),"Absent") &&
    String.is_empty(nc_error(no_emit(noa_body(no_plan_analysis(plan)),params,params,
      no_schema_specs_layouts(no_schema_specs(schema)),0)))

@unsafe
def p169ec_book(native: Bool) -> List<&2,KDef>:
  [KDef{"U32","ADT",0,0,atom("Absent"),atom("Absent"),[],native,False{}}]

@unsafe
def p169ec_plan(wrapper: KTerm, roots: List<&2,U32>, body: KTerm, error: String) -> NO_Plan:
  NO_Plan{"probe",NO_Schema{[var("U32",10)],roots,wrapper,11,"U32",[],12,""},
    NO_Analysis{body,12,4095,""},error}

@unsafe
def p169ec_body(index: U32) -> KTerm:
  kt("NO_Return","",0,0,[var("",index)])

@unsafe
def p169ec_row(name: String, +book: List<&2,KDef>, +plan: NO_Plan, +expected: Bool) -> String:
  p167c_row(name,U32.is_eq(Bool.to_u32(p169e_reference(book,plan)),Bool.to_u32(expected)) &&
    U32.is_eq(Bool.to_u32(p128bs_eligible(book,plan)),Bool.to_u32(expected)))

@unsafe
def p169ec_collision(name: String) -> List<&2,KDef>:
  Con{KDef{name,"Def",0,0,atom("Absent"),atom("Absent"),[],False{},False{}},p169ec_book(True{})}

@unsafe
def p169e_controls() -> List<&2,String>:
  +book = p169ec_book(True{})
  +wrapper = var("U32",11)
  +body = p169ec_body(10)
  [p169ec_row("lazy-one-root",book,p169ec_plan(wrapper,[0],body,""),True{}),
   p169ec_row("lazy-two-roots",book,p169ec_plan(wrapper,[0,1],body,""),True{}),
   p169ec_row("lazy-duplicate-root-count-unchanged",book,p169ec_plan(wrapper,[0,0],body,""),True{}),
   p169ec_row("lazy-error-plan",book,p169ec_plan(wrapper,[0],body,"known refusal"),False{}),
   p169ec_row("lazy-nonvariable-wrapper",book,p169ec_plan(kt("Ctr","U32",11,0,[]),[0],body,""),False{}),
   p169ec_row("lazy-wrong-result",book,p169ec_plan(var("U32",12),[0],body,""),False{}),
   p169ec_row("lazy-wrong-observation",book,p169ec_plan(var("Other",11),[0],body,""),False{}),
   p169ec_row("lazy-zero-roots",book,p169ec_plan(wrapper,[],body,""),False{}),
   p169ec_row("lazy-three-roots",book,p169ec_plan(wrapper,[0,1,2],body,""),False{}),
   p169ec_row("lazy-unknown-scalar",[],p169ec_plan(wrapper,[0],body,""),False{}),
   p169ec_row("lazy-nonnative-empty-adt",p169ec_book(False{}),p169ec_plan(wrapper,[0],body,""),False{}),
   p169ec_row("lazy-reader-collision",p169ec_collision(p118b_read_name("probe")),p169ec_plan(wrapper,[0],body,""),False{}),
   p169ec_row("lazy-owned-collision",p169ec_collision(p128bs_owned("probe")),p169ec_plan(wrapper,[0],body,""),False{}),
   p169ec_row("lazy-unbound-emission",book,p169ec_plan(wrapper,[0],p169ec_body(99),""),False{}),
   p169ec_row("lazy-unsupported-emission",book,p169ec_plan(wrapper,[0],atom("Unsupported"),""),False{}),
   p169ec_row("lazy-error-and-bad-emission",book,p169ec_plan(wrapper,[0],atom("Unsupported"),"known refusal"),False{})]
