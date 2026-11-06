# Full-record differential inputs for the exact already-filtered-env boundary.
# Some raw terms are deliberately malformed; both lowering APIs must agree.
type P171LEInput is Data:
  P171LEInput{+name: String, +value: KTerm, +env: List<&2,NC_Binding>, +body: KTerm}

type P171LECase is Data:
  P171LECase{+name: String, +code: P113DCode}

@unsafe
def p171le_inputs() -> List<&2,P171LEInput>:
  +word = kt("NWord","7",0,0,[])
  +bound = var("bound",7)
  +env : List<&2,NC_Binding> = [NC_Binding{3,"unused",N_W64{}},NC_Binding{1,"first",N_W32{}},
    NC_Binding{2,"held",N_W64{}},NC_Binding{1,"second",N_W64{}},NC_Binding{13,"raw_head",N_W64{}}]
  [P171LEInput{"empty-env",word,[],bound},
   P171LEInput{"live-var",var("one",1),[NC_Binding{1,"one",N_W32{}}],kt("NOp","u32_add",0,0,[bound,var("one",1)])},
   P171LEInput{"duplicate-ids",var("one",1),env,kt("NOp","u32_add",0,0,[bound,var("held",2)])},
   P171LEInput{"var-children-stay-ignored",kt("Var","raw",1,1,[var("ignored",2)]),env,bound},
   P171LEInput{"nested-let",kt("Let","",0,0,[kt("Bind","",13,1,[word]),var("one",1)]),env,bound},
   P171LEInput{"malformed-binding-var",kt("NSeqLet","",0,0,[kt("Var","head",13,1,[var("child",2)]),var("one",1)]),env,bound},
   P171LEInput{"empty-let-failure",kt("Let","",0,0,[]),env,bound},
   P171LEInput{"product-fields",kt("NCtr","Pair",0,0,[word,word]),env,bound}]

@unsafe
def p171le_one(input: P171LEInput) -> List<&2,P171LECase>:
  match input:
    case P171LEInput{+name,+value,+env,+body}:
      +target : P113PTarget = P113PTarget{[],atom("Absent"),True{},"owner",[]}
      +rest = p112_liveness_terms([body])
      [P171LECase{name ++ ":direct",p113d_let([],value,body,env,7,"owner",P113DReturn{},17)},
       P171LECase{name ++ ":direct-plan",p113dl_let([],value,rest,env,7,"owner",P113DReturn{},17)},
       P171LECase{name ++ ":flat",p113pl_bind_flat([],value,body,env,7,target,17,kt("NQShape","Pair",2,0,[]))},
       P171LECase{name ++ ":boxed",p113pl_bind_boxed([],value,body,env,7,target,17)},
       P171LECase{name ++ ":product-plan",p113px_boxed([],value,rest,env,7,target,17)}]

@unsafe
def p171le_rows(inputs: List<&2,P171LEInput>) -> List<&2,P171LECase>:
  match inputs:
    case Nil{}: []
    case Con{input,rest}: nt_append(P171LECase,p171le_one(input),p171le_rows(rest))

@unsafe
def p171le_whole() -> List<&2,P171LECase>:
  +env : List<&2,NC_Binding> = [NC_Binding{3,"unused_a",N_W64{}},NC_Binding{1,"one",N_W32{}},
    NC_Binding{4,"unused_b",N_W32{}},NC_Binding{1,"one_alias",N_W64{}}]
  +good = kt("Let","",0,0,[kt("Bind","",7,1,[var("one",1)]),var("bound",7)])
  +bad = kt("Let","",0,0,[kt("Bind","",7,1,[kt("BadFirst","",0,0,[])]),var("bound",7)])
  +target : P113PTarget = P113PTarget{[],atom("Absent"),True{},"owner",[]}
  [P171LECase{"outer-direct-drop-order",p113d_lower([],good,env,"owner",P113DReturn{},31)},
   P171LECase{"outer-product-drop-order",p113pl_lower([],good,env,target,31)},
   P171LECase{"outer-direct-failure",p113d_lower([],bad,env,"owner",P113DReturn{},31)},
   P171LECase{"outer-product-failure",p113pl_lower([],bad,env,target,31)}]

@unsafe
def p171le_cases() -> List<&2,P171LECase>:
  nt_append(P171LECase,p171le_rows(p171le_inputs()),p171le_whole())
