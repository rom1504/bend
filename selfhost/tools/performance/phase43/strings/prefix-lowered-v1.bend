def j_string_u32_call_prefix(+book: List<&2,KDef>, +env: List<&2,KTerm>, +t: KTerm) -> Bool:
  +head = j_strip(t)
  +spine = kc(KTerm, String.eq(tg(head), "JDirectCall"),
    u => kt("Call", nm(head), 0, 0, ks(head)), u => j_call_spine(head, Nil{}))