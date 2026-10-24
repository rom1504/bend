# Isolated owner-reuse experiment: useful negative result

The checked Bend prototype caches an owner's actual `P111Code` before generic
lowering. It is isolated, not integrated or native-qualified. The key and grammar
received an independent source audit; all 29 finite controls pass, including stale
output detection and changes to contextual entry facts.

The decisive test edits the frozen lexer's `prng` shift from 13 to 12. The old
product exactly matches the independently qualified 577,297-byte QBE reference;
the edited cached product exactly matches independent fresh compilation. All 14
hits are cheap native U32 primitives. All 31 ordinary owners are refused. Warm
compilation took 6.144 s versus 4.318 s fresh in one ordered hosted observation;
these are diagnostic timings, not a calibrated native regression estimate.

**Do not promote this cache.** A hit count does not demonstrate useful work
avoidance. Reusing contextual computations would require stronger dependency
information, while exact global fresh counters also limit reuse after edits.
Measure the actual expensive stages before expanding the cache interface.

The [prototype documentation](../../../selfhost/tools/performance/phase134/reuse/README.md)
describes the grammar, keys, trust boundary, reproduction and retained negative
attempts. [archive.json](archive.json) identifies every copied receipt by its
original path and hash. The authoritative real-edit result is
[reuse-lexer05](phase134/reuse-lexer05/report.json); older `lexer04` omitted native
chunk-separator newlines in the harness and is retained as a rejected measurement.

The follow-up [stage-ceiling investigation](stage-ceilings.md) identifies the
more important boundary: generic lowering is only 4.5–10.7% of warmed hosted
backend time on these requests. Expensive private optimization/verification and
render preparation remain; all six diagnostic products match frozen native QBE.

That led to [within-request verification reuse](verification-reuse.md): unchanged
functions reuse their successful check under the same exact ordered signature
context. A balanced real-edit hosted comparison suggests a modest gain; the
actual integrated candidate passes 59 controls and three frozen output bridges.
An additional [range memo experiment](range-reuse.md) passed its correctness
controls but produced mixed complete-request timings and was omitted.

The later [cross-edit optimization-unit prototype](cross-edit-units.md) does
reuse expensive transformations before executing them. Two balanced lexer edits
show approximately 26.7% lower hosted backend time. Reversing Map's measurement
order removes its apparent improvement, so broad transfer is not established.
This prototype remains separate from the selected native candidate.

No source checker, admission rule, independent final verifier, production
selection or runtime ABI changed. The harness orchestrates checked Bend exports;
host JavaScript supplies byte transport, identity checks and timestamps only.
