# Diagnostic only: inspect the actual checked emission cursor's original
# segments and immutable callable registries. No emission or admission changes.

@unsafe
def p186hp_bool(value: Bool) -> String:
  nt_choose(String,value,u => "1",u => "0")

@unsafe
def p186hp_frames(body: List<&2,N111Stmt>) -> U32:
  match body:
    case Nil{}: 0
    case Con{N111Call{dest,typ,symbol,args},rest}:
      U32.add(nt_bool(String.eq(symbol,"p111_rt_frame")),p186hp_frames(rest))
    case Con{N111If{condition,yes,no},rest}:
      U32.add(p186hp_frames(yes),U32.add(p186hp_frames(no),p186hp_frames(rest)))
    case Con{stmt,rest}: p186hp_frames(rest)

law p186hp_scan:
  for +body: List<&2,N111Stmt>
  for +owner: String
  for +arity: U32
  for +view: KDef
  List<&2,String>

@unsafe
def p186hp_frame(+tail: List<&2,N111Stmt>, +owner: String, +arity: U32, +view: KDef, +name: String, +captures: U32) -> List<&2,String>:
  +target = p124r_target(tail)
  Con{"frame " ++ name ++ " captures=" ++ U32.show(captures) ++
    " scalar-self-tail=" ++ p186hp_bool(p126r_arguments(tail,owner,arity)) ++
    " ready-target=" ++ target ++ " callable=" ++ p186hp_bool(p124r_known(view,target)) ++
    " remaining-frame-sites=" ++ U32.show(p186hp_frames(tail)),p186hp_scan(tail,owner,arity,view)}

@unsafe
def p186hp_next(body: List<&2,N111Stmt>, +owner: String, +arity: U32, +view: KDef) -> List<&2,String>:
  match body:
    case Nil{}: []
    case Con{N111If{condition,yes,no},rest}:
      nt_append(String,p186hp_scan(yes,owner,arity,view),
        nt_append(String,p186hp_scan(no,owner,arity,view),p186hp_scan(rest,owner,arity,view)))
    case Con{N111Call{dest,typ,symbol,Con{state,Con{N111Arg{N111U32{},N111FuncId{+target}},args}}},+rest}:
      nt_choose(List<&2,String>,String.eq(symbol,"p111_rt_jump"),
        u => Con{"jump " ++ target ++ " self=" ++ p186hp_bool(String.eq(target,owner)) ++
          " callable=" ++ p186hp_bool(p124r_known(view,target)),p186hp_scan(rest,owner,arity,view)},
        u => p186hp_scan(rest,owner,arity,view))
    case Con{N111Call{dest,typ,symbol,args},+rest}:
      nt_choose(List<&2,String>,String.eq(symbol,"p111_rt_apply"),
        u => Con{"dynamic apply",p186hp_scan(rest,owner,arity,view)},u => p186hp_scan(rest,owner,arity,view))
    case Con{stmt,rest}: p186hp_scan(rest,owner,arity,view)

@unsafe
def p186hp_scanned(+body: List<&2,N111Stmt>, +owner: String, +arity: U32, +view: KDef, frame: Maybe<&2,P112FusionFrame>) -> List<&2,String>:
  match frame:
    case Some{P112FusionFrame{captures,name,dest,tail}}: p186hp_frame(tail,owner,arity,view,name,nt_count(N111Value,captures))
    case None{}: p186hp_next(body,owner,arity,view)

@unsafe
def p186hp_scan(body,owner,arity,view):
  p186hp_scanned(body,owner,arity,view,p112f_frame(body,0,[]))

@unsafe
def p186hp_segment(+segment: N111Segment, +context: P134Context) -> List<&2,String>:
  match segment context:
    case N111Segment{+name,+arity,+result,+incoming,+flags,+body} P134Context{ids,+index,direct,+ready,+view,lookups,heap,mode}:
      Con{"segment " ++ name ++ " arity=" ++ U32.show(arity) ++ " incoming=" ++ U32.show(incoming) ++
        " result=" ++ U32.show(result) ++ " flags=" ++ U32.show(flags) ++ " nodes=" ++ U32.show(p112f_size(body)) ++
        " callable=" ++ p186hp_bool(p124r_known(view,name)) ++
        " old-H=" ++ p186hp_bool(p114h_valid(p114h_plan(segment,index,ready))) ++
        " view-H=" ++ p186hp_bool(p114h_valid(p114h_plan(segment,index,view))),
        p186hp_scan(body,name,arity,view)}

@unsafe
def p186hp_found(+name: String, context: P134Context, found: Maybe<&2,N111Segment>) -> List<&2,String>:
  match found:
    case Some{segment}: p186hp_segment(segment,context)
    case None{}: ["missing " ++ name]

@unsafe
def p186hp_names(names: List<&2,String>, +context: P134Context) -> List<&2,String>:
  match names context:
    case Nil{} _: []
    case Con{+name,rest} P134Context{ids,index,direct,ready,view,lookups,heap,mode}:
      nt_append(String,p186hp_found(name,context,p112f_index_get(index,name)),p186hp_names(rest,context))

@unsafe
def p186hp_probe(cursor: P134Cursor, names: List<&2,String>) -> List<&2,String>:
  match cursor:
    case P134Private{functions,context,next}: p186hp_names(names,context)
    case P134Legacy{entries,context,next}: p186hp_names(names,context)
    case P134Public{segments,context,next}: p186hp_names(names,context)
    case _: ["no planner context in cursor"]
