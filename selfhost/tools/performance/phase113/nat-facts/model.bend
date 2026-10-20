# Optional exact type replacement. Existing constructors retain their order.
# N_Imm64 is an ownership fact, never a request for a U32 machine value.
type N_WordKind is Data:
  N_W32{}
  N_W64{}
  N_Box{}
  N_Imm64{}
