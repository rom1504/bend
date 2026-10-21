# Finite compiler-analysis controls only. These construct IR as data and inspect
# origin facts; they never emit/execute an owning graph or invoke runtime calls.
# Deliberately unknown pointers/callees are refusal probes, not admitted programs.
@unsafe
def p117hc_start() -> P117HScan:
  P117HScan{p117h_seed([NC_Binding{0,"a",N_Box{}},NC_Binding{1,"b",N_Box{}}],1,missing()),
    missing(),3,0,False{},256,0,missing()}

@unsafe
def p117hc_run(body: List<&2,P113DStmt>) -> P117HScan:
  p117h_walk(body,2,p117hc_start())

def p117hc_copy(name: String, source: String) -> P113DStmt:
  P113DScalar{N111Set{name,N111U64{},N111Local{source}}}

def p117hc_store(buffer: String, value: String) -> P113DStmt:
  P113DScalar{N111Store{N111U64{},N111Local{buffer},0,N111Local{value}}}

@unsafe
def p117hc_origin(scan: P117HScan, name: String, expected: U32) -> Bool:
  match scan:
    case P117HScan{facts,slots,mask,used,again,left,next,sites}: U32.is_eq(p117h_get(facts,name),expected)

@unsafe
def p117hc_slot(scan: P117HScan, name: String, expected: U32) -> Bool:
  match scan:
    case P117HScan{facts,slots,mask,used,again,left,next,sites}: U32.is_eq(p117h_load(N111Local{name},0,slots),expected)

@unsafe
def p117hc_mask(scan: P117HScan, expected: U32) -> Bool:
  match scan:
    case P117HScan{facts,slots,mask,used,again,left,next,sites}: U32.is_eq(mask,expected)

@unsafe
def p117hc_loop(scan: P117HScan, expected: U32) -> Bool:
  match scan:
    case P117HScan{facts,slots,mask,used,again,left,next,sites}: again && U32.is_eq(mask,expected)

@unsafe
def p117hc_site(scan: P117HScan, expected: U32) -> Bool:
  match scan:
    case P117HScan{facts,slots,mask,used,again,left,next,sites}:
      U32.is_eq(next,1) && U32.is_eq(p117h_get(sites,"0"),expected)

@unsafe
def p117hc_row(name: String, ok: Bool) -> String:
  name ++ nt_choose(String,ok,u => " PASS\n",u => " FAIL\n")

