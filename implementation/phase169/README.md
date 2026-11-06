# Phase169 — early verified interfaces in a native self-hosting compiler

Work in progress. The requested target is a complete native self-build in150s
or less. **It has not yet been reached.** Qualified/installed production remains
Phase152. No production source, runtime or selection has changed.

## Measured checkpoint

All native builds use the authenticated prepared Base, original serial QBE
runtime, pinned QBE/assembler/linker and one guarded CPU3 execution lane.
Whole build clocks include compiler execution, bounded streaming into QBE,
assembly and linking. Compiler/QBE overlap is not counted twice.

| Producer → product | Exact input | Whole build |
|---|---|---:|
| Qualified Phase152 → experimental N1 |1,503,932-byte native closure|194.820s|
| Experimental N1 → same-source N2 |same closure|154.376s|
| Experimental N2 → same-source N3 |same closure|156.480s|
| Experimental N1 → canonical compiler |unchanged3,085,157-byte Phase152 source|197.355s|

N2 and N3 reproduce the complete84,506,244-byte QBE stream, assembly and object
bytes exactly. This is a bootstrap consistency result, not a correctness theorem.
The retained canonical Phase152 build took249.222s, but that observation is from
an earlier campaign; a fresh same-source baseline remains to be collected.
Do not compare the smaller native closure's154s directly to the canonical249s.

N1 and N2 both emit the exact independently retained Phase168 verifier QBE and
produce its required768 result. The canonical-source product has the old main
and old algorithms: it is a generated-code transfer workload, **not** another
generation of the experimental compiler. That product emits the exact old
verifier QBE and also produces768.

## What changed

The checked Phase168 route exposes verified callable interfaces before dependent
continuation discovery. Actual forwarders satisfy those interfaces; ordinary
fallbacks, ownership/stack obligations and independent final checking remain.
The new native entry drains its results through the maintained streaming cursor,
using one File for prefix and cursor output. It also incorporates the separately
validated Phase156 publication-provenance improvement, which avoids redundant
canonicalization. That prior improvement is reused, not claimed as a new result.

The canonical product shrinks118.23→94.45MB of QBE and73,926→58,376 functions.
Direct workers remain2,254→2,274;1,150 common direct bodies and the inspected
hot equality/hash readers remain exact. Less duplicated/expanded direct code
accounts for much of the reduction. Static sizes do not prove runtime gains.
See the [source-grounded census](../../experiments/phase169/canonical-product-review.md).

The experimental entry implements the checked single-request QBE protocol.
It does not implement the maintained session/batch commands or establish new
JS/C/parallel/GPU qualification. Source extraction retains the QBE main's
dependency closure; the complete maintained source and other targets remain.

## Transfer and negative evidence

A new469KB workload performs320 real parser/loader/checker calls on ten nonempty
programs, including exact type-error results. Twelve hosted controls compare
complete values against frozen independent Phase156 results and verify the
digest consumer. Eight native runs match the fixed complete output.

Four balanced runtime rounds: baseline median0.362544s, early-interface
candidate0.349252s, ratio0.96333 (3.67% less time). This is one compiler-workload
transfer, not a claim about all generated programs. Its candidate compilation
took42.615s. The first
baseline build hit an underestimated65MiB artifact budget after emission.
Its complete retained QBE was separately rebuilt and output-checked; that
salvage supplies a runtime baseline, **not** a successful whole-build timing.

A separate runtime-only experiment passes126 focused state/output controls.
Disabled runtime flags reproduce the qualified object and ELF exactly; atomic
flags reproduce their atomic control. Two reversed verifier compiler-request
rounds improve only2.15% with both changes. This does not justify treating the
runtime tweak as the main architectural result or changing production.

## Current next tests

Profile the actual N2 compiler on canonical source, preserving exact full output.
Then screen guarded metadata lookups and same-book scalar eligibility reuse:
the existing eligibility query constructs an observer body, so caching its
NO_Plan alone does not reuse all that work. Independent source review found no
semantic blocker, but new records have a cost and exact-QBE/performance gates
must determine whether the candidate is worth retaining. See the
[bounded successor](../../experiments/phase169/admission-work.md).

All completed runs are sealed through verified retention. Old, authenticated
intermediates were archived before selective pruning; executables and current
inputs were kept. The initial implementation checkpoint is453e361. Final
metrics, costs, qualification limits and follow-up findings will be added when
the campaign closes.
