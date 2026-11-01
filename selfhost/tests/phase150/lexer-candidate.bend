# Private lexer producer: exact FToken output, unchanged parser consumers.
# SNil alone ends input; an actual NUL remains a one-character symbol.
type P150LQuoted is Data:
  P150LQuoted{+word: String, +rest: String, size: U32, width: U32, line: U32, column: U32}

type P150LEdge is Data:
  P150LEdge{column: U32, natural: Bool}

@unsafe
def p150l_cursor(+s: String, +l: U32, +c: U32, +d: U32, +acc: List<&2,FToken>, +offset: U32, +previous: U32) -> List<&2,FToken>:
  match s:
    case SNil{}:
      List.reverse(&2,FToken,f_choose(List<&2,FToken>,U32.is_eq(offset,0),
        u => acc,u => Con{FToken{"<eof>",0,0,0,offset,offset,previous},acc}))
    case SCon{+head,+rest}:
      +code = Char.to_u32(head)
      f_choose(List<&2,FToken>,U32.is_eq(code,10),u => p150l_newline(rest,l,c,d,acc,offset,previous),
      u => f_choose(List<&2,FToken>,f_ascii_space_code(code),
        u => p150l_cursor(rest,l,U32.add(c,1),d,acc,f_cursor_add(offset,dg_units(head)),previous),
      u => f_choose(List<&2,FToken>,U32.is_eq(code,35),u => p150l_comment(rest,l,c,d,acc,f_cursor_add(offset,1),previous),
      u => f_choose(List<&2,FToken>,U32.is_eq(code,34) || U32.is_eq(code,39),
        u => p150l_quoted(p150l_quote(rest,head,SCon{head,""},1,1,l,U32.add(c,1)),l,c,d,acc,offset,previous),
        u => f_choose(List<&2,FToken>,f_ident(head) && Bool.not(Char.is_eq(head,'.')),
          u => p150l_word_done(p150l_word(rest,SCon{head,""},1,head),l,c,d,acc,offset,previous),
          u => p150l_other(head,rest,l,c,d,acc,offset,previous))))))

@unsafe
def p150l_newline(rest: String, +l: U32, +c: U32, +d: U32, +acc: List<&2,FToken>, +offset: U32, +previous: U32) -> List<&2,FToken>:
  p150l_cursor(rest,U32.add(l,1),0,d,
    f_choose(List<&2,FToken>,U32.is_eq(d,0),u => Con{FToken{"\n",l,c,0,offset,f_cursor_add(offset,1),previous},acc},u => acc),
    f_cursor_add(offset,1),previous)

# Comment bytes advance the indexed cursor, deliberately not the physical column.
@unsafe
def p150l_comment(s: String, +l: U32, +c: U32, +d: U32, +acc: List<&2,FToken>, +offset: U32, +previous: U32) -> List<&2,FToken>:
  match s:
    case SNil{}: p150l_cursor("",l,c,d,acc,offset,previous)
    case SCon{+head,+rest}:
      f_choose(List<&2,FToken>,f_ascii_char_eq(head,'\n'),
        u => p150l_newline(rest,l,c,d,acc,offset,previous),
        u => p150l_comment(rest,l,c,d,acc,f_cursor_add(offset,dg_units(head)),previous))

@unsafe
def p150l_digit(s: String) -> Bool:
  match s:
    case SNil{}: False{}
    case SCon{head,rest}: f_ascii_digit(head)

# The exponent sign rule also applies to identifiers such as name+2.
@unsafe
def p150l_word(+s: String, +acc: String, +n: U32, +last: Char) -> FScanned:
  match s:
    case SNil{}: FScanned{String.reverse(acc),"",n}
    case SCon{+head,+rest}:
      f_choose(FScanned,f_choose(Bool,f_ident(head),u => True{},u =>
        (Char.is_eq(head,'+') || Char.is_eq(head,'-')) &&
          (Char.is_eq(last,'e') || Char.is_eq(last,'E')) && p150l_digit(rest)),
        u => p150l_word(rest,SCon{head,acc},U32.add(n,1),head),
        u => FScanned{String.reverse(acc),s,n})

