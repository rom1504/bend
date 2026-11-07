import Base

# Complete upstream-observed value; source SHA256 ab53fdc13f4bdf1b3535ff5d84f43a8c108bfe8c8294c67708c1ef9e4f5ca7b0
type P173OwnedPacket is Data:
  P173OwnedPacket{+label: String, +values: List<&2,U32>, +stamp: U32, +backup: List<&2,U32>}
  P173OwnedVacant{+stamp: U32}

def main() -> List<&2,P173OwnedPacket>:
  [P173OwnedPacket{"9",[13,14,15,16,17,18,19],9,[31,37]},P173OwnedPacket{"17",[28,29,30,31,32,33],17,[31,37]},P173OwnedPacket{"17",[17,18,19,20,21,22],17,[31,37]},P173OwnedPacket{"same-child",[4,5,6,7,8],43,[3,4,5,6,7]},P173OwnedVacant{71}]
