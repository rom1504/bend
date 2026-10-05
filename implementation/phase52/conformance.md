# Phase52 direct JavaScript conformance checkpoints

Recorded on 2026-10-05. The **checked-direct06 maintained JavaScript census
passes all 26 agreement rows: 22 fixture passes and four N/A**. The separate
maintained eight-suite gate also passes against that checked image. The separate,
larger **checked-direct06 semantic gate passes 95 of 96 scenarios and fails
overall**. Its remaining signaling-NaN case disagrees with both the unchanged
source oracle and the pinned upstream result. These are distinct acquisitions
and scopes; the successful census does not waive the semantic NaN failure.

The target is Bend's TypeScript compiler at
`018751270e800bc222a93dad7f257083ee53a5f7`. Direct output uses the explicitly
selected upstream-style callable interface. The legacy `js` backend's mutable
`G` descriptor protocol remains a separate contract. See the
[parity contract](parity-contract.md) and [phase report](README.md).

## Maintained source census: checked-direct04

The [controller](../../selfhost/tools/performance/phase52/direct-conformance.py)
reuses the JavaScript selection from the maintained backend census: four
compile-boundary cases and 22 namespace representatives. It preserves source
fixtures, expected outputs, judging and the pinned TypeScript reference adapter.
The new [adapter](../../selfhost/tools/performance/phase52/direct-conformance-adapter.mjs)
explicitly selects `backend: 'direct'`; it does not delegate emission to the
legacy JavaScript backend.

| Observation | Reference | Direct04 |
| --- | ---: | ---: |
| Successful runtime fixture verdicts | 18 | 18 |
| Expected compile-boundary rejections | 4 | 4 |
| Not applicable at compilation | 4 | 4 |
| Exact paired agreements, including diagnostics | 26 | 26 |
| Semantic paired agreements | 26 | 26 |

Both sides satisfy the unchanged fixture judge. N/A stays N/A; it is not a
successful execution. The four compile-boundary passes are rejection tests for
an unknown CID, a constructor/foreign-name conflict, a foreign `main`, and an
open Array element type.

The 18 runtime cases cover arithmetic, eta expansion, shared trees, higher-order
recursion, effects, imports, foreign character marshalling, erased types,
partial applications, and printed results. Their exact IDs are:

```text
base/nat_ops.bend                 check/eta_long_sides.bend
compile/fork_leaf_handoff.bend    comptime/op_ns.bend
cost/shared_tree_walk.bend        eval/maybe_ops.bend
gfx/app_play.bend                 grade/accept_fill.bend
halt/linear_descent_hoas.bend      import/js_names_apart.bend
io/marshal_char_type.bend         page/compile_type_erasure.bend
parse/do_step_lines.bend          reg/brw_shared_fields.bend
rfc/share_kind.bend               run/gpu_trig.bend
spec/comp_map_mint.bend            stats/match_call_flat.bend
```

The four unchanged N/A rows are `printer/let_in_argument_typ.bend`,
`show/nullary_adt_table.bend`, `state/eval_curried_tree.bend`, and
`stuck/lte.bend`. A source named `run/gpu_trig.bend` here runs through the
JavaScript lane; this does not establish GPU backend coverage.

Execution took **57.712 seconds**, with **349.711 MiB** peak summed process-tree
RSS. Those are gate costs, not compiler-throughput or generated-program speed
measurements. The run was serial on CPU 3 with Node 24.18.0, 30-second case
deadlines, 1 GiB worker heaps, a 2 GiB tree RSS limit, a 4 GiB available-memory
floor and a 900-second outer deadline. The [protocol](../../selfhost/tools/performance/phase52/direct-conformance.md)
documents replay and fresh-output requirements.

Raw evidence is retained under `selfhost/build/phase52/direct-conformance04/`:
`report.json` binds the selected attempt, consumed inputs and final rehash;
`selected/paired.json` holds every paired observation; `selected/` also retains
generated programs, logs and replay records. The frozen consumed adapter binds
its attempt path explicitly. Live source paths in snapshot provenance are not
treated as replay inputs; the corresponding frozen copies are hashed instead.

