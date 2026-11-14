# Phase193 bounded ownership frontier

Read-only source, retained-profile and ELF investigation at dc413be. No target,
compiler, sampler or benchmark was executed; no production source was changed.
The proposed change is unimplemented and unmeasured.

## Best narrow candidate: retain checked constructor identity through take

The ordinary source match factory already knows constructor identity and field
count, but `p185pt_previous` in `back/qbe/packed-take.bend` discards identity for
multi-field takes and emits generic `p111_rt_take`. Final verified lowering uses
`p125_rt_takeN`, whose constant field count is known but whose runtime CID and
arity-table checks remain. `region-admission.bend:p112m_original_match_apply`
places this take directly in the successful `p111_test` branch. The common
factory is `lower.bend:p111_take`; the same structured IR reaches x86 and QBE.

Smallest candidate: preserve a checked match/layout certificate to select a
shared take-N entry that skips only already-established CID/arity checks. Keep
its tag check, ordered field copies, RFC/view/count paths, static-location
check, free-list insertion, handoff and returned count exactly. This avoids the
per-call-site body expansion that failed in Phase186. A raw name/count pair is
not sufficient authorization: the final verifier must validate the actual
constructor metadata and the true-edge relation to the unchanged word. If
certificate transport proves disproportionately complex, use expected-CID
comparison with original-helper fallback; that preserves behavior for arbitrary
mismatching words, at the cost of an extra argument and branch. Do not create
an unchecked public runtime entry or infer uniqueness from successful matching.

This is a limited guard-elimination hypothesis, not elimination of allocation,
RC or an entire product. It ranks below a proven complete producer/consumer
elimination if another audit establishes such a hot boundary.

## Actual physical evidence

Retained `selfhost/build/phase192/selected-build01/tree-bitonic/machine/program`
contains `p125_rt_take2` at 0x421b50. Its exact entry executes:

- +0x09 SHR40, +0x0d MOVZX16: reconstruct CID;
- +0x14 load p111_program_active;
- +0x1b compare constructor_count, +0x1f branch;
- +0x33 load cid_arity, +0x3a compare byte to 2, +0x3e branch;
- +0x40 onward check tag, then perform actual field/ownership work.

The first eight named instructions re-establish metadata already available at
ordinary successful match sites. They are not all necessarily removable from a
new shared implementation: the active descriptor is also used by the later
static-heap-boundary calculation.

Read-only aggregation of the two retained profile02 periods, using every sample
(including unknowns) in each denominator, yields:

| Exact role | All weighted sample us | take2 weighted us / share | Named eight metadata PCs weighted us / share |
|---|---:|---:|---:|
| tree candidate | 5,953,000 | 782,000 / 13.136% | 311,000 / 5.224% |
| expression candidate | 5,716,000 | 577,000 / 10.094% | 108,000 / 1.889% |
| lexer candidate | 5,640,000 | 717,000 / 12.713% | 34,000 / 0.603% |

Algorithm: glob `profile02/*<case>-candidate-candidate/analysis.json`, sum
`header.samples * header.period_us`; select `pcs[].symbol == p125_rt_take2`,
and for the last column offsets {9,13,20,27,31,51,58,62}. The take2 entry sequences
have the same relevant offsets in these exact products. PCs can reflect earlier
work and sample counts are sparse; these are descriptive attribution, not a
causal ceiling, removed-instruction count, speed prediction or hit-frequency
measurement. The existing profile admission/unknown limitations remain those
in `research/phase192/post-h-profile-assessment.md`.

The actual N2 compiler ELF `selfhost/build/phase192/native-self01/program` has
2,374 static direct call sites to p125_rt_take2 (objdump text followed by exact
call-target count). That establishes actual compiler applicability, not compiler
hotness. A same-request compiler screen remains required before claiming a
shared compiler/user benefit. No new whole-compiler profile was acquired.

## Runtime semantics and current alternatives

`runtime/qbe/runtime.c:4936` defines P125_VERIFIED. Constructor entries omit
already-verified metadata checks, but still allocate and apply the capability-8
cold-versus-hot publication rule. `rfc_seal` wraps raw CTR children; arbitrary
elimination can change later ownership behavior. Cold allocation is already
expanded by `back/qbe/cold-constructors.bend`, and x86/scalar.bend consumes that
same expansion. Merely proposing constructor inlining duplicates existing work.

`ctr_take` at runtime.c:1074 first copies fields in order. For raw CTR it returns
the source location. For an RFC wrapper it views the count, copies its fields,
frees a count-one wrapper and returns its payload; shared cases call span_fade
and return zero. `spare_free` only frees dynamic locations; heap_free preserves
allocator handoff. Packed one-field constructors already have a checked fast
path in packed-take.bend. Neither tag nor matched CID establishes raw uniqueness,
and a heap wrapper can refer to static data. All of those distinctions remain.

A successful source-level constructor match normally eliminates the arity
failure, but arbitrary N111 calls still need the original exact failure route.
Restrict a new lowering to certified matches, or guard and fall back. Preserve
original read-before-write behavior if the destination aliases operands and
ordered output copies for overlapping buffers. No native recursion is introduced,
so stack safety can remain the existing local-continuation contract.

## Negative evidence and stop rule

`experiments/phase186/P186-004-unique-take.md` records two rejected blanket
unique-take templates. V1 copied the fallback four times, increasing tree text
12.07% and Map text 23.16%; independent tree/Map IR comparison isolates its
regressions. V2 kept only one fallback but still regressed tree 8.90%, Map 15.27%
and record 13.01%. Its guards, static-boundary computation and free-list work
remained, plus caller register pressure. Do not repeat that experiment under a
new name or promise gain from the full take helper share.

First falsifier for the narrower proposal: actual emitted calls must remove the
metadata-table dependence without expanding every call site into the old inline
body or enlarging caller frames materially. Then ordinary ownership controls,
shared/static/packed paths and certificate rejection controls must pass. Require
one real compiler request and two unrelated user computations to improve in a
serial paired screen before broader qualification. If only the tree improves,
or compiler work/call-argument cost offsets the saved checks, reject rather than
adding a global analysis pass to rescue the idea.
