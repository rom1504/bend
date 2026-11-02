# Actual production source graph and pinned full Base; only the private
# clone's name predicate differs. Complete independent FResult serialization.
@unsafe
def p155t_result(parsed: FResult) -> String:
  match parsed:
    case FResult{book,error,imports}:
      "R" ++ p155p_defs(book) ++ "E" ++ p155p_string(error) ++ "I" ++ p155p_terms(imports)

@unsafe
def p155t_loaded(trace: FLoadTrace) -> FResult:
  match trace:
    case FLoadTrace{result,done,sources}: result

@unsafe
def p155t_sources(+source: String, +base: String) -> List<&2,FSource>:
  +end = U32.add(dg_width(base),2)
  [FLocatedSource{FSource{"Base","/phase155/Base.bend",base},1,end},
   FLocatedSource{FSource{"Main","/phase155/Main.bend",source},end,U32.add(U32.add(end,dg_width(source)),1)}]

@unsafe
def p155t_parse(+source: String, +n: U32, changed: Bool) -> FResult:
  +sources = p155t_sources(source,p155t_base_source(n))
  p155t_loaded(p155x_choose(FLoadTrace,changed,
    u => p155t_clone_f_load_graph_trace("/phase155/Main.bend",sources),
    u => f_load_graph_trace("/phase155/Main.bend",sources)))

@unsafe
def p155t_repeat(+n: U32, +changed: Bool) -> String:
  match n:
    case 0: "done"
    case _:
      +prior = U32.sub(n,1)
      "C" ++ p155t_result(p155t_parse(p155t_compiler_source(prior),prior,changed)) ++
      "O" ++ p155t_result(p155t_parse(p155t_ordinary_source(prior),prior,changed)) ++
      p155t_repeat(prior,changed)

def p155t_old(n: U32) -> String:
  p155t_repeat(n,False{})

def p155t_new(n: U32) -> String:
  p155t_repeat(n,True{})

@unsafe
def p155t_named(book: List<&2,KDef>, +wanted: String) -> Bool:
  match book:
    case Nil{}: False{}
    case Con{definition,rest}: String.eq(dn(definition),wanted) || p155t_named(rest,wanted)

@unsafe
def p155t_accept(parsed: FResult, wanted: String) -> Bool:
  match parsed:
    case FResult{book,error,imports}: String.is_empty(error) && p155t_named(book,wanted)

# Independently known declarations in the exact dependency-closed fixtures.
# Matching error results must never count as successful parser transfer.
def p155t_controls(unused: U32) -> String:
  p155x_choose(String,
    p155t_accept(p155t_parse(p155t_compiler_source(0),0,False{}),"p111v_functions") &&
    p155t_accept(p155t_parse(p155t_compiler_source(0),0,True{}),"p111v_functions") &&
    p155t_accept(p155t_parse(p155t_ordinary_source(0),0,False{}),"eval") &&
    p155t_accept(p155t_parse(p155t_ordinary_source(0),0,True{}),"eval"),
    u => "ok",u => "parse failure")
