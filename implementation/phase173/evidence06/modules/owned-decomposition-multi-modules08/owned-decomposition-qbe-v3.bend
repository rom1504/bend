# Separate QBE-only permission variant; frozen pure v2 remains unchanged.
# Preconditions: source checked by p86_plan; selected fixed QBE runtime/provider
# bytes authenticated by acquisition/build receipts; p169np_plan runtime gate;
# p168_request_mode checked source/layout/observer admission. These internal
# helpers do not authenticate a forged book or a caller-provided permission.

# This conservative extra certificate permits known IO/File effects while
# excluding arbitrary foreign code and Rwt. It is NOT a purity proof. Its
# whole-body walk is charged as additional experimental compilation cost.
# The broader fixed-runtime gate already ran; do not repeat it on this path.
@unsafe
def p173op_prepared(book, names, prepared):
  match prepared:
    case P112SPrepared{+ready,nodes,+error}:
      nt_choose(P112SPrepared,String.is_empty(error) &&
        String.eq(dk(ns_context(ready)),"NativeStaticContext") &&
        U32.is_lt(norm_book_bound(book),3999998000) && p118ns_effect_definitions(True{},book,names),
        u => P112SPrepared{p173oa_publish(ready,p173oa_definitions(book,ready,names,
          index_first(dc(ns_context(ready))),U32.inc(norm_book_bound(book)),0)),nodes,error},
        u => prepared)

# Diagnostic only. Unlike the selected entry, this observation checks both
# predicates explicitly, allowing finite controls and scope census without
# compiling a new executable. Never use its timing as the production pass cost.
@unsafe
def p173op_permission(+source: List<&2,KDef>, +book: List<&2,KDef>, +names: List<&2,String>) -> Bool:
  String.is_empty(p111_runtime_effects(p111_effects(source,names),p111_runtime_names())) &&
    p118ns_effect_definitions(True{},book,names)

@unsafe
def p173op_inspect_request(request: NR_Request) -> List<&2,String>:
  match request:
    case NR_Request{+source,+book,+names,paths,scope,bound}:
      +runtime = String.is_empty(p111_runtime_effects(p111_effects(source,names),p111_runtime_names()))
      +certificate = p118ns_effect_definitions(True{},book,names)
      Con{nt_choose(String,runtime,u => "runtime:admitted",u => "runtime:refused"),
        Con{nt_choose(String,certificate,u => "observer-certificate:admitted",u => "observer-certificate:refused"),
          nt_choose(List<&2,String>,runtime && certificate,
            u => Con{"scope:qbe-certified",p173oa_inspect_names(book,names,U32.inc(norm_book_bound(book)))},
            u => ["scope:qbe-refused"])}}
