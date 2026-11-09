# Force each admitted physical destination without involving the allocator or
# earlier simplifiers. All input parameters and captured outputs stay on stack.
@unsafe
def p185rb_join(rows: List<&2,List<&2,P113DStmt>>) -> List<&2,P113DStmt>:
  match rows:
    case Nil{}: []
    case Con{head,rest}: nt_append(P113DStmt,head,p185rb_join(rest))

@unsafe
def p185rb_values(+index: U32) -> List<&2,N111Value>:
  nt_choose(List<&2,N111Value>,U32.is_eq(index,8),u => [],
    u => Con{p185x_v("out" ++ U32.show(index)),p185rb_values(U32.inc(index))})

def p185rb_arow(index: U32, start: N111Value, op: String, left: N111Value, right: N111Value) -> List<&2,P113DStmt>:
  [p185cp_set("x",start),p185x_bin("x",N111U64{},op,left,right),p185cp_set("out" ++ U32.show(index),p185x_v("x"))]

@unsafe
def p185rb_arithmetic() -> List<&2,P113DStmt>:
  p185rb_join([
    p185rb_arow(0,p185x_v("a"),"sub",p185x_v("x"),p185x_v("b")),
    p185rb_arow(1,p185x_v("b"),"sub",p185x_v("a"),p185x_v("x")),
    p185rb_arow(2,p185x_v("a"),"xor",p185x_v("x"),p185x_v("x")),
    p185rb_arow(3,p185x_v("b"),"shr",p185x_v("a"),p185x_v("x")),
    p185rb_arow(4,p185x_v("a"),"shl",p185x_v("x"),p185x_v("b")),
    p185rb_arow(5,p185x_v("a"),"xor",p185x_v("x"),N111Const{2147483648,0}),
    p185rb_arow(6,p185x_v("a"),"and",p185x_v("x"),N111Const{4294967295,0}),
    p185rb_arow(7,p185x_v("b"),"mul",p185x_v("a"),p185x_v("x")),
    [P113DResult{p185rb_values(0)}]])

@unsafe
def p185rb_capture(index: U32) -> List<&2,P113DStmt>:
  nt_append(P113DStmt,p185x_widen(["test"]),[p185cp_set("out" ++ U32.show(index),p185x_v("z_test"))])

@unsafe
def p185rb_crow(index: U32, op: String) -> List<&2,P113DStmt>:
  nt_append(P113DStmt,[p185cp_set("x",p185x_v("b")),
    p185x_bin("test",N111U64{},op,p185x_v("a"),p185x_v("x"))],p185rb_capture(index))

@unsafe
def p185rb_comparisons() -> List<&2,P113DStmt>:
  p185rb_join([p185rb_crow(0,"eq"),p185rb_crow(1,"ne"),p185rb_crow(2,"ult"),p185rb_crow(3,"ule"),
    p185rb_crow(4,"ugt"),p185rb_crow(5,"uge"),p185rb_crow(6,"slt"),p185rb_crow(7,"sge"),
    [P113DResult{p185rb_values(0)}]])

# The x and test IR names share a physical home only after x's last read.
# Source words at128/136 remain separate from the width-widening cell at32.
@unsafe
def p185rb_wrow(index: U32, op: String, +reverse: Bool) -> List<&2,P113DStmt>:
  nt_append(P113DStmt,
    [P113DScalar{N111Load{"x",N111U32{},p185x_v("scratch"),nt_choose(U32,reverse,u => 136,u => 128)}},
     P113DScalar{N111Load{"y",N111U32{},p185x_v("scratch"),nt_choose(U32,reverse,u => 128,u => 136)}},
     p185x_bin("test",N111U32{},op,nt_choose(N111Value,reverse,u => p185x_v("y"),u => p185x_v("x")),
       nt_choose(N111Value,reverse,u => p185x_v("x"),u => p185x_v("y")))],p185rb_capture(index))

@unsafe
def p185rb_words() -> List<&2,P113DStmt>:
  p185rb_join([[P113DScalar{N111Store{N111U64{},p185x_v("scratch"),128,p185x_v("a")}},
      P113DScalar{N111Store{N111U64{},p185x_v("scratch"),136,p185x_v("b")}}],
    p185rb_wrow(0,"add",False{}),p185rb_wrow(1,"sub",True{}),p185rb_wrow(2,"mul",True{}),
    p185rb_wrow(3,"shr",True{}),p185rb_wrow(4,"shl",False{}),p185rb_wrow(5,"eq",True{}),
    p185rb_wrow(6,"ult",True{}),p185rb_wrow(7,"slt",True{}),[P113DResult{p185rb_values(0)}]])

