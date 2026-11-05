# Complete-operation workload, not an insertion-only inner-loop timer.
# Requires index-zipper.bend and Phase163 direct-runtime.bend's all-field digest.
# Mode 0 uses the actual name hash. Mode 1 masks it to 256 buckets (about 16
# records/bucket at 4096 keys). Every round builds, overwrites and consumes a
# fresh bounded map; no map or key count accumulates across rounds.
@unsafe
def p164xw_apply(+tree: KDef, +record: KDef, +hash: U32, new: Bool) -> KDef:
  nt_choose(KDef,new,u => p164x_insert(tree,record,hash),u => p131i_insert(tree,record,hash))

@unsafe
def p164xw_hash(+name: String, mode: U32) -> U32:
  +hash = index_hash(name,2166136261)
  nt_choose(U32,U32.is_eq(mode,1),u => U32.and(hash,255),u => hash)

@unsafe
def p164xw_record(name: String, +version: U32, +key: U32) -> KDef:
  KDef{name,"P164Fact",32,1,kt("Epoch","",version,0,[]),
    kt("Value","",U32.xor(U32.mul(key,2654435761),version),key,[]),[],False{},False{}}

@unsafe
def p164xw_update(tree: KDef, +key: U32, version: U32, mode: U32, new: Bool) -> KDef:
  +name = "fact." ++ U32.show(key)
  p164xw_apply(tree,p164xw_record(name,version,key),p164xw_hash(name,mode),new)

@unsafe
def p164xw_build(+tree: KDef, +at: U32, +keys: U32, +version: U32, +mode: U32, +new: Bool) -> KDef:
  nt_choose(KDef,U32.is_eq(at,keys),u => tree,u =>
    p164xw_build(p164xw_update(tree,at,version,mode,new),U32.inc(at),keys,version,mode,new))

# Reverse-key overwrite changes every value/epoch without growing the key set.
@unsafe
def p164xw_overwrite(+tree: KDef, +left: U32, +version: U32, +mode: U32, +new: Bool) -> KDef:
  nt_choose(KDef,U32.is_eq(left,0),u => tree,u =>
    p164xw_overwrite(p164xw_update(tree,U32.sub(left,1),version,mode,new),U32.sub(left,1),version,mode,new))

@unsafe
def p164xw_map(keys: U32, +mode: U32, +epoch: U32, +new: Bool) -> KDef:
  +bounded = U32.min(keys,65536)
  p164xw_overwrite(p164xw_build(missing(),0,bounded,U32.mul(epoch,2),mode,new),
    bounded,U32.inc(U32.mul(epoch,2)),mode,new)

def p164xw_digest_words(words: List<&2,U32>, h: U32) -> U32:
  match words:
    case Nil{}: h
    case Con{word,rest}: p164xw_digest_words(rest,p163r_mix(h,word))

@unsafe
def p164xw_rounds(+keys: U32, +left: U32, +epoch: U32, +mode: U32, +new: Bool, +h: U32) -> U32:
  nt_choose(U32,U32.is_eq(left,0),u => h,u =>
    p164xw_rounds(keys,U32.sub(left,1),U32.inc(epoch),mode,new,
      p164xw_digest_words(p163r_digest([p164xw_map(keys,mode,epoch,new)]),p163r_mix(h,epoch))))

@unsafe
def p164xw_run(keys: U32, rounds: U32, mode: U32, new: Bool) -> U32:
  p164xw_rounds(U32.min(keys,65536),rounds,0,mode,new,2166136261)
