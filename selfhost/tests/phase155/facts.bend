# Phase155 facts experiments 01--04. All preparation, updates, checksum
# consumption and teardown are inside each standalone entry. No arrays.
# Kept separate mechanisms: scalar projection, fused query, cached hash,
# and atomic ordinary-fact/predicate publication.

@unsafe
def p155f_name(+raw: U32) -> P154Name:
  p155f_name_at(U32.and(raw,31))

@unsafe
def p155f_name_at(+id: U32) -> P154Name:
  nt_choose(P154Name,U32.is_eq(id,0),u => P154Named{"value"},u =>
  nt_choose(P154Name,U32.is_eq(id,1),u => P154Named{"p112_s_a"},u =>
  nt_choose(P154Name,U32.is_eq(id,2),u => P154Named{"p112_s_b"},u =>
  nt_choose(P154Name,U32.is_eq(id,3),u => P154Named{"p112_s_test"},u =>
  nt_choose(P154Name,U32.is_eq(id,4),u => P154Binder{0},u =>
  nt_choose(P154Name,U32.is_eq(id,5),u => P154Binder{4294967295},u =>
  nt_choose(P154Name,U32.is_eq(id,6),u => P154Binder{1113510858},u => P154Binder{U32.sub(4294967295,id)})))))))

@unsafe
def p155f_seed(+left: U32, facts: P154Facts) -> P154Facts:
  match left:
    case 0: facts
    case _: p155f_seed(U32.sub(left,1),p155f_seed_name(facts,p155f_name(U32.sub(left,1)),left))

@unsafe
def p155f_seed_name(facts: P154Facts, +name: P154Name, +n: U32) -> P154Facts:
  p155f_seed_meta(p154k_put(facts,name,
    nt_choose(P113KFact,U32.is_eq(U32.mod(n,4),0),u => p113k_bound(1),u =>
      nt_choose(P113KFact,U32.is_eq(U32.mod(n,5),0),v => p113k_exact(n,0),v => p113k_bound(U32.inc(U32.mod(n,16)))))),name,U32.is_eq(U32.mod(n,4),0))

@unsafe
def p155f_seed_meta(facts: P154Facts, +name: P154Name, enabled: Bool) -> P154Facts:
  match enabled:
    case True{}: p154p_put(p154l_relate(facts,name,name,1,1),name,name,0)
    case False{}: facts

@unsafe
def p155f_next(bits: U32, i: U32) -> U32:
  U32.inc(U32.mod(U32.add(bits,i),63))

@unsafe
def p155f_combine(bits: U32, version: U32) -> U32:
  U32.add(bits,U32.mul(version,17))

@unsafe
def p155f_relation_sum(relation: P154Relation) -> U32:
  match relation:
    case P154NoRelation{}: 0
    case P154Relation{subject,version,epoch,truth}: U32.add(p154n_hash(subject),U32.add(version,U32.add(epoch,truth)))

@unsafe
def p155f_predicate_sum(predicate: P154Predicate) -> U32:
  match predicate:
    case P154NoPredicate{}: 0
    case P154Predicate{root,version,epoch,invert}: U32.add(p154n_hash(root),U32.add(version,U32.add(epoch,invert)))

@unsafe
def p155f_cell_sum(cell: P154FCell) -> U32:
  match cell:
    case P154FAbsent{}: 0
    case P154FCell{name,present,P113KFact{bits,exact,lo,hi},version,relation,predicate}:
      U32.add(p154n_hash(name),U32.add(Bool.to_u32(present),U32.add(bits,U32.add(Bool.to_u32(exact),
        U32.add(lo,U32.add(hi,U32.add(version,U32.add(p155f_relation_sum(relation),p155f_predicate_sum(predicate)))))))))

