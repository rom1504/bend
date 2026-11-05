# Private policy selection; overrides only the experimental entry, never a
# protected maintained compiler declaration. Admission/checking remain shared.
@unsafe
def p163n_pure(+request: NR_Request) -> P111Emission:
  match request:
    case NR_Request{+source,book,names,paths,scope,bound}:
      nt_choose(P111Emission,Bool.not(nc_is_io(source,dt(lookup(source,"main")))),
        u => p163o_executable(request),
        u => P111Emission{[],"direct-only native compiler: pure main required"})
