# Finite compiler-data controls. Append to the checked js-api source and export
# p185fc_controls. Malformed calls are data only; none execute the runtime.

def p185fc_args(id: N111Value, count: N111Value) -> List<&2,N111Arg>:
  [p111_state(),N111Arg{N111U32{},id},p111_scratch(),N111Arg{N111U32{},count}]

def p185fc_call(id: U32, count: U32) -> N111Stmt:
  N111Call{"answer",N111U64{},"p111_rt_op",p185fc_args(N111Const{id,0},N111Const{count,0})}

@unsafe
def p185fc_bound(typ: N111Type, symbol: String, args: List<&2,N111Arg>, +expected: U32) -> Bool:
  p185fc_bound_result(p185k_call_fact(typ,symbol,args),expected)

@unsafe
def p185fc_bound_result(fact: P113KFact, expected: U32) -> Bool:
  match fact:
    case P113KFact{bits,exact,lo,hi}:
      U32.is_eq(bits,expected) && Bool.not(exact) && U32.is_eq(lo,0) && U32.is_eq(hi,0)

@unsafe
def p185fc_ids(ids: List<&2,U32>, +count: U32, +expected: U32) -> Bool:
  match ids:
    case Nil{}: True{}
    case Con{id,rest}:
      p185fc_bound(N111U64{},"p111_rt_op",p185fc_args(N111Const{id,0},N111Const{count,0}),expected) &&
        p185fc_ids(rest,count,expected)

@unsafe
def p185fc_facts(body: List<&2,N111Stmt>) -> KDef:
  p185fc_facts_result(p113k_scalars(body,missing()))

def p185fc_facts_result(result: P113KScalar) -> KDef:
  match result:
    case P113KScalar{body,facts}: facts

@unsafe
def p185fc_bits(body: List<&2,N111Stmt>, name: String, expected: U32) -> Bool:
  U32.is_eq(p113k_bits_of(p113k_get(p185fc_facts(body),name)),expected)

# Exercise the existing raw-or-packed Bool lowering, including its CID bits.
# Only the raw comparison remains; the packed test becomes an exact false.
@unsafe
def p185fc_packed() -> Bool:
  p185fc_packed_result(p113k_scalars(Con{p185fc_call(32,2),p112_special_bool(N111Local{"answer"},False{})},missing()))

@unsafe
def p185fc_packed_result(result: P113KScalar) -> Bool:
  match result:
    case P113KScalar{
      Con{N111Call{name,N111U64{},symbol,args},
      Con{N111Bin{raw,N111U64{},rawop,N111Local{source},N111Const{1,0}},
      Con{N111Set{bits,N111U64{},N111Const{0,0}},
      Con{N111Set{bits2,N111U64{},N111Const{0,0}},
      Con{N111Bin{expected,N111U64{},expectedop,N111CtorId{ctor},N111Const{65536,0}},
      Con{N111Set{boxed,N111U32{},N111Const{0,0}},
      Con{N111Set{condition,N111U32{},N111Local{raw2}},Nil{}}}}}}}},facts}:
      String.eq(name,"answer") && String.eq(symbol,"p111_rt_op") && String.eq(source,"answer") &&
        String.eq(raw,"p112_b_raw") && String.eq(rawop,"eq") && String.eq(bits,"p112_b_bits") &&
        String.eq(bits2,"p112_b_bits") && String.eq(expected,"p112_b_expected") &&
        String.eq(expectedop,"or") && String.eq(ctor,"True") && String.eq(boxed,"p112_b_boxed") &&
        String.eq(condition,"match_condition") && String.eq(raw2,"p112_b_raw")
    case _: False{}

@unsafe
def p185fc_branches() -> Bool:
  p185fc_branches_result(p113k_scalars([p185fc_call(30,2),
    N111Bin{"condition",N111U64{},"eq",N111Local{"answer"},N111Const{1,0}},
    N111If{N111Local{"condition"},
      [N111Bin{"again",N111U64{},"eq",N111Local{"answer"},N111Const{1,0}}],
      [N111Bin{"again",N111U64{},"eq",N111Local{"answer"},N111Const{1,0}}]}],missing()))

