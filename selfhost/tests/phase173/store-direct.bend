# Direct terminal destination for indexed compaction. The input store is read
# only; output KTerm and ordered refs are the required public product.
type P173OChild is Data:
  P173OChild{+shape: P173Shape, +start: U32, +next: U32, +count: U32, +terms: List<&2,KTerm>, +raw: Bool}

type P173OFrame is Data:
  P173OVisit{+id: U32, +raw: Bool}
  P173OChildren{+child: P173OChild}
  P173OSucc{+count: U32}
  P173OString{+text: String}
  P173OStringJoin{+head: KTerm}

type P173OState is Data:
  P173OState{+todo: List<&2,P173OFrame>, +values: List<&2,KTerm>, +references: List<&2,String>, +fuel: U32}

type P173OResult is Type:
  P173OResult{store: P173Store, +term: KTerm, +references: List<&2,String>}

law p173o_go:
  for store: P173Store
  for state: P173OState
  P173OResult

@unsafe
def p173o_refused(store: P173Store) -> P173OResult:
  P173OResult{p173s_fail(store),atom("Absent"),[]}

@unsafe
def p173o_fuel(state: P173OState) -> U32:
  match state:
    case P173OState{todo,values,references,fuel}: fuel

@unsafe
def p173o_with_fuel(state: P173OState, fuel: U32) -> P173OState:
  match state:
    case P173OState{todo,values,references,old}: P173OState{todo,values,references,fuel}

@unsafe
def p173o_note(state: P173OState, name: String) -> P173OState:
  match state:
    case P173OState{todo,values,references,fuel}: P173OState{todo,values,Con{name,references},fuel}

@unsafe
def p173o_note_if(state: P173OState, name: String, yes: Bool) -> P173OState:
  match yes:
    case True{}: p173o_note(state,name)
    case False{}: state

@unsafe
def p173o_note_shape(state: P173OState, +shape: P173Shape) -> P173OState:
  p173o_note_if(state,p173s_shape_name(shape),p88_string_eq(p173s_shape_tag(shape),"Ref"))

@unsafe
def p173o_push(store: P173Store, state: P173OState, term: KTerm) -> P173OResult:
  match state:
    case P173OState{todo,values,references,fuel}:
      p173o_go(store,P173OState{todo,Con{term,values},references,fuel})

@unsafe
def p173o_queue(store: P173Store, state: P173OState, frames: List<&2,P173OFrame>) -> P173OResult:
  match state:
    case P173OState{todo,values,references,fuel}:
      p173o_go(store,P173OState{nt_append(P173OFrame,frames,todo),values,references,fuel})

@unsafe
def p173o_word(number: U32) -> KTerm:
  kt("NWord",U32.show(number),0,0,[])

@unsafe
def p173o_child_descend(store: P173Store, state: P173OState, child: P173OChild, id: U32) -> P173OResult:
  match child:
    case P173OChild{shape,start,next,count,terms,+raw}:
      p173o_queue(store,state,[P173OVisit{id,raw},P173OChildren{P173OChild{shape,start,U32.inc(next),count,terms,raw}}])

@unsafe
def p173o_child_edge(state: P173OState, child: P173OChild, pair: P173Store & U32) -> P173OResult:
  match pair:
    case Tuple{store,id}: p173o_child_descend(store,state,child,id)

@unsafe
def p173o_child_next(store: P173Store, state: P173OState, +child: P173OChild) -> P173OResult:
  match child:
    case P173OChild{shape,start,next,count,terms,raw}:
      p173o_child_edge(state,child,p173s_edge(store,U32.add(start,next)))

@unsafe
def p173o_child_done(store: P173Store, state: P173OState, child: P173OChild) -> P173OResult:
  match child:
    case P173OChild{shape,start,next,count,terms,raw}:
      p173o_push(store,state,p173s_shape_term(shape,nt_reverse(KTerm,terms,[])))

@unsafe
def p173o_child_test(store: P173Store, state: P173OState, child: P173OChild, done: Bool) -> P173OResult:
  match done:
    case True{}: p173o_child_done(store,state,child)
    case False{}: p173o_child_next(store,state,child)

@unsafe
def p173o_child_return(store: P173Store, state: P173OState, child: P173OChild, term: KTerm) -> P173OResult:
  match child:
    case P173OChild{shape,start,+next,+count,terms,raw}:
      p173o_child_test(store,state,P173OChild{shape,start,next,count,Con{term,terms},raw},U32.is_eq(next,count))

@unsafe
def p173o_children_first(state: P173OState, shape: P173Shape, start: U32, count: U32, +raw: Bool, pair: P173Store & U32) -> P173OResult:
  match pair:
    case Tuple{store,id}:
      p173o_queue(store,state,[P173OVisit{id,raw},P173OChildren{P173OChild{shape,start,1,count,[],raw}}])

