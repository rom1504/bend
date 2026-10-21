# Additional necessary gate, used only AFTER ordinary full IR verification.
# Checks the complete original segment catalogue and every final direct worker.
# It neither replaces verification nor accepts final template-expanded raw IR.
# Descriptor capability4 may be set only when this AND the verifier succeed.

@unsafe
def p118z_transition(+symbol: String) -> Bool:
  String.eq(symbol,"p111_rt_jump") || String.eq(symbol,"p111_rt_return") || String.eq(symbol,"p111_rt_apply")

@unsafe
def p118z_runtime(+symbol: String) -> Bool:
  Bool.not(List.is_empty(&2,U32,p111v_signature(symbol))) ||
    String.eq(symbol,"p113_rt_array_pair") || String.eq(symbol,"p118_rt_extend") ||
    String.eq(symbol,"p118_rt_finish") || String.eq(symbol,"p118_rt_borrow_fields")

@unsafe
def p118z_nonpointer(typ: N111Type) -> Bool:
  match typ:
    case N111Ptr{}: False{}
    case _: True{}

@unsafe
def p118z_scalar(stmt: N111Stmt, +direct: Bool) -> Bool:
  match stmt:
    case N111Set{name,typ,value}: p118z_nonpointer(typ)
    case N111Bin{name,typ,op,left,right}: p118z_nonpointer(typ)
    case N111Call{name,N111U64{},+symbol,args}:
      p118z_runtime(symbol) && p113e_runtime_args(args) &&
        Bool.not(direct && (p118z_transition(symbol) || String.eq(symbol,"p111_rt_reg_get")))
    case N111If{condition,yes,no}: p118z_scalars(yes,direct) && p118z_scalars(no,direct)
    case N111Load{name,typ,base,offset}: p118z_nonpointer(typ) && p113e_nonstate_pointer(base)
    case N111Store{typ,base,offset,value}: p118z_nonpointer(typ) && p113e_nonstate_pointer(base)
    case N111Alloca{name,bytes,align}: True{}
    case N111Return{value}: Bool.not(direct)
    # No pointer aliases/offsets/loads; other pointer roots are verified allocas.
    case _: False{}

# A transition must terminate its block immediately. This forbids reading the
# old segment's wider inputs after a narrower outgoing transfer. The original
# verifier checks the transition's count, target and return value definitions.
@unsafe
def p118z_scalars(body: List<&2,N111Stmt>, +direct: Bool) -> Bool:
  match body:
    case Nil{}: True{}
    case Con{N111Call{+name,N111U64{},+symbol,+args},Con{N111Return{N111Local{+reply}},Nil{}}}:
      nt_choose(Bool,p118z_transition(symbol),
        u => Bool.not(direct) && String.eq(name,reply) && p118z_scalar(N111Call{name,N111U64{},symbol,args},direct),
        u => p118z_scalar(N111Call{name,N111U64{},symbol,args},direct) && p118z_scalar(N111Return{N111Local{reply}},direct))
    case Con{N111Call{name,typ,+symbol,args},rest}:
      Bool.not(p118z_transition(symbol)) && p118z_scalar(N111Call{name,typ,symbol,args},direct) && p118z_scalars(rest,direct)
    case Con{head,rest}: p118z_scalar(head,direct) && p118z_scalars(rest,direct)

@unsafe
def p118z_segments(segments: List<&2,N111Segment>) -> Bool:
  match segments:
    case Nil{}: True{}
    case Con{N111Segment{name,arity,result,incoming,flags,body},rest}:
      U32.is_eq(result,1) && U32.is_le(incoming,1) && p118z_scalars(body,False{}) && p118z_segments(rest)

@unsafe
def p118z_direct(body: List<&2,P113DStmt>) -> Bool:
  match body:
    case Nil{}: True{}
    case Con{P113DScalar{stmt},rest}: p118z_scalar(stmt,True{}) && p118z_direct(rest)
    case Con{P113DIf{condition,yes,no},rest}: p118z_direct(yes) && p118z_direct(no) && p118z_direct(rest)
    case Con{stmt,rest}: p118z_direct(rest)

@unsafe
def p118z_functions(functions: List<&2,P113DFunction>) -> Bool:
  match functions:
    case Nil{}: True{}
    case Con{P113DFunction{name,params,result,public,body},rest}:
      p118z_direct(body) && p118z_functions(rest)

@unsafe
def p118z_eligible(program: P113AProgram) -> Bool:
  match program:
    case P113AProgram{P113DProgram{P112StaticProgram{P111Program{segments,constructors,show,names,effects,pure},nodes},functions},certificate}:
      p118z_segments(segments) && p118z_functions(functions)

# Pure finite refusals; no malformed target code is run by these controls.
@unsafe
def p118z_controls() -> List<&2,String>:
  +load : N111Stmt = N111Load{"probe",N111U64{},N111Local{"state"},48}
  +alias : N111Stmt = N111Set{"alias",N111Ptr{},N111Local{"state"}}
  +reg : N111Stmt = N111Call{"value",N111U64{},"p111_rt_reg_get",[p111_state(),p111_u32(0)]}
  +ret : N111Stmt = N111Call{"reply",N111U64{},"p111_rt_return",[p111_state(),p111_scratch(),p111_u32(1)]}
  [p113ft_row("transport-state-load-refused",Bool.not(p118z_scalar(load,False{}))),
   p113ft_row("transport-state-alias-refused",Bool.not(p118z_scalar(alias,False{}))),
   p113ft_row("transport-direct-register-read-refused",Bool.not(p118z_scalar(reg,True{}))),
   p113ft_row("transport-verified-generic-register-read",p118z_scalar(reg,False{})),
   p113ft_row("transport-terminal-return",p118z_scalars([ret,N111Return{N111Local{"reply"}}],False{})),
   p113ft_row("transport-post-transition-read-refused",Bool.not(p118z_scalars([ret,reg,N111Return{N111Local{"reply"}}],False{}))),
   p113ft_row("transport-multi-result-generic-refused",Bool.not(p118z_segments([N111Segment{"probe",2,2,0,0,[]}]))),
   p113ft_row("transport-multi-input-continuation-refused",Bool.not(p118z_segments([N111Segment{"probe",2,1,2,0,[]}])))]
