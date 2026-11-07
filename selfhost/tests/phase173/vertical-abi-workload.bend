# Ordinary source controls for boxed nested product -> verified flat argument.
# These exercise unique/shared values and a bounded source-tail recursive cycle.
# No malformed runtime values or foreign memory are constructed.

type P173VAProduct is Data:
  P173VAProduct{+word: U32, +values: List<&2,U32>, +label: String}

type P173VAOptional is Data:
  P173VANone{}
  P173VASome{+value: P173VAProduct}

law p173va_even:
  for +node: P173VAProduct
  for count: U32
  U32 & U32

law p173va_odd:
  for pair: P173VAProduct & U32
  U32 & U32

@unsafe
def p173va_make(+value: U32) -> P173VAProduct & U32:
  (P173VAProduct{value,[value,U32.inc(value)],"kept"},U32.add(value,5))

@unsafe
def p173va_observe(node: P173VAProduct, salt: U32) -> U32 & U32:
  match node:
    case P173VAProduct{word,values,label}:
      (U32.add(word,nt_count(U32,values)),U32.add(salt,Bool.to_u32(String.eq(label,"kept"))))

@unsafe
def p173va_from(pair: P173VAProduct & U32) -> U32 & U32:
  match pair:
    case Tuple{node,salt}: p173va_observe(node,salt)

@unsafe
def p173va_values(pair: U32 & U32) -> List<&2,U32>:
  match pair:
    case Tuple{first,second}: [first,second]

@unsafe
def p173va_join(first: U32 & U32, second: U32 & U32) -> List<&2,U32>:
  match first second:
    case Tuple{a,b} Tuple{c,d}: [a,b,c,d]

@unsafe
def p173va_shared(pair: P173VAProduct & U32) -> List<&2,U32>:
  match pair:
    case Tuple{+node,salt}: p173va_join(p173va_observe(node,salt),p173va_observe(node,100))

@unsafe
def p173va_two(first: P173VAProduct, second: P173VAProduct, salt: U32) -> U32 & U32:
  match first second:
    case P173VAProduct{a,xs,left} P173VAProduct{b,ys,right}:
      (U32.add(U32.add(a,b),U32.add(nt_count(U32,xs),nt_count(U32,ys))),
        U32.add(salt,U32.add(Bool.to_u32(String.eq(left,"kept")),Bool.to_u32(String.eq(right,"kept")))))

@unsafe
def p173va_both(pair: P173VAProduct & U32) -> U32 & U32:
  match pair:
    case Tuple{+node,salt}: p173va_two(node,node,salt)

@unsafe
def p173va_optional(option: P173VAOptional, salt: U32) -> U32 & U32:
  match option:
    case P173VANone{}: (0,salt)
    case P173VASome{node}: p173va_observe(node,salt)

@unsafe
def p173va_even(node,count):
  match count:
    case 0: p173va_observe(node,0)
    case _: p173va_odd((node,U32.sub(count,1)))

@unsafe
def p173va_odd(pair):
  match pair:
    case Tuple{node,count}: p173va_even(node,count)

@unsafe
def p173va_cycle(pair: P173VAProduct & U32, count: U32) -> U32 & U32:
  match pair:
    case Tuple{node,salt}: p173va_even(node,count)

@unsafe
def p173va_run() -> List<&2,U32>:
  nt_append(U32,p173va_values(p173va_from(p173va_make(7))),
    nt_append(U32,p173va_shared(p173va_make(7)),
      nt_append(U32,p173va_values(p173va_both(p173va_make(7))),
        nt_append(U32,p173va_values(p173va_optional(P173VANone{},17)),
          nt_append(U32,p173va_values(p173va_optional(P173VASome{P173VAProduct{3,[1,2],"kept"}},4)),
            p173va_values(p173va_cycle(p173va_make(7),65536)))))))

def main() -> List<&2,U32>:
  p173va_run()

#| [9,13,9,13,9,101,18,14,0,17,5,5,9,1]
