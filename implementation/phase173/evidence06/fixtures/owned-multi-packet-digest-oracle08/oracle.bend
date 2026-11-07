import Base

# Complete upstream-observed value; source SHA256 8328d69875d1ed44bcb69c84cff87d0c6f50ff55dcfa9d87f7b09c9242ba25d0
type P173OwnedPacket is Data:
  P173OwnedPacket{+label: String, +values: List<&2,U32>, +stamp: U32, +backup: List<&2,U32>}
  P173OwnedVacant{+stamp: U32}

def main() -> U32:
  1289100
