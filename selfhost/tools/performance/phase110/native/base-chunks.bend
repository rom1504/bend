# Exact sequential text comparison. A separate literal helper bounds each
# compiled constructor body; no digest or cache stamp substitutes for equality.
@unsafe
def p110_base_prefix(actual: String, expected: String) -> Maybe<&2,String>:
  match expected:
    case SNil{}: Some{actual}
    case SCon{want,more}: p110_base_prefix_head(actual,want,more)

@unsafe
def p110_base_prefix_head(actual: String, want: Char, more: String) -> Maybe<&2,String>:
  match actual:
    case SNil{}: None{}
    case SCon{have,rest}: p110_base_prefix_equal(Char.is_eq(have,want),rest,more)

@unsafe
def p110_base_prefix_equal(equal: Bool, actual: String, expected: String) -> Maybe<&2,String>:
  match equal:
    case False{}: None{}
    case True{}: p110_base_prefix(actual,expected)

# Count only through the expected end plus one, so unexpected large inputs
# cannot wrap the U32 length check.
@unsafe
def p110_base_size(text: String, +size: U32) -> U32:
  match text:
    case SNil{}: size
    case SCon{char,rest}: p110_base_size_more(U32.is_lt(size,p110_general_base_expected_length()),rest,size)

@unsafe
def p110_base_size_more(allowed: Bool, text: String, size: U32) -> U32:
  match allowed:
    case False{}: U32.inc(p110_general_base_expected_length())
    case True{}: p110_base_size(text,U32.inc(size))

@unsafe
def p110_general_base_matches(+text: String) -> Bool:
  p110_base_length_checked(U32.is_eq(p110_base_size(text,0),p110_general_base_expected_length()),text)

@unsafe
def p110_base_length_checked(equal: Bool, text: String) -> Bool:
  match equal:
    case False{}: False{}
    case True{}: p110_base_chunk_0(text)