@unsafe
def p185fc_branches_result(result: P113KScalar) -> Bool:
  match result:
    case P113KScalar{Con{call,Con{test,Con{N111If{condition,
      Con{N111Set{yes,N111U32{},N111Const{1,0}},Nil{}},
      Con{N111Set{no,N111U32{},N111Const{0,0}},Nil{}}},Nil{}}}},facts}:
      String.eq(yes,"again") && String.eq(no,"again")
    case _: False{}

@unsafe
def p185fc_direct_kill() -> Bool:
  p185fc_direct_kill_result(p113k_stmt(P113DCall{["answer"],"other",[]},p185fc_facts([p185fc_call(30,2)])))

@unsafe
def p185fc_direct_kill_result(result: P113KBody) -> Bool:
  match result:
    case P113KBody{body,facts,terminal}: U32.is_eq(p113k_bits_of(p113k_get(facts,"answer")),64)

@unsafe
def p185fc_verify(body: List<&2,P113DStmt>) -> Bool:
  String.is_empty(p113e_function(P113DFunction{"probe",[],1,False{},body},N111Ids{missing(),missing()},missing()))

@unsafe
def p185fc_verified() -> Bool:
  +body : List<&2,P113DStmt> = [P113DScalar{N111Store{N111U64{},N111Local{"scratch"},0,N111Const{1065353216,0}}},
    P113DScalar{N111Store{N111U64{},N111Local{"scratch"},8,N111Const{1073741824,0}}},
    P113DScalar{p185fc_call(32,2)},P113DResult{[N111Local{"answer"}]}]
  p185fc_verify(body) &&
    String.is_empty(p113e_function(p113k_function(P113DFunction{"probe",[],1,False{},body}),N111Ids{missing(),missing()},missing()))

