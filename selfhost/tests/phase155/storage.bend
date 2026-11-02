# Phase155 storage screens. Both roles produce their representation directly.
# Array-bearing wrappers are consumed immediately; no shared Type wrapper.
# Every read/update and the complete final ordered mapping affect the String.

@unsafe
def p155s_take(pair: Array<U32> & U32) -> U32:
  match pair:
    case Tuple{rest,value}: value

@unsafe
def p155s_get(+data: Array<U32>, at: U32) -> U32:
  p155s_take(Array.get(U32,data,at))

@unsafe
def p155s_set3(data: Array<U32>, +at: U32, lo: U32, hi: U32, version: U32) -> Array<U32>:
  Array.set(U32,Array.set(U32,Array.set(U32,data,at,lo),U32.inc(at),hi),U32.add(at,2),version)

@unsafe
def p155s_set4(data: Array<U32>, +at: U32, key: U32, lo: U32, hi: U32, version: U32) -> Array<U32>:
  p155s_set3(Array.set(U32,data,at,key),U32.inc(at),lo,hi,version)

@unsafe
def p155s_mix(key: U32, lo: U32, hi: U32, version: U32) -> U32:
  U32.xor(U32.add(U32.mul(key,31),lo),U32.add(U32.mul(hi,17),U32.mul(version,257)))

@unsafe
def p155s_roll(acc: U32, seen: U32) -> U32:
  U32.xor(U32.mul(acc,16777619),seen)

@unsafe
def p155s_row(key: U32, lo: U32, hi: U32, version: U32) -> String:
  U32.show(key) ++ ":" ++ U32.show(lo) ++ ":" ++ U32.show(hi) ++ ":" ++ U32.show(version) ++ ";"

@unsafe
def p155s_put(tree: P154Facts, +key: U32, lo: U32, hi: U32, version: U32) -> P154Facts:
  p154f_put(tree,P154Binder{key},P154FCell{P154Binder{key},True{},P113KFact{64,True{},lo,hi},version,P154NoRelation{},P154NoPredicate{}})

@unsafe
def p155s_cell_mix(+key: U32, cell: P154FCell) -> U32:
  match cell:
    case P154FCell{name,present,P113KFact{bits,exact,lo,hi},version,relation,predicate}: p155s_mix(key,lo,hi,version)
    case _: 0

@unsafe
def p155s_cell_row(+key: U32, cell: P154FCell) -> String:
  match cell:
    case P154FCell{name,present,P113KFact{bits,exact,lo,hi},version,relation,predicate}: p155s_row(key,lo,hi,version)
    case _: U32.show(key) ++ ":-;"

@unsafe
def p155s_initial_lo(n: U32, key: U32) -> U32:
  U32.add(U32.add(n,U32.mul(key,3)),1)

@unsafe
def p155s_initial_hi(n: U32, key: U32) -> U32:
  U32.xor(n,U32.mul(key,65537))

# 19: fixed dense identity domain, three scalar fields per present fact.
@unsafe
def p155s_dense_old_build(+n: U32, +at: U32, +tree: P154Facts) -> P154Facts:
  nt_choose(P154Facts,U32.is_eq(at,64),u => tree,u =>
    p155s_dense_old_build(n,U32.inc(at),p155s_put(tree,at,p155s_initial_lo(n,at),p155s_initial_hi(n,at),1)))

@unsafe
def p155s_dense_new_build(+n: U32, +at: U32, +data: Array<U32>) -> Array<U32>:
  nt_choose(Array<U32>,U32.is_eq(at,64),u => data,u =>
    p155s_dense_new_build(n,U32.inc(at),p155s_set3(data,U32.mul(at,3),p155s_initial_lo(n,at),p155s_initial_hi(n,at),1)))

@unsafe
def p155s_dense_old_text(+tree: P154Facts, +at: U32) -> String:
  nt_choose(String,U32.is_eq(at,64),u => "",u =>
    p155s_cell_row(at,p154f_get(tree,P154Binder{at})) ++ p155s_dense_old_text(tree,U32.inc(at)))

@unsafe
def p155s_dense_new_text(+data: Array<U32>, +at: U32) -> String:
  nt_choose(String,U32.is_eq(at,64),u => "",u =>
    p155s_row(at,p155s_get(data,U32.mul(at,3)),p155s_get(data,U32.inc(U32.mul(at,3))),p155s_get(data,U32.add(U32.mul(at,3),2))) ++ p155s_dense_new_text(data,U32.inc(at)))

