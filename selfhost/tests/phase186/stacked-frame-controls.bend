# Original N111 segments are independently verified before planning/emission.
# Two pending owned-word captures, arithmetic continuations, and deep explicit
# descent exercise order and restoration without relying on a source oracle.

@unsafe
def p186sfc_bind(name: String, id: U32) -> NC_Binding:
  NC_Binding{id,name,N_W64{}}

@unsafe
def p186sfc_v(name: String) -> N111Value:
  N111Local{name}

@unsafe
def p186sfc_return(word: N111Value) -> List<&2,N111Stmt>:
  p111_body(p111_return(word,0))

@unsafe
def p186sfc_frame(name: String, word: String) -> List<&2,N111Stmt>:
  p111_frame([p186sfc_bind(word,0)],name)

@unsafe
def p186sfc_again(owner: String) -> List<&2,N111Stmt>:
  Con{N111Bin{"next_n",N111U64{},"sub",p186sfc_v("n"),N111Const{1,0}},
  Con{N111Bin{"next_seed",N111U64{},"add",p186sfc_v("seed"),N111Const{3,0}},
    p111_body(p111_jump(owner,[p186sfc_v("next_n"),p186sfc_v("next_seed")],0))}}

@unsafe
def p186sfc_step(+owner: String, +mode: U32) -> List<&2,N111Stmt>:
  +outer = p186sfc_frame("outer","seed")
  +inner = p186sfc_frame("inner","n")
  nt_choose(List<&2,N111Stmt>,U32.is_eq(mode,0),
    u => nt_append(N111Stmt,outer,nt_append(N111Stmt,inner,p186sfc_again(owner))),
    u => [N111Bin{"odd",N111U64{},"and",p186sfc_v("n"),N111Const{1,0}},
      N111Bin{"is_odd",N111U64{},"ne",p186sfc_v("odd"),N111Const{0,0}},
      N111If{p186sfc_v("is_odd"),
        nt_append(N111Stmt,inner,nt_append(N111Stmt,outer,p186sfc_again(owner))),
        nt_append(N111Stmt,outer,p186sfc_again(owner))}])

@unsafe
def p186sfc_owner(+name: String, mode: U32) -> N111Segment:
  p111_segment(name,[p186sfc_bind("n",0),p186sfc_bind("seed",1)],0,0,
    [N111Bin{"zero",N111U64{},"eq",p186sfc_v("n"),N111Const{0,0}},
      N111If{p186sfc_v("zero"),p186sfc_return(p186sfc_v("seed")),p186sfc_step(name,mode)}])

@unsafe
def p186sfc_outer() -> N111Segment:
  p111_segment("outer",[p186sfc_bind("captured",0),p186sfc_bind("result",1)],1,1,
    Con{N111Bin{"answer",N111U64{},"xor",p186sfc_v("result"),p186sfc_v("captured")},
      p186sfc_return(p186sfc_v("answer"))})

@unsafe
def p186sfc_inner() -> N111Segment:
  p111_segment("inner",[p186sfc_bind("captured",0),p186sfc_bind("result",1)],1,1,
    Con{N111Bin{"scaled",N111U64{},"mul",p186sfc_v("captured"),N111Const{17,0}},
    Con{N111Bin{"answer",N111U64{},"add",p186sfc_v("result"),p186sfc_v("scaled")},
      p186sfc_return(p186sfc_v("answer"))}})

@unsafe
def p186sfc_segments(mode: U32) -> List<&2,N111Segment>:
  [p186sfc_owner("stacked",mode),p186sfc_outer(),p186sfc_inner()]

@unsafe
def p186sfc_plan(+mode: U32) -> P114HPlan:
  p114h_plan(p186sfc_owner("stacked",mode),p112f_index(p186sfc_segments(mode)),missing())

@unsafe
def p186sfc_verified_scan(+segments: List<&2,N111Segment>, scan: P111VScan) -> String:
  match scan:
    case P111VScan{index,+error,count}:
      nt_choose(String,String.is_empty(error),u => p111v_segments(segments,N111Ids{index,missing()}),u => error)

@unsafe
def p186sfc_verified(+mode: U32) -> String:
  +segments = p186sfc_segments(mode)
  p186sfc_verified_scan(segments,p111v_functions(segments,P111VScan{missing(),"",0}))

@unsafe
def p186sfc_count(plan: P114HPlan) -> U32:
  match plan:
    case P114HPlan{valid,params,body,cases}: nt_count(P114HCase,cases)