@unsafe
def p150l_word_done(sc: FScanned, +l: U32, +c: U32, +d: U32, +acc: List<&2,FToken>, +offset: U32, +previous: U32) -> List<&2,FToken>:
  match sc:
    case FScanned{word,rest,+size}:
      f_choose(List<&2,FToken>,U32.is_eq(size,0),
        u => p150l_unterminated(l,c,acc,offset,previous),
        u => p150l_word_end(word,rest,l,c,d,acc,offset,previous,size,f_cursor_add(offset,size)))

@unsafe
def p150l_word_end(+word: String, rest: String, +l: U32, +c: U32, d: U32, acc: List<&2,FToken>, +offset: U32, previous: U32, size: U32, +end: U32) -> List<&2,FToken>:
  p150l_cursor(rest,l,U32.add(c,size),d,Con{FToken{word,l,c,1,offset,end,previous},acc},end,end)

# Metadata is accumulated with raw U32 addition, then added to the opening
# cursor once. Applying f_cursor_add per quote character changes wrap-to-zero.
# Only the entry's single/double quote calls reach these private scanners.
@unsafe
def p150l_quote(s: String, +quote: Char, +acc: String, +n: U32, +width: U32, +l: U32, +c: U32) -> P150LQuoted:
  match s:
    case SNil{}: P150LQuoted{"","",0,0,0,0}
    case SCon{+head,+rest}:
      f_choose(P150LQuoted,f_ascii_char_eq(head,'\\'),u => p150l_escape(rest,quote,acc,n,width,l,c),
      u => f_choose(P150LQuoted,f_ascii_char_eq(head,'\n'),
        u => p150l_quote(rest,quote,SCon{head,acc},U32.add(n,1),U32.add(width,1),U32.add(l,1),0),
      u => f_choose(P150LQuoted,Char.is_eq(head,quote),
        u => P150LQuoted{String.reverse(SCon{head,acc}),rest,U32.add(n,1),U32.add(width,1),l,U32.add(c,1)},
        u => p150l_quote(rest,quote,SCon{head,acc},U32.add(n,1),U32.add(width,dg_units(head)),l,U32.add(c,1)))))

@unsafe
def p150l_escape(s: String, +quote: Char, +acc: String, +n: U32, +width: U32, +l: U32, +c: U32) -> P150LQuoted:
  match s:
    case SNil{}: P150LQuoted{"","",0,0,0,0}
    case SCon{+head,+rest}:
      f_choose(P150LQuoted,f_ascii_char_eq(head,'\n'),
        u => p150l_quote(rest,quote,SCon{head,SCon{'\\',acc}},U32.add(n,2),U32.add(width,2),U32.add(l,1),0),
        u => p150l_quote(rest,quote,SCon{head,SCon{'\\',acc}},U32.add(n,2),U32.add(width,U32.add(1,dg_units(head))),l,U32.add(c,2)))

@unsafe
def p150l_quoted(sc: P150LQuoted, +l: U32, +c: U32, +d: U32, +acc: List<&2,FToken>, +offset: U32, +previous: U32) -> List<&2,FToken>:
  match sc:
    case P150LQuoted{word,rest,size,width,line,column}:
      f_choose(List<&2,FToken>,U32.is_eq(size,0),
        u => p150l_unterminated(l,c,acc,offset,previous),
        u => p150l_quote_end(word,rest,l,c,d,acc,offset,previous,line,column,f_cursor_add(offset,width)))

@unsafe
def p150l_quote_end(word: String, rest: String, l: U32, c: U32, d: U32, acc: List<&2,FToken>, offset: U32, previous: U32, line: U32, column: U32, +end: U32) -> List<&2,FToken>:
  p150l_cursor(rest,line,column,d,Con{FToken{word,l,c,2,offset,end,previous},acc},end,end)

@unsafe
def p150l_unterminated(l: U32, c: U32, acc: List<&2,FToken>, +offset: U32, previous: U32) -> List<&2,FToken>:
  List.reverse(&2,FToken,Con{FToken{"unterminated string",l,c,3,offset,offset,previous},acc})

