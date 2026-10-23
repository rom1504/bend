import Base
import ./production.bend as P
import ./reference.bend as R
import ./absent-production.bend as A
import ./merge-production-v01.bend as M
import ./aligned-production.bend as V
import ./compare-laws.bend as C

law merge_same_key:
  for -less: Unit -> List<&2,A.P131UEntry>
  for -equal: Unit -> List<&2,A.P131UEntry>
  for -greater: Unit -> List<&2,A.P131UEntry>
  for +key: U32
  {M.p131u_merge_choose(less,equal,greater,U32.cmp(key,key)) == equal(Unit{}) : List<&2,A.P131UEntry>}

def merge_same_key(less,equal,greater,key):
  %C.u32_compare_reflexive(key) : {M.p131u_merge_choose(less,equal,greater,U32.cmp(key,key)) == M.p131u_merge_choose(less,equal,greater,_) : List<&2,A.P131UEntry>}
  {==}

# Complete output equality, for arbitrary key sequences and U32 count fields.
# Sortedness and count bounds are unnecessary for this aligned-domain case.
law aligned_merge_exact:
  for +entries: List<&2,V.P131UAligned>
  for +kind: R.P131Mode
  {M.p131u_merge(V.left(entries),V.right(entries),R.mode(kind)) == V.combine(entries,R.mode(kind)) : List<&2,A.P131UEntry>}

def aligned_merge_exact(entries,kind):
  match entries:
    case Nil{}:
      match kind:
        case R.P131Sequence{}: {==}
        case R.P131Branch{}: {==}
        case R.P131Pattern{}: {==}
    case Con{V.P131UAligned{+key,+ll,+lh,+rl,+rh},+rest}:
      %aligned_merge_exact(rest,kind) : {M.p131u_merge(Con{A.P131UEntry{key,ll,lh},V.left(rest)},Con{A.P131UEntry{key,rl,rh},V.right(rest)},R.mode(kind)) == Con{A.P131UEntry{key,P.p131a_low(R.mode(kind),ll,rl),P.p131a_high(R.mode(kind),lh,rh)},_} : List<&2,A.P131UEntry>}
      merge_same_key(
        u => Con{A.P131UEntry{key,P.p131a_low(R.mode(kind),ll,0),P.p131a_high(R.mode(kind),lh,0)},M.p131u_merge(V.left(rest),Con{A.P131UEntry{key,rl,rh},V.right(rest)},R.mode(kind))},
        u => Con{A.P131UEntry{key,P.p131a_low(R.mode(kind),ll,rl),P.p131a_high(R.mode(kind),lh,rh)},M.p131u_merge(V.left(rest),V.right(rest),R.mode(kind))},
        u => Con{A.P131UEntry{key,P.p131a_low(R.mode(kind),0,rl),P.p131a_high(R.mode(kind),0,rh)},M.p131u_merge(Con{A.P131UEntry{key,ll,lh},V.left(rest)},V.right(rest),R.mode(kind))},
        key)

#|ALL PROOFS CHECK
#|Use --verdict for mathematical validity.
