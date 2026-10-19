# ABI11101-only private helper exposure. Mandatory whole-program verification
# precedes rendering, unchanged from Phase111. The original owning graph remains
# visible to worker planning; only the final statement rendering expands helpers.
# Modes: 0 unchanged, 1 pure auxiliary-tag extraction, 2 register reads, 3 both.

@unsafe
def p112a_tag(+name: String, word: N111Value) -> List<&2, N111Stmt>:
  [N111Bin{name, N111U64{}, "shr", word, N111Const{40, 0}},
   N111Bin{name, N111U64{}, "and", N111Local{name}, N111Const{65535, 0}}]

@unsafe
def p112a_expand(+mode: U32, +stmt: N111Stmt) -> List<&2, N111Stmt>:
  match stmt:
    case N111Call{+name, N111U64{}, +symbol, Con{N111Arg{N111Ptr{}, N111Local{+context}}, Con{N111Arg{N111U64{}, +word}, Nil{}}}}:
      nt_choose(List<&2, N111Stmt>, (U32.is_eq(mode, 1) || U32.is_eq(mode, 3)) && String.eq(symbol, "p111_rt_tag") && String.eq(context, "state"),
        u => p112a_tag(name, word), u => [stmt])
    case N111Call{+name, N111U64{}, +symbol, Con{N111Arg{N111Ptr{}, N111Local{+context}}, Con{N111Arg{N111U32{}, N111Const{+index, +high}}, Nil{}}}}:
      nt_choose(List<&2, N111Stmt>, (U32.is_eq(mode, 2) || U32.is_eq(mode, 3)) && String.eq(symbol, "p111_rt_reg_get") && String.eq(context, "state") && U32.is_eq(high, 0) && U32.is_lt(index, 255),
        u => [N111Load{name, N111U64{}, N111Local{"state"}, U32.add(40, U32.mul(index, 8))}], u => [stmt])
    case _: [stmt]

# Expansion outputs are rendered through the exact original renderer. Thus an
# unchanged call cannot recurse through expansion. Original nested If rendering
# still visits the globally selected statement entry for each child statement.
@unsafe
def p112a_words(words: List<&2, N111Stmt>, +ids: N111Ids, +code: P111QCode) -> P111QCode:
  match words:
    case Nil{}: code
    case Con{head, rest}: p112a_words(rest, ids, p112a_original_stmt(head, ids, code))

@unsafe
def p112a_stmt(mode: U32, stmt: N111Stmt, ids: N111Ids, code: P111QCode) -> P111QCode:
  p112a_words(p112a_expand(mode, stmt), ids, code)
