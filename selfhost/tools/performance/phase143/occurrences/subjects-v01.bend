# Exact selected compiler computation on an already checked ordinary request.
# These are real compacted bodies; n/left/env replay schedules are constructed
# experiments, not captured nd_comb_fresh invocation statistics.
type P143OSubject is Data:
  P143OSubject{+owner: String, +body: KTerm, +arity: U32, +error: String}

@unsafe
def p143o_subject(+request: NR_Request, +name: String, +fresh: U32) -> P143OSubject:
  match request:
    case NR_Request{source,+book,names,paths,scope,bound}:
      +definition = lookup(book,name)
      nt_choose(P143OSubject,p88_string_eq(dk(definition),"Def") &&
        Bool.not(nc_native_def(definition) || nc_foreign(definition)),
        u => P143OSubject{name,nc_compact_definition(book,definition,fresh),nd_arity(book,name),""},
        u => P143OSubject{name,KTerm{"Absent","",0,0,[],[],0,0},0,"not an ordinary source definition"})
