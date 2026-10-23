import Base
import ./production.bend as P
import ./reference.bend as R
import ./absent-production.bend as A
import ./merge-production-v01.bend as M
import ./lookup-production-v02.bend as L
import ./aligned-production.bend as V
import ./aligned-merge-laws.bend as T

law high_choose:
  for +kind: R.P131Mode
  for +a: U32
  for +b: U32
  for -left: Unit -> U32
  for -right: Unit -> U32
  for +order: Cmp
  {L.p131u_choose(P.p131a_high(R.mode(kind),a,b),u => P.p131a_high(R.mode(kind),left(Unit{}),right(Unit{})),order) == P.p131a_high(R.mode(kind),L.p131u_choose(a,left,order),L.p131u_choose(b,right,order)) : U32}

def high_choose(kind,a,b,left,right,order):
  match kind order:
    case R.P131Sequence{} LT{}: {==}
    case R.P131Sequence{} EQ{}: {==}
    case R.P131Sequence{} GT{}: {==}
    case R.P131Branch{} LT{}: {==}
    case R.P131Branch{} EQ{}: {==}
    case R.P131Branch{} GT{}: {==}
    case R.P131Pattern{} LT{}: {==}
    case R.P131Pattern{} EQ{}: {==}
    case R.P131Pattern{} GT{}: {==}

law low_choose:
  for +kind: R.P131Mode
  for +a: U32
  for +b: U32
  for -left: Unit -> U32
  for -right: Unit -> U32
  for +order: Cmp
  {L.p131u_choose(P.p131a_low(R.mode(kind),a,b),u => P.p131a_low(R.mode(kind),left(Unit{}),right(Unit{})),order) == P.p131a_low(R.mode(kind),L.p131u_choose(a,left,order),L.p131u_choose(b,right,order)) : U32}

def low_choose(kind,a,b,left,right,order):
  match kind order:
    case R.P131Sequence{} LT{}: {==}
    case R.P131Sequence{} EQ{}: {==}
    case R.P131Sequence{} GT{}: {==}
    case R.P131Branch{} LT{}: {==}
    case R.P131Branch{} EQ{}: {==}
    case R.P131Branch{} GT{}: {==}
    case R.P131Pattern{} LT{}: {==}
    case R.P131Pattern{} EQ{}: {==}
    case R.P131Pattern{} GT{}: {==}

law aligned_maximum:
  for +entries: List<&2,V.P131UAligned>
  for +kind: R.P131Mode
  for +id: U32
  {L.p131u_max(V.combine(entries,R.mode(kind)),id) == P.p131a_high(R.mode(kind),L.p131u_max(V.left(entries),id),L.p131u_max(V.right(entries),id)) : U32}

def aligned_maximum(entries,kind,id):
  match entries:
    case Nil{}:
      match kind:
        case R.P131Sequence{}: {==}
        case R.P131Branch{}: {==}
        case R.P131Pattern{}: {==}
    case Con{V.P131UAligned{+key,+ll,+lh,+rl,+rh},+rest}:
      %high_choose(kind,lh,rh,u => L.p131u_max(V.left(rest),id),u => L.p131u_max(V.right(rest),id),U32.cmp(key,id)) : {L.p131u_max(V.combine(Con{V.P131UAligned{key,ll,lh,rl,rh},rest},R.mode(kind)),id) == _ : U32}
      %aligned_maximum(rest,kind,id) : {L.p131u_choose(P.p131a_high(R.mode(kind),lh,rh),u => L.p131u_max(V.combine(rest,R.mode(kind)),id),U32.cmp(key,id)) == L.p131u_choose(P.p131a_high(R.mode(kind),lh,rh),u => _,U32.cmp(key,id)) : U32}
      {==}

law aligned_minimum:
  for +entries: List<&2,V.P131UAligned>
  for +kind: R.P131Mode
  for +id: U32
  {L.p131u_min(V.combine(entries,R.mode(kind)),id) == P.p131a_low(R.mode(kind),L.p131u_min(V.left(entries),id),L.p131u_min(V.right(entries),id)) : U32}

def aligned_minimum(entries,kind,id):
  match entries:
    case Nil{}:
      match kind:
        case R.P131Sequence{}: {==}
        case R.P131Branch{}: {==}
        case R.P131Pattern{}: {==}
    case Con{V.P131UAligned{+key,+ll,+lh,+rl,+rh},+rest}:
      %low_choose(kind,ll,rl,u => L.p131u_min(V.left(rest),id),u => L.p131u_min(V.right(rest),id),U32.cmp(key,id)) : {L.p131u_min(V.combine(Con{V.P131UAligned{key,ll,lh,rl,rh},rest},R.mode(kind)),id) == _ : U32}
      %aligned_minimum(rest,kind,id) : {L.p131u_choose(P.p131a_low(R.mode(kind),ll,rl),u => L.p131u_min(V.combine(rest,R.mode(kind)),id),U32.cmp(key,id)) == L.p131u_choose(P.p131a_low(R.mode(kind),ll,rl),u => _,U32.cmp(key,id)) : U32}
      {==}

law merged_maximum:
  for +entries: List<&2,V.P131UAligned>
  for +kind: R.P131Mode
  for +id: U32
  {L.p131u_max(M.p131u_merge(V.left(entries),V.right(entries),R.mode(kind)),id) == P.p131a_high(R.mode(kind),L.p131u_max(V.left(entries),id),L.p131u_max(V.right(entries),id)) : U32}

def merged_maximum(entries,kind,id):
  Equal.trans(U32,
    L.p131u_max(M.p131u_merge(V.left(entries),V.right(entries),R.mode(kind)),id),
    L.p131u_max(V.combine(entries,R.mode(kind)),id),
    P.p131a_high(R.mode(kind),L.p131u_max(V.left(entries),id),L.p131u_max(V.right(entries),id)),
    Equal.cong(List<&2,A.P131UEntry>,U32,values => L.p131u_max(values,id),
      M.p131u_merge(V.left(entries),V.right(entries),R.mode(kind)),V.combine(entries,R.mode(kind)),T.aligned_merge_exact(entries,kind)),
    aligned_maximum(entries,kind,id))

law merged_minimum:
  for +entries: List<&2,V.P131UAligned>
  for +kind: R.P131Mode
  for +id: U32
  {L.p131u_min(M.p131u_merge(V.left(entries),V.right(entries),R.mode(kind)),id) == P.p131a_low(R.mode(kind),L.p131u_min(V.left(entries),id),L.p131u_min(V.right(entries),id)) : U32}

def merged_minimum(entries,kind,id):
  Equal.trans(U32,
    L.p131u_min(M.p131u_merge(V.left(entries),V.right(entries),R.mode(kind)),id),
    L.p131u_min(V.combine(entries,R.mode(kind)),id),
    P.p131a_low(R.mode(kind),L.p131u_min(V.left(entries),id),L.p131u_min(V.right(entries),id)),
    Equal.cong(List<&2,A.P131UEntry>,U32,values => L.p131u_min(values,id),
      M.p131u_merge(V.left(entries),V.right(entries),R.mode(kind)),V.combine(entries,R.mode(kind)),T.aligned_merge_exact(entries,kind)),
    aligned_minimum(entries,kind,id))

#|ALL PROOFS CHECK
#|Use --verdict for mathematical validity.
