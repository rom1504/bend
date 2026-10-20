# Internal optimization session, not a public proof or serialized admission.
# Only open establishes valid. Passes retain original/ids by construction;
# close returns ordinary IR, which still crosses the unchanged final verifier.
type P114SBoundary is Data:
  P114SBoundary{+original: P112StaticProgram, +ids: N111Ids, +functions: List<&2,P113DFunction>, +valid: Bool}

type P114SLowered is Data:
  P114SLowered{+boundary: P114SBoundary, +error: String}
