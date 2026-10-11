import Base

type Chain69 is Data:
  Last69{}
  Link69{head: U32, tail: Chain69}

def chain69() -> Chain69:
  Link69{1, Link69{2, Last69{}}}

def total69(value: Chain69) -> U32:
  match value:
    case Last69{}: 0
    case Link69{head, tail}: U32.add(head, total69(tail))

def extend69(head: U32, tail: Chain69) -> Chain69:
  Link69{head, tail}

def main() -> U32:
  +value = chain69()
  U32.add(total69(value), total69(extend69(10, value)))

#|16
