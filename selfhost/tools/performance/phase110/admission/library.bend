# Roots are declarations only. Dependency discovery, certification and closed
# machine-name binding are all performed here over the same checked request.
type NxeRoot is Data:
  NxeRoot{+source: String, +symbol: String}

type NxeReferences is Data:
  NxeReferences{+names: List<&2,String>, +error: String}

type NxeClosure is Data:
  NxeClosure{+sources: List<&2,NxcSource>, +certificates: List<&2,NxeCertificate>, +exports: List<&2,String>, +error: String}

@unsafe
def nxe_name_in(+names: List<&2,String>, +name: String) -> Bool:
  match names:
    case Nil{}: False{}
    case Con{head,rest}: String.eq(head,name) || nxe_name_in(rest,name)

@unsafe
def nxe_root_names(+roots: List<&2,NxeRoot>, +symbols: Bool) -> List<&2,String>:
  match roots:
    case Nil{}: []
    case Con{NxeRoot{source,symbol},rest}:
      Con{nx_choose(String,symbols,u => symbol,u => source),nxe_root_names(rest,symbols)}

@unsafe
def nxe_roots_ok(+roots: List<&2,NxeRoot>) -> Bool:
  match roots:
    case Nil{}: True{}
    case Con{NxeRoot{source,symbol},rest}:
      Bool.not(String.eq(source,"")) && nx_ident(symbol) &&
      Bool.not(String.starts_with(symbol,"nxe_private_") || String.starts_with(symbol,"rt_")) &&
      Bool.not(nxe_name_in(nxe_root_names(rest,False{}),source) || nxe_name_in(nxe_root_names(rest,True{}),symbol)) && nxe_roots_ok(rest)

@unsafe
def nxe_private_codes(name: String) -> String:
  match name:
    case SNil{}: ""
    case SCon{head,rest}: U32.show(Char.to_u32(head)) ++ "_" ++ nxe_private_codes(rest)

@unsafe
def nxe_symbol(+name: String, +roots: List<&2,NxeRoot>) -> String:
  match roots:
    case Nil{}: "nxe_private_" ++ nxe_private_codes(name)
    case Con{NxeRoot{source,symbol},rest}:
      nx_choose(String,String.eq(source,name),u => symbol,u => nxe_symbol(name,rest))

# Ref records are dependency identities only. The existing owned body admission
# independently refuses partial/dynamic calls and unsupported erased operations.
@unsafe
def nxe_references(todo: List<&2,KTerm>, +left: U32, +names: List<&2,String>) -> NxeReferences:
  match todo:
    case Nil{}: NxeReferences{names,""}
    case Con{+head,rest}:
      nx_choose(NxeReferences,U32.is_eq(left,0),u => NxeReferences{[],"erased body dependency budget exhausted"},u =>
        nxe_references(nxo_join(KTerm,ks(head),rest),U32.sub(left,1),
          nx_choose(List<&2,String>,String.eq(tg(head),"Ref") && Bool.not(nxe_name_in(names,nm(head))),v => Con{nm(head),names},v => names)))

def nxe_close_refused(error: String) -> NxeClosure:
  NxeClosure{[],[],[],error}

@unsafe
def nxe_close_walk(+source_book: List<&2,KDef>, +erased_facts: List<&2,KDef>, +roots: List<&2,NxeRoot>, todo: List<&2,String>, +done: List<&2,String>, +sources: List<&2,NxcSource>, +certificates: List<&2,NxeCertificate>, +left: U32) -> NxeClosure:
  match todo:
    case Nil{}: NxeClosure{sources,certificates,nxe_root_names(roots,True{}),""}
    case Con{+name,+rest}:
      nx_choose(NxeClosure,nxe_name_in(done,name),u => nxe_close_walk(source_book,erased_facts,roots,rest,done,sources,certificates,left),u =>
      nx_choose(NxeClosure,U32.is_eq(left,0),v => nxe_close_refused("checked callee closure budget exhausted"),v =>
        nxe_close_entry(source_book,erased_facts,roots,name,rest,done,sources,certificates,U32.sub(left,1),nxe_entry(source_book,erased_facts,name))))

