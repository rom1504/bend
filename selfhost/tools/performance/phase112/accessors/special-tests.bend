# Exact special-test semantics; arrays and generic constructors retain the original path.
@unsafe
def p112_special_test_fallback(+name: String, +word: N111Value) -> List<&2, N111Stmt>:
  +kind = p111_special(name)
  nt_choose(List<&2, N111Stmt>, U32.is_eq(kind, 0),
    u => [N111Call{"tag", N111U64{}, "p111_rt_tag", [p111_state(), p111_word(word)]}, N111Bin{"match_condition", N111U64{}, "eq", N111Local{"tag"}, N111CtorId{name}}],
    u => [N111Call{"test", N111U64{}, "p111_rt_special_test", [p111_state(), p111_u32(kind), p111_word(word)]}, N111Bin{"match_condition", N111U64{}, "ne", N111Local{"test"}, N111Const{0, 0}}])

@unsafe
def p112_special_safe(word: N111Value) -> Bool:
  match word:
    case N111Local{+name}:
      Bool.not(String.eq(name, "p112_b_raw") || String.eq(name, "p112_b_bits") || String.eq(name, "p112_b_expected") || String.eq(name, "p112_b_boxed"))
    case _: True{}

# Bits40..55 are aux, bits56..62 are the7-bit tag; bit63 is RFC.
# A packed True may have arbitrary location bits and either RFC bit.
@unsafe
def p112_special_bool(+word: N111Value, invert: Bool) -> List<&2, N111Stmt>:
  nt_append(N111Stmt,
    [N111Bin{"p112_b_raw", N111U64{}, "eq", word, N111Const{1, 0}},
     N111Bin{"p112_b_bits", N111U64{}, "shr", word, N111Const{40, 0}},
     N111Bin{"p112_b_bits", N111U64{}, "and", N111Local{"p112_b_bits"}, N111Const{8388607, 0}},
     N111Bin{"p112_b_expected", N111U64{}, "or", N111CtorId{"True"}, N111Const{65536, 0}},
     N111Bin{"p112_b_boxed", N111U64{}, "eq", N111Local{"p112_b_bits"}, N111Local{"p112_b_expected"}},
     N111Bin{"match_condition", N111U32{}, "or", N111Local{"p112_b_raw"}, N111Local{"p112_b_boxed"}}],
    nt_choose(List<&2, N111Stmt>, invert,
      u => [N111Bin{"match_condition", N111U32{}, "xor", N111Local{"match_condition"}, N111Const{1, 0}}], u => []))

@unsafe
def p112_special_selected(+kind: U32, +word: N111Value) -> List<&2, N111Stmt>:
  nt_choose(List<&2, N111Stmt>, U32.is_le(kind, 2), u => p112_special_bool(word, U32.is_eq(kind, 1)), u =>
  nt_choose(List<&2, N111Stmt>, U32.is_eq(kind, 3), u => [N111Bin{"match_condition", N111U64{}, "eq", word, N111Const{0, 0}}], u =>
  nt_choose(List<&2, N111Stmt>, U32.is_eq(kind, 4), u => [N111Bin{"match_condition", N111U64{}, "ne", word, N111Const{0, 0}}],
    u => [N111Bin{"match_condition", N111U64{}, "eq", word, word}])))

@unsafe
def p112_special_test(+name: String, +word: N111Value) -> List<&2, N111Stmt>:
  +kind = p111_special(name)
  nt_choose(List<&2, N111Stmt>, U32.is_gt(kind, 0) && U32.is_le(kind, 7) && p112_special_safe(word),
    u => p112_special_selected(kind, word), u => p112_special_test_fallback(name, word))

@unsafe
def p111_test(+name: String, +word: N111Value) -> List<&2, N111Stmt>:
  p112_special_test(name, word)


