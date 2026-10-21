# Scalar observer V2 repair

Root's first checked-source acquisition succeeded, but ordinary control emission
was rejected by the independent direct verifier with
`direct condition must be a definitely assigned U32`. Evidence:
`selfhost/build/phase118/scalar-controls-emit01/report.json`.

The runtime guard returns a U64, and V1 passed it directly to `P113DIf`.
`scalar-observer-v2.bend` inserts one comparison against zero before the branch.
The `N111Bin` operand type remains U64, while the existing comparison schema
declares its result as U32. The new branch uses that result. Runtime helper,
guard semantics, fallback and controls are unchanged.

V2 SHA256:
`7a370d21d53ed09d7edce30f1c2a836c33c0e6d31a9ccac5a4cf0605e1d399a5`.
The original module and failed attempt remain reproducible. This repair received
source review only here; subsequent checking and runtime evidence belong to the
root's separate reports.
