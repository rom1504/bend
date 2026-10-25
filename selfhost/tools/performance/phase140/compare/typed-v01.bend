# Private exact first-order comparison experiment. Original comparisons remain
# the independent reference. Preserve field order and && semantics; no identity
# shortcut, new native calling convention or forced recursion admission.

def p140e_bool(a: Bool, b: Bool) -> Bool:
  Bool.not(Bool.xor(a,b))


def p140e_type(a: N111Type, b: N111Type) -> Bool:
  match a b:
    case N111U32{} N111U32{}: True{}
    case N111U64{} N111U64{}: True{}
    case N111Ptr{} N111Ptr{}: True{}
    case _ _: False{}


def p140e_kind(a: N_WordKind, b: N_WordKind) -> Bool:
  match a b:
    case N_W32{} N_W32{}: True{}
    case N_W64{} N_W64{}: True{}
    case N_Box{} N_Box{}: True{}
    case N_Imm64{} N_Imm64{}: True{}
    case _ _: False{}


def p140e_value(a: N111Value, b: N111Value) -> Bool:
  match a b:
    case N111Local{x} N111Local{y}: String.eq(x,y)
    case N111Const{xl,xh} N111Const{yl,yh}: U32.is_eq(xl,yl) && U32.is_eq(xh,yh)
    case N111Symbol{x} N111Symbol{y}: String.eq(x,y)
    case N111FuncId{x} N111FuncId{y}: String.eq(x,y)
    case N111CtorId{x} N111CtorId{y}: String.eq(x,y)
    case _ _: False{}


def p140e_arg(a: N111Arg, b: N111Arg) -> Bool:
  match a b:
    case N111Arg{at,av} N111Arg{bt,bv}: p140e_type(at,bt) && p140e_value(av,bv)


def p140e_binding(a: NC_Binding, b: NC_Binding) -> Bool:
  match a b:
    case NC_Binding{ai,an,ak} NC_Binding{bi,bn,bk}: U32.is_eq(ai,bi) && String.eq(an,bn) && p140e_kind(ak,bk)


@unsafe
def p140e_scalar(a: N111Stmt, b: N111Stmt) -> Bool:
  match a b:
    case N111Set{an,at,av} N111Set{bn,bt,bv}: String.eq(an,bn) && p140e_type(at,bt) && p140e_value(av,bv)
    case N111Bin{an,at,ao,al,ar} N111Bin{bn,bt,bo,bl,br}:
      String.eq(an,bn) && p140e_type(at,bt) && String.eq(ao,bo) && p140e_value(al,bl) && p140e_value(ar,br)
    case N111Call{an,at,as,aa} N111Call{bn,bt,bs,ba}:
      String.eq(an,bn) && p140e_type(at,bt) && String.eq(as,bs) && p140e_args(aa,ba)
    case N111If{ac,ay,an} N111If{bc,by,bn}:
      p140e_value(ac,bc) && p140e_scalars(ay,by) && p140e_scalars(an,bn)
    case N111Return{av} N111Return{bv}: p140e_value(av,bv)
    case N111Load{an,at,ab,ao} N111Load{bn,bt,bb,bo}:
      String.eq(an,bn) && p140e_type(at,bt) && p140e_value(ab,bb) && U32.is_eq(ao,bo)
    case N111Store{at,ab,ao,av} N111Store{bt,bb,bo,bv}:
      p140e_type(at,bt) && p140e_value(ab,bb) && U32.is_eq(ao,bo) && p140e_value(av,bv)
    case N111Offset{an,ab,ax} N111Offset{bn,bb,bx}:
      String.eq(an,bn) && p140e_value(ab,bb) && p140e_value(ax,bx)
    case N111Alloca{an,ab,aa} N111Alloca{bn,bb,ba}: String.eq(an,bn) && U32.is_eq(ab,bb) && U32.is_eq(aa,ba)
    case _ _: False{}


@unsafe
def p140e_stmt(a: P113DStmt, b: P113DStmt) -> Bool:
  match a b:
    case P113DScalar{as} P113DScalar{bs}: p140e_scalar(as,bs)
    case P113DIf{ac,ay,an} P113DIf{bc,by,bn}:
      p140e_value(ac,bc) && p140e_stmts(ay,by) && p140e_stmts(an,bn)
    case P113DCall{ad,at,aa} P113DCall{bd,bt,ba}:
      p140e_strings(ad,bd) && String.eq(at,bt) && p140e_values(aa,ba)
    case P113DResult{av} P113DResult{bv}: p140e_values(av,bv)
    case P113DAgain{av} P113DAgain{bv}: p140e_values(av,bv)
    case _ _: False{}


