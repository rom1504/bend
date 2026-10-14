# Defunctionalize the continuation: its environment is explicitly Data.
import Base

type Cont is Data:
  AddSeed{seed: U32}

def apply_cont(k: Cont, x: U32) -> U32:
  match k:
    case AddSeed{seed}: U32.add(seed, x)

def route(+k: Cont) -> U32:
  U32.add(apply_cont(k, 1), apply_cont(k, 2))

def run(seed: U32) -> U32:
  route(AddSeed{seed})

def main() -> U32:
  run(40)

#|83
