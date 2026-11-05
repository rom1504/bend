# Experimental closed direct library. No generic segment bodies or program
# descriptor are constructed. The caller supplies a checked prepared NR_Request.
# This is not a standalone executable or a replacement for source checking.

type P163DExport is Data:
  P163DExport{+source: String, +owner: String, +arity: U32}

type P163DExports is Data:
  P163DExports{+items: List<&2,P163DExport>, +error: String}

type P163DLibrary is Data:
  P163DLibrary{+exports: List<&2,P163DExport>, +constructors: List<&2,N_Constructor>,
    +nodes: List<&2,P112SNode>, +functions: List<&2,P113DFunction>,
    +text: String, +error: String}

def p163d_error(library: P163DLibrary) -> String:
  match library:
    case P163DLibrary{exports,constructors,nodes,functions,text,error}: error

def p163d_text(library: P163DLibrary) -> String:
  match library:
    case P163DLibrary{exports,constructors,nodes,functions,text,error}: text

def p163d_fail(error: String) -> P163DLibrary:
  P163DLibrary{[],[],[],[],"",error}

# The empty function-ID map means ZERO scheduled function identities exist.
# The direct verifier rejects closure construction, scheduler operations and
# unknown FuncIds. Direct-call signatures are inserted in checked order only.
@unsafe
def p163d_verify(+constructors: List<&2,N_Constructor>, +nodes: List<&2,P112SNode>,
    +functions: List<&2,P113DFunction>) -> String:
  p163d_verify_ctors(constructors,nodes,functions,
    p111v_constructors(constructors,P111VScan{missing(),"",0}))

@unsafe
def p163d_verify_ctors(+constructors: List<&2,N_Constructor>, +nodes: List<&2,P112SNode>,
    +functions: List<&2,P113DFunction>, scan: P111VScan) -> String:
  match scan:
    case P111VScan{index,+error,count}:
      nt_choose(String,String.is_empty(error),
        u => p163d_verify_nodes(constructors,functions,
          p112s_nodes_error(nodes,p112s_ctors(constructors,0,missing()),missing(),0)),
        u => error)

@unsafe
def p163d_verify_nodes(+constructors: List<&2,N_Constructor>, +functions: List<&2,P113DFunction>,
    +error: String) -> String:
  nt_choose(String,String.is_empty(error),
    u => p113e_functions(functions,N111Ids{missing(),ns_ctor_index(constructors,missing())},missing()),
    u => error)

# public=False means no scheduler adapter is claimed by this library. Names,
# parameters, results and bodies are unchanged; external ordinary-call exports
# are independently matched to requested source arities below.
def p163d_private(functions: List<&2,P113DFunction>) -> List<&2,P113DFunction>:
  match functions:
    case Nil{}: []
    case Con{P113DFunction{name,params,result,public,body},rest}:
      Con{P113DFunction{name,params,result,False{},body},p163d_private(rest)}

@unsafe
def p163d_source_names(+book: List<&2,KDef>, names: List<&2,String>, +bangs: List<&2,String>) -> String:
  match names:
    case Nil{}: ""
    case Con{+name,+rest}:
      +definition = lookup(book,name)
      nt_choose(String,String.eq(dk(definition),"Absent"),
        u => "direct library: unknown declaration " ++ name,
        u => nt_choose(String,nc_native_def(definition),
          v => p163d_source_names(book,rest,bangs),
          v => nt_choose(String,Bool.not(String.eq(dk(definition),"Def")) || nc_foreign(definition) || nb_contains(bangs,name),
            w => "direct library: nonordinary/foreign/bang declaration " ++ name,
            w => p163d_source_names(book,rest,bangs))))

@unsafe
def p163d_exports(+book: List<&2,KDef>, roots: List<&2,String>, +ready: KDef) -> P163DExports:
  match roots:
    case Nil{}: P163DExports{[],""}
    case Con{+name,rest}:
      +definition = lookup(book,name)
      +owner = p113d_public(book,name)
      +entry = p111v_get(ready,owner)
      nt_choose(P163DExports,String.eq(dk(definition),"Def") &&
        Bool.not(nc_native_def(definition) || nc_foreign(definition)) &&
        String.eq(dk(entry),"P113Direct") && U32.is_eq(dx(entry),1) &&
        U32.is_eq(da(entry),nd_arity(book,name)),
        u => p163d_export_cons(P163DExport{name,owner,da(entry)},p163d_exports(book,rest,ready)),
        u => P163DExports{[],"direct library: root has no complete admitted boxed entry " ++ name})

