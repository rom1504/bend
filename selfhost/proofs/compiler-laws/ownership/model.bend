import Base

# Sequential immutable single-cell model. Live{extra, value} has 1 + extra
# roots; Dead has zero. Nat is structural: there is no wrapping machine count.
type OwnOp is Data:
  OwnKeep{}
  OwnRead{}
  OwnDrop{}

type OwnCell<-A: Data> is Data:
  OwnDead{}
  OwnLive{extra: Nat, value: A}

# A fault means an operation attempted to use a dead cell. Reads before the
# fault remain observable; fault always leaves zero roots.
type OwnResult<-A: Data> is Data:
  OwnDone{cell: OwnCell<A>, reads: List<&2, A>}
  OwnFault{reads: List<&2, A>}

def cell_roots(-A: Data, cell: OwnCell<A>) -> Nat:
  match cell:
    case OwnDead{}: 0n
    case OwnLive{extra, value}: 1n+extra

def result_roots(-A: Data, result: OwnResult<A>) -> Nat:
  match result:
    case OwnDone{cell, reads}: cell_roots(A, cell)
    case OwnFault{reads}: 0n

def prepend_read(-A: Data, value: A, result: OwnResult<A>) -> OwnResult<A>:
  match result:
    case OwnDone{cell, reads}: OwnDone{cell, value <> reads}
    case OwnFault{reads}: OwnFault{value <> reads}

def prepend_reads(-A: Data, reads: List<&2, A>, result: OwnResult<A>) -> OwnResult<A>:
  match reads:
    case Nil{}: result
    case Con{value, rest}: prepend_read(A, value, prepend_reads(A, rest, result))

# Reads copy an abstract immutable value into the trace; they do not return
# escaping runtime pointers. Every operation faults on a dead cell, including
# Keep: a dead root cannot be resurrected.
def execute(-A: Data, ops: List<&2, OwnOp>, cell: OwnCell<A>) -> OwnResult<A>:
  match ops:
    case Nil{}: OwnDone{cell, Nil{}}
    case Con{op, rest}:
      match op:
        case OwnKeep{}:
          match cell:
            case OwnDead{}: OwnFault{Nil{}}
            case OwnLive{extra, value}: execute(A, rest, OwnLive{1n+extra, value})
        case OwnRead{}:
          match cell:
            case OwnDead{}: OwnFault{Nil{}}
            case OwnLive{extra, +value}:
              prepend_read(A, value, execute(A, rest, OwnLive{extra, value}))
        case OwnDrop{}:
          match cell:
            case OwnDead{}: OwnFault{Nil{}}
            case OwnLive{extra, value}:
              match extra:
                case 0n: execute(A, rest, OwnDead{})
                case 1n+prior: execute(A, rest, OwnLive{prior, value})

# Sequencing preserves an earlier fault and concatenates all successful reads
# with any later read trace, including one ending in a fault.
def resume(-A: Data, result: OwnResult<A>, suffix: List<&2, OwnOp>) -> OwnResult<A>:
  match result:
    case OwnFault{reads}: OwnFault{reads}
    case OwnDone{cell, reads}: prepend_reads(A, reads, execute(A, suffix, cell))
