import Base

# Complete upstream-observed value; source SHA256 7e300342bdf8a69508cf84ffb9ac4f3933a7018487493c407aa13e35c8ffffc6
type P173OwnedPacket is Data:
  P173OwnedPacket{+label: String, +values: List<&2,U32>, +stamp: U32, +backup: List<&2,U32>}
  P173OwnedVacant{+stamp: U32}

def main() -> U32:
  1289100
