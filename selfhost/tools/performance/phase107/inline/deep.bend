# Optional bounded purity summaries. Expansion limits do not change.
type NxIFact is Data:
  NxIFact{+name: String, +local: Bool, +calls: List<&2, String>}

type NxIPurity is Data:
  NxIPurity{+name: String, +pure: Bool}

type NxIProof is Data:
  NxIProof{+pure: Bool, +cache: List<&2, NxIPurity>}

@unsafe
def nx_i_local_rhs(+expr: NxExpr) -> Bool:
  match expr:
    case NxCall{name, args}: nx_i_args_pure(args)
    case _: nx_i_expr_pure(expr)

@unsafe
def nx_i_local_fallthrough(+body: List<&2, NxStmt>) -> Bool:
  match body:
    case Nil{}: True{}
    case Con{NxSet{name, value}, rest}: nx_i_local_rhs(value) && nx_i_local_fallthrough(rest)
    case Con{NxIf{condition, yes, no}, rest}:
      nx_i_expr_pure(condition) && nx_i_local_fallthrough(yes) && nx_i_local_fallthrough(no) && nx_i_local_fallthrough(rest)
    case _: False{}

@unsafe
def nx_i_local_tail(+body: List<&2, NxStmt>) -> Bool:
  match body:
    case Con{NxSet{name, value}, rest}: nx_i_local_rhs(value) && nx_i_local_tail(rest)
    case Con{NxReturn{value}, Nil{}}: nx_i_local_rhs(value)
    case Con{NxIf{condition, yes, no}, Nil{}}: nx_i_expr_pure(condition) && nx_i_local_tail(yes) && nx_i_local_tail(no)
    case Con{NxIf{condition, yes, no}, rest}:
      nx_i_expr_pure(condition) && nx_i_local_fallthrough(yes) && nx_i_local_fallthrough(no) && nx_i_local_tail(rest)
    case _: False{}

@unsafe
def nx_i_names_join(+a: List<&2, String>, +b: List<&2, String>) -> List<&2, String>:
  match a:
    case Nil{}: b
    case Con{head, rest}: Con{head, nx_i_names_join(rest, b)}

def nx_i_expr_refs(+expr: NxExpr) -> List<&2, String>:
  match expr:
    case NxCall{name, args}: [name]
    case _: []

@unsafe
def nx_i_refs(+body: List<&2, NxStmt>) -> List<&2, String>:
  match body:
    case Nil{}: []
    case Con{NxSet{name, value}, rest}: nx_i_names_join(nx_i_expr_refs(value), nx_i_refs(rest))
    case Con{NxReturn{value}, rest}: nx_i_names_join(nx_i_expr_refs(value), nx_i_refs(rest))
    case Con{NxIf{condition, yes, no}, rest}: nx_i_names_join(nx_i_refs(yes), nx_i_names_join(nx_i_refs(no), nx_i_refs(rest)))
    case _: []

@unsafe
def nx_i_fact(+f: NxFunction) -> NxIFact:
  match f:
    case NxFunction{name, params, result, locals, body}:
      NxIFact{name, nx_scalar(result) && nx_i_scalar_params(params) && nx_i_scalar_params(locals)
        && U32.is_le(nx_i_param_count(params), 16) && U32.is_le(nx_i_param_count(locals), 32)
        && U32.is_le(nx_i_body_nodes(body), 256) && U32.is_le(nx_i_body_calls(body), 4)
        && nx_i_local_tail(body), nx_i_refs(body)}

@unsafe
def nx_i_facts(+fs: List<&2, NxFunction>) -> List<&2, NxIFact>:
  match fs:
    case Nil{}: []
    case Con{head, rest}: Con{nx_i_fact(head), nx_i_facts(rest)}

@unsafe
def nx_i_fact_find(+name: String, +facts: List<&2, NxIFact>) -> Maybe<&2, NxIFact>:
  match facts:
    case Nil{}: None{}
    case Con{NxIFact{key, local, calls}, rest}:
      nx_choose(Maybe<&2, NxIFact>, String.eq(name, key), u => Some{NxIFact{key, local, calls}}, u => nx_i_fact_find(name, rest))

@unsafe
def nx_i_cached(+name: String, +cache: List<&2, NxIPurity>) -> Maybe<&2, Bool>:
  match cache:
    case Nil{}: None{}
    case Con{NxIPurity{key, pure}, rest}:
      nx_choose(Maybe<&2, Bool>, String.eq(name, key), u => Some{pure}, u => nx_i_cached(name, rest))

@unsafe
def nx_i_prove(+name: String, +facts: List<&2, NxIFact>, +gray: List<&2, String>, +cache: List<&2, NxIPurity>, +depth: U32) -> NxIProof:
  nx_i_prove_cached(nx_i_cached(name, cache), name, facts, gray, cache, depth)

