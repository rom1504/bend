# The original graph verifier supplies operand typing. This additional gate
# admits only numeric copies/arithmetic and excludes all state/scratch locals.
def p112g_word_type(typ: N111Type) -> Bool:
  match typ:
    case N111U32{}: True{}
    case N111U64{}: True{}
    case _: False{}

@unsafe
def p112g_name(+name: String) -> Bool:
  Bool.not(String.eq(name,"state") || p112r_buffer(name,8))

@unsafe
def p112g_value(value: N111Value) -> Bool:
  match value:
    case N111Local{+name}: p112g_name(name)
    case N111Const{+lo,+hi}: True{}
    case _: False{}

@unsafe
def p112g_pure(stmt: N111Stmt) -> Bool:
  match stmt:
    case N111Set{+name,+typ,+value}: p112g_word_type(typ) && p112g_name(name) && p112g_value(value)
    case N111Bin{+name,+typ,+op,+left,+right}: p112g_word_type(typ) && p112g_name(name) && p112g_value(left) && p112g_value(right)
    case _: False{}

@unsafe
def p112g_split(+body: List<&2,N111Stmt>, +count: U32, +acc: List<&2,N111Stmt>) -> Maybe<&2,P112PureGap>:
  match body:
    case Nil{}: Some{P112PureGap{nt_reverse(N111Stmt,acc,[]),body}}
    case Con{+stmt,+rest}:
      nt_choose(Maybe<&2,P112PureGap>,p112g_pure(stmt),
        u => nt_choose(Maybe<&2,P112PureGap>,U32.is_lt(count,32),
          v => p112g_split(rest,U32.inc(count),Con{stmt,acc}),v => None{}),
        u => Some{P112PureGap{nt_reverse(N111Stmt,acc,[]),body}})

def p112g_prepend(+stmt: N111Stmt, found: Maybe<&2,List<&2,N111Stmt>>) -> Maybe<&2,List<&2,N111Stmt>>:
  match found:
    case None{}: None{}
    case Some{+body}: Some{Con{stmt,body}}

# The pinned p112f_fused scaffold begins with capture-count snapshots and one
# zero frame-result assignment. The gap must follow these, and precede every
# argument snapshot. An unexpectedly short scaffold refuses the whole attempt.
@unsafe
def p112g_splice(+body: List<&2,N111Stmt>, +left: U32, +gap: List<&2,N111Stmt>) -> Maybe<&2,List<&2,N111Stmt>>:
  nt_choose(Maybe<&2,List<&2,N111Stmt>>,U32.is_eq(left,0),u => Some{nt_append(N111Stmt,gap,body)},
    u => p112g_splice_next(body,left,gap))

@unsafe
def p112g_splice_next(body: List<&2,N111Stmt>, +left: U32, +gap: List<&2,N111Stmt>) -> Maybe<&2,List<&2,N111Stmt>>:
  match body:
    case Nil{}: None{}
    case Con{+stmt,+rest}: p112g_prepend(stmt,p112g_splice(rest,U32.sub(left,1),gap))

@unsafe
def p112g_found(+gap: List<&2,N111Stmt>, +captures: U32, found: Maybe<&2,List<&2,N111Stmt>>) -> Maybe<&2,List<&2,N111Stmt>>:
  match found:
    case None{}: None{}
    case Some{+body}: p112g_splice(body,U32.inc(captures),gap)

@unsafe
def p112g_finish(frame: P112FusionFrame, +index: P112FusionIndex, +ready: KDef, +site: U32, +buffer: String, split: Maybe<&2,P112PureGap>) -> Maybe<&2,List<&2,N111Stmt>>:
  match frame split:
    case _ None{}: None{}
    case P112FusionFrame{+captures,+name,+dest,+original} Some{P112PureGap{+gap,+tail}}:
      +stripped: P112FusionFrame = P112FusionFrame{captures,name,dest,tail}
      p112g_found(gap,nt_count(N111Value,captures),p112c_target(stripped,index,ready,site,buffer,p112r_target(tail,site)))