@unsafe
def p173o_children_test(store: P173Store, state: P173OState, shape: P173Shape, +start: U32, count: U32, raw: Bool, empty: Bool) -> P173OResult:
  match empty:
    case True{}: p173o_push(store,state,p173s_shape_term(shape,[]))
    case False{}: p173o_children_first(state,shape,start,count,raw,p173s_edge(store,start))

@unsafe
def p173o_children(store: P173Store, state: P173OState, +shape: P173Shape, start: U32, +count: U32, raw: Bool) -> P173OResult:
  p173o_children_test(store,p173o_note_shape(state,shape),shape,start,count,raw,U32.is_eq(count,0))

@unsafe
def p173o_succ_scanned(store: P173Store, state: P173OState, scan: P173Succ) -> P173OResult:
  match scan:
    case P173Succ{tail,count,fuel}:
      p173o_queue(store,p173o_with_fuel(state,fuel),[P173OVisit{tail,False{}},P173OSucc{count}])

@unsafe
def p173o_succ_pair(state: P173OState, pair: P173Store & P173Succ) -> P173OResult:
  match pair:
    case Tuple{store,scan}: p173o_succ_scanned(store,state,scan)

@unsafe
def p173o_succ_kid(+state: P173OState, pair: P173Store & U32) -> P173OResult:
  match pair:
    case Tuple{store,id}: p173o_succ_pair(state,p173c_succ_scan(store,id,1,p173o_fuel(state)))

@unsafe
def p173o_ctor_succ(store: P173Store, state: P173OState, shape: P173Shape, start: U32, count: U32, succ: Bool) -> P173OResult:
  match succ:
    case True{}: p173o_succ_kid(state,p173c_kid(store,start,count,0))
    case False{}: p173o_children(store,state,p173c_clear(shape),start,count,False{})

@unsafe
def p173o_decoded_valid(store: P173Store, state: P173OState, +shape: P173Shape, start: U32, +count: U32, number: U32, valid: Bool) -> P173OResult:
  match valid:
    case True{}: p173o_push(store,state,p173o_word(number))
    case False{}: p173o_ctor_succ(store,state,shape,start,count,p88_string_eq(p173s_shape_name(shape),"Succ") && U32.is_eq(count,1))

@unsafe
def p173o_decoded(store: P173Store, state: P173OState, shape: P173Shape, start: U32, count: U32, decoded: P173Decode) -> P173OResult:
  match decoded:
    case P173Decode{valid,number,fuel}: p173o_decoded_valid(store,p173o_with_fuel(state,fuel),shape,start,count,number,valid)

@unsafe
def p173o_decode_pair(state: P173OState, shape: P173Shape, start: U32, count: U32, pair: P173Store & P173Decode) -> P173OResult:
  match pair:
    case Tuple{store,decoded}: p173o_decoded(store,state,shape,start,count,decoded)

@unsafe
def p173o_constructor(store: P173Store, +state: P173OState, id: U32, +shape: P173Shape, +start: U32, +count: U32) -> P173OResult:
  p173o_decode_pair(state,shape,start,count,p173c_decode(store,id,shape,start,count,p173o_fuel(state)))

@unsafe
def p173o_term_ctr(store: P173Store, state: P173OState, id: U32, shape: P173Shape, start: U32, count: U32, ctr: Bool) -> P173OResult:
  match ctr:
    case True{}: p173o_constructor(store,state,id,shape,start,count)
    case False{}: p173o_children(store,state,p173c_clear(shape),start,count,False{})

@unsafe
def p173o_term_static(store: P173Store, state: P173OState, id: U32, +shape: P173Shape, start: U32, count: U32, opaque: Bool) -> P173OResult:
  match opaque:
    case True{}: p173o_children(store,state,shape,start,count,True{})
    case False{}: p173o_term_ctr(store,state,id,shape,start,count,p88_string_eq(p173s_shape_tag(shape),"Ctr"))

@unsafe
def p173o_literal(store: P173Store, state: P173OState, number: U32, text: String, string: Bool) -> P173OResult:
  match string:
    case True{}: p173o_queue(store,state,[P173OString{text}])
    case False{}: p173o_push(store,state,p173o_word(number))

@unsafe
def p173o_shape(store: P173Store, state: P173OState, id: U32, start: U32, count: U32, +shape: P173Shape) -> P173OResult:
  match shape:
    case P173Literal{kind,number,text,b,e}: p173o_literal(store,state,number,text,p88_string_eq(kind,"String"))
    case P173Lambda{name,n,q,removed,b,e,p}: p173o_children(store,state,p173c_clear(shape),start,count,False{})
    case P173Term{tag,name,n,q,removed,b,e}: p173o_term_static(store,state,id,shape,start,count,p88_string_eq(tag,"NStatic"))

@unsafe
def p173o_mode(store: P173Store, state: P173OState, id: U32, shape: P173Shape, start: U32, count: U32, raw: Bool) -> P173OResult:
  match raw:
    case True{}: p173o_children(store,state,shape,start,count,True{})
    case False{}: p173o_shape(store,state,id,start,count,shape)

