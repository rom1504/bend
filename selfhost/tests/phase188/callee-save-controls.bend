# Phase188 test-only type/render adaptation; Phase186 source and C oracle remain frozen.
@unsafe
def p186_sv_slots(+mask: U32, +reg: U32, +slots: KDef) -> KDef:
  nt_choose(KDef,U32.is_ge(reg,5),u => slots,u =>
    p186_sv_slots(mask,U32.inc(reg),nt_choose(KDef,U32.is_eq(U32.and(mask,U32.shln(1,U32.to_nat(reg))),0),
      v => slots,v => p111v_put(slots,"home" ++ U32.show(reg),"X181Register",reg,8))))

@unsafe
def p186_sv_body(+mask: U32, +reg: U32) -> List<&2,P113DStmt>:
  nt_choose(List<&2,P113DStmt>,U32.is_ge(reg,5),
    u => [P113DResult{[N111Const{77,0}]}],u =>
      nt_choose(List<&2,P113DStmt>,U32.is_eq(U32.and(mask,U32.shln(1,U32.to_nat(reg))),0),
        v => p186_sv_body(mask,U32.inc(reg)),v =>
          Con{P113DScalar{N111Set{"home" ++ U32.show(reg),N111U64{},N111Const{4294967295,4294967295}}},
            p186_sv_body(mask,U32.inc(reg))}))

@unsafe
def p186_sv_frame(+mask: U32) -> X181Frame:
  X181Frame{p186_sv_slots(mask,0,missing()),40,0,[],"p186_sv_" ++ U32.show(mask)}

@unsafe
def p186_sv_one(+mask: U32) -> X181Output:
  x185_function_frame("p186_sv_" ++ U32.show(mask),[],p186_sv_body(mask,0),
    N111Ids{missing(),missing()},p186_sv_frame(mask))

@unsafe
def p186_sv_join(left: X181Output, right: X181Output) -> X181Output:
  match left right:
    case X181Output{a,ae} X181Output{b,be}: X181Output{nt_append(X188Seq,a,b),p111_first(ae,be)}

@unsafe
def p186_sv_all(+mask: U32) -> X181Output:
  nt_choose(X181Output,U32.is_ge(mask,32),u => X181Output{[],""},
    u => p186_sv_join(p186_sv_one(mask),p186_sv_all(U32.inc(mask))))

def p186_sv_emit() -> X181Output: p186_sv_all(0)

@unsafe
def p186_sv_rows(+mask: U32) -> List<&2,String>:
  nt_choose(List<&2,String>,U32.is_ge(mask,32),u => [],u =>
    Con{"mask-" ++ U32.show(mask) ++ "=" ++
      nt_choose(String,U32.is_eq(x186_saves_mask(x186_saves_frame(p186_sv_frame(mask))),mask),v => "1",v => "0"),
      p186_sv_rows(U32.inc(mask))})

def p186_sv_controls() -> List<&2,String>:
  Con{"unknown-mask=" ++ nt_choose(String,U32.is_eq(x186_saves_mask(p186_sv_frame(0)),31),u => "1",u => "0"),
    p186_sv_rows(0)}