@unsafe
def nxe_close_entry(+source_book: List<&2,KDef>, +erased_facts: List<&2,KDef>, +roots: List<&2,NxeRoot>, +name: String, +todo: List<&2,String>, +done: List<&2,String>, +sources: List<&2,NxcSource>, +certificates: List<&2,NxeCertificate>, +left: U32, result: NxeResult) -> NxeClosure:
  match result:
    case NxeResult{None{},error}: nxe_close_refused(name ++ ": " ++ error)
    case NxeResult{Some{certificate},error}:
      nxe_close_certificate(source_book,erased_facts,roots,name,todo,done,sources,certificates,left,certificate)

@unsafe
def nxe_close_certificate(+source_book: List<&2,KDef>, +erased_facts: List<&2,KDef>, +roots: List<&2,NxeRoot>, +name: String, +todo: List<&2,String>, +done: List<&2,String>, +sources: List<&2,NxcSource>, +certificates: List<&2,NxeCertificate>, +left: U32, +certificate: NxeCertificate) -> NxeClosure:
  match certificate:
    case NxeCertificate{source,erased,params,result,constructors,abi}:
      nxe_close_refs(source_book,erased_facts,roots,name,todo,done,
        nxo_join(NxcSource,sources,[NxcSource{erased,nxe_symbol(name,roots)}]),
        nxo_join(NxeCertificate,certificates,[certificate]),left,nxe_references([dv(erased)],8192,[]))

@unsafe
def nxe_close_refs(+source_book: List<&2,KDef>, +erased_facts: List<&2,KDef>, +roots: List<&2,NxeRoot>, +name: String, +todo: List<&2,String>, +done: List<&2,String>, +sources: List<&2,NxcSource>, +certificates: List<&2,NxeCertificate>, +left: U32, references: NxeReferences) -> NxeClosure:
  match references:
    case NxeReferences{names,+error}:
      nx_choose(NxeClosure,String.eq(error,""),u =>
        nxe_close_walk(source_book,erased_facts,roots,nxo_join(String,names,todo),Con{name,done},sources,certificates,left),u => nxe_close_refused(name ++ ": " ++ error))

@unsafe
def nxe_close(+source_book: List<&2,KDef>, +erased_facts: List<&2,KDef>, +roots: List<&2,NxeRoot>) -> NxeClosure:
  nx_choose(NxeClosure,nxe_roots_ok(roots) && Bool.not(List.is_empty(&2,NxeRoot,roots)) && U32.is_le(nxo_size(NxeRoot,roots),32),u =>
    nxe_close_walk(source_book,erased_facts,roots,nxe_root_names(roots,False{}),[],[],[],128),u => nxe_close_refused("invalid checked export declarations"))

@unsafe
def nxe_lower_closed(closure: NxeClosure, +policy: String) -> NxcLibraryResult:
  match closure:
    case NxeClosure{sources,certificates,exports,+error}:
      nx_choose(NxcLibraryResult,String.eq(error,""),u => nxc_lower_library(sources,nxe_constructors(),exports,policy),u => nxc_refused(error))

@unsafe
def nxe_lower_library(+source_book: List<&2,KDef>, +erased_facts: List<&2,KDef>, +roots: List<&2,NxeRoot>, +policy: String) -> NxcLibraryResult:
  nxe_lower_closed(nxe_close(source_book,erased_facts,roots),policy)

@unsafe
def nxe_lower_runtime_closed(closure: NxeClosure, +view: String) -> Nx110RtLibraryResult:
  match closure:
    case NxeClosure{sources,certificates,exports,+error}:
      nx_choose(Nx110RtLibraryResult,String.eq(error,""),u => nx110rt_lower_library(sources,nxe_constructors(),exports,view),u => nx110rt_library_refused(error))

@unsafe
def nxe_lower_runtime_library(+source_book: List<&2,KDef>, +erased_facts: List<&2,KDef>, +roots: List<&2,NxeRoot>, +view: String) -> Nx110RtLibraryResult:
  nxe_lower_runtime_closed(nxe_close(source_book,erased_facts,roots),view)