@unsafe
def p155f_finish(+facts: P154Facts, +left: U32, +acc: U32) -> String:
  match left:
    case 0: U32.show(acc)
    case _: p155f_finish(facts,U32.sub(left,1),U32.add(acc,p155f_cell_sum(p154f_get(facts,p155f_name(U32.sub(left,1))))))

# 01: descend to the requested scalar, never return a whole cell/fact.
@unsafe
def p155f_bits_bucket(cells: List<&2,P154FCell>, +name: P154Name) -> U32:
  match cells:
    case Nil{}: 64
    case Con{P154FCell{key,present,P113KFact{bits,exact,lo,hi},version,relation,predicate},rest}:
      nt_choose(U32,p154n_eq(key,name),u => nt_choose(U32,present,v => bits,v => 64),u => p155f_bits_bucket(rest,name))
    case Con{P154FAbsent{},rest}: p155f_bits_bucket(rest,name)

@unsafe
def p155f_bits_lookup(+tree: P154Facts, +name: P154Name, +hash: U32) -> U32:
  match tree:
    case P154FEmpty{}: 64
    case P154FLeaf{stored,cells}: nt_choose(U32,U32.is_eq(stored,hash),u => p155f_bits_bucket(cells,name),u => 64)
    case P154FNode{prefix,mask,left,right}:
      nt_choose(U32,U32.is_eq(U32.and(U32.xor(prefix,hash),U32.sub(mask,1)),0),
        u => nt_choose(U32,U32.is_eq(U32.and(hash,mask),0),v => p155f_bits_lookup(left,name,hash),v => p155f_bits_lookup(right,name,hash)),u => 64)

@unsafe
def p155f_bits(+facts: P154Facts, +name: P154Name) -> U32:
  p155f_bits_lookup(facts,name,p154n_hash(name))

# 02: one existing whole-cell lookup supplies width and epoch together.
# Unlike 01, this deliberately retains the owned whole-cell result interface.
@unsafe
def p155f_combined(+facts: P154Facts, +name: P154Name) -> U32:
  p155f_combined_cell(p154f_get(facts,name))

@unsafe
def p155f_combined_cell(cell: P154FCell) -> U32:
  match cell:
    case P154FCell{name,present,P113KFact{bits,exact,lo,hi},version,relation,predicate}:
      p155f_combine(nt_choose(U32,present,u => bits,u => 64),version)
    case _: 64

# 03: preserve the same whole-cell reads and update count, retain only the hash.
@unsafe
def p155f_put_hash(+facts: P154Facts, +name: P154Name, +hash: U32, value: P113KFact) -> P154Facts:
  p155f_put_hash_cell(facts,name,hash,value,p154f_lookup(facts,name,hash))

@unsafe
def p155f_put_hash_cell(facts: P154Facts, +name: P154Name, hash: U32, value: P113KFact, cell: P154FCell) -> P154Facts:
  match cell:
    case P154FCell{old,present,prior,version,relation,predicate}:
      p154f_insert(facts,name,hash,P154FCell{name,True{},value,U32.inc(version),relation,predicate})
    case _: p154f_insert(facts,name,hash,P154FCell{name,True{},value,1,P154NoRelation{},P154NoPredicate{}})

# 04: ordinary fact then self-rooted predicate is the p154p_record comparison
# publication shape. Publish both fields once while retaining old relations.
@unsafe
def p155f_publish_old(facts: P154Facts, +name: P154Name, value: P113KFact, invert: U32) -> P154Facts:
  p154p_put(p154k_put(facts,name,value),name,name,invert)

@unsafe
def p155f_publish_new(+facts: P154Facts, +name: P154Name, value: P113KFact, invert: U32) -> P154Facts:
  p155f_publish_cell(facts,name,value,invert,p154f_get(facts,name))

@unsafe
def p155f_publish_cell(facts: P154Facts, name: P154Name, value: P113KFact, invert: U32, cell: P154FCell) -> P154Facts:
  match cell:
    case P154FCell{old,present,prior,version,relation,predicate}:
      p155f_publish_at(facts,name,value,U32.inc(version),relation,invert)
    case _: p155f_publish_at(facts,name,value,1,P154NoRelation{},invert)

