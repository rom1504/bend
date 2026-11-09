# Diagnostic-only continuation parser: exact original prefix/safety checks,
# with no suffix-size gate, to measure the gate's original N111 body. The
# returned value is never installed into a compiler plan.

@unsafe
def p186hc_cont_result(body: List<&2,N111Stmt>, +captures: List<&2,String>, +pop: String) -> Maybe<&2,P112FusionCont>:
  match body:
    case Con{N111Call{+word,N111U64{},+symbol,Con{N111Arg{N111Ptr{},N111Local{+state}},Con{N111Arg{N111U32{},N111Const{0,0}},Nil{}}}},+rest}:
      nt_choose(Maybe<&2,P112FusionCont>,String.eq(symbol,"p111_rt_reg_get") && String.eq(state,"state") && Bool.not(nb_contains(captures,word) || String.eq(word,"state") || String.eq(word,"scratch")) && p112f_safe(rest),
        u => Some{P112FusionCont{nt_reverse(String,captures,[]),word,pop,rest}},u => None{})
    case _: None{}

@unsafe
def p186hc_cont_gets(+body: List<&2,N111Stmt>, +count: U32, +index: U32, +captures: List<&2,String>, +pop: String) -> Maybe<&2,P112FusionCont>:
  nt_choose(Maybe<&2,P112FusionCont>,U32.is_eq(count,index),u => p186hc_cont_result(body,captures,pop),u =>
    p186hc_cont_get(body,count,index,captures,pop))

@unsafe
def p186hc_cont_get(body: List<&2,N111Stmt>, +count: U32, +index: U32, +captures: List<&2,String>, +pop: String) -> Maybe<&2,P112FusionCont>:
  match body:
    case Con{N111Call{+word,N111U64{},+symbol,Con{N111Arg{N111Ptr{},N111Local{+state}},Con{N111Arg{N111U32{},N111Const{+slot,0}},Nil{}}}},+rest}:
      nt_choose(Maybe<&2,P112FusionCont>,String.eq(symbol,"p111_rt_stack_get") && String.eq(state,"state") && U32.is_eq(slot,index) && Bool.not(nb_contains(captures,word) || String.eq(word,"state") || String.eq(word,"scratch")),
        u => p186hc_cont_gets(rest,count,U32.inc(index),Con{word,captures},pop),u => None{})
    case _: None{}

@unsafe
def p186hc_cont_pop(body: List<&2,N111Stmt>, +count: U32) -> Maybe<&2,P112FusionCont>:
  match body:
    case Con{N111Call{+word,N111U64{},+symbol,Con{N111Arg{N111Ptr{},N111Local{+state}},Con{N111Arg{N111U32{},N111Const{+held,0}},Nil{}}}},+rest}:
      nt_choose(Maybe<&2,P112FusionCont>,String.eq(symbol,"p111_rt_stack_pop") && String.eq(state,"state") && U32.is_eq(held,count),
        u => p186hc_cont_gets(rest,count,0,[],word),u => None{})
    case _: None{}

@unsafe
def p186hc_cont_body(body: List<&2,N111Stmt>, +count: U32) -> Maybe<&2,P112FusionCont>:
  match body:
    case Con{N111Alloca{+name,2048,8},+rest}:
      nt_choose(Maybe<&2,P112FusionCont>,String.eq(name,"scratch"),u =>
        nt_choose(Maybe<&2,P112FusionCont>,U32.is_eq(count,0),v => p186hc_cont_gets(rest,0,0,[],""),v => p186hc_cont_pop(rest,count)),u => None{})
    case _: None{}

@unsafe
def p186hc_cont(segment: N111Segment, +count: U32) -> Maybe<&2,P112FusionCont>:
  match segment:
    case N111Segment{+name,+arity,+result,+incoming,+flags,+body}:
      nt_choose(Maybe<&2,P112FusionCont>,U32.is_eq(arity,U32.inc(count)) && U32.is_eq(result,1) && U32.is_eq(incoming,1) && U32.is_eq(flags,0) && p112f_clean(body),
        u => p186hc_cont_body(body,count),u => None{})

def p186hc_bool(value: Bool) -> String:
  nt_choose(String,value,u => "1",u => "0")

def p186hc_cont_valid(cont: Maybe<&2,P112FusionCont>) -> Bool:
  match cont:
    case Some{value}: True{}
    case None{}: False{}

def p186hc_closed(closed: P114HClosed) -> String:
  match closed:
    case P114HClosed{valid,cases}:
      "closure8=" ++ p186hc_bool(valid) ++ " closed-cases=" ++ U32.show(nt_count(P114HCase,cases))

@unsafe
def p186hc_scan_row(owner: String, arity: U32, index: P112FusionIndex, ready: KDef, scanned: P114GBody) -> String:
  match scanned:
    case P114GBody{+valid,+frames,body}:
      "scan=" ++ p186hc_bool(valid) ++ " frame-sites=" ++ U32.show(nt_count(P114GFrame,frames)) ++ " " ++
        nt_choose(String,valid,u => p186hc_closed(p114h_close(frames,owner,arity,index,ready,[],8)),
          u => "closure8=not-scanned")

@unsafe
def p186hc_prelude_row(+owner: String, +arity: U32, index: P112FusionIndex, +ready: KDef, prelude: P112TailPrelude) -> String:
  match prelude:
    case P112TailPrelude{valid,params,prefix,body}:
      nt_choose(String,valid,u => p186hc_scan_row(owner,arity,index,ready,p114h_scan(body,owner,arity,ready)),
        u => "prelude=refused")

