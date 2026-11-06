import Base

# Unrelated ordinary selector. Complete expected result: ["left","right","", "left"].
type P171Entry is Data:
  P171Entry{+key: String, +payload: String}

def p171_choose(-A: Type, value: Bool, yes: Unit -> A, no: Unit -> A) -> A:
  match value:
    case True{}: yes(Unit{})
    case False{}: no(Unit{})

def p171_key(entry: P171Entry) -> String:
  match entry:
    case P171Entry{key,payload}: key

def p171_payload(entry: P171Entry) -> String:
  match entry:
    case P171Entry{key,payload}: payload

def p171_find(+entries: List<&2,P171Entry>, +key: String) -> P171Entry:
  match entries:
    case Nil{}: P171Entry{"",""}
    case Con{+head,rest}:
      p171_choose(P171Entry,String.eq(p171_key(head),key),u => head,u => p171_find(rest,key))

def main() -> List<&2,String>:
  +first : P171Entry = P171Entry{"a","left"}
  +entries : List<&2,P171Entry> = [first,P171Entry{"b","right"}]
  [p171_payload(p171_find(entries,"a")),p171_payload(p171_find(entries,"b")),
   p171_payload(p171_find(entries,"z")),p171_payload(first)]
