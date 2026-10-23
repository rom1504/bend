# Phase127: general profiling and native compiler cost

Work started 2026-10-23 09:44 UTC; the requested investigation runs through
12:44 UTC. This is an intermediate checkpoint while the controlled same-source
compiler experiment is running. Final measurements and qualification will be
added here. Parent: Phase126 `6fe4f29`; installed compiler selection is unchanged.

The [profiler guide](../../docs/self_hosted/PROFILING.md) documents the reusable
tool. The [design](../../design/phase127/general-native-profiler.md) and
[experiment](../../experiments/phase127/P127-001-general-profiler.md) define the
scope. This phase measures execution of native N1 while it compiles fixed Bend
inputs to QBE, including process startup, prepared-Base decoding, output and exit.
Machine assembly/linking, compiler acquisition and generated user-program speed
are distinct costs.

## First observations

Three-round clean fresh-process medians reproduce the Phase126 slowdown:

| Request | Phase125 N1 | Phase126 N1 | Ratio |
|---|---:|---:|---:|
| closures | 0.6102 s | 0.7212 s | 1.182× |
| lexer | 2.2509 s | 2.5084 s | 1.114× |
| map | 2.9802 s | 3.9448 s | 1.324× |

The geometric ratio is **1.2036×**, a fresh comparison on these three requests,
not a universal compiler slowdown or the historical broad program-runtime score.
All captures retain exact complete QBE stdout and empty stderr expectations.

The profiler exposed a specific information loss. Phase126's generated compiler
has capability value1; Phase125 has5. A verified divmod helper was omitted from
the separate live-register-bank admission list. One cold formatting helper can
therefore disable that transport optimization for the entire generated image.
See the [source/runtime audit](live-bank-audit.md).

Dynamic counters show zero register-tail clearing in the parent, versus requested
clearing of **4.916GB** per lexer request, **1.894GB** per closure request and
**7.638GB** per Map request in Phase126. These are requested bytes, not measured
memory-bus traffic. Counters run separately and their timings are diagnostic.

Authenticated physical callers independently locate Phase126's libc fill samples
in jump/return handling. Across24 captures all612 eligible libc samples recovered
one valid caller, with zero reported loss. The [caller report](physical-caller-audit.md)
keeps exact sample counts, interval weighting and attribution limitations.

## Causal experiment in progress

An experimental checked Bend overlay adds the missing helper to the audited
admission list; it does not force descriptor flags or weaken the final verifier.
Its49 predicates pass. Tree and Map QBE differ from Phase126 in exactly one
capability field; every other byte matches. RLE remains unchanged because it has
a separate existing admission blocker. That negative result is preserved.

One controlled full emission is compiling unchanged Phase126 source32 with the
repaired producer. It tests whether restoring the transport certificate recovers
native compiler throughput. It is not full N1/N2 qualification or a production
promotion. See [P127-002](../../experiments/phase127/P127-002-live-bank-admission.md).

## Capability and limits

The reusable tools provide clean wall/CPU/RSS, loss-aware ELF leaf samples,
selected physical callers, linked-FID validation, conditional lowered-definition
owners, active dispatch contexts and16 runtime event counters. Multiple periods
and compatible capture pooling improve diagnosis of short requests. Clean and
instrumented timings remain separate; missing lifetime coverage suppresses
absolute CPU estimates. Unknown attribution remains in the denominator.

The implementation is sequential Linux x86-64 research tooling. It does not
reconstruct logical recursive stacks, measure all worker threads or infer source
allocation origins. Independent test and ordinary-program qualification results
will accompany the final report.
