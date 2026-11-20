@unsafe
def p169np_admitted(+request: NR_Request,+error: String) -> P169Prepared:
  nt_choose(P169Prepared,String.is_empty(error),u =>
    x198pw_annotate(request,p169s_lowered(request,p168_request_mode(1,request))),
    u => p169s_fail("compile: " ++ error))

