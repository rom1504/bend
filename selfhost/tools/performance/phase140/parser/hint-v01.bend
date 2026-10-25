# A lexical landmark is only a hint. The actual top parser certifies the state;
# a cut after the requested edit position is rejected. Cold lexing occurs once.
@unsafe
def p140p_landmark(tokens: List<&2,FToken>, +edit: U32, +best: U32) -> U32:
  match tokens:
    case Nil{}: best
    case Con{token,rest}:
      match token:
        case FToken{+text,line,column,kind,+begin,end,previous}:
          nt_choose(U32,U32.is_gt(begin,edit),u => best,
            u => p140p_landmark(rest,edit,
              nt_choose(U32,U32.is_eq(column,0) && (String.eq(text,"def") || String.eq(text,"law") || String.eq(text,"type")),
                u => begin,u => best)))

@unsafe
def p140p_seed_before(+source: String, +header: FHeader, +scope: FParseScope, +start: U32, +edit: U32) -> P140PParsed:
  match header:
    case FHeader{+imports,+error,+body,+line,+offset}:
      nt_choose(P140PParsed,String.is_empty(error) && U32.is_gt(edit,0),
        u => p140p_before_tokens(source,scope,start,edit,imports,
          f_lex_cursor(body,line,0,0,[],f_cursor_add(start,offset),f_cursor_add(start,offset))),
        u => P140PParsed{f_body_header(source,header,scope,start),None{},False{}})

@unsafe
def p140p_before_tokens(+source: String, +scope: FParseScope, +start: U32, +edit: U32, +imports: List<&2,KTerm>, +tokens: List<&2,FToken>) -> P140PParsed:
  p140p_before_stopped(source,scope,start,edit,tokens,
    p140p_tops(p140p_landmark(tokens,edit,0),f_input(tokens),[],List.reverse(&2,KTerm,imports),False{},scope))

@unsafe
def p140p_before_stopped(+source: String, +initial: FParseScope, +start: U32, +edit: U32, +tokens: List<&2,FToken>, +stopped: P140PStop) -> P140PParsed:
  match stopped:
    case P140PDone{raw}: p140p_seed_stopped(source,initial,start,tokens,stopped)
    case P140PCut{+input,+book,+imports,+unsafe,+scope}:
      nt_choose(P140PParsed,U32.is_le(f_begin(input),edit),
        u => p140p_seed_stopped(source,initial,start,tokens,stopped),
        u => P140PParsed{f_context_result(fpe_finish_indexed(start,source,f_top(input,book,imports,unsafe,scope))),None{},False{}})
