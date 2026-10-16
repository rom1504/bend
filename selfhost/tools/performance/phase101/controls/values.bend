import Base

# Observe characters as decimal U32 words, including non-Unicode Char values.
def p101_codes(text: String) -> String:
  match text:
    case SNil{}: ""
    case SCon{head, tail}: U32.show(Char.to_u32(head)) ++ "," ++ p101_codes(tail)

def p101_row(label: String, +text: String) -> IO(Unit):
  IO.print(label ++ "\t" ++ Nat.show(String.length(text)) ++ "\t" ++ p101_codes(text))

def p101_bool(label: String, value: Bool) -> IO(Unit):
  IO.print(label ++ "\t" ++ U32.show(Bool.to_u32(value)))

def p101_order(order: Cmp) -> String:
  match order:
    case LT{}: "LT"
    case EQ{}: "EQ"
    case GT{}: "GT"

def p101_compare(label: String, result: (String & String) & Cmp) -> IO(Unit):
  ((left, right), order) = result
  IO.print(label ++ "\t" ++ p101_order(order) ++ "\t" ++ p101_codes(left) ++ "\t" ++ p101_codes(right))

# The root and extracted tail are both used after matching. Nested ownership
# and a tail escaping a disposed enclosing product must retain their values.
type P101Pair is Data:
  P101Pair{left: String, right: String}

def p101_escape(pair: P101Pair) -> String:
  match pair:
    case P101Pair{left, right}: String.drop(left, 1n)

def p101_match_twice(text: String) -> String:
  match text:
    case SNil{}: ""
    case SCon{head, +tail}: tail ++ tail ++ SCon{head, tail}

def main() -> IO(Unit):
  +text : String = "A\0λ🙂z"
  +tail : String = String.drop(text, 1n)
  +words : String = String.from_list([Chr{0}, Chr{127}, Chr{128}, Chr{2047}, Chr{2048}, Chr{55295}, Chr{55296}, Chr{57343}, Chr{57344}, Chr{65535}, Chr{65536}, Chr{1114111}, Chr{1114112}, Chr{4294967295}])
  +large : String = String.repeat("aλ🙂\0", 33n)
  +escaped : String = p101_escape(P101Pair{"x" ++ tail, text})
  do IO<Unit>:
    p101_row("empty", "")
    p101_row("literal", text)
    p101_row("alias-tail", tail)
    p101_row("alias-root", text)
    p101_row("escaped", escaped)
    p101_row("match-twice", p101_match_twice(text))
    p101_row("append-empty-left", "" ++ text)
    p101_row("append-empty-right", text ++ "")
    p101_row("append-self", text ++ text)
    p101_row("append-shared-tail", text ++ tail)
    p101_row("reverse", String.reverse(text))
    p101_row("take-0", String.take(text, 0n))
    p101_row("take-3", String.take(text, 3n))
    p101_row("take-beyond", String.take(text, 99n))
    p101_row("drop-beyond", String.drop(text, 99n))
    p101_row("list-roundtrip", String.from_list(String.to_list(text)))
    p101_row("all-u32", words)
    p101_row("all-u32-tail", String.drop(words, 7n))
    p101_row("all-u32-reverse", String.reverse(words))
    p101_row("chunk-boundaries", large)
    p101_row("chunk-middle", String.take(String.drop(large, 31n), 66n))
    p101_compare("cmp-empty", String.cmp("", text))
    p101_compare("cmp-self", String.cmp(text, text))
    p101_compare("cmp-prefix", String.cmp("A", text))
    p101_compare("cmp-late", String.cmp("aλ🙂x", "aλ🙂y"))
    p101_compare("cmp-earlier", String.cmp("b", "aa"))
    p101_compare("cmp-u32", String.cmp(SCon{Chr{4294967295}, ""}, SCon{Chr{1114111}, ""}))
    p101_bool("eq-high-bits", String.eq("Ł", "A"))
    p101_bool("eq-nul-tail", String.eq("a\0x", "a\0y"))
    p101_bool("eq-rebuilt", String.eq(text, String.from_list(String.to_list(text))))
    p101_row("live-after-observers", text ++ escaped)
