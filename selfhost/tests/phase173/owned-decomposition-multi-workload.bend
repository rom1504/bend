import Base

# Multi-argument helper transfer; same full-value oracle as original packet.
# Independent user-program transfer: a packet update, no compiler KTerm type.
type P173OwnedPacket is Data:
  P173OwnedPacket{+label: String, +values: List<&2,U32>, +stamp: U32, +backup: List<&2,U32>}
  P173OwnedVacant{+stamp: U32}

def p173odw_get(packet: P173OwnedPacket) -> List<&2,U32>:
  match packet:
    case P173OwnedPacket{label,values,stamp,backup}: values
    case P173OwnedVacant{stamp}: []

def p173odw_set(packet: P173OwnedPacket, replacement: List<&2,U32>) -> P173OwnedPacket:
  match packet:
    case P173OwnedPacket{label,values,stamp,backup}: P173OwnedPacket{label,replacement,stamp,backup}
    case P173OwnedVacant{stamp}: P173OwnedVacant{stamp}

@unsafe
def p173odw_map(values: List<&2,U32>, +amount: U32) -> List<&2,U32>:
  match values:
    case Nil{}: []
    case Con{head,rest}: Con{U32.add(head,amount),p173odw_map(rest,amount)}

# Wider rebuild helper; all metadata arguments are supplied by verified getters.
def p173odm_label(packet: P173OwnedPacket) -> String:
  match packet:
    case P173OwnedPacket{label,values,stamp,backup}: label
    case P173OwnedVacant{stamp}: ""

def p173odm_stamp(packet: P173OwnedPacket) -> U32:
  match packet:
    case P173OwnedPacket{label,values,stamp,backup}: stamp
    case P173OwnedVacant{stamp}: stamp

def p173odm_backup(packet: P173OwnedPacket) -> List<&2,U32>:
  match packet:
    case P173OwnedPacket{label,values,stamp,backup}: backup
    case P173OwnedVacant{stamp}: []

def p173odm_rebuild(packet: P173OwnedPacket, label: String, values: List<&2,U32>, stamp: U32, backup: List<&2,U32>) -> P173OwnedPacket:
  match packet:
    case P173OwnedPacket{oldLabel,oldValues,oldStamp,oldBackup}: P173OwnedPacket{label,values,stamp,backup}
    case P173OwnedVacant{oldStamp}: P173OwnedVacant{oldStamp}

def p173odw_change(+packet: P173OwnedPacket, +amount: U32) -> P173OwnedPacket:
  p173odm_rebuild(packet,p173odm_label(packet),p173odw_map(p173odw_get(packet),amount),p173odm_stamp(packet),p173odm_backup(packet))

@unsafe
def p173odw_values(n: Nat, +next: U32) -> List<&2,U32>:
  match n:
    case 0n: []
    case 1n+p: Con{next,p173odw_values(p,U32.inc(next))}

def p173odw_make(n: Nat, +seed: U32) -> P173OwnedPacket:
  P173OwnedPacket{U32.show(seed),p173odw_values(n,seed),seed,[31,37]}

def p173odw_aliases() -> List<&2,P173OwnedPacket>:
  +record = p173odw_make(6n,17)
  +children = p173odw_values(5n,3)
  [p173odw_change(p173odw_make(7n,9),4),
   p173odw_change(record,11),record,
   p173odw_change(P173OwnedPacket{"same-child",children,43,children},1),
   p173odw_change(P173OwnedVacant{71},29)]

@unsafe
def p173odw_repeat(n: Nat, packet: P173OwnedPacket) -> P173OwnedPacket:
  match n:
    case 0n: packet
    case 1n+p: p173odw_repeat(p,p173odw_change(packet,1))

@unsafe
def p173odw_sum(values: List<&2,U32>) -> U32:
  match values:
    case Nil{}: 0
    case Con{head,rest}: U32.add(head,p173odw_sum(rest))

def p173odw_digest(packet: P173OwnedPacket) -> U32:
  match packet:
    case P173OwnedPacket{label,values,stamp,backup}:
      U32.add(U32.from_nat(String.length(label)),U32.add(stamp,U32.add(p173odw_sum(values),p173odw_sum(backup))))
    case P173OwnedVacant{stamp}: stamp

def main() -> List<&2,P173OwnedPacket>:
  p173odw_aliases()
