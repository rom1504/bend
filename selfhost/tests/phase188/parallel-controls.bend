# Phase188 test-only type/render adaptation; Phase186 source and C oracle remain frozen.
@unsafe
def p186mv_loop(name: String, params: List<&2,String>, +results: List<&2,N111Value>,
    changed: List<&2,N111Value>, prefix: List<&2,P113DStmt>) -> P113DFunction:
  P113DFunction{name,p186_params(params,0),nt_count(N111Value,results),False{},
    [p186_bin("done","eq",p186_v("n"),N111Const{0,0}),
     P113DIf{p186_v("done"),[P113DResult{results}],nt_append(P113DStmt,prefix,
       [p186_bin("next","sub",p186_v("n"),N111Const{1,0}),P113DAgain{Con{p186_v("next"),changed}}])}]}

def p186mv_chain() -> P113DFunction:
  p186mv_loop("p186va",["n","a","b","c"],[p186_v("a"),p186_v("b"),p186_v("c")],
    [p186_v("b"),p186_v("c"),N111Const{2309737967,4275878552}],[])
def p186mv_swap() -> P113DFunction:
  p186mv_loop("p186vb",["n","a","b"],[p186_v("a"),p186_v("b")],[p186_v("b"),p186_v("a")],[])
def p186mv_rotate() -> P113DFunction:
  p186mv_loop("p186vc",["n","a","b","c"],[p186_v("a"),p186_v("b"),p186_v("c")],
    [p186_v("b"),p186_v("c"),p186_v("a")],[])
def p186mv_fanout() -> P113DFunction:
  p186mv_loop("p186vd",["n","a","b","c"],[p186_v("a"),p186_v("b"),p186_v("c")],
    [p186_v("b"),p186_v("b"),p186_v("a")],[])
def p186mv_constants() -> P113DFunction:
  p186mv_loop("p186ve",["n","a","b"],[p186_v("a"),p186_v("b")],
    [N111Const{2309737967,4275878552},N111Const{4294967295,4294967295}],[])
def p186mv_transient() -> P113DFunction:
  p186mv_loop("p186vf",["n","a","b","c","d","e"],
    [p186_v("a"),p186_v("b"),p186_v("c"),p186_v("d"),p186_v("e")],
    [p186_v("u"),p186_v("v"),p186_v("w"),p186_v("x"),p186_v("y")],
    [p186_bin("u","add",p186_v("a"),N111Const{1,0}),p186_bin("v","add",p186_v("b"),N111Const{2,0}),
     p186_bin("w","add",p186_v("c"),N111Const{3,0}),p186_bin("x","add",p186_v("d"),N111Const{4,0}),
     p186_bin("y","add",p186_v("e"),N111Const{5,0})])

def p186mv_setup() -> List<&2,P113DStmt>: [p186_set("saved",p186_v("a"))]
def p186mv_setup_body() -> List<&2,P113DStmt>:
  [p186_bin("done","eq",p186_v("n"),N111Const{0,0}),
   P113DIf{p186_v("done"),[P113DResult{[p186_v("a"),p186_v("saved")]}],
     [p186_bin("next","sub",p186_v("n"),N111Const{1,0}),p186_bin("changed","add",p186_v("a"),N111Const{1,0}),
      P113DAgain{[p186_v("next"),p186_v("changed")]}]}]
@unsafe
def p186mv_setup_function() -> P113DFunction:
  P113DFunction{"p186vg",p186_params(["n","a"],0),2,False{},nt_append(P113DStmt,p186mv_setup(),p186mv_setup_body())}

def p186mv_functions() -> List<&2,P113DFunction>:
  [p186mv_chain(),p186mv_swap(),p186mv_rotate(),p186mv_fanout(),p186mv_constants(),p186mv_transient(),p186mv_setup_function()]
@unsafe
def p186mv_validate() -> String:
  p113e_functions(p186mv_functions(),N111Ids{missing(),missing()},missing())

@unsafe
def p186mv_install(frame: X181Frame) -> X181Frame:
  match frame:
    case X181Frame{slots,bytes,calls,params,symbol}:
      X181Frame{p111v_put(p111v_put(p111v_put(p111v_put(p111v_put(slots,
        "u","X185Transient",0,8),"v","X185Transient",1,8),"w","X185Transient",2,8),
        "x","X185Transient",3,8),"y","X185Transient",4,8),bytes,calls,params,symbol}

