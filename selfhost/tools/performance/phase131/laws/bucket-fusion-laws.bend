import Base
import ./bucket-production.bend as P

law bucket_projection_distributes:
  for +hit: Bool
  for +head: P.KDef
  for -tail: Unit -> P.KDef
  {P.dx(P.kc(P.KDef,hit,u => head,tail)) == P.kc(U32,hit,u => P.dx(head),u => P.dx(tail(Unit{}))) : U32}

def bucket_projection_distributes(hit,head,tail):
  match hit:
    case False{}: {==}
    case True{}: {==}

# All KDef variants and all keys, including empty keys matching index nodes.
law bucket_scalar_fusion:
  for +entries: List<&2,P.KDef>
  for +key: String
  {P.dx(P.index_bucket(entries,key)) == P.p131sc_bucket(entries,key) : U32}

def bucket_scalar_fusion(entries,key):
  match entries:
    case Nil{}: {==}
    case Con{+head,+rest}:
      %bucket_scalar_fusion(rest,key) : {P.dx(P.index_bucket(Con{head,rest},key)) == P.kc(U32,P.p88_string_eq(P.dn(head),key),u => P.dx(head),u => _) : U32}
      bucket_projection_distributes(P.p88_string_eq(P.dn(head),key),head,u => P.index_bucket(rest,key))

#|ALL PROOFS CHECK
#|Use --verdict for mathematical validity.
