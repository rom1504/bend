# Independent finite controls against the proposed core. Every retained cache
# below comes from p142ff_apply itself; no cache is fabricated as authority.
def p142ffd_cache(result: P142FFResult) -> P142FFCache:
  match result:
    case P142FFResult{value,cache,hit}: cache

def p142ffd_empty(cache: P142FFCache) -> Bool:
  match cache:
    case P142FFEmpty{}: True{}
    case P142FFCache{start,cut,original,fresh,next}: False{}

@unsafe
def p142ffd_checked(result: P142FFResult, expected: FFreshDefs, hit: Bool) -> Bool:
  match result:
    case P142FFResult{value,cache,used}:
      Bool.not(Bool.xor(used,hit)) && p142ft_same(value,expected)

@unsafe
def p142ffd_case(+book: List<&2,KDef>, +start: U32, cut: U32, cache: P142FFCache, hit: Bool) -> Bool:
  p142ffd_checked(p142ff_apply(book,start,cut,cache),f_fresh_defs(book,start),hit)

@unsafe
def p142ffd_invalid(result: P142FFResult, expected: FFreshDefs) -> Bool:
  match result:
    case P142FFResult{value,cache,hit}:
      Bool.not(hit) && p142ffd_empty(cache) && p142ft_same(value,expected)

@unsafe
def p142ffd_controls() -> List<&2,String>:
  +one = p142ft_definition("one",7,8,[],False{},False{})
  +two = p142ft_definition("two",90,91,[],True{},True{})
  +nested = p142ft_nested()
  +original : List<&2,KDef> = [one,two]
  +edited : List<&2,KDef> = [one,nested]
  +cache_a = p142ffd_cache(p142ff_apply(original,10,1,P142FFEmpty{}))
  +cache_b = p142ffd_cache(p142ff_apply(edited,10,1,cache_a))
  +path_a = f_path_defs([p142ft_foreign("./foreign.js")],"/a/",False{})
  +path_b = f_path_defs([p142ft_foreign("./foreign.js")],"/b/",False{})
  +path_cache = p142ffd_cache(p142ff_apply(norm_defs_join(path_a,[one]),10,1,P142FFEmpty{}))
  +absolute_a = f_path_defs([p142ft_foreign("/shared/foreign.js")],"/a/",False{})
  +absolute_b = f_path_defs([p142ft_foreign("/shared/foreign.js")],"/b/",False{})
  +absolute_cache = p142ffd_cache(p142ff_apply(norm_defs_join(absolute_a,[one]),10,1,P142FFEmpty{}))
  +new_prefix : List<&2,KDef> = [p142ft_definition("one",7,8,[],False{},True{}),two]
  +new_cache = p142ffd_cache(p142ff_apply(new_prefix,10,1,cache_a))
  [p114st_row("freshening-core-cold-exact",p142ffd_case(original,10,1,P142FFEmpty{},False{})),
   p114st_row("freshening-core-warm-exact",p142ffd_case(original,10,1,cache_a,True{})),
   p114st_row("freshening-core-suffix-binder-change",p142ffd_case(edited,10,1,cache_a,True{})),
   p114st_row("freshening-core-edit-revert",p142ffd_case(original,10,1,cache_b,True{})),
   p114st_row("freshening-core-start-change",p142ffd_case(original,11,1,cache_a,False{})),
   p114st_row("freshening-core-cut-change",p142ffd_case(original,10,2,cache_a,False{})),
   p114st_row("freshening-core-prefix-flag-change",p142ffd_case(new_prefix,10,1,cache_a,False{})),
   p114st_row("freshening-core-miss-publishes-current-prefix",p142ffd_case(new_prefix,10,1,new_cache,True{})),
   p114st_row("freshening-core-relative-path-change",p142ffd_case(norm_defs_join(path_b,[one]),10,1,path_cache,False{})),
   p114st_row("freshening-core-absolute-path-stable",p142ffd_case(norm_defs_join(absolute_b,[one]),10,1,absolute_cache,True{})),
   p114st_row("freshening-core-short-book-fallback",p142ffd_invalid(p142ff_apply([],10,1,cache_a),f_fresh_defs([],10))),
   p114st_row("freshening-core-out-of-range-cut-fallback",p142ffd_invalid(p142ff_apply(original,10,3,cache_a),f_fresh_defs(original,10)))]
