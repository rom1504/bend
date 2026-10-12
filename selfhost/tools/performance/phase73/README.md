# Phase73 native parity experiments

[Design](../../../../design/phase73/native-parity.md) ·
[Report](../../../../implementation/phase73/README.md) ·
[Ownership/scalar invariants](../../../../docs/self_hosted/NATIVE_OWNERSHIP_FACTS.md).
One agent, one guarded target tree at a time. CPU3,2GiB RSS ceiling,4GiB available
floor; Node1GiB heap/4MiB stack. Threaded correctness uses CPUs0–3. No PR comments.

## Fast loops

Always use a fresh directory under `selfhost/build/phase73`. `development.json`
binds the checked B1/equality workflow to unchanged upstream0592662. A checked
build takes about32seconds on the recorded host. Keep slow gates for a candidate
that has demonstrated runtime gains. Saved-C falsifiers are diagnostics; they do
not become production results until the Bend implementation emits the change.

`freeze.py --api API --out NEW.json` pins the six additional families.
`run.py acquire --recipe NEW.json --out NEW --roles selfhost --cases LIST`
emits checked C, builds with the pinned Clang recipe and checks a smoke checksum.
Use `compare.py --help` to bind preserved Phase72 and upstream acquisitions to
the candidate, the fixed `counts.json`, and a scoped comma-separated family set.
Three rotated rounds are the initial comparison; the final selected campaign
uses six rounds to reduce sensitivity to the observed host drift. Every timing
must match the independent16-input oracle and exceed100ms.

The original six families use the existing Phase67 benchmark freezer/acquirer,
followed by `compare-native.py`. Compiler emission, Clang, warmup and execution
are separate clocks. The fixed equal-family12 geometric mean is an optional
summary, not a probability distribution of all possible Bend programs.

## Diagnostic methods

- `counts.py`: Phase72/upstream dynamic allocation, RFC and segment counters.
- `counts-selected.py --acquired DIR...`: identical counters for selected C.
  Counts are diagnostics, never clean timing evidence.
- `cold-probe.py`, `borrow-probe.py`, `borrow-cold-probe.py`: saved-C ownership
  falsifiers; preserve exact diffs and outputs. Their named interventions are
  experiments, not benchmark-specific production admission rules.
- `sharing.mjs`, `sharing-v2.mjs`: private checked-book inspection through an
  explicitly derived diagnostic API. Installed images are never overwritten.
- `inline-probe.py`, `inline-none-probe.py`: opposite inline-policy falsifiers.
- The initial unrestricted-recursion diagnostic API is explicitly unsafe for
  deep inputs and was rejected, not installed.

Each hypothesis has a file in `experiments/phase73`. Failed source/fixture
versions and noisy intermediate campaigns remain in the raw evidence. The later
binding-kind experiment composes the initially unhelpful field-mask experiment
with continuation capture; do not attribute that combined result to the earlier
standalone candidate.

## Correctness, compiler cost and installation

`prepare-custom.py` prepares paired selected native gates. The standard native100
selection retains the seven known upstream unused-error-demand disagreements.
`selection-new-v4.json` adds12 focused controls. `recheck-controls.py` verifies
both positive/negative cold-root admission and retained binaries at threads1/4.
`prepare-custom-raw.py` binds the31 inherited raw observations; `verify-js.py`
requires exact equality of the2,992-function non-native dependency closure,
runtime and public export wrappers.

`prepare-bootstrap.py` binds the actual selected source and B1 to genuine B2
emission and eight driver comparisons. `prepare-release-qualification.py`
prepares fresh own-source acceptance, exact B3 and deferred install/CLI checks.
`prepare-c-identity.py` requires B2 to emit the twelve independently validated C
programs exactly; redundant B1 jobs can be omitted and are not claimed.

`prepare-compilation.py` binds old/new genuine images and exact C oracles.
`pair-compilation.py` creates45 serial, rotated/reversed fresh requests for
Numeric/Array/Lexer across old/new B1/B2 and upstream. Use the unchanged Phase70
compilation runner's prepare/clean groups. Imports and prepared Bend Base are
outside the request clock; upstream checks Base inside its request. Clang and
native program execution are outside both. Profiles never enter timing samples.

Only install after qualification. Preserve all seven prior release files,
verify before/after, and run legacy42/default24/helper5 CLI checks. See the report
for actual executed gates and selected identities rather than inferring success
from a prepared plan.

## Evidence and replay limits

`seal.py` preserves Phase73 raw attempts, source snapshots, generated C/binaries,
B2/B3, gates, failed fixtures and these methods. It reopens the archive and checks
every file hash and executable mode. Private `usage-*` snapshots are excluded;
only aggregate accounting belongs in the report. Historical baselines, upstream
and toolchains remain pinned external dependencies. Absolute recorded paths need
restoration/adaptation; this is not a hermetic environment.
