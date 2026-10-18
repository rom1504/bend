# Current frontier: Phase110 structured runtime ownership and canonical calls

[Report](../implementation/phase110/README.md) ·
[Design](../design/phase110/ownership-laws-and-search.md) ·
[Frozen experimental selection](../implementation/phase110/selection.json) ·
[Fast loop](../selfhost/tools/performance/phase110/README.md).

The direct path keeps checked types, closed owning callees and ownership
operations until Nx lowering. Canonical String/List<String> entry admission,
ordinary calls, typed transfers and explicit private runtime IR are implemented
in Bend. Shared/static cases retain production runtime fallback. Native-source05
passes actual request and worker qualification. Its live general command derives
the checked request internally; arbitrary caller-supplied seed/certificates are
not trusted. Generic specialization, arbitrary datatypes, closures, effects,
scheduling and device execution remain outside this slice.

Frozen selection: simpler compact-general QBE runtime profile. Eleven fresh
reverse held-outs take0.8051× unchanged fused-QBE worker time; wrapper-spare Clang
control takes0.6582×. QBE has four small individual regressions, maximum1.0221×.
A separate five-round matched reverse kernel takes0.8531× preserved production
Clang time. These are not full-compiler, upstream or broad45 ratios. More complex
QBE refinements failed the frozen3% incremental-benefit/round rule and remain
experiments. Fewer instructions did not reliably mean faster code.

The fixed-policy transfer check improves actual compiler nt_append medians, but
regresses non-tail recursive Base String.append5–16%. The separate
[P110-002](phase110/P110-002-context-boundary.md) experiment retains public checks
and removes repeated context getters from private calls. It uses about10–15%
less QBE worker time on two reused append inputs, with all18 semantic workers
passing. Threading borrowed pointers and loading them from the context have
different register costs; neither is universally best. These diagnostic results
do not retroactively change the frozen image or supply a fresh fused denominator.

Twenty-three independent local laws,14 well-typed model mutants and2 actual
compiled-consumer mutants provide complementary checks. Physical runtime/layout,
separation, writer and single-context premises remain explicit. Laws do not prove
whole-compiler or machine correctness. Typed/call admission and source provenance
are separate from owning-credit checking.

Full native acquisition initially timed out on the new75KB Base literal.
Packed exact U32 comparison preserves every codepoint and length while avoiding
the observed static-image representation cliff. Minimal emission drops from
>45s to4.825s; complete source05 acquires in148.836+87.720s,3.086GB peak. Ordinary
direct requests use noJS/Clang/cproc; one-time acquisition still usesC/cproc/QBE.
The full-language Phase108 path and installed production selection stay intact.

Use the1–2s checked API, focused ownership controls and cached worker binaries
before full acquisition. Observed worker execution is only~3% of the diagnostic
evaluation loop; improving it alone cannot materially accelerate that fixed loop.
Measure the real critical path before claiming recursive self-improvement.
Build→Take cancellation has no demonstrated retained opportunity in the present
lowering; preserve/integrate owning-call structure before adding a dead pass.
Next: qualify context-boundary handling across more real compiler callees, then
carry ownership operations into scanner/allocation kernels. Do not pay another
full image acquisition before the smaller transfer gate supports integration.

Root owns serial CPU3 target work; agents prepare and review offline. Preserve
failed receipts and frozen gates. Full native acquisition needs4GiB tree cap and
16GiB free-memory floor. Disk cleanup must authenticate archived bytes first.
Phase105 remains the last broad production B1/B2/upstream measurement. No PR
comments without explicit user instruction.

# Previous frontier: Phase109 direct ownership IR and native selected-library frontend

[Report](../implementation/phase109/README.md) ·
[Design](../design/phase109/direct-owned-ir.md) ·
[Usage](../docs/self_hosted/OWNED_NATIVE_IR.md) ·
[Fast loop](../selfhost/tools/performance/phase109/README.md).

Direct structured IR is the development direction. Keep Phase108 cproc/QBE as
the working full-language bootstrap/reference; do not delete it or replace the
selected production compiler before full direct-IR semantic/bootstrap gates.

