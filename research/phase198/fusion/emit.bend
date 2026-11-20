@unsafe
def p198e_bin(name: String, op: String, a: N111Value, b: N111Value) -> N111Stmt:
  N111Bin{name,N111U64{},op,a,b}

@unsafe
def p198e_mask(+name: String, +source: String) -> N111Stmt:
  p198e_bin(name,"and",p121f_ref(source),N111Const{4294967295,0})

@unsafe
def p198e_again(m: String, b: String) -> P113DCode:
  P113DCode{[P113DAgain{[p121f_ref("epred"),p121f_ref("enext"),p121f_ref(m),p121f_ref(b)]}],90000,"",[]}

@unsafe
def p198e_action(+op: String, +left: Bool) -> P113DCode:
  nt_choose(P113DCode,String.eq(op,"U32.mul"),u =>
    p113d_prepend([p198e_bin("emul","mul",p121f_ref("em"),p121f_ref("esibling")),
      p198e_mask("enewm","emul")],p198e_again("enewm","ebias")),u =>
    p113d_prepend([p198e_bin("ecross","mul",p121f_ref("em"),p121f_ref("esibling")),
      p198e_bin("eplus",nt_choose(String,String.eq(op,"U32.sub") && left,v => "sub",v => "add"),
        p121f_ref("ebias"),p121f_ref("ecross")),p198e_mask("enewb","eplus")],
      nt_choose(P113DCode,String.eq(op,"U32.sub") && Bool.not(left),v =>
        p113d_prepend([p198e_bin("eneg","sub",N111Const{0,0},p121f_ref("em")),
          p198e_mask("enewm","eneg")],p198e_again("enewm","enewb")),v => p198e_again("em","enewb"))))

@unsafe
def p198e_action_arm(+book: List<&2,KDef>, +arm: P198EArm, +fresh: U32) -> P113DCode:
  match arm:
    case P198EArm{op,left,value,seed}:
      p113d_join(p121f_expr(book,value,[p121f_env(seed,"ebranch")],"esibling",fresh),p198e_action(op,left))
    case _: p113d_fail("missing proved word algebra arm",fresh)

@unsafe
def p198e_loop(+book: List<&2,KDef>, +step: KTerm, +base: KTerm, +basevar: KTerm, +next: KTerm,
    +key: KTerm, +branch: KTerm, +a: P198EArm, +b: P198EArm, +c: P198EArm) -> P113DCode:
  +env : List<&2,NC_Binding> = [p121f_env(step,"eseed")]
  +advance = p121f_expr(book,next,env,"enext",1000)
  +choice = p121f_expr(book,key,env,"ekey",p113d_fresh(advance))
  +argument = p121f_expr(book,branch,env,"ebranch",p113d_fresh(choice))
  +arms = p113d_prepend([p198e_bin("epred","sub",p121f_ref("ecount"),N111Const{1,0}),
      p198e_bin("ezero","eq",p121f_ref("ekey"),N111Const{0,0})],
    p113d_branch(p121f_ref("ezero"),p198e_action_arm(book,a,p113d_fresh(argument)),
      p113d_prepend([p198e_bin("eone","eq",p121f_ref("ekey"),N111Const{1,0})],
        p113d_branch(p121f_ref("eone"),p198e_action_arm(book,b,p113d_fresh(argument)),p198e_action_arm(book,c,p113d_fresh(argument))))))
  +leaf = p113d_join(p121f_expr(book,base,[p121f_env(basevar,"eseed")],"eleaf",1000),
    p113d_prepend([p198e_bin("efactor","mul",p121f_ref("em"),p121f_ref("eleaf")),
      p198e_bin("efinal","add",p121f_ref("efactor"),p121f_ref("ebias")),p198e_mask("eanswer","efinal")],
      P113DCode{[P113DResult{[p121f_ref("eanswer")]}],90000,"",[]}))
  p113d_prepend([p198e_bin("emore","ne",p121f_ref("ecount"),N111Const{0,0})],
    p113d_branch(p121f_ref("emore"),p113d_join(advance,p113d_join(choice,p113d_join(argument,arms))),leaf))

@unsafe
def p198e_candidates(+book: List<&2,KDef>, +name: String, plan: P198EPlan) -> List<&2,P113DCandidate>:
  match plan:
    case P198EReady{+params,n,seed,step,base,basevar,next,key,branch,a,b,c}:
      +worker = "$p198.algebra." ++ name
      +loop = p198e_loop(book,step,base,basevar,next,key,branch,a,b,c)
      +ncode = p121f_expr(book,n,params,"en0",1000)
      +scode = p121f_expr(book,seed,params,"es0",p113d_fresh(ncode))
      +entry = p113d_join(ncode,p113d_join(scode,P113DCode{[
        P113DCall{["eresult"],worker,[p121f_ref("en0"),p121f_ref("es0"),N111Const{1,0},N111Const{0,0}]},
        P113DResult{[p121f_ref("eresult")]}],p113d_fresh(scode),"",[worker]}))
      [P113DCandidate{P113DFunction{worker,[NC_Binding{0,"ecount",N_W32{}},NC_Binding{1,"eseed",N_W32{}},
         NC_Binding{2,"em",N_W32{}},NC_Binding{3,"ebias",N_W32{}}],1,False{},p113d_body(loop)},p113d_error(loop),p113d_calls(loop)},
       P113DCandidate{P113DFunction{p113d_public(book,name),params,1,True{},p113d_body(entry)},p113d_error(entry),p113d_calls(entry)}]
    case _: []

@unsafe
def p198e_select(+book: List<&2,KDef>, +name: String, +sigs: List<&2,KDef>, +prior: P121FPlan, +plan: P198EPlan) -> List<&2,P113DCandidate>:
  match plan:
    case P198ERefused{}: p125p_select(book,lookup(book,name),p125p_previous_selected(book,name,sigs,prior))
    case _: p198e_candidates(book,name,plan)

@unsafe
def p121f_selected(+book: List<&2,KDef>, +name: String, signatures: List<&2,KDef>, plan: P121FPlan) -> List<&2,P113DCandidate>:
  p198e_select(book,name,signatures,plan,p198e_plan(book,lookup(book,name)))

@unsafe
def p198e_inspect(+request: NR_Request, +name: String) -> P198EPlan:
  match request:
    case NR_Request{source,+book,names,paths,scope,bound}: p198e_plan(book,lookup(book,name))
