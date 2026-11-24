# bend5k/main.bend — Minimal Phase 0 Smoke Stub
# =============================================
# Verifies SymTab, ByteBuf, AST/IR/X64 ADTs and helpers end-to-end.

def b5k_smoke_step3(id1: U32, id2: U32, r3: SymRes) -> U32:
  match r3:
    case SymRes{+st3, +id3}:
      bb0 = bb_emit_u32(bb_emit_u8(bb_new(), 144), 305419896)
      bb1 = bb_emit_cstr(bb0, symtab_name(st3, id2))
      nbytes = b5k_u32_list_len(bb_to_bytes(bb1))
      eq_ok = Bool.to_u32(b5k_str_eq(symtab_name(st3, id3), "main"))
      id_ok = Bool.to_u32(U32.is_eq(id1, id3))
      U32.add(U32.add(nbytes, U32.add(eq_ok, id_ok)), symtab_count(st3))

def b5k_smoke_step2(id1: U32, r2: SymRes) -> U32:
  match r2:
    case SymRes{st2, id2}:
      b5k_smoke_step3(id1, id2, symtab_intern(st2, "main"))

def b5k_smoke_step1(r1: SymRes) -> U32:
  match r1:
    case SymRes{st1, id1}:
      b5k_smoke_step2(id1, symtab_intern(st1, "add"))

def b5k_smoke() -> U32:
  b5k_smoke_step1(symtab_intern(symtab_new(), "main"))

def main() -> IO(Unit):
  IO.print(b5k_u32_to_str(b5k_smoke()))
