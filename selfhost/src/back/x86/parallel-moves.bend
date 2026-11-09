# Acyclic full-word parallel assignment on Again edges. Scheduling is by actual
# frame home, never spelling. Self moves disappear; a destination is written
# only after every pending read of that home has been consumed. Any cycle or
# malformed/big vector refuses the whole plan and retains the snapshot path.
type X186Move is Data:
  X186Move{+destination: String, +source: N111Value, +home: KDef, +read: KDef}

type X186Pick is Data:
  X186Pick{+move: X186Move, +rest: List<&2,X186Move>}
  X186PickNone{}

def x186_parallel_enabled() -> Bool: True{}

@unsafe
def x186_p_same(+a: KDef, +b: KDef) -> Bool:
  Bool.not(String.eq(dk(a),"Absent")) && String.eq(dk(a),dk(b)) && U32.is_eq(da(a),da(b))

@unsafe
def x186_p_word_home(+slot: KDef, +destination: Bool) -> Bool:
  (String.eq(dk(slot),"X181Stack") && U32.is_ge(da(slot),48) && U32.is_eq(U32.mod(da(slot),8),0) && U32.is_eq(dx(slot),8)) ||
  (String.eq(dk(slot),"X181Register") && U32.is_le(da(slot),4) &&
    (Bool.not(destination) || U32.is_gt(da(slot),0))) ||
  (Bool.not(destination) && String.eq(dk(slot),"X185Transient") && U32.is_lt(da(slot),5))

@unsafe
def x186_p_source(value: N111Value, slots: KDef) -> KDef:
  match value:
    case N111Local{name}: p111v_get(slots,name)
    case _: missing()

@unsafe
def x186_p_source_valid(value: N111Value, slots: KDef) -> Bool:
  match value:
    case N111Local{name}: x186_p_word_home(p111v_get(slots,name),False{})
    case _: True{}

@unsafe
def x186_p_dest_used(+home: KDef, moves: List<&2,X186Move>) -> Bool:
  match moves:
    case Nil{}: False{}
    case Con{X186Move{destination,source,other,read},rest}: x186_p_same(home,other) || x186_p_dest_used(home,rest)

@unsafe
def x186_p_zip(params: List<&2,String>, values: List<&2,N111Value>, +slots: KDef,
    +moves: List<&2,X186Move>) -> Maybe<&2,List<&2,X186Move>>:
  match params values:
    case Nil{} Nil{}: Some{nt_reverse(X186Move,moves,[])}
    case Con{+name,rest} Con{+value,more}:
      +home = p111v_get(slots,name)
      nt_choose(Maybe<&2,List<&2,X186Move>>,x186_p_word_home(home,True{}) &&
          x186_p_source_valid(value,slots) && Bool.not(x186_p_dest_used(home,moves)),
        u => x186_p_zip(rest,more,slots,Con{X186Move{name,value,home,x186_p_source(value,slots)},moves}),
        u => None{})
    case _ _: None{}

@unsafe
def x186_p_self(moves: List<&2,X186Move>) -> List<&2,X186Move>:
  match moves:
    case Nil{}: []
    case Con{+move,+rest}:
      match move:
        case X186Move{destination,source,home,read}:
          nt_choose(List<&2,X186Move>,x186_p_same(home,read),u => x186_p_self(rest),u => Con{move,x186_p_self(rest)})

@unsafe
def x186_p_read(+home: KDef, moves: List<&2,X186Move>) -> Bool:
  match moves:
    case Nil{}: False{}
    case Con{X186Move{destination,source,other,read},rest}: x186_p_same(home,read) || x186_p_read(home,rest)

def x186_p_pick_cons(move: X186Move, picked: X186Pick) -> X186Pick:
  match picked:
    case X186Pick{chosen,rest}: X186Pick{chosen,Con{move,rest}}
    case _: X186PickNone{}

@unsafe
def x186_p_pick(todo: List<&2,X186Move>, +all: List<&2,X186Move>) -> X186Pick:
  match todo:
    case Nil{}: X186PickNone{}
    case Con{+move,+rest}:
      match move:
        case X186Move{destination,source,home,read}:
          nt_choose(X186Pick,Bool.not(x186_p_read(home,all)),
            u => X186Pick{move,rest},u => x186_p_pick_cons(move,x186_p_pick(rest,all)))

law x186_p_schedule:
  for +moves: List<&2,X186Move>
  for +ids: N111Ids
  for +frame: X181Frame
  for chunks: List<&2,String>
  for +fuel: U32
  Maybe<&2,String>

@unsafe
def x186_p_chosen(picked: X186Pick, +ids: N111Ids, +frame: X181Frame,
    chunks: List<&2,String>, fuel: U32) -> Maybe<&2,String>:
  match picked:
    case X186Pick{X186Move{destination,source,home,read},rest}:
      x186_p_schedule(rest,ids,frame,Con{x181_load(source,ids,frame,"%r10") ++ x181_store(destination,frame,"%r10"),chunks},fuel)
    case _: None{}

@unsafe
def x186_p_schedule(moves,ids,frame,chunks,fuel):
  match moves:
    case Nil{}: Some{nt_text_finish(chunks,"")}
    case Con{head,rest}:
      nt_choose(Maybe<&2,String>,U32.is_gt(fuel,0),
        u => x186_p_chosen(x186_p_pick(moves,moves),ids,frame,chunks,U32.sub(fuel,1)),u => None{})

@unsafe
def x186_p_ready(plan: Maybe<&2,List<&2,X186Move>>, ids: N111Ids, frame: X181Frame) -> Maybe<&2,String>:
  match plan:
    case Some{moves}: x186_p_schedule(x186_p_self(moves),ids,frame,[],64)
    case _: None{}

@unsafe
def x186_parallel(+params: List<&2,String>, +values: List<&2,N111Value>, +ids: N111Ids, +frame: X181Frame) -> Maybe<&2,String>:
  match frame:
    case X181Frame{slots,bytes,calls,words,symbol}:
      nt_choose(Maybe<&2,String>,x186_parallel_enabled() && U32.is_le(nt_count(String,params),64) &&
          U32.is_le(nt_count(N111Value,values),64),
        u => x186_p_ready(x186_p_zip(params,values,slots,[]),ids,frame),u => None{})