| Identity | SHA-256 |
| --- | --- |
| `direct-conformance04/report.json` | `4f926d2d427909d5b9326f5e29a2e829a773db56cae34225437141dea9441876` |
| `direct-conformance04/selected/paired.json` | `73bf79a18922787d40d966b6ed265810928b9510bd2ce13e4773154f204e2f04` |
| `checked-direct04/attempt.json` | `f487a147a559b472fb019967b5de6680df647833653ff30e0990aebe62647bda` |
| Checked04 API | `ad226df5f5395af247d17e905fb8600f530c41ba0506f22d7ad81a04ebb8bc57` |
| Checked04 direct runtime | `417d2d47f98116d4eae889ff53132d9255c8a0ffaf047dd497b877f2df0c188a` |

This is the JavaScript subset of the historical 81-row backend census. It does
not renew that entire census, the larger frontend inventories, proof checking,
native backends, all upstream source tests, or any performance result.

## Selected06 maintained gates

The same frozen checked-direct06 image passed the maintained eight suites:
IR, backend, global initializers, choice, arm, primitive guards, provenance and
foreign calls. These are eight suite verdicts against the selected compiler;
they are separate from the direct callable-interface corpus.

Its freshly executed JavaScript census also passed all **26 exact and semantic
paired agreements**: 18 runtime passes, four expected compile-boundary
rejections and four unchanged N/A cases. Both candidates and references have
22 fixture passes and four N/A; none of the N/A cases is counted as execution.
The source selection and judge match the earlier 04 census described above.
The 06 census took **53.734 seconds**, with **369,242,112 bytes** peak summed
process-tree RSS. Both gates used their own serial resource guard; there was no
nested guard or concurrent target job.

| Selected06 receipt | SHA-256 |
| --- | --- |
| `maintained06/report.json` | `36766ac5a5f435d2448803adcc8e1ffa653e29a32b2529fe6933ba5d2e3edbf8` |
| `direct-conformance06/report.json` | `d72b393a43b564970cc83aa357ff41ec39eadc0f11f1ffc0192fdcfdbae2417c` |
| `direct-conformance06/selected/paired.json` | `75dc4cb5dcc75178611cd81e3beeb5c540fc2f64be612f207eb9966e3a63e349` |

## Independent semantic controls and the retained failure

These controls use independently stated values, errors and event sequences as
well as differential comparison. They cover full returned values and host
boundaries that the scalar benchmark runner cannot express, including BigInt
Nat values, NaN and signed zero, closures, aliasing, ordered getters, effect
registration and CLI output. Upstream programs run unchanged as CommonJS;
direct programs run unchanged as ESM. A host adapter is not a source rewrite.

| Checked emitter | Fixtures / scenarios | Passed | Failed | Gate |
| --- | ---: | ---: | ---: | --- |
| Direct04 | 22 / 64 | 63 | 1 | Fail |
| Direct05 | 28 / 90 | 89 | 1 | Fail |
| Direct06 | 29 / 96 | 95 | 1 | Fail |

The 05 [catalog](../../selfhost/tools/performance/phase52/semantic-catalog-v7.json)
adds 26 successful scenarios for Nat match demand, mixed-arity mutual tail
updates, closure snapshots, dead/erased/live FFI registration and proof-valued
program output. All 28 direct05 source acquisitions completed successfully.
These newer semantic observations belong to checked05; they do not overwrite
or extend the identity of the checked04 maintained-source census.

The 06 [catalog](../../selfhost/tools/performance/phase52/semantic-catalog-v8.json)
retains every earlier scenario and adds six independently checked native-inline
controls. Both the complex-argument and prior-let multiplication cases require
callback completion before the `Math.imul` getter or throwing hook. The
`Nat.double` cases require one argument callback followed by two coercions,
including a throw on the second coercion. The Array.set case checks all four
array elements after a wrapped-index store and requires the returned array to
be the retained public input itself. All six passed against upstream and direct06;
all 29 candidate sources emitted with checked receipts.