@unsafe
def p155f_publish_at(facts: P154Facts, +name: P154Name, value: P113KFact, +version: U32, relation: P154Relation, invert: U32) -> P154Facts:
  p154f_put(facts,name,P154FCell{name,True{},value,version,relation,P154Predicate{name,version,version,invert}})

@unsafe
def p155f_observed(predicate: P154Predicate) -> U32:
  match predicate:
    case P154NoPredicate{}: 0
    case P154Predicate{root,version,epoch,invert}: U32.inc(U32.add(version,U32.add(epoch,invert)))

@unsafe
def p155f_01_old(+n: U32) -> String:
  p155f_01_old_loop(p155f_seed(32,P154FEmpty{}),n,0,0)

@unsafe
def p155f_01_old_loop(+facts: P154Facts, +left: U32, +i: U32, +acc: U32) -> String:
  match left:
    case 0: p155f_finish(facts,32,acc)
    case n:
      +bits = p113k_bits_of(p154k_get(facts,p155f_name(U32.add(i,7))))
      +value = p155f_next(bits,i)
      p155f_01_old_loop(p154k_put(facts,p155f_name(i),p113k_bound(value)),U32.sub(n,1),U32.inc(i),U32.add(acc,U32.add(bits,value)))

@unsafe
def p155f_01_new(+n: U32) -> String:
  p155f_01_new_loop(p155f_seed(32,P154FEmpty{}),n,0,0)

@unsafe
def p155f_01_new_loop(+facts: P154Facts, +left: U32, +i: U32, +acc: U32) -> String:
  match left:
    case 0: p155f_finish(facts,32,acc)
    case n:
      +bits = p155f_bits(facts,p155f_name(U32.add(i,7)))
      +value = p155f_next(bits,i)
      p155f_01_new_loop(p154k_put(facts,p155f_name(i),p113k_bound(value)),U32.sub(n,1),U32.inc(i),U32.add(acc,U32.add(bits,value)))

@unsafe
def p155f_02_old(+n: U32) -> String:
  p155f_02_old_loop(p155f_seed(32,P154FEmpty{}),n,0,0)

@unsafe
def p155f_02_old_loop(+facts: P154Facts, +left: U32, +i: U32, +acc: U32) -> String:
  match left:
    case 0: p155f_finish(facts,32,acc)
    case n:
      +name = p155f_name(U32.add(i,7))
      +score = p155f_combine(p113k_bits_of(p154k_get(facts,name)),p154l_version(facts,name))
      +value = p155f_next(score,i)
      p155f_02_old_loop(p154k_put(facts,p155f_name(i),p113k_bound(value)),U32.sub(n,1),U32.inc(i),U32.add(acc,U32.add(score,value)))

@unsafe
def p155f_02_new(+n: U32) -> String:
  p155f_02_new_loop(p155f_seed(32,P154FEmpty{}),n,0,0)

@unsafe
def p155f_02_new_loop(+facts: P154Facts, +left: U32, +i: U32, +acc: U32) -> String:
  match left:
    case 0: p155f_finish(facts,32,acc)
    case n:
      +name = p155f_name(U32.add(i,7))
      +score = p155f_combined(facts,name)
      +value = p155f_next(score,i)
      p155f_02_new_loop(p154k_put(facts,p155f_name(i),p113k_bound(value)),U32.sub(n,1),U32.inc(i),U32.add(acc,U32.add(score,value)))

@unsafe
def p155f_03_old(+n: U32) -> String:
  p155f_03_old_loop(p155f_seed(32,P154FEmpty{}),n,0,0)