@unsafe
def p186sfc_text(+mode: U32) -> String:
  p114h_private("stacked",N111Ids{p111q_function_ids(p186sfc_segments(mode),0,missing()),missing()},p186sfc_plan(mode))

@unsafe
def p186sfc_old_refused() -> Bool:
  +body = p186sfc_step("stacked",0)
  p186sfc_refused(p186sf_previous_frame(body,"stacked",2,missing(),p112f_frame(body,0,[])))

@unsafe
def p186sfc_refused(scanned: P114GBody) -> Bool:
  match scanned:
    case P114GBody{valid,frames,lowered}: Bool.not(valid)

@unsafe
def p186sfc_unknown() -> Bool:
  +body = nt_append(N111Stmt,p186sfc_frame("outer","seed"),
    p111_body(p111_jump("unready",[p186sfc_v("seed")],0)))
  p186sfc_refused(p114h_scan(body,"stacked",2,missing()))

@unsafe
def p186sfc_missing() -> Bool:
  Bool.not(p114h_valid(p114h_plan(p186sfc_owner("stacked",0),p112f_index([p186sfc_owner("stacked",0),p186sfc_outer()]),missing())))

@unsafe
def p186sfc_many_frames(+left: U32) -> List<&2,N111Stmt>:
  nt_choose(List<&2,N111Stmt>,U32.is_eq(left,0),u => p186sfc_again("many"),
    u => nt_append(N111Stmt,p186sfc_frame("case" ++ U32.show(left),"seed"),p186sfc_many_frames(U32.sub(left,1))))

@unsafe
def p186sfc_many_cases(+left: U32) -> List<&2,N111Segment>:
  nt_choose(List<&2,N111Segment>,U32.is_eq(left,0),u => [],u =>
    Con{p111_segment("case" ++ U32.show(left),[p186sfc_bind("captured",0),p186sfc_bind("result",1)],1,1,
      p186sfc_return(p186sfc_v("result"))),p186sfc_many_cases(U32.sub(left,1))})

@unsafe
def p186sfc_many(+count: U32) -> Bool:
  +owner = p111_segment("many",[p186sfc_bind("n",0),p186sfc_bind("seed",1)],0,0,p186sfc_many_frames(count))
  p114h_valid(p114h_plan(owner,p112f_index(Con{owner,p186sfc_many_cases(count)}),missing()))

@unsafe
def p186sfc_row(name: String, +ok: Bool) -> String:
  name ++ nt_choose(String,ok,u => "=1",u => "=0")

@unsafe
def p186sfc_failed(code: P111QCode) -> Bool:
  match code:
    case P111QCode{chunks,next,terminal,error}: Bool.not(String.is_empty(error))

@unsafe
def p186sfc_controls() -> List<&2,String>:
  +text = p186sfc_text(0)
  [p186sfc_row("original-ir-two-verified",String.is_empty(p186sfc_verified(0))),
   p186sfc_row("original-ir-branch-verified",String.is_empty(p186sfc_verified(1))),
   p186sfc_row("original-single-frame-rule-refuses",p186sfc_old_refused()),
   p186sfc_row("two-pending-admitted",p114h_valid(p186sfc_plan(0))),
   p186sfc_row("alternating-branches-admitted",p114h_valid(p186sfc_plan(1))),
   p186sfc_row("two-cases",U32.is_eq(p186sfc_count(p186sfc_plan(0)),2)),
   p186sfc_row("unknown-call-refused",p186sfc_unknown()),
   p186sfc_row("missing-case-refused",p186sfc_missing()),
   p186sfc_row("eight-cases-admitted",p186sfc_many(8)),
   p186sfc_row("nine-cases-refused",Bool.not(p186sfc_many(9))),
   p186sfc_row("no-global-dispatch",Bool.not(String.contains(text,"call $p111_rt_jump") || String.contains(text,"call $p111_rt_return"))),
   p186sfc_row("no-native-self-call",Bool.not(String.contains(text,"call $" ++ p114r_symbol("stacked")))),
   p186sfc_row("explicit-depth",String.contains(text,"%p114r_depth =l add %p114r_depth, 1")),
   p186sfc_row("outside-region-refused",p186sfc_failed(p114r_stmt(P114RPushFrame{p186sfc_frame("outer","seed")},[],N111Ids{missing(),missing()},P111QCode{[],0,False{},""})))]

@unsafe
def p186sfc_oracle_module(mode: U32) -> String:
  p186sfc_text(mode) ++ "export function l $p186stack(l %state, l %n, l %seed) {\n@entry\n%value =l call $" ++
    p114r_symbol("stacked") ++ "(l %state, l %n, l %seed)\nret %value\n}\n"
