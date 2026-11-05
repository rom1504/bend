# Experimental semantic result. Only the separate independent final verifier
# grants emission permission; this lowering record is not a certificate.
type P167Lowered is Data:
  P167Lowered{+program: P113DProgram, +adapters: KDef, +error: String, +stats: List<&2,U32>}

type P167Catalogue is Data:
  P167Catalogue{+index: KDef, +error: String}

type P167Context is Data:
  P167Context{+book: List<&2,KDef>, +catalogue: KDef, +bangs: List<&2,String>}

type P167Demand is Data:
  P167Demand{+todo: List<&2,String>, +asked: KDef, +count: U32}

type P167Built is Data:
  P167Built{+segments: List<&2,N111Segment>, +present: KDef, +adapters: KDef,
    +fresh: U32, +families: U32, +factories: U32, +wrappers: U32,
    +demands: U32, +error: String}
