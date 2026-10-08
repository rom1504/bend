import Base

type Box is Type:
  Hidden{f: U32 -> U32}

def make() -> Box:
  Hidden{x => x}
