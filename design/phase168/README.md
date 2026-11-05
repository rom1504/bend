# Phase168 — recover execution quality without rebuilding the old pipeline

Start: Phase167 `85b03b1`, qualified compiler remains Phase152.

The Phase167 observer-first path compiles the real 39,333-byte verifier
computation in 23.351s versus31.343s, but its generated executable takes
0.6554s versus0.4412s (1.485×). Those are fresh-process hosted compiler builds
with authenticated prepared Base, not native full-self-build measurements.
The 249.222s qualified full-build reference is unchanged.

## Hypothesis and bounded implementation

The baseline has ten scalar reader/owned-fallback pairs absent from the early
observer path. Reuse the existing source-authorized scalar plans before raw
candidate admission; produce general observers once; compose scalar readers
only when the real owned implementation passes the existing leaf/fallback
admission. Preserve source permission, actual identities, constructor layouts,
retained-root ownership, stack safety, and independent final verification.
Do not restore all late optimization passes merely to improve a number.

Implementation stays in experimental checked Bend modules. No production,
runtime, upstream, installed-image, or protected-verifier changes. A source
auditor independently inspects generated code; root owns the serial execution
lane. Host tooling only assembles source, transports requests, measures, and
checks fixed outputs; it does not implement compilation semantics.

## Decision gates

1. Check the API source and existing30 malformed-IR plus5 borrowed-projection
   controls. Preserve failed attempts and exact source receipts.
2. Build the same verifier source through baseline and candidate in one checked
   API, each fresh process, identical Base/toolchain and output requirements.
   Report complete source-to-executable cost and frontend/backend/render/machine
   intervals separately. Backend+render is the comparable combined interval.
3. Execute alternating native pairs with exact independent `768\n` oracle.
   Target runtime≤1.10× baseline while retaining approximately25% lower build
   cost. One build observation is a screen; repeat if a promotion claim depends
   on a small difference. Inspect actual restored helpers, not just text size.
4. Only if promising, test frozen Map/IO and closure/sharing/deep-recursion
   semantics and a larger real compiler workload. Full native qualification is
   justified only by meaningful joint compile/runtime benefit and transfer.
5. If restoring scalar composition fails, identify the remaining concrete
   boundary. A bounded canonical recursive computation with explicit resumable
   frames is the alternative; do not whitelist ordinary recursive native calls
   or increase admission fuel. No general rewrite without a cheap falsifier.

The initial scalar experiment is timeboxed around one hour of implementation
and bounded testing, not a promise of a qualified image. Success is reduced
complete work with maintained execution quality, not fewer bytes alone. A
negative result should establish which retained capability is indispensable.

## Resource and evidence discipline

Guard every target job with the maintained disk/RSS/time guard, default5GiB
reserve, CPU3 and one execution lane. Reclaim only individually authenticated
archived intermediates; preserve ELF/source/API/receipts and useful machine
comparisons. Close and archive/verify every run. Keep separate clean timings,
diagnostic counts, source checking, finite semantics and mathematical proof.
Record target-lane cost and failures, without calling it total agent cost.

## Adaptive experiments after the first measurements

The initial mode1 recovers all ten readers but restores almost all construction
cost and remains about1.41× slower at execution. Mode0 retains much of the build
saving but is about1.36× slower. Offline machine inspection finds broad early
inlining embeds old owned scalar bodies inside consumers before reader
replacement. A separate89-line variant therefore prepares only cached eligible
nonleaf scalar fallbacks, excluding future replacement owners from its helper
table. Preserve the first API and its negative result; a new API explicitly
overrides only the experimental `p168_closed` policy boundary.

The registry-only renderer also fails to recover runtime. That narrow negative
does not reject continuation composition: it omits the maintained p134/p124
direct-call/resume path, and the demanded program deliberately marks every
worker private. Consequently the emitter loses an already-verified fact: an
actual source-bound adapter provides a callable boxed ABI.

The next small control uses the same final program with the maintained cursor
renderer. Mode0 retains private flags; mode1 derives renderer-only public flags
strictly from actual authenticated adapter entries, preserving exact bodies,
order and all other fields. First run unchanged all-private `p167ob_final`;
then independently check the flagged copy against actual original headers via
the existing borrowed/direct verifier. No invented certificates or generic
bodies. Compare private/coherent views to isolate recovered callable knowledge.
Both use the same scalar treatment and existing checked live capability. This
tests whether preserving that semantic interface removes scheduler work without
restoring the late optimization pipeline; it is not a new universal IR.

## Final bounded decision

The callable view alone did not recover quality: the registry was already built
without its imports. The final experiment seeds source-bound direct adapters
before unchanged region discovery, preserves the full fusion index, skips only
their redundant candidate preparation and emits real rank-zero forwarders. This
reuses the Phase164 import contract; original private final verification and the
additional public/borrowed-copy check remain mandatory. The matched stock control
reproduces the prior callable-view QBE exactly.

[Final report](../../implementation/phase168/README.md): verifier complete hosted
build31.558→27.759s with roughly maintained generated execution; unrelated lookup
build11.754→7.037s with6.92% slower generated execution. Both fit the runtime
pilot limit, but the verifier misses the original≈25% build-saving target.
The36 added region-named functions are actual import forwarders, not further
discovered workers; all93 direct bodies remain unchanged. This supports earlier
semantic interfaces, not a10× full-build forecast. Test a larger real closure
before native qualification; the qualified/installed compiler stays unchanged.
