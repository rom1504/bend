# Exact query walkers versus summary preparation plus all lookups. This bounded
# proxy isolates the query algebra; real ns/nh and whole-request gates are separate.
@unsafe
def p131k_terms(count: Nat, +id: U32, +mode: U32) -> List<&2,KTerm>:
  match count:
    case 0n: []
    case 1n+rest: Con{p131k_term(id,mode),p131k_terms(rest,U32.inc(id),mode)}

@unsafe
def p131k_term(+id: U32, mode: U32) -> KTerm:
  match mode:
    case 0: var("",id)
    case 1: kt("Mat","",0,0,[var("",id),var("",id)])
    case other: kt("NWPattern","",0,0,[kt("Row","",0,0,[var("",id)]),kt("Row","",0,0,[var("",id)])])

@unsafe
def p131k_original(+term: KTerm, count: Nat, +id: U32, hash: U32) -> U32:
  match count:
    case 0n: hash
    case 1n+rest: p131k_original(term,rest,U32.inc(id),U32.add(U32.mul(hash,17),U32.add(U32.mul(nq_uses(term,id),3),nq_min_uses(term,id))))

@unsafe
def p131k_summary(+entries: List<&2,P131UEntry>, count: Nat, +id: U32, hash: U32) -> U32:
  match count:
    case 0n: hash
    case 1n+rest: p131k_summary(entries,rest,U32.inc(id),U32.add(U32.mul(hash,17),U32.add(U32.mul(p131u_max(entries,id),3),p131u_min(entries,id))))

# The extractor substitutes only this declaration for the summary variant.
@unsafe
def p131k_query(term: KTerm, count: Nat) -> U32:
  p131k_original(term,count,0,0)

@unsafe
def p131k_repeat(iterations: Nat, +term: KTerm, +count: Nat, hash: U32) -> U32:
  match iterations:
    case 0n: hash
    case 1n+rest: p131k_repeat(rest,term,count,U32.add(hash,p131k_query(term,count)))

@unsafe
def p131k_case(mode: U32) -> U32:
  p131k_repeat(100n,kt("Seq","",0,0,p131k_terms(64n,0,mode)),64n,0)

@unsafe
def main() -> IO<Unit>:
  do IO:
    IO.print(U32.show(p131k_case(0)))
    IO.print(U32.show(p131k_case(1)))
    IO.print(U32.show(p131k_case(2)))
    return Unit{}
