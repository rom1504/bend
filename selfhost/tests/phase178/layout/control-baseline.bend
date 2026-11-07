@unsafe
def erasure_control_observe(book,input,reverseSeed,tail):
  +body = nc_erase(book,input)
  ErasureObservation{body,nt_reverse(String,reverseSeed,nt_append(String,nc_refs(body),tail))}

@unsafe
def erasure_control_uncollected(book,input,reverseSeed):
  ErasureObservation{nc_erase(book,input),reverseSeed}

@unsafe
def erasure_control_definition(book,definition,n):
  +body = nc_definition_plain(book,definition,n)
  ErasureObservation{body,nc_refs(body)}
