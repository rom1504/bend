# Reuse only an unchanged function's successful verification from the same
# immutable P114SBoundary. All signature/order facts must match first.
# Changed bodies and unknown/header-changing candidates use existing verifiers.
@unsafe
def p134v_list(-A: Data, +eq: A -> A -> Bool, a: List<&2,A>, b: List<&2,A>) -> Bool:
  match a b:
    case Nil{} Nil{}: True{}
    case Con{x,xs} Con{y,ys}: eq(x,y) && p134v_list(A,eq,xs,ys)
    case _ _: False{}

def p134v_bool(a: Bool, b: Bool) -> Bool:
  Bool.not(Bool.xor(a,b))

def p134v_type(a: N111Type, b: N111Type) -> Bool:
  match a b:
    case N111U32{} N111U32{}: True{}
    case N111U64{} N111U64{}: True{}
    case N111Ptr{} N111Ptr{}: True{}
    case _ _: False{}

def p134v_kind(a: N_WordKind, b: N_WordKind) -> Bool:
  match a b:
    case N_W32{} N_W32{}: True{}
    case N_W64{} N_W64{}: True{}
    case N_Box{} N_Box{}: True{}
    case N_Imm64{} N_Imm64{}: True{}
    case _ _: False{}

def p134v_value(a: N111Value, b: N111Value) -> Bool:
  match a b:
    case N111Local{x} N111Local{y}: String.eq(x,y)
    case N111Const{xl,xh} N111Const{yl,yh}: U32.is_eq(xl,yl) && U32.is_eq(xh,yh)
    case N111Symbol{x} N111Symbol{y}: String.eq(x,y)
    case N111FuncId{x} N111FuncId{y}: String.eq(x,y)
    case N111CtorId{x} N111CtorId{y}: String.eq(x,y)
    case _ _: False{}

def p134v_arg(a: N111Arg, b: N111Arg) -> Bool:
  match a b:
    case N111Arg{at,av} N111Arg{bt,bv}: p134v_type(at,bt) && p134v_value(av,bv)

def p134v_binding(a: NC_Binding, b: NC_Binding) -> Bool:
  match a b:
    case NC_Binding{ai,an,ak} NC_Binding{bi,bn,bk}: U32.is_eq(ai,bi) && String.eq(an,bn) && p134v_kind(ak,bk)

@unsafe
def p134v_scalar(a: N111Stmt, b: N111Stmt) -> Bool:
  match a b:
    case N111Set{an,at,av} N111Set{bn,bt,bv}: String.eq(an,bn) && p134v_type(at,bt) && p134v_value(av,bv)
    case N111Bin{an,at,ao,al,ar} N111Bin{bn,bt,bo,bl,br}:
      String.eq(an,bn) && p134v_type(at,bt) && String.eq(ao,bo) && p134v_value(al,bl) && p134v_value(ar,br)
    case N111Call{an,at,as,aa} N111Call{bn,bt,bs,ba}:
      String.eq(an,bn) && p134v_type(at,bt) && String.eq(as,bs) && p134v_list(N111Arg,p134v_arg,aa,ba)
    case N111If{ac,ay,an} N111If{bc,by,bn}:
      p134v_value(ac,bc) && p134v_list(N111Stmt,p134v_scalar,ay,by) && p134v_list(N111Stmt,p134v_scalar,an,bn)
    case N111Return{av} N111Return{bv}: p134v_value(av,bv)
    case N111Load{an,at,ab,ao} N111Load{bn,bt,bb,bo}:
      String.eq(an,bn) && p134v_type(at,bt) && p134v_value(ab,bb) && U32.is_eq(ao,bo)
    case N111Store{at,ab,ao,av} N111Store{bt,bb,bo,bv}:
      p134v_type(at,bt) && p134v_value(ab,bb) && U32.is_eq(ao,bo) && p134v_value(av,bv)
    case N111Offset{an,ab,ax} N111Offset{bn,bb,bx}:
      String.eq(an,bn) && p134v_value(ab,bb) && p134v_value(ax,bx)
    case N111Alloca{an,ab,aa} N111Alloca{bn,bb,ba}: String.eq(an,bn) && U32.is_eq(ab,bb) && U32.is_eq(aa,ba)
    case _ _: False{}

