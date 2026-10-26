# Diagnostic only: the existing checked source certificate and its subconditions.
# No admission predicate, compiler body, runtime operation, or fallback changes.

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
