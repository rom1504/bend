# Optional argument placement after the unchanged x186 frame/capacity admission.
# Outgoing stack arguments are stored first using r10. At most six ABI register
# assignments then use a bounded parallel-copy schedule, with r11 for a cycle.
# All source loads write only their destination; no helper calls or effects move.
# A refused plan exposes no partial sequence and retains the snapshot path.
def x191_call_moves_enabled() -> Bool: False{}

type X191CallMove is Data:
  X191CallMove{+destination: U32, +physical: U32, +value: N111Value, +typ: N111Type}

type X191CallPick is Data:
  X191CallPick{+move: X191CallMove, +rest: List<&2,X191CallMove>}
  X191CallPickNone{}

def x191_cm_abi(index: U32) -> U32:
  match index:
    case 0: 7
    case 1: 6
    case 2: 2
    case 3: 1
    case 4: 8
    case _: 9

# Physical index16 is a non-register source. Exact frame admission guarantees
# actual homes never use reserved r10/r11 or a changing RSP-relative source.
def x191_cm_physical(home: X185Physical) -> U32:
  match home:
    case X185Physical{X187Reg{index,64,False{}},narrow,byte}: index
    case _: 16

@unsafe
def x191_cm_first(args: List<&2,N111Arg>, +frame: X181Frame, +index: U32) -> List<&2,X191CallMove>:
  match args:
    case Nil{}: []
    case Con{N111Arg{typ,+value},rest}:
      nt_choose(List<&2,X191CallMove>,U32.is_lt(index,6),u =>
        Con{X191CallMove{x191_cm_abi(index),x191_cm_physical(x190_value_home(value,frame)),value,typ},
          x191_cm_first(rest,frame,U32.inc(index))},u => [])

@unsafe
def x191_cm_stack(args: List<&2,N111Arg>, +index: U32) -> List<&2,N111Arg>:
  match args:
    case Nil{}: []
    case Con{head,+rest}: nt_choose(List<&2,N111Arg>,U32.is_eq(index,5),u => rest,
      u => x191_cm_stack(rest,U32.inc(index)))

# Ignore only the candidate's own read. A narrow identity remains a write and
# must wait for all other readers of the old full-width physical value.
@unsafe
def x191_cm_needed(+register: U32, moves: List<&2,X191CallMove>, +ignoreSelf: Bool) -> Bool:
  match moves:
    case Nil{}: False{}
    case Con{X191CallMove{destination,source,value,typ},rest}:
      (U32.is_eq(source,register) && (Bool.not(ignoreSelf) || Bool.not(U32.is_eq(destination,register)))) ||
        x191_cm_needed(register,rest,ignoreSelf)

def x191_cm_pick_cons(move: X191CallMove, pick: X191CallPick) -> X191CallPick:
  match pick:
    case X191CallPick{chosen,rest}: X191CallPick{chosen,Con{move,rest}}
    case _: X191CallPickNone{}

@unsafe
def x191_cm_pick_head(+move: X191CallMove, +rest: List<&2,X191CallMove>, +all: List<&2,X191CallMove>) -> X191CallPick:
  match move:
    case X191CallMove{destination,source,value,typ}:
      nt_choose(X191CallPick,Bool.not(x191_cm_needed(destination,all,True{})),
        u => X191CallPick{move,rest},u => x191_cm_pick_cons(move,x191_cm_pick(rest,all)))

@unsafe
def x191_cm_pick(todo: List<&2,X191CallMove>, +all: List<&2,X191CallMove>) -> X191CallPick:
  match todo:
    case Nil{}: X191CallPickNone{}
    case Con{move,rest}: x191_cm_pick_head(move,rest,all)

@unsafe
def x191_cm_rename(moves: List<&2,X191CallMove>, +old: U32) -> List<&2,X191CallMove>:
  match moves:
    case Nil{}: []
    case Con{X191CallMove{destination,+source,value,typ},rest}:
      Con{X191CallMove{destination,nt_choose(U32,U32.is_eq(source,old),u => 11,u => source),value,typ},x191_cm_rename(rest,old)}

@unsafe
def x191_cm_emit(move: X191CallMove, +ids: N111Ids, +frame: X181Frame) -> X188Seq:
  match move:
    case X191CallMove{+destination,+source,value,+typ}:
      x188_cat(nt_choose(X188Seq,U32.is_lt(source,16),u =>
        nt_choose(X188Seq,U32.is_eq(source,destination),v => X188Empty{},
          v => x188_i2("movq",x188_reg(source,64),x188_reg(destination,64))),
        u => x181_load(value,ids,frame,x188_reg(destination,64))),x186_call_mask(typ,x188_reg(destination,32)))

law x191_cm_schedule:
  for +moves: List<&2,X191CallMove>
  for +ids: N111Ids
  for +frame: X181Frame
  for +chunks: List<&2,X188Seq>
  for +fuel: U32
  Maybe<&2,X188Seq>

@unsafe
def x191_cm_cycle(+moves: List<&2,X191CallMove>, +ids: N111Ids, +frame: X181Frame,
    +chunks: List<&2,X188Seq>, +fuel: U32) -> Maybe<&2,X188Seq>:
  match moves:
    case Con{X191CallMove{destination,+source,value,typ},rest}:
      nt_choose(Maybe<&2,X188Seq>,U32.is_lt(source,16) && Bool.not(x191_cm_needed(11,moves,False{})),
        u => x191_cm_schedule(x191_cm_rename(moves,source),ids,frame,
          Con{x188_i2("movq",x188_reg(source,64),x188_reg(11,64)),chunks},fuel),u => None{})
    case _: None{}

@unsafe
def x191_cm_chosen(pick: X191CallPick, moves: List<&2,X191CallMove>, +ids: N111Ids,
    +frame: X181Frame, +chunks: List<&2,X188Seq>, +fuel: U32) -> Maybe<&2,X188Seq>:
  match pick:
    case X191CallPick{move,rest}: x191_cm_schedule(rest,ids,frame,Con{x191_cm_emit(move,ids,frame),chunks},fuel)
    case _: x191_cm_cycle(moves,ids,frame,chunks,fuel)

@unsafe
def x191_cm_schedule(moves,ids,frame,chunks,fuel):
  match moves:
    case Nil{}: Some{x188_finish(chunks)}
    case Con{head,rest}:
      nt_choose(Maybe<&2,X188Seq>,U32.is_gt(fuel,0),u =>
        x191_cm_chosen(x191_cm_pick(moves,moves),moves,ids,frame,chunks,U32.sub(fuel,1)),u => None{})

@unsafe
def x191_cm_finish(plan: Maybe<&2,X188Seq>, args: List<&2,N111Arg>, ids: N111Ids, frame: X181Frame) -> Maybe<&2,X188Seq>:
  match plan:
    case Some{registers}: Some{x188_cat(x186_call_direct(x191_cm_stack(args,0),ids,frame,6),registers)}
    case _: None{}

@unsafe
def x191_cm_admitted(plan: X186CallPlan, +args: List<&2,N111Arg>, +ids: N111Ids, +frame: X181Frame) -> Maybe<&2,X188Seq>:
  match plan:
    case X186CallPlan{kind,count}:
      nt_choose(Maybe<&2,X188Seq>,U32.is_eq(kind,2),u =>
        x191_cm_finish(x191_cm_schedule(x191_cm_first(args,frame,0),ids,frame,[],18),args,ids,frame),u => None{})
