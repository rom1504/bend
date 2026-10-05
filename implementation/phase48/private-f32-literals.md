# Private finite-F32 literal specialization

The isolated compiler change passes its checked build and independent value,
host-boundary and activation controls. A four-point production screen finds an
8.11% speedup on the 1,024-step numeric recurrence and little change on the other
three points. Two of those programs emit identical modules to the baseline.
This candidate is not selected or installed.

## Change and proof boundary

The 35-line [module](../../selfhost/src/back/js/private-float.bend) specializes
canonical finite F32 literals only inside an accepted typed private-region plan.
It retains `floatView.setUint32(0,bits,true)` at the original demand site, then
uses an exact dyadic JavaScript Number expression. It removes the following
native read and decoder call, while keeping all arithmetic rounding operations.

The leaf retains its `F32` identity, so the existing full host guard remains
mandatory. Ordinary literals, public fallbacks, the JW graph and every exponent
255 payload retain their previous decoder. A previously exposed shared view
still receives every write, and a detached view still throws at that write.
The [design and diagnostic result](../../experiments/phase48/P48-007-private-f32-literals.md)
explain why replacing the whole decoder by a constant would be unsafe.

## Qualified identities

| Artifact | SHA-256 |
| --- | --- |
| Baseline array06 API | `28f9eb983b2ba3603a9af703d832d4a301efe32182b468e090db6b728a47d12f` |
| Candidate float01 API | `265fb79712bef04acba399478826f09f1fff51f69ea49f846e686fb72fcb7612` |
| Shared runtime | `880bce50e3194b9ee9d99bd57c18ef88bcb8925d9d1668dec6765040a4d3219b` |
| Shared pinned Base | `c742fae9c49b14f0cc9128429a2c6109364c8a933a142f2c90b9f2e5fd976661` |
| Baseline control module | `476b22bf824e5bad8185f6e7a8efef5de2790b5cc6aebedc5eb543e99671a474` |
| Candidate control module | `b9b7bf00610d3182c8171ee90416c00b559712b1a17f1711098af1142d5f5678` |

The checked build plus selected validation takes 49.973 s. All 36 selected
paired probes pass, with zero exact differences. These selected checks do not
renew the historical full frontend or backend conformance results.

## Independent controls

The actual checked compiler's literal constructor, planner and emitter pass 22
explicit bit patterns: 14 finite values and eight infinity/NaN encodings. Finite
coverage includes positive and negative zero, minimum and maximum subnormals,
minimum normals, neighbors of one and finite maxima. Nonfinite encodings retain
`bitsFloat`; four unrelated literal/nonliteral inputs remain unchanged. Every
pattern preserves its written bits and detached-buffer `TypeError`. This
diagnostic export takes 3.143 s and leaves the production API unchanged.

Checked source emissions pass 408 scalar observations, comprising 204 inputs per
compiler, and 17 paired host/view boundaries in 1.471 s. The source controls
include canonical and noncanonical inputs, runtime infinities/NaNs, zero-demand
behavior, retained shared-view contents, detached buffers, own/prototype methods,
getters, exact sentinel throws and reentry. The [control specification](private-float-controls.md)
separates source expressibility from synthetic nonfinite-literal refusal.

A separate counter derivative witnesses specialized execution in all five
renamed roots: `walk`, `tiny`, `huge`, `negative_zero` and `nonfinite`. A one-step
call executes respectively two, one, one, one and one specialized writes;
zero-step calls execute none. Four own-method/getter/throw refusal witnesses
execute zero specialized writes. The original checked modules supply semantic
observations; the derivative supplies activation evidence and is never timed.

## Production runtime screen and selected paths

The completed `float-screen01` measures four catalog points, three fresh rotated
rounds per role, for 36 passing samples in 28.235 s. It compares array06, float01
and the pinned TypeScript compiler with the same inputs and full result oracles.
Each sample uses a 350 ms warmup, 40 ms calibration target and 150 ms measurement
target under the existing serial resource policy.

| Point | Baseline µs/call | Candidate µs/call | TypeScript µs/call | Baseline/candidate |
| --- | ---: | ---: | ---: | ---: |
| Numeric 256, seed 17 | 13.160411 | 13.031212 | 1.987780 | 1.009915× |
| Numeric 1024, seed 123 | 20.449512 | 18.915884 | 8.108732 | 1.081076× |
| Mandelbrot, `[2,0]` | 121.922923 | 122.240178 | 47.744791 | 0.997405× |
| Symreg, `[6,42]` | 1455.238257 | 1446.530673 | 1102.032911 | 1.006020× |

The 1,024-step point's execution time falls 7.50%; it remains 2.333× TypeScript.
These are medians from short warmed windows, not a statistical significance or
stationarity result. Maximum absolute half-window drift across each role's
three samples is:

| Point | Baseline | Candidate | TypeScript |
| --- | ---: | ---: | ---: |
| Numeric 256 | 0.832% | 2.439% | 12.532% |
| Numeric 1024 | 2.697% | 1.679% | 10.787% |
| Mandelbrot | 1.721% | 18.207% | 2.687% |
| Symreg | 1.078% | 0.165% | 1.044% |

The numeric module grows from 83,393 to 83,830 bytes. Only the complete generated
assignments for `p37.numeric` and `bench` change; restoring those two assignments
reconstructs the baseline module byte for byte. They contain three and four
finite-write sites respectively. The standalone Nat loop and the private scalar
root use the region planner covered by this implementation.

Mandelbrot and Symreg contain no selected finite-write markers. Their complete
modules are byte-identical to the baseline, and their `bench` roots use the
first-order JW worker path, which this slice leaves unchanged. Their near-neutral
timings therefore do not measure an activated specialization. Extending literal
facts into that separate path would need its own integration and qualification.

The [untimed corpus probe](../../selfhost/tools/performance/phase48/controls/private-float-corpus-v1.mjs)
now passes all four exact catalog points. It rechecks 12 full result observations
across the original three roles, then checks the same four full results in
separate AST-scoped counter derivatives. Numeric 256 executes 769 specialized
writes and numeric 1024 executes 3,073: three literals per iteration plus the
initial `100.0` literal. All occur in the private copy inside `bench`; the three
sites in the standalone `p37.numeric` assignment execute zero times during these
calls. Mandelbrot and Symreg have neither static sites nor executed specialized
writes. These derivative counters establish activation and absence without
contributing any throughput samples.

## Evidence and remaining decision

[Compact qualification evidence](evidence/private-float-controls.json) binds 43
rehashed inputs, compiler identities, root job receipts, exact counts and counter
deltas. [Production screen evidence](evidence/private-float-screen.json) separately
recomputes all 12 medians, drift summaries and exact module differences, rehashing
137 consumed inputs and raw sample/process leaves.
[Corpus activation evidence](evidence/private-float-corpus.json) rehashes its 69
inputs and records exact per-site counts and full output agreement. Raw reports are
`selfhost/build/phase48/checked-float01/validation-001/report.json`,
`selfhost/build/phase48/float-ir01/report.json` and
`selfhost/build/phase48/float-controls01/report.json`, with timing in
`selfhost/build/phase48/float-screen01/report.json` and activation in
`selfhost/build/phase48/float-corpus01/report.json`. No raw evidence was edited.

The earlier saved-output screen found write-preserving gains of 1.057×, 1.027×
and 1.180× on three numeric sizes. Those measurements motivated this source
change; their seed schedule and protocol differ from the production screen and
their samples are not pooled. The finite production screen supports a small
numeric improvement, not a whole-corpus speedup or universal parity claim.