@unsafe
def p155s_dense_old_step(+n: U32, +step: U32, +key: U32, +seen: U32, tree: P154Facts, acc: U32) -> String:
  p155s_dense_old_loop(n,U32.inc(step),p155s_put(tree,key,U32.add(seen,U32.add(step,11)),U32.xor(seen,U32.add(n,key)),U32.add(step,2)),p155s_roll(acc,seen))

@unsafe
def p155s_dense_old_observe(+n: U32, +step: U32, +key: U32, +tree: P154Facts, acc: U32) -> String:
  p155s_dense_old_step(n,step,key,p155s_cell_mix(key,p154f_get(tree,P154Binder{key})),tree,acc)

@unsafe
def p155s_dense_old_loop(+n: U32, +step: U32, +tree: P154Facts, +acc: U32) -> String:
  nt_choose(String,U32.is_eq(step,n),u => U32.show(acc) ++ "|" ++ p155s_dense_old_text(tree,0),u =>
    p155s_dense_old_observe(n,step,U32.and(U32.add(U32.mul(step,17),n),63),tree,acc))

@unsafe
def p155s_dense_new_step(+n: U32, +step: U32, +key: U32, +seen: U32, data: Array<U32>, acc: U32) -> String:
  p155s_dense_new_loop(n,U32.inc(step),p155s_set3(data,U32.mul(key,3),U32.add(seen,U32.add(step,11)),U32.xor(seen,U32.add(n,key)),U32.add(step,2)),p155s_roll(acc,seen))

@unsafe
def p155s_dense_new_observe(+n: U32, +step: U32, +key: U32, +data: Array<U32>, acc: U32) -> String:
  p155s_dense_new_step(n,step,key,p155s_mix(key,p155s_get(data,U32.mul(key,3)),p155s_get(data,U32.inc(U32.mul(key,3))),p155s_get(data,U32.add(U32.mul(key,3),2))),data,acc)

@unsafe
def p155s_dense_new_loop(+n: U32, +step: U32, +data: Array<U32>, +acc: U32) -> String:
  nt_choose(String,U32.is_eq(step,n),u => U32.show(acc) ++ "|" ++ p155s_dense_new_text(data,0),u =>
    p155s_dense_new_observe(n,step,U32.and(U32.add(U32.mul(step,17),n),63),data,acc))

@unsafe
def p155s_dense_old(+n: U32) -> String:
  p155s_dense_old_loop(n,0,p155s_dense_old_build(n,0,P154FEmpty{}),2166136261)

@unsafe
def p155s_dense_new(+n: U32) -> String:
  p155s_dense_new_loop(n,0,p155s_dense_new_build(n,0,Array.new(U32,8n,0)),2166136261)

# 20: sparse full-width keys; each fresh sorted batch is shared input work.
# Initial 32 even identities; eight sorted updates replace and insert keys.
# Candidate merges into a fresh contiguous buffer, paying allocation/destruction.
@unsafe
def p155s_sparse_key(ordinal: U32) -> U32:
  U32.add(1000003,U32.mul(ordinal,65537))

@unsafe
def p155s_sparse_old_build(+n: U32, +at: U32, +tree: P154Facts) -> P154Facts:
  nt_choose(P154Facts,U32.is_eq(at,32),u => tree,u =>
    p155s_sparse_old_build(n,U32.inc(at),p155s_put(tree,p155s_sparse_key(U32.mul(at,2)),p155s_initial_lo(n,p155s_sparse_key(U32.mul(at,2))),p155s_initial_hi(n,p155s_sparse_key(U32.mul(at,2))),1)))

@unsafe
def p155s_sparse_new_build(+n: U32, +at: U32, +data: Array<U32>) -> Array<U32>:
  nt_choose(Array<U32>,U32.is_eq(at,32),u => data,u =>
    p155s_sparse_new_build(n,U32.inc(at),p155s_set4(data,U32.mul(at,4),p155s_sparse_key(U32.mul(at,2)),p155s_initial_lo(n,p155s_sparse_key(U32.mul(at,2))),p155s_initial_hi(n,p155s_sparse_key(U32.mul(at,2))),1)))

