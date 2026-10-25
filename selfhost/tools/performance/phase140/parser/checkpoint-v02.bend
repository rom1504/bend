# Exact source-prefix comparison produces the new suffix; no host text split.
# UTF16 units match lexer offsets, including non-BMP code points and surrogates.
@unsafe
def p140p_prefix(+old: String, +current: String, +left: U32) -> P140PMatch:
  nt_choose(P140PMatch,U32.is_eq(left,0),u => P140PMatch{current,True{}},u =>
    p140p_prefix_nonempty(old,current,left))

@unsafe
def p140p_prefix_nonempty(old: String, current: String, +left: U32) -> P140PMatch:
  match old current:
    case SCon{+a,ar} SCon{+b,br}:
      nt_choose(P140PMatch,Char.is_eq(a,b) && U32.is_ge(left,dg_units(a)),
        u => p140p_prefix(ar,br,U32.sub(left,dg_units(a))),u => P140PMatch{"",False{}})
    case _ _: P140PMatch{"",False{}}

# Preserve KDef variant, not merely its exported projection fields.
@unsafe
def p140p_variant(d: KDef) -> U32:
  match d:
    case KDef{n,k,a,x,t,v,c,b,u}: 0
    case KIndexLeaf{h,b}: 1
    case KIndexNode{h,m,l,r}: 2

@unsafe
def p140p_defs(left: List<&2,KDef>, right: List<&2,KDef>) -> Bool:
  match left right:
    case Nil{} Nil{}: True{}
    case Con{+a,ar} Con{+b,br}:
      nt_choose(Bool,U32.is_eq(p140p_variant(a),p140p_variant(b)) && f_fresh_prefix_exact_head(a,b),
        u => p140p_defs(norm_defs_join(dc(a),ar),norm_defs_join(dc(b),br)),u => False{})
    case _ _: False{}

@unsafe
def p140p_scope_same(a: FParseScope, b: FParseScope) -> Bool:
  match a b:
    case FParseScope{ap,ai,ac,an,aa} FParseScope{bp,bi,bc,bn,ba}:
      String.eq(an,bn) && f_fresh_prefix_exact_terms(aa,ba) &&
      p140p_defs(ap,bp) && p140p_defs([ai,ac],[bi,bc])

@unsafe
def p140p_token_same(a: FToken, b: FToken) -> Bool:
  match a b:
    case FToken{at,al,ac,ak,ab,ae,ap} FToken{bt,bl,bc,bk,bb,be,bp}:
      String.eq(at,bt) && U32.is_eq(al,bl) && U32.is_eq(ac,bc) && U32.is_eq(ak,bk) &&
      U32.is_eq(ab,bb) && U32.is_eq(ae,be) && U32.is_eq(ap,bp)

# An emitted newline proves original lexer depth0. A synthetic parser token
# cannot manufacture a checkpoint: the complete current token must occur in
# the original lexical stream, immediately following such a newline.
@unsafe
def p140p_prior(tokens: List<&2,FToken>, +wanted: FToken, previous: Maybe<&2,FToken>) -> Maybe<&2,FToken>:
  match tokens:
    case Nil{}: None{}
    case Con{+token,rest}:
      nt_choose(Maybe<&2,FToken>,p140p_token_same(token,wanted),
        u => p140p_prior_valid(previous),u => p140p_prior(rest,wanted,Some{token}))

@unsafe
def p140p_prior_valid(previous: Maybe<&2,FToken>) -> Maybe<&2,FToken>:
  match previous:
    case None{}: None{}
    case Some{+token}:
      nt_choose(Maybe<&2,FToken>,String.eq(f_raw_tx([token]),"\n"),u => Some{token},u => None{})

@unsafe
def p140p_checkpoint(+source: String, +initial: FParseScope, +start: U32, +tokens: List<&2,FToken>, +input: FInput, +book: List<&2,KDef>, +imports: List<&2,KTerm>, +unsafe: Bool, +scope: FParseScope) -> Maybe<&2,P140PCache>:
  match input:
    case FInput{remaining,context}:
      match remaining:
        case Nil{}: None{}
        case Con{+token,rest}:
          p140p_checkpoint_previous(source,initial,start,token,context,book,imports,unsafe,scope,
            p140p_prior(tokens,token,None{}))

@unsafe
def p140p_checkpoint_previous(+source: String, +initial: FParseScope, +start: U32, +token: FToken, +context: FParseContext, +book: List<&2,KDef>, +imports: List<&2,KTerm>, +unsafe: Bool, +scope: FParseScope, previous: Maybe<&2,FToken>) -> Maybe<&2,P140PCache>:
  match previous:
    case None{}: None{}
    case Some{prior}:
      nt_choose(Maybe<&2,P140PCache>,U32.is_gt(start,0) && U32.is_gt(f_raw_begin([token]),start),
        u => Some{P140PCache{source,initial,start,token,prior,context,book,imports,unsafe,scope}},u => None{})

@unsafe
def p140p_seed_finished(+result: FResult, cache: Maybe<&2,P140PCache>) -> P140PParsed:
  match result:
    case FResult{book,+error,imports}:
      P140PParsed{result,nt_choose(Maybe<&2,P140PCache>,String.is_empty(error),u => cache,u => None{}),False{}}

