# V2: adapts the diagnostic to the reserved-namespace SCC API.
# This remains pre-early-ready; no workers are reserved in this diagnostic.
# Diagnostic only: exact raw lowering errors and component obligations for the
# actual store functions. No final-verifier or admission policy replacement.

type P173VDComponent is Data:
  P173VDComponent{+names: List<&2,String>, +found: U32, +result: U32,
    +width: U32, +statements: U32, +stack: U32, +valid: Bool}

type P173VDReport is Data:
  P173VDReport{+error: String, +selected: List<&2,String>,
    +signatures: List<&2,KDef>, +raw: List<&2,P113DCandidate>,
    +components: List<&2,P173VDComponent>}

@unsafe
def p173vd_select(names: List<&2,String>) -> List<&2,String>:
  match names:
    case Nil{}: []
    case Con{+name,+rest}:
      nt_choose(List<&2,String>,String.starts_with(name,"p173") &&
        Bool.not(String.starts_with(name,"p173vn_")),
        u => Con{name,p173vd_select(rest)},u => p173vd_select(rest))

@unsafe
def p173vd_signature_rows(+signatures: List<&2,KDef>, names: List<&2,String>) -> List<&2,KDef>:
  match names:
    case Nil{}: []
    case Con{name,rest}: Con{lookup(signatures,name),p173vd_signature_rows(signatures,rest)}

@unsafe
def p173vd_component(+names: List<&2,String>, +functions: List<&2,P113DFunction>) -> P173VDComponent:
  match functions:
    case Nil{}: P173VDComponent{names,0,0,0,0,0,False{}}
    case Con{+first,+rest}:
      P173VDComponent{names,nt_count(P113DFunction,functions),p173sc_result(first),
        p173sc_width(functions),p173sc_size(functions),p173sc_stack(functions),
        p173sc_valid(functions,p173sc_members(functions,0,missing()),p173sc_result(first))}

@unsafe
def p173vd_components(groups: List<&2,List<&2,String>>, +index: P113ITable) -> List<&2,P173VDComponent>:
  match groups:
    case Nil{}: []
    case Con{+names,rest}:
      Con{p173vd_component(names,p173sc_functions(names,index)),p173vd_components(rest,index)}

@unsafe
def p173vd_indexed(+selected: List<&2,String>, signatures: List<&2,KDef>,
  +raw: List<&2,P113DCandidate>, +counts: KDef, +index: P113ITable) -> P173VDReport:
  P173VDReport{"",selected,p173vd_signature_rows(signatures,selected),raw,
    p173vd_components(p173sc_groups(p173sc_search(p173sc_names(raw),[],index,counts,
      P173SCSearch{missing(),[],1,[]})),index)}

@unsafe
def p173vd_counted(selected: List<&2,String>, signatures: List<&2,KDef>,
  +raw: List<&2,P113DCandidate>, +counts: KDef) -> P173VDReport:
  p173vd_indexed(selected,signatures,raw,counts,p173sc_table(raw,counts,missing(),P113IEmpty{}))

@unsafe
def p173vd_lowered(selected: List<&2,String>, signatures: List<&2,KDef>,
  +raw: List<&2,P113DCandidate>) -> P173VDReport:
  p173vd_counted(selected,signatures,raw,p173sc_counts(raw,missing(),0))

@unsafe
def p173vd_lower(+book: List<&2,KDef>, +selected: List<&2,String>,
  +signatures: List<&2,KDef>) -> P173VDReport:
  p173vd_lowered(selected,signatures,
    p113pl_candidates(book,selected,nc_bangs_names(book,selected),signatures))

@unsafe
def p173vd_prepared(+names: List<&2,String>, prepared: P112SPrepared) -> P173VDReport:
  match prepared:
    case P112SPrepared{+book,nodes,+error}:
      nt_choose(P173VDReport,String.is_empty(error),
        u => p173vd_lower(book,p173vd_select(names),book_cached(nq_signatures(book,names),0)),
        u => P173VDReport{error,[],[],[],[]})

@unsafe
def p173vd_request(request: NR_Request) -> P173VDReport:
  match request:
    case NR_Request{+source,+book,+names,paths,scope,bound}:
      p173vd_prepared(names,p112s_prepare(book,names,
        nc_add_ctors(nc_default_ctors(),p144o_constructors(source,source,
          p144o_payload(nc_ctor_context(book))))))
