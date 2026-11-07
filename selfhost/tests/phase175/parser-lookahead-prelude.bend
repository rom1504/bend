law p175p_grow_word:
  for +n: KTerm
  for +ts: FInput
  for +min: U32
  for +word: String
  FParsed
law p175p_grow_operator:
  for +n: KTerm
  for +ts: FInput
  for +min: U32
  for +word: String
  FParsed
law p175p_grow_sign:
  for +n: KTerm
  for +ts: FInput
  for +min: U32
  for +word: String
  for +next: FInput
  FParsed
law p175p_grow_shift:
  for +n: KTerm
  for +ts: FInput
  for +min: U32
  for +word: String
  FParsed
law p175p_shift_end:
  for +word: String
  Bool
law p175p_grow_newline:
  for +n: KTerm
  for +ts: FInput
  for +min: U32
  for +skipped: FInput
  FParsed
law p175p_grow_suffix:
  for +n: KTerm
  for +ts: FInput
  for +min: U32
  for +word: String
  FParsed
law p175p_grow_bang:
  for +n: KTerm
  for +ts: FInput
  for +min: U32
  for +next: FInput
  FParsed
