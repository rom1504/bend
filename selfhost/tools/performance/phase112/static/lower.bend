@unsafe
def p112s_finish(+nodes: List<&2,P112SNode>, result: P111Result) -> P112SResult:
  match result:
    case P111Result{program,error}: P112SResult{P112StaticProgram{program,nodes},error}

@unsafe
def p112s_lower_prepared(+source: List<&2,KDef>, +names: List<&2,String>, prepared: P112SPrepared) -> P112SResult:
  match prepared:
    case P112SPrepared{+book,+nodes,+error}:
      nt_choose(P112SResult,String.is_empty(error),
        u => p112s_finish(nodes,p111_finish(source,names,p111_compile_defs(book,names,nc_bangs_names(book,names),0,[]))),
        u => P112SResult{P112StaticProgram{p111_empty(),[]},error})

@unsafe
def p112s_lower_request(request: NR_Request) -> P112SResult:
  match request:
    case NR_Request{+source,+book,+names,paths,scope,+bound}:
      +error = nc_compile_error_known(source,bound)
      nt_choose(P112SResult,String.is_empty(error),
        u => p112s_lower_prepared(source,names,p112s_prepare(book,names,nc_add_ctors(nc_default_ctors(),nc_constructors(source,source)))),
        u => P112SResult{P112StaticProgram{p111_empty(),[]},error})

@unsafe
def p112s_emit_verified(+bundle: P112StaticProgram, +error: String) -> P111Emission:
  nt_choose(P111Emission,String.is_empty(error),u => P111Emission{p112s_chunks(bundle),""},
    u => P111Emission{[],"static structured IR: " ++ error})

@unsafe
def p112s_emit_lowered(result: P112SResult) -> P111Emission:
  match result:
    case P112SResult{+bundle,+error}:
      nt_choose(P111Emission,String.is_empty(error),u => p112s_emit_verified(bundle,p112s_verify(bundle)),
        u => P111Emission{[],"static native lowering: " ++ error})
