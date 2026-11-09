# A setup snapshot used repeatedly by the loop competes with a setup-only
# temporary. Both remain semantically live in their original regions.

def p185rs_setup() -> List<&2,P113DStmt>:
  [p185cp_set("saved",p185x_v("a")),p185cp_set("noise",p185x_v("b")),
   p185x_bin("first",N111U64{},"add",p185x_v("noise"),p185x_v("noise")),
   p185x_bin("second",N111U64{},"add",p185x_v("noise"),p185x_v("noise")),
   p185x_bin("third",N111U64{},"add",p185x_v("noise"),p185x_v("noise"))]

def p185rs_body() -> List<&2,P113DStmt>:
  [p185x_bin("twice",N111U64{},"add",p185x_v("saved"),p185x_v("saved")),
   p185x_bin("answer",N111U64{},"add",p185x_v("twice"),p185x_v("saved")),
   p185x_bin("done",N111U64{},"eq",p185x_v("n"),N111Const{0,0}),
   P113DIf{p185x_v("done"),[P113DResult{[p185x_v("answer")]}],
     [p185x_bin("next",N111U64{},"sub",p185x_v("n"),N111Const{1,0}),
      p185x_bin("changed",N111U64{},"add",p185x_v("a"),N111Const{1,0}),
      P113DAgain{[p185x_v("next"),p185x_v("changed"),p185x_v("b")]}]}]

@unsafe
def p185rs_validate() -> String:
  p113e_functions([P113DFunction{"p185l",p185cp_params(["n","a","b"],0),1,False{},
    nt_append(P113DStmt,p185rs_setup(),p185rs_body())}],N111Ids{missing(),missing()},missing())

@unsafe
def p185rs_emit() -> X181Output:
  x185_function_setup(p113e_symbol("p185l"),["state","n","a","b"],p185rs_setup(),p185rs_body(),N111Ids{missing(),missing()})
