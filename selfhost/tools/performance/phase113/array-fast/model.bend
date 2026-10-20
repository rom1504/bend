# Private emission profile. The certificate comes only from the checked request
# factory; the original typed/owning program remains the public verifier input.
type P113ACertificate is Data:
  P113ACertificate{+scalar: Bool, +unshared: Bool}

type P113AProgram is Data:
  P113AProgram{+original: P113DProgram, +certificate: P113ACertificate}

type P113ALowering is Data:
  P113ALowered{+program: P113AProgram, +error: String}

type P113ABody is Data:
  P113ABody{+body: List<&2,P113DStmt>, +next: U32}

type P113AInspection is Data:
  P113AInspection{+scalar: Bool, +unshared: Bool, +enabled: Bool, +functions: U32, +sites: U32, +error: String}

@unsafe
def p113a_enabled(certificate: P113ACertificate) -> Bool:
  match certificate:
    case P113ACertificate{scalar,unshared}: scalar && unshared

@unsafe
def p113a_certificate(request: NR_Request) -> P113ACertificate:
  match request:
    case NR_Request{source,+book,+names,paths,scope,bound}:
      +scalar = ns_definitions(book,names)
      P113ACertificate{scalar,nt_choose(Bool,scalar,u => nr_unshared(book,names),u => False{})}

@unsafe
def p113a_finish(certificate: P113ACertificate, lowered: P113DLowering) -> P113ALowering:
  match lowered:
    case P113DLowered{program,error}: P113ALowered{P113AProgram{program,certificate},error}

@unsafe
def p113a_lower_request(+request: NR_Request) -> P113ALowering:
  p113a_finish(p113a_certificate(request),p113d_lower_request(request))

@unsafe
def p113a_name(n: U32, role: String) -> String:
  "p113a_" ++ U32.show(n) ++ "_" ++ role

@unsafe
def p113a_value(n: U32, role: String) -> N111Value:
  N111Local{p113a_name(n,role)}

# A zero means no rewrite. These checks are deliberately redundant with the
# original direct verifier; no unchecked call is made legal by this profile.
@unsafe
def p113a_pair_id(+symbol: String, +args: List<&2,N111Arg>) -> U32:
  +id = p111v_literal(p111v_arg(args,1))
  nt_choose(U32,p113p_array_call(symbol,args) &&
    (U32.is_eq(id,72) || U32.is_eq(id,74) || U32.is_eq(id,75)),u => id,u => 0)

@unsafe
def p113a_call_id(+symbol: String, +args: List<&2,N111Arg>) -> U32:
  match args:
    case Con{N111Arg{N111Ptr{},N111Local{+state}},
      Con{N111Arg{N111U32{},N111Const{73,0}},
      Con{N111Arg{N111Ptr{},N111Local{+input}},
      Con{N111Arg{N111U32{},N111Const{3,0}},Nil{}}}}}:
        nt_choose(U32,String.eq(symbol,"p111_rt_op") && String.eq(state,"state") &&
          Bool.not(String.eq(input,"state")),u => 73,u => p113a_pair_id(symbol,args))
    case _: p113a_pair_id(symbol,args)

@unsafe
def p113a_stmt_id(stmt: N111Stmt) -> U32:
  match stmt:
    case N111Call{name,N111U64{},symbol,args}: p113a_call_id(symbol,args)
    case _: 0
