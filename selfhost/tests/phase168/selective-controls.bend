# Pure selection-policy controls. No malformed machine code is executed.
# Negative cases compare every field of the complete output function list.

def p168tc_helper() -> P113DFunction:
  P113DFunction{"p168tc_helper",[],1,False{},[P113DResult{[N111Const{7,0}]}]}

def p168tc_caller(name: String, target: String) -> P113DFunction:
  P113DFunction{name,[],1,False{},[
    P113DCall{["answer"],target,[]},P113DResult{[N111Local{"answer"}]}]}

@unsafe
def p168tc_equal(a: List<&2,P113DFunction>, b: List<&2,P113DFunction>) -> Bool:
  p134v_list(~P113DFunction,~p134v_function,a,b)

@unsafe
def p168tc_leaf(function: P113DFunction) -> Bool:
  match function:
    case P113DFunction{name,params,result,public,body}: p128bs_leaf(body)

@unsafe
def p168tc_positive_result(+functions: List<&2,P113DFunction>) -> Bool:
  match functions:
    case Con{helper,Con{+target,Con{consumer,Nil{}}}}:
      p134v_function(helper,p168tc_helper()) &&
      p134v_function(consumer,p168tc_caller("p168tc_consumer","p168tc_helper")) &&
      Bool.not(p134v_function(target,p168tc_caller("p168tc_target","p168tc_helper"))) &&
      p168tc_leaf(target) &&
      String.is_empty(p113e_functions(functions,N111Ids{missing(),missing()},missing()))
    case _: False{}

@unsafe
def p168tc_positive() -> Bool:
  p168tc_positive_result(p168t_walk([
    p168tc_helper(),p168tc_caller("p168tc_target","p168tc_helper"),
    p168tc_caller("p168tc_consumer","p168tc_helper")],missing(),
    p167l_mark(missing(),"p168tc_target"),p167l_mark(missing(),"p168tc_target"),P113IEmpty{},[]))

@unsafe
def p168tc_blocked() -> Bool:
  +original : List<&2,P113DFunction> = [p168tc_helper(),p168tc_caller("p168tc_target","p168tc_helper")]
  p168tc_equal(original,p168t_walk(original,missing(),
    p167l_mark(p167l_mark(missing(),"p168tc_target"),"p168tc_helper"),
    p167l_mark(missing(),"p168tc_target"),P113IEmpty{},[]))

@unsafe
def p168tc_seed() -> Bool:
  +original : List<&2,P113DFunction> = [p168tc_helper(),p168tc_caller("p168tc_target","p168tc_helper")]
  p168tc_equal(original,p168t_walk(original,p113e_signatures([p168tc_helper()],missing()),
    p167l_mark(missing(),"p168tc_target"),p167l_mark(missing(),"p168tc_target"),P113IEmpty{},[]))

@unsafe
def p168tc_unknown() -> Bool:
  +original : List<&2,P113DFunction> = [p168tc_caller("p168tc_target","p168tc_missing")]
  p168tc_equal(original,p168t_walk(original,missing(),
    p167l_mark(missing(),"p168tc_target"),p167l_mark(missing(),"p168tc_target"),P113IEmpty{},[]))

@unsafe
def p168tc_controls() -> List<&2,String>:
  [p167c_row("selective-leaf-helper-only-target-changes",p168tc_positive()),
   p167c_row("selective-blocked-helper-not-inlined",p168tc_blocked()),
   p167c_row("selective-seed-helper-not-inlined",p168tc_seed()),
   p167c_row("selective-unavailable-helper-preserves-original",p168tc_unknown())]
