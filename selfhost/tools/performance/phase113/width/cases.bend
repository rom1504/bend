# Small original verified functions for native raw-word observations. A host
# transport may enumerate these records; it must not synthesize their bodies.
def p113wt_op(which: U32) -> String:
  match which:
    case 0: "add"
    case 1: "sub"
    case 2: "mul"
    case 3: "and"
    case 4: "or"
    case _: "xor"

@unsafe
def p113wt_case_body(+which: U32) -> List<&2,P113DStmt>:
  +a : N111Value = N111Local{"a"}
  +b : N111Value = N111Local{"b"}
  +value : N111Value = N111Local{"value"}
  +mask : P113DStmt = p113wt_mask("value","value",4294967295,0)
  nt_choose(List<&2,P113DStmt>,U32.is_lt(which,6),u =>
    [p113wt_first(p113wt_op(which)),mask,P113DResult{[value]}],u =>
  nt_choose(List<&2,P113DStmt>,U32.is_eq(which,6),u =>
    [p113wt_mask("value","a",4294967295,0),P113DResult{[value]}],u =>
  nt_choose(List<&2,P113DStmt>,U32.is_eq(which,7),u =>
    [P113DScalar{N111Bin{"a",N111U64{},"add",a,b}},p113wt_mask("a","a",4294967295,0),P113DResult{[a]}],u =>
  nt_choose(List<&2,P113DStmt>,U32.is_eq(which,8),u =>
    [P113DScalar{N111Bin{"a",N111U64{},"mul",a,a}},p113wt_mask("a","a",4294967295,0),P113DResult{[a]}],u =>
  nt_choose(List<&2,P113DStmt>,U32.is_eq(which,9),u =>
    [p113wt_first("add"),p113wt_mask("other","value",4294967295,0),P113DResult{[value]}],u =>
  nt_choose(List<&2,P113DStmt>,U32.is_eq(which,10),u =>
    [P113DScalar{N111Bin{"value",N111U64{},"shr",a,N111Const{32,0}}},mask,P113DResult{[value]}],u =>
  nt_choose(List<&2,P113DStmt>,U32.is_eq(which,11),u =>
    [P113DScalar{N111Bin{"value",N111U64{},"shl",a,N111Const{40,0}}},mask,P113DResult{[value]}],u =>
  nt_choose(List<&2,P113DStmt>,U32.is_eq(which,12),u =>
    [p113wt_first("add"),P113DScalar{N111Set{"saved",N111U64{},value}},mask,P113DResult{[N111Local{"saved"}]}],u =>
  nt_choose(List<&2,P113DStmt>,U32.is_eq(which,13),u =>
    [p113wt_first("add"),p113wt_mask("value","value",4294967294,0),P113DResult{[value]}],u =>
  nt_choose(List<&2,P113DStmt>,U32.is_eq(which,14),u =>
    [p113wt_first("add"),p113wt_mask("value","value",4294967295,1),P113DResult{[value]}],u =>
    [p113wt_first("mul"),mask,P113DScalar{N111Bin{"upper",N111U64{},"shr",value,N111Const{40,0}}},P113DResult{[N111Local{"upper"}]}]))))))))))

@unsafe
def p113_width_function(which: U32) -> P113DFunction:
  P113DFunction{"p113_width_case_" ++ U32.show(which),[NC_Binding{0,"a",N_W64{}},NC_Binding{1,"b",N_W64{}}],1,False{},p113wt_case_body(which)}

@unsafe
def p113_width_case_error(which: U32) -> String:
  p113e_function(p113_width_function(which),N111Ids{missing(),missing()},missing())

@unsafe
def p113_width_case_qbe(+which: U32) -> String:
  nt_choose(String,String.is_empty(p113_width_case_error(which)),
    u => "export " ++ p113e_private(p113_width_function(which),N111Ids{missing(),missing()}),
    u => "INVALID_WIDTH_CONTROL\n")
