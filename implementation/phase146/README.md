# Phase146 — retain accepted context across final verification

The retained-context optimization reduces matched full-source native compiler
time **247.353→237.491s (3.99%)**, with identical complete QBE. Four smaller
requests improve roughly2–7%. Native self-reproduction, both focused19 suites
and ordinary45 pass. The new ordinary-native checkpoint is qualified; installed
selection is unchanged.

[Design](../../design/phase146/README.md) ·
[Invariant audit](../../research/phase146/accepted-context.md) ·
[Independent review](../../research/phase146/context-review.md) ·
[Candidate](candidate.json) · [Qualification](qualification.json) ·
[Measurements and cost](metrics.json) · [Evidence](evidence01/receipt.json).

The compiler retains its existing immutable `P114SBoundary` instead of discarding
it before final checking. It reuses the accepted raw/static input and its bound
original-function/constructor IDs. Every actual transformed direct function is
still checked in order, including call dependencies, ABI and both namespace
rules. Rejected openings and prior lowering errors use the original path.
Public verifiers, later final gates, proofs and runtime are unchanged.

The 52-line Bend module changes one original definition. The final source03
adds 207 physical lines including finite controls and a diagnostic ablation,
and introduces no new IR type, cache or runtime representation. Its checked
source is `96c40c9d…ab80`; new private helpers are not general public verifiers.

## Measured evidence

- Genuine source check and 76 finite controls pass. Independent review added
  actual-factory error cases after identifying that some initial differential
  tests bypassed the production fallback. First-attempt missing fixture type
  annotations are preserved as a failed source check.
- Reversible six-entry probes show raw/static verification falling from twice
  to once on all three requests; one original/constructor index rebuild also
  disappears. Direct-function check counts remain exactly 83/133/17 for
  Lexer/Map/closures. All six complete QBE products equal the parent oracles.
- Four checked-hosted pairs pass complete output gates. Their mixed timing
  results are only a screen, not a native speed claim.
- Four alternating native pairs on each of four inputs produce 32 exact QBE
  outputs. The table reports medians and paired geometric ratios separately.

| Request | Parent native | Candidate N1 | Paired candidate/parent |
| --- | ---: | ---: | ---: |
| Lexer | 1.1688s | 1.1339s | 0.9695× |
| Map churn128 | 1.7931s | 1.6578s | 0.9343× |
| Closures256 | 0.3934s | 0.3857s | 0.9772× |
| Actual compiler-index slice | 2.1587s | 2.0468s | 0.9510× |

These exploratory native observations show roughly 2–7% less request time.
They are not confidence intervals or a new upstream comparison. Generated
program runtime is not rebenchmarked; complete emitted QBE is unchanged for
these observed inputs.

The matched full-source pair runs the qualified parent and actual N2 with
identical bounded streaming output comparison, on source03 and prepared Base.
Every one of the117,232,528 output bytes matches the retained qualified-parent
reference. Parent user CPU is241.702s; candidate232.024s. This is one
baseline-first pair without confidence intervals, one CPU3 lane, fresh native
processes and no source-specific reuse; OS caches are not flushed.

These are **compiler-request times, excluding QBE machine construction**. They
must not be compared with historical247s source-to-executable on Phase142 input.
The qualified parent acquired N1 in275.327s through native→QBE→assembler/linker;
N1 acquired N2 in268.311s. Those actual acquisition clocks use different QBE
retention settings and therefore are not the clean speed claim. Runtime, backend
flags and machine objects match; final ELF identity is not claimed.

## Qualified native checkpoint

The final source03 is independently checked, all76 finite controls pass, and
qualified final04 produces N1, which produces N2. Q1/Q2 full-stream size/digests
agree. Actual N2 then emits Q3, literally equal to every byte of retained Q1.
Both native images pass focused19 (16 executions plus3 checked refusals each).
N2 passes all45 ordinary programs. All77 positive suite products match the
qualified parent's complete QBE; their executions match independent frozen
stdout/stderr/exit oracles. No expensive runtime benchmark is repeated for this
code-generation-preserving change; no fresh corpus geometric mean is claimed.

Use `selfhost/build/phase134/p146-context01-n2/program` with the exact source,
runtime and prepared-Base identities in [candidate.json](candidate.json).
The serial runtime still requires `--threads 1 --gpu off`. Final04 remains the
qualified fallback. This does not change the installed selection or broaden
incremental/parallel qualification.

## What this tests

