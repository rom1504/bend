# Phase155 frontend tournament, ID18. Append after maintained declarations.
# ID17 is rejected by source audit; it has no timing entry.
# Both roles run the current Phase150 scalar lexer, then consume every token
# field/text and the complete name-validity result. No saved-token input.

def p155x_choose(-A: Type, b: Bool, yes: Unit -> A, no: Unit -> A) -> A:
  match b:
    case True{}: yes(Unit{})
    case False{}: no(Unit{})

# These are exact little-endian ASCII spellings, not hashes. Length is part
# of the key. The old predicate's 16 reserved spellings are the whole set.
def p155x_reserved(length: U32, +lo: U32, +hi: U32) -> Bool:
  match length:
    case 2: U32.is_eq(lo,28516) || U32.is_eq(lo,29545)
    case 3: U32.is_eq(lo,6710628) || U32.is_eq(lo,7823724) || U32.is_eq(lo,7499622) || U32.is_eq(lo,7567461)
    case 4: U32.is_eq(lo,1701869940) || U32.is_eq(lo,1702060387) || U32.is_eq(lo,1701869908) || U32.is_eq(lo,1635017028) || U32.is_eq(lo,1684957515)
    case 5: (U32.is_eq(lo,1668571501) && U32.is_eq(hi,104)) || (U32.is_eq(lo,1919248503) && U32.is_eq(hi,101)) || (U32.is_eq(lo,1851880785) && U32.is_eq(hi,116))
    case 6: (U32.is_eq(lo,1970562418) && U32.is_eq(hi,28274)) || (U32.is_eq(lo,1869639017) && U32.is_eq(hi,29810))
    case _: False{}

def p155x_start(+code: U32) -> Bool:
  U32.is_le(U32.sub(U32.or(code,32),97),25) || U32.is_eq(code,95)

def p155x_ident(+code: U32) -> Bool:
  p155x_start(code) || U32.is_le(U32.sub(code,48),9) || U32.is_eq(code,46)

# Fixed byte positions avoid converting a runtime shift distance to Nat.
def p155x_place(code: U32, slot: U32) -> U32:
  match slot:
    case 0: code
    case 1: U32.mul(code,256)
    case 2: U32.mul(code,65536)
    case 3: U32.mul(code,16777216)
    case _: 0

# A capped length avoids wraparound after long valid input and guarantees
# that characters beyond six never alias a reserved word's exact key.
@unsafe
def p155x_cursor(s: String, +need_start: Bool, +length: U32, +lo: U32, +hi: U32) -> Bool:
  match s:
    case SNil{}: Bool.not(need_start) && Bool.not(p155x_reserved(length,lo,hi))
    case SCon{head,tail}:
      +code = Char.to_u32(head)
      p155x_choose(Bool,p155x_ident(code) && (Bool.not(need_start) || p155x_start(code)),
        u => p155x_cursor(tail,U32.is_eq(code,46),
          p155x_choose(U32,U32.is_lt(length,7),u => U32.add(length,1),u => 7),
          p155x_choose(U32,U32.is_lt(length,4),u => U32.or(lo,p155x_place(code,length)),u => lo),
          p155x_choose(U32,U32.is_ge(length,4) && U32.is_lt(length,6),u => U32.or(hi,p155x_place(code,U32.sub(length,4))),u => hi)),
        u => False{})

def p155x_valid(s: String) -> Bool:
  p155x_cursor(s,True{},0,0,0)

def p155x_mix(hash: U32, value: U32) -> U32:
  U32.mul(U32.xor(hash,value),16777619)

@unsafe
def p155x_text(text: String, hash: U32) -> U32:
  match text:
    case SNil{}: p155x_mix(hash,1100000)
    case SCon{head,tail}: p155x_text(tail,p155x_mix(hash,Char.to_u32(head)))

@unsafe
def p155x_tokens(tokens: List<&2,FToken>, +changed: Bool, hash: U32) -> U32:
  match tokens:
    case Nil{}: p155x_mix(hash,20)
    case Con{FToken{+text,line,column,kind,begin,end,previous},tail}:
      +valid = p155x_choose(Bool,changed,u => p155x_valid(text),u => f_valid_name(text))
      p155x_tokens(tail,changed,p155x_mix(
        p155x_mix(p155x_mix(p155x_mix(p155x_mix(p155x_mix(p155x_mix(
          p155x_text(text,hash),line),column),kind),begin),end),previous),
        p155x_choose(U32,valid,u => 1,u => 0)))

# Each repetition creates a fresh valid source with a changing numeric literal.
# Keywords, names, qualified names, punctuation and numeric tokens all pass
# through the real lexer and the complete consumed predicate observation.
def p155x_source(n: U32) -> String:
  "import Base\ndef tally(input: U32, offset: U32) -> U32:\n  U32.add(input, offset)\ndef bump(x: U32) -> U32:\n  U32.add(x, " ++ U32.show(U32.and(n,31)) ++ ")\n"

@unsafe
def p155x_repeat(+n: U32, +changed: Bool, hash: U32) -> U32:
  match n:
    case 0: hash
    case _:
      +p = U32.sub(n,1)
      p155x_repeat(p,changed,p155x_tokens(f_lex_cursor(p155x_source(p),1,0,0,[],1,1),changed,hash))

def p155x_name_old(n: U32) -> String:
  U32.show(p155x_repeat(n,False{},2166136261))

def p155x_name_new(n: U32) -> String:
  U32.show(p155x_repeat(n,True{},2166136261))

# Independent expected predicate truth, distinct from valid-source parse status.
def p155x_case(+name: String, +want: Bool) -> Bool:
  Bool.not(Bool.xor(f_valid_name(name),want)) && Bool.not(Bool.xor(p155x_valid(name),want))

@unsafe
def p155x_cases(names: List<&2,String>, +want: Bool) -> Bool:
  match names:
    case Nil{}: True{}
    case Con{name,rest}: p155x_case(name,want) && p155x_cases(rest,want)

def p155x_controls(unused: U32) -> String:
  p155x_choose(String,
    p155x_cases(["x","_","_x9","a.b","a._b","a.b.c.d.e.f.g","Typex","typex","DEF","deF","returning","data","kind","quant","NaN","a0","a._"],True{}) &&
    p155x_cases(["",".a","a.","a..b","a.7","7x","x\0y","é","a+z","def","type","law","match","case","do","return","for","exs","where","is","import","Type","Data","Kind","Quant"],False{}),
    u => "ok",u => "mismatch")

# No main: the root-owned tournament supplies the checked entry/observer.
