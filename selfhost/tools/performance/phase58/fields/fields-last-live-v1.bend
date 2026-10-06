import Base

type P58LastEmpty is Data:
  P58LastEmpty{}

type P58LastSingle is Data:
  P58LastSingle{only: U32}

type P58LastErased is Type:
  P58LastErased{first: U32, final: U32, -T: Type}

type P58LastOrdered is Data:
  P58LastOrdered{first: U32, middle: U32, final: U32}

def empty() -> P58LastEmpty: P58LastEmpty{}
def single() -> P58LastSingle: P58LastSingle{7}
def trailing() -> P58LastErased: P58LastErased{11, 13, U32}
def ordered_last(f: U32 -> U32, g: U32 -> U32, h: U32 -> U32) -> P58LastOrdered:
  P58LastOrdered{f(1), g(2), h(3)}
def checksum() -> U32:
  match trailing():
    case P58LastErased{a, b, T}: U32.add(a, b)
