# RNFA F32 composite boundary controls

Qualified root-owned RNFA03 composition controls pass 50 value observations and
five paired boundary scenarios. This agent executed no Node or target job.
Existing composite controls cover U32 handles; finite-float controls cover scalar
results. This addition exercises their actual composed F32 handle boundary.

`selfhost/tools/performance/phase48/controls/composite-float-v2.bend` returns a
flat FloatParcel with two owned Array<F32> fields and scalar last. A self-tail
swap loop replaces left cells with 0.25 and writes rounded(old+0.125) into right.
The fixture destructures computed read/swap pairs only in separate function
parameters. Array.new supplies four cells per array; inputs are scalar U32/F32.

The catalog's main=0 is only a checked acquisition anchor. Controller
`composite-float-controls-v3.mjs BASELINE CANDIDATE NEW_OUT` binds source/catalog,
checked emission receipts, upstream commit, output paths/hashes, producer/Node,
and rehashes inputs before success. Baseline is checked array06; candidate is
RNFA03 or its qualified successor. No TS comparator is needed for this untimed
independent semantics check.

There are 50 scalar-oracle observations (two roles, five counts, five F32 seeds),
including signed zero and smallest subnormal. Separate operations round through
captured Math.fround; deep strict equality preserves signed zero. Every case
checks public tags/fields/prototypes, distinct arrays/backings, fresh record and
handles per call, post-return JS/native mutations, and isolation of another
returned result. Five paired complete-trace boundaries cover injected same
handle, shared backing with distinct handles, native swap-code getter, allocation
throw and allocation reentry. Shared-handle tests deliberately mutate native
allocation and therefore validate generic fallback; selected-path affine output
contains distinct handles. No selected-path duplicate-handle claim follows.

A separate Acorn-based derivative finds complete G assignments and inserts
composite fast/fallback counters and finite-literal write counters. Clean zero
and one calls must each actually enter the composite branch; zero call must write only initial0.0 once; one iteration must write initial0.0,
swap0.25 and addition0.125 exactly once each, verified by separate bit counters.
Each finite marker must precede the corresponding AST floatView.setUint32 call
inside the complete make assignment. Every host boundary must
refuse that branch and enter fallback. Exact modules provide semantics; this
altered derivative is never timing-eligible. Successful scenarios reject caught
assertions, preventing identical oracle failures from passing differentially.

The executed qualification below supplies checked acquisition and dynamic
activation evidence. These controls do not supply a performance claim.

V1 controller is preserved. Reviewer hardened v2 to distinguish each finite
literal demand, reparse the derivative before import, and pin/rehash its bytes.
No Node syntax check or target was executed by this agent.

Independent review: phase44_ir static PASS on fixture/type premise and v2
controller SHA256 `115a8accf2277cf22089ac561131e95c00ad03139aeb5573ae39e15ca16ad30b`.
That review preceded the executed qualification recorded below.

## Preserved frontend failure and corrected fixture

The first baseline acquisition failed checking, not candidate compilation:
`selfhost/build/phase48/composite-float-baseline01/modules/composite-float-v1.mjs.json`
records typeAccepted=false, phase=check, and old consumed more than once in
floatparcel.finish. Tuple fields are affine even when their scalar type is F32;
v1 incorrectly used the destructured old both in F32.add and as a result field.
This is a fixture defect, not a production semantic failure. V1 source/catalog
and all earlier controllers and failed receipts are preserved.

Source v2 forwards old exactly once to floatparcel.end's explicit +old:F32
formal parameter. That helper may reuse the scalar for addition and last-field
return. No array is duplicated; both owned handles still appear once. The
recurrence, literal demand, all 50 value oracles, five boundary scenarios and
exact private-entry/F32-bit counters are unchanged. Catalog v2 pins source v2;
controller v3 changes only its catalog/usage reference from reviewed controller
v2. Fresh root-owned acquisition and qualification then passed as recorded below.

## Executed composed-path qualification

Root job `selfhost/build/phase48/job-composite-float03v2/process.json` passes in
1.124031449 seconds, return 0, peak process-tree RSS 208,203,776 bytes. Exact
report `selfhost/build/phase48/composite-float-controls03v2/report.json` has
complete=true/passed=true, SHA256
`5058cc0ddf95d71980e7fd686e6d5d9f2ca295f6042dc0affc1223e26d3b6c7d`.
All 31 recorded input identity rows were rehashed during this data-only update.
Consumed source v2 SHA `32cf077b3c20fd928fc631a812e6dc693bb27269e4935d56c77de564eca69209`;
controller v3 SHA `b364e079758564ee96337cfa17e3451b73e020e29543790fcc6919843019f358`.

The baseline module SHA `8bfc48b0105eaa408c19aadfe273689104a16fa5552e942cb841b308bebf795f`
is emitted by array06 API `28f9eb983b2ba3603a9af703d832d4a301efe32182b468e090db6b728a47d12f`.
Candidate module SHA `6de9616a083f826a59a53ea74d07df5a39480340fdde9806cd4ad2dc62fb35b8`
is emitted by RNFA03 API `a64c4dceb00f60c7cdb9994afb864564f4ff9a9c8b1c143b066db793b9ba738b`.
Both receipts bind exactly the same corrected source.

Executed derivative observations, separate from untouched-module value checks:

| Observation | Composite fast delta | Fallback delta | Finite-write delta |
| --- | --- | --- | --- |
| Clean n=0 | 1 | 0 | 1: +0 bits 0 once |
| Clean n=1 | 1 | 0 | 3: +0 bits 0,0.25 bits1048576000,0.125 bits1040187392 each once |
| Injected same handle | 0 | 1 | 0 |
| Injected shared backing | 0 | 1 | 0 |
| Native swap-code getter | 0 | 1 | 0 |
| Allocation throw | 0 | 1 | 0 |
| Allocation reentry | 0 | 3 | 0 |

Final cumulative counters are fast 2 / fallback 7 / finiteWrites 4, with bit counts
0→2,1048576000→1,1040187392→1. Eight static guarded finite-leaf sites exist
inside the complete make assignment; site count alone grants no activation.
The actual zero/one deltas distinguish initial literal demand from swap/add
literal demand. The derivative SHA is
`63dc71d126767be51e352ff1f7ae96a1b062d379f0cb854f7e62e4ac0c81e8de`
and remains timingEligible=false. Independent assertions check signedzero;
ordinary JSON numeric serialization does not preserve a signedzero bit trace.

The 50 exact-module value observations pass distinct handle/backing identity,
freshness after repeated returns, post-return mutation, signedzero/subnormal
values and rounded recurrence. Five complete paired boundary comparisons pass.
Shared-handle injection proves fallback identity preservation only, as scoped
above. Source v1's actual affine checking failure and its receipt remain preserved;
the corrected v2 qualification does not erase it.

Compact exact activation evidence is saved in
[evidence/composite-float-qualified.json](evidence/composite-float-qualified.json).
All full RNFA03 acquisition and core8 screen outcomes belong to the integration
campaign; this independent control qualification does not select a release.
A possible literal-profitability successor remains pending root selection.
