import Base

# Complete ordinary source values, not hashes. Upstream and the unchanged
# compiler are independent execution oracles for the experimental template.
type BorrowBox is Data:
  BorrowBox{+label: String, +low: U32, +high: U32,
    +values: List<&2,U32>, +other: List<&2,U32>, +kind: U32}

@unsafe
def p173c_list(+n: Nat) -> List<&2,U32>:
  match n:
    case 0n: []
    case 1n+p: Con{U32.from_nat(n),p173c_list(p)}

def p173c_box() -> BorrowBox:
  BorrowBox{U32.show(123),1,2,p173c_list(3n),p173c_list(2n),7}

def p173c_span(box: BorrowBox, low: U32, high: U32) -> BorrowBox:
  match box:
    case BorrowBox{label,oldLow,oldHigh,values,other,kind}:
      BorrowBox{label,low,high,values,other,kind}

def p173c_values(box: BorrowBox, values: List<&2,U32>) -> BorrowBox:
  match box:
    case BorrowBox{label,low,high,oldValues,other,kind}:
      BorrowBox{label,low,high,values,other,kind}

def p173c_low(box: BorrowBox) -> U32:
  match box:
    case BorrowBox{label,low,high,values,other,kind}: low

def p173c_get_values(box: BorrowBox) -> List<&2,U32>:
  match box:
    case BorrowBox{label,low,high,values,other,kind}: values

def p173c_shared() -> List<&2,BorrowBox>:
  +box = p173c_box()
  [p173c_span(box,11,12),box]

def p173c_unique_rfc() -> BorrowBox:
  +box = p173c_box()
  +observed = p173c_low(box)
  p173c_span(box,U32.add(observed,20),U32.add(observed,21))

def p173c_static() -> List<&2,BorrowBox>:
  +box : BorrowBox = BorrowBox{"static",3,4,[5,6],[7,8],9}
  [p173c_span(box,31,32),box]

def p173c_child_alias() -> List<&2,BorrowBox>:
  +values = p173c_list(4n)
  box : BorrowBox = BorrowBox{"aliases",5,6,values,values,10}
  +result = p173c_values(box,values)
  [result,p173c_span(result,51,52)]

def p173c_shared_child() -> List<&2,BorrowBox>:
  +box = p173c_box()
  values = p173c_get_values(box)
  [p173c_values(box,values),box]

def main() -> List<&2,List<&2,BorrowBox>>:
  [[p173c_span(p173c_box(),41,42),p173c_unique_rfc()],
    p173c_shared(),p173c_static(),p173c_child_alias(),p173c_shared_child(),
    [p173c_values(p173c_box(),p173c_list(5n)),p173c_values(p173c_box(),[61,62])]]