# Exact three-character dispatch precedes dot-word scanning. Only accepted
# operators construct token text; lookahead compares scalar character values.
@unsafe
def p150l_other(+head: Char, +rest: String, +l: U32, +c: U32, +d: U32, +acc: List<&2,FToken>, +offset: U32, +previous: U32) -> List<&2,FToken>:
  match rest:
    case SCon{+second,SCon{+third,tail}}:
      f_choose(List<&2,FToken>,p150l_triple(head,second,third),
        u => p150l_emit(SCon{head,SCon{second,SCon{third,""}}},tail,l,c,d,acc,offset,previous,3,3),
        u => p150l_other_plain(head,rest,l,c,d,acc,offset,previous))
    case _: p150l_other_plain(head,rest,l,c,d,acc,offset,previous)

@unsafe
def p150l_triple(+a: Char, +b: Char, +c: Char) -> Bool:
  f_choose(Bool,f_ascii_char_eq(a,'.'),
    u => f_ascii_char_eq(c,'.') && (f_ascii_char_eq(b,'&') || f_ascii_char_eq(b,'|') || f_ascii_char_eq(b,'^')),
    u => f_ascii_char_eq(a,'<') && f_ascii_char_eq(b,'&') && f_ascii_char_eq(c,'>'))

@unsafe
def p150l_other_plain(+head: Char, +rest: String, +l: U32, +c: U32, +d: U32, +acc: List<&2,FToken>, +offset: U32, +previous: U32) -> List<&2,FToken>:
  f_choose(List<&2,FToken>,f_ascii_char_eq(head,'.'),u => p150l_word_done(p150l_word(rest,".",1,'.'),l,c,d,acc,offset,previous),
  u => f_choose(List<&2,FToken>,f_ascii_char_eq(head,'+'),u => p150l_plus(rest,l,c,d,acc,offset,previous,p150l_edge(acc)),
  u => f_choose(List<&2,FToken>,f_ascii_char_eq(head,'>'),u => p150l_greater(rest,l,c,d,acc,offset,previous,p150l_edge(acc)),
    u => p150l_symbol(head,rest,l,c,d,acc,offset,previous))))

# The old adjacency rule uses the stored token text, including >op/+bind,
# and no line check. One scan obtains length and the final character together.
@unsafe
def p150l_edge(tokens: List<&2,FToken>) -> P150LEdge:
  match tokens:
    case Nil{}: P150LEdge{5,False{}}
    case Con{FToken{text,line,column,kind,begin,end,previous},rest}: p150l_edge_text(text,column,'\0')

@unsafe
def p150l_edge_text(text: String, +column: U32, last: Char) -> P150LEdge:
  match text:
    case SNil{}: P150LEdge{column,Char.is_eq(last,'n')}
    case SCon{head,rest}: p150l_edge_text(rest,U32.add(column,1),head)

@unsafe
def p150l_plus(+rest: String, +l: U32, +c: U32, +d: U32, +acc: List<&2,FToken>, +offset: U32, +previous: U32, edge: P150LEdge) -> List<&2,FToken>:
  match edge:
    case P150LEdge{column,natural}: p150l_plus_at(rest,l,c,d,acc,offset,previous,natural && U32.is_eq(c,column))

@unsafe
def p150l_plus_at(+rest: String, +l: U32, +c: U32, +d: U32, +acc: List<&2,FToken>, +offset: U32, +previous: U32, +contiguous: Bool) -> List<&2,FToken>:
  match rest:
    case SNil{}: p150l_emit("+","",l,c,d,acc,offset,previous,1,1)
    case SCon{+head,tail}:
      f_choose(List<&2,FToken>,f_ascii_char_eq(head,'+'),
        u => f_choose(List<&2,FToken>,contiguous,
          v => p150l_emit("+",rest,l,c,d,acc,offset,previous,1,1),
          v => p150l_emit("++",tail,l,c,d,acc,offset,previous,2,2)),
        u => p150l_emit(f_choose(String,f_ascii_alpha(head) && Bool.not(contiguous),v => "+bind",v => "+"),rest,l,c,d,acc,offset,previous,1,1))