def p163d_export_cons(head: P163DExport, tail: P163DExports) -> P163DExports:
  match tail:
    case P163DExports{rest,error}: P163DExports{Con{head,rest},error}

# Wrapper formals are ordinal and separate from generated worker-local names.
@unsafe
def p163d_export_params(+arity: U32, +at: U32, +acc: String) -> String:
  nt_choose(String,U32.is_eq(at,arity),u => acc,
    u => p163d_export_params(arity,U32.inc(at),acc ++ ", l %p163_arg_" ++ U32.show(at)))

@unsafe
def p163d_export_text(entry: P163DExport, +at: U32) -> String:
  match entry:
    case P163DExport{source,+owner,+arity}:
      +args = p163d_export_params(arity,0,"l %state")
      "export function l $p163_entry_" ++ U32.show(at) ++ "(" ++ args ++ ") {\n@entry\n" ++
      "%p163_result =l call $" ++ p113e_symbol(owner) ++ "(" ++ args ++ ")\nret %p163_result\n}\n"

@unsafe
def p163d_export_chunks(entries: List<&2,P163DExport>, +at: U32) -> List<&2,String>:
  match entries:
    case Nil{}: []
    case Con{head,rest}: Con{p163d_export_text(head,at),p163d_export_chunks(rest,U32.inc(at))}

# This is a library catalogue, NOT ABI11101's executable program descriptor.
# The runtime harness must bind the exact CID order/static image before calls.
@unsafe
def p163d_data(+constructors: List<&2,N_Constructor>, +nodes: List<&2,P112SNode>,
    +exports: List<&2,P163DExport>) -> List<&2,P111QData>:
  +names = p111q_ctor_names(constructors)
  [P111QData{"p163_library_meta",8,True{},[
      P111QLong{16301,0},P111QLong{nt_count(N_Constructor,constructors),0},
      P111QLong{p112s_size(nodes,0),0},P111QLong{nt_count(P163DExport,exports),0}]},
   P111QData{"p163_cid_arity",1,True{},p111q_ctor_table(constructors,False{},[])},
   P111QData{"p163_cid_hot",1,True{},p111q_ctor_table(constructors,True{},[])},
   P111QData{"p163_cid_names",8,True{},p111q_string_refs(names,"p163_cid_name",0,[])},
   P111QData{"p163_static_image",8,True{},p111q_nonempty(
     p112s_image_items(nodes,p112s_ctors(constructors,0,missing()),[]))}]

@unsafe
def p163d_emit(+exports: List<&2,P163DExport>, +constructors: List<&2,N_Constructor>,
    +nodes: List<&2,P112SNode>, +functions: List<&2,P113DFunction>) -> String:
  +ids : N111Ids = N111Ids{missing(),p111q_constructor_ids(constructors,0,missing())}
  nt_text_finish(nt_reverse(String,nt_append(String,p113e_private_chunks(functions,ids,[]),
    nt_append(String,p163d_export_chunks(exports,0),
      p111q_data_chunks(nt_append(P111QData,p163d_data(constructors,nodes,exports),
        p111q_string_defs(p111q_ctor_names(constructors),"p163_cid_name",0,[]))))),[]),"")

@unsafe
def p163d_admitted(+book: List<&2,KDef>, +roots: List<&2,String>,
    +constructors: List<&2,N_Constructor>, +nodes: List<&2,P112SNode>,
    +functions: List<&2,P113DFunction>) -> P163DLibrary:
  +error = p163d_verify(constructors,nodes,functions)
  nt_choose(P163DLibrary,String.is_empty(error),
    u => p163d_finish(constructors,nodes,functions,
      p163d_exports(book,roots,p113e_signatures(functions,missing()))),
    u => p163d_fail("direct library verification: " ++ error))

