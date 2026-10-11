# Checked scalar arrays: Phase68 integration

Design: [checked scalar arrays](../../design/phase68/checked-scalar-arrays.md).
Experiments: [P68-017](../../experiments/phase68/P68-017-checked-scalar-layout.md),
[P68-018](../../experiments/phase68/P68-018-unshared-user-constructors.md).

## Result

The actual checked compiler20 improves the six-family native runtime geometric
mean **5.6816× versus installed Phase67**, leaving **1.7449× upstream C runtime**.
Numeric and array workloads reach upstream parity. This is a six-family screen,
not a claim about every Bend program. The cumulative gain includes earlier
Phase68 worker, product and constructor-packing work; it is not all due to arrays.

Same-source, same-Clang, CPU3, one native thread, GPU off; three balanced rotations
of installed/candidate/upstream roles. All 54 observations pass independent
checksums and the 100ms measured-interval floor. Values are medians in ms:

| Family | Installed | Candidate20 | Upstream | Candidate / upstream |
|---|---:|---:|---:|---:|
| Numeric | 1795 | 252 | 252 | 1.000× |
| Array | 14591 | 184 | 185 | 0.995× |
| Closures | 506 | 403 | 227 | 1.775× |
| Tree | 1877 | 647 | 193 | 3.352× |
| Map | 2386 | 729 | 393 | 1.855× |
| Lexer | 2927 | 586 | 228 | 2.570× |

The array-only development loop measured packed-only compiler18 at
278/278/289ms and combined compiler20 at 172/176/174ms. The final balanced
campaign above is separate. The main mechanism is recovering type/ownership
facts already known after checking: 32-bit storage and direct unshared access
replace generic 64-bit terms and reference-count location lookup.

## Implementation and boundary

`scalar-array.bend` adds a conservative checked-entry certificate. All reachable
array representation demands must agree on scalar elements; unknown sites,
proof transport and unaudited foreign calls refuse it. A separate use analysis
allows multiple uses only for recursively proven array-free trusted Base values.
User ADTs, functions/IO and opaque types decline. Packed seeds cannot introduce
hidden sharing of user objects. Match alternatives use maximum use counts;
parallel operands count together.

Raw `nc_compile` cannot opt in from arbitrary annotations. The new exported
`nc_compile_checked` requires a checked/specialized/annotated book, layout
validation and authenticated runtime/effects. The ordinary host enforces the
pinned Base hash and exact args/print/now handler hashes, and passes the effect
permission. Changed Base or unknown effects retain the generic path. This is a
trusted compiler API contract, not validation of arbitrary calls to that API.

The C runtime centralizes array get/set/swap for both ordinary and product-result
lowering. Creation, leaf extraction and atomics respect 32/64-bit width. Existing
copy/half/show/drop paths dispatch on tags. Uniform whole-program layout avoids
mixed-width node construction. The analysis is general but intentionally
conservative; per-array specialization is deferred.

Compiler20 also includes previously uncommitted Phase68 bounded product-alias
resolution and runtime-template rendering. Those changes were present in the
pre-array compiler17/15 baseline; they are not credited as new array findings.

## Qualification in progress

Completed: checked B1 and exact focused frontend gate; 14 paired native cases;
8 admission/raw/effect-refusal controls; exact JS/frontend driver paths and
2,988 reachable generated functions. Genuine B2 generation and eight ordinary
driver observations pass; this is not a fresh full-source B2 self-check or B3
fixed-point claim. Broader integration and balanced B1/B2 C request timing are
being recorded before this report is closed. Installed Phase67 remains intact.

## Rejected experiment and failures

P68-018 reused the ownership certificate to diagnose omitting eager wrappers on
user constructors. Saved-C intervention passed all 18 observations but yielded
mixed results: tree647→597ms, lexer569→585ms, Map704→710ms (no applicable user
constructors). No production constructor-sealing change was selected.

The first diagnostic preparation stopped because Map had no user constructors;
no target ran. Compiler19 failed bootstrap on a captured linear binder, corrected
with the explicit duplicable binder in compiler20. An annotation inspection
initially used the raw positional API instead of the maintained ABI adapter;
that failed inspection was preserved and rerun through the actual driver.

Raw receipts are under `selfhost/build/phase68/`: scalar-build20,
scalar-build20-b2, scalar-controls20, scalar-admission20,
scalar-js-closure20, scalar-native-comparison20, user-seal-diagnostic01/02.
Durable evidence and final compilation/complexity results follow on closure.