@unsafe
def p150l_greater(+rest: String, +l: U32, +c: U32, +d: U32, +acc: List<&2,FToken>, +offset: U32, +previous: U32, edge: P150LEdge) -> List<&2,FToken>:
  match edge:
    case P150LEdge{column,natural}: p150l_greater_at(rest,l,c,d,acc,offset,previous,U32.is_gt(c,column))

@unsafe
def p150l_greater_at(+rest: String, +l: U32, +c: U32, +d: U32, +acc: List<&2,FToken>, +offset: U32, +previous: U32, +gap: Bool) -> List<&2,FToken>:
  match rest:
    case SNil{}: p150l_emit(f_choose(String,gap,u => ">op",u => ">"),"",l,c,d,acc,offset,previous,1,1)
    case SCon{+head,+tail}:
      f_choose(List<&2,FToken>,f_ascii_char_eq(head,'>'),
        u => p150l_emit(f_choose(String,gap,v => ">>op",v => ">>"),tail,l,c,d,acc,offset,previous,2,2),
      u => f_choose(List<&2,FToken>,f_ascii_char_eq(head,'='),u => p150l_emit(">=",tail,l,c,d,acc,offset,previous,2,2),
        u => p150l_emit(f_choose(String,gap,v => ">op",v => ">"),rest,l,c,d,acc,offset,previous,1,1)))

@unsafe
def p150l_symbol(+head: Char, +rest: String, +l: U32, +c: U32, +d: U32, +acc: List<&2,FToken>, +offset: U32, +previous: U32) -> List<&2,FToken>:
  match rest:
    case SNil{}: p150l_single(head,"",l,c,d,acc,offset,previous)
    case SCon{+second,tail}:
      f_choose(List<&2,FToken>,p150l_pair(head,second),
        u => p150l_emit(SCon{head,SCon{second,""}},tail,l,c,d,acc,offset,previous,2,2),
        u => p150l_single(head,rest,l,c,d,acc,offset,previous))

# Scalar predicates avoid expanding Char literal patterns into bit patterns.
@unsafe
def p150l_pair(a: Char, b: Char) -> Bool:
  +x = Char.to_u32(a)
  +y = Char.to_u32(b)
  f_choose(Bool,U32.is_eq(y,62),u => U32.is_eq(x,45) || U32.is_eq(x,61) || U32.is_eq(x,60),
  u => f_choose(Bool,U32.is_eq(y,61),u => U32.is_eq(x,61) || U32.is_eq(x,33) || U32.is_eq(x,60),
  u => f_choose(Bool,U32.is_eq(x,60),u => U32.is_eq(y,45) || U32.is_eq(y,60),
    u => U32.is_eq(x,y) && (U32.is_eq(x,38) || U32.is_eq(x,124)))))

@unsafe
def p150l_single(+head: Char, rest: String, l: U32, c: U32, d: U32, acc: List<&2,FToken>, offset: U32, previous: U32) -> List<&2,FToken>:
  p150l_emit(SCon{head,""},rest,l,c,p150l_depth(head,d),acc,offset,previous,1,dg_units(head))

@unsafe
def p150l_depth(head: Char, +depth: U32) -> U32:
  +code = Char.to_u32(head)
  f_choose(U32,U32.is_eq(code,40) || U32.is_eq(code,91) || U32.is_eq(code,123),u => U32.add(depth,1),
  u => f_choose(U32,U32.is_eq(code,41) || U32.is_eq(code,93) || U32.is_eq(code,125),u => U32.sub(depth,1),u => depth))

@unsafe
def p150l_emit(text: String, rest: String, +l: U32, +c: U32, d: U32, acc: List<&2,FToken>, +offset: U32, previous: U32, columns: U32, width: U32) -> List<&2,FToken>:
  p150l_emitted(text,rest,l,c,d,acc,offset,previous,columns,f_cursor_add(offset,width))

@unsafe
def p150l_emitted(text: String, rest: String, +l: U32, +c: U32, d: U32, acc: List<&2,FToken>, offset: U32, previous: U32, columns: U32, +end: U32) -> List<&2,FToken>:
  p150l_cursor(rest,l,U32.add(c,columns),d,Con{FToken{text,l,c,0,offset,end,previous},acc},end,end)
