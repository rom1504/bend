import Base
import ./production.bend as P

# Proof support for the actual numeric-pattern literal recognizers. The Base
# comparator visits significant bits first; constructor patterns visit the
# stored low bit first. Their equal/not-equal result must agree for all bits.
def pattern_word_equal(n: Nat, a: Word(n), b: Word(n)) -> Bool:
  match n:
    case Zero{}: True{}
    case Succ{p}:
      match a b:
        case WCon{ah, at} WCon{bh, bt}:
          Bool.and(Cmp.is_eq(Bool.cmp(ah, bh)), pattern_word_equal(p, at, bt))

law comparison_finish_equal:
  for a: Bool
  for b: Bool
  for rest: Cmp
  {Cmp.is_eq(Word.cmp.fin(a, b, rest)) == Bool.and(Cmp.is_eq(Bool.cmp(a, b)), Cmp.is_eq(rest)) : Bool}

def comparison_finish_equal(a, b, rest):
  match a b rest:
    case False{} False{} LT{}: {==}
    case False{} False{} EQ{}: {==}
    case False{} False{} GT{}: {==}
    case False{} True{} LT{}: {==}
    case False{} True{} EQ{}: {==}
    case False{} True{} GT{}: {==}
    case True{} False{} LT{}: {==}
    case True{} False{} EQ{}: {==}
    case True{} False{} GT{}: {==}
    case True{} True{} LT{}: {==}
    case True{} True{} EQ{}: {==}
    case True{} True{} GT{}: {==}

law word_pattern_equal:
  for +n: Nat
  for a: Word(n)
  for b: Word(n)
  {Cmp.is_eq(Word.cmp(n, a, b)) == pattern_word_equal(n, a, b) : Bool}

def word_pattern_equal(n, a, b):
  match n:
    case Zero{}: {==}
    case Succ{+p}:
      match a b:
        case WCon{+ah, +at} WCon{+bh, +bt}:
          %word_pattern_equal(p, at, bt) : {Cmp.is_eq(Word.cmp.fin(ah, bh, Word.cmp(p, at, bt))) == Bool.and(Cmp.is_eq(Bool.cmp(ah, bh)), _) : Bool}
          comparison_finish_equal(ah, bh, Word.cmp(p, at, bt))

def pattern_char_equal(a: Char, b: Char) -> Bool:
  match a b:
    case Chr{U32{av}} Chr{U32{bv}}:
      pattern_word_equal(32n, av, bv)

law char_pattern_equal:
  for a: Char
  for b: Char
  {Char.is_eq(a, b) == pattern_char_equal(a, b) : Bool}

def char_pattern_equal(a, b):
  match a b:
    case Chr{U32{av}} Chr{U32{bv}}:
      word_pattern_equal(32n, av, bv)

def pattern_string_equal(a: String, b: String) -> Bool:
  match a b:
    case SNil{} SNil{}: True{}
    case SNil{} SCon{head, tail}: False{}
    case SCon{head, tail} SNil{}: False{}
    case SCon{ah, at} SCon{bh, bt}:
      Bool.and(pattern_char_equal(ah, bh), pattern_string_equal(at, bt))

law string_pattern_invariant:
  for a: String
  for b: String
  for same: Bool
  {P.p88_string_eq_go(a, b, same) == Bool.and(same, pattern_string_equal(a, b)) : Bool}

def string_pattern_invariant(a, b, same):
  match a b same:
    case SNil{} SNil{} False{}: {==}
    case SNil{} SNil{} True{}: {==}
    case SNil{} SCon{head, tail} False{}: {==}
    case SNil{} SCon{head, tail} True{}: {==}
    case SCon{head, tail} SNil{} False{}: {==}
    case SCon{head, tail} SNil{} True{}: {==}
    case SCon{ah, at} SCon{bh, bt} False{}: {==}
    case SCon{+ah, at} SCon{+bh, bt} True{}:
      %char_pattern_equal(ah, bh) : {P.p88_string_eq_go(at, bt, Char.is_eq(ah, bh)) == Bool.and(_, pattern_string_equal(at, bt)) : Bool}
      string_pattern_invariant(at, bt, Char.is_eq(ah, bh))

law string_pattern_exact:
  for a: String
  for b: String
  {P.p88_string_eq(a, b) == pattern_string_equal(a, b) : Bool}

def string_pattern_exact(a, b):
  string_pattern_invariant(a, b, True{})

#|ALL PROOFS CHECK
#|Use --verdict for mathematical validity.
