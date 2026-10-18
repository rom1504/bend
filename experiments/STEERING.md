# Current frontier: Phase108 full native compiler through QBE

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