Actual compiler List<String> reverse, Base String reverse and checked
discard/duplication bodies lower in Bend from mature NativeErasedBody facts to
owned operations and an Nx library. Imports use the actual tagged-Term heap and
reference counts. Ownership verification, exact fixed-descriptor admission and
generic consume/build/tail fusion are implemented. Shared/static/retained-alias
and lifetime controls pass; unsupported constructs refuse.

The native selected-library image reuses the full mature checked frontend and
erasure. Nine source-contract/policy QBE products equal hosted outputs exactly;
live Base, IR JSON, four refusals and a fresh thirteen-case native worker pass.
Its one-time C/cproc/QBE acquisition takes about 150 s. Ordinary selected requests
use native Bend directly, ~0.53s prepared in finite qualification observations.
It accepts frozen source contracts only: arbitrary typed ABI/layout admission,
ordinary/non-tail calls, closures, effects, scheduling and GPU remain unimplemented.

Five-round worker screen: raw direct QBE 4.78× production Clang time; trusted 1.68×;
fused 1.39×. This is one 65,536-cell reverse kernel, not upstream/B1/B2/full-compiler
speed. Fused is 3.45× faster than the initial direct IR worker. QBE and Clang of
the same imported-runtime graph are close: preserve constructor constants and
typed multiple-result ownership transfers before changing machine backends.
Production reverse already has a direct loop; no trampoline-removal gain here.

Use the 1.4 s checked API, 10 s semantic suite and 19 s paired screen for routine work.
Next coverage gate: general checked descriptor/entry facts and ordinary calls,
then scanner and genuine continuation-heavy kernels. Keep runtime acquisition
separate from cached worker builds. The cproc kernel control lacks Phase108 v3
accessor expansions; never substitute it for that full compiler denominator.
No broad45, production B1/B2 metric update, or recursive-acceleration claim.

# Previous frontier: Phase108 full native compiler through QBE

[Report](../implementation/phase108/README.md) · [Design](../design/phase108/full-native-qbe.md) ·
[Usage](../docs/self_hosted/QBE_COMPILER.md) · [Fast loop](../selfhost/tools/performance/phase108/README.md).

The full compiler now runs through Bend C lowering → cproc → QBE with a portable
CPU trampoline. A full self-emission matches all 30,396,376 bytes of the trusted
parent's adapted output; no bridge is required for self-emission. This is distinct
from the still-scalar direct Nx path below. No Clang/Bun runs on ordinary requests
or current QBE image acquisition; the initial native seed is historical.

v3 uses a one-pointer segment ABI and five exact scalar accessor expansions.
Six-source native compiler requests remain 3.22× the selected Clang-built B2;
full self-emission 338.89s versus the parent's 144.39s (explicit runtime-template
adaptation). Image machine build 60.42s. These are not upstream TypeScript or
generated-program runtime ratios. The rebuilt successor passes frozen, real-output,
calls5 and live-Base gates; its separately screened request ratio is 3.34× with
identical executable text. Installed production selection stays unchanged.

Next performance opportunity: runtime helper inlining/optimized runtime ABI.
cproc/QBE does not inline C helpers. Preserve full-output equivalence and ownership
semantics; use the six-source/frozen controls before another full self-image.
The first 2 ms sampler lost half its events to timer granularity; do not cite its
fractions as quantitative evidence. Full builds need 4 GiB process-tree cap with
16 GiB free-memory floor. Keep timed/large target work serial on CPU3.

# Previous frontier: Phase107 native source → IR → QBE

[Report and diagrams](../implementation/phase107/README.md) ·
[Design](../design/phase107/native-ir-ambition-ladder.md) ·
[Fast loop](../selfhost/tools/performance/phase107/README.md) ·
[Compiler usage](../docs/self_hosted/NATIVE_IR.md).

The three-hour campaign started 2026-10-18 at 06:37UTC, with consolidation reserved
before 09:37UTC. User authorized ambitious alternatives to Clang, commits and pushes;
no PR comments without explicit instruction. The installed general compiler and
selected release remain unchanged. The new route is an experimental native compiler
written in Bend, accepting a stated first-order scalar source subset.