@unsafe
def p185fc_controls() -> List<&2,String>:
  +good = p185fc_args(N111Const{30,0},N111Const{2,0})
  [p113ft_row("fact-all-binary-bools",p185fc_ids([7,8,9,10,11,12,30,31,32,33,34,35,67,68,69],2,1)),
   p113ft_row("fact-unary-is-zero",p185fc_ids([21],1,1)),
   p113ft_row("fact-other-opcodes-unknown",p185fc_ids([0,1,6,13,20,21,22,29,36,66,70,86,87,4294967295],2,64)),
   p113ft_row("fact-binary-wrong-arity",p185fc_ids([7,30,35,67,68,69],1,64)),
   p113ft_row("fact-zero-arity",p185fc_ids([21,30],0,64)),
   p113ft_row("fact-large-arity",p185fc_ids([21,30],256,64)),
   p113ft_row("fact-wrong-symbol",p185fc_bound(N111U64{},"p111_rt_special_ctor",good,64)),
   p113ft_row("fact-u32-result",p185fc_bound(N111U32{},"p111_rt_op",good,64)),
   p113ft_row("fact-pointer-result",p185fc_bound(N111Ptr{},"p111_rt_op",good,64)),
   p113ft_row("fact-high-id",p185fc_bound(N111U64{},"p111_rt_op",p185fc_args(N111Const{30,1},N111Const{2,0}),64)),
   p113ft_row("fact-high-count",p185fc_bound(N111U64{},"p111_rt_op",p185fc_args(N111Const{30,0},N111Const{2,1}),64)),
   p113ft_row("fact-dynamic-id",p185fc_bound(N111U64{},"p111_rt_op",p185fc_args(N111Local{"op"},N111Const{2,0}),64)),
   p113ft_row("fact-dynamic-count",p185fc_bound(N111U64{},"p111_rt_op",p185fc_args(N111Const{30,0},N111Local{"count"}),64)),
   p113ft_row("fact-exact-local-id-stays-conservative",p185fc_bits([N111Set{"op",N111U32{},N111Const{30,0}},
     N111Call{"answer",N111U64{},"p111_rt_op",p185fc_args(N111Local{"op"},N111Const{2,0})}],"answer",64)),
   p113ft_row("fact-constructor-id",p185fc_bound(N111U64{},"p111_rt_op",p185fc_args(N111CtorId{"True"},N111Const{2,0}),64)),
   p113ft_row("fact-state-identity",p185fc_bound(N111U64{},"p111_rt_op",[N111Arg{N111Ptr{},N111Local{"other"}},p111_u32(30),p111_scratch(),p111_u32(2)],64)),
   p113ft_row("fact-state-width",p185fc_bound(N111U64{},"p111_rt_op",[p111_word(N111Local{"state"}),p111_u32(30),p111_scratch(),p111_u32(2)],64)),
   p113ft_row("fact-id-width",p185fc_bound(N111U64{},"p111_rt_op",[p111_state(),p111_word(N111Const{30,0}),p111_scratch(),p111_u32(2)],64)),
   p113ft_row("fact-count-width",p185fc_bound(N111U64{},"p111_rt_op",[p111_state(),p111_u32(30),p111_scratch(),p111_word(N111Const{2,0})],64)),
   p113ft_row("fact-buffer-width",p185fc_bound(N111U64{},"p111_rt_op",[p111_state(),p111_u32(30),p111_word(N111Local{"scratch"}),p111_u32(2)],64)),
   p113ft_row("fact-buffer-null",p185fc_bound(N111U64{},"p111_rt_op",[p111_state(),p111_u32(30),N111Arg{N111Ptr{},N111Const{0,0}},p111_u32(2)],64)),
   p113ft_row("fact-buffer-state",p185fc_bound(N111U64{},"p111_rt_op",[p111_state(),p111_u32(30),p111_state(),p111_u32(2)],64)),
   p113ft_row("fact-buffer-unknown",p185fc_bound(N111U64{},"p111_rt_op",[p111_state(),p111_u32(30),N111Arg{N111Ptr{},N111Local{"custom"}},p111_u32(2)],64)),
   p113ft_row("fact-missing-argument",p185fc_bound(N111U64{},"p111_rt_op",[p111_state(),p111_u32(30),p111_scratch()],64)),
   p113ft_row("fact-extra-argument",p185fc_bound(N111U64{},"p111_rt_op",nt_append(N111Arg,good,[p111_u32(0)]),64)),
   p113ft_row("fact-packed-test-folded",p185fc_packed()),
   p113ft_row("fact-branch-assumptions",p185fc_branches()),
   p113ft_row("fact-copy-propagates",p185fc_bits([p185fc_call(30,2),N111Set{"copy",N111U64{},N111Local{"answer"}}],"copy",1)),
   p113ft_row("fact-call-overwrite-kills",p185fc_bits([p185fc_call(30,2),p185fc_call(26,2)],"answer",64)),
   p113ft_row("fact-load-overwrite-kills",p185fc_bits([p185fc_call(30,2),N111Load{"answer",N111U64{},N111Local{"scratch"},0}],"answer",64)),
   p113ft_row("fact-direct-call-overwrite-kills",p185fc_direct_kill()),
   p113ft_row("fact-unknown-branch-join",p185fc_bits([p185fc_call(30,2),N111If{N111Local{"condition"},[p185fc_call(26,2)],[]}],"answer",64)),
   p113ft_row("fact-original-and-candidate-verify",p185fc_verified()),
   p113ft_row("fact-verifier-rejects-scratch-redefinition",Bool.not(p185fc_verify([P113DScalar{N111Alloca{"scratch",8,8}},P113DResult{[N111Const{0,0}]}]))),
   p113ft_row("fact-verifier-rejects-short-buffer",Bool.not(p185fc_verify([P113DScalar{N111Alloca{"small",8,8}},
     P113DScalar{N111Call{"answer",N111U64{},"p111_rt_op",[p111_state(),p111_u32(30),N111Arg{N111Ptr{},N111Local{"small"}},p111_u32(2)]}},
     P113DResult{[N111Local{"answer"}]}])))]
