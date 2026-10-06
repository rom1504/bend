import Base

# Shared checked Base declaration provenance. These inspect definitions, not runtime values.

@unsafe
def j_u32_native_ctor(+book: List<&2,KDef>, +owner: String, +name: String) -> Bool:
  +d = lookup(book, owner)
  +c = lookup(dc(d), name)
  String.eq(dk(d), "ADT") && db(d) && String.eq(dk(c), "Ctr") && db(c)

@unsafe
def j_u32_native_book(+book: List<&2,KDef>) -> Bool:
  j_u32_native_ctor(book, "U32", "U32") &&
  j_u32_native_ctor(book, "Word.Nil", "WNil") &&
  j_u32_native_ctor(book, "Word.Con", "WCon") &&
  j_u32_native_ctor(book, "Bool", "False") &&
  j_u32_native_ctor(book, "Bool", "True") &&
  String.eq(dk(lookup(book, "Word")), "Def") && db(lookup(book, "Word"))
