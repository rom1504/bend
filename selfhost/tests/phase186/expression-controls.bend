# Isolate expression reuse from copy/facts/DCE and force ordinary frame placement.
# The source and transformed IR are independently passed through the same verifier.
@unsafe
def p186ce_result(a: String, b: String, c: String, d: String) -> P113DStmt:
  P113DResult{[p186_v(a),p186_v(b),p186_v(c),p186_v(d)]}

def p186ce_function(name: String, body: List<&2,P113DStmt>) -> P113DFunction:
  P113DFunction{name,p186_params(["a","b"],0),4,False{},body}

def p186ce_simple() -> P113DFunction:
  p186ce_function("p186ea",[p186_bin("x","add",p186_v("a"),p186_v("b")),p186_bin("y","add",p186_v("a"),p186_v("b")),
    p186_bin("z","mul",p186_v("a"),p186_v("b")),p186_bin("w","mul",p186_v("a"),p186_v("b")),p186ce_result("x","y","z","w")])

def p186ce_source() -> P113DFunction:
  p186ce_function("p186eb",[p186_bin("x","add",p186_v("a"),p186_v("b")),p186_bin("a","add",p186_v("a"),N111Const{1,0}),
    p186_bin("y","add",p186_v("a"),p186_v("b")),p186ce_result("x","y","a","b")])

def p186ce_overwrite() -> P113DFunction:
  p186ce_function("p186ec",[p186_bin("x","add",p186_v("a"),p186_v("b")),p186_set("x",p186_v("b")),
    p186_bin("y","add",p186_v("a"),p186_v("b")),p186ce_result("x","y","a","b")])

def p186ce_snapshot() -> P113DFunction:
  p186ce_function("p186ed",[p186_set("x",p186_v("a")),p186_set("a",p186_v("b")),
    p186_bin("y","add",p186_v("x"),N111Const{1,0}),p186_bin("z","add",p186_v("a"),N111Const{1,0}),p186ce_result("x","a","y","z")])

def p186ce_updates() -> P113DFunction:
  p186ce_function("p186ee",[p186_set("x",p186_v("a")),p186_bin("x","add",p186_v("x"),N111Const{1,0}),
    p186_bin("x","add",p186_v("x"),N111Const{1,0}),p186_bin("y","add",p186_v("a"),N111Const{1,0}),
    p186_bin("z","add",p186_v("a"),N111Const{1,0}),p186ce_result("x","y","z","a")])

def p186ce_aliases() -> P113DFunction:
  p186ce_function("p186ef",[p186_set("x",p186_v("a")),p186_bin("x","and",p186_v("x"),N111Const{4294967295,0}),
    p186_set("y",p186_v("a")),p186_bin("y","and",p186_v("y"),N111Const{4294967295,0}),
    p186_bin("z","mul",p186_v("x"),N111Const{4,0}),p186_bin("w","mul",p186_v("y"),N111Const{4,0}),p186ce_result("x","y","z","w")])

@unsafe
def p186ce_widen(names: List<&2,String>) -> List<&2,P113DStmt>:
  match names:
    case Nil{}: []
    case Con{+name,rest}:
      Con{p186_store("scratch",128,N111Const{0,0}),Con{P113DScalar{N111Store{N111U32{},p186_v("scratch"),128,p186_v(name)}},
        Con{p186_load("wide_" ++ name,"scratch",128),p186ce_widen(rest)}}}

@unsafe
def p186ce_comparisons() -> P113DFunction:
  p186ce_function("p186eg",nt_append(P113DStmt,
    [p186_bin("x","eq",p186_v("a"),p186_v("b")),p186_bin("y","eq",p186_v("a"),p186_v("b")),
     p186_bin("z","slt",p186_v("a"),p186_v("b")),p186_bin("w","slt",p186_v("a"),p186_v("b"))],
    nt_append(P113DStmt,p186ce_widen(["x","y","z","w"]),[p186ce_result("wide_x","wide_y","wide_z","wide_w")])))

def p186ce_shifts() -> P113DFunction:
  p186ce_function("p186eh",[p186_bin("x","shl",p186_v("a"),p186_v("b")),p186_bin("y","shl",p186_v("a"),p186_v("b")),
    p186_bin("z","shr",p186_v("a"),p186_v("b")),p186_bin("w","shr",p186_v("a"),p186_v("b")),p186ce_result("x","y","z","w")])

def p186ce_store() -> P113DFunction:
  p186ce_function("p186ei",[p186_bin("x","add",p186_v("a"),p186_v("b")),p186_store("scratch",0,p186_v("a")),
    p186_bin("y","add",p186_v("a"),p186_v("b")),p186_load("a","scratch",0),
    p186_bin("z","add",p186_v("a"),p186_v("b")),p186ce_result("x","y","z","a")])