@unsafe
def p155s_batch(+n: U32, +step: U32, +seen: U32, +at: U32, +data: Array<U32>) -> Array<U32>:
  nt_choose(Array<U32>,U32.is_eq(at,8),u => data,u =>
    p155s_batch_row(n,step,seen,at,p155s_sparse_key(U32.add(U32.mul(at,8),U32.and(step,7))),data))

@unsafe
def p155s_batch_row(+n: U32, +step: U32, +seen: U32, +at: U32, +key: U32, data: Array<U32>) -> Array<U32>:
  p155s_batch(n,step,seen,U32.inc(at),p155s_set4(data,U32.mul(at,4),key,U32.add(seen,U32.add(step,key)),U32.xor(seen,U32.add(n,key)),U32.add(step,2)))

@unsafe
def p155s_batch_tree(+batch: Array<U32>, +at: U32, +tree: P154Facts) -> P154Facts:
  nt_choose(P154Facts,U32.is_eq(at,8),u => tree,u =>
    p155s_batch_tree(batch,U32.inc(at),p155s_put(tree,p155s_get(batch,U32.mul(at,4)),p155s_get(batch,U32.add(U32.mul(at,4),1)),p155s_get(batch,U32.add(U32.mul(at,4),2)),p155s_get(batch,U32.add(U32.mul(at,4),3)))))

@unsafe
def p155s_copy4(+source: Array<U32>, +at: U32, out: Array<U32>, to: U32) -> Array<U32>:
  p155s_set4(out,to,p155s_get(source,at),p155s_get(source,U32.add(at,1)),p155s_get(source,U32.add(at,2)),p155s_get(source,U32.add(at,3)))

@unsafe
def p155s_merge(+data: Array<U32>, +used: U32, +batch: Array<U32>, +i: U32, +j: U32, +count: U32, +out: Array<U32>) -> Array<U32> & U32:
  nt_choose(Array<U32> & U32,U32.is_eq(j,8),u =>
    nt_choose(Array<U32> & U32,U32.is_eq(i,used),v => Tuple{out,count},v =>
      p155s_merge(data,used,batch,U32.inc(i),j,U32.inc(count),p155s_copy4(data,U32.mul(i,4),out,U32.mul(count,4)))),u =>
    nt_choose(Array<U32> & U32,U32.is_eq(i,used),v =>
      p155s_merge(data,used,batch,i,U32.inc(j),U32.inc(count),p155s_copy4(batch,U32.mul(j,4),out,U32.mul(count,4))),v =>
      p155s_merge_keys(data,used,batch,i,j,count,out,p155s_get(data,U32.mul(i,4)),p155s_get(batch,U32.mul(j,4)))))

@unsafe
def p155s_merge_keys(+data: Array<U32>, +used: U32, +batch: Array<U32>, +i: U32, +j: U32, +count: U32, +out: Array<U32>, +left: U32, +right: U32) -> Array<U32> & U32:
  nt_choose(Array<U32> & U32,U32.is_lt(left,right),u =>
    p155s_merge(data,used,batch,U32.inc(i),j,U32.inc(count),p155s_copy4(data,U32.mul(i,4),out,U32.mul(count,4))),u =>
    p155s_merge(data,used,batch,U32.add(i,Bool.to_u32(U32.is_eq(left,right))),U32.inc(j),U32.inc(count),p155s_copy4(batch,U32.mul(j,4),out,U32.mul(count,4))))

# Binary search returns a record index or the sentinel64. Half-open bounds.
@unsafe
def p155s_find(+data: Array<U32>, +key: U32, +lo: U32, +hi: U32) -> U32:
  nt_choose(U32,U32.is_ge(lo,hi),u => 64,u => p155s_find_mid(data,key,lo,hi,U32.shr(U32.add(lo,hi))))

@unsafe
def p155s_find_mid(+data: Array<U32>, +key: U32, +lo: U32, +hi: U32, +mid: U32) -> U32:
  p155s_find_key(data,key,lo,hi,mid,p155s_get(data,U32.mul(mid,4)))

@unsafe
def p155s_find_key(+data: Array<U32>, +key: U32, +lo: U32, +hi: U32, +mid: U32, +stored: U32) -> U32:
  nt_choose(U32,U32.is_eq(key,stored),u => mid,u =>
    nt_choose(U32,U32.is_lt(key,stored),v => p155s_find(data,key,lo,mid),v => p155s_find(data,key,U32.inc(mid),hi)))

