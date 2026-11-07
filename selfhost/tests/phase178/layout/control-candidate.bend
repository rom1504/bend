@unsafe
def erasure_control_product_observe(product: NativeErasedTerm, tail: List<&2,String>) -> ErasureObservation:
  match product:
    case NativeErasedTerm{body,reversedRefs}:
      ErasureObservation{body,nt_reverse(String,reversedRefs,tail)}

@unsafe
def erasure_control_observe(book,input,reverseSeed,tail):
  erasure_control_product_observe(nc_erase_product(book,input,True{},reverseSeed),tail)

@unsafe
def erasure_control_product_raw(product: NativeErasedTerm) -> ErasureObservation:
  match product:
    case NativeErasedTerm{body,reversedRefs}: ErasureObservation{body,reversedRefs}

@unsafe
def erasure_control_uncollected(book,input,reverseSeed):
  erasure_control_product_raw(nc_erase_product(book,input,False{},reverseSeed))

@unsafe
def erasure_control_definition(book,definition,n):
  erasure_control_product_observe(nc_definition_product(book,definition,n,True{}),[])
