# Compiler-data controls only. The actual request entry and final verifier remain
# required to authorize emitted runtime bodies.

@unsafe
def p171db_take(kind: U32, buffer: String) -> P113DStmt:
  P113DScalar{N111Call{"ignored",N111U64{},"p111_rt_special_take",[p111_state(),p111_u32(kind),p111_word(N111Local{"root"}),N111Arg{N111Ptr{},N111Local{buffer}},p111_u32(1)]}}

@unsafe
def p171db_tail(buffer: String) -> List<&2,P113DStmt>:
  [P113DScalar{N111Load{"field",N111U64{},N111Local{buffer},0}},P113DResult{[N111Local{"field"}]}]

@unsafe
def p171db_alias(+kind: U32) -> Bool:
  p171di_exact(p171dc_run(nt_append(P113DStmt,[
    P113DScalar{N111Alloca{"buffer",8,8}},
    P113DScalar{N111Set{"alias",N111Ptr{},N111Local{"buffer"}}},p171db_take(kind,"buffer")],p171db_tail("alias")),[]),[
    P113DScalar{N111Alloca{"buffer",8,8}},
    P113DScalar{N111Set{"alias",N111Ptr{},N111Local{"buffer"}}},p171db_take(kind,"buffer"),
    P113DScalar{N111Load{"field",N111U64{},N111Local{"alias"},0}},
    P113DResult{[N111Const{1,0},N111Local{"field"}]}],5,1,0,False{})

@unsafe
def p171db_refuse(body: List<&2,P113DStmt>) -> Bool:
  Bool.not(p171dc_accept(p171dc_run(body,[])))

@unsafe
def p171db_phi(+bit: U32) -> Bool:
  +prefix : List<&2,P113DStmt> = [
    P113DScalar{N111Set{"condition",N111U32{},N111Const{bit,0}}},
    P113DScalar{N111If{N111Local{"condition"},[N111Set{"joined",N111U64{},N111Const{1,0}}],[N111Set{"joined",N111U64{},N111Const{0,0}}]}},
    P113DScalar{N111Set{"alias",N111U64{},N111Local{"joined"}}}]
  p171di_exact(p171dc_run(nt_append(P113DStmt,prefix,[P113DResult{[N111Local{"alias"}]}]),[]),
    nt_append(P113DStmt,prefix,[P113DResult{[N111Const{1,0},N111Local{"alias"}]}]),4,1,0,False{})

@unsafe
def p171d_buffer_controls() -> List<&2,String>:
  [p171dc_row("named-Chr-buffer-pointer-alias-full-value",p171db_alias(5)),
   p171dc_row("named-Succ-buffer-pointer-alias-full-value",p171db_alias(4)),
   p171dc_row("undeclared-buffer-refuses",p171db_refuse(Con{p171db_take(5,"absent"),p171db_tail("absent")})),
   p171dc_row("uninitialized-buffer-load-refuses",p171db_refuse(Con{P113DScalar{N111Alloca{"buffer",8,8}},p171db_tail("buffer")})),
   p171dc_row("short-buffer-refuses",p171db_refuse(nt_append(P113DStmt,[P113DScalar{N111Alloca{"buffer",4,8}},p171db_take(5,"buffer")],p171db_tail("buffer")))),
   p171dc_row("bad-alignment-refuses",p171db_refuse(nt_append(P113DStmt,[P113DScalar{N111Alloca{"buffer",8,3}},p171db_take(5,"buffer")],p171db_tail("buffer")))),
   p171dc_row("oversized-buffer-refuses",p171db_refuse(nt_append(P113DStmt,[P113DScalar{N111Alloca{"buffer",2049,8}},p171db_take(5,"buffer")],p171db_tail("buffer")))),
   p171dc_row("other-buffer-not-last-writer-refuses",p171db_refuse(nt_append(P113DStmt,[P113DScalar{N111Alloca{"buffer",8,8}},P113DScalar{N111Alloca{"other",8,8}},p171db_take(5,"buffer")],p171db_tail("other")))),
   p171dc_row("reallocation-invalidates-and-refuses",p171db_refuse(nt_append(P113DStmt,[P113DScalar{N111Alloca{"buffer",8,8}},P113DScalar{N111Set{"alias",N111Ptr{},N111Local{"buffer"}}},P113DScalar{N111Alloca{"buffer",8,8}},p171db_take(5,"buffer")],p171db_tail("alias")))),
   p171dc_row("pointer-result-refuses",p171db_refuse([P113DScalar{N111Alloca{"buffer",8,8}},P113DResult{[N111Local{"buffer"}]}])),
   p171dc_row("allocating-special-kind-refuses",p171db_refuse(nt_append(P113DStmt,[P113DScalar{N111Alloca{"buffer",8,8}},p171db_take(7,"buffer")],p171db_tail("buffer")))),
   p171dc_row("compact-true-constant-join-full-value",p171db_phi(1)),
   p171dc_row("compact-false-constant-join-full-value",p171db_phi(0))]
