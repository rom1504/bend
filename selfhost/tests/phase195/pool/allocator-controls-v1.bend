# Finite compiler-data controls. Machine output is separately root-owned.
def p195p_v(name: String) -> N111Value: N111Local{name}

@unsafe
def p195p_label(name: String, pass: Bool) -> String:
  name ++ "=" ++ nt_choose(String,pass,u => "1",u => "0")

@unsafe
def p195p_groups(color: U32, bit: U32) -> List<&2,U32>:
  x190_l_group([0,0,0,0,0,0,0,0,0,0,0],color,bit)

@unsafe
def p195p_ids() -> KDef:
  p111v_put(p111v_put(p111v_put(missing(),"a","X190LBit",1,0),"b","X190LBit",2,0),"c","X190LBit",4,0)

@unsafe
def p195p_shift(after: U32, value: N111Value) -> U32:
  x195_p_shift_scalar(N111Bin{"b",N111U64{},"shl",p195p_v("a"),value},after,
    X190LEnv{p195p_ids(),0,0,False{}},0)

@unsafe
def p195p_frame(width: U32) -> X181Frame:
  X181Frame{p111v_put(p111v_put(missing(),"state","X181Register",0,width),"v","X181Stack",64,8),64,0,["state"],"pool_control"}

@unsafe
def p195p_home(frame: X181Frame, name: String, kind: String, offset: U32) -> Bool:
  match frame:
    case X181Frame{slots,bytes,calls,params,symbol}:
      +slot = p111v_get(slots,name)
      String.eq(dk(slot),kind) && U32.is_eq(da(slot),offset) && U32.is_eq(dx(slot),8)

def p195p_bytes(frame: X181Frame, wanted: U32) -> Bool:
  match frame:
    case X181Frame{slots,bytes,calls,params,symbol}: U32.is_eq(bytes,wanted)

@unsafe
def p195p_transaction(width: U32, color: U32) -> X181Frame:
  x195_p_checked(p195p_frame(width),["state"],[],[],[],["v"],[0],p195p_groups(color,1),0)

@unsafe
def p195p_collision() -> Bool:
  Bool.not(x195_p_valid(["a","b"],[2,1],[],1,p195p_groups(10,3),0))

@unsafe
def p195p_duplicate() -> Bool:
  Bool.not(x195_p_valid(["v"],[0],[],1,x190_l_group(p195p_groups(10,1),9,1),0))

@unsafe
def p195p_abi(position: U32) -> Bool:
  x195_p_valid_groups(p195p_groups(9,1),1,0,position,0,False{},0)

@unsafe
def p195p_live_through_shift() -> Bool:
  +rows: List<&2,P113DStmt> = [P113DScalar{N111Bin{"b",N111U64{},"shr",N111Const{9,0},p195p_v("c")}},
    P113DResult{[p195p_v("a")]}]
  U32.is_eq(x195_p_shifts(rows,0,X190LEnv{p195p_ids(),0,0,False{}},0),3)

@unsafe
def p195p_controls() -> List<&2,String>:
  [p195p_label("pool-variable-shift-destination-blocked",U32.is_eq(p195p_shift(0,p195p_v("c")),2)),
   p195p_label("pool-variable-shift-liveout-blocked",U32.is_eq(p195p_shift(1,p195p_v("c")),3)),
   p195p_label("pool-dying-shift-sources-allowed",U32.is_eq(U32.and(p195p_shift(0,p195p_v("c")),5),0)),
   p195p_label("pool-immediate-shift-no-clobber",U32.is_eq(p195p_shift(1,N111Const{7,0}),0)),
   p195p_label("pool-silent-live-through-shift",p195p_live_through_shift()),
   p195p_label("pool-rcx-destination-validation",Bool.not(x195_p_valid(["v"],[0],[],1,p195p_groups(9,1),1))),
   p195p_label("pool-rcx-callcross-refused",Bool.not(x195_p_valid(["v"],[1],[],1,p195p_groups(9,1),0))),
   p195p_label("pool-r12-callcross-allowed",x195_p_valid(["v"],[1],[],1,p195p_groups(10,1),0)),
   p195p_label("pool-rcx-incoming2-refused",Bool.not(p195p_abi(2))),
   p195p_label("pool-rcx-incoming3-allowed",p195p_abi(3)),
   p195p_label("pool-r12-interference-refused",p195p_collision()),
   p195p_label("pool-duplicate-home-refused",p195p_duplicate()),
   p195p_label("pool-uncolored-sentinel11",U32.is_eq(x195_p_home(p195p_groups(0,2),1,0),11)),
   p195p_label("pool-high-bit-shift-refused",Bool.not(x195_p_valid_groups(p195p_groups(9,2147483648),2147483648,0,4294967295,0,False{},2147483648))),
   p195p_label("pool-high-bit-r12-allowed",x195_p_valid_groups(p195p_groups(10,2147483648),2147483648,0,4294967295,0,False{},0)),
   p195p_label("pool-fresh-state-required",Bool.not(x195_p_state_safe(p195p_frame(4)))),
   p195p_label("pool-state-stack-transaction",p195p_home(p195p_transaction(8,10),"state","X181Stack",72)),
   p195p_label("pool-r12-local-installed",p195p_home(p195p_transaction(8,10),"v","X181Register",0)),
   p195p_label("pool-state-append-exactly8",p195p_bytes(p195p_transaction(8,10),72)),
   p195p_label("pool-rcx-local-installed",p195p_home(p195p_transaction(8,9),"v","X185Transient",5)),
   p195p_label("pool-unused-r12-keeps-state",p195p_home(p195p_transaction(8,9),"state","X181Register",0)),
   p195p_label("pool-unused-r12-no-frame-growth",p195p_bytes(p195p_transaction(8,9),64)),
   p195p_label("pool-unsafe-state-refuses-install",p195p_home(p195p_transaction(4,10),"v","X181Stack",64))]
