# P194-003 — paired diagnostic computations

Question: can six paired source-level probes expose missing general backend capabilities more cheaply than another full compiler rebuild?

Twelve programs cover mutable value identity, register pressure, closed/mixed F32, predicate flow, unique/shared products and cache-resident memory dependence. They remain outside immutable native45. Independent mathematical expectations cover two sizes; controlled runtime uses fixed inputs and calibrated repetitions.

Initial fixtures/catalog and mathematical checks are retained. First actual source check (`diag-baseline-emit01`) rejects a forward-reference wrapper (`p194.after`). No generated-program result is claimed from this attempt. Corrected fixtures must be versioned and checked before measurements.

A source pair is a diagnostic, not proof that the intended machine structure survives optimization. Machine inspection and actual timings decide what it reveals. In particular the memory pair is not a DRAM latency benchmark and the pressure checksum alone cannot authenticate executed work.

Completed: active catalog v3,24 independent mathematical output points, all12
programs built via C/QBE/baseline/selected and96 exact observations per campaign.
Only size1024 is timed. The resulting disassembly exposed22 removable MOVs in
the few-live loop, motivating P194-004. Many-live spills, F32 backedge bank
conversions, shared-product reconstruction and C vectorization remain distinct
limits. Source pairs are not isolation proofs; all runtime/negative evidence is
in the Phase194 report and machine witnesses. No native45 membership changed.
