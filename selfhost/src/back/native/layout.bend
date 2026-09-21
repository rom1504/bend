@unsafe
def nl_word() -> N_Layout:
  N_Layout{Con{N_W32{}, Nil{}}, Nil{}}

@unsafe
def nl_wide() -> N_Layout:
  N_Layout{Con{N_W64{}, Nil{}}, Nil{}}

@unsafe
def nl_box() -> N_Layout:
  N_Layout{Con{N_Box{}, Nil{}}, Nil{}}

@unsafe
def nl_c_type(+k: N_WordKind) -> String:
  match k:
    case N_W32{}: "u32"
    case N_W64{}: "Term"
    case N_Box{}: "Term"

@unsafe
def nl_merge_word(+a: N_WordKind, +b: N_WordKind) -> N_WordKind:
  match a, b:
    case N_Box{}, _: N_Box{}
    case _, N_Box{}: N_Box{}
    case N_W64{}, _: N_W64{}
    case _, N_W64{}: N_W64{}
    case _, _: N_W32{}

@unsafe
def nl_merge(+a: List<&2, N_WordKind>, +b: List<&2, N_WordKind>) -> List<&2, N_WordKind>:
  match a, b:
    case Nil{}, _: b
    case _, Nil{}: a
    case Con{h, t}, Con{j, u}: Con{nl_merge_word(h, j), nl_merge(t, u)}

@unsafe
def nl_pad(+n: U32) -> List<&2, N_WordKind>:
  match n:
    case 0: Nil{}
    case _: Con{N_W32{}, nl_pad(U32.sub(n, 1))}

@unsafe
def nl_field_words(+fs: List<&2, N_Field>) -> List<&2, N_WordKind>:
  match fs:
    case Nil{}: Nil{}
    case Con{N_Field{at, ws}, t}:
      nl_merge(List.append(&2, N_WordKind, nl_pad(at), ws), nl_field_words(t))

@unsafe
def nl_arm_words(+xs: List<&2, N_Arm>) -> List<&2, N_WordKind>:
  match xs:
    case Nil{}: Nil{}
    case Con{N_Arm{k, fs}, t}: nl_merge(nl_field_words(fs), nl_arm_words(t))

@unsafe
def nl_shift_fields(+xs: List<&2, N_Field>, +tag: U32) -> List<&2, N_Field>:
  match xs:
    case Nil{}: Nil{}
    case Con{N_Field{at, ws}, t}: Con{N_Field{U32.add(at, tag), ws}, nl_shift_fields(t, tag)}

@unsafe
def nl_shift_arms(+xs: List<&2, N_Arm>, +tag: U32) -> List<&2, N_Arm>:
  match xs:
    case Nil{}: Nil{}
    case Con{N_Arm{k, fs}, t}: Con{N_Arm{k, nl_shift_fields(fs, tag)}, nl_shift_arms(t, tag)}

@unsafe
def nl_pack(+arms: List<&2, N_Arm>) -> N_Layout:
  +tag = nt_choose(U32, U32.is_gt(nt_count(N_Arm, arms), 1), u => 1, u => 0)
  +shifted = nl_shift_arms(arms, tag)
  N_Layout{nl_merge(nl_pad(tag), nl_arm_words(shifted)), shifted}

@unsafe
def nl_size(+x: N_Layout) -> U32:
  match x:
    case N_Layout{ws, arms}: nt_count(N_WordKind, ws)

@unsafe
def nl_fits(+x: N_Layout) -> Bool:
  U32.is_le(nl_size(x), 256)

@unsafe
def nl_cls_go(+n: U32, +acc: U32) -> U32:
  match n:
    case 0: acc
    case _: nl_cls_go(U32.shr(n), U32.inc(acc))

@unsafe
def nl_cls_fit(+n: U32) -> U32:
  nt_choose(U32, U32.is_le(n, 1), u => 0, u => nl_cls_go(U32.sub(n, 1), 0))

@unsafe
def nl_has_box(+xs: List<&2, N_WordKind>) -> Bool:
  match xs:
    case Nil{}: False{}
    case Con{N_W32{}, t}: nl_has_box(t)
    case Con{_, t}: True{}