@unsafe
def p140p_seed_stopped(+source: String, +initial: FParseScope, +start: U32, +tokens: List<&2,FToken>, stopped: P140PStop) -> P140PParsed:
  match stopped:
    case P140PDone{raw}: P140PParsed{f_context_result(fpe_finish_indexed(start,source,raw)),None{},False{}}
    case P140PCut{+input,+book,+imports,+unsafe,+scope}:
      p140p_seed_finished(f_context_result(fpe_finish_indexed(start,source,f_top(input,book,imports,unsafe,scope))),
        p140p_checkpoint(source,initial,start,tokens,input,book,imports,unsafe,scope))

@unsafe
def p140p_seed_tokens(+source: String, +scope: FParseScope, +start: U32, +hint: U32, +imports: List<&2,KTerm>, +tokens: List<&2,FToken>) -> P140PParsed:
  p140p_seed_stopped(source,scope,start,tokens,
    p140p_tops(hint,f_input(tokens),[],List.reverse(&2,KTerm,imports),False{},scope))

@unsafe
def p140p_seed(+source: String, +header: FHeader, +scope: FParseScope, +start: U32, +hint: U32) -> P140PParsed:
  match header:
    case FHeader{+imports,+error,+body,+line,+offset}:
      nt_choose(P140PParsed,String.is_empty(error),
        u => p140p_seed_tokens(source,scope,start,hint,imports,
          f_lex_cursor(body,line,0,0,[],f_cursor_add(start,offset),f_cursor_add(start,offset))),
        u => P140PParsed{f_body_header(source,header,scope,start),None{},False{}})

# Keep the previous lexical token solely as scanner lookbehind. Remove its
# copied output token before parsing; all new suffix token spans remain exact.
@unsafe
def p140p_relex(+tail: String, token: FToken, previous: FToken) -> List<&2,FToken>:
  match token:
    case FToken{text,line,column,kind,begin,end,previousEnd}:
      f_raw_tl(f_lex_cursor(tail,line,column,0,[previous],begin,previousEnd))

@unsafe
def p140p_resume_match(+source: String, +header: FHeader, +initial: FParseScope, +start: U32, +cache: P140PCache, matched: P140PMatch) -> P140PParsed:
  match matched:
    case P140PMatch{tail,same}:
      nt_choose(P140PParsed,same,u => p140p_resume_tail(source,header,cache,tail),
        u => P140PParsed{f_body_header(source,header,initial,start),Some{cache},False{}})

# The first suffix token is lookahead of the completed preceding expression.
# A changed operator can retroactively extend that expression across a newline.
# Require the exact original declaration token before trusting the checkpoint.
@unsafe
def p140p_resume_tail(+source: String, +header: FHeader, +cache: P140PCache, tail: String) -> P140PParsed:
  match cache:
    case P140PCache{old,initial,start,+token,previous,context,book,imports,unsafe,scope}:
      p140p_resume_lexed(source,header,cache,p140p_relex(tail,token,previous))

@unsafe
def p140p_resume_lexed(+source: String, +header: FHeader, +cache: P140PCache, +tokens: List<&2,FToken>) -> P140PParsed:
  match cache:
    case P140PCache{old,+initial,+start,+token,previous,+context,+book,+imports,+unsafe,+scope}:
      nt_choose(P140PParsed,p140p_first_token(tokens,token),
        u => P140PParsed{f_context_result(fpe_finish_indexed(start,source,
          f_top(FInput{tokens,context},book,imports,unsafe,scope))),Some{cache},True{}},
        u => P140PParsed{f_body_header(source,header,initial,start),Some{cache},False{}})

@unsafe
def p140p_first_token(tokens: List<&2,FToken>, expected: FToken) -> Bool:
  match tokens:
    case Nil{}: False{}
    case Con{token,rest}: p140p_token_same(token,expected)

@unsafe
def p140p_resume(+source: String, +header: FHeader, +initial: FParseScope, +start: U32, checkpoint: Maybe<&2,P140PCache>) -> P140PParsed:
  match checkpoint:
    case None{}: P140PParsed{f_body_header(source,header,initial,start),None{},False{}}
    case Some{+cache}:
      match cache:
        case P140PCache{+old,+prior,+origin,+token,previous,context,book,imports,unsafe,scope}:
          nt_choose(P140PParsed,U32.is_eq(start,origin) && p140p_scope_same(initial,prior),
            u => p140p_resume_match(source,header,initial,start,cache,
              p140p_prefix(old,source,U32.sub(f_raw_begin([token]),origin))),
            u => P140PParsed{f_body_header(source,header,initial,start),Some{cache},False{}})

@unsafe
def p140p_parsed_result(parsed: P140PParsed) -> FResult:
  match parsed:
    case P140PParsed{result,cache,hit}: result

@unsafe
def p140p_parsed_cache(parsed: P140PParsed) -> Maybe<&2,P140PCache>:
  match parsed:
    case P140PParsed{result,cache,hit}: cache

@unsafe
def p140p_parsed_hit(parsed: P140PParsed) -> Bool:
  match parsed:
    case P140PParsed{result,cache,hit}: hit
