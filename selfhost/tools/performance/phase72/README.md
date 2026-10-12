# Phase72 product transport methods

[Design](../../../../design/phase72/product-transport.md) ·
[Report](../../../../implementation/phase72/README.md).
All target paths are fresh under `selfhost/build/phase72`. No subagent was used.
One heavy process tree at a time, CPU3,2GiB RSS/4GiB available memory. Node runs
with1GiB heap/4MiB stack. Methods retain the diagnosed sandbox stdin exception.

## Fast loop and implementation

`bst-prototype.py` makes one hash-checked saved-C substitution and builds it with
pinned Clang-O3. `measure.py bst --out NEW` compares original/prototype/upstream
with independent16-input checksums and rotated rounds. `measure-v1.py` preserves
the failed old upstream-path binding; final `bst02` passes. Array.map's analogous
intervention is the frozen Phase71 result. The first saved-C result justified
compiler work; it is not relabeled as a compiler-generated result.

`compiler01` is the checked one-line result-shape change; `compiler02` adds
checked private entry admission. Both were built through the maintained
`tools/development/workflow.mjs run` entry with the frozen Phase70 development
configuration and a fresh bounded-run output. `diagnose.mjs` adds an explicitly
private helper to a derived API to inspect signatures and rejected lowering;
it does not change the installed API or execute benchmark programs.

`methods/` preserves exact successors of the earlier checked harnesses. Their
adjacent derivation receipts identify parent bytes. Changes set the Phase72
output boundary and Phase70 comparison baseline; runtime oracles and guards stay.
The coverage freezer/run/compare trio serves the six added families. The existing
Phase67 benchmark freezer/acquirer serves the original six, with
`methods/compare-native.py` for the same-campaign old/new/upstream comparison.
Use their `--cases` parameters for small iteration sets, and fresh output names.
Never overwrite a saved attempt or rerun its controller into its old output.

Final acquisitions:`compiler02-native06`,`compiler02-coverage02`,
`compiler02-coverage-rest`. Final timings:`compiler02-native-comparison` and
`compiler02-coverage-comparison`; intermediate comparisons remain separate.
`shapes.py` compares whole C and private-worker source-site counts. It is not a
profiler or a claim about dynamic allocation frequency.

## Gates, costs and release

`prepare-custom.py` binds focused or native100 source selections to the checked
attempt; `prepare-custom-raw.py` binds the retained31 raw observations. Run each
prepared `plan.json.command` serially. The paired native100 failure is retained:
candidate100pass/reference93pass with seven known demand disagreements. New
loop fixture versions1–3 were rejected by both checkers; version4 and scalar
state pass. `verify-js.py` protects the exact non-native executable closure.

`request-screen.py` measures a short Numeric B1 pair. `prepare-bootstrap.py`
prepares genuine B2 and driver gates; `prepare-compilation.py` binds the three
native source oracles to B1/B2. `pair-compilation.py` creates the interleaved
45-request campaign including old/new B1/B2 and upstream. The unchanged Phase70
compilation runner executes its prepare/clean groups; no profiles were needed.

`prepare-c-identity.py` binds all twelve acquisitions. Run only its `b2` prepare
and clean jobs via the runner's `--only` option; the unexecuted B1 jobs are not
claimed. `prepare-release-qualification.py` prepares own-source checking, exact
B3 reproduction and deferred installation/CLI checks. Installation occurred only
after qualification. `qualification.py` joins receipts and independently verifies
all seven historical release files. `summarize.py` reads retained measurements;
it does not resample or select favorable intervals.

## Closed evidence

`seal.py` archives Phase72 raw and these methods, excluding private `usage-*`
snapshots and the archive's own directory. `evidence01/manifest.json` records
members, hashes and modes; `verification.json` records reopened verification.
Restore ZIP member paths under a scratch repository root. Selected compiler
snapshots and generated artifacts are included. Prior-phase baseline archives,
reference compiler and pinned toolchains remain external dependencies. Use
fresh replay outputs; do not edit closed evidence or expect absolute paths to
work on an unrelated machine without a recorded adaptation.