@unsafe
def nx_i_prove_cached(+cached: Maybe<&2, Bool>, +name: String, +facts: List<&2, NxIFact>, +gray: List<&2, String>, +cache: List<&2, NxIPurity>, +depth: U32) -> NxIProof:
  match cached:
    case Some{pure}: NxIProof{pure, cache}
    case None{}:
      nx_choose(NxIProof, U32.is_eq(depth, 0) || nx_i_names_has(name, gray), u => NxIProof{False{}, cache},
        u => nx_i_prove_fact(nx_i_fact_find(name, facts), name, facts, Con{name, gray}, cache, U32.sub(depth, 1)))

@unsafe
def nx_i_prove_fact(+found: Maybe<&2, NxIFact>, +name: String, +facts: List<&2, NxIFact>, +gray: List<&2, String>, +cache: List<&2, NxIPurity>, +depth: U32) -> NxIProof:
  match found:
    case None{}: NxIProof{False{}, Con{NxIPurity{name, False{}}, cache}}
    case Some{NxIFact{key, local, calls}}:
      nx_choose(NxIProof, local,
        u => nx_i_prove_record(name, nx_i_prove_refs(calls, facts, gray, cache, depth)),
        u => NxIProof{False{}, Con{NxIPurity{name, False{}}, cache}})

@unsafe
def nx_i_prove_record(+name: String, +proof: NxIProof) -> NxIProof:
  match proof:
    case NxIProof{pure, cache}: NxIProof{pure, Con{NxIPurity{name, pure}, cache}}

@unsafe
def nx_i_prove_refs(+names: List<&2, String>, +facts: List<&2, NxIFact>, +gray: List<&2, String>, +cache: List<&2, NxIPurity>, +depth: U32) -> NxIProof:
  match names:
    case Nil{}: NxIProof{True{}, cache}
    case Con{head, rest}: nx_i_prove_next(nx_i_prove(head, facts, gray, cache, depth), rest, facts, gray, depth)

@unsafe
def nx_i_prove_next(+proof: NxIProof, +rest: List<&2, String>, +facts: List<&2, NxIFact>, +gray: List<&2, String>, +depth: U32) -> NxIProof:
  match proof:
    case NxIProof{pure, cache}:
      nx_choose(NxIProof, pure, u => nx_i_prove_refs(rest, facts, gray, cache, depth), u => proof)

@unsafe
def nx_i_prove_all(+items: List<&2, NxIFact>, +facts: List<&2, NxIFact>, +cache: List<&2, NxIPurity>) -> List<&2, NxIPurity>:
  match items:
    case Nil{}: cache
    case Con{NxIFact{name, local, calls}, rest}: nx_i_prove_all_next(nx_i_prove(name, facts, [], cache, 256), rest, facts)

@unsafe
def nx_i_prove_all_next(+proof: NxIProof, +rest: List<&2, NxIFact>, +facts: List<&2, NxIFact>) -> List<&2, NxIPurity>:
  match proof:
    case NxIProof{pure, cache}: nx_i_prove_all(rest, facts, cache)

@unsafe
def nx_i_eligible(+cache: List<&2, NxIPurity>) -> List<&2, String>:
  match cache:
    case Nil{}: []
    case Con{NxIPurity{name, pure}, rest}:
      nx_choose(List<&2, String>, pure, u => Con{name, nx_i_eligible(rest)}, u => nx_i_eligible(rest))

@unsafe
def nx_i_function_count(+fs: List<&2, NxFunction>) -> U32:
  match fs:
    case Nil{}: 0
    case Con{head, rest}: U32.add(1, nx_i_function_count(rest))

@unsafe
def nx_i_deep_program(+program: NxProgram, +budget: U32) -> NxProgram:
  match program:
    case NxProgram{entry, fs}:
      nx_choose(NxProgram, U32.is_le(nx_i_function_count(fs), 256),
        u => nx_i_deep_facts(program, nx_i_facts(fs), budget), u => program)

@unsafe
def nx_i_deep_facts(+program: NxProgram, +facts: List<&2, NxIFact>, +budget: U32) -> NxProgram:
  nx_i_program_policy(program, budget, Some{nx_i_eligible(nx_i_prove_all(facts, facts, []))})

@unsafe
def nx_inline_deep(+program: NxProgram, +budget: U32) -> NxProgram:
  nx_choose(NxProgram, U32.is_eq(budget, 0), u => program,
    u => nx_choose(NxProgram, nx_verify(program),
      u => nx_i_deep_program(program, nx_inline_budget(budget)), u => program))
