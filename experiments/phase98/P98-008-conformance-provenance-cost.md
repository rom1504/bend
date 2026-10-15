# P98-008: stop rehashing historical provenance for every test

Status: accepted for the final native conformance run; both stages pass.

The first final-image native conformance run hit its 300-second suite guard
while an artifact for case 60 was present. It has no completed 69-case report
and is not a conformance pass. No memory limit was hit. Retain
`origin-conformance01/b1-guard` and the unfinished artifact tree.

Inspection found 462 files totaling 411.52 MiB in the new plan's `inputs`,
versus 248 files and 212.67 MiB in the historical Phase92 plan. The unchanged
adapter verifies that entire list at module import and around every case; the
harness also records artifact identities. The list contains the 123.7 MB Node
executable, 79.5 MB Bun executable, and several historical 17–38 MB C products
which are not consumed by an individual native request. This is validation
overhead, not a measurement of native compiler request time.

Hypothesis: separating immutable provenance from execution inputs will recover
a short full-conformance loop without changing any semantic expectation.

The successor must retain:

- Full provenance verification before and after each stage suite and at final
  collection/admission.
- Per-case verification of the selected compiler, source, Base, runtime parts,
  providers, carrier, fixtures and actual adapter/harness methods.
- The exact original 69 fixtures, 31 exclusions, stage arguments, one-worker
  execution, Clang recipe, output/error oracles and six rejection observations.
- The original deadline and memory limits, with the old failed run untouched.

Only artifact-enumeration policy may change in the adapter. Compiler execution,
program execution, output comparison and diagnostic expectations stay exact.
Actual completion and unchanged-input results, rather than source inspection
alone, decide whether this is useful.

The final snapshot17 adapter changes only the three input-enumeration uses;
the diagnostic runner changes only its adapter import. A separate partition
check compares the original fixtures, toolchains, flags, arguments and oracles
and rejects removal of an executable, active fixture, carrier or adapter.

Per-case checks now cover 12.97 MiB for B1 and 19.22 MiB for B2. The full
411.57 MiB provenance closure remains checked before and after each suite and
at collection/admission. Actual fresh outcomes in `origin-conformance02`:

| Gate | Guarded wall time | Result |
| --- | ---: | --- |
| B1 | 68.633 s | All 69 cases pass; exact historical observed fields. |
| B2 | 79.686 s | All 69 cases pass; exact historical observed fields. |
| Rejections | See diagnostics receipt | Three exact invalid-source observations per stage. |

The wrapper, including suite-level integrity work, takes 72.044 s for B1 and
83.104 s for B2. The diagnostic wrapper takes 4.972 s and final collection
3.273 s. The incomplete 300-second B1 run is a lower bound on the old total,
so this is more than a fourfold B1 suite improvement, not a precise paired
compiler-speed measurement. The native compiler and semantic expectations did
not change between these harness runs. The optimized loop enables more frequent
full qualification without treating historical provenance as a per-case input.
