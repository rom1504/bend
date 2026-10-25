# Finite differential controls only. Not a proof, and not yet executed.
# Dependencies: selected Phase137 p134v_*; Phase140 typed-v01.bend and
# the exact Phase140 fixture subset in fixtures-v01.bend.
# Static same/typed references are closed; fixture values remain runtime data.
@unsafe
def p141st_case(~A: Data, ~same: A -> A -> Bool, ~typed: List<&2,A> -> List<&2,A> -> Bool, +a: List<&2,A>, +b: List<&2,A>) -> Bool:
  p134v_bool(p141st_list(~A,~same,a,b),p134v_list(A,same,a,b)) &&
  p134v_bool(p141st_list(~A,~same,a,b),typed(a,b))

@unsafe
def p141st_cases(~A: Data, ~same: A -> A -> Bool, ~typed: List<&2,A> -> List<&2,A> -> Bool, +items: List<&2,A>) -> Bool:
  p141st_case(~A,~same,~typed,[],[]) &&
  p141st_case(~A,~same,~typed,items,items) &&
  p141st_case(~A,~same,~typed,[],items) &&
  p141st_case(~A,~same,~typed,items,[]) &&
  p141st_case(~A,~same,~typed,items,List.reverse(&2,A,items))

def p141st_offset(offset: U32, a: U32, b: U32) -> Bool:
  U32.is_eq(U32.add(a,offset),b)

@unsafe
def p141st_offset_reference(+offset: U32, a: List<&2,U32>, b: List<&2,U32>) -> Bool:
  match a b:
    case Nil{} Nil{}: True{}
    case Con{x,xs} Con{y,ys}: p141st_offset(offset,x,y) && p141st_offset_reference(offset,xs,ys)
    case _ _: False{}

@unsafe
def p141st_state_case(+offset: U32, +a: List<&2,U32>, +b: List<&2,U32>) -> Bool:
  p134v_bool(p141st_state(~U32,~U32,~p141st_offset,offset,a,b),p141st_offset_reference(offset,a,b))

@unsafe
def p141st_controls() -> List<&2,String>:
  [p128bs_control_row("static-strings",p141st_cases(~String,~String.eq,~p140e_strings,["a","b","c"])),
   p128bs_control_row("static-u32s",p141st_cases(~U32,~U32.is_eq,~p140e_u32s,[0,1,4294967295])),
   p128bs_control_row("static-args",p141st_cases(~N111Arg,~p140e_arg,~p140e_args,p140tc_args())),
   p128bs_control_row("static-scalars",p141st_cases(~N111Stmt,~p140e_scalar,~p140e_scalars,p140tc_scalars())),
   p128bs_control_row("static-stmts",p141st_cases(~P113DStmt,~p140e_stmt,~p140e_stmts,p140tc_stmts())),
   p128bs_control_row("static-values",p141st_cases(~N111Value,~p140e_value,~p140e_values,p140tc_values())),
   p128bs_control_row("static-bindings",p141st_cases(~NC_Binding,~p140e_binding,~p140e_bindings,p140tc_bindings())),
   p128bs_control_row("static-headers",p141st_cases(~P113DFunction,~p140e_header,~p140e_headers,p140tc_functions())),
   p128bs_control_row("static-raw-headers",p141st_cases(~N111Segment,~p140e_raw_header,~p140e_raw_headers,p140tc_raw_headers())),
   p128bs_control_row("static-ctors",p141st_cases(~N_Constructor,~p140e_ctor,~p140e_ctors,p140tc_ctors())),
   p128bs_control_row("static-state-empty",p141st_state_case(7,[],[])),
   p128bs_control_row("static-state-equal",p141st_state_case(7,[0,1,2],[7,8,9])),
   p128bs_control_row("static-state-wrap",p141st_state_case(1,[4294967295,0],[0,1])),
   p128bs_control_row("static-state-mismatch",p141st_state_case(7,[0,1,2],[7,8,10])),
   p128bs_control_row("static-state-length",p141st_state_case(7,[0,1],[7]))]
