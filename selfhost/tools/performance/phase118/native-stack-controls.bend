# Analysis-only controls. These ordinary IR/catalogue values are never emitted
# or executed as native programs. The large case isolates list depth from full
# source checking, lowering, allocation, and QBE machine build.

@unsafe
def p118nsc_segments(+n: U32, reversed: List<&2,N111Segment>) -> List<&2,N111Segment>:
  match n:
    case 0: reversed
    case _: p118nsc_segments(U32.sub(n,1),Con{N111Segment{"p118_segment_" ++ U32.show(n),0,1,0,0,[N111Return{N111Const{0,0}}]},reversed})

@unsafe
def p118nsc_functions(+n: U32, reversed: List<&2,P113DFunction>) -> List<&2,P113DFunction>:
  match n:
    case 0: reversed
    case _: p118nsc_functions(U32.sub(n,1),Con{P113DFunction{"p118_function_" ++ U32.show(n),[],1,False{},[P113DResult{[N111Const{0,0}]}]},reversed})

@unsafe
def p118nsc_names(+n: U32, reversed: List<&2,String>) -> List<&2,String>:
  match n:
    case 0: reversed
    case _: p118nsc_names(U32.sub(n,1),Con{"probe",reversed})

@unsafe
def p118nsc_scalars(+n: U32, reversed: List<&2,N111Stmt>) -> List<&2,N111Stmt>:
  match n:
    case 0: reversed
    case _: p118nsc_scalars(U32.sub(n,1),Con{N111Set{"value",N111U64{},N111Const{n,0}},reversed})

@unsafe
def p118nsc_order(functions: List<&2,P113DFunction>, +expected: U32, +valid: Bool) -> Bool:
  match functions:
    case Nil{}: valid
    case Con{P113DFunction{name,params,result,public,body},rest}:
      p118nsc_order(rest,U32.inc(expected),valid && String.eq(name,"p118_function_" ++ U32.show(expected)))

@unsafe
def p118nsc_count(functions: List<&2,P113DFunction>, count: U32) -> U32:
  match functions:
    case Nil{}: count
    case Con{head,rest}: p118nsc_count(rest,U32.inc(count))

@unsafe
def p118nsc_projected(workers: P118BWorkers, +count: U32) -> Bool:
  match workers:
    case P118BWorkers{+functions,+error}:
      String.is_empty(error) && U32.is_eq(p118nsc_count(functions,0),count) && p118nsc_order(functions,1,True{})

def p118nsc_definition(name: String, value: KTerm, trusted: Bool) -> KDef:
  KDef{name,"Def",0,0,atom("Typ"),value,[],trusted,False{}}

@unsafe
def p118nsc_permission(+book: List<&2,KDef>, +names: List<&2,String>) -> Bool:
  U32.is_eq(Bool.to_u32(no_effect_definitions(book,names)),
    Bool.to_u32(p118ns_effect_definitions(True{},book,names)))

@unsafe
def p118ns_scale(+requested: U32) -> List<&2,String>:
  +count = U32.min(requested,65536)
  +functions = p118nsc_functions(count,[])
  +ids : N111Ids = N111Ids{missing(),missing()}
  +plain = p118nsc_definition("probe",kt("NWord","7",0,0,[]),False{})
  [p113ft_row("stack-large-segments",p118z_segments(p118nsc_segments(count,[]))),
   p113ft_row("stack-large-scalars",p118z_scalars(p118nsc_scalars(count,[]),True{})),
   p113ft_row("stack-large-direct-functions",p118z_functions(functions)),
   p113ft_row("stack-large-projected-order",p118nsc_projected(p118b_project_functions(functions,ids),count)),
   p113ft_row("stack-large-retained-order",p118nsc_projected(P118BWorkers{p118b_without(functions,missing()),""},count)),
   p113ft_row("stack-large-effect-definitions",p118ns_effect_definitions(True{},[plain],p118nsc_names(count,[])))]

@unsafe
def p118ns_controls() -> List<&2,String>:
  +plain = p118nsc_definition("probe",kt("NWord","7",0,0,[]),False{})
  +rewrite = p118nsc_definition("rewrite",kt("Rwt","",0,0,[]),False{})
  +trusted = p118nsc_definition("IO.print",atom("Foreign"),True{})
  +untrusted = p118nsc_definition("IO.print",atom("Foreign"),False{})
  +absent = p118nsc_definition("IO.print",atom("Absent"),True{})
  +unknown = p118nsc_definition("custom.foreign",atom("Foreign"),True{})
  +ids : N111Ids = N111Ids{missing(),missing()}
  +body : List<&2,P113DStmt> = [
    P113DScalar{N111Set{"a",N111U64{},N111Const{1,0}}},
    P113DScalar{N111Bin{"test",N111U64{},"eq",N111Local{"a"},N111Const{0,0}}},
    P113DIf{N111Local{"test"},[P113DResult{[N111Const{9,0}]}],[P113DResult{[N111Const{7,0}]}]}]
  +original : P113DFunction = P113DFunction{"p118_projection",[],1,False{},body}
  +projected = p118b_project(body,ids)
  nt_append(String,
    [p113ft_row("stack-permission-empty",p118nsc_permission([],[])),
     p113ft_row("stack-permission-ordinary",p118nsc_permission([plain],["probe","probe"])),
     p113ft_row("stack-permission-rewrite",p118nsc_permission([plain,rewrite],["probe","rewrite","probe"])),
     p113ft_row("stack-permission-trusted-foreign",p118nsc_permission([trusted],["IO.print"])),
     p113ft_row("stack-permission-untrusted-foreign",p118nsc_permission([untrusted],["IO.print"])),
     p113ft_row("stack-permission-unfilled-foreign",p118nsc_permission([absent],["IO.print"])),
     p113ft_row("stack-permission-unknown-foreign",p118nsc_permission([unknown],["custom.foreign"])),
     p113ft_row("stack-projection-nested-exact",String.is_empty(p113d_error(projected)) &&
       String.eq(p113e_private(original,ids),p113e_private(P113DFunction{"p118_projection",[],1,False{},p113d_body(projected)},ids)))],
    nt_append(String,p118z_controls(),p118ns_scale(8)))
