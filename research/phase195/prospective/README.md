# Prospective remainder: modest lexer result, no broad promotion

The isolated generic constant-U32-remainder candidate passes checking and finite
machine controls. Six balanced rounds show **3.17% less lexer time** than the
simpler combined Phase195 candidate; active-ray64 is effectively neutral with
large late dispersion. Retain this as a small experimental improvement, not a
parity mechanism or a native-qualified addition to the maintained combination.

| Ordinary program | Combined median ms | Remainder median ms | After/before |
| --- | ---: | ---: | ---: |
| lexer | 1.025510 | 0.992991 | 0.968289 |
| active-ray64 | 0.184475 | 0.185353 | 1.004758 |

All24 timed full-result/count observations pass. Each role calibrated its own
repetitions for a200ms target; six rounds balance ordering. No confidence interval
is claimed. Lexer before/after ranges are1.015–1.056/0.986–1.005ms. Ray's last
rounds rise markedly for both roles; before/after maximum-to-minimum ratios are
1.383/1.337. Keep that dispersion, do not discard the late samples or advertise
ray transfer. The two-case geometric0.986355 ratio is descriptive only.

Exact observations are selfhost/build/phase195/remainder-runtime01/report.json.
results.json retains every per-case sample, input/receipt hashes and cost rows.
No maintained source, native compiler image, or installed selection changed.

## What actually changed

The actual combined lexer has five literal opcode19 runtime calls. The candidate
replaces four: ident26, num10, expand6 and gen.at6; a decimal-formatting SCC call
remains. Ray's active-loop80 call disappears and its formatter remains. The
initial offline audit incorrectly demanded every literal call disappear; that
refusal and the corrected actual coverage are preserved in
emitted-machine-audit.json. No prototype or output oracle changed for that audit.
Some original scratch argument stores survive, so the ideal arithmetic model is
not the full emitted replacement.

The compiler uses a bounded generic U32 reciprocal certificate and ordinary
integer IR, with exact ABI/count/type and current private-scratch facts. Zero,
one, unsupported reciprocals and destination/numerator alias preserve the old
call. It adds no hidden locals. constant-remainder-v3.bend is the checked source;
remainder-hook.bend is the isolated x185_function_place replacement. Source
snapshot03 SHA256 is86e55f9e2bf261591b9e862f5e75653f28e8271ce5597699adbee56683cfe8c5.
See planned.md for the arithmetic argument and frozen original scope.

## Prediction versus observation

Before runtime, Ivy Bridge LLVM11 modeled the frozen26 arithmetic projection:
2529→242 cycles for100 independent instances; block throughput10→2. The prediction
was directional: faster arithmetic and likely positive lexer effect, magnitude
unknown. It matches the lexer direction but **does not predict its3.17% size**.
The model omits caller packing, runtime dispatch, calls, layout, and whole-program
hotness. The emitted replacement also uses different physical registers/forms.
Exact frozen/model evidence is under ../hardware-models/evidence/prospective01.
The recorded baseline57.034us/5.40% runtime-op profile covers all opcodes, not
just remainder; it is not a causal removed-time measurement.

## Correctness, failures and cost

remainder-api03 independently accepts the full extracted source. Seventeen
recognition/refusal controls and2,640 independent C arithmetic/ABI observations
pass on **each** direct-object and rendered-assembly route. These routes share
Bend instruction selection. Ordinary lexer/ray oracles pass. The independent
Python certificate/IR checks passed294,712 cases; the original exploration also
rejects three arithmetic mutants. These are finite tests, not a backend theorem.

Source01 and02 failed affine capture checks (power/shift and shared facts).
Both failures and unchanged snapshots remain; source03 only adds required `+`
annotations, leaving the arithmetic algorithm unchanged. The checked source and
controls remain isolated from the candidate being broadly/native qualified.

Seven guarded jobs total83.873 seconds, including13.079 failure seconds; maximum
process-tree RSS2,225,967,104 bytes. Every job retains its guard and completed or
failed retention receipt. This excludes research/model labor and is not a
compiler-speed claim. CPU3 was released immediately after runtime completion.
No further target jobs are queued by this experiment.

Start any reproduction from execution-order-v3.json; the original order and argv
remain historical. Do not rerun into existing output roots.