def p185rb_family(family: U32) -> String:
  match family:
    case 0: "a"
    case 1: "c"
    case _: "w"

@unsafe
def p185rb_function(+family: U32, home: U32) -> P113DFunction:
  P113DFunction{"p185rb" ++ p185rb_family(family) ++ U32.show(home),p185cp_params(["a","b"],0),8,False{},
    nt_choose(List<&2,P113DStmt>,U32.is_eq(family,0),u => p185rb_arithmetic(),
      u => nt_choose(List<&2,P113DStmt>,U32.is_eq(family,1),v => p185rb_comparisons(),v => p185rb_words()))}

@unsafe
def p185rb_functions(+family: U32, +home: U32) -> List<&2,P113DFunction>:
  nt_choose(List<&2,P113DFunction>,U32.is_eq(family,3),u => [],
    u => nt_choose(List<&2,P113DFunction>,U32.is_eq(home,9),v => p185rb_functions(U32.inc(family),0),
      v => Con{p185rb_function(family,home),p185rb_functions(family,U32.inc(home))}))

@unsafe
def p185rb_validate() -> String:
  p113e_functions(p185rb_functions(0,0),N111Ids{missing(),missing()},missing())

@unsafe
def p185rb_frame(frame: X181Frame, +home: U32) -> X181Frame:
  match frame:
    case X181Frame{slots,bytes,calls,params,symbol}:
      +kind = nt_choose(String,U32.is_lt(home,4),u => "X181Register",u => "X185Transient")
      +index = nt_choose(U32,U32.is_lt(home,4),u => U32.inc(home),u => U32.sub(home,4))
      X181Frame{p111v_put(p111v_put(slots,"x",kind,index,8),"test",kind,index,8),bytes,calls,params,symbol}

@unsafe
def p185rb_emit_one(function: P113DFunction, home: U32) -> X181Output:
  match function:
    case P113DFunction{+name,params,result,public,+body}:
      x181_function_frame(p113e_symbol(name),body,N111Ids{missing(),missing()},
        p185rb_frame(x181_frame(p113e_symbol(name),["state","__x181_result_out","a","b"],body),home))

@unsafe
def p185rb_emit_all(+family: U32, +home: U32) -> X181Output:
  nt_choose(X181Output,U32.is_eq(family,3),u => X181Output{[],""},
    u => nt_choose(X181Output,U32.is_eq(home,9),v => p185rb_emit_all(U32.inc(family),0),
      v => x181_program_join(p185rb_emit_one(p185rb_function(family,home),home),p185rb_emit_all(family,U32.inc(home)))))

@unsafe
def p185rb_emit() -> X181Output:
  p185rb_emit_all(0,0)

@unsafe
def p185rb_probe(+home: U32, +op: String, left: N111Value, right: N111Value) -> String:
  x185_physical_binary("x",N111U64{},op,left,right,N111Ids{missing(),missing()},
    p185rb_frame(x181_frame("probe",["state","a","b"],p185rb_arithmetic()),home))

@unsafe
def p185rb_homes(+home: U32) -> Bool:
  nt_choose(Bool,U32.is_eq(home,9),u => True{},
    u => Bool.not(String.is_empty(p185rb_probe(home,"add",p185x_v("a"),p185x_v("x")))) && p185rb_homes(U32.inc(home)))

@unsafe
def p185rb_row(name: String, +good: Bool) -> String:
  name ++ nt_choose(String,good,u => "=1",u => "=0")

@unsafe
def p185rb_controls() -> List<&2,String>:
  [p185rb_row("verified",String.is_empty(p185rb_validate())),
   p185rb_row("nine-physical-homes",p185rb_homes(0)),
   p185rb_row("stack-fallback",String.is_empty(x185_physical_binary("x",N111U64{},"add",p185x_v("a"),p185x_v("b"),
     N111Ids{missing(),missing()},x181_frame("probe",["state","a","b"],p185rb_arithmetic())))),
   p185rb_row("unsupported-fallback",String.is_empty(p185rb_probe(0,"unsupported",p185x_v("a"),p185x_v("x")))),
   p185rb_row("rhs-snapshot-first",String.starts_with(p185rb_probe(0,"sub",p185x_v("a"),p185x_v("x")),"  movq %rbx, %r11\n")),
   p185rb_row("self-load-omitted",String.eq(p185rb_probe(0,"add",p185x_v("x"),N111Const{1,0}),"  addq $1, %rbx\n")),
   p185rb_row("wide-immediate",String.starts_with(p185rb_probe(0,"xor",p185x_v("x"),N111Const{2147483648,0}),"  movabsq $2147483648, %r11\n"))]
