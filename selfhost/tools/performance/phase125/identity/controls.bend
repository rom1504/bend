# Analysis-only malformed arities; none are emitted or executed as targets.
@unsafe
def p125ic_copy(code: P111ValueCode, lo: U32, hi: U32) -> Bool:
  match code:
    case P111ValueCode{Con{N111Set{dest,N111U64{},N111Const{a,b}},Nil{}},N111Local{result},error}:
      String.eq(dest,"value") && String.eq(result,"value") && String.is_empty(error) && U32.is_eq(a,lo) && U32.is_eq(b,hi)
    case _: False{}

@unsafe
def p125ic_has_call(body: List<&2,N111Stmt>) -> Bool:
  match body:
    case Nil{}: False{}
    case Con{N111Call{dest,typ,symbol,args},rest}: String.eq(symbol,"p111_rt_op")
    case Con{head,rest}: p125ic_has_call(rest)

@unsafe
def p125ic_fallback(code: P111ValueCode) -> Bool:
  match code:
    case P111ValueCode{body,value,error}: p125ic_has_call(body)

@unsafe
def p125ic_controls() -> List<&2,String>:
  [p113ft_row("u32-to-nat-zero",p125ic_copy(p112_intrinsic_fallback("u32_to_nat",[N111Const{0,0}]),0,0)),
   p113ft_row("u32-to-nat-max",p125ic_copy(p112_intrinsic_fallback("u32_to_nat",[N111Const{4294967295,0}]),4294967295,0)),
   p113ft_row("full-u64-identity",p125ic_copy(p112_intrinsic_fallback("u32_to_nat",[N111Const{17,4294967295}]),17,4294967295)),
   p113ft_row("f32-bits-payload",p125ic_copy(p112_intrinsic_fallback("f32_bits",[N111Const{2143289345,0}]),2143289345,0)),
   p113ft_row("f32-bits-signed-zero",p125ic_copy(p112_intrinsic_fallback("f32_bits",[N111Const{2147483648,0}]),2147483648,0)),
   p113ft_row("u32-from-nat-not-identity",p125ic_fallback(p112_intrinsic_fallback("u32_from_nat",[N111Const{0,1}]))),
   p113ft_row("numeric-conversion-not-identity",p125ic_fallback(p112_intrinsic_fallback("u32_to_f32",[N111Const{1,0}]))),
   p113ft_row("missing-argument-original-path",p125ic_fallback(p112_intrinsic_fallback("u32_to_nat",[]))),
   p113ft_row("extra-argument-original-path",p125ic_fallback(p112_intrinsic_fallback("f32_bits",[N111Const{0,0},N111Const{1,0}])))]