Phase145 witnessed the same immutable raw/static object being checked twice.
This implementation removes that duplicate judgment, and also retains the exact
original-function and constructor ID tables which the first boundary already
built. The accepted object, IDs and successful opening remain in the existing
private carrier throughout the original optimizer. Nothing recomputes a deep
fingerprint to establish request-local identity.

This is narrower than replacing the final verifier with an optimizer assertion.
The public arbitrary-input verifiers are unchanged. The private success path
freshly checks every transformed direct body, ordered callee availability, types,
ABI and array/transport namespace obligations. Source review covers the opening,
commit, inline/range transitions, closing, and the incremental error fallback
caller. A lowering error or failed opening invokes the original final path.
Private helpers accepting IDs cannot safely serve as general public verifiers;
the correctness argument depends on this audited factory/call graph.

No new mathematical theorem is claimed. Parent proof declarations remain exact;
source typing, finite adversarial controls, independent output oracles and native
reproduction establish different properties. We have not qualified arbitrary
parallel embedding, all incremental sessions or another backend.

## Negative and limiting results

1. Initial fixture definitions lacked local type annotations. The genuine source
   check rejected them; source01 and its diagnostics remain in the evidence.
2. Review found that some initial failed-opening controls compared the public
   verifier with itself. Eight supplementary controls now exercise the real
   production factory and error precedence, including raw-before-static and
   prior-lowering-error cases.
3. A one-pair hosted screen was mixed: Map was 2.35% slower while other cases
   improved. It was not promoted as native timing. The native alternating screen
   measures the actual new executable and retains every observation.
4. N1/N2 emit the same complete QBE and identical machine objects, but their
   complete ELF hashes differ. The proposed strict early-fixed-point shortcut
   therefore does not apply. We execute Q3; we do not invent ELF normalization
   rules to avoid this check.
5. N1 acquisition retained QBE while N2 did not. These clocks are recorded as
   actual costs; the separate literal-stream pair supplies matched request
   timing. Historical 247s on another frozen compiler input is not its baseline.

## Architectural result and next experiment

Keeping an existing checked context across a phase boundary pays without a new
IR, persistent cache, runtime ABI or optimization policy. The dynamic evidence
shows which work disappeared. It does not justify assigning the entire historical
18.9-second verifier interval to this saving: transformed-body work remains.

The larger next experiment is the Phase145 **complete numeric-ID verifier
environment**: preserve local identities, separate immutable schema from mutable
flow facts, and include joins, errors, conversion and teardown in the measurement.
Start with the existing actual Lexer body and one unrelated range/registry
consumer. Check native private-worker admission before broadening it. The compact
parser boundary is the alternative if that complete region does not pay.

This small result supports preserving semantic products across phases; it does
not establish 5–10× headroom or recursive research acceleration. Avoid another
major rewrite or full native campaign until the next complete-region proxy shows
a materially larger reduction in real work.

## Reproduction and storage

The [methods guide](../../selfhost/tools/performance/phase146/README.md) describes
composition, source checking, diagnostic counters, native measurements and the
qualification commands. Frozen raw runs live under `selfhost/build/phase146`,
with checked APIs and native coverage under `phase111/p146-*`, and acquisition
under `phase134/p146-context01-*`. Candidate source is composed from qualified
final04 plus the three successful Bend modules; host scripts only orchestrate,
instrument diagnostic copies, compare products or package evidence.

Disk began with about458MiB free. Two fixed allowlists reclaimed archived
diagnostic files only after authenticating complete archive/member identities;
248,217,567 logical bytes remain recoverable. Identical new assembly/objects
share storage after literal comparison, reclaiming another112,057,672 bytes
without losing either path. Current qualified images and oracles are retained.
The [storage audit](../../research/phase146/validation-and-storage.md) records
restore/split commands and the requirement to keep shared products immutable.

The [evidence archive](evidence01/receipt.json) includes checked source, methods,
controls, failures, audits and receipts. Large toolchains, QBE and native images remain pinned local
dependencies, so this is reproducible evidence rather than a hermetic SDK.

Fourteen nonoverlapping guarded jobs take22.58minutes: native acquisition9.09,
measurement/counters plus the combined Q3 comparison10.81, ordinary semantic
qualification2.00, and source/control gates0.68. The one failed source check
costs6.41seconds and is included. Peak process-tree RSS is2.36GB across all jobs;
native full-build/measurement jobs peak about1.08GB. No OOM or timeout occurred.
Metadata work, source editing, archiving and agent effort are separate unmeasured
costs; no token/quota or causal research-acceleration claim is made.
