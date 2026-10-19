# Data-only image mutations and semantic producer boundary checks.
@unsafe
def p112s_control_name(+name: String, good: Bool) -> String:
  nt_choose(String,good,u => "PASS " ++ name,u => "FAIL " ++ name)

def p112s_control_ctors() -> List<&2,N_Constructor>:
  [N_Constructor{"SNil",0,True{}},N_Constructor{"SCon",2,True{}},N_Constructor{"$ctor.Leaf",1,True{}},N_Constructor{"Pair",2,True{}},N_Constructor{"ALeaf",1,True{}}]

@unsafe
def p112s_control_image(nodes: List<&2,P112SNode>) -> Bool:
  String.is_empty(p112s_nodes_error(nodes,p112s_ctors(p112s_control_ctors(),0,missing()),missing(),0))

@unsafe
def p112s_control_shallow(result: P112STerm, +size: U32, +tag: String) -> Bool:
  match result:
    case P112STerm{+term,P112SImage{actual,nodes,index,error}}:
      String.is_empty(error) && U32.is_eq(size,actual) && String.eq(tg(term),tag) &&
        nt_choose(Bool,String.eq(tag,"NStatic"),u => List.is_empty(&2,KTerm,ks(term)),u => True{})

@unsafe
def p112s_control_stale(result: P112STerm) -> Bool:
  match result:
    case P112STerm{term,P112SImage{size,nodes,index,error}}: Bool.not(String.is_empty(error))

@unsafe
def p112s_control_dedup(first: P112STerm, +term: KTerm) -> Bool:
  match first:
    case P112STerm{head,image}: p112s_control_shallow(p112s_term(ns_ctor_index(p112s_control_ctors(),missing()),term,image),2,"NStatic")

@unsafe
def p112s_control_value(value: N111Value, +lo: U32, +hi: U32) -> Bool:
  match value:
    case N111Const{a,b}: U32.is_eq(a,lo) && U32.is_eq(b,hi)
    case _: False{}

@unsafe
def p112s_control_effect() -> Bool:
  +program : P111Program = P111Program{[],p112s_control_ctors(),[],[],["Pair"],False{}}
  Bool.not(String.is_empty(p112s_image_error(P112StaticProgram{program,[P112SNode{0,"Pair",[P112SRaw{0},P112SRaw{0}]}]})))

@unsafe
def p112s_control_report() -> List<&2,String>:
  +constructors = ns_ctor_index(p112s_control_ctors(),missing())
  +ids = p112s_ctors(p112s_control_ctors(),0,missing())
  +empty : P112SImage = P112SImage{0,[],missing(),""}
  +pair = kt("Ctr","Pair",0,0,[kt("NWord","7",0,0,[]),kt("NWord","11",0,0,[])])
  +valid : List<&2,P112SNode> = [P112SNode{0,"SCon",[P112SRaw{127822},P112SPacked{"SNil",0}]},P112SNode{2,"SCon",[P112SRaw{945},P112SBox{"SCon",0}]}]
  [p112s_control_name("empty-image",p112s_control_image([])),
   p112s_control_name("unicode-backward-image",p112s_control_image(valid)),
   p112s_control_name("packed-user-payload",p112s_control_image([P112SNode{0,"Pair",[P112SPacked{"$ctor.Leaf",4294967295},P112SRaw{0}]}])),
   p112s_control_name("offset-gap-refused",Bool.not(p112s_control_image([P112SNode{1,"Pair",[P112SRaw{0},P112SRaw{0}]}]))),
   p112s_control_name("forward-reference-refused",Bool.not(p112s_control_image([P112SNode{0,"SCon",[P112SRaw{0},P112SBox{"SCon",2}]},P112SNode{2,"SCon",[P112SRaw{1},P112SPacked{"SNil",0}]}]))),
   p112s_control_name("cycle-refused",Bool.not(p112s_control_image([P112SNode{0,"SCon",[P112SRaw{0},P112SBox{"SCon",0}]}]))),
   p112s_control_name("unknown-constructor-refused",Bool.not(p112s_control_image([P112SNode{0,"Missing",[P112SRaw{0}]}]))),
   p112s_control_name("wrong-arity-refused",Bool.not(p112s_control_image([P112SNode{0,"Pair",[P112SRaw{0}]}]))),
   p112s_control_name("array-image-refused",Bool.not(p112s_control_image([P112SNode{0,"ALeaf",[P112SRaw{0}]}]))),
   p112s_control_name("registered-effect-image-refused",p112s_control_effect()),
   p112s_control_name("packed-nullary-payload-refused",Bool.not(p112s_control_image([P112SNode{0,"Pair",[P112SPacked{"SNil",1},P112SRaw{0}]}]))),
   p112s_control_name("packed-multifield-refused",Bool.not(p112s_control_image([P112SNode{0,"Pair",[P112SPacked{"Pair",0},P112SRaw{0}]}]))),
   p112s_control_name("boxed-word-exact",p112s_control_value(p112s_word(P112SBox{"SCon",2},ids),51413506,33554688)),
   p112s_control_name("packed-word-exact",p112s_control_value(p112s_word(P112SPacked{"$ctor.Leaf",4294967295},ids),4294967295,16777728)),
   p112s_control_name("shallow-static-atom",p112s_control_shallow(p112s_term(constructors,pair,empty),2,"NStatic")),
   p112s_control_name("exact-intern-dedup",p112s_control_dedup(p112s_term(constructors,pair,empty),pair)),
   p112s_control_name("stale-marker-refused",p112s_control_stale(p112s_term(constructors,kt("NStatic","Pair",0,0,[]),empty))),
   p112s_control_name("budget-exact-fill",p112s_control_shallow(p112s_term(constructors,pair,P112SImage{65534,[],missing(),""}),65536,"NStatic")),
   p112s_control_name("budget-parent-fallback",p112s_control_shallow(p112s_term(constructors,pair,P112SImage{65535,[],missing(),""}),65535,"Ctr")),
   p112s_control_name("array-producer-fallback",p112s_control_shallow(p112s_term(constructors,kt("Ctr","ALeaf",0,0,[kt("NWord","7",0,0,[])]),empty),0,"Ctr"))]
