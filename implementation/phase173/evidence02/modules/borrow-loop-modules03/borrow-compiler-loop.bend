# Driver only. prepare-workload.py retains the exact canonical KTerm and
# k_with_span declarations; the candidate has no knowledge of these names.
# Return the whole final term and the original shared alias, including every
# child, note, string, quantity and span field. Existing kind=compiler oracle
# transport observes this complete P173BWReport through the upstream compiler.
type P173BWReport is Data:
  P173BWReport{+located: List<&2,KTerm>, +shared: List<&2,GResult>, +replaced: KTerm}

@unsafe
def p173bwl_children(n: Nat, +value: U32) -> List<&2,KTerm>:
  match n:
    case 0n: []
    case 1n+p:
      Con{KLiteral{"U32",value,U32.show(value),3,8},
        p173bwl_children(p,U32.inc(value))}

def p173bwl_make() -> KTerm:
  KTerm{"Ctr",U32.show(7),17,2,p173bwl_children(7n,1),
    ["retain-root-note","retain-second-note"],3,8}

# The first update observes a shared root and must preserve the retained alias.
# Its owned result is handed directly to the next update. No root escapes until
# return; recursive calls are tail calls, preserving bounded native stack use.
@unsafe
def p173bwl_update(n: Nat, term: KTerm, +begin: U32) -> KTerm:
  match n:
    case 0n: term
    case 1n+p:
      p173bwl_update(p,k_with_span(term,begin,U32.inc(begin)),U32.inc(begin))

def p173bwl_result() -> P173BWReport:
  +original = p173bwl_make()
  P173BWReport{[p173bwl_update(2000000n,original,1),original],[],
    KLiteral{"U32",2000000,"iteration-count",0,0}}