@unsafe
def p134v_stmt(a: P113DStmt, b: P113DStmt) -> Bool:
  match a b:
    case P113DScalar{as} P113DScalar{bs}: p134v_scalar(as,bs)
    case P113DIf{ac,ay,an} P113DIf{bc,by,bn}:
      p134v_value(ac,bc) && p134v_list(P113DStmt,p134v_stmt,ay,by) && p134v_list(P113DStmt,p134v_stmt,an,bn)
    case P113DCall{ad,at,aa} P113DCall{bd,bt,ba}:
      p134v_list(String,String.eq,ad,bd) && String.eq(at,bt) && p134v_list(N111Value,p134v_value,aa,ba)
    case P113DResult{av} P113DResult{bv}: p134v_list(N111Value,p134v_value,av,bv)
    case P113DAgain{av} P113DAgain{bv}: p134v_list(N111Value,p134v_value,av,bv)
    case _ _: False{}

@unsafe
def p134v_header(a: P113DFunction, b: P113DFunction) -> Bool:
  match a b:
    case P113DFunction{an,ap,ar,au,ab} P113DFunction{bn,bp,br,bu,bb}:
      String.eq(an,bn) && p134v_list(NC_Binding,p134v_binding,ap,bp) && U32.is_eq(ar,br) && p134v_bool(au,bu)

@unsafe
def p134v_function(a: P113DFunction, b: P113DFunction) -> Bool:
  match a b:
    case P113DFunction{an,ap,ar,au,ab} P113DFunction{bn,bp,br,bu,bb}:
      String.eq(an,bn) && p134v_list(NC_Binding,p134v_binding,ap,bp) && U32.is_eq(ar,br) && p134v_bool(au,bu) && p134v_list(P113DStmt,p134v_stmt,ab,bb)

@unsafe
def p134v_check(original: List<&2,P113DFunction>, candidate: List<&2,P113DFunction>, +ids: N111Ids, +ready: KDef) -> String:
  match original candidate:
    case Nil{} Nil{}: ""
    case Con{old,olds} Con{+new,news}:
      +error = nt_choose(String,p134v_function(old,new),u => "",u => p113e_function(new,ids,ready))
      nt_choose(String,String.is_empty(error),u => p134v_check(olds,news,ids,p113e_insert(ready,p113e_signature(new))),u => error)
    case _ _: "verification reuse: mismatched function count"

@unsafe
def p134v_commit(+boundary: P114SBoundary, +candidate: List<&2,P113DFunction>) -> P114SBoundary:
  match boundary:
    case P114SBoundary{+original,+ids,+functions,+valid}:
      nt_choose(P114SBoundary,valid,
        u => nt_choose(P114SBoundary,p134v_list(P113DFunction,p134v_header,functions,candidate),
          v => nt_choose(P114SBoundary,String.is_empty(p134v_check(functions,candidate,ids,missing())),
            w => P114SBoundary{original,ids,candidate,True{}},w => boundary),
          v => p114s_commit(boundary,candidate)),u => boundary)

# Production callers keep the original p114s_commit as exact fallback.
# Only p114s_open-created or previously committed boundaries reach this route.
@unsafe
def p114s_inline(+boundary: P114SBoundary) -> P114SBoundary:
  match boundary:
    case P114SBoundary{original,ids,functions,valid}:
      nt_choose(P114SBoundary,valid,
        u => p134v_commit(boundary,p113i_functions(functions,P113IEmpty{},[])),
        u => boundary)

@unsafe
def p114s_ranges(+boundary: P114SBoundary) -> P114SBoundary:
  match boundary:
    case P114SBoundary{original,ids,functions,valid}:
      nt_choose(P114SBoundary,valid,
        u => p134v_commit(boundary,p113k_functions(functions)),u => boundary)
