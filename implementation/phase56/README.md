# Phase56: smaller compiler, qualified direct self-hosting

The direct compiler image now freshly type-checks its complete source and emits
a byte-identical successor. Seven unused legacy helpers were removed. A small,
definition-only native `String.eq` optimization preserves existing call order
and makes self-reproduction finish within the bounded experiment.

The selected checked compiler `checked-string01` is installed and verified.
All **42 legacy + 24 default/relocated interface checks** pass, together with
the eight maintained compatibility suites. The
compiler implementation remains in Bend. Ordinary compilation has no TypeScript
fallback, and the upstream pin remains `018751270e800bc222a93dad7f257083ee53a5f7`.

## Results

| Obligation | Result and scope |
| --- | --- |
| Simplification | Seven dead helpers removed; total change **−40 physical / −32 code lines / −7 definitions** |
| Checked build | **60.70 s**, all **36** strict focused gates pass |
| Direct image generation by checked B1 | **84.43 s**, then eight exact ordinary-driver observations |
| Direct B2 checking its own complete source | **29.68 s** for the check, **35.39 s** overall; all 3,012 expected `@unsafe` definitions accounted for |
| Direct B2 emitting B3 | **250.72 s**, complete **3,896,951-byte** equality with B2 |
| B2 semantic qualification | **96** source, **34** numeric, **18** composition and **2** overapplication observations pass; scopes overlap |
| Equality-specific controls | **484** UTF-16 pairs, **8** evaluation-order/partial/throw cases, native-name and refusal controls pass |
| B1/B2 program equality | All **23** checked benchmark sources and **45** final benchmark points have identical emitted bytes between the two images |
| Program-speed retention | **44/45** points unchanged from host02; changed map/set point takes **15.9% less time** in five fresh paired rounds |

The previous direct B2 exceeded the **300 s** reproduction deadline. The new
result establishes a completed fixed point; a censored baseline does not give
an exact overall speedup. The old full-source check took 55.84 s with V8 profiling
enabled; the new 29.68 s check is unprofiled, so those times are not a controlled
before/after ratio.

Type acceptance, self-reproduction and mathematical proof validity are separate.
The source's 3,012 `@unsafe` definitions cause the expected proof-trust refusal;
this phase does not establish a kernel proof of compiler correctness. The selected
package remains the checked B1 derivative. The emitted B2 is independently
qualified; it is not given a forged checked-bootstrap sidecar.

## Why this change helped

The profile of the original direct image put **17.6% of total ticks** in
`String.cmp` and its recursive helper. String equality was going through that
general comparison implementation. Primitive JavaScript string equality can
compare the same native string domain directly.

The compiler already has a guarded native-primitive table. The optimization adds
one entry and uses the table when emitting a function definition. It deliberately
keeps ordinary `String.eq` calls on the existing call path: expanding the intrinsic
at call sites would introduce argument holds that change callback order in a
composition witness. The accepted change needs no new runtime, cache, IR or
analysis pass. See the [design](../../design/phase56/native-string-equality.md)
and [implementation evidence](string-equality.md).

## Compiler speed and the next bottleneck

The three-role [latency screen](latency.md) uses three rotated fresh-process
rounds on two representative library requests, including type-checking and JS
emission. Primary times include host import and request execution; Bend's base
cache is primed separately. These are compiler times, not generated-program times.

| Input | Pinned TypeScript | Checked B1 | Direct B2 |
| --- | ---: | ---: | ---: |
| Evening program | 0.825 s | 2.566 s (**3.110×**) | 4.581 s (**5.551×**) |
| Lexer | 0.579 s | 1.643 s (**2.837×**) | 2.940 s (**5.077×**) |

The direct self-hosted image is still about 1.8× slower than checked B1 on these
requests. Keep the fast checked build for routine development. The largest
measured pieces of B2 reproduction are emitted reachability (**89.03 s**) and
unsplit library emission (**111.68 s**). These timings identify where to profile
next; they do not prove which internal operation causes the remaining cost.

## Program speed

The only changed benchmark point is map/set operations. Fresh medians are
**20.8518 µs** for host02, **17.5360 µs** for string01 and **20.5952 µs** for pinned
TypeScript. All 15 measured samples pass their output oracle; this point is
**0.851× TypeScript time**. The other 44 points have exactly the same executable
bytes as before. We did not repeat the 669-sample campaign or claim a new full
corpus aggregate. Phase53's dated 1.069599× result remains historical evidence;
its unchanged point results can be retained individually. See [performance](performance.md).

## Evidence and reproducibility

- [Cleanup](cleanup.md) and [source accounting](architecture.md).
- [Direct reproduction workflow and receipts](reproduction.md).
- [Fresh self-check and semantic controls](conformance.md).
- [String optimization, rejected harness attempt and profile limitations](string-equality.md).
- [Compiler latency](latency.md) and [generated-program retention](performance.md).
- [Tools and bounded rerun recipes](../../selfhost/tools/performance/phase56/README.md).
- [Initial design](../../design/phase56/qualification-and-simplification.md).

The [accounting receipt](../../selfhost/tools/performance/phase56/evidence/time-summary.json)
records **49.46 minutes** from 04:12:57 UTC to its cutoff, including **29.12 minutes**
of recorded process intervals and **20.34 minutes** of other elapsed time. Overlapping
intervals are counted once. Other time includes analysis, tools without process
receipts, review, orchestration and documentation; it is not a measured waiting
category. Initial orientation and publication after the cutoff are excluded.

The preservation audits confirm all **103** inherited unrelated files and all
**9,334** files in the closed Phase54/55 trees remain unchanged. The seven files
of the prior installed release are preserved; the existing public legacy ABI and
live bootstrap clients remain supported.

Heavy jobs run serially on CPU3, with a 1 GiB Node heap, 2 GiB process-tree RSS
ceiling and 4 GiB available-memory floor. Agents handle analysis, tooling,
documentation and independent review in parallel. Byte equality avoids repeating
large timing campaigns when the emitted program is unchanged. The baseline
timeout, a bounded profile-processor heap failure and the corrected fixture-loader
failure remain in the experiment record.

The [publication index](../../selfhost/tools/performance/phase56/publication.json)
binds the installed release, interface gates, preservation audits and closed raw
archive. No upstream PR comment is part of this phase.
