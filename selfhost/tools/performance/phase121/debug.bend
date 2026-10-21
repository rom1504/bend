# Read-only candidate diagnosis. No optimizer or admission override.
@unsafe
def p121c_debug(request: NR_Request, +name: String) -> List<&2,String>:
  match request:
    case NR_Request{source,+book,names,paths,scope,bound}:
      +d = lookup(book,name)
      +call = j_call_spine(j_fusion_after(dv(d),2),[])
      +count = j_call_spine(kid(call,0),[])
      +f = lookup(book,nm(call))
      +s = j_fusion_link(f)
      +body = j_fusion_after(s,1)
      +composition = j_call_spine(kid(body,1),[])
      +c = lookup(book,nm(composition))
      [name ++ " root=" ++ U32.show(da(d)) ++ " call=" ++ tg(call) ++ ":" ++ nm(call) ++ ":" ++ U32.show(terms_len(ks(call))),
       p114st_row("root signature",p121c_signature(book,dt(d),2)),
       p114st_row("count primitive",j_primitive_call(book,count)),
       p114st_row("count scalar",j_fusion_scalar(book,kid(count,0),[j_fusion_binder(dv(d),0),j_fusion_binder(dv(d),1)])),
       p114st_row("seed scalar",j_fusion_scalar(book,kid(call,1),[j_fusion_binder(dv(d),0),j_fusion_binder(dv(d),1)])),
       "factory=" ++ dn(f) ++ ":" ++ U32.show(da(f)) ++ ":" ++ tg(j_strip(dv(f))),
       p114st_row("factory bounded",p121f_bounded(dv(f))),
       p114st_row("factory type",j_callback_factory_type(book,dt(f))),
       p114st_row("factory",j_callback_factory(book,f)),
       "composition=" ++ dn(c) ++ ":" ++ U32.show(da(c)) ++ ":" ++ tg(j_strip(dv(c))),
       p114st_row("compose",j_callback_compose(book,c)),
       p114st_row("compose direct",j_callback_compose_on(book,c))]