The exact 06 run completed all 96 scenarios in **10.967 seconds**, with
**142,954,496 bytes** peak summed process-tree RSS. Its report is complete and
failing overall; the supervisor exited 1. The
[qualified scope](../../selfhost/tools/performance/phase52/semantic-qualified-scope-v2.json)
pins the catalog, controller, checked acquisition, strict role join, upstream
six-control qualification and runtime reports. These observations do not claim
full conformance or renew an earlier maintained census.

The single failing scenario is `f32_table_nan_bits / nan-table-bits`:

| Value source | Observed result |
| --- | ---: |
| Unchanged Bend fixture golden | 40 |
| Pinned TypeScript-generated JavaScript | 1 |
| Direct04, separately observed after the first runner failure | 39 |
| Direct05, observed by the successor runner alongside TypeScript | 39 |
| Direct06, observed alongside TypeScript | 39 |

The 04 runner stopped this scenario when the reference failed its source oracle;
the separate candidate observation preserves its actual result. The 05 runner
observes both roles even when either source oracle fails. It still requires
both source oracles and their differential comparison. Thus the reference's
failure does not excuse the candidate's differing value, and the source golden
has not been changed to make either backend pass.

The separate Node host diagnostic shows that literal `NaN` table values lose
the original payload distinctions, whereas bit conversion preserves distinct
quieted payloads for the tested values. This helps explain the mismatch; it is
not proof of language correctness or a conformance waiver. Its receipt explicitly
sets `passGate: false`. Ordinary arithmetic NaN controls are separate from this
bit-observing signaling-NaN case.

The completed 05 semantic run took **10.061 seconds** and exited 1. Its semantic
report is complete with a failing verdict; the outer supervisor's `complete`
flag is false because the command failed. Neither flag is presented as a pass.

All paths in the next table are relative to `selfhost/build/phase52/`:

| Retained receipt | SHA-256 |
| --- | --- |
| `semantic-direct04-controls01/report.json` | `97401191d543e5a8d4eb9a52d51d08f1ac382a1fbd6b39cee13abf99134e1a93` |
| `semantic-direct04-nan-observation01.json` | `3cbe00c5194c6aefddfd89144a40ff6943e9b5c0158ec89f594383f7790d0802` |
| `semantic-direct05-acquisition01/manifest.json` | `f1f217ea8e7ff4b7404e740a5618b82467aed09859ce03456d1e8c00acb1e2d0` |
| `semantic-direct05-controls01/report.json` | `b366375483a4dbd77650846ed0aeab0bb4afe7fd5668dfe83b674e56afa46bec` |
| `semantic-direct05-controls01-supervisor/run.json` | `f864d974114b92a7bcc9a2f80c790921369775518857ac3541bbd349b60c1e38` |
| `semantic-nan-host01.json` | `73ec40b633bd3f23de225f97c5e5ab906f1c4b1d7f5a675e37cac60154bbadb3` |
| `semantic-direct06-controls01/report.json` | `5357c24a5a1c9623bb25278e0b60e6d4b79b377653a841db08ba088f47485bf8` |
| `semantic-direct06-controls01-supervisor/run.json` | `8215db764ab15d55d62f28691423249e5a1e2695afca5ae7bf8d4011b7669017` |
| `semantic-direct06-acquisition01/manifest.json` | `07e9c6d278c3a20d319afff8f68126c1673680d5e6f3b8eac334c0ab311c44ac` |

## Remaining qualification at this checkpoint

The 06 maintained-eight suite and 26-row JavaScript census are complete and
passing, separately from the 95/96 semantic verdict. Any later selected source
image requires its own fresh qualification. The independent NaN failure remains open. Legacy
regression suites, full-corpus runtime measurements and installation checks are
separate gates owned by the phase report. Counts overlap and must not be summed
as unique tests. No full-conformance, installation or promotion claim follows
from the successful 26-row checkpoint.
