import Base

# Complete upstream-observed value; source SHA256 1f2b5df52aaa1c7f1291804fcd6ca4cbc0701d8cb53ff22042cb63d00c6afa71
type KTerm is Data:
  KTerm{+tag: String, +name: String, +id: U32, +quant: U32, +kids: List<&2, KTerm>, +removed: List<&2, String>, +originBegin: U32, +originEnd: U32}
  KLambda{+name: String, +id: U32, +quant: U32, +kids: List<&2,KTerm>, +removed: List<&2,String>, +originBegin: U32, +originEnd: U32, +quantityPresent: Bool}
  KLiteral{+kind: String, +number: U32, +text: String, +originBegin: U32, +originEnd: U32}

type GHeap is Data:
  GEmpty{}
  GNode{+value: KTerm, +left: GHeap, +right: GHeap}

type GState is Data:
  GState{+heap: GHeap, +next: U32}

type GResult is Data:
  GResult{+state: GState, +term: KTerm}

type P173BWReport is Data:
  P173BWReport{+located: List<&2,KTerm>, +shared: List<&2,GResult>, +replaced: KTerm}

def main() -> P173BWReport:
  P173BWReport{[KTerm{"Ctr","7",17,2,[KLiteral{"U32",1,"1",3,8},KLiteral{"U32",2,"2",3,8},KLiteral{"U32",3,"3",3,8},KLiteral{"U32",4,"4",3,8},KLiteral{"U32",5,"5",3,8},KLiteral{"U32",6,"6",3,8},KLiteral{"U32",7,"7",3,8}],["retain-root-note","retain-second-note"],500000,500001},KTerm{"Ctr","7",17,2,[KLiteral{"U32",1,"1",3,8},KLiteral{"U32",2,"2",3,8},KLiteral{"U32",3,"3",3,8},KLiteral{"U32",4,"4",3,8},KLiteral{"U32",5,"5",3,8},KLiteral{"U32",6,"6",3,8},KLiteral{"U32",7,"7",3,8}],["retain-root-note","retain-second-note"],3,8}],[],KLiteral{"U32",500000,"iteration-count",0,0}}