Ordinary requests perform native Bend parsing/checking, checked-KTerm lowering,
shared Nx optimization and QBE emission, then QBE/GNU assembler/GCC-driver linking.
No Bun or Clang runs on that request path. The frontend image's one-time acquisition
still uses the existing C backend and Clang (375.367s). Full Bend data/ownership,
closures/scheduler/device runtime and QBE self-hosting are not implemented.

## Established results, with separate denominators

- Eleven admitted source families and six declared unsupported families. Frozen
  held-out GCD, non-tail triangular recursion and saturating arithmetic pass six
  raw/fast builds and 196 exact independent results without post-freeze adaptation.
- Complete source-to-executable comparison on three initial sources: native QBE
  0.376–0.390s versus installed native C/Clang0.584–0.624s, or34.6–37.5% less wall.
  Three alternating rounds, fresh objects, prepared Base. Excludes tool/image
  acquisition; not upstream B1/B2 parity or a full-language result. A separately
  frozen three-source held-out comparison then gives36.4–38.6% shorter compilation
  (0.627× geometric mean), with 18 fresh builds and exact independent outputs.
- General tail conversion/inlining/reachability bring the 128-helper IR kernel to
  about raw-Clang runtime with QBE/Cranelift, roughly5× faster than their raw IR.
- Memory forwarding alone was insufficient. Closed-allocation scalar promotion
  gives QBE a2.65× shared-workload speedup, reaching1.26× raw-Clang time. Further
  scalar constants reduce Cranelift time30.8% versus promotion alone by removing
  a hot-loop spill. QBE gets no meaningful additional gain. Synthetic memory IR
  does not prove production reference-count/ownership lowering.
- Boundary verification removes repeated public-pass checks: identical warmed
  JS128-helper pipeline0.890s versus 8.627s. Native IR-kernel complete requests
  are much cheaper than JS hosting; these are different clocks from source builds.
- Constant multiplication is optional: paired recurrence gains coexist with a
  QBE text regression. Compare actual executable text and alternating timings;
  do not credit batch noise on unchanged binaries.

The fixed native source image04 uses its recorded simpler `fast` policy. Newer
shared-kernel policies are experiments, not silently installed in that image.
Source, ABI, model, native, mutation and local-law evidence remain separately
labelled in the report. The IR verifier is structural/type checking, not an
ownership or whole-compiler correctness proof. Capacity/refusal boundaries matter.

## Best next architectural step

Follow [the source lowering boundary](../implementation/phase107/next-lowering-boundary.md):
real `nt_reverse<List<String>>`, then unrelated `String.reverse.go`, before the
allocation-heavy scanner. Reuse checked erasure/layout/call decisions before
existing C-string formatting. Specify a versioned runtime import/context ABI and
cached runtime object, including ownership/alias and lifetime behavior.

Do not treat the synthetic calloc/free contract as the production tagged-Term
heap/scheduler contract. Preserve dynamic/unknown fallback. Closures, higher-order
calls and general mutual tail calls need their own ABI/admission gates before
attempting the complete compiler. A direct x86 backend or JIT is not required to
learn this semantic boundary; QBE and Cranelift already remove Clang from object
construction in the admitted slice.

Measure a real compiler subset before more scalar tuning. Native IR kernels make
optimizer changes cheap to test. Freeze independent expected outputs, test invalid
admission/negative controls, inspect generated assembly, then run the broader
13-program backend screen. Full frontend image acquisition is justified only by
frontend/runtime integration changes, not every shared-pass edit.

## Resource and evidence discipline

Root serializes timed/large target work on CPU3 with process-tree guards. Offline
agents prepare and review disjoint source/docs. Keep failed attempts and source
snapshots; no broad45 or full-self reruns for additive IR experiments. Disk is
constrained; evidence capsules are bounded and streamed. Accounting distinguishes
guarded occupancy from uninstrumented wall time and actual billing/quota data.

[Phase105](../implementation/phase105/README.md) remains authoritative for production
B1/B2 versus upstream: prepared45-program0.499×/0.517×, live-Base2.384×/2.231×,
full-source prepared2.602×/2.965×. Phase107 does not update these ratios or selected
compiled-program/conformance metrics. No recursive research acceleration has been
established. The 1×/10×/100× design labels scope, never measured speedup factors.
