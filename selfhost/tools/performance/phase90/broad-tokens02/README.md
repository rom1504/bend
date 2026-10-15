# Broad token comparison, extraction transport correction

Use this worker instead of `../broad-tokens01/run.mjs` with the same arguments,
serial guards, prepared oracle manifest and 20/60/300-second tiers documented in
that directory. The archive preparation method remains unchanged.

The actual first attempt `selfhost/build/phase90/broad-token16/report.json`
failed before its first compiler request: Python extracted the exact baseline
and returned status 0, while Node also returned `spawnSync ... EPERM`. Captured
stdout contained the correct digest and stderr was empty. The previous worker
correctly refused this contradictory result; neither the failure nor its raw
logs are overwritten.

This derivative gives the extraction child regular stdout/stderr file
descriptors, retaining both files and all child status/error fields. It still
rejects every child error. It changes no Bend algorithm, C preprocessing,
selected case, archived oracle, budget or equality criterion. `derivation.json`
records exact reversible edits and pins the failed attempt.

The 16-case offline binding preflight passed in `broad-token-preflight02`.
An archive-IO-only control of the new transport passed in
`broad-extract-fd-control01`: return code 0, no subprocess error, empty stderr,
and exact 209,545-byte baseline. Its temporary baseline was removed after the
check. That control ran no compiler, Clang, native image or generated program.
The underlying cause of Node's earlier contradictory result is not established.
