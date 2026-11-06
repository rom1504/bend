# Experimental suffix preservation. These five wrappers pass the same String
# through two distinct parameters. Match refinement may reconstruct `inspected`,
# but a non-consuming fallback returns the untouched `original` parameter.
# All lexical predicates, consuming tails and metadata arithmetic stay unchanged.
@unsafe
def p150l_word(+s: String, +acc: String, +n: U32, +last: Char) -> FScanned:
  p170ls_word(s,s,acc,n,last)

@unsafe
def p170ls_word(inspected: String, +original: String, +acc: String, +n: U32, +last: Char) -> FScanned:
  match inspected:
    case SNil{}: FScanned{String.reverse(acc),"",n}
    case SCon{+head,+rest}:
      f_choose(FScanned,f_choose(Bool,f_ident(head),u => True{},u =>
        (Char.is_eq(head,'+') || Char.is_eq(head,'-')) &&
          (Char.is_eq(last,'e') || Char.is_eq(last,'E')) && p150l_digit(rest)),
        u => p150l_word(rest,SCon{head,acc},U32.add(n,1),head),
        u => FScanned{String.reverse(acc),original,n})

@unsafe
def p150l_other(+head: Char, +rest: String, +l: U32, +c: U32, +d: U32, +acc: List<&2,FToken>, +offset: U32, +previous: U32) -> List<&2,FToken>:
  p170ls_other(head,rest,rest,l,c,d,acc,offset,previous)

@unsafe
def p170ls_other(+head: Char, inspected: String, +original: String, +l: U32, +c: U32, +d: U32, +acc: List<&2,FToken>, +offset: U32, +previous: U32) -> List<&2,FToken>:
  match inspected:
    case SCon{+second,SCon{+third,tail}}:
      f_choose(List<&2,FToken>,p150l_triple(head,second,third),
        u => p150l_emit(SCon{head,SCon{second,SCon{third,""}}},tail,l,c,d,acc,offset,previous,3,3),
        u => p150l_other_plain(head,original,l,c,d,acc,offset,previous))
    case _: p150l_other_plain(head,original,l,c,d,acc,offset,previous)

@unsafe
def p150l_symbol(+head: Char, +rest: String, +l: U32, +c: U32, +d: U32, +acc: List<&2,FToken>, +offset: U32, +previous: U32) -> List<&2,FToken>:
  p170ls_symbol(head,rest,rest,l,c,d,acc,offset,previous)

@unsafe
def p170ls_symbol(+head: Char, inspected: String, +original: String, +l: U32, +c: U32, +d: U32, +acc: List<&2,FToken>, +offset: U32, +previous: U32) -> List<&2,FToken>:
  match inspected:
    case SNil{}: p150l_single(head,"",l,c,d,acc,offset,previous)
    case SCon{+second,tail}:
      f_choose(List<&2,FToken>,p150l_pair(head,second),
        u => p150l_emit(SCon{head,SCon{second,""}},tail,l,c,d,acc,offset,previous,2,2),
        u => p150l_single(head,original,l,c,d,acc,offset,previous))

@unsafe
def p150l_plus_at(+rest: String, +l: U32, +c: U32, +d: U32, +acc: List<&2,FToken>, +offset: U32, +previous: U32, +contiguous: Bool) -> List<&2,FToken>:
  p170ls_plus(rest,rest,l,c,d,acc,offset,previous,contiguous)

@unsafe
def p170ls_plus(inspected: String, +original: String, +l: U32, +c: U32, +d: U32, +acc: List<&2,FToken>, +offset: U32, +previous: U32, +contiguous: Bool) -> List<&2,FToken>:
  match inspected:
    case SNil{}: p150l_emit("+","",l,c,d,acc,offset,previous,1,1)
    case SCon{+head,tail}:
      f_choose(List<&2,FToken>,f_ascii_char_eq(head,'+'),
        u => f_choose(List<&2,FToken>,contiguous,
          v => p150l_emit("+",original,l,c,d,acc,offset,previous,1,1),
          v => p150l_emit("++",tail,l,c,d,acc,offset,previous,2,2)),
        u => p150l_emit(f_choose(String,f_ascii_alpha(head) && Bool.not(contiguous),v => "+bind",v => "+"),original,l,c,d,acc,offset,previous,1,1))

@unsafe
def p150l_greater_at(+rest: String, +l: U32, +c: U32, +d: U32, +acc: List<&2,FToken>, +offset: U32, +previous: U32, +gap: Bool) -> List<&2,FToken>:
  p170ls_greater(rest,rest,l,c,d,acc,offset,previous,gap)

@unsafe
def p170ls_greater(inspected: String, +original: String, +l: U32, +c: U32, +d: U32, +acc: List<&2,FToken>, +offset: U32, +previous: U32, +gap: Bool) -> List<&2,FToken>:
  match inspected:
    case SNil{}: p150l_emit(f_choose(String,gap,u => ">op",u => ">"),"",l,c,d,acc,offset,previous,1,1)
    case SCon{+head,+tail}:
      f_choose(List<&2,FToken>,f_ascii_char_eq(head,'>'),
        u => p150l_emit(f_choose(String,gap,v => ">>op",v => ">>"),tail,l,c,d,acc,offset,previous,2,2),
      u => f_choose(List<&2,FToken>,f_ascii_char_eq(head,'='),u => p150l_emit(">=",tail,l,c,d,acc,offset,previous,2,2),
        u => p150l_emit(f_choose(String,gap,v => ">op",v => ">"),original,l,c,d,acc,offset,previous,1,1)))
