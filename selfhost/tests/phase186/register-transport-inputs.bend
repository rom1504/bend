import Base

type TransferTree is Data:
  TransferLeaf{value: Nat}
  TransferPair{left: TransferTree, right: TransferTree}

def transfer_tree(depth: Nat, +seed: Nat) -> TransferTree:
  match depth:
    case 0n: TransferLeaf{seed}
    case 1n+prior:
      +prior = prior
      TransferPair{transfer_tree(prior,Nat.add(Nat.mul(seed,2n),1n)),
        transfer_tree(prior,Nat.add(Nat.mul(seed,2n),2n))}

def transfer_visit(tree: TransferTree, +apply: Nat -> Nat) -> Nat:
  match tree:
    case TransferLeaf{value}: apply(value)
    case TransferPair{left,right}:
      Nat.add(transfer_visit(left,apply),transfer_visit(right,apply))

def transfer_run(depth: Nat, +bias: Nat) -> Nat:
  transfer_visit(transfer_tree(depth,0n),value => Nat.add(bias,value))

def main() -> List<&2,Nat>:
  +bias = Nat.mul(65536n,65536n)
  [transfer_run(0n,bias),transfer_run(1n,bias),transfer_run(6n,bias)]
#|[4294967296n, 8589934595n, 274877912992n]