# Collect syntactic frame names, including failure-only branches. This is a
# diagnostic inventory, not a claim that every listed frame belongs to H.
@unsafe
def p186hc_raw_frames(body: List<&2,N111Stmt>) -> List<&2,P114GFrame>:
  match body:
    case Nil{}: []
    case Con{N111If{condition,yes,no},rest}:
      nt_append(P114GFrame,p186hc_raw_frames(yes),nt_append(P114GFrame,p186hc_raw_frames(no),p186hc_raw_frames(rest)))
    case Con{N111Call{dest,N111U64{},symbol,
      Con{N111Arg{N111Ptr{},N111Local{state}},Con{N111Arg{N111U32{},N111FuncId{name}},
      Con{N111Arg{N111Ptr{},N111Local{buffer}},Con{N111Arg{N111U32{},N111Const{count,0}},Nil{}}}}}},+rest}:
      nt_choose(List<&2,P114GFrame>,String.eq(symbol,"p111_rt_frame") && String.eq(state,"state") && String.eq(buffer,"scratch"),
        u => Con{P114GFrame{name,count},p186hc_raw_frames(rest)},u => p186hc_raw_frames(rest))
    case Con{stmt,rest}: p186hc_raw_frames(rest)

@unsafe
def p186hc_cont_row(+name: String, +count: U32, +owner: String, +arity: U32, +ready: KDef,
    +segment: N111Segment, cont: Maybe<&2,P112FusionCont>) -> String:
  match cont:
    case None{}: "continuation " ++ name ++ " captures=" ++ U32.show(count) ++ " non-size-refusal=1"
    case Some{P112FusionCont{captures,result,pop,+body}}:
      +nodes = p112f_size(body)
      "continuation " ++ name ++ " captures=" ++ U32.show(count) ++ " suffix-nodes=" ++ U32.show(nodes) ++
        " old128=" ++ p186hc_bool(U32.is_le(nodes,128)) ++ " new1024=" ++ p186hc_bool(U32.is_le(nodes,1024)) ++
        " current-parser=" ++ p186hc_bool(p186hc_cont_valid(p112f_cont(segment,count))) ++
        " scalar-scan=" ++ p186hc_scan_valid(p114h_scan(body,owner,arity,ready))

def p186hc_scan_valid(scanned: P114GBody) -> String:
  match scanned:
    case P114GBody{valid,frames,body}: p186hc_bool(valid)

@unsafe
def p186hc_cont_found(+name: String, +count: U32, owner: String, arity: U32, ready: KDef,
    found: Maybe<&2,N111Segment>) -> String:
  match found:
    case None{}: "continuation " ++ name ++ " missing=1"
    case Some{+segment}: p186hc_cont_row(name,count,owner,arity,ready,segment,p186hc_cont(segment,count))

@unsafe
def p186hc_frame_rows(frames: List<&2,P114GFrame>, +seen: KDef, +left: U32,
    +owner: String, +arity: U32, +index: P112FusionIndex, +ready: KDef) -> List<&2,String>:
  match frames:
    case Nil{}: []
    case Con{P114GFrame{+name,+count},+rest}:
      nt_choose(List<&2,String>,U32.is_eq(left,0),u => ["continuation-inventory-truncated=1"],u =>
        nt_choose(List<&2,String>,String.eq(dk(p111v_get(seen,name)),"Absent"),
          v => Con{p186hc_cont_found(name,count,owner,arity,ready,p112f_index_get(index,name)),
            p186hc_frame_rows(rest,p111v_put(seen,name,"Seen",count,0),U32.sub(left,1),owner,arity,index,ready)},
          v => p186hc_frame_rows(rest,seen,left,owner,arity,index,ready)))

@unsafe
def p186hc_segment(+segment: N111Segment, context: P134Context) -> List<&2,String>:
  match segment context:
    case N111Segment{+name,+arity,+result,+incoming,+flags,+body} P134Context{ids,+index,direct,ready,+view,lookups,heap,mode}:
      +nodes = p112f_size(body)
      Con{"segment " ++ name ++ " arity=" ++ U32.show(arity) ++ " result=" ++ U32.show(result) ++
        " incoming=" ++ U32.show(incoming) ++ " flags=" ++ U32.show(flags) ++ " owner-nodes=" ++ U32.show(nodes) ++
        " old512=" ++ p186hc_bool(U32.is_le(nodes,512)) ++ " new2048=" ++ p186hc_bool(U32.is_le(nodes,2048)) ++
        " callable=" ++ p186hc_bool(p124r_known(view,name)) ++
        " current-H=" ++ p186hc_bool(p114h_valid(p114h_plan(segment,index,view))),
        Con{p186hc_prelude_row(name,arity,index,view,p112t_prelude(body,arity)),
          p186hc_frame_rows(p186hc_raw_frames(body),missing(),32,name,arity,index,view)}}

@unsafe
def p186hc_found(+name: String, context: P134Context, found: Maybe<&2,N111Segment>) -> List<&2,String>:
  match found:
    case None{}: ["missing " ++ name]
    case Some{segment}: p186hc_segment(segment,context)

@unsafe
def p186hc_names(names: List<&2,String>, +context: P134Context) -> List<&2,String>:
  match names context:
    case Nil{} _: []
    case Con{+name,rest} P134Context{ids,index,direct,ready,view,lookups,heap,mode}:
      nt_append(String,p186hc_found(name,context,p112f_index_get(index,name)),p186hc_names(rest,context))

@unsafe
def p186hc_probe(cursor: P134Cursor, names: List<&2,String>) -> List<&2,String>:
  match cursor:
    case P134Private{functions,context,next}: p186hc_names(names,context)
    case P134Legacy{entries,context,next}: p186hc_names(names,context)
    case P134Public{segments,context,next}: p186hc_names(names,context)
    case _: ["no planner context in cursor"]
