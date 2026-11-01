import Base
import ./model.bend as M

# Candidate transformation: eliminate a temporary extra root around a read.
def temporary_read(tail: List<&2, M.OwnOp>) -> List<&2, M.OwnOp>:
  M.OwnKeep{} <> M.OwnRead{} <> M.OwnDrop{} <> tail

def borrowed_read(tail: List<&2, M.OwnOp>) -> List<&2, M.OwnOp>:
  M.OwnRead{} <> tail