# Exercise register/register cycles and register/stack chains with the same
# semantic fixtures. The incoming argument path still establishes every home.
@unsafe
def p186mv_mixed(frame: X181Frame) -> X181Frame:
  match frame:
    case X181Frame{slots,bytes,calls,params,symbol}:
      X181Frame{p111v_put(p111v_put(slots,"a","X181Register",1,8),"b","X181Register",2,8),bytes,calls,params,symbol}

@unsafe
def p186mv_emit_one(function: P113DFunction) -> X181Output:
  match function:
    case P113DFunction{+name,params,result,public,+body}:
      +words: List<&2,String> = Con{"state",Con{"__x181_result_out",x181_param_names(params)}}
      +frame = x181_frame(p113e_symbol(name),words,body)
      x181_function_frame(p113e_symbol(name),body,N111Ids{missing(),missing()},
        nt_choose(X181Frame,String.eq(name,"p186vf"),u => p186mv_install(frame),u => p186mv_mixed(frame)))

@unsafe
def p186mv_emit_functions(functions: List<&2,P113DFunction>) -> X181Output:
  match functions:
    case Nil{}: X181Output{[],""}
    case Con{P113DFunction{+name,params,result,public,body},+rest}:
      nt_choose(X181Output,String.eq(name,"p186vg"),
        u => x181_program_join(x185_function_setup(p113e_symbol(name),["state","__x181_result_out","n","a"],
          p186mv_setup(),p186mv_setup_body(),N111Ids{missing(),missing()}),p186mv_emit_functions(rest)),
        u => x181_program_join(p186mv_emit_one(P113DFunction{name,params,result,public,body}),p186mv_emit_functions(rest)))

@unsafe
def p186mv_emit() -> X181Output: p186mv_emit_functions(p186mv_functions())

def p186mv_ready(plan: Maybe<&2,X188Seq>) -> Bool:
  match plan:
    case Some{text}: True{}
    case _: False{}
def p186mv_empty(plan: Maybe<&2,X188Seq>) -> Bool:
  match plan:
    case Some{text}: x188_empty(text)
    case _: False{}

@unsafe
def p186mv_plan(params: List<&2,String>, values: List<&2,N111Value>) -> Maybe<&2,X188Seq>:
  x186_parallel(params,values,N111Ids{missing(),missing()},x181_frame("probe",["state","n","a","b","c"],[]))

@unsafe
def p186mv_duplicate(frame: X181Frame) -> X181Frame:
  match frame:
    case X181Frame{+slots,bytes,calls,params,symbol}:
      X181Frame{p111v_put(slots,"b","X181Stack",da(p111v_get(slots,"a")),8),bytes,calls,params,symbol}

@unsafe
def p186mv_many(+count: U32) -> List<&2,String>:
  nt_choose(List<&2,String>,U32.is_eq(count,0),u => [],u => Con{"p" ++ U32.show(count),p186mv_many(U32.sub(count,1))})

@unsafe
def p186mv_controls() -> List<&2,String>:
  [p186pm_row("verified",String.is_empty(p186mv_validate())),
   p186pm_row("self-empty",p186mv_empty(p186mv_plan(["a","b"],[p186_v("a"),p186_v("b")]))),
   p186pm_row("acyclic-chain",p186mv_ready(p186mv_plan(["a","b","c"],[p186_v("b"),p186_v("c"),N111Const{1,0}]))),
   p186pm_row("self-fanout",p186mv_ready(p186mv_plan(["a","b","c"],[p186_v("b"),p186_v("b"),p186_v("a")]))),
   p186pm_row("two-cycle-fallback",Bool.not(p186mv_ready(p186mv_plan(["a","b"],[p186_v("b"),p186_v("a")])))),
   p186pm_row("three-cycle-fallback",Bool.not(p186mv_ready(p186mv_plan(["a","b","c"],[p186_v("b"),p186_v("c"),p186_v("a")])))),
   p186pm_row("discard-scheduled-prefix",Bool.not(p186mv_ready(p186mv_plan(["n","a","b"],[N111Const{0,0},p186_v("b"),p186_v("a")])))),
   p186pm_row("mismatched-vector",Bool.not(p186mv_ready(p186mv_plan(["a","b"],[p186_v("a")])))),
   p186pm_row("duplicate-homes",Bool.not(p186mv_ready(x186_parallel(["a","b"],[N111Const{1,0},N111Const{2,0}],
     N111Ids{missing(),missing()},p186mv_duplicate(x181_frame("probe",["state","a","b"],[])))))),
   p186pm_row("buffer-source-fallback",Bool.not(p186mv_ready(p186mv_plan(["a"],[p186_v("scratch")])))),
   p186pm_row("bounded-vector",Bool.not(p186mv_ready(p186mv_plan(p186mv_many(65),[]))))]
