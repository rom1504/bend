# Reject global constructor gate on current qualified source

The existing `x185_ctor_enabled` switch improves tree slightly but regresses the
required Map transfer control. **Keep the gate false.** No maintained source,
installed image or qualification changed. This bounded experiment started from
qualified commit3137580a04919bce3712f742128ac3f62221dbd7 and completed within its
approximately8-minute engineering limit; CPU3 was released after timing.

| Case | False median ms | True median ms | True/false |
| --- | ---: | ---: | ---: |
| BST64 | 0.027750 | 0.027389 | 0.986987 |
| tree-bitonic | 0.520000 | 0.498765 | 0.959164 |
| Map128 | 0.818930 | 0.890830 | 1.087797 |

Six balanced rounds, independently calibrated200ms targets, all36 timed
full-result/count observations correct. The descriptive three-case geometric
ratio is1.009836. Map's off samples0.818930–0.827160ms and on samples
0.886463–0.895197ms do not overlap. No confidence interval or whole-suite
projection is claimed. The1.30% BST result is small; it does not explain the
profiled constructor-helper attribution difference.

## Mechanism and validation

Two freshly checked hosted APIs derive from the exact current selected-source02
snapshot and differ **only** in the literal gate. All three false-gate complete
objects are byte-identical to retained qualified N1 native45-01 objects before
timing. Shared preparation preserves the exact4,081-declaration/1,367,502-byte
closure and frozen assets. All six ordinary machine/oracle builds pass.

The actual BST product.bst.down now loads the allocator at0x40a426, tests the
free-list bin at0x40a42b, and updates the head, allocation length and original
fields on the hit path. The original sized constructor remains on misses.
Independent unchanged cold-ctor-oracle.c passes221 checks through **each** direct
object and rendered-assembly route, exercising cache hits, empty bins, descriptor
and capability guards, exact fallback pointer/count/fields, widths1–4 and twice
reuse. Twenty-four existing QBE-independent admission rows also pass. Routes
share Bend selection; these are finite checks, not an ownership/backend theorem.

Inlining materially enlarges physical code. BST down grows154→374 instructions
and41→120 explicit frame references. The inspected Map seek worker grows
4194→7040 instructions and1376→2054 explicit frame references. These are static
counts across alternative paths, not dynamic spills or measured stalls. Tree's
warp remains557 instructions/193 frame references. Actual constructor hits
therefore do not imply a general win; placement/transport/code growth merits
measurement before any smaller general admission policy. No benchmark-specific
enablement or further policy search was attempted.

## Failures, cost and retained evidence

The first two preparation acquisitions failed because the historical controls
referenced QBE-only P111QCode and p111q_value declarations, absent from the current
x86 source profile. Original sources, errors and guard receipts remain.
Version3 reuses the original admission helpers and24 non-QBE-text rows; eight
QBE text/printing rows are omitted, explicitly. The C cache oracle is unchanged.
A small fixture invokes the actual x86 late expansion, then the existing alpha
renamer maps scratch to an external argument so exact fallback pointer identity
can be tested. No production backend algorithm was added or edited.

Nine guarded jobs cost138.488 seconds, including13.524 seconds for those two
failed acquisitions. `results.json` records exact per-job costs, per-case samples
and receipt pins; all jobs have completed/failed retention closure receipts.
`machine-audit.json` binds complete objects and actual selected-owner counts;
adjacent .asm files retain full inspected owners. All prepared argv and fixture
versions are preserved here. Live products remain under
selfhost/build/phase195/ctor-{off,on}-build01; the runtime authority is
selfhost/build/phase195/ctor-gate-runtime01/report.json.

No new targets remain queued. Any future experiment needs fresh output roots
and a new measured hypothesis, not another unconditional constructor enable.
