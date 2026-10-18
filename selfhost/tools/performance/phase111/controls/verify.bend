# Structural-verifier fixtures only. Minimal descriptors deliberately omit the
# production runtime's constructor catalogue: these programs must NOT execute.
# Export p111_verify_controls from the ordinary checked library bridge.
def p111vc_program(body: List<&2,N111Stmt>) -> P111Program:
  P111Program{[N111Segment{"main",0,1,0,0,body}],[],[],[],[],True{}}

def p111vc_segments(segments: List<&2,N111Segment>) -> P111Program:
  P111Program{segments,[],[],[],[],True{}}

def p111vc_return() -> N111Stmt:
  N111Return{N111Const{0,0}}

def p111vc_state() -> N111Arg:
  N111Arg{N111Ptr{},N111Local{"state"}}

def p111vc_word(value: U32) -> N111Arg:
  N111Arg{N111U64{},N111Const{value,0}}

def p111vc_count(value: U32) -> N111Arg:
  N111Arg{N111U32{},N111Const{value,0}}

def p111vc_scratch() -> N111Arg:
  N111Arg{N111Ptr{},N111Local{"scratch"}}

def p111vc_alloca() -> N111Stmt:
  N111Alloca{"scratch",2048,8}

@unsafe
def p111vc_case(name: String, +valid: Bool, program: P111Program) -> String:
  +error = p111_verify_program(program)
  name ++ "|" ++ nt_choose(String,nt_choose(Bool,valid,v => String.is_empty(error),v => Bool.not(String.is_empty(error))),u => "PASS",u => "FAIL") ++ "|" ++ error ++ "\n"

@unsafe
def p111vc_lines(lines: List<&2,String>) -> String:
  match lines:
    case Nil{}: ""
    case Con{head,rest}: head ++ p111vc_lines(rest)

