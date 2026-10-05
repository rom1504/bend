# P48-007: finite F32 literals under an existing private proof

**Correctness:** checked `float01`, 36 selected exact probes, 22 synthetic bit
patterns, four other refusals, 408 source observations and 17 paired host/view
boundaries pass. **Measurement:** separate three-size saved-output diagnostic and
four-point production screen; production numeric 1024 gains 1.08108× while the
other three points are near-neutral. **Decision:** bounded private slice
implemented and independently qualified; not selected or installed.

## Hypothesis and causal distinction

An already-proved private loop need not read back a known finite F32 value from
the shared DataView after writing its exact bits. Retaining the write preserves
its demand position, failure and observable terminal state. Removing the read
and tiny decoder call may reduce cost without changing F32 rounding operations.

The selected numeric worker repeatedly decodes 3.75, 1 and 1000000. Its paired
upstream output uses literals, but this is not permission to remove our shared
view writes: a previous generic hook can retain the view. The pure-literal
variant is only an unqualified upper bound.

## Root-executed diagnostic result

All 105 finite observations (35 independent inputs × three variants) and 45
fresh timing samples pass. The existing resource supervisor and execution worker
run serially on CPU 3 with Node 24.18.0, a 1 GiB heap, 2 GiB RSS cap and 4 GiB available
memory floor. Each size uses five rotated rounds per variant, 1 s warmup and a
300 ms target. Total controller wall time is 107.101 s.

| Steps, seed 123 | Original µs/call | Write-preserved µs/call | Improvement | Pure-literal µs/call |
| --- | ---: | ---: | ---: | ---: |
| 256 | 13.702 | 12.964 | 1.05695× | 13.821 |
| 1024 | 20.358 | 19.814 | 1.02742× | 19.411 |
| 8192 | 90.620 | 76.814 | 1.17973× | 78.026 |

Write-preserving time reductions are 5.39%, 2.67% and 15.23%. Smaller cases have
overlapping ranges and half-window drift; no significance or stationarity claim
is made. The stronger large-input signal justifies the small production slice,
not an extrapolation to the whole corpus. The pure-literal variant's lack of a
consistent extra win does not make its omitted writes semantically acceptable.

[Compact evidence](../../implementation/phase48/evidence/numeric-constants-screen.json)
independently recomputes all nine medians and rehashes all 45 sample/config leaves
and consumed inputs. Original report: `selfhost/build/phase48/numeric-screen01/report.json`,
SHA256 `7969b8ca9fe7a3cab4675dad380efa0949e13ce8ad4e42792d335380e1b16f2a`.

## Minimal source mechanism

The new 35-line [private-float module](../../selfhost/src/back/js/private-float.bend)
has five definitions. The existing canonical typed region-literal visit creates
a `JF32` leaf with original bits only when its exponent is not 255. That leaf
remains inside a provisional region plan; an incomplete/invalid plan cannot
reach the private emitter. Its name remains `F32`, retaining existing full-host
guard discovery. The successful graph and public input/dependency gates are
unchanged. No new graph traversal, cache or mutable emission mode is added.

The printer emits a comma expression with `floatView.setUint32(0,bits,true)` at
the original demand site followed by an exact dyadic Number expression. Sign,
mantissa and exponent use only integer bit operations in the compiler. Binary32
finite values have at most 24 significant binary digits and all exponent ranges
fit binary64 exactly; multiplying an integer significand by the corresponding
power of two introduces no extra rounding. Negative zero is emitted explicitly.

Exponent 255 payloads, including both infinities and every NaN payload, retain
`bitsFloat`. The frontend currently rejects nonfinite compact literals, so a
source Inf/NaN result test is not a test of this lower-level refusal. A diagnostic
checked-API helper test exercises synthetic KLiteral payloads separately.

The [isolated integration patch](patches/private-float-v1.patch) is based on the
frozen array06 source and changes only region literal planning, private emission,
the flat-plan leaf audit and the module manifest, plus the new module. Its
[receipt](patches/private-float-v1.json) pins before/after source hashes. Generic
`j_word_text`, ordinary JIRWord emission and the original fallback stay unchanged.
The concurrently widened Array audit must admit this proved leaf in its normal
and literal-constructor field walks before combining candidates.

## Root-executed production qualification

The isolated `checked-float01` build and selected validation complete in 49.973 s,
with all 36 selected paired probes passing and zero exact differences. Its API is
`265fb79712bef04acba399478826f09f1fff51f69ea49f846e686fb72fcb7612`.
The runtime remains identical to array06:
`880bce50e3194b9ee9d99bd57c18ef88bcb8925d9d1668dec6765040a4d3219b`.
This is a selected check, not a renewed whole-language conformance result.

`float-ir01` passes 22 explicit bit patterns: 14 finite values, including both
zeros, signed subnormal/normal boundaries and finite maxima, plus eight infinity
or NaN payloads that retain the original decoder. Four additional U32/Nat/String
and nonliteral-F32 inputs remain unchanged. The actual checked planner/emitter
is exposed by an appended diagnostic export; production API bytes are untouched.
Every pattern retains its exact written bits and original detached-write failure.

`float-controls01` uses the reviewed v2 controller and checked emissions from
array06 and float01. All 408 observations (204 per compiler), 17 paired host/view
boundaries and separate activation checks pass. The five renamed roots actually
execute the specialized writes; zero-trip calls execute none. Four instrumented
own-method/getter/throw scenarios execute no specialized write and retain the
ordinary observations. The retained-view case ends at the expected `0.125` bits;
detaching the retained buffer preserves the original `TypeError`.

[Production report](../../implementation/phase48/private-f32-literals.md) and
[compact evidence](../../implementation/phase48/evidence/private-float-controls.json)
record exact compiler/module/report identities. This update independently
rehashes 43 consumed files and checks the recorded counts, boundary equality and
activation deltas. The source-control diagnostic derivative is excluded from timing.

## Qualification scope and remaining measurement

The production `float-screen01` completes all 36 fresh samples in 28.235 s.
Numeric 256 changes 13.160411→13.031212 µs/call; numeric 1024 changes
20.449512→18.915884 µs/call, a 1.081076× speedup or 7.50% time reduction.
Mandelbrot changes 121.922923→122.240178 µs/call and Symreg changes
1455.238257→1446.530673 µs/call. The [production report](../../implementation/phase48/private-f32-literals.md)
gives exact role medians, drift and scope; samples are not pooled with the earlier
diagnostic screen.

Only the numeric module changes: its `p37.numeric` and `bench` assignments contain
seven static finite-write sites. The independent `float-corpus01` probe now
passes all four exact catalog outputs across baseline, candidate and TypeScript,
plus four separate counter-derivative output checks. Numeric 256 executes 769
specialized writes; numeric 1024 executes 3,073. These are three writes per
iteration plus the initial `100.0`, all in the private copy inside `bench`;
the standalone `p37.numeric` sites execute zero times for these calls.
Mandelbrot and Symreg modules remain byte-identical to baseline, with no static
or executed specialization markers; their JW worker roots bypass this region-plan
slice. [Activation evidence](../../implementation/phase48/evidence/private-float-corpus.json)
binds all 69 rehashed inputs. No counter derivative contributes timing samples.

The checks above cover the stated finite values, numeric/view mutations and
host-boundary cases; they are not a universal proof or a replacement for the
compiler's maintained source-dependency mutation suites. Root owns checked
builds, generated controls and clean timing.
The earlier diagnostic ratios are not attributed to the compiled source change.
Historical conformance counts and closed Phase45–47 evidence remain unchanged.