@unsafe
def p117h_controls() -> String:
  +branch_same = p117hc_run([P113DIf{N111Const{1,0},[p117hc_copy("x","a")],[p117hc_copy("x","a")]}])
  +branch_diff = p117hc_run([P113DIf{N111Const{1,0},[p117hc_copy("x","a")],[p117hc_copy("x","b")]}])
  +slot_same = p117hc_run([P113DIf{N111Const{1,0},[p117hc_store("scratch","a")],[p117hc_store("scratch","a")]}])
  +slot_diff = p117hc_run([P113DIf{N111Const{1,0},[p117hc_store("scratch","a")],[p117hc_store("scratch","b")]}])
  +fresh = p117hc_run([p117hc_store("scratch","a"),P113DScalar{N111Alloca{"p113p_out_0",16,8}}])
  +get = p117hc_run([p117hc_store("scratch","a"),
    P113DScalar{N111Store{N111U64{},N111Local{"scratch"},8,N111Const{0,0}}},
    P113DScalar{N111Alloca{"p113p_out_0",16,8}},
    P113DScalar{N111Call{"status",N111U64{},"p113_rt_array_pair",
      [p111_state(),p111_u32(72),p111_scratch(),p111_u32(2),N111Arg{N111Ptr{},N111Local{"p113p_out_0"}},p111_u32(2)]}}])
  +unknown_write = p117hc_run([P113DScalar{N111Alloca{"other_buffer",16,8}},
    p117hc_store("scratch","a"),p117hc_store("other_buffer","b")])
  +unknown_call = p117hc_run([p117hc_store("scratch","a"),
    P113DScalar{N111Call{"kept",N111U64{},"p111_rt_keep",[p111_state(),N111Arg{N111U64{},N111Local{"a"}}]}}])
  +diamond = p117hc_run([p117hc_copy("x","a"),p117hc_store("scratch","b"),
    P113DScalar{N111If{N111Const{1,0},[N111Set{"x",N111U64{},N111Const{1,0}}],[N111Set{"x",N111U64{},N111Const{0,0}}]}}])
  +sites = p117h_put(p117h_put(missing(),"0",1),"1",2)
  p117hc_row("copy-backedge",p117hc_loop(p117hc_run([p117hc_copy("x","a"),P113DAgain{[N111Local{"x"},N111Local{"b"}]}]),3)) ++
  p117hc_row("changed-origin-rejects",p117hc_loop(p117hc_run([P113DAgain{[N111Local{"b"},N111Local{"b"}]}]),2)) ++
  p117hc_row("snapshot-survives-rebinding",p117hc_loop(p117hc_run([
    p117hc_copy("x","a"),p117hc_copy("a","b"),P113DAgain{[N111Local{"x"},N111Local{"b"}]}]),3)) ++
  p117hc_row("rebound-parameter-rejects",p117hc_loop(p117hc_run([
    p117hc_copy("a","b"),P113DAgain{[N111Local{"a"},N111Local{"b"}]}]),2)) ++
  p117hc_row("all-backedges-intersect",p117hc_loop(p117hc_run([P113DIf{N111Const{1,0},
    [P113DAgain{[N111Local{"a"},N111Local{"b"}]}],[P113DAgain{[N111Local{"b"},N111Local{"b"}]}]}]),2)) ++
  p117hc_row("fresh-alloca-preserves-scratch",p117hc_slot(fresh,"scratch",1) && p117hc_slot(fresh,"p113p_out_0",0)) ++
  p117hc_row("get-site-after-fresh-alloca",p117hc_site(get,1) && p117hc_slot(get,"p113p_out_0",1)) ++
  p117hc_row("branch-origin-agreement",p117hc_origin(branch_same,"x",1) && p117hc_origin(branch_same,"a",1)) ++
  p117hc_row("branch-origin-disagreement",p117hc_origin(branch_diff,"x",0) && p117hc_origin(branch_diff,"a",1)) ++
  p117hc_row("branch-slot-agreement",p117hc_slot(slot_same,"scratch",1)) ++
  p117hc_row("branch-slot-disagreement",p117hc_slot(slot_diff,"scratch",0)) ++
  p117hc_row("unknown-store-invalidates-slot",p117hc_slot(unknown_write,"scratch",0) && p117hc_origin(unknown_write,"a",1)) ++
  p117hc_row("narrow-store-invalidates-slot",p117hc_slot(p117hc_run([p117hc_store("scratch","a"),
    P113DScalar{N111Store{N111U32{},N111Local{"scratch"},0,N111Const{0,0}}}]),"scratch",0)) ++
  p117hc_row("unknown-call-invalidates-slot",p117hc_slot(unknown_call,"scratch",0) && p117hc_origin(unknown_call,"a",1) && p117hc_origin(unknown_call,"kept",0)) ++
  p117hc_row("pointer-alias-refuses",p117hc_mask(p117hc_run([
    P113DScalar{N111Set{"alias",N111Ptr{},N111Local{"scratch"}}}]),0)) ++
  p117hc_row("pointer-offset-refuses",p117hc_mask(p117hc_run([
    P113DScalar{N111Offset{"alias",N111Local{"scratch"},N111Const{0,0}}}]),0)) ++
  p117hc_row("boolean-diamond-preserves-other-facts",p117hc_origin(diamond,"x",0) && p117hc_origin(diamond,"a",1) && p117hc_slot(diamond,"scratch",2)) ++
  p117hc_row("effectful-scalar-branch-refuses",p117hc_mask(p117hc_run([P113DScalar{N111If{N111Const{1,0},
    [N111Store{N111U64{},N111Local{"scratch"},0,N111Local{"a"}}],[]}}]),0)) ++
  p117hc_row("version-all-sites-covered",p117v_all(sites,2,3,0)) ++
  p117hc_row("version-noninvariant-site-refuses",Bool.not(p117v_all(sites,2,1,0))) ++
  p117hc_row("version-missing-site-refuses",Bool.not(p117v_all(sites,3,3,0))) ++
  p117hc_row("reserved-buffer-parameter-refuses",Bool.not(p117h_params_clean([NC_Binding{0,"p113p_out_0",N_Box{}}])))
