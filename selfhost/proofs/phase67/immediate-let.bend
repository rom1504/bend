# Native immediate-let continuation contraction.
# A saved frame transports ordered held words and one already computed word.
# The local form builds the identical body environment without that frame.
# No import, @unsafe declaration, foreign code, axiom or numeric primitive.
# See README.md for the production correspondence and trusted boundary.

type NP_Words<-W: Data> is Data:
  NP_Empty{}
  NP_Word{word: W, rest: NP_Words<W>}

type NP_Frame<-W: Data> is Data:
  NP_Saved{held: NP_Words<W>, result: W}

type NP_Sequence<-W: Data> is Data:
  NP_End{}
  NP_Bind{value: W, rest: NP_Sequence<W>}

def np_append(-W: Data, held: NP_Words<W>, value: W) -> NP_Words<W>:
  match held:
    case NP_Empty{}: NP_Word{value, NP_Empty{}}
    case NP_Word{word, rest}: NP_Word{word, np_append(W, rest, value)}

def np_resume(-W: Data, -R: Type, frame: NP_Frame<W>, body: NP_Words<W> -> R) -> R:
  match frame:
    case NP_Saved{held, value}: body(np_append(W, held, value))

def np_local(-W: Data, -R: Type, held: NP_Words<W>, value: W, body: NP_Words<W> -> R) -> R:
  body(np_append(W, held, value))

law np_contract:
  for -W: Data
  for -R: Type
  for -held: NP_Words<W>
  for -value: W
  for -body: NP_Words<W> -> R
  {np_resume(W, R, NP_Saved{held, value}, body) == np_local(W, R, held, value, body) : R}

def np_contract(W, R, held, value, body):
  {==}

# The sequence theorem composes contraction for arbitrarily many immediate
# bindings, preserving order. R may include an observable result/trace; only
# frame allocation and dispatch itself are absent from this model.
def np_framed(-W: Data, -R: Type, seq: NP_Sequence<W>, held: NP_Words<W>, body: NP_Words<W> -> R) -> R:
  match seq:
    case NP_End{}: body(held)
    case NP_Bind{value, rest}:
      np_resume(W, R, NP_Saved{held, value}, next => np_framed(W, R, rest, next, body))

def np_straight(-W: Data, -R: Type, seq: NP_Sequence<W>, held: NP_Words<W>, body: NP_Words<W> -> R) -> R:
  match seq:
    case NP_End{}: body(held)
    case NP_Bind{value, rest}:
      np_local(W, R, held, value, next => np_straight(W, R, rest, next, body))

law np_sequence_contract:
  for -W: Data
  for -R: Type
  for seq: NP_Sequence<W>
  for -held: NP_Words<W>
  for -body: NP_Words<W> -> R
  {np_framed(W, R, seq, held, body) == np_straight(W, R, seq, held, body) : R}

def np_sequence_contract(W, R, seq, held, body):
  match seq:
    case NP_End{}: {==}
    case NP_Bind{value, rest}:
      np_sequence_contract(W, R, rest, np_append(W, held, value), body)

#|ALL PROOFS CHECK
#|Use --verdict for mathematical validity.
