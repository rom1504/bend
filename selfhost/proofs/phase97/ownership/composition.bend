import Base
import ./model.bend as M
import ./protocol.bend as P
import ./local.bend as L

# Supporting lemma: sequencing retains a read even when the suffix faults.
law resume_read:
  for -A: Data
  for value: A
  for result: M.OwnResult<A>
  for suffix: List<&2, M.OwnOp>
  {M.resume(A, M.prepend_read(A, value, result), suffix) == M.prepend_read(A, value, M.resume(A, result, suffix)) : M.OwnResult<A>}

def resume_read(A, value, result, suffix):
  match result:
    case M.OwnDone{cell, reads}: {==}
    case M.OwnFault{reads}: {==}

# Supporting induction: the observable result is a compositional semantics
# for sequencing actual Base list append, including early faults.
law execute_append:
  for -A: Data
  for +prefix: List<&2, M.OwnOp>
  for +suffix: List<&2, M.OwnOp>
  for cell: M.OwnCell<A>
  {M.resume(A, M.execute(A, prefix, cell), suffix) == M.execute(A, List.append(&2, M.OwnOp, prefix, suffix), cell) : M.OwnResult<A>}

def execute_append(A, prefix, suffix, cell):
  match prefix:
    case Nil{}: {==}
    case Con{op, +rest}:
      match op:
        case M.OwnKeep{}:
          match cell:
            case M.OwnDead{}: {==}
            case M.OwnLive{extra, value}:
              execute_append(A, rest, suffix, M.OwnLive{1n+extra, value})
        case M.OwnRead{}:
          match cell:
            case M.OwnDead{}: {==}
            case M.OwnLive{+extra, +value}:
              %execute_append(A, rest, suffix, M.OwnLive{extra, value}) : {M.resume(A, M.prepend_read(A, value, M.execute(A, rest, M.OwnLive{extra, value})), suffix) == M.prepend_read(A, value, _) : M.OwnResult<A>}
              resume_read(A, value, M.execute(A, rest, M.OwnLive{extra, value}), suffix)
        case M.OwnDrop{}:
          match cell:
            case M.OwnDead{}: {==}
            case M.OwnLive{extra, value}:
              match extra:
                case 0n: execute_append(A, rest, suffix, M.OwnDead{})
                case 1n+prior: execute_append(A, rest, suffix, M.OwnLive{prior, value})

# Supporting congruence over a previously computed outcome, rather than an
# assumption that a surrounding prefix finishes successfully.
law resume_temporary_read:
  for -A: Data
  for result: M.OwnResult<A>
  for +tail: List<&2, M.OwnOp>
  {M.resume(A, result, P.temporary_read(tail)) == M.resume(A, result, P.borrowed_read(tail)) : M.OwnResult<A>}

def resume_temporary_read(A, result, tail):
  match result:
    case M.OwnFault{reads}: {==}
    case M.OwnDone{cell, reads}:
      %L.temporary_read_preserves(A, tail, cell) : {M.prepend_reads(A, reads, M.execute(A, P.temporary_read(tail), cell)) == M.prepend_reads(A, reads, _) : M.OwnResult<A>}
      {==}

# Public contextual preservation: the replacement is valid after any prefix
# and before any suffix. Equality covers the full trace, final roots and fault.
law temporary_read_in_context:
  for -A: Data
  for +prefix: List<&2, M.OwnOp>
  for +tail: List<&2, M.OwnOp>
  for +cell: M.OwnCell<A>
  {M.execute(A, List.append(&2, M.OwnOp, prefix, P.temporary_read(tail)), cell) == M.execute(A, List.append(&2, M.OwnOp, prefix, P.borrowed_read(tail)), cell) : M.OwnResult<A>}

def temporary_read_in_context(A, prefix, tail, cell):
  %execute_append(A, prefix, P.temporary_read(tail), cell) : {_ == M.execute(A, List.append(&2, M.OwnOp, prefix, P.borrowed_read(tail)), cell) : M.OwnResult<A>}
  %execute_append(A, prefix, P.borrowed_read(tail), cell) : {M.resume(A, M.execute(A, prefix, cell), P.temporary_read(tail)) == _ : M.OwnResult<A>}
  resume_temporary_read(A, M.execute(A, prefix, cell), tail)

#|ALL PROOFS CHECK
#|Use --verdict for mathematical validity.