@unsafe
def p155f_03_old_loop(+facts: P154Facts, +left: U32, +i: U32, +acc: U32) -> String:
  match left:
    case 0: p155f_finish(facts,32,acc)
    case n:
      +name = p155f_name(i)
      +score = p155f_combine(p113k_bits_of(p154k_get(facts,name)),p154l_version(facts,name))
      +value = p155f_next(score,i)
      p155f_03_old_loop(p154k_put(facts,name,p113k_bound(value)),U32.sub(n,1),U32.inc(i),U32.add(acc,U32.add(score,value)))

@unsafe
def p155f_03_new(+n: U32) -> String:
  p155f_03_new_loop(p155f_seed(32,P154FEmpty{}),n,0,0)

@unsafe
def p155f_03_new_loop(+facts: P154Facts, +left: U32, +i: U32, +acc: U32) -> String:
  match left:
    case 0: p155f_finish(facts,32,acc)
    case n:
      +name = p155f_name(i)
      +hash = p154n_hash(name)
      +score = p155f_combine(p113k_bits_of(p154f_value(p154f_lookup(facts,name,hash))),p154f_version(p154f_lookup(facts,name,hash)))
      +value = p155f_next(score,i)
      p155f_03_new_loop(p155f_put_hash(facts,name,hash,p113k_bound(value)),U32.sub(n,1),U32.inc(i),U32.add(acc,U32.add(score,value)))

@unsafe
def p155f_04_old(+n: U32) -> String:
  p155f_04_old_loop(p155f_seed(32,P154FEmpty{}),n,0,0)

@unsafe
def p155f_04_old_loop(+facts: P154Facts, +left: U32, +i: U32, +acc: U32) -> String:
  match left:
    case 0: p155f_finish(facts,32,acc)
    case n:
      +name = p155f_name(i)
      +value = p113k_bin_fact(N111U64{},"eq",p154k_get(facts,p155f_name(U32.add(i,7))),p113k_exact(U32.and(i,1),0))
      +after = p155f_publish_old(facts,name,value,0)
      p155f_04_old_loop(after,U32.sub(n,1),U32.inc(i),U32.add(acc,U32.add(p113k_bits_of(value),p155f_observed(p154p_get(after,name)))))

@unsafe
def p155f_04_new(+n: U32) -> String:
  p155f_04_new_loop(p155f_seed(32,P154FEmpty{}),n,0,0)

@unsafe
def p155f_04_new_loop(+facts: P154Facts, +left: U32, +i: U32, +acc: U32) -> String:
  match left:
    case 0: p155f_finish(facts,32,acc)
    case n:
      +name = p155f_name(i)
      +value = p113k_bin_fact(N111U64{},"eq",p154k_get(facts,p155f_name(U32.add(i,7))),p113k_exact(U32.and(i,1),0))
      +after = p155f_publish_new(facts,name,value,0)
      p155f_04_new_loop(after,U32.sub(n,1),U32.inc(i),U32.add(acc,U32.add(p113k_bits_of(value),p155f_observed(p154p_get(after,name)))))

# Supplementary exact controls only; none of these walkers is on a timed path.
@unsafe
def p155f_relation_equal(left: P154Relation, right: P154Relation) -> Bool:
  match left right:
    case P154NoRelation{} P154NoRelation{}: True{}
    case P154Relation{a,av,ae,at} P154Relation{b,bv,be,bt}:
      p154n_eq(a,b) && U32.is_eq(av,bv) && U32.is_eq(ae,be) && U32.is_eq(at,bt)
    case _ _: False{}

@unsafe
def p155f_predicate_equal(left: P154Predicate, right: P154Predicate) -> Bool:
  match left right:
    case P154NoPredicate{} P154NoPredicate{}: True{}
    case P154Predicate{a,av,ae,ai} P154Predicate{b,bv,be,bi}:
      p154n_eq(a,b) && U32.is_eq(av,bv) && U32.is_eq(ae,be) && U32.is_eq(ai,bi)
    case _ _: False{}

