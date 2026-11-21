# Both callers supply a distinct, encounter-ordered name list from X181ReadCounts.
@unsafe
def x203_prefix(rows: List<&2,X181RegisterChoice>, +limit: U32) -> List<&2,X181RegisterChoice>:
  match rows:
    case Nil{}: []
    case Con{head,rest}: nt_choose(List<&2,X181RegisterChoice>,U32.is_eq(limit,0),
      u => [],u => Con{head,x203_prefix(rest,U32.sub(limit,1))})

@unsafe
def x203_insert(rows: List<&2,X181RegisterChoice>, +name: String, +score: U32,
    +limit: U32) -> List<&2,X181RegisterChoice>:
  match rows:
    case Nil{}: nt_choose(List<&2,X181RegisterChoice>,U32.is_eq(limit,0),u => [],u => [X181RegisterChoice{name,score}])
    case Con{X181RegisterChoice{old,+oldScore},+rest}:
      nt_choose(List<&2,X181RegisterChoice>,U32.is_eq(limit,0),u => [],u =>
        nt_choose(List<&2,X181RegisterChoice>,U32.is_gt(score,oldScore),
          v => Con{X181RegisterChoice{name,score},x203_prefix(rows,U32.sub(limit,1))},
          v => Con{X181RegisterChoice{old,oldScore},x203_insert(rest,name,score,U32.sub(limit,1))}))

@unsafe
def x203_rank(names: List<&2,String>, +counts: KDef, +slots: KDef,
    +ranked: List<&2,X181RegisterChoice>) -> List<&2,X181RegisterChoice>:
  match names:
    case Nil{}: ranked
    case Con{+name,rest}:
      +hash = index_hash(name,2166136261)
      +score = da(index_find(counts,name,hash,32))
      x203_rank(rest,counts,slots,nt_choose(List<&2,X181RegisterChoice>,U32.is_gt(score,0),
        u => nt_choose(List<&2,X181RegisterChoice>,String.eq(dk(index_find(slots,name,hash,32)),"X181Stack"),
          v => x203_insert(ranked,name,score,32),v => ranked),u => ranked))

@unsafe
def x203_choices(rows: List<&2,X181RegisterChoice>, +bit: U32, ids: KDef,
    reversed: List<&2,String>) -> X190LCandidates:
  match rows:
    case Nil{}: X190LCandidates{nt_reverse(String,reversed,[]),ids}
    case Con{X181RegisterChoice{+name,score},rest}:
      x203_choices(rest,U32.shl(bit),p111v_put(ids,name,"X190LBit",bit,0),Con{name,reversed})

@unsafe
def x203_candidates(names: List<&2,String>, counts: KDef, slots: KDef) -> X190LCandidates:
  x203_choices(x203_rank(names,counts,slots,[]),1,missing(),[])
