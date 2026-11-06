# Read-only compiler data from the actual checked request. No admission override.
@unsafe
def p171dd_row(+book: List<&2,KDef>, +role: String, +ty: KTerm) -> KTerm:
  +definition = lookup(book,nm(ty))
  +specialized = nq_layout_specialize(dt(definition),ks(ty),64)
  kt(role,nm(ty),Bool.to_u32(nol_scalar(book,ty)),Bool.to_u32(p171d_type(book,ty)),
    [ty,dt(definition),specialized,nq_layout_type(book,specialized),
     kt("type-flags",dk(definition),Bool.to_u32(db(definition)),Bool.to_u32(nc_native_def(definition)),[])])

@unsafe
def p171dd_types(+book: List<&2,KDef>, +ty: KTerm, +fuel: U32) -> List<&2,KTerm>:
  +head = nq_layout_type(book,ty)
  nt_choose(List<&2,KTerm>,U32.is_eq(fuel,0),u => [atom("fuel")],u =>
    nt_choose(List<&2,KTerm>,String.eq(tg(head),"All"),
      v => Con{p171dd_row(book,nt_choose(String,U32.is_eq(qt(head),0),w => "erased",w => "parameter"),nq_layout_type(book,kid(head,0))),p171dd_types(book,kid(head,1),U32.sub(fuel,1))},
      v => [p171dd_row(book,"result",head)]))

@unsafe
def p171d_debug_shape(request: NR_Request, owner: String) -> List<&2,KTerm>:
  match request:
    case NR_Request{source,+book,names,paths,scope,bound}: p171dd_types(book,dt(lookup(book,owner)),32)
