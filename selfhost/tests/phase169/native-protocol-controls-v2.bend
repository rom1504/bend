# Finite protocol controls only. Rejected requests never emit or execute code.
@unsafe
def p169npc_error(prepared: P169Prepared, expected: String) -> Bool:
  match prepared:
    case P169Prepared{Nil{},P134End{},error}: String.eq(error,expected)
    case _: False{}

@unsafe
def p169npc_foreign(name: String) -> KDef:
  KDef{name,"Def",0,0,atom("U32"),atom("Foreign"),[],False{},True{}}

@unsafe
def p169npc_request(+names: List<&2,String>) -> NR_Request:
  +book : List<&2,KDef> = [p169npc_foreign("p108_missing"),p169npc_foreign("other_missing")]
  NR_Request{book,book,names,[],[],None{}}

@unsafe
def p169np_controls() -> List<&2,String>:
  +request = p169npc_request(["p108_missing"])
  +error = "foreign provider unavailable in fixed runtime: p108_missing"
  [p167c_row("native-protocol-base-error",p169npc_error(
     p169n_prepared("/unused","",P86PreparationError{"base_prepare: rejected"}),"base_prepare: rejected")),
   p167c_row("native-protocol-parse-error",p169npc_error(
     p169np_plan(P86PlanError{"parse: rejected"}),"parse: rejected")),
   p167c_row("native-protocol-check-error",p169npc_error(
     p169np_plan(P86PlanError{"check: main: rejected"}),"check: main: rejected")),
   p167c_row("native-protocol-frontend-compile-error",p169npc_error(
     p169np_plan(P86PlanError{"compile: rejected"}),"compile: rejected")),
   p167c_row("native-protocol-no-string-rewrite",p169npc_error(
     p169np_plan(P86PlanError{"check: adapter renderer runtime: user diagnostic"}),
     "check: adapter renderer runtime: user diagnostic")),
   p167c_row("native-protocol-runtime-compile-error",p169npc_error(
     p169np_plan(P86PlanReady{request,"unused"}),"compile: " ++ error)),
   p167c_row("native-protocol-hosted-contract-unchanged",p169npc_error(
     p169s_plan(P86PlanReady{request,"unused"}),"adapter renderer runtime: " ++ error)),
   p167c_row("native-protocol-first-runtime-error",p169npc_error(
     p169np_plan(P86PlanReady{p169npc_request(["other_missing","p108_missing"]),"unused"}),
     "compile: foreign provider unavailable in fixed runtime: other_missing"))]
