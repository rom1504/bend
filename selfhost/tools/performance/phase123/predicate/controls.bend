# Finite pure controls. No malformed IR is executed as native code.
@unsafe
def p123pt_transport(+invert: Bool) -> List<&2,N111Stmt>:
  [N111Bin{"root",N111U64{},"ult",N111Local{"a"},N111Local{"b"}},
   N111If{N111Local{"root"},
     [N111Set{"wide",N111U64{},N111Const{Bool.to_u32(Bool.not(invert)),0}}],
     [N111Set{"wide",N111U64{},N111Const{Bool.to_u32(invert),0}}]},
   N111Set{"copy",N111U64{},N111Local{"wide"}}]

@unsafe
def p123pt_case(+which: U32) -> List<&2,N111Stmt>:
  nt_append(N111Stmt,p123pt_transport(U32.is_eq(which,1)),
    nt_append(N111Stmt,
      nt_choose(List<&2,N111Stmt>,U32.is_eq(which,2),
        u => [N111Set{"root",N111U32{},N111Const{0,0}}],u =>
      nt_choose(List<&2,N111Stmt>,U32.is_eq(which,3),
        v => [N111Set{"copy",N111U64{},N111Local{"a"}}],v =>
      nt_choose(List<&2,N111Stmt>,U32.is_eq(which,4),
        w => [N111If{N111Local{"root"},[N111Set{"copy",N111U64{},N111Local{"a"}}],[N111Set{"copy",N111U64{},N111Local{"b"}}]}],w => []))),
      [N111Bin{"test",N111U64{},"eq",N111Local{"copy"},N111Const{1,nt_choose(U32,U32.is_eq(which,5),u => 1,u => 0)}}]))

@unsafe
def p123pt_kind(stmt: N111Stmt) -> String:
  match stmt:
    case N111Set{_,N111U32{},N111Local{"root"}}: "copy-root-u32"
    case N111Bin{_,N111U32{},"xor",N111Local{"root"},N111Const{1,0}}: "invert-root-u32"
    case N111Bin{_,N111U64{},"eq",_,_}: "original-u64-compare"
    case _: "other"

@unsafe
def p123pt_last(body: List<&2,N111Stmt>) -> String:
  match body:
    case Con{stmt,Nil{}}: p123pt_kind(stmt)
    case Con{stmt,rest}: p123pt_last(rest)
    case Nil{}: "empty"

@unsafe
def p123pt_result(scan: P113KScalar) -> String:
  match scan:
    case P113KScalar{body,facts}: p123pt_last(body)

@unsafe
def p123pt_function(which: U32) -> P113DFunction:
  P113DFunction{"predicate_control",[NC_Binding{0,"a",N_W64{}},NC_Binding{1,"b",N_W64{}}],1,False{},
    nt_append(P113DStmt,p113d_scalars(p123pt_case(which)),
      [P113DIf{N111Local{"test"},[P113DResult{[N111Const{1,0}]}],[P113DResult{[N111Const{0,0}]}]}])}

@unsafe
def p123pt_verify(+which: U32) -> Bool:
  String.is_empty(p113e_function(p123pt_function(which),N111Ids{missing(),missing()},missing())) &&
    String.is_empty(p113e_function(p113k_function(p123pt_function(which)),N111Ids{missing(),missing()},missing()))

@unsafe
def p123pt_row(+label: String, ok: Bool) -> String:
  nt_choose(String,ok,u => "PASS " ++ label,u => "FAIL " ++ label)

@unsafe
def p123_predicate_controls() -> List<&2,String>:
  [p123pt_row("comparison-diamond-copy-eq1",String.eq(p123pt_result(p113k_scalars(p123pt_case(0),missing())),"copy-root-u32")),
   p123pt_row("inverted-diamond-copy-eq1",String.eq(p123pt_result(p113k_scalars(p123pt_case(1),missing())),"invert-root-u32")),
   p123pt_row("root-overwrite-refused",String.eq(p123pt_result(p113k_scalars(p123pt_case(2),missing())),"original-u64-compare")),
   p123pt_row("unknown-value-refused",String.eq(p123pt_result(p113k_scalars(p123pt_case(3),missing())),"original-u64-compare")),
   p123pt_row("branch-unknown-refused",String.eq(p123pt_result(p113k_scalars(p123pt_case(4),missing())),"original-u64-compare")),
   p123pt_row("nonzero-high-constant-refused",Bool.not(String.eq(p123pt_result(p113k_scalars(p123pt_case(5),missing())),"copy-root-u32"))),
   p123pt_row("whole-function-original-and-after-verifies",p123pt_verify(0) && p123pt_verify(1) && p123pt_verify(2) && p123pt_verify(3) && p123pt_verify(4) && p123pt_verify(5))]

# Export ordinary before/after IR for an independent finite arithmetic oracle.
@unsafe
def p123pt_body(result: P113KScalar) -> List<&2,N111Stmt>:
  match result:
    case P113KScalar{body,facts}: body

@unsafe
def p123pt_after(which: U32) -> List<&2,N111Stmt>:
  p123pt_body(p113k_scalars(p123pt_case(which),missing()))