@unsafe
def p111_verify_controls() -> String:
  p111vc_lines([
    p111vc_case("positive-return",True{},p111vc_program([p111vc_return()])),
    p111vc_case("positive-assigned",True{},p111vc_program([N111Set{"x",N111U64{},N111Const{7,0}},N111Return{N111Local{"x"}}])),
    p111vc_case("positive-mutable",True{},p111vc_program([N111Set{"x",N111U64{},N111Const{7,0}},N111Set{"x",N111U64{},N111Const{8,0}},N111Return{N111Local{"x"}}])),
    p111vc_case("positive-branch-join",True{},p111vc_program([N111If{N111Const{1,0},[N111Set{"x",N111U64{},N111Const{7,0}}],[N111Set{"x",N111U64{},N111Const{8,0}}]},N111Return{N111Local{"x"}}])),
    p111vc_case("positive-terminal-join",True{},p111vc_program([N111If{N111Const{1,0},[p111vc_return()],[N111Set{"x",N111U64{},N111Const{8,0}}]},N111Return{N111Local{"x"}}])),
    p111vc_case("positive-both-terminal",True{},p111vc_program([N111If{N111Const{1,0},[p111vc_return()],[p111vc_return()]}])),
    p111vc_case("positive-comparison",True{},p111vc_program([N111Bin{"condition",N111U64{},"ult",N111Const{0,0},N111Const{1,0}},N111If{N111Local{"condition"},[p111vc_return()],[p111vc_return()]}])),
    p111vc_case("positive-scratch",True{},p111vc_program([p111vc_alloca(),N111Store{N111U64{},N111Local{"scratch"},2040,N111Const{4,0}},N111Load{"x",N111U64{},N111Local{"scratch"},2040},N111Return{N111Local{"x"}}])),
    p111vc_case("positive-runtime-call",True{},p111vc_program([N111Call{"x",N111U64{},"p111_rt_keep",[p111vc_state(),p111vc_word(0)]},N111Return{N111Local{"x"}}])),
    p111vc_case("positive-primitive",True{},p111vc_program([p111vc_alloca(),N111Call{"x",N111U64{},"p111_rt_op",[p111vc_state(),p111vc_count(1),p111vc_scratch(),p111vc_count(2)]},N111Return{N111Local{"x"}}])),
    p111vc_case("positive-frame-incoming",True{},p111vc_segments([N111Segment{"main",0,1,0,0,[p111vc_alloca(),N111Call{"x",N111U64{},"p111_rt_frame",[p111vc_state(),N111Arg{N111U32{},N111FuncId{"continuation"}},p111vc_scratch(),p111vc_count(0)]},p111vc_return()]},N111Segment{"continuation",1,1,1,0,[N111Call{"x",N111U64{},"p111_rt_reg_get",[p111vc_state(),p111vc_count(0)]},N111Return{N111Local{"x"}}]}])),
    p111vc_case("negative-undefined-local",False{},p111vc_program([N111Return{N111Local{"x"}}])),
    p111vc_case("negative-use-before-set",False{},p111vc_program([N111Set{"x",N111U64{},N111Local{"x"}},N111Return{N111Local{"x"}}])),
    p111vc_case("negative-local-width",False{},p111vc_program([N111Set{"x",N111U64{},N111Const{0,0}},N111Set{"x",N111U32{},N111Const{0,0}},p111vc_return()])),
    p111vc_case("negative-branch-local",False{},p111vc_program([N111If{N111Const{1,0},[N111Set{"x",N111U64{},N111Const{7,0}}],[]},N111Return{N111Local{"x"}}])),
    p111vc_case("negative-width-branch",False{},p111vc_program([N111If{N111Const{1,0},[N111Set{"x",N111U32{},N111Const{7,0}}],[N111Set{"x",N111U64{},N111Const{8,0}}]},p111vc_return()])),
    p111vc_case("negative-missing-terminal",False{},p111vc_program([])),
    p111vc_case("negative-partial-terminal",False{},p111vc_program([N111If{N111Const{1,0},[p111vc_return()],[]}])),
    p111vc_case("negative-after-return",False{},p111vc_program([p111vc_return(),p111vc_return()])),
    p111vc_case("negative-condition-width",False{},p111vc_program([N111Set{"x",N111U64{},N111Const{1,0}},N111If{N111Local{"x"},[p111vc_return()],[p111vc_return()]}])),
    p111vc_case("negative-state-write",False{},p111vc_program([N111Set{"state",N111Ptr{},N111Const{0,0}},p111vc_return()])),
    p111vc_case("negative-local-token",False{},p111vc_program([N111Set{"x y",N111U64{},N111Const{0,0}},p111vc_return()])),
    p111vc_case("negative-symbol",False{},p111vc_program([N111Set{"x",N111Ptr{},N111Symbol{"foreign"}},p111vc_return()])),
    p111vc_case("negative-unknown-fid",False{},p111vc_program([N111Set{"x",N111U64{},N111FuncId{"absent"}},p111vc_return()])),
    p111vc_case("negative-unknown-cid",False{},p111vc_program([N111Set{"x",N111U64{},N111CtorId{"absent"}},p111vc_return()])),
    p111vc_case("negative-unknown-import",False{},p111vc_program([N111Call{"x",N111U64{},"malloc",[p111vc_state()]},p111vc_return()])),
    p111vc_case("negative-import-arity",False{},p111vc_program([N111Call{"x",N111U64{},"p111_rt_keep",[p111vc_state()]},p111vc_return()])),
    p111vc_case("negative-import-width",False{},p111vc_program([N111Call{"x",N111U64{},"p111_rt_keep",[p111vc_state(),p111vc_count(0)]},p111vc_return()])),
    p111vc_case("negative-import-result",False{},p111vc_program([N111Call{"x",N111U32{},"p111_rt_keep",[p111vc_state(),p111vc_word(0)]},p111vc_return()])),
    p111vc_case("negative-null-state",False{},p111vc_program([N111Call{"x",N111U64{},"p111_rt_keep",[N111Arg{N111Ptr{},N111Const{0,0}},p111vc_word(0)]},p111vc_return()])),
    p111vc_case("negative-primitive-count",False{},p111vc_program([p111vc_alloca(),N111Call{"x",N111U64{},"p111_rt_op",[p111vc_state(),p111vc_count(1),p111vc_scratch(),p111vc_count(1)]},p111vc_return()])),
    p111vc_case("negative-primitive-id",False{},p111vc_program([p111vc_alloca(),N111Call{"x",N111U64{},"p111_rt_op",[p111vc_state(),p111vc_count(86),p111vc_scratch(),p111vc_count(0)]},p111vc_return()])),
    p111vc_case("negative-import-capacity",False{},p111vc_program([N111Alloca{"scratch",8,8},N111Call{"x",N111U64{},"p111_rt_op",[p111vc_state(),p111vc_count(1),p111vc_scratch(),p111vc_count(2)]},p111vc_return()])),
    p111vc_case("negative-return-count",False{},p111vc_program([p111vc_alloca(),N111Call{"x",N111U64{},"p111_rt_return",[p111vc_state(),p111vc_scratch(),p111vc_count(2)]},p111vc_return()])),
    p111vc_case("negative-register-bound",False{},p111vc_program([N111Call{"x",N111U64{},"p111_rt_reg_get",[p111vc_state(),p111vc_count(0)]},p111vc_return()])),
    p111vc_case("negative-stack-on-direct",False{},p111vc_program([N111Call{"x",N111U64{},"p111_rt_stack_pop",[p111vc_state(),p111vc_count(0)]},p111vc_return()])),
    p111vc_case("negative-load-capacity",False{},p111vc_program([N111Alloca{"scratch",8,8},N111Load{"x",N111U64{},N111Local{"scratch"},8},p111vc_return()])),
    p111vc_case("negative-load-alignment",False{},p111vc_program([N111Alloca{"scratch",16,8},N111Load{"x",N111U64{},N111Local{"scratch"},1},p111vc_return()])),
    p111vc_case("negative-store-capacity",False{},p111vc_program([N111Alloca{"scratch",8,8},N111Store{N111U64{},N111Local{"scratch"},8,N111Const{0,0}},p111vc_return()])),
    p111vc_case("negative-offset-capacity",False{},p111vc_program([N111Alloca{"scratch",8,8},N111Offset{"ptr",N111Local{"scratch"},N111Const{16,0}},p111vc_return()])),
    p111vc_case("negative-alloca-repeat",False{},p111vc_program([p111vc_alloca(),p111vc_alloca(),p111vc_return()])),
    p111vc_case("negative-alloca-size",False{},p111vc_program([N111Alloca{"scratch",2049,8},p111vc_return()])),
    p111vc_case("negative-alloca-align",False{},p111vc_program([N111Alloca{"scratch",8,2},p111vc_return()])),
    p111vc_case("negative-opcode",False{},p111vc_program([N111Bin{"x",N111U64{},"division",N111Const{0,0},N111Const{1,0}},p111vc_return()])),
    p111vc_case("negative-truncated-u32",False{},p111vc_program([N111Set{"x",N111U32{},N111Const{0,1}},p111vc_return()])),
    p111vc_case("negative-missing-main",False{},p111vc_segments([N111Segment{"other",0,1,0,0,[p111vc_return()]}])),
    p111vc_case("negative-duplicate-segment",False{},p111vc_segments([N111Segment{"main",0,1,0,0,[p111vc_return()]},N111Segment{"main",0,1,0,0,[p111vc_return()]}])),
    p111vc_case("negative-main-arity",False{},p111vc_segments([N111Segment{"main",1,1,0,0,[p111vc_return()]}])),
    p111vc_case("negative-arity-capacity",False{},p111vc_segments([N111Segment{"main",0,1,0,0,[p111vc_return()]},N111Segment{"other",256,1,0,0,[p111vc_return()]}])),
    p111vc_case("negative-incoming-capacity",False{},p111vc_segments([N111Segment{"main",0,1,0,0,[p111vc_return()]},N111Segment{"other",0,1,1,0,[p111vc_return()]}])),
    p111vc_case("negative-result-capacity",False{},p111vc_segments([N111Segment{"main",0,256,0,0,[p111vc_return()]}])),
    p111vc_case("negative-duplicate-ctor",False{},P111Program{[N111Segment{"main",0,1,0,0,[p111vc_return()]}],[N_Constructor{"Ctor",0,False{}},N_Constructor{"Ctor",0,False{}}],[],[],[],True{}}),
    p111vc_case("negative-ctor-capacity",False{},P111Program{[N111Segment{"main",0,1,0,0,[p111vc_return()]}],[N_Constructor{"Ctor",256,False{}}],[],[],[],True{}})
  ])
