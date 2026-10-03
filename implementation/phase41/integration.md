# Phase41 installed selected-image account

**Final postinstall correctness audit: PASS, 15/15 gates.** The selected image is
checked attempt `checked01`, API
`9900abf49719575db7f7bbee32c6b16e10bcd554f9de22cde0799eb859cc6f0b`. Canonical
source validation accepted all 227 snapshot sources with no changes. Phase41 checked01 is installed on the ordinary user path. Release verification
and all 42 ordinary/relocated CLI checks pass. The preinstall14/14 record below
is retained separately from the final postinstall 15/15 closure.

The canonical audit is
[`preinstall-audit/gates.json`](../../selfhost/build/phase41/integration01/preinstall-audit/gates.json)
(SHA-256 `edd50312185b4db83814a4c4779f11eec3f362e1d99133afc720e5efc01b0840`);
its [human-readable table](../../selfhost/build/phase41/integration01/preinstall-audit/gates.md)
records accepted counts and the retained observation policy. All fourteen gates
passed: checked build, frontend main and broader, backend pilot, primitive,
worker, nested, primitive guards, selected upstream, corpus, worker admission,
component, HVM, and Phase35 owner controls.

## Semantic and frontend evidence

The fresh two-worker frontend gates passed exact agreement for 3,026 main and
196 broader observations. Main retains 2,525 pass, 497 observed, and four
shared historical failures; broader retains 195 pass and one observed result.
The candidate used two workers and the pinned reference kept four. The
[validation account](validation.md) separates this historical elapsed comparison
from a controlled same-image worker experiment.

Additional accepted audit scopes include 81 backend-pilot points (69 pass,
8 not applicable, four fail under the retained policy); 56,205 primitive scalar
checks and 58 observations; 3,759 worker scalar checks and 14 observations;
144 nested checks; 1,129 primitive guards and 25 observations; 15 selected
upstream probes; 23 corpus libraries / 127 points; 40 worker-admission guards
with two execution witnesses; 22 component observations; 42 HVM stdout bytes;
and 15 Phase35 owner-control groups. These scopes overlap and must not be added
as a single total.

The independent new wrapper fixture v2 passed 84 oracles and two boundaries,
admitting `wrap.turn` and `wrap.forward` and refusing the nine malformed,
scalar, and backedge witnesses. Its
[report](../../selfhost/build/phase41/wrapper-fixture02/controls03/report.json)
is bound to checked01. The [owner closure report](../../selfhost/build/phase41/integration01/owner-report.json)
passed 15 groups. Additional new-owner groups (15 + 7 + 3 + 4, including tail
controls) passed; actual Phase40 list, Nat, linear-order, and scalar-island
precedence controls also passed. Their exact selected-image receipts are listed
in the canonical audit and raw Phase41 tree.

The full 45-module identity check found 42 byte-identical modules and exactly
three changed tree modules: `tree-bitonic`, `variation-tree-bitonic-6-17`, and
`variation-tree-bitonic-9-123`. This is an identity result, not a timing result.
The [identity receipt](../../selfhost/build/phase41/module-identities01.json) is
SHA-256 `8193e6185ec8a489c66dcc86039b81fb4d430f45833b3a248391aaf2db8e04a3`.

Static source counts report 18,898 physical lines, 16,187 nonblank lines,
777,508 bytes, 2,108 definitions, 640 laws, 71 types, and 70 modules for the
checked source inventory; delta from Phase40 is +35 physical lines,
+31 nonblank lines, +1,963 bytes, and +4 definitions. The source-count scope
excludes generated compiler/API size and experiment tooling. See
[`source-counts01.json`](../../selfhost/build/phase41/source-counts01.json)
(SHA-256 `485194782d47611f161988c111b259a0c0ff4c2ea9781a73b004d94ceb55adac`).

## Retained diagnostics and remaining gates

Five unsuccessful jobs are preserved, including four fixture/tool diagnostics: the tree deep-oracle
expectation, the list sequence-expression grouping, the first wrapper-fixture
binder, and the first double-map fixture oracle. Together with the transient sandbox `EPERM` they total17.282seconds of
recorded enclosing job intervals; corrected controls and the authorized local
execution retry passed. None was a checked compiler
failure or an accepted-audit failure; raw attempts remain in the build tree.

The postinstall run closes release installation, installed verification, and all
42 ordinary/relocated CLI checks in54.252seconds of enclosing tool time. The
[final audit](../../selfhost/build/phase41/integration01/postinstall-audit/gates.json)
passes 15/15 groups, sets `postInstallChecked: true`, and verifies all 227
canonical snapshot sources unchanged. Phase40 is preserved in release history.
This is a checked B1 derivative, not a new self-emitted fixed point.

The [performance admission](performance-admission.md) accepts the measured tree
compilation tradeoff explicitly. All36 compiler-cost requests reproduce their
expected checked output. The six-point maintained runtime run passes 90 samples;
three changed tree points improve 1.506–1.592×. Diagnostics pass six captures;
the portable45-point candidate bundle's fast-five smoke passes in16.934seconds.
See [results](results.md), [profiles](profile-findings.md), and the
[portable run guide](../../selfhost/tools/performance/phase41/README.md).

The [closed evidence capsule](evidence/README.md) preserves successful and failed
receipts, checked image, ledger and consumed tools. Its capture and independent
verification follow the explicit [raw closure](raw-closure.json). No complete
backend/GPU, independent proof-validity or universal conformance claim is made.
