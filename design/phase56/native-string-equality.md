# Definition-only native string equality

The first direct B2 self-emission exceeded its 300-second deadline below 1 GiB
RSS. Its emitted-reachability phase took 124.8 seconds, compared with 21.9 seconds
in the prior B1 diagnostic. Fresh complete-source type checking separately passed
in 55.8 seconds with V8 profiling. The profile's flat table places String.cmp
first (15.7% of all ticks) plus String.cmp.rec (1.9%). Full profile processing hit
its separate 512 MiB heap limit after printing the flat table; retain that failed
analysis attempt and obtain a completed bounded analysis before claiming a full
profile result.

The checked B1 image has a guarded equality transformation. The direct backend
instead emits Base String.eq through String.order and recursive String.cmp.
Replacing this repeated traversal is a general library operation improvement,
not recognition of the compiler or individual benchmark programs.

Add String.eq to the existing native-definition table with two live arguments
and a Boolean strict-equality result. Retain the existing exact Def/native,
non-Foreign, non-template and telescope admission. Ordinary user definitions
with the same spelling remain ordinary code. Native String values are primitive
JavaScript strings; test empty, Unicode, combining sequences, NUL and malformed
UTF-16 without normalization. Boxed objects and arbitrary non-string host values
are outside that representation contract. The existing Phase52 scope excludes
arbitrary post-import builtin-hook identity; source callback behavior is retained.

Crucially, optimize only the emitted function body. Keep String.eq excluded from
call-site intrinsic expansion, so its arguments retain their ordinary pending
evaluation and partial-application behavior. A table-only change would introduce
new eager argument holds: inside `(String.eq(f(x), ""), U32.add(g(x), 0))` that can
reverse the observable f/g callback ordering. The definition-only change avoids
this counterexample without a special ordering rule or new runtime machinery.

Validate the canonical native body and same-named nonnative fallback, source
checking, packed callbacks, thrown errors, partial demand, Unicode values and
existing semantic suites. Build a checked candidate before emitting its full
direct image. Then rerun fresh self-checking and require exact B2/B3 reproduction
on the candidate source. Compare benchmark module bytes; run controlled timings
for changed workloads before promotion. Keep baseline timeouts, rejected
table-only reasoning and resource failures visible. No deadline or graph-cap
increase may substitute for a semantic fix.
