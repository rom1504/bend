# Four exact ASCII bytes per U32. Generation proves the complete byte inverse;
# runtime compares full Char codepoints, so non-ASCII input never aliases a byte.
@unsafe
def p110_base_packed_words(actual: String, words: List<&2,U32>) -> Maybe<&2,String>:
  match words:
    case Nil{}: Some{actual}
    case Con{word,rest}: p110_base_packed_continue(p110_base_packed_four(actual,word,4),rest)

@unsafe
def p110_base_packed_continue(first: Maybe<&2,String>, words: List<&2,U32>) -> Maybe<&2,String>:
  match first:
    case None{}: None{}
    case Some{actual}: p110_base_packed_words(actual,words)

@unsafe
def p110_base_packed_four(actual: String, word: U32, +left: U32) -> Maybe<&2,String>:
  p110_base_packed_remaining(U32.is_eq(left,0),actual,word,left)

@unsafe
def p110_base_packed_remaining(done: Bool, actual: String, word: U32, left: U32) -> Maybe<&2,String>:
  match done:
    case True{}: Some{actual}
    case False{}: p110_base_packed_head(actual,word,left)

@unsafe
def p110_base_packed_head(actual: String, +word: U32, left: U32) -> Maybe<&2,String>:
  match actual:
    case SNil{}: None{}
    case SCon{char,rest}:
      p110_base_packed_equal(U32.is_eq(Char.to_u32(char),U32.and(word,255)),rest,U32.shrn(word,8n),U32.sub(left,1))

@unsafe
def p110_base_packed_equal(equal: Bool, actual: String, word: U32, left: U32) -> Maybe<&2,String>:
  match equal:
    case False{}: None{}
    case True{}: p110_base_packed_four(actual,word,left)