@unsafe
def p163d_finish(+constructors: List<&2,N_Constructor>, +nodes: List<&2,P112SNode>,
    +functions: List<&2,P113DFunction>, exports: P163DExports) -> P163DLibrary:
  match exports:
    case P163DExports{+items,+error}:
      nt_choose(P163DLibrary,String.is_empty(error),
        u => P163DLibrary{items,constructors,nodes,functions,"",""},
        u => p163d_fail(error))

@unsafe
def p163d_candidates(+book: List<&2,KDef>, +roots: List<&2,String>,
    +constructors: List<&2,N_Constructor>, +nodes: List<&2,P112SNode>,
    raw: List<&2,P113DCandidate>) -> P163DLibrary:
  p163d_admitted(book,roots,constructors,nodes,
    p163d_private(p113d_passes(p126sc_candidates(raw),missing(),[],32)))

@unsafe
def p163d_prepared(+roots: List<&2,String>, +names: List<&2,String>,
    +constructors: List<&2,N_Constructor>, prepared: P112SPrepared) -> P163DLibrary:
  match prepared:
    case P112SPrepared{+book,+nodes,+error}:
      nt_choose(P163DLibrary,String.is_empty(error),
        u => p163d_candidates(book,roots,constructors,nodes,
          p113pl_candidates(book,names,nc_bangs_names(book,names),book_cached(nq_signatures(book,names),0))),
        u => p163d_fail("direct library static preparation: " ++ error))

@unsafe
def p163d_selected(+source: List<&2,KDef>, +book: List<&2,KDef>, +roots: List<&2,String>,
    closure: NR_Closure) -> P163DLibrary:
  match closure:
    case NR_Closure{+names,facts}:
      +fresh = ns_attach_book(book,facts,0,[])
      +error = p163d_source_names(fresh,names,nc_bangs_names(fresh,names))
      nt_choose(P163DLibrary,String.is_empty(error),
        u => p163d_catalogued(fresh,roots,names,nc_add_ctors(nc_default_ctors(),
          p144o_constructors(source,source,p144o_payload(nc_ctor_context(book))))),
        u => p163d_fail(error))

@unsafe
def p163d_catalogued(+book: List<&2,KDef>, +roots: List<&2,String>,
    +names: List<&2,String>, +constructors: List<&2,N_Constructor>) -> P163DLibrary:
  p163d_prepared(roots,names,constructors,p112s_prepare(book,names,constructors))

@unsafe
def p163d_plan(request: NR_Request, +roots: List<&2,String>) -> P163DLibrary:
  match request:
    case NR_Request{+source,+book,names,paths,scope,bound}:
      +error = nc_compile_error_known(source,bound)
      nt_choose(P163DLibrary,List.is_empty(&2,String,roots),
        u => p163d_fail("direct library: at least one ordinary root is required"),
        u => nt_choose(P163DLibrary,String.is_empty(error),
          v => p163d_selected(source,book,roots,nr_walk(book,roots,[],[])),
          v => p163d_fail("direct library request: " ++ error)))

# Planning performs lowering/admission/verification exactly once and leaves
# text empty. Library and executable rendering each consume that same plan;
# neither renderer repeats semantic work or manufactures a new certificate.
@unsafe
def p163d_render(plan: P163DLibrary) -> P163DLibrary:
  match plan:
    case P163DLibrary{+exports,+constructors,+nodes,+functions,text,+error}:
      nt_choose(P163DLibrary,String.is_empty(error),
        u => P163DLibrary{exports,constructors,nodes,functions,
          p163d_emit(exports,constructors,nodes,functions),""},
        u => p163d_fail(error))

@unsafe
def p163d_library(request: NR_Request, roots: List<&2,String>) -> P163DLibrary:
  p163d_render(p163d_plan(request,roots))

@unsafe
def p163d_summary(library: P163DLibrary) -> String:
  match library:
    case P163DLibrary{exports,constructors,nodes,functions,text,+error}:
      nt_choose(String,String.is_empty(error),
        u => "exports=" ++ U32.show(nt_count(P163DExport,exports)) ++
          ";functions=" ++ U32.show(nt_count(P113DFunction,functions)) ++
          ";constructors=" ++ U32.show(nt_count(N_Constructor,constructors)) ++
          ";staticWords=" ++ U32.show(p112s_size(nodes,0)) ++ ";genericSegments=0",
        u => "REFUSED: " ++ error)
