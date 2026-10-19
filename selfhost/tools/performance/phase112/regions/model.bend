# A frozen entry is never reconstructed against a later ready set.
type P112RegionEntry is Data:
  P112RegionEntry{+segment: N111Segment, +plan: P112WorkerPlan, +rank: U32, +sites: U32}

type P112RegionRegistry is Data:
  P112RegionRegistry{+ready: KDef, +symbols: KDef, +entries: List<&2,P112RegionEntry>, +workers: U32, +fusions: U32}
