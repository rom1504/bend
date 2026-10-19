# Backend intrinsic expansion of an already verified ordered runtime call.
# The original N111 graph and its verifier remain unchanged. Scratch stores,
# public state ABI, unsupported primitive calls, and operation order remain.
type P112FPEmission is Data:
  P112FPEmission{+expanded: Bool, +code: P111QCode}

def p112fp_binary(id: U32) -> String:
  match id:
    case 26: "add"
    case 27: "sub"
    case 28: "mul"
    case 29: "div"
    case 30: "ceqs"
    case 31: "cnes"
    case 32: "clts"
    case 33: "cles"
    case 34: "cgts"
    case 35: "cges"
    case _: "INVALID_P112_FLOAT_OPERATION"

@unsafe
def p112fp_supported(+id: U32, +count: U32) -> Bool:
  (U32.is_eq(id,23) && U32.is_eq(count,1)) ||
    (U32.is_ge(id,26) && U32.is_le(id,35) && U32.is_eq(count,2))

@unsafe
def p112fp_binary_text(+id: U32, +name: String, +buffer: String, +n: U32) -> String:
  +rawa = p111q_tmp(n)
  +a = p111q_tmp(U32.add(n,1))
  +af = p111q_tmp(U32.add(n,2))
  +at = p111q_tmp(U32.add(n,3))
  +rawb = p111q_tmp(U32.add(n,4))
  +b = p111q_tmp(U32.add(n,5))
  +bf = p111q_tmp(U32.add(n,6))
  +out = p111q_tmp(U32.add(n,7))
  +bits = p111q_tmp(U32.add(n,8))
  rawa ++ " =l loadl " ++ p111q_local(buffer) ++ "\n" ++ a ++ " =w copy " ++ rawa ++ "\n" ++ af ++ " =s cast " ++ a ++ "\n" ++
  at ++ " =l add " ++ p111q_local(buffer) ++ ", 8\n" ++ rawb ++ " =l loadl " ++ at ++ "\n" ++ b ++ " =w copy " ++ rawb ++ "\n" ++
  bf ++ " =s cast " ++ b ++ "\n" ++
  nt_choose(String,U32.is_lt(id,30),
    u => out ++ " =s " ++ p112fp_binary(id) ++ " " ++ af ++ ", " ++ bf ++ "\n" ++
      bits ++ " =w cast " ++ out ++ "\n" ++ p111q_local(name) ++ " =l extuw " ++ bits ++ "\n",
    u => out ++ " =w " ++ p112fp_binary(id) ++ " " ++ af ++ ", " ++ bf ++ "\n" ++
      p111q_local(name) ++ " =l extuw " ++ out ++ "\n")

@unsafe
def p112fp_convert_text(+name: String, +buffer: String, +n: U32) -> String:
  +raw = p111q_tmp(n)
  +a = p111q_tmp(U32.inc(n))
  +out = p111q_tmp(U32.add(n,2))
  +bits = p111q_tmp(U32.add(n,3))
  raw ++ " =l loadl " ++ p111q_local(buffer) ++ "\n" ++ a ++ " =w copy " ++ raw ++ "\n" ++ out ++ " =s uwtof " ++ a ++ "\n" ++
  bits ++ " =w cast " ++ out ++ "\n" ++ p111q_local(name) ++ " =l extuw " ++ bits ++ "\n"

@unsafe
def p112fp_emit(+name: String, +id: U32, +buffer: String, code: P111QCode) -> P112FPEmission:
  match code:
    case P111QCode{chunks,+n,terminal,error}:
      P112FPEmission{True{},P111QCode{Con{nt_choose(String,U32.is_eq(id,23),
        u => p112fp_convert_text(name,buffer,n),u => p112fp_binary_text(id,name,buffer,n)),chunks},U32.add(n,9),terminal,error}}

@unsafe
def p112fp_expand(stmt: N111Stmt, +code: P111QCode) -> P112FPEmission:
  match stmt:
    case N111Call{+name,N111U64{},+symbol,
      Con{N111Arg{N111Ptr{},N111Local{state}},Con{N111Arg{N111U32{},N111Const{+id,0}},Con{N111Arg{N111Ptr{},N111Local{+buffer}},Con{N111Arg{N111U32{},N111Const{count,0}},Nil{}}}}}}:
      nt_choose(P112FPEmission,String.eq(symbol,"p111_rt_op") && String.eq(state,"state") && p112fp_supported(id,count),
        u => p112fp_emit(name,id,buffer,code),u => P112FPEmission{False{},code})
    case _: P112FPEmission{False{},code}