def p186ce_call() -> P113DFunction:
  p186ce_function("p186ej",[p186_store("scratch",0,p186_v("a")),p186_bin("x","add",p186_v("a"),p186_v("b")),
    P113DScalar{p112fp_control_call(N111Const{36,0},N111Const{1,0},"scratch")},
    p186_bin("y","add",p186_v("a"),p186_v("b")),p186ce_result("x","y","result","a")])

def p186ce_branch() -> P113DFunction:
  p186ce_function("p186ek",[p186_bin("x","add",p186_v("a"),p186_v("b")),p186_bin("zero","eq",p186_v("a"),N111Const{0,0}),
    P113DIf{p186_v("zero"),[p186_bin("y","add",p186_v("a"),p186_v("b")),p186ce_result("x","y","a","b")],
      [p186_bin("y","add",p186_v("a"),p186_v("b")),p186ce_result("x","y","a","b")]}])

@unsafe
def p186ce_words() -> P113DFunction:
  p186ce_function("p186el",nt_append(P113DStmt,
    [p186_store("scratch",0,p186_v("a")),p186_store("scratch",8,p186_v("b")),
     P113DScalar{N111Load{"left",N111U32{},p186_v("scratch"),0}},P113DScalar{N111Load{"right",N111U32{},p186_v("scratch"),8}},
     P113DScalar{N111Bin{"x",N111U32{},"add",p186_v("left"),p186_v("right")}},
     P113DScalar{N111Bin{"y",N111U32{},"add",p186_v("left"),p186_v("right")}},
     P113DScalar{N111Bin{"z",N111U32{},"shl",p186_v("left"),p186_v("right")}},
     P113DScalar{N111Bin{"w",N111U32{},"shl",p186_v("left"),p186_v("right")}}],
    nt_append(P113DStmt,p186ce_widen(["x","y","z","w"]),[p186ce_result("wide_x","wide_y","wide_z","wide_w")])))

def p186ce_offset() -> N111Segment:
  N111Segment{"p186em",0,1,0,0,[N111Alloca{"buffer",16,8},N111Load{"a",N111U64{},p186_v("state"),0},
    N111Store{N111U64{},p186_v("buffer"),8,p186_v("a")},N111Offset{"p",p186_v("buffer"),N111Const{8,0}},
    N111Offset{"q",p186_v("buffer"),N111Const{8,0}},N111Load{"x",N111U64{},p186_v("q"),0},N111Return{p186_v("x")} ]}

def p186ce_load() -> P113DFunction:
  p186ce_function("p186en",[p186_store("scratch",0,p186_v("b")),p186_bin("x","add",p186_v("a"),p186_v("b")),
    p186_load("z","scratch",0),p186_bin("y","add",p186_v("a"),p186_v("b")),p186ce_result("x","y","z","a")])

def p186ce_self_hit() -> P113DFunction:
  p186ce_function("p186eo",[p186_bin("x","add",p186_v("a"),p186_v("b")),p186_bin("x","add",p186_v("a"),p186_v("b")),
    p186_set("y",p186_v("x")),p186ce_result("x","y","a","b")])

def p186ce_functions() -> List<&2,P113DFunction>:
  [p186ce_simple(),p186ce_source(),p186ce_overwrite(),p186ce_snapshot(),p186ce_updates(),p186ce_aliases(),
   p186ce_comparisons(),p186ce_shifts(),p186ce_store(),p186ce_call(),p186ce_branch(),p186ce_words(),p186ce_load(),p186ce_self_hit()]

@unsafe
def p186ce_candidate(function: P113DFunction) -> P113DFunction:
  match function:
    case P113DFunction{name,params,result,public,body}: P113DFunction{name,params,result,public,x186_expression_body([],body)}

@unsafe
def p186ce_candidates(functions: List<&2,P113DFunction>) -> List<&2,P113DFunction>:
  match functions:
    case Nil{}: []
    case Con{head,rest}: Con{p186ce_candidate(head),p186ce_candidates(rest)}

@unsafe
def p186ce_scalars(body: List<&2,P113DStmt>) -> List<&2,N111Stmt>:
  match body:
    case Nil{}: []
    case Con{P113DScalar{stmt},rest}: Con{stmt,p186ce_scalars(rest)}
    case Con{head,rest}: p186ce_scalars(rest)

@unsafe
def p186ce_offset_candidate(segment: N111Segment) -> N111Segment:
  match segment:
    case N111Segment{name,arity,result,incoming,flags,body}:
      N111Segment{name,arity,result,incoming,flags,p186ce_scalars(x186_expression_body([],x181_scalar_rows(body)))}

@unsafe
def p186ce_validate() -> String:
  p111_first(p111v_segment(p186ce_offset(),N111Ids{missing(),missing()}),
    p111_first(p111v_segment(p186ce_offset_candidate(p186ce_offset()),N111Ids{missing(),missing()}),p111_first(p113e_functions(p186ce_functions(),N111Ids{missing(),missing()},missing()),
      p113e_functions(p186ce_candidates(p186ce_functions()),N111Ids{missing(),missing()},missing()))))

