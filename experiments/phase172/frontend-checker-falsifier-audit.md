# Deferred pattern rows: native falsifier audit

Status: source-only audit. No native product was acquired or executed for this
audit. The proposed Phase169 checker run was cancelled before acquisition because
its workload does not exercise the intended pattern-substitution boundary.

## Result already available

Root's independently source-checked baseline/candidate APIs passed the20 complete
substitution observations and24 complete flattening observations, including
ordered substitutions, malformed-term metadata, early errors and span behavior.
They also produced identical complete `FLoadTrace` values for the actual verifier
source:682,767 compared values. See
`selfhost/build/phase172/frontend-controls05/report.json` and the immutable source
snapshot `selfhost/build/phase172/frontend-inputs05/manifest.json`.

The single hosted full-loader observations were baseline4.9673s and
candidate5.0208s. They are neutral diagnostic evidence, not a clean native speed
comparison or a statistically established slowdown. Complete output equality is
useful; no material performance benefit has been demonstrated.

## Why the retained checker is the wrong performance falsifier

The proposed input was the full469,012-byte,1,601-declaration frozen program:

`selfhost/build/phase169/checker-source01/compiler.bend`

SHA256: `ae01b6557f3aafac0e98c3a73ca5d2f4ca1aef89088ceca1cc2c3e1c6577cc70`.

Its unchanged `main` calls `p169c_run(32)`. This performs320 genuine loader/checker
requests and consumes their complete result through the existing digest. However,
all ten embedded `p169c_fixtures` source strings concern ADT publication,
template instantiation, laws and type failures. None contains a `match` or a
constructor-destructuring local binding. None imports Base.

The actual original call sites establish the missing connection:

- `ff_flat` enters `ff_match` for a term tagged `Match`.
- `ff_local` enters it for a local binder tagged `Ctr`.
- The other `ff_match` references are recursive continuations inside that same
  pattern-flattening computation.

Ordinary function argument binding is not one of those entry conditions. Source
inspection therefore provides no basis for expecting these320 requests to do
meaningful deferred pattern substitution. No dynamic zero-count is claimed: the
important finding is that relevance was unestablished, so an expensive native
run would not be a sound falsifier of this optimization mechanism. The actual
verifier source used in the successful hosted control contains real patterns and
has stronger relevance.

The full source includes the compiler's own pattern-heavy implementation, but
that is code being executed; it is not automatically an input being parsed during
the benchmark. Confusing those two levels would give this test unjustified
coverage.

## Retained executable is also not a same-producer baseline

The old native product is
`selfhost/build/phase169/checker-baseline-machine01/program`:

- SHA256 `4ec91c5c11782589a7362c7267b180166b5e749b4ae3003956bf99e325755455`.
- Emitted using the Phase152 producer, not the current qualified compiler.
- Its retained39,916,130-byte QBE has SHA256
  `d55e0c88d43d279e112c6371bb67b92c72aade8824a52704c11713b044350281`.
- The combined original `checker-baseline01/report.json` is incomplete; the
  separate `checker-baseline-machine01/report.json` is complete.
- Runtime object SHA256 is
  `2d07832382a11d7e993124ecc70452e4e1a3b7f753cf429343e1183cd8e493a3`.

If this source becomes useful for another experiment, compare two variants
produced by the same compiler, runtime and machine flags. Reuse of the old
executable would require matching its producer policy or establishing exact
baseline IR identity. Matching only its source and runtime is insufficient.

## Why deferred substitution can remain neutral

The implementation removes repeated materialization of unaffected term nodes but
does not remove all repeated work. For a body with approximately `N` original
nodes, `V` variable occurrences and `d` pending substitutions, the old traversal
can approach `d*N` node visits. The deferred implementation approaches `N + V*d`
visits/scans, plus replacement traversal, row conversion, pending-list retention
and reversal. This is a structural estimate, not an allocation or runtime
measurement.

`p172dp_variable` linearly searches the pending chain at each variable. An
unaffected variable searches the entire chain. A replaced variable processes
subsequent substitutions inside the inserted value. Thus variable-heavy bodies,
small substitution depths and large necessary replacements can erase the
benefit. Persistent pending lists also retain terms and add ownership traffic.

`p172dp_entry` converts every generic row even when no heads remain, whereas the
old terminal path reads only the selected first row. This is another plausible
cost, but fixing it now would be an unmeasured new micro-optimization. This pilot
must first earn further investment with actual whole-loader/request improvement.

## Decision

Preserve the checked experimental implementation and finite/full-value evidence;
do not promote it or launch a new synthetic fixture campaign. Root will finish
the already justified actual-verifier QBE equality gate. Unless existing evidence
reveals a material native hot path, stop this pilot with **no demonstrated speed
gain**, rather than interpreting a no-pattern native benchmark as a rejection
or undertaking a full image build. The principal lesson is to check the dynamic
input boundary before spending on native acquisition.