@unsafe
def p173o_node(store: P173Store, state: P173OState, id: U32, raw: Bool, node: P173Node) -> P173OResult:
  match node:
    case P173Node{shape,start,count}: p173o_mode(store,state,id,shape,start,count,raw)

@unsafe
def p173o_read(state: P173OState, id: U32, raw: Bool, pair: P173Store & P173Node) -> P173OResult:
  match pair:
    case Tuple{store,node}: p173o_node(store,state,id,raw,node)

@unsafe
def p173o_finish_frame(store: P173Store, state: P173OState, term: KTerm, frame: P173OFrame) -> P173OResult:
  match frame:
    case P173OChildren{child}: p173o_child_return(store,state,child,term)
    case P173OSucc{+count}:
      +shape = kc(P173Shape,U32.is_eq(count,1),u => P173Term{"Ctr","Succ",0,0,[],0,0},u => P173Term{"NNatAdd",U32.show(U32.sub(count,1)),0,0,[],0,0})
      p173o_push(store,state,p173s_shape_term(shape,[term]))
    case P173OStringJoin{head}: p173o_push(store,state,kt("Ctr","SCon",0,1,[head,term]))
    case _: p173o_refused(store)

@unsafe
def p173o_pop_values(store: P173Store, todo: List<&2,P173OFrame>, references: List<&2,String>, fuel: U32, frame: P173OFrame, values: List<&2,KTerm>) -> P173OResult:
  match values:
    case Nil{}: p173o_refused(store)
    case Con{term,rest}: p173o_finish_frame(store,P173OState{todo,rest,references,fuel},term,frame)

@unsafe
def p173o_pop(store: P173Store, frame: P173OFrame, state: P173OState) -> P173OResult:
  match state:
    case P173OState{todo,values,references,fuel}: p173o_pop_values(store,todo,references,fuel,frame,values)

@unsafe
def p173o_string(store: P173Store, state: P173OState, text: String) -> P173OResult:
  match text:
    case SNil{}: p173o_push(store,state,kt("Ctr","SNil",0,1,[]))
    case SCon{head,tail}:
      +chr = kt("Ctr","Chr",0,1,[p173o_word(Char.to_u32(head))])
      p173o_queue(store,state,[P173OString{tail},P173OStringJoin{chr}])

@unsafe
def p173o_frame(store: P173Store, state: P173OState, +frame: P173OFrame) -> P173OResult:
  match frame:
    case P173OVisit{+id,raw}: p173o_read(state,id,raw,p173s_node(store,id))
    case P173OString{text}: p173o_string(store,state,text)
    case _: p173o_pop(store,frame,state)

@unsafe
def p173o_budget(store: P173Store, state: P173OState, frame: P173OFrame, empty: Bool) -> P173OResult:
  match empty:
    case True{}: p173o_refused(store)
    case False{}: p173o_frame(store,state,frame)

@unsafe
def p173o_done(store: P173Store, references: List<&2,String>, values: List<&2,KTerm>) -> P173OResult:
  match values:
    case Nil{}: p173o_refused(store)
    case Con{term,rest}: P173OResult{store,term,nt_reverse(String,references,[])}

@unsafe
def p173o_todo(store: P173Store, values: List<&2,KTerm>, references: List<&2,String>, +fuel: U32, todo: List<&2,P173OFrame>) -> P173OResult:
  match todo:
    case Nil{}: p173o_done(store,references,values)
    case Con{frame,rest}: p173o_budget(store,P173OState{rest,values,references,U32.sub(fuel,1)},frame,U32.is_eq(fuel,0))

@unsafe
def p173o_go(store, state):
  match state:
    case P173OState{todo,values,references,fuel}: p173o_todo(store,values,references,fuel,todo)

@unsafe
def p173o_validated(name: String, body: KTerm, references: List<&2,String>, pair: P173Store & Bool) -> P173VBody:
  match pair:
    case Tuple{store,valid}:
      P173VBody{name,body,references,nt_choose(String,valid,u => "",u => "phase173 direct destination refused")}

@unsafe
def p173o_validate(name: String, result: P173OResult) -> P173VBody:
  match result:
    case P173OResult{store,body,references}: p173o_validated(name,body,references,p173s_valid(store,10000000))

@unsafe
def p173o_imported(+name: String, pair: P173Store & U32) -> P173VBody:
  match pair:
    case Tuple{store,id}: p173o_validate(name,p173o_go(store,P173OState{[P173OVisit{id,False{}}],[],[],10000000}))

@unsafe
def p173o_body(input: P173VInput) -> P173VBody:
  match input:
    case P173VInput{name,body}: p173o_imported(name,p173s_import(p173s_new(),body,10000000))

@unsafe
def p173o_candidate(inputs: List<&2,P173VInput>) -> List<&2,P173VBody>:
  match inputs:
    case Nil{}: []
    case Con{head,rest}: Con{p173o_body(head),p173o_candidate(rest)}
