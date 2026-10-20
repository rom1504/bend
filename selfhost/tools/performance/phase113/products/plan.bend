# Product layouts come from the original checked telescope retained in book.
# Boxed public-compatible and private flat variants share one closed admission
# pass. A refused product never changes its generic public segment or descriptor.
@unsafe
def p113pl_candidate_code(name: String, params: List<&2,NC_Binding>, shape: KTerm, public: Bool, code: P113DCode) -> P113DCandidate:
  match code:
    case P113DCode{body,fresh,error,calls}: P113DCandidate{P113DFunction{name,params,nq_width(shape),public,body},error,calls}

@unsafe
def p113pl_boxed_candidate(+book: List<&2,KDef>, +name: String, +signatures: List<&2,KDef>) -> P113DCandidate:
  +arity = nd_arity(book,name)
  +params = nk_typed_bindings(nd_entry_params(arity,0),nf_worker_kinds(book,name,arity))
  +owner = p113d_public(book,name)
  +body = nc_compact_definition(book,lookup(book,name),0)
  p113pl_candidate_code(owner,params,atom("Absent"),True{},
    p113pl_lower(book,nd_reapply(body,nd_entry_args(params)),params,P113PTarget{[],atom("Absent"),True{},owner,signatures},arity))

@unsafe
def p113pl_flat_entry(+book: List<&2,KDef>, +name: String, +info: KDef, +signatures: List<&2,KDef>, entry: NQ_Entry) -> P113DCandidate:
  match entry:
    case NQ_Entry{params,+args,+fresh}:
      +typed = nk_typed_bindings(params,nf_expand_kinds(ks(dv(info)),nf_worker_kinds(book,name,da(info))))
      +route = nm(dv(info))
      +shape = dt(info)
      +body = nc_compact_definition(book,lookup(book,name),fresh)
      p113pl_candidate_code(route,typed,shape,False{},
        p113pl_lower(book,nd_reapply(body,args),typed,P113PTarget{[],shape,True{},route,signatures},fresh))

@unsafe
def p113pl_flat_candidate(+book: List<&2,KDef>, +name: String, +signatures: List<&2,KDef>) -> P113DCandidate:
  +info = lookup(signatures,name)
  p113pl_flat_entry(book,name,info,signatures,nq_entry(ks(dv(info)),0,da(info)))

@unsafe
def p113pl_candidates(+book: List<&2,KDef>, names: List<&2,String>, +bangs: List<&2,String>, +signatures: List<&2,KDef>) -> List<&2,P113DCandidate>:
  match names:
    case Nil{}: []
    case Con{+name,+rest}:
      +definition = lookup(book,name)
      +info = lookup(signatures,name)
      nt_choose(List<&2,P113DCandidate>,String.eq(dk(definition),"Def") &&
        Bool.not(nc_native_def(definition) || nc_foreign(definition) || nb_contains(bangs,name)) && U32.is_le(nd_arity(book,name),32),
        u => Con{p113pl_boxed_candidate(book,name,signatures),
          nt_choose(List<&2,P113DCandidate>,String.eq(tg(dv(info)),"NQSig"),
            v => Con{p113pl_flat_candidate(book,name,signatures),p113pl_candidates(book,rest,bangs,signatures)},
            v => p113pl_candidates(book,rest,bangs,signatures))},
        u => p113pl_candidates(book,rest,bangs,signatures))

@unsafe
def p113pl_plan(+book: List<&2,KDef>, +names: List<&2,String>) -> List<&2,P113DFunction>:
  p113d_passes(p113pl_candidates(book,names,nc_bangs_names(book,names),nq_signatures(book,names)),missing(),[],32)

@unsafe
def p113pl_prepared(+source: List<&2,KDef>, +names: List<&2,String>, prepared: P112SPrepared) -> P113DLowering:
  match prepared:
    case P112SPrepared{+book,+nodes,+error}:
      nt_choose(P113DLowering,String.is_empty(error),
        u => p113d_finish(p112s_finish(nodes,p111_finish(source,names,p111_compile_defs(book,names,nc_bangs_names(book,names),0,[]))),p113pl_plan(book,names)),
        u => P113DLowered{P113DProgram{P112StaticProgram{p111_empty(),[]},[]},error})

@unsafe
def p113pl_lower_request(request: NR_Request) -> P113DLowering:
  match request:
    case NR_Request{+source,+book,+names,paths,scope,+bound}:
      +error = nc_compile_error_known(source,bound)
      nt_choose(P113DLowering,String.is_empty(error),
        u => p113pl_prepared(source,names,p112s_prepare(book,names,nc_add_ctors(nc_default_ctors(),nc_constructors(source,source)))),
        u => P113DLowered{P113DProgram{P112StaticProgram{p111_empty(),[]},[]},error})
