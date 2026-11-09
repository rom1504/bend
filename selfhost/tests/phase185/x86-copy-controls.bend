# Stable-copy execution controls. Keep the one-time setup separate from the
# body when emitting p185j; combining them is only the original IR gate.

@unsafe
def p185cp_params(names: List<&2,String>, +index: U32) -> List<&2,NC_Binding>:
  match names:
    case Nil{}: []
    case Con{name,rest}: Con{NC_Binding{index,name,N_W64{}},p185cp_params(rest,U32.inc(index))}

def p185cp_set(name: String, value: N111Value) -> P113DStmt:
  P113DScalar{N111Set{name,N111U64{},value}}

def p185cp_loop() -> P113DFunction:
  P113DFunction{"p185e",p185cp_params(["n","a"],0),1,False{},
    [p185cp_set("saved",p185x_v("a")),
     p185x_bin("done",N111U64{},"eq",p185x_v("n"),N111Const{0,0}),
     P113DIf{p185x_v("done"),[P113DResult{[p185x_v("saved")]}],
       [p185x_bin("next",N111U64{},"sub",p185x_v("n"),N111Const{1,0}),
        p185x_bin("changed",N111U64{},"add",p185x_v("a"),N111Const{1,0}),
        P113DAgain{[p185x_v("next"),p185x_v("changed")]}]}]}

def p185cp_mutate() -> P113DFunction:
  P113DFunction{"p185f",p185cp_params(["a"],0),2,False{},
    [p185cp_set("saved",p185x_v("a")),
     p185x_bin("a",N111U64{},"add",p185x_v("a"),N111Const{1,0}),
     P113DResult{[p185x_v("saved"),p185x_v("a")]}]}

def p185cp_branch() -> P113DFunction:
  P113DFunction{"p185g",p185cp_params(["a","b"],0),2,False{},
    [p185cp_set("x",p185x_v("a")),p185cp_set("saved",p185x_v("x")),
     p185x_bin("zero",N111U64{},"eq",p185x_v("a"),N111Const{0,0}),
     P113DIf{p185x_v("zero"),[p185cp_set("x",p185x_v("b"))],
       [p185x_bin("x",N111U64{},"add",p185x_v("a"),N111Const{1,0})]},
     P113DResult{[p185x_v("saved"),p185x_v("x")]}]}

def p185cp_unique() -> P113DFunction:
  P113DFunction{"p185h",p185cp_params(["a"],0),1,False{},
    [p185x_bin("zero",N111U64{},"eq",p185x_v("a"),N111Const{0,0}),
     P113DIf{p185x_v("zero"),[P113DResult{[N111Const{99,0}]}],[p185cp_set("x",p185x_v("a"))]},
     p185cp_set("y",p185x_v("x")),P113DResult{[p185x_v("y")]}]}

def p185cp_permute() -> P113DFunction:
  P113DFunction{"p185i",p185cp_params(["n","a","b"],0),2,False{},
    [p185cp_set("x",p185x_v("a")),p185cp_set("y",p185x_v("b")),
     p185x_bin("done",N111U64{},"eq",p185x_v("n"),N111Const{0,0}),
     P113DIf{p185x_v("done"),[P113DResult{[p185x_v("x"),p185x_v("y")]}],
       [p185x_bin("next",N111U64{},"sub",p185x_v("n"),N111Const{1,0}),
        P113DAgain{[p185x_v("next"),p185x_v("y"),p185x_v("x")]}]}]}

def p185cp_setup() -> List<&2,P113DStmt>:
  [p185cp_set("snapshot",p185x_v("a"))]

def p185cp_setup_body() -> List<&2,P113DStmt>:
  [p185cp_set("copy",p185x_v("snapshot")),
   p185x_bin("done",N111U64{},"eq",p185x_v("n"),N111Const{0,0}),
   P113DIf{p185x_v("done"),[P113DResult{[p185x_v("copy")]}],
     [p185x_bin("next",N111U64{},"sub",p185x_v("n"),N111Const{1,0}),
      p185x_bin("changed",N111U64{},"add",p185x_v("a"),N111Const{1,0}),
      P113DAgain{[p185x_v("next"),p185x_v("changed")]}]}]

@unsafe
def p185cp_setup_function(+candidate: Bool) -> P113DFunction:
  P113DFunction{"p185j",p185cp_params(["n","a"],0),1,False{},
    nt_append(P113DStmt,p185cp_setup(),nt_choose(List<&2,P113DStmt>,candidate,
      u => x185_prepare_body(["state","n","a"],p185cp_setup(),p185cp_setup_body()),u => p185cp_setup_body()))}

@unsafe
def p185cp_emit_setup() -> X181Output:
  x185_function_setup(p113e_symbol("p185j"),["state","n","a"],p185cp_setup(),p185cp_setup_body(),N111Ids{missing(),missing()})

@unsafe
def p185cp_narrow() -> P113DFunction:
  P113DFunction{"p185k",p185cp_params(["a"],0),1,False{},
    nt_append(P113DStmt,
      [P113DScalar{N111Store{N111U64{},p185x_v("scratch"),0,p185x_v("a")}},
       P113DScalar{N111Load{"low",N111U32{},p185x_v("scratch"),0}},
       P113DScalar{N111Set{"copy",N111U32{},p185x_v("low")}}],
      nt_append(P113DStmt,p185x_widen(["copy"]),[P113DResult{[p185x_v("z_copy")]}]))}

def p185cp_functions() -> List<&2,P113DFunction>:
  [p185cp_loop(),p185cp_mutate(),p185cp_branch(),p185cp_unique(),p185cp_permute(),p185cp_narrow()]

@unsafe
def p185cp_candidate(function: P113DFunction) -> P113DFunction:
  match function:
    case P113DFunction{name,+params,result,public,body}:
      P113DFunction{name,params,result,public,x185_prepare_body(Con{"state",x181_param_names(params)},[],body)}

@unsafe
def p185cp_candidates(functions: List<&2,P113DFunction>) -> List<&2,P113DFunction>:
  match functions:
    case Nil{}: []
    case Con{head,rest}: Con{p185cp_candidate(head),p185cp_candidates(rest)}

@unsafe
def p185cp_validate() -> String:
  p111_first(p113e_functions(Con{p185cp_setup_function(False{}),p185cp_functions()},N111Ids{missing(),missing()},missing()),
    p113e_functions(Con{p185cp_setup_function(True{}),
      p185cp_candidates(nt_append(P113DFunction,p185cp_functions(),p185x_functions()))},N111Ids{missing(),missing()},missing()))
