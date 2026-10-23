# Hook the actual integrated entry, after its unchanged permission/source/IR
# gates. Diagnostic p118b_emit_verified alone is not this entry's call path.
@unsafe
def p126bp_integrated(+request: NR_Request, +original: P113AProgram, +workers: P118BWorkers) -> P111Emission:
  match workers:
    case P118BWorkers{functions,+error}:
      nt_choose(P111Emission,String.is_empty(error) && p126bp_has_flat(functions),
        u => p126bp_workers(request,original,workers),
        u => p118e_emit_workers(original,workers))

# The scalar-permitted path retains its exact original cold-metadata derivation.
@unsafe
def p118e_permitted(+request: NR_Request, original: P113AProgram) -> P111Emission:
  match request:
    case NR_Request{source,+book,+names,paths,scope,bound}:
      +hot = nh_definitions(book,names,[])
      p126bp_integrated(request,p118e_cold(original,book,source,hot),
        p118e_workers(book,no_candidate_names(book,names,nc_bangs_names(book,names)),[]))

# The effect-permitted, nonscalar path still acquires no cold/array certificate.
@unsafe
def p118i_borrow(+request: NR_Request, original: P113AProgram) -> P111Emission:
  match request:
    case NR_Request{source,+book,+names,paths,scope,bound}:
      p126bp_integrated(request,original,
        p118e_workers(book,no_candidate_names(book,names,nc_bangs_names(book,names)),[]))
