# Experimental overlay after validated joint coloring. Only previously Stack,
# noncandidate, first-write regional locals can acquire caller homes. Existing
# saved/caller homes, candidate graph, gate and emitted program are unchanged.
type X195HMarks is Data:
  X195HMarks{+position: U32, +reversed: List<&2,U32>}

@unsafe
def x195_h_ids(names: List<&2,String>, +bit: U32, +ids: KDef) -> KDef:
  match names:
    case Nil{}: ids
    case Con{name,rest}: x195_h_ids(rest,U32.shl(bit),p111v_put(ids,name,"X190LBit",bit,0))

def x195_h_live(flow: X190LFlow) -> U32:
  match flow:
    case X190LFlow{live,graph}: live

def x195_h_mark(mask: U32, marks: X195HMarks) -> X195HMarks:
  match marks:
    case X195HMarks{position,reversed}: X195HMarks{U32.inc(position),Con{mask,reversed}}

@unsafe
def x195_h_inline_writes(operation: X186InlineOp, name: String, +ids: KDef) -> U32:
  match operation:
    case X186InlineF32{destination,id,buffer}: x190_l_bit(destination,ids)
    case _: x190_l_bit(name,ids)

# Include dead global writes, which live-in/live-out alone do not contain.
@unsafe
def x195_h_scalar_writes(+stmt: N111Stmt, +ids: KDef) -> U32:
  match stmt:
    case N111Set{name,typ,value}: x190_l_bit(name,ids)
    case N111Bin{name,typ,op,left,right}: x190_l_bit(name,ids)
    case N111Load{name,typ,base,offset}: x190_l_bit(name,ids)
    case N111Offset{name,base,bytes}: x190_l_bit(name,ids)
    case N111Call{name,typ,symbol,args}: x195_h_inline_writes(x186_inline_op(stmt),name,ids)
    case _: 0

@unsafe
def x195_h_writes(stmt: P113DStmt, env: X190LEnv) -> U32:
  match stmt env:
    case P113DScalar{scalar} X190LEnv{ids,parameters,header,collect}: x195_h_scalar_writes(scalar,ids)
    case P113DCall{names,target,args} X190LEnv{ids,parameters,header,collect}: x190_l_names(names,ids)
    case P113DAgain{values} X190LEnv{ids,parameters,header,collect}: U32.or(parameters,header)
    case _ _: 0

law x195_h_body:
  for body: List<&2,P113DStmt>
  for +after: U32
  for +env: X190LEnv
  for marks: X195HMarks
  X195HMarks

# This positional traversal matches x185_t_if exactly: condition endpoint,
# yes arm, cut, no arm, cut. Both arms receive the actual common live-out.
@unsafe
def x195_h_if(yes: List<&2,P113DStmt>, no: List<&2,P113DStmt>, +after: U32,
    +env: X190LEnv, mask: U32, marks: X195HMarks) -> X195HMarks:
  x195_h_mark(0,x195_h_body(no,after,env,
    x195_h_mark(0,x195_h_body(yes,after,env,x195_h_mark(mask,marks)))))

@unsafe
def x195_h_stmt_marked(stmt: P113DStmt, +after: U32, +env: X190LEnv,
    mask: U32, marks: X195HMarks) -> X195HMarks:
  match stmt:
    case P113DIf{condition,yes,no}: x195_h_if(yes,no,after,env,mask,marks)
    case P113DScalar{N111If{condition,yes,no}}:
      x195_h_if(x181_scalar_rows(yes),x181_scalar_rows(no),after,env,mask,marks)
    case _: x195_h_mark(mask,marks)

@unsafe
def x195_h_stmt(+stmt: P113DStmt, +after: U32, +env: X190LEnv, marks: X195HMarks) -> X195HMarks:
  +before = x195_h_live(x190_l_stmt(stmt,X190LFlow{after,[]},env))
  +mask = U32.or(before,U32.or(after,x195_h_writes(stmt,env)))
  x195_h_stmt_marked(stmt,after,env,mask,marks)

# Reuse the certified global transfer functions instead of approximating
# occupancy by names mentioned in a region. A silent live-through value is
# present in each suffix's live-out. Work is quadratic inside the 256-row gate.
@unsafe
def x195_h_body(body,after,env,marks):
  match body:
    case Nil{}: marks
    case Con{head,+rest}:
      +live = x195_h_live(x190_l_body(rest,X190LFlow{after,[]},env))
      x195_h_body(rest,after,env,x195_h_stmt(head,live,env,marks))

@unsafe
def x195_h_range(points: List<&2,U32>, +position: U32, +first: U32, +last: U32) -> U32:
  match points:
    case Nil{}: 0
    case Con{mask,rest}:
      nt_choose(U32,U32.is_gt(position,last),u => 0,u =>
        U32.or(nt_choose(U32,U32.is_lt(position,first),v => 0,v => mask),
          x195_h_range(rest,U32.inc(position),first,last)))

def x195_h_callers(groups: List<&2,U32>) -> List<&2,U32>:
  match groups:
    case Con{a,Con{b,Con{c,Con{d,rest}}}}: rest
    case _: []

