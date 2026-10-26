# Exact first-prior view. The original scope.index has different duplicate
# precedence and is intentionally retained unchanged. None preserves raw callers.
@unsafe
def p144p_find(+name: String, +prior: List<&2,KDef>, view: Maybe<&2,KDef>) -> KDef:
  match view:
    case None{}: f_find(name,prior)
    case Some{index}:
      kc(KDef,String.is_empty(name),u => f_find(name,prior),u =>
        p144p_found(name,index_find(index,name,index_hash(name,2166136261),32)))

@unsafe
def p144p_found(+name: String, +found: KDef) -> KDef:
  kc(KDef,p88_string_eq(dn(found),name),u => found,u => f_find(name,[]))

@unsafe
def p144p_ready_scope(+scope: FParseScope) -> FParseScope:
  match scope:
    case FParseScope{+prior,index,ctors,ns,aliases,view}:
      match view:
        case None{}: FParseScope{prior,index,ctors,ns,aliases,Some{index_build(prior)}}
        case Some{ready}: scope

@unsafe
def p144p_update(+definition: KDef, view: Maybe<&2,KDef>) -> Maybe<&2,KDef>:
  match view:
    case None{}: None{}
    case Some{index}: Some{index_set(index,definition,index_hash(dn(definition),2166136261),32)}

@unsafe
def p144p_declared(+d: KDef, +prior: List<&2,KDef>, +index: KDef,
    +ctorIndex: KDef, +ns: String, +aliases: List<&2,KTerm>, view: Maybe<&2,KDef>) -> FParseScope:
  FParseScope{Con{d,prior},index_set(index,d,index_hash(dn(d),2166136261),32),
    f_ctor_index_def(d,ctorIndex),ns,aliases,p144p_update(d,view)}

@unsafe
def p144p_view_same(left: Maybe<&2,KDef>, right: Maybe<&2,KDef>) -> Bool:
  match left right:
    case None{} None{}: True{}
    case Some{a} Some{b}: p140eq_def(a,b)
    case _ _: False{}
