
@unsafe
def p144e_body_tail(+code: P111QCode, +tail: String) -> String:
  match code:
    case P111QCode{chunks,n,terminal,error}:
      nt_choose(String,String.eq(error,""),u =>
        nt_choose(String,terminal,u => nt_text_finish(chunks,tail),u => "INVALID_N111_FALLTHROUGH\n" ++ tail),u => "INVALID_N111_BODY\n" ++ tail)

@unsafe
def p144ec_tail(+chunks: List<&2,String>, +terminal: Bool, +error: String, +tail: String, +expected: String) -> Bool:
  +code : P111QCode = P111QCode{chunks,4294967295,terminal,error}
  p88_string_eq(p144e_body_tail(code,tail),expected) &&
    p88_string_eq(p111q_body_text(code) ++ tail,expected)


@unsafe
def p144e_controls() -> List<&2,String>:
  [p114st_row("body-tail-empty-body",p144ec_tail([],True{},"","}\n","}\n")),
   p114st_row("body-tail-empty-suffix",p144ec_tail(["ret 0\n"],True{},"","","ret 0\n")),
   p114st_row("body-tail-reversed-instruction-order",p144ec_tail(["ret 0\n","@entry\n"],True{},"","}\n","@entry\nret 0\n}\n")),
   p114st_row("body-tail-empty-fragments",p144ec_tail(["","ret 0\n","","@entry\n",""],True{},"","}\n","@entry\nret 0\n}\n")),
   p114st_row("body-tail-partial-line-boundaries",p144ec_tail(["0\n","ret ","@entry\n"],True{},"","}\n","@entry\nret 0\n}\n")),
   p114st_row("body-tail-no-terminal-preserves-marker",p144ec_tail(["ignored"],False{},"","}\n","INVALID_N111_FALLTHROUGH\n}\n")),
   p114st_row("body-tail-error-before-terminal",p144ec_tail(["ignored"],True{},"problem","}\n","INVALID_N111_BODY\n}\n")),
   p114st_row("body-tail-error-before-fallthrough",p144ec_tail(["ignored"],False{},"problem","}\n","INVALID_N111_BODY\n}\n")),
   p114st_row("body-tail-error-empty-suffix",p144ec_tail([],True{},"problem","","INVALID_N111_BODY\n")),
   p114st_row("body-tail-unicode-and-embedded-newlines",p144ec_tail(["𐀀\n商"],True{},"","\n}\n","𐀀\n商\n}\n"))]

@unsafe
def p144cn_native_result(front: P140FCache, raw: P140ORCache, stats: List<&2,U32>, back: P140BResult) -> P140SResult:
  match back:
    case P140BResult{emission,cache,counts}:
      P140SResult{emission,P140SCache{front,raw,cache},nt_append(U32,stats,counts)}

@unsafe
def p144a_flag(name: String, bit: Bool) -> String:
  name ++ nt_choose(String,bit,u => "=true",u => "=false")


@unsafe
def p144a_definition(+book: List<&2,KDef>, +d: KDef) -> List<&2,String>:
  +empty = nm(j_strip(dv(d)))
  +link = nm(j_strip(kid(j_strip(dv(d)),1)))
  +ty = wnf(book,dt(d))
  +rest = wnf(book,kid(ty,1))
  +owner = wnf(book,kid(ty,0))
  ["name=" ++ dn(d),"kind=" ++ dk(d),"arity=" ++ U32.show(da(d)),
   "capacity=" ++ U32.show(dx(d)),p144a_flag("native",db(d)),
   "body=" ++ tg(j_strip(dv(d))),"empty=" ++ empty,"link=" ++ link,
   p144a_flag("definition",j_fusion_def(d,2)),p144a_flag("bounded",p121f_bounded(dv(d))),
   p144a_flag("equations",p125p_equations(d,empty,link)),
   p144a_flag("types",p125p_types(book,d,empty,link)),
   p144a_flag("admitted",p125p_admitted(book,d)),
   "type=" ++ tg(ty),"quantity=" ++ U32.show(qt(ty)),
   "rest=" ++ tg(rest),"rest-quantity=" ++ U32.show(qt(rest)),
   "owner-type=" ++ tg(owner),"owner-name=" ++ nm(owner),
   p144a_flag("owner",p125p_owner(book,owner,empty,link))]


@unsafe
def p144a_inspect(request: NR_Request, name: String) -> List<&2,String>:
  match request:
    case NR_Request{source,book,names,paths,scope,bound}:
      p144a_definition(book,lookup(book,name))
