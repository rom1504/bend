# Ordinary user constructor identity is supplied by nc_ctor_identity after
# checked source admission. Canonical Base/builtin/effect identities stay on
# their original paths. Arity is also checked by the retained fallback import.
@unsafe
def p114p_ordinary(+name: String) -> Bool:
  String.starts_with(name,"$ctor.") && U32.is_eq(p111_special(name),0)

# Exact mature ne_single guard: all bits outside LOC_MASK are zero. This
# excludes every owning tag and RFC bit without truncating the original word.
# Both branches preserve the already-evaluated payload and return full U64.
@unsafe
def p114p_single(+name: String, field: N111Value) -> P111ValueCode:
  P111ValueCode{[
    N111Set{"p114p_payload",N111U64{},field},
    N111Store{N111U64{},N111Local{"scratch"},0,N111Local{"p114p_payload"}},
    N111Bin{"p114p_fits",N111U64{},"ule",N111Local{"p114p_payload"},N111Const{4294967295,255}},
    N111If{N111Local{"p114p_fits"},[
      N111Bin{"p114p_metadata",N111U64{},"shl",N111CtorId{name},N111Const{40,0}},
      N111Bin{"p114p_metadata",N111U64{},"or",N111Local{"p114p_metadata"},N111Const{0,16777216}},
      N111Bin{"value",N111U64{},"or",N111Local{"p114p_metadata"},N111Local{"p114p_payload"}}],[
      N111Call{"value",N111U64{},"p111_rt_ctor",[p111_state(),N111Arg{N111U32{},N111CtorId{name}},p111_scratch(),p111_u32(1)]}]}],
    N111Local{"value"},""}

@unsafe
def p114p_constructor(+name: String, +values: List<&2,N111Value>) -> P111ValueCode:
  match values:
    case Con{+field,Nil{}}:
      nt_choose(P111ValueCode,p114p_ordinary(name),
        u => p114p_single(name,field),u => p114p_original_constructor(name,values))
    case _: p114p_original_constructor(name,values)
