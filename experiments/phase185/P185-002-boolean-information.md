# P185-002: Preserve Boolean meaning through native lowering

Status: testing; no promotion.

Observation: Bool.or/xor still use generic primitive dispatch in tree sorting. F32 comparison results are treated as arbitrary64-bit terms, causing repeated raw/packed Boolean normalization.

Two independently reviewable transformations: inline exact raw-or-packed Boolean truth for or/xor with hygienic snapshots; preserve a one-bit result fact for exact authenticated Boolean primitive calls using the verified reserved scratch buffer. Unknown symbols, malformed arity, custom buffers and aliases retain existing behavior.

Expected mechanism: remove generic helper calls and impossible normalization branches. No change to F32 computation or NaN semantics is intended. The raw representation contract is broader than merely testing nonzero.

Gates: seven direct functions over17×17 independently labelled raw-word pairs on QBE and x86;18 admission/hygiene rows;35 scalar-fact, invalidation and unchanged-verifier controls; source-level Boolean/F32 NaN/inf/signed-zero oracles; transfer on tree and ray and broad native45. Finite controls are not a proof of backend equivalence.
