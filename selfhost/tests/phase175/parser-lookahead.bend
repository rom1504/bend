# Separate overlay: use original f_prec unless the precedence experiment is
# explicitly combined. Preserve parser calls, cursor values and failure paths.
@unsafe
def f_grow_base(+p: FParsed, +min: U32) -> FParsed:
  match p:
    case FParsed{n,ts}:
      f_choose(FParsed,f_eq(tg(n),"Error"),u => FParsed{n,ts},
        u => p175p_grow_word(n,ts,min,f_tx(ts)))

@unsafe
def p175p_grow_word(n,ts,min,word):
  f_choose(FParsed,f_eq(word,"("),u => f_context_call(n,ts,min),u =>
    f_choose(FParsed,U32.is_gt(f_prec(word),min) || (f_eq(word,"<") && U32.is_eq(ke(n),f_begin(ts))),
      u => p175p_grow_operator(n,ts,min,word),u => FParsed{n,ts}))

@unsafe
def p175p_grow_operator(n,ts,min,word):
  f_choose(FParsed,f_eq(word,"%") || f_eq(word,"-"),
    u => p175p_grow_sign(n,ts,min,word,f_tl(ts)),
    u => p175p_grow_shift(n,ts,min,word))

@unsafe
def p175p_grow_sign(n,ts,min,word,next):
  f_choose(FParsed,U32.is_eq(f_col(next),U32.add(f_col(ts),1)) && Char.is_alpha(f_head(f_tx(next))),
    u => FParsed{n,ts},u => p175p_grow_shift(n,ts,min,word))

@unsafe
def p175p_grow_shift(n,ts,min,word):
  f_choose(FParsed,f_eq(word,">"),u => FParsed{n,ts},u =>
    f_choose(FParsed,f_eq(word,">>") && p175p_shift_end(f_tx(f_tl(ts))),
      u => FParsed{n,ts},u => f_binary_start(n,ts,min)))

@unsafe
def p175p_shift_end(word):
  f_eq(word,")") || f_eq(word,"}") || f_eq(word,",") || f_eq(word,":") ||
  f_eq(word,">") || f_eq(word,"\n") || f_eq(word,"->") || f_eq(word,"<eof>") || f_eq(word,"]")

@unsafe
def f_grow_existing(+p: FParsed, +min: U32) -> FParsed:
  match p:
    case FParsed{n,ts}:
      +word = f_tx(ts)
      f_choose(FParsed,f_eq(word,"\n"),
        u => p175p_grow_newline(n,ts,min,f_skip(ts)),
        u => p175p_grow_suffix(n,ts,min,word))

@unsafe
def p175p_grow_newline(n,ts,min,skipped):
  +word = f_tx(skipped)
  f_choose(FParsed,U32.is_gt(f_prec(word),0) && Bool.not((f_eq(word,"%") || f_eq(word,"-")) && U32.is_eq(f_col(f_tl(skipped)),U32.add(f_col(skipped),1))),
    u => f_grow_base(FParsed{n,skipped},min),
    u => p175p_grow_suffix(n,ts,min,"\n"))

@unsafe
def p175p_grow_suffix(n,ts,min,word):
  f_choose(FParsed,f_eq(word,"!"),u => p175p_grow_bang(n,ts,min,f_tl(ts)),u =>
    f_choose(FParsed,f_eq(word,"["),u => f_index(n,f_expect(f_expr(f_tl(ts),0),"]"),min),
      u => f_grow_base(FParsed{n,ts},min)))

@unsafe
def p175p_grow_bang(n,ts,min,next):
  f_choose(FParsed,f_eq(f_tx(next),"(") && U32.is_eq(f_line(ts),f_line(next)) && U32.is_eq(f_col(next),U32.add(f_col(ts),1)),
    u => f_bang(f_context_call_head(n),ts,min),u => f_grow_base(FParsed{n,ts},min))