# One physical caller color is available only if no global occupant is live
# or written anywhere in the local's inclusive range, and no earlier local
# using this color overlaps the range. Existing source/dest reuse stays intact.
@unsafe
def x195_h_pick(groups: List<&2,U32>, ends: List<&2,U32>, +blocked: U32,
    +first: U32, +index: U32) -> U32:
  match groups ends:
    case Con{mask,rest} Con{last,more}:
      nt_choose(U32,U32.is_lt(last,first) && U32.is_eq(U32.and(mask,blocked),0),
        u => index,u => x195_h_pick(rest,more,blocked,first,U32.inc(index)))
    case _ _: 5

law x195_h_place:
  for names: List<&2,String>
  for +ranges: KDef
  for +ids: KDef
  for +points: List<&2,U32>
  for +groups: List<&2,U32>
  for +frame: X181Frame
  for +ends: List<&2,U32>
  X181Frame

@unsafe
def x195_h_chosen(+name: String, +rest: List<&2,String>, +ranges: KDef, +ids: KDef,
    +points: List<&2,U32>, +groups: List<&2,U32>, +frame: X181Frame,
    +ends: List<&2,U32>, +index: U32, +last: U32) -> X181Frame:
  nt_choose(X181Frame,U32.is_lt(index,5),
    u => x195_h_place(rest,ranges,ids,points,groups,x185_t_install(name,index,frame),x185_t_end(ends,index,last)),
    u => x195_h_place(rest,ranges,ids,points,groups,frame,ends))

@unsafe
def x195_h_place(names,ranges,ids,points,groups,frame,ends):
  match names frame:
    case Nil{} _: frame
    case Con{+name,+rest} X181Frame{+slots,bytes,calls,params,symbol}:
      +range = p111v_get(ranges,name)
      nt_choose(X181Frame,String.eq(dk(range),"X185TRange") &&
          String.eq(dk(p111v_get(slots,name)),"X181Stack") && U32.is_eq(x190_l_bit(name,ids),0),
        u => x195_h_chosen(name,rest,ranges,ids,points,groups,frame,ends,
          x195_h_pick(groups,ends,x195_h_range(points,1,da(range),dx(range)),da(range),0),dx(range)),
        u => x195_h_place(rest,ranges,ids,points,groups,frame,ends))

# Refuse an inconsistent positional walk without disturbing the validated
# joint result. Eligibility is the existing scan, including setup/param bans.
@unsafe
def x195_h_scanned(+frame: X181Frame, ids: KDef, groups: List<&2,U32>,
    scan: X185TScan, marks: X195HMarks) -> X181Frame:
  match scan marks:
    case X185TScan{ranges,names,position,region} X195HMarks{count,reversed}:
      nt_choose(X181Frame,U32.is_eq(position,count),
        u => x195_h_place(nt_reverse(String,names,[]),ranges,ids,nt_reverse(U32,reversed,[]),
          x195_h_callers(groups),frame,[0,0,0,0,0]),u => frame)

@unsafe
def x195_h_solved(+frame: X181Frame, params: List<&2,String>, setup: List<&2,P113DStmt>,
    +body: List<&2,P113DStmt>, +ids: KDef, groups: List<&2,U32>, parameters: U32, fixed: X190LFixed) -> X181Frame:
  match fixed:
    case X190LFixed{header,ready}:
      nt_choose(X181Frame,ready,
        u => x195_h_scanned(frame,ids,groups,
          x185_t_body(body,X185TScan{x185_copy_writes_names(params,x185_copy_writes(setup,missing())),[],1,0}),
          x195_h_body(body,0,X190LEnv{ids,parameters,header,False{}},X195HMarks{1,[]})),u => frame)

@unsafe
def x195_h_overlay(+frame: X181Frame, params: List<&2,String>, setup: List<&2,P113DStmt>,
    +body: List<&2,P113DStmt>, +names: List<&2,String>, groups: List<&2,U32>) -> X181Frame:
  +ids = x195_h_ids(names,1,missing())
  +parameters = x190_l_names(x181_tail_args(frame),ids)
  nt_choose(X181Frame,U32.is_le(nt_count(String,names),32),
    u => x195_h_solved(frame,params,setup,body,ids,groups,parameters,x190_l_fixed(body,ids,parameters,0,33)),u => frame)

# Sole override: preserve validation, original candidate colors and refusal.
@unsafe
def x190_j_checked(+frame: X181Frame, +params: List<&2,String>, +setup: List<&2,P113DStmt>,
    +body: List<&2,P113DStmt>, +registerBody: List<&2,P113DStmt>, +names: List<&2,String>,
    +rows: List<&2,U32>, +groups: List<&2,U32>) -> X181Frame:
  nt_choose(X181Frame,x190_j_valid(names,rows,params,1,groups),
    u => x195_h_overlay(x190_j_install(names,groups,1,frame),params,setup,body,names,groups),
    u => x190_allocate_legacy(frame,params,setup,body,registerBody))
