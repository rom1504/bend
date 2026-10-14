# Component controls: synthetic compiler-owned core, complete analysis outputs.
# Root checks the whole assembled source before either target is emitted.
import Base

type P88Case is Data:
  P88Case{+name: String, +analysis: NO_Analysis}

@unsafe
def p88_word(n: U32) -> KTerm:
  KLiteral{"U32", n, "", 0, 0}

@unsafe
def p88_lam(id: U32, body: KTerm) -> KTerm:
  kt("Lam", "x", id, 1, [body])

@unsafe
def p88_add(a: KTerm, b: KTerm) -> KTerm:
  app(app(ref("U32.add"), a), b)

@unsafe
def p88_book() -> List<&2, KDef>:
  +word = kt("ADT", "U32", 0, 0, Nil{})
  [KDef{"U32", "ADT", 0, 0, typ(2), atom("Absent"), Nil{}, True{}, False{}},
   KDef{"U32.add", "Def", 2, 0, all(2, "x", 501, word, all(2, "y", 502, word, word)), atom("Absent"), Nil{}, True{}, False{}}]

@unsafe
def p88_context(wrapper: KTerm, specs: List<&2, NO_Spec>, params: List<&2, KTerm>) -> NO_Context:
  NO_Context{p88_book(), "owner", NO_Schema{params, Nil{}, wrapper, 0, "U32", specs, 100, ""}}

@unsafe
def p88_scalar_context() -> NO_Context:
  p88_context(var("", 0), Nil{}, Nil{})

@unsafe
def p88_choice_context() -> NO_Context:
  p88_context(var("", 0), [NO_Spec{NO_Layout{"Yes", "Yes", "Nullary", 0}, "Choice", Nil{}}], Nil{})

@unsafe
def p88_choice_env() -> List<&2, KTerm>:
  noa_bind(90, noa_atom("Choice", kt("OArg", "", 0, 0, Nil{}), var("", 91)), Nil{})

@unsafe
def p88_symbolic(yes: KTerm, no: KTerm) -> KTerm:
  app(kt("Mat", "Yes", 1, 0, [yes, p88_lam(12, no)]), var("", 90))

# These three calls are the only representation-specific test adapters.
# baseline-entry.py replaces their frame values by the original lambda values.
@unsafe
def p88_eval(+ctx: NO_Context, t: KTerm, env: List<&2, KTerm>, n: U32, fuel: U32) -> NO_Analysis:
  noa_eval(ctx, t, env, Nil{}, Nil{}, n, fuel, NO_KFinish{})

@unsafe
def p88_recur(+ctx: NO_Context, args: List<&2, KTerm>) -> NO_Analysis:
  noa_recur(ctx, args, Nil{}, 100, 100, NO_KFinish{})

@unsafe
def p88_recur_not_tail(+ctx: NO_Context, args: List<&2, KTerm>, +fn: KTerm) -> NO_Analysis:
  noa_recur(ctx, args, Nil{}, 100, 100, NO_KAppArgument{fn, NO_KFinish{}})

@unsafe
def p88_recursive_arg() -> KTerm:
  noa_atom("Root", kt("OField", "Child", 0, 0, [kt("OArg", "", 0, 0, Nil{}), ref("Root")]), var("", 92))

@unsafe
def p88_partial_add() -> KTerm:
  kt("OR", "U32.add", 0, 0, [kt("OStack", "", 0, 0, Nil{}), noa_atom("U32", kt("OConst", "U32", 1, 0, Nil{}), kt("NWord", "1", 0, 0, Nil{}))])

@unsafe
def main() -> List<&2, P88Case>:
  +scalar = p88_scalar_context()
  +choice = p88_choice_context()
  +recursive = p88_context(var("", 0), Nil{}, [var("Root", 3)])
  +identity = p88_lam(1, var("", 1))
  +boxed = kt("Ctr", "Box", 0, 0, [app(identity, p88_word(7))])
  +symbolic = p88_symbolic(p88_add(p88_word(7), p88_word(1)), p88_add(p88_word(9), p88_word(1)))
  [P88Case{"literal", p88_eval(scalar, p88_word(7), Nil{}, 100, 100)},
   P88Case{"application", p88_eval(scalar, app(identity, p88_word(7)), Nil{}, 100, 100)},
   P88Case{"nested-application", p88_eval(scalar, app(app(p88_lam(1, p88_lam(2, var("", 1))), p88_word(7)), p88_word(9)), Nil{}, 100, 100)},
   P88Case{"let-body", p88_eval(scalar, kt("Let", "", 0, 0, [kt("Bind", "x", 8, 1, [p88_word(7)]), var("", 8)]), Nil{}, 100, 100)},
   P88Case{"constructor-fields", p88_eval(p88_context(kt("Ctr", "Box", 0, 0, [var("", 0)]), Nil{}, Nil{}), boxed, Nil{}, 100, 100)},
   P88Case{"virtual-match-yes", p88_eval(scalar, app(kt("Mat", "Box", 2, 0, [identity, p88_lam(2, p88_word(9))]), boxed), Nil{}, 100, 100)},
   P88Case{"virtual-match-no", p88_eval(scalar, app(kt("Mat", "Other", 2, 0, [identity, p88_lam(2, p88_word(9))]), boxed), Nil{}, 100, 100)},
   P88Case{"primitive-prefix", p88_eval(scalar, p88_add(p88_word(7), p88_word(1)), Nil{}, 100, 100)},
   P88Case{"symbolic-fresh-order", p88_eval(choice, symbolic, p88_choice_env(), 100, 100)},
   P88Case{"symbolic-resume-both", p88_eval(choice, app(identity, symbolic), p88_choice_env(), 100, 100)},
   P88Case{"symbolic-first-error", p88_eval(choice, p88_symbolic(atom("Unsupported"), p88_add(p88_word(9), p88_word(1))), p88_choice_env(), 100, 100)},
   P88Case{"zero-fuel", p88_eval(scalar, p88_word(7), Nil{}, 100, 0)},
   P88Case{"exhausted-application", p88_eval(scalar, app(identity, p88_word(7)), Nil{}, 100, 2)},
   P88Case{"fresh-limit", p88_eval(scalar, p88_word(7), Nil{}, 294967200, 100)},
   P88Case{"absurd-skips-continuation", p88_eval(scalar, kt("Let", "", 0, 0, [kt("Bind", "x", 8, 1, [atom("Efq")]), atom("Unsupported")]), Nil{}, 100, 100)},
   P88Case{"recursive-tail", p88_recur(recursive, [p88_recursive_arg()])},
   P88Case{"recursive-non-tail", p88_recur_not_tail(recursive, [p88_recursive_arg()], p88_partial_add())}]
