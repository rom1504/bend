# Public ABI11102 static transfers. Both arms must establish the same next FID.
# Keep the existing complete transport (including overlap snapshots and cap4
# fallback). Then perform exactly the work_loop reset and a native tail jump.
# No heap ownership, continuation stack or return transfer is changed.

@unsafe
def x198h_public(frame: X181Frame) -> Bool:
  match frame:
    case X181Frame{slots,bytes,calls,[+state],+symbol}:
      String.eq(state,"state") && String.starts_with(symbol,"p111_FID_")
    case _: False{}

@unsafe
def x198h_finish(body: List<&2,P113DStmt>, +dest: String, +fid: String) -> Bool:
  match body:
    case [P113DScalar{N111Store{N111U32{},N111Local{+s1},28,N111Const{0,0}}},
          P113DScalar{N111Store{N111U32{},N111Local{+s2},32,N111FuncId{+target}}},
          P113DScalar{N111Set{+name,N111U64{},N111Const{0,0}}}]:
      String.eq(s1,"state") && String.eq(s2,"state") && String.eq(target,fid) && String.eq(name,dest)
    case Con{P113DScalar{N111Load{name,typ,base,offset}},rest}: x198h_finish(rest,dest,fid)
    case Con{P113DScalar{N111Store{typ,base,offset,value}},rest}: x198h_finish(rest,dest,fid)
    case _: False{}

@unsafe
def x198h_target(body: List<&2,P113DStmt>, +ids: N111Ids, +frame: X181Frame) -> Maybe<&2,String>:
  match body:
    case [P113DIf{condition,+yes,[P113DScalar{N111Call{+dest,N111U64{},+symbol,
        [N111Arg{N111Ptr{},N111Local{+state}},N111Arg{N111U32{},N111FuncId{+fid}},
         N111Arg{N111Ptr{},N111Local{+buffer}},N111Arg{N111U32{},N111Const{+count,0}}]}}]},
        P113DScalar{N111Return{N111Local{+result}}}]:
      nt_choose(Maybe<&2,String>,x198h_public(frame) && String.eq(symbol,"p111_rt_jump") &&
        String.eq(state,"state") && String.eq(dest,result) && U32.is_le(count,8) &&
        p114t_buffer(buffer) && p186rt_fid(fid,ids) && x198h_finish(yes,dest,fid),
        u => Some{fid},u => None{})
    case _: None{}

@unsafe
def x198h_tail(fid: String, +ids: N111Ids, +frame: X181Frame, code: X181Code) -> X181Code:
  match code:
    case X181Code{chunks,next,terminal,error}:
      X181Code{Con{x188_many([
        x181_load(N111Local{"state"},ids,frame,x188_reg(7,64)),
        x188_i2("movl",X187Imm{4294967295,0},X187Mem{7,32}),
        x186_saves_text(x186_saves_mask(frame),0,True{}),
        x188_i2("movq",x188_reg(5,64),x188_reg(4,64)),x188_i1("popq",x188_reg(5,64)),
        x188_i1("jmp",X187Target{p111q_symbol(fid)})]),chunks},next,True{},error}

@unsafe
def x198h_selected(pick: Maybe<&2,String>, +body: List<&2,P113DStmt>, +facts: X190BranchFacts,
    +ids: N111Ids, +frame: X181Frame, +code: X181Code) -> X181Code:
  match pick body:
    case Some{fid} Con{head,rest}: x198h_tail(fid,ids,frame,x190_stmt(head,facts,ids,frame,code))
    case _ _: x194_ps_step(x194_ps_pick(body),body,facts,ids,frame,code)
