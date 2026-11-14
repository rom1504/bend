# Finite checked compiler-data controls; root runs these in its single lane.
def p195h_v(name: String) -> N111Value: N111Local{name}
def p195h_set(name: String) -> P113DStmt: P113DScalar{N111Set{name,N111U64{},N111Const{7,0}}}
def p195h_use(name: String) -> P113DStmt:
  P113DScalar{N111Store{N111U64{},p195h_v("state"),0,p195h_v(name)}}

@unsafe
def p195h_label(name: String, pass: Bool) -> String:
  name ++ "=" ++ nt_choose(String,pass,u => "1",u => "0")

@unsafe
def p195h_points(body: List<&2,P113DStmt>, ids: KDef, parameters: U32, header: U32) -> List<&2,U32>:
  match x195_h_body(body,0,X190LEnv{ids,parameters,header,False{}},X195HMarks{1,[]}):
    case X195HMarks{position,reversed}: nt_reverse(U32,reversed,[])

@unsafe
def p195h_mask(body: List<&2,P113DStmt>, first: U32, last: U32) -> U32:
  x195_h_range(p195h_points(body,x195_h_ids(["g","h"],1,missing()),0,0),1,first,last)

@unsafe
def p195h_range_ok(scan: X185TScan, name: String) -> Bool:
  match scan:
    case X185TScan{ranges,names,position,region}: String.eq(dk(p111v_get(ranges,name)),"X185TRange")

@unsafe
def p195h_eligible(body: List<&2,P113DStmt>) -> Bool:
  p195h_range_ok(x185_t_body(body,X185TScan{missing(),[],1,0}),"local")

@unsafe
def p195h_home(frame: X181Frame, name: String, index: U32) -> Bool:
  match frame:
    case X181Frame{slots,bytes,calls,params,symbol}:
      +slot = p111v_get(slots,name)
      String.eq(dk(slot),"X185Transient") && U32.is_eq(da(slot),index)

@unsafe
def p195h_allocated(+body: List<&2,P113DStmt>, +params: List<&2,String>, +setup: List<&2,P113DStmt>) -> X181Frame:
  +groups: List<&2,U32> = [0,0,0,0,1,0,0,0,0]
  x195_h_overlay(x190_j_install(["g"],groups,1,x181_frame("control",params,nt_append(P113DStmt,setup,body))),
    params,setup,body,["g"],groups)

@unsafe
def p195h_counts(+body: List<&2,P113DStmt>) -> Bool:
  match x185_t_body(body,X185TScan{missing(),[],1,0})
      x195_h_body(body,0,X190LEnv{missing(),0,0,False{}},X195HMarks{1,[]}):
    case X185TScan{ranges,names,a,region} X195HMarks{b,points}: U32.is_eq(a,b)

def p195h_inline() -> N111Stmt:
  N111Call{"g",N111U64{},"p111_rt_op",[
    N111Arg{N111Ptr{},p195h_v("state")},N111Arg{N111U32{},N111Const{26,0}},
    N111Arg{N111Ptr{},p195h_v("h")},N111Arg{N111U32{},N111Const{2,0}}]}

@unsafe
def p195h_controls() -> List<&2,String>:
  +silent: List<&2,P113DStmt> = [p195h_set("local"),p195h_use("local"),P113DResult{[p195h_v("g")]}]
  +dead: List<&2,P113DStmt> = [p195h_set("local"),p195h_set("g"),p195h_use("local"),P113DResult{[]}]
  +branch: List<&2,P113DStmt> = [P113DIf{N111Const{1,0},[p195h_set("local"),p195h_use("local")],[]},P113DResult{[p195h_v("g")]}]
  +loop: List<&2,P113DStmt> = [p195h_set("local"),p195h_use("local"),P113DAgain{[p195h_v("g")]}]
  +realCall: P113DStmt = P113DCall{["answer"],"external",[p195h_v("local")]}
  +ids = x195_h_ids(["g","h"],1,missing())
  [p195h_label("silent-live-through-mask",U32.is_eq(p195h_mask(silent,1,2),1)),
   p195h_label("dead-global-write-mask",U32.is_eq(p195h_mask(dead,1,3),1)),
   p195h_label("branch-live-through-mask",U32.is_eq(p195h_mask(branch,2,3),1)),
   p195h_label("branch-position-alignment",p195h_counts(branch)),
   p195h_label("again-header-and-parameter-mask",U32.is_eq(x195_h_range(p195h_points([P113DAgain{[]}],ids,2,1),1,1,1),3)),
   p195h_label("inline-buffer-and-destination-mask",U32.is_eq(p195h_mask([P113DScalar{p195h_inline()}],1,1),3)),
   p195h_label("inclusive-local-endpoint",U32.is_eq(x195_h_pick([0,0,0,0,0],[3,0,0,0,0],0,3,0),1)),
   p195h_label("expired-local-home-reusable",U32.is_eq(x195_h_pick([0,0,0,0,0],[3,0,0,0,0],0,4,0),0)),
   p195h_label("all-global-colors-blocked",U32.is_eq(x195_h_pick([1,2,4,8,16],[0,0,0,0,0],31,1,0),5)),
   p195h_label("first-read-refused",Bool.not(p195h_eligible([p195h_use("local"),p195h_set("local")]))),
   p195h_label("cross-branch-local-refused",Bool.not(p195h_eligible([p195h_set("local"),P113DIf{N111Const{1,0},[p195h_use("local")],[]}]))),
   p195h_label("real-call-local-refused",Bool.not(p195h_eligible([p195h_set("local"),realCall,p195h_use("local")]))),
   p195h_label("setup-name-refused",Bool.not(p195h_range_ok(x185_t_body([p195h_set("local"),p195h_use("local")],
     X185TScan{x185_copy_writes([p195h_set("local")],missing()),[],1,0}),"local"))),
   p195h_label("silent-live-through-admission",p195h_home(p195h_allocated(silent,["state"],[p195h_set("g")]),"local",1)),
   p195h_label("dead-write-admission",p195h_home(p195h_allocated(dead,["state"],[]),"local",1)),
   p195h_label("loop-invariant-admission",p195h_home(p195h_allocated(loop,["state","g"],[]),"local",1)),
   p195h_label("unused-global-color-reused",p195h_home(p195h_allocated([p195h_set("local"),p195h_use("local"),P113DResult{[]}],["state"],[p195h_set("g")]),"local",0)),
   p195h_label("existing-global-home-unchanged",p195h_home(p195h_allocated(silent,["state"],[p195h_set("g")]),"g",0))]