@unsafe
def p155f_cell_equal(left: P154FCell, right: P154FCell) -> Bool:
  match left right:
    case P154FAbsent{} P154FAbsent{}: True{}
    case P154FCell{a,ap,P113KFact{ab,ax,al,ah},av,ar,at} P154FCell{b,bp,P113KFact{bb,bx,bl,bh},bv,br,bt}:
      p154n_eq(a,b) && U32.is_eq(Bool.to_u32(ap),Bool.to_u32(bp)) &&
        U32.is_eq(ab,bb) && U32.is_eq(Bool.to_u32(ax),Bool.to_u32(bx)) &&
        U32.is_eq(al,bl) && U32.is_eq(ah,bh) && U32.is_eq(av,bv) &&
        p155f_relation_equal(ar,br) && p155f_predicate_equal(at,bt)
    case _ _: False{}

@unsafe
def p155f_cells_equal(left: List<&2,P154FCell>, right: List<&2,P154FCell>) -> Bool:
  match left right:
    case Nil{} Nil{}: True{}
    case Con{a,ar} Con{b,br}: p155f_cell_equal(a,b) && p155f_cells_equal(ar,br)
    case _ _: False{}

@unsafe
def p155f_table_equal(left: P154Facts, right: P154Facts) -> Bool:
  match left right:
    case P154FEmpty{} P154FEmpty{}: True{}
    case P154FLeaf{ah,ac} P154FLeaf{bh,bc}: U32.is_eq(ah,bh) && p155f_cells_equal(ac,bc)
    case P154FNode{ap,am,al,ar} P154FNode{bp,bm,bl,br}:
      U32.is_eq(ap,bp) && U32.is_eq(am,bm) && p155f_table_equal(al,bl) && p155f_table_equal(ar,br)
    case _ _: False{}

@unsafe
def p155f_query_equal(+facts: P154Facts, +name: P154Name) -> Bool:
  U32.is_eq(p155f_bits(facts,name),p113k_bits_of(p154k_get(facts,name))) &&
    U32.is_eq(p155f_combined(facts,name),p155f_combine(p113k_bits_of(p154k_get(facts,name)),p154l_version(facts,name)))

@unsafe
def p155f_queries_equal(+facts: P154Facts, +left: U32) -> Bool:
  match left:
    case 0:
      p155f_query_equal(facts,P154Binder{17}) &&
        p155f_query_equal(facts,P154Named{"phase155_absent"})
    case _:
      p155f_query_equal(facts,p155f_name(U32.sub(left,1))) &&
        p155f_queries_equal(facts,U32.sub(left,1))

@unsafe
def p155f_controls_go(+facts: P154Facts, +left: U32, +i: U32) -> Bool:
  match left:
    case 0: p155f_queries_equal(facts,32)
    case n:
      p155f_controls_step(facts,n,i,p155f_name(i),
        p113k_bin_fact(N111U64{},"eq",p154k_get(facts,p155f_name(U32.add(i,7))),p113k_exact(U32.and(i,1),0)))

@unsafe
def p155f_controls_step(+facts: P154Facts, left: U32, +i: U32, +name: P154Name, +value: P113KFact) -> Bool:
  +ordinary = p154k_put(facts,name,value)
  +hashed = p155f_put_hash(facts,name,p154n_hash(name),value)
  +published = p155f_publish_old(facts,name,value,0)
  +batched = p155f_publish_new(facts,name,value,0)
  p155f_query_equal(facts,name) && p155f_table_equal(ordinary,hashed) &&
    p155f_table_equal(published,batched) &&
    p155f_controls_go(published,U32.sub(left,1),U32.inc(i))

@unsafe
def p155f_controls(+n: U32) -> String:
  p155f_controls_result(p155f_controls_go(p155f_seed(32,P154FEmpty{}),n,0))

@unsafe
def p155f_controls_result(ok: Bool) -> String:
  match ok:
    case True{}: "ok"
    case False{}: "mismatch"

