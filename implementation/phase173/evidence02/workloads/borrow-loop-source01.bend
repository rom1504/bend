import Base



# Generated source assembly. Edit the individual src modules.

# Module: src/core/term.bend:25
type KTerm is Data:
  KTerm{+tag: String, +name: String, +id: U32, +quant: U32, +kids: List<&2, KTerm>, +removed: List<&2, String>, +originBegin: U32, +originEnd: U32}
  KLambda{+name: String, +id: U32, +quant: U32, +kids: List<&2,KTerm>, +removed: List<&2,String>, +originBegin: U32, +originEnd: U32, +quantityPresent: Bool}
  KLiteral{+kind: String, +number: U32, +text: String, +originBegin: U32, +originEnd: U32}



# Module: src/core/graph.bend:6
type GHeap is Data:
  GEmpty{}
  GNode{+value: KTerm, +left: GHeap, +right: GHeap}



# Module: src/core/graph.bend:10
type GState is Data:
  GState{+heap: GHeap, +next: U32}



# Module: src/core/graph.bend:13
type GResult is Data:
  GResult{+state: GState, +term: KTerm}



# Module: src/core/term.bend:594
@unsafe
def k_with_span(+t: KTerm, +newBegin: U32, +newEnd: U32) -> KTerm:
  match t:
    case KTerm{tag, name, id, quant, kids, removed, oldBegin, oldEnd}:
      KTerm{tag, name, id, quant, kids, removed, newBegin, newEnd}
    case KLambda{name, id, quant, kids, removed, begin, end, present}:
      KLambda{name, id, quant, kids, removed, newBegin, newEnd, present}
    case KLiteral{kind, number, text, literalBegin, literalEnd}:
      KLiteral{kind, number, text, newBegin, newEnd}


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
  P173BWReport{[p173bwl_update(500000n,original,1),original],[],
    KLiteral{"U32",500000,"iteration-count",0,0}}


def main() -> P173BWReport:
  p173bwl_result()