@unsafe
def p186ce_emit_one(function: P113DFunction) -> X181Output:
  match function:
    case P113DFunction{name,params,result,public,body}:
      +words: List<&2,String> = ["state","__x181_result_out","a","b"]
      x185_function_copied(p113e_symbol(name),words,[],x186_expression_body([],body),N111Ids{missing(),missing()})

@unsafe
def p186ce_emit_functions(functions: List<&2,P113DFunction>) -> X181Output:
  match functions:
    case Nil{}: X181Output{[],""}
    case Con{head,rest}: x181_program_join(p186ce_emit_one(head),p186ce_emit_functions(rest))

@unsafe
def p186ce_emit_offset(segment: N111Segment) -> X181Output:
  match segment:
    case N111Segment{name,arity,result,incoming,flags,body}:
      x185_function_copied(p111q_symbol(name),["state"],[],x186_expression_body([],x181_scalar_rows(body)),N111Ids{missing(),missing()})

@unsafe
def p186ce_emit() -> X181Output:
  x181_program_join(p186ce_emit_functions(p186ce_functions()),p186ce_emit_offset(p186ce_offset()))

law p186ce_bins:
  for body: List<&2,P113DStmt>
  U32

@unsafe
def p186ce_bins(body):
  match body:
    case Nil{}: 0
    case Con{P113DScalar{N111Bin{name,typ,op,left,right}},rest}: U32.inc(p186ce_bins(rest))
    case Con{P113DIf{condition,yes,no},rest}: U32.add(p186ce_bins(yes),U32.add(p186ce_bins(no),p186ce_bins(rest)))
    case Con{head,rest}: p186ce_bins(rest)

@unsafe
def p186ce_count(function: P113DFunction) -> U32:
  match function:
    case P113DFunction{name,params,result,public,body}: p186ce_bins(x186_expression_body([],body))

@unsafe
def p186ce_comparison_copy(body: List<&2,P113DStmt>) -> Bool:
  match body:
    case Nil{}: False{}
    case Con{P113DScalar{N111Set{name,N111U32{},N111Local{source}}},rest}: True{}
    case Con{head,rest}: p186ce_comparison_copy(rest)

@unsafe
def p186ce_comparison_width(function: P113DFunction) -> Bool:
  match function:
    case P113DFunction{name,params,result,public,body}: p186ce_comparison_copy(x186_expression_body([],body))

@unsafe
def p186ce_bound(+n: U32) -> List<&2,P113DStmt>:
  nt_choose(List<&2,P113DStmt>,U32.is_eq(n,0),u => [],
    u => Con{p186_bin("v" ++ U32.show(n),"add",p186_v("a"),p186_v("b")),p186ce_bound(U32.sub(n,1))})

@unsafe
def p186ce_controls() -> List<&2,String>:
  [p186pm_row("verified",String.is_empty(p186ce_validate())),
   p186pm_row("duplicate-bin",U32.is_eq(p186ce_count(p186ce_simple()),2)),
   p186pm_row("source-write",U32.is_eq(p186ce_count(p186ce_source()),3)),
   p186pm_row("result-write",U32.is_eq(p186ce_count(p186ce_overwrite()),2)),
   p186pm_row("snapshot-write",U32.is_eq(p186ce_count(p186ce_snapshot()),2)),
   p186pm_row("self-updates",U32.is_eq(p186ce_count(p186ce_updates()),3)),
   p186pm_row("alias-mask-address",U32.is_eq(p186ce_count(p186ce_aliases()),2)),
   p186pm_row("comparison-width",p186ce_comparison_width(p186ce_comparisons())),
   p186pm_row("variable-shifts",U32.is_eq(p186ce_count(p186ce_shifts()),2)),
   p186pm_row("store-load-barrier",U32.is_eq(p186ce_count(p186ce_store()),3)),
   p186pm_row("unknown-call-barrier",U32.is_eq(p186ce_count(p186ce_call()),2)),
   p186pm_row("branch-barrier",U32.is_eq(p186ce_count(p186ce_branch()),4)),
   p186pm_row("u32-operations",U32.is_eq(p186ce_count(p186ce_words()),2)),
   p186pm_row("load-preserves-pure-fact",U32.is_eq(p186ce_count(p186ce_load()),1)),
   p186pm_row("self-hit",U32.is_eq(p186ce_count(p186ce_self_hit()),1)),
   p186pm_row("offset-capacity-preserved",String.is_empty(p111v_segment(p186ce_offset_candidate(p186ce_offset()),N111Ids{missing(),missing()}))),
   p186pm_row("bound-refusal",U32.is_eq(p186ce_bins(x186_expression_body([],p186ce_bound(4096))),4096))]
