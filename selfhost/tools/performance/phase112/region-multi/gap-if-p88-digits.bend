import Base

type P88Cursor is Data:
  P88Cursor{+text: String, +ok: Bool}
type P88Number is Data:
  P88Number{+cursor: P88Cursor, +value: U32}

@unsafe
def p88_digits(text: String, +acc: U32, +digits: U32) -> P88Number:
  match text:
    case SCon{'\n', tail}: P88Number{P88Cursor{tail, U32.is_ne(digits, 0)}, acc}
    case SCon{Chr{c}, tail}:
      +d = U32.sub(c, 48)
      p88_digit(tail, acc, digits, d, U32.is_lt(d, 10) && U32.is_lt(digits, 10) && (U32.is_eq(digits, 0) || U32.is_ne(acc, 0)) && (U32.is_lt(acc, 429496729) || (U32.is_eq(acc, 429496729) && U32.is_le(d, 5))))
    case other: P88Number{P88Cursor{"", False{}}, 0}

@unsafe
def p88_digit(text: String, acc: U32, digits: U32, digit: U32, ok: Bool) -> P88Number:
  match ok:
    case True{}: p88_digits(text, U32.add(U32.mul(acc, 10), digit), U32.inc(digits))
    case False{}: P88Number{P88Cursor{"", False{}}, 0}

def p112_digits_value(number: P88Number) -> U32:
  match number:
    case P88Number{P88Cursor{+text,True{}},+value}: value
    case _: 0

def main() -> U32:
  p112_digits_value(p88_digits("123456789\n",0,0))
