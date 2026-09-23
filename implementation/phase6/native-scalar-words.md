# Native scalar constructor words — isolated candidate

Status: checked source, emitted-size mechanism and selected actual JS/native
execution gates pass. Candidate remains isolated pending root review and
integration; no controlled timing result.
[Preregistered experiment](../../experiments/phase6/P6-005-native-scalar-words.md).

## Change and checked identity

Only `selfhost/src/back/native/bridge.bend` differs in the isolated complete-source
project. The change adds five physical lines. During `NCtr` sequencing, an already
compacted private `NWord` is retained directly as a constructor argument. Its
reserved temporary counter still advances. `nc_values` prints that immediate word
with the same `ull` spelling used by ordinary native lowering. Nonliteral fields
retain the original nested Let path; NCall sequencing, constructor allocation,
packing, matching, disposal and task continuation code are unchanged.

The candidate is a genuine checked bootstrap followed by the maintained equality
derivation, not an edited generated compiler:

- Source: `371a755ef01a0e8d9384fe9b4d9a3825542dc72ee27de6c01a927373dfaf42eb`.
- Checked B1: `51153380cb0eb8e33e25f73404377c215ac5ce0cb196ce74682a58e0306fe975`.
- Selected derivative: `fed4638f1ddc7263a3eebd31766a3cb710eaa5c30cec590f250b89ac029fec1b`.

The maintained 21-case build/validation gate passes, retaining seven known exact
diagnostic differences. Source/API/runtime/Base and consumed tools are bound by
the normal attempt manifest. Candidate project and all attempts are under
`selfhost/build/phase6/campaign/native`.

## Size mechanism

Fresh checked native emission succeeds for all four source sizes. No Clang ran
in this gate. Historical baseline values below are the retained unchanged Phase 5
emissions, not newly paired time samples.

| Fields | Previous C bytes | Candidate C bytes | Reduction |
| ---: | ---: | ---: | ---: |
| 32 | 217,752 | 148,643 | 31.74% |
| 64 | 396,504 | 152,291 | 61.59% |
| 128 | 1,075,095 | 159,657 | 85.15% |
| 255 | 3,716,568 | 174,389 | 95.31% |

Candidate `WL_CASE` count stays at 127 for all four sizes. The 255-field case has
zero syntactic literal-return continuations, compared with 255 previously, and
four signature Term registers instead of 256. The growing live-prefix chain is
removed; remaining size growth is approximately linear on this ladder.

Fresh request observations were 3.13 / 4.29 / 6.92 / 11.67 seconds. Other agents
were doing correctness work, and baseline timing was not rerun in the same
window. These are descriptive observations, not an estimated speedup. This
native result does not update the released compiler's 6.03× full-source JS
comparison with TypeScript.

## Controls and retained failures

Sixteen source fixtures cover the size ladder, mixed scalar/call fields, unused
heap fields, shared and nested records, a packed single-field constructor,
U32/F32/Nat boundaries, ASCII/non-BMP Char and String, and existing fork/array
regressions. The first fixture copy incorrectly left a shared Box literal
unannotated; both compilers rejected it with identical diagnostics. That failed
`fixtures-v1/check-v1` gate remains preserved. The separate `fixtures-v2` adds the
required annotation; all 16 check observations then match the pinned reference
exactly.

The first actual paired execution gate has 16/16 JavaScript passes per compiler,
with exact outputs, and 16 native unsupported results per compiler because the
retained Clang installation is not on ordinary PATH. A second, separately named
native attempt supplies the Phase 5 CC/CPATH/library environment; the sandbox
returns EPERM when Clang is spawned. These infrastructure failures are not passes
or emitter regressions. The current native host properly reports these EPERM
failures with exit 1. Both complete failed gates remain preserved.

Tool-level escalation for the already-authorized local compile/run task allowed
a fresh native-v3 gate to complete successfully. Its 16 native probes per
compiler all produce the exact expected output, including the 255-field timeout
witness. All 32 actual binaries were then reexecuted with one and four scheduler
workers: **64/64 passes**, with CPU3 affinity. Four workers exercise the task
path, but this is not a multicore throughput measurement.

Additional gates close at 05:31:18 UTC:

| Gate | Actual result |
| --- | --- |
| F32 bit boundaries | Exact JS and native output per compiler for negative zero, positive/negative infinity, maximum finite value, smallest subnormal and canonical NaN. |
| Earlier/later nonliteral overflow field | Both native witnesses reject at runtime with the exact pinned Nat-overflow error, even though the failing field is unused by the matcher. |
| 256-field record | Live TS, unchanged released baseline and candidate all reject in checked compile phase, before C output or Clang. |

Across the positive source gates there are **17 JS and 17 native successful
executions per compiler**. The two runtime failures are separate passing negative
oracles, not successful executions. The three 256-field observations preserve
the arity refusal rather than weakening it. No compiler crash, missing toolchain
or shared failure is counted as a positive pass.

The file-only [audit](native-scalar-audit.py) rechecks source identities, exact
gate coverage, retained failed outcomes, output size, zero literal continuations
and four-register signatures. It confirms production bridge source was unchanged
at the audit. [Independent root inspection](native-scalar-independent-review.md)
accepts the source mechanism; combined integration remains separate.
Allocation-failure behavior is supported by the unchanged allocator
path, not an injected OOM test. No GPU, whole-source performance, arbitrary
malformed private-IR equivalence, or full conformance claim follows from these
selected controls.

## Reproduction and preservation

From `selfhost/`, with Node 24.18 and fresh output directories:

```sh
node tools/development/workflow.mjs run build/phase6/campaign/native/config-v1.json NEW_ATTEMPT
node tools/performance/phase6/native-scalar-words.mjs run NEW_ATTEMPT NEW_EMISSION
node tools/performance/phase6/native-scalar-gates.mjs NEW_ATTEMPT SELECTION NEW_GATE
```

Actual launches use CPU3, 4 MiB stack, 4 GiB heap and finite outer deadlines.
The complete toolchain environment and failed attempts are retained in the
[durable archive](native-scalar-words-evidence/README.md): 4,243 historical
identities in 3,135 verified objects, 12,680,028 compressed bytes, SHA-256
`19142ccd8c465889574b4d12d5d83e5ce944d3bd12ff8a372631fa96cfce32dd`.
It includes genuine candidate artifacts, full C and native binaries, all failed
attempts, fixture copies, consumed tools and the successful file-only audit.
Node and Clang/LLVM remain explicit external prerequisites. All compiler children
and execution gates closed before this archive was made.
