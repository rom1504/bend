# Private, fixed-producer request evidence. No caller-supplied witness is admitted.
# The only live producer is the raw-owner cache loop in this module family.
type P142WRun is Data:
  P142WRun{+count: U32, +retained: Bool}

type P142WReverse is Data:
  P142WReverse{+segments: List<&2,N111Segment>, +count: U32}

type P142OGResult is Data:
  P142OGResult{+compiled: P111Book, +entries: List<&2,P140OGEntry>, +runs: List<&2,P142WRun>, +hits: U32, +misses: U32}

type P142ORResult is Data:
  P142ORResult{+lowering: P128RawLowering, +cache: P140ORCache, +runs: List<&2,P142WRun>, +stats: List<&2,U32>}

type P142WCounts is Data:
  P142WCounts{+retained: U32, +compared: U32, +mismatches: U32}

type P142VWalk is Data:
  P142VWalk{+walk: P140VWalk, +counts: P142WCounts}

type P142VOpened is Data:
  P142VOpened{+opened: P140VOpened, +counts: P142WCounts}

type P142BResult is Data:
  P142BResult{+back: P140BResult, +counts: P142WCounts}

# Capsule construction is an audited internal invariant, not cryptographic sealing.
# Keep the actual seed and the complete successful front/raw/backend state together.
type P142WSession is Data:
  P142WSession{+seed: P86Seed, +prior: P140SCache}

type P142WResult is Data:
  P142WResult{+emission: P111Emission, +cache: P142WSession, +stats: List<&2,U32>, +counts: P142WCounts}

def p142w_zero() -> P142WCounts:
  P142WCounts{0,0,0}
