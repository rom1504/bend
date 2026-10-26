# Optional isolated integration. Do not install without complete product gates.
@unsafe
def nc_ctor_owned(book, name):
  p144o_owned(book,name)

@unsafe
def nr_prepare_annotated(+book: List<&2,KDef>, annotated: List<&2,KDef>) -> NR_Request:
  p144o_prepare_annotated(book,annotated)

@unsafe
def p128raw_lower_request(request: NR_Request) -> P128RawLowering:
  p144o_lower_request(request)
