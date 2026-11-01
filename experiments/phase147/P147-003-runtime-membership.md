# P147-003: answer the Boolean question directly

Status: integrated and ordinary serial native-qualified; isolated gain transfers
modestly to the registry stage, with inconclusive additional whole-build effect.
[Final report](../../implementation/phase147/README.md).

The fresh native profile leaves registry preparation at about 16.8 seconds.
Its transport admission predicate calls `p111v_signature`, constructs a list of
argument types, and asks whether that list is nonempty. It additionally performs
seven eager full-name comparisons. The caller needs only an exact Boolean result.

Replace this observation with constructor pattern matching over the same 25
closed runtime names, sharing the common `p111_rt_` and `p118_rt_` prefixes. Keep
the public signature-producing verifier unchanged. No hash-only acceptance,
prefix-only acceptance, new runtime operation or speculative cache is involved.

Independent source inspection decoded every accepting path and established the
same finite accepted-name set. All 677 positive, prefix, mutation, suffix, case
and Unicode controls pass through the checked hosted API and native executable.
Native tests compare the entire Boolean result string before and after timing,
including separate startup and salted-negative controls.

On 1,375 actual call-symbol occurrences from the retained current function
captures, four native ABBA blocks measure a new/old ratio of 0.0921. This is about
10.85 times faster for the predicate workload, not for the compiler. Acquisition
and timing costs are recorded separately. The larger full-QBE static call census
does not represent dynamic execution frequencies.

Using ordinary string literals for complete patterns reduces the prototype from
4,355 to 1,346 source bytes. The maintained native compiler emits exactly the same
1,188,233-byte QBE product for the explicit-constructor and literal versions. The
two prefix patterns retain their explicit tail bindings. Canonical integration
changes one existing definition and adds two helpers; final whole-build timing
and qualification decide adoption. The final registry stage falls16.834→15.944s;
clean full build246.745→246.173s is an inconclusive0.23% additional difference.
Native qualification passes. The small predicate is retained, without claiming
the microbenchmark's10.85× as a whole-compiler speedup.

Rejected before implementation: stop transport admission after its first
failure. The frozen full compiler's descriptor capability value is 5, proving
that this complete program passes transport admission. Its conjunctions never
accumulate False, so early refusal cannot shorten this successful cold build.
Likewise, caching full encoded function names has only two uses per symbol and
would retain megabytes of extra strings; no cache was implemented.

Evidence: `runtime-classifier-plan05`, `runtime-classifier-pairs02`,
`runtime-classifier-plan06` and `runtime-classifier-literal-emit01` under
`selfhost/build/phase147`. The first executed API attempt failed because its
helpers followed the entry in declaration order; that failure is preserved.
