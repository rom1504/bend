# Pure admission/model controls only. Fabricated registry rows are inputs to
# these predicates, never passed to code generation or target execution.

@unsafe
def p124c_direct(arity: U32, result: U32, public: Bool) -> KDef:
  p113e_insert(missing(),KDef{"helper","P113Direct",arity,result,atom("Absent"),
    kt("P113Public","",Bool.to_u32(public),0,[]),[],False{},False{}})

@unsafe
def p124c_legacy(arity: U32) -> KDef:
  p111v_put(missing(),"helper","P112Worker",arity,0)

@unsafe
def p124c_jump(target: String, count: U32) -> List<&2,N111Stmt>:
  [N111Call{"transfer",N111U64{},"p111_rt_jump",[p111_state(),
    N111Arg{N111U32{},N111FuncId{target}},N111Arg{N111Ptr{},N111Local{"scratch"}},p111_u32(count)]},
    N111Return{N111Local{"transfer"}}]

@unsafe
def p124c_tail(target: String, count: U32) -> List<&2,N111Stmt>:
  Con{N111Store{N111U64{},N111Local{"scratch"},0,N111Local{"argument"}},p124c_jump(target,count)}

@unsafe
def p124c_frame(tail: List<&2,N111Stmt>) -> List<&2,N111Stmt>:
  Con{N111Store{N111U64{},N111Local{"scratch"},0,N111Local{"capture"}},
    Con{N111Call{"frame",N111U64{},"p111_rt_frame",[p111_state(),
      N111Arg{N111U32{},N111FuncId{"resume"}},N111Arg{N111Ptr{},N111Local{"scratch"}},p111_u32(1)]},tail}}

@unsafe
def p124c_scan(+body: List<&2,N111Stmt>, owner: String, ready: KDef) -> P114GBody:
  p114h_scan_frame(body,owner,1,ready,p112f_frame(body,0,[]))


def p124c_kind(result: P114GBody) -> U32:
  match result:
    case P114GBody{True{},Con{P114GFrame{name,1},Nil{}},Con{P114RResumeReady{frame,call,value},Nil{}}}: 1
    case P114GBody{True{},Con{P114GFrame{name,1},Nil{}},Con{P114RDescend{frame,args},Nil{}}}: 2
    case P114GBody{False{},frames,body}: 0
    case _: 3

@unsafe
def p124c_symbol(callable: P124Callable, expected: String) -> Bool:
  match callable:
    case P124Callable{valid,arity,symbol}: valid && String.eq(symbol,expected)

@unsafe
def p124c_admitted(+ready: KDef) -> Bool:
  U32.is_eq(p124c_kind(p124c_scan(p124c_frame(p124c_tail("helper",1)),"owner",ready)),1)

@unsafe
def p124c_refused(+ready: KDef) -> Bool:
  U32.is_eq(p124c_kind(p124c_scan(p124c_frame(p124c_tail("helper",1)),"owner",ready)),0)

@unsafe
def p124c_renamed(stmt: P114RStmt) -> Bool:
  match stmt:
    case P114RResumeReady{Con{N111Set{a,N111U64{},N111Local{b}},Nil{}},
      Con{N111Set{c,N111U64{},N111Local{d}},Nil{}},N111Local{e}}:
      String.eq(a,"case_local_frame") && String.eq(b,"case_local_owned") &&
      String.eq(c,"case_local_value") && String.eq(d,"case_local_argument") && String.eq(e,"case_local_value")
    case _: False{}

@unsafe
def p124c_controls() -> List<&2,String>:
  [p113ft_row("complete-public-result1",p124c_admitted(p124r_view(missing(),p124c_direct(1,1,True{})))),
   p113ft_row("legacy-view",p124c_admitted(p124r_view(p124c_legacy(1),missing()))),
   p113ft_row("legacy-original-refusal",p124c_refused(p124c_legacy(1))),
   p113ft_row("missing-helper",p124c_refused(p124r_view(missing(),missing()))),
   p113ft_row("wrong-arity",p124c_refused(p124r_view(missing(),p124c_direct(2,1,True{})))),
   p113ft_row("private-only",p124c_refused(p124r_view(missing(),p124c_direct(1,1,False{})))),
   p113ft_row("multi-result",p124c_refused(p124r_view(missing(),p124c_direct(1,2,True{})))),
   p113ft_row("arity-over-eight",p124c_refused(p124r_view(missing(),p124c_direct(9,1,True{})))),
   p113ft_row("untrusted-view-shape",Bool.not(p124r_valid(p124r_lookup(missing(),"helper")))),
   p113ft_row("direct-symbol",p124c_symbol(p124r_lookup(p124r_view(missing(),p124c_direct(1,1,True{})),"helper"),p113e_symbol("helper"))),
   p113ft_row("legacy-symbol",p124c_symbol(p124r_lookup(p124r_view(p124c_legacy(1),missing()),"helper"),p112w_symbol("helper"))),
   p113ft_row("complete-priority",p124c_symbol(p124r_lookup(p124r_view(p124c_legacy(1),p124c_direct(1,1,True{})),"helper"),p113e_symbol("helper"))),
   p113ft_row("same-owner-old-descend",U32.is_eq(p124c_kind(p124c_scan(p124c_frame(p124c_tail("owner",1)),"owner",p124r_view(missing(),missing()))),2)),
   p113ft_row("unknown-call-blocks",U32.is_eq(p124c_kind(p124c_scan(p124c_frame(Con{N111Call{"unknown",N111U64{},"unknown",[]},p124c_tail("helper",1)}),"owner",p124r_view(missing(),p124c_direct(1,1,True{})))),0)),
   p113ft_row("scalar-prefix",U32.is_eq(p124c_kind(p124c_scan(p124c_frame(Con{N111Set{"word",N111U64{},N111Const{7,0}},p124c_tail("helper",1)}),"owner",p124r_view(missing(),p124c_direct(1,1,True{})))),1)),
   p113ft_row("scratch-shape-refusal",U32.is_eq(p124c_kind(p124c_scan(p124c_frame(Con{N111Store{N111U64{},N111Local{"other"},0,N111Local{"argument"}},p124c_jump("helper",1)}),"owner",p124r_view(missing(),p124c_direct(1,1,True{})))),0)),
   p113ft_row("all-node-fields-renamed",p124c_renamed(p114h_rename_stmt(P114RResumeReady{
     [N111Set{"frame",N111U64{},N111Local{"owned"}}],[N111Set{"value",N111U64{},N111Local{"argument"}}],N111Local{"value"}},"case_")))]
