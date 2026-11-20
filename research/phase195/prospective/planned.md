# Prospective constant unsigned remainder

This is an isolated, **unchecked** Bend candidate, not a maintained change or a
performance result. It targets remaining literal U32.mod calls after the simpler
Phase195 combination. No compiler, generated program, benchmark, or model was
executed by this investigation; source extraction, objdump and Python arithmetic
checks ran on CPU0. The independent model owner has frozen the supplied inputs.

## Actual machine witness and expected scope

Both authenticated Phase194 and combined lexer have five opcode19 calls, with
literal divisors26,10,10,6,6. Combined ident packs two arguments at408ae6–408b04,
sets opcode19 at408b0b, and calls at408b2c. Runtime41cbea–41cbf1 executes
`mov eax,r12d; xor edx,edx; div ecx; mov r12,rdx`. Exact caller excerpts, full
runtime disassembly, ELF hashes and the static six-case census are retained in
constant-remainder-evidence.json and the adjacent .asm files.

The existing recorded baseline lexer profile puts57.034us/invocation (5.40%) in
all p111_rt_op, with a hot sampled PC immediately after DIV. This is not a cost
measurement of just remainder, not the combined profile, and not an upper bound
including caller argument packing. No dynamic call counts exist. The simple
combination retains this concrete arithmetic boundary. Numeric has three
literal97 call sites and ray an80 site; most other surviving decimal10 sites
are formatting/SCC helpers, so static six-case occurrence is **not hot breadth**.
Literal97 is deliberately refused by this simple certificate if it needs an
oversized reciprocal; broad applicability is conditional, not demonstrated.

A compiler-wide primitive improvement transfers beyond a named lexer source,
but present evidence supports a modest lexer opportunity, not parity-scale
whole-suite gain. Freeze the directional prediction: positive arithmetic gain
for26 and likely positive lexer effect, magnitude unknown. A cheap lexer screen
is warranted; a full compiler rebuild is not justified by this proposal alone.

## Certificate and implementation boundary

constant-remainder.bend computes a generic reciprocal with at most32 bounded
U32 steps. For m=ceil(2^(32+s)/d), it admits m<=2^32-1 and
`e=m*d-2^(32+s)<=2^s`. Then for every n<2^32 the added quotient error is
`n*e/(d*2^(32+s))<1/d`, smaller than the distance to the next integer quotient.
Therefore floor(n*m/2^(32+s))=floor(n/d). The U64 product cannot overflow.
Construction uses only U32 arithmetic; there is no huge unary-Nat calculation.
Divisors0,1,7 refuse unchanged;6/10/26 admit. Other failures preserve the call.

Recognition requires the original exact ABI11102 opcode19/count2/U64-result
call, authenticated state local, and both current U64 scratch-cell facts.
Unknown buffer facts, alias escapes and control boundaries use the existing
scratch invalidations. Destination equal to numerator refuses. No new local
names are introduced: the original result name carries five ordinary integer
operations ending with a canonical U32 publication. The original scratch stores
remain available for the existing private-memory pass to prove dead; this pass
never deletes observable stores itself. Existing verifier/error paths and all
other operations remain unchanged.

The isolated source hook wraps the body entering x185_scratch_body with
x195rem_body. This can increase row pressure and produce worse placement; actual
emitted code must be inspected. The reserved-r10/r11 model input is an ideal
arithmetic projection, **not yet confirmed emitted code**. It excludes real
call/dispatch/packing and layout, so its ratio cannot predict whole-program time.

## Independent checks and prepared gates

check-remainder-certificate.py passes294,712 arithmetic observations across2,379
divisor trials, including full-width edges, quotient boundaries and contaminated
upper words. It checks the actual bounded-U32 certificate and compares simulated
five-op IR results with Python `%`. The earlier endpoint-certificate exploration
passes110,125 observations and rejects wrong shift, wrong magic and missing
truncation mutants. These are finite arithmetic checks, not Bend acceptance,
emitted-code validation, or a compiler theorem.

The source-only prepared manifest is
selfhost/build/phase195/remainder-api-source01/manifest.json, derived from the
exact combined-api-source01 snapshot. It replaces only x185_function_place.
Acquisition and controls argv are here, **unexecuted**: acquire-argv.json and
controls-argv.json. Each declares a120-second,96MiB guarded job and3GiB RSS;
root owns admission/CPU3 execution. The prototype source must independently pass
checking before any product request.

Seventeen checked structural controls cover actual call recognition, near-op,
arity/state/symbol/width, missing/dynamic/high-word denominator, zero/one/seven
fallback and destination alias. The emitted controls pair actual old/new
functions for ten modes, use the existing pinned runtime for the old call, and
check2,640 independent C `%`/ABI observations per direct-object and assembly
route. They include noncanonical high words, zero remainder's full-word identity,
bit31, all-one words, live salt across the original call, state preservation,
and destination-alias fallback. They have been prepared, not executed.

Next falsifier: after these gates pass, emit the ordinary combined lexer with
only this added candidate; require all five supported remainder calls to vanish
and no DIV in those replacements. Inspect register/row-pressure effects and
then compare complete lexer output plus a short paired screen against combined.
If it loses or shows no material repeatable gain, retain the negative and stop.
Do not infer success from arithmetic/model/static-count improvements alone.
