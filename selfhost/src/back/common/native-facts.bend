
# Module: src/back/common/native-facts.bend:6
@unsafe
def j_u32_native_ctor(+book: List<&2,KDef>, +owner: String, +name: String) -> Bool:
  +d = lookup(book, owner)
  +c = lookup(dc(d), name)
  p88_string_eq(dk(d), "ADT") && db(d) && p88_string_eq(dk(c), "Ctr") && db(c)

# Module: src/back/common/native-facts.bend:12
@unsafe
def j_u32_native_book(+book: List<&2,KDef>) -> Bool:
  j_u32_native_ctor(book, "U32", "U32") &&
  j_u32_native_ctor(book, "Word.Nil", "WNil") &&
  j_u32_native_ctor(book, "Word.Con", "WCon") &&
  j_u32_native_ctor(book, "Bool", "False") &&
  j_u32_native_ctor(book, "Bool", "True") &&
  p88_string_eq(dk(lookup(book, "Word")), "Def") && db(lookup(book, "Word"))