@unsafe
def p140e_header(a: P113DFunction, b: P113DFunction) -> Bool:
  match a b:
    case P113DFunction{an,ap,ar,au,ab} P113DFunction{bn,bp,br,bu,bb}:
      String.eq(an,bn) && p140e_bindings(ap,bp) && U32.is_eq(ar,br) && p140e_bool(au,bu)


@unsafe
def p140e_function(a: P113DFunction, b: P113DFunction) -> Bool:
  match a b:
    case P113DFunction{an,ap,ar,au,ab} P113DFunction{bn,bp,br,bu,bb}:
      String.eq(an,bn) && p140e_bindings(ap,bp) && U32.is_eq(ar,br) && p140e_bool(au,bu) && p140e_stmts(ab,bb)


def p140e_raw_header(a: N111Segment, b: N111Segment) -> Bool:
  match a b:
    case N111Segment{an,aa,ar,ai,af,ab} N111Segment{bn,ba,br,bi,bf,bb}:
      String.eq(an,bn) && U32.is_eq(aa,ba) && U32.is_eq(ar,br) && U32.is_eq(ai,bi) && U32.is_eq(af,bf)

def p140e_ctor(a: N_Constructor, b: N_Constructor) -> Bool:
  match a b:
    case N_Constructor{an,aa,ah} N_Constructor{bn,ba,bh}:
      String.eq(an,bn) && U32.is_eq(aa,ba) && p140e_bool(ah,bh)

@unsafe
def p140e_strings(a: List<&2,String>, b: List<&2,String>) -> Bool:
  match a b:
    case Nil{} Nil{}: True{}
    case Con{x,xs} Con{y,ys}: String.eq(x,y) && p140e_strings(xs,ys)
    case _ _: False{}

@unsafe
def p140e_u32s(a: List<&2,U32>, b: List<&2,U32>) -> Bool:
  match a b:
    case Nil{} Nil{}: True{}
    case Con{x,xs} Con{y,ys}: U32.is_eq(x,y) && p140e_u32s(xs,ys)
    case _ _: False{}

@unsafe
def p140e_args(a: List<&2,N111Arg>, b: List<&2,N111Arg>) -> Bool:
  match a b:
    case Nil{} Nil{}: True{}
    case Con{x,xs} Con{y,ys}: p140e_arg(x,y) && p140e_args(xs,ys)
    case _ _: False{}

@unsafe
def p140e_scalars(a: List<&2,N111Stmt>, b: List<&2,N111Stmt>) -> Bool:
  match a b:
    case Nil{} Nil{}: True{}
    case Con{x,xs} Con{y,ys}: p140e_scalar(x,y) && p140e_scalars(xs,ys)
    case _ _: False{}

@unsafe
def p140e_stmts(a: List<&2,P113DStmt>, b: List<&2,P113DStmt>) -> Bool:
  match a b:
    case Nil{} Nil{}: True{}
    case Con{x,xs} Con{y,ys}: p140e_stmt(x,y) && p140e_stmts(xs,ys)
    case _ _: False{}

@unsafe
def p140e_values(a: List<&2,N111Value>, b: List<&2,N111Value>) -> Bool:
  match a b:
    case Nil{} Nil{}: True{}
    case Con{x,xs} Con{y,ys}: p140e_value(x,y) && p140e_values(xs,ys)
    case _ _: False{}

@unsafe
def p140e_bindings(a: List<&2,NC_Binding>, b: List<&2,NC_Binding>) -> Bool:
  match a b:
    case Nil{} Nil{}: True{}
    case Con{x,xs} Con{y,ys}: p140e_binding(x,y) && p140e_bindings(xs,ys)
    case _ _: False{}

@unsafe
def p140e_headers(a: List<&2,P113DFunction>, b: List<&2,P113DFunction>) -> Bool:
  match a b:
    case Nil{} Nil{}: True{}
    case Con{x,xs} Con{y,ys}: p140e_header(x,y) && p140e_headers(xs,ys)
    case _ _: False{}

@unsafe
def p140e_raw_headers(a: List<&2,N111Segment>, b: List<&2,N111Segment>) -> Bool:
  match a b:
    case Nil{} Nil{}: True{}
    case Con{x,xs} Con{y,ys}: p140e_raw_header(x,y) && p140e_raw_headers(xs,ys)
    case _ _: False{}

@unsafe
def p140e_ctors(a: List<&2,N_Constructor>, b: List<&2,N_Constructor>) -> Bool:
  match a b:
    case Nil{} Nil{}: True{}
    case Con{x,xs} Con{y,ys}: p140e_ctor(x,y) && p140e_ctors(xs,ys)
    case _ _: False{}

