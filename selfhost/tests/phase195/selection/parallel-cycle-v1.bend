# Preserve the existing validated full-word parallel assignment domain.
# Drain self/acyclic moves, then snapshot only the residual cycles into the
# original private tail bank. No scratch register is live across a helper.
def x195cy_enabled() -> Bool: True{}

@unsafe
def x195cy_overlap(+slot: KDef, +bank: KDef) -> Bool:
  String.eq(dk(slot),"X181Stack") && U32.is_le(da(slot),da(bank)) &&
    U32.is_gt(da(slot),U32.sub(da(bank),dx(bank)))

@unsafe
def x195cy_clear(moves: List<&2,X186Move>, +bank: KDef) -> Bool:
  match moves:
    case Nil{}: True{}
    case Con{X186Move{destination,source,home,read},rest}:
      Bool.not(x195cy_overlap(home,bank) || x195cy_overlap(read,bank)) && x195cy_clear(rest,bank)

@unsafe
def x195cy_bank(+moves: List<&2,X186Move>, frame: X181Frame) -> Bool:
  match frame:
    case X181Frame{slots,bytes,calls,params,symbol}:
      +bank = p111v_get(slots,"__x181_tail")
      String.eq(dk(bank),"X181Buffer") && U32.is_ge(dx(bank),U32.mul(nt_count(X186Move,moves),8)) &&
        U32.is_ge(da(bank),dx(bank)) && U32.is_le(da(bank),bytes) &&
        U32.is_eq(U32.mod(da(bank),8),0) && U32.is_eq(U32.mod(dx(bank),8),0) && x195cy_clear(moves,bank)

@unsafe
def x195cy_snapshot(moves: List<&2,X186Move>, +offset: U32, +ids: N111Ids, +frame: X181Frame) -> X188Seq:
  match moves:
    case Nil{}: X188Empty{}
    case Con{X186Move{destination,source,home,read},rest}:
      x188_many([x181_load(source,ids,frame,x188_reg(10,64)),
        x181_load(N111Local{"__x181_tail"},ids,frame,x188_reg(11,64)),
        x188_i2("movq",x188_reg(10,64),X187Mem{11,offset}),
        x195cy_snapshot(rest,U32.add(offset,8),ids,frame)])

@unsafe
def x195cy_publish(moves: List<&2,X186Move>, +offset: U32, +ids: N111Ids, +frame: X181Frame) -> X188Seq:
  match moves:
    case Nil{}: X188Empty{}
    case Con{X186Move{destination,source,home,read},rest}:
      x188_many([x181_load(N111Local{"__x181_tail"},ids,frame,x188_reg(11,64)),
        x188_i2("movq",X187Mem{11,offset},x188_reg(0,64)),x181_store(destination,frame,x188_reg(0,64)),
        x195cy_publish(rest,U32.add(offset,8),ids,frame)])

law x195cy_schedule:
  for +moves: List<&2,X186Move>
  for +ids: N111Ids
  for +frame: X181Frame
  for +chunks: List<&2,X188Seq>
  for +fuel: U32
  Maybe<&2,X188Seq>

@unsafe
def x195cy_picked(picked: X186Pick, +moves: List<&2,X186Move>, +ids: N111Ids,
    +frame: X181Frame, +chunks: List<&2,X188Seq>, fuel: U32) -> Maybe<&2,X188Seq>:
  match picked:
    case X186Pick{X186Move{destination,source,home,read},rest}:
      x195cy_schedule(rest,ids,frame,Con{x190_move(destination,source,ids,frame),chunks},fuel)
    case X186PickNone{}:
      nt_choose(Maybe<&2,X188Seq>,x195cy_bank(moves,frame),
        u => Some{x188_many([x188_finish(chunks),x195cy_snapshot(moves,0,ids,frame),x195cy_publish(moves,0,ids,frame)])},u => None{})

@unsafe
def x195cy_schedule(moves,ids,frame,chunks,fuel):
  match moves:
    case Nil{}: Some{x188_finish(chunks)}
    case Con{head,rest}: nt_choose(Maybe<&2,X188Seq>,U32.is_gt(fuel,0),
      u => x195cy_picked(x186_p_pick(moves,moves),moves,ids,frame,chunks,U32.sub(fuel,1)),u => None{})

@unsafe
def x195cy_ready(plan: Maybe<&2,List<&2,X186Move>>, +ids: N111Ids, +frame: X181Frame) -> Maybe<&2,X188Seq>:
  match plan:
    case Some{+moves}: nt_choose(Maybe<&2,X188Seq>,x195cy_enabled(),
      u => x195cy_schedule(x186_p_self(moves),ids,frame,[],64),
      u => x186_p_schedule(x186_p_self(moves),ids,frame,[],64))
    case None{}: None{}
