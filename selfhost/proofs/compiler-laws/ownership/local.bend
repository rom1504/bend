import Base
import ./model.bend as M
import ./protocol.bend as P

# Complete outcomes agree for every payload, initial root count and suffix.
# This includes the dead initial cell and a suffix that later faults.
law temporary_read_preserves:
  for -A: Data
  for +tail: List<&2, M.OwnOp>
  for cell: M.OwnCell<A>
  {M.execute(A, P.temporary_read(tail), cell) == M.execute(A, P.borrowed_read(tail), cell) : M.OwnResult<A>}

def temporary_read_preserves(A, tail, cell):
  match cell:
    case M.OwnDead{}: {==}
    case M.OwnLive{extra, value}: {==}

# Semantic anchor: all three operations fault on a dead root.
law dead_root_fault:
  for -A: Data
  for op: M.OwnOp
  for tail: List<&2, M.OwnOp>
  {M.execute(A, op <> tail, M.OwnDead{}) == M.OwnFault{Nil{}} : M.OwnResult<A>}

def dead_root_fault(A, op, tail):
  match op:
    case M.OwnKeep{}: {==}
    case M.OwnRead{}: {==}
    case M.OwnDrop{}: {==}

# Semantic anchor: removing the final owner before reading is a fault.
law drop_last_then_read_fault:
  for -A: Data
  for value: A
  for tail: List<&2, M.OwnOp>
  {M.execute(A, M.OwnDrop{} <> M.OwnRead{} <> tail, M.OwnLive{0n, value}) == M.OwnFault{Nil{}} : M.OwnResult<A>}

def drop_last_then_read_fault(A, value, tail):
  {==}

#|ALL PROOFS CHECK
#|Use --verdict for mathematical validity.