@unsafe
def p155s_sparse_mix(+data: Array<U32>, +key: U32, +at: U32) -> U32:
  nt_choose(U32,U32.is_eq(at,64),u => 0,u =>
    p155s_mix(key,p155s_get(data,U32.add(U32.mul(at,4),1)),p155s_get(data,U32.add(U32.mul(at,4),2)),p155s_get(data,U32.add(U32.mul(at,4),3))))

@unsafe
def p155s_sparse_row(+data: Array<U32>, +key: U32, +at: U32) -> String:
  nt_choose(String,U32.is_eq(at,64),u => U32.show(key) ++ ":-;",u =>
    p155s_row(key,p155s_get(data,U32.add(U32.mul(at,4),1)),p155s_get(data,U32.add(U32.mul(at,4),2)),p155s_get(data,U32.add(U32.mul(at,4),3))))

@unsafe
def p155s_sparse_old_text(+tree: P154Facts, +at: U32) -> String:
  nt_choose(String,U32.is_eq(at,64),u => "",u =>
    p155s_cell_row(p155s_sparse_key(at),p154f_get(tree,P154Binder{p155s_sparse_key(at)})) ++ p155s_sparse_old_text(tree,U32.inc(at)))

@unsafe
def p155s_sparse_new_text(+data: Array<U32>, +used: U32, +at: U32) -> String:
  nt_choose(String,U32.is_eq(at,64),u => "",u =>
    p155s_sparse_row(data,p155s_sparse_key(at),p155s_find(data,p155s_sparse_key(at),0,used)) ++ p155s_sparse_new_text(data,used,U32.inc(at)))

@unsafe
def p155s_sparse_old_seen(+n: U32, +step: U32, +seen: U32, tree: P154Facts, acc: U32) -> String:
  p155s_sparse_old_loop(n,U32.inc(step),p155s_batch_tree(p155s_batch(n,step,seen,0,Array.new(U32,5n,0)),0,tree),p155s_roll(acc,seen))

@unsafe
def p155s_sparse_old_observe(+n: U32, +step: U32, +key: U32, +tree: P154Facts, acc: U32) -> String:
  p155s_sparse_old_seen(n,step,p155s_cell_mix(key,p154f_get(tree,P154Binder{key})),tree,acc)

@unsafe
def p155s_sparse_old_loop(+n: U32, +step: U32, +tree: P154Facts, +acc: U32) -> String:
  nt_choose(String,U32.is_eq(step,n),u => U32.show(acc) ++ "|" ++ p155s_sparse_old_text(tree,0),u =>
    p155s_sparse_old_observe(n,step,p155s_sparse_key(U32.and(U32.add(U32.mul(step,13),n),63)),tree,acc))

@unsafe
def p155s_sparse_new_merged(+n: U32, step: U32, acc: U32, result: Array<U32> & U32) -> String:
  match result:
    case Tuple{data,used}: p155s_sparse_new_loop(n,step,data,used,acc)

@unsafe
def p155s_sparse_new_seen(+n: U32, +step: U32, +seen: U32, data: Array<U32>, used: U32, acc: U32) -> String:
  p155s_sparse_new_merged(n,U32.inc(step),p155s_roll(acc,seen),p155s_merge(data,used,p155s_batch(n,step,seen,0,Array.new(U32,5n,0)),0,0,0,Array.new(U32,8n,0)))

@unsafe
def p155s_sparse_new_observe(+n: U32, +step: U32, +key: U32, +data: Array<U32>, +used: U32, acc: U32) -> String:
  p155s_sparse_new_seen(n,step,p155s_sparse_mix(data,key,p155s_find(data,key,0,used)),data,used,acc)

@unsafe
def p155s_sparse_new_loop(+n: U32, +step: U32, +data: Array<U32>, +used: U32, +acc: U32) -> String:
  nt_choose(String,U32.is_eq(step,n),u => U32.show(acc) ++ "|" ++ p155s_sparse_new_text(data,used,0),u =>
    p155s_sparse_new_observe(n,step,p155s_sparse_key(U32.and(U32.add(U32.mul(step,13),n),63)),data,used,acc))

@unsafe
def p155s_sparse_old(+n: U32) -> String:
  p155s_sparse_old_loop(n,0,p155s_sparse_old_build(n,0,P154FEmpty{}),2166136261)

@unsafe
def p155s_sparse_new(+n: U32) -> String:
  p155s_sparse_new_loop(n,0,p155s_sparse_new_build(n,0,Array.new(U32,8n,0)),32,2166136261)
