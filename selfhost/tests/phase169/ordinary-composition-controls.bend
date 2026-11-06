# Policy controls only; real normal-entry source certificate remains mandatory.

@unsafe
def p169oc_chain() -> List<&2,P113DFunction>:
  [p168tc_helper(),p168tc_caller("middle","p168tc_helper"),p168tc_caller("caller","middle")]

@unsafe
def p169oc_all_leaf(functions: List<&2,P113DFunction>) -> Bool:
  match functions:
    case Nil{}: True{}
    case Con{head,rest}: p168tc_leaf(head) && p169oc_all_leaf(rest)

@unsafe
def p169oc_positive_result(+original: List<&2,P113DFunction>, +functions: List<&2,P113DFunction>) -> Bool:
  p168tc_equal(functions,p113i_functions(original,P113IEmpty{},[])) &&
    Bool.not(p168tc_equal(original,functions)) && p169oc_all_leaf(functions) &&
    String.is_empty(p113e_functions(functions,N111Ids{missing(),missing()},missing()))

@unsafe
def p169oc_positive() -> Bool:
  +original : List<&2,P113DFunction> = p169oc_chain()
  p169oc_positive_result(original,p169o_walk(original,missing(),missing(),missing(),P113IEmpty{},[]))

@unsafe
def p169oc_protected(+seed: Bool) -> Bool:
  +original : List<&2,P113DFunction> = [p168tc_helper(),p168tc_caller("caller","p168tc_helper")]
  +seeds = nt_choose(KDef,seed,u => p113e_signatures([p168tc_helper()],missing()),u => missing())
  +blocked = nt_choose(KDef,seed,u => missing(),u => p167l_mark(missing(),"p168tc_helper"))
  p168tc_equal(original,p169o_walk(original,seeds,blocked,missing(),P113IEmpty{},[]))

@unsafe
def p169oc_target() -> Bool:
  +original : List<&2,P113DFunction> = p169oc_chain()
  +blocked = p167l_mark(missing(),"middle")
  p168tc_equal(p168t_walk(original,missing(),blocked,blocked,P113IEmpty{},[]),
    p169o_walk(original,missing(),blocked,blocked,P113IEmpty{},[]))

@unsafe
def p169oc_seed_body() -> Bool:
  +original : List<&2,P113DFunction> = p169oc_chain()
  +seeds = p113e_signatures([p168tc_caller("middle","p168tc_helper")],missing())
  p168tc_equal(original,p169o_walk(original,seeds,missing(),missing(),P113IEmpty{},[]))

@unsafe
def p169oc_unknown() -> Bool:
  +original : List<&2,P113DFunction> = [p168tc_caller("caller","unknown")]
  p168tc_equal(original,p169o_walk(original,missing(),missing(),missing(),P113IEmpty{},[]))

@unsafe
def p169o_controls() -> List<&2,String>:
  [p167c_row("ordinary-chain-matches-maintained-inliner",p169oc_positive()),
   p167c_row("ordinary-seed-never-published",p169oc_protected(True{})),
   p167c_row("ordinary-retry-owner-never-published",p169oc_protected(False{})),
   p167c_row("ordinary-target-policy-preserved",p169oc_target()),
   p167c_row("ordinary-seed-body-unchanged",p169oc_seed_body()),
   p167c_row("ordinary-unavailable-helper-unchanged",p169oc_unknown()),
   p167c_row("ordinary-false-certificate-stays-mode1",U32.is_eq(p169o_certified(1,P113ACertificate{False{},False{}}),1)),
   p167c_row("ordinary-partial-certificate-stays-mode1",U32.is_eq(p169o_certified(1,P113ACertificate{True{},False{}}),1)),
   p167c_row("ordinary-complete-certificate-internal-mode2",U32.is_eq(p169o_certified(1,P113ACertificate{True{},True{}}),2)),
   p167c_row("ordinary-mode0-stays-mode0",U32.is_eq(p169o_certified(0,P113ACertificate{True{},True{}}),0))]
