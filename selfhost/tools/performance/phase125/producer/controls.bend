# Pure recognizer controls. These fabricated terms are never compiled/executed.
@unsafe
def p125pc_equation(+empty: String, +link: String, head: U32, tail: U32, suffix: U32, base: U32, target: String) -> KDef:
  +call = kt("App","",0,0,[kt("App","",0,0,[kt("Ref",target,0,1,[]),var("tail",tail)]),var("suffix",suffix)])
  +step = k_lam("head",1,1,[k_lam("tail",2,1,[k_lam("suffix",3,1,[kt("Ctr",link,0,1,[var("head",head),call])],0,0,False{})],0,0,False{})],0,0,False{})
  KDef{"join","Def",2,0,atom("Absent"),kt("Mat",empty,0,1,[
    k_lam("suffix",4,1,[var("suffix",base)],0,0,False{}),
    kt("Mat",link,0,1,[step,atom("Efq")])]),[],False{},False{}}

@unsafe
def p125pc_forward(dest: String, returned: String) -> List<&2,P113DStmt>:
  [P113DCall{[dest],"private",[N111Local{"left"},N111Local{"right"},N111Const{0,0},N111Const{0,0}]},
   P113DResult{[N111Local{returned}]}]

@unsafe
def p125pc_controls() -> List<&2,String>:
  [p113ft_row("exact-append-equations",p125p_equations(p125pc_equation("End","Link",1,2,3,4,"join"),"End","Link")),
   p113ft_row("constructor-name-independent",p125p_equations(p125pc_equation("Empty","Pair",1,2,3,4,"join"),"Empty","Pair")),
   p113ft_row("changed-head-refused",Bool.not(p125p_equations(p125pc_equation("End","Link",2,2,3,4,"join"),"End","Link"))),
   p113ft_row("non-tail-recursion-refused",Bool.not(p125p_equations(p125pc_equation("End","Link",1,1,3,4,"join"),"End","Link"))),
   p113ft_row("changed-suffix-refused",Bool.not(p125p_equations(p125pc_equation("End","Link",1,2,2,4,"join"),"End","Link"))),
   p113ft_row("changed-base-refused",Bool.not(p125p_equations(p125pc_equation("End","Link",1,2,3,1,"join"),"End","Link"))),
   p113ft_row("different-callee-refused",Bool.not(p125p_equations(p125pc_equation("End","Link",1,2,3,4,"other"),"End","Link"))),
   p113ft_row("wrong-constructor-refused",Bool.not(p125p_equations(p125pc_equation("End","Other",1,2,3,4,"join"),"End","Link"))),
   p113ft_row("forwarding-factory",p125p_forward(p125pc_forward("old_result","old_result"))),
   p113ft_row("different-return-refused",Bool.not(p125p_forward(p125pc_forward("old_result","other")))),
   p113ft_row("namespace-collision-refused",Bool.not(p125p_forward(p125pc_forward("p125_concat_out","p125_concat_out")))),
   p113ft_row("extra-effect-refused",Bool.not(p125p_forward(Con{P113DScalar{N111Call{"effect",N111U64{},"foreign",[]}},p125pc_forward("old_result","old_result")})))]
