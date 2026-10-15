import Base

# Both are valid owning computations, but neither can become a borrowed root
# observer under the retained schema: Array is mutable and Word is allocating.
def p98_array_probe(array: Array<U32>) -> Array<U32> & U32:
  Array.size(U32, array)

def p98_word_view(+word: U32) -> U32 & U32:
  match word:
    case U32{bits}: (word, U32{bits})

def p98_array_answer(pair: Array<U32> & U32) -> U32:
  (array, size) = pair
  size

def p98_word_answer(pair: U32 & U32) -> U32:
  (left, right) = pair
  U32.add(left, right)

def main() -> U32:
  U32.add(p98_array_answer(p98_array_probe(Array.new(U32, 2n, 7))),
    p98_word_answer(p98_word_view(13)))

#|30
