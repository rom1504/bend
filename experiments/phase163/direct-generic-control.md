# Matched generic-construction control

Comparing the current production pipeline with direct mode3 changes two things:
generic/scheduler materialization and the set/order of optimization passes. The
added `selfhost/tests/phase163/direct-generic-control.bend` separates those by
constructing genuine generic IR while emitting the same selected direct policy.

## API

```text
p163g_executable(mode, request) -> P111Emission
p163g_raw(request) -> P163GRaw
p163g_finish(mode, request, raw) -> P111Emission
p163g_summary(raw) -> String
```

Modes0–3 have exactly the meanings in `direct-optimize.md`. The one-call entry
guarantees that raw work and finishing share the same checked request. The split
timing API has the same prerequisite; do not pair one request's raw result with
another request or accept arbitrary constructed raw data as authority.

## Matched work and additional work

The control performs the same source/binder admission, recomputed main closure,
fresh erased facts and constructor-catalogue expression as `p163d_plan`. Instead
of building only candidates, it calls the maintained `p144o_catalogued` raw
pipeline. That existing function shares one `p112s_prepare` result between:

- actual `p111_compile_defs` generic segment construction and `p140or_finish`
  metadata/show construction;
- the same `p113pl_candidates`, `p126sc_candidates` and `p113d_passes` used by the
  direct-first plan.

The control independently calls unchanged `p112s_verify` on the real generic
program and static image. It then discards those verified segments, privatizes
the actual admitted direct workers and performs the same `p163d_admitted`
closed verification with zero scheduler FIDs. The same `p163o_apply` policy and
`p163x_library` executable renderer follow. No fake original, empty replacement
body or scheduler identity is used to admit a worker.

This constructs raw candidates only once. It does not call the whole direct-only
pipeline a second time merely to discard the first result. Generic source
matching, segment metadata, show metadata, verification, retention and eventual
destruction are all charged to the control. That is a broader cost than only the
body of `p111_compile_defs` and must be described accordingly.

## Required validation and timing interpretation

For the same frozen request and mode, first require byte-identical emitted QBE
between `p163g_executable` and `p163o_executable_mode`. Also retain the complete
result and native correctness gates. `p163g_summary` reports actual generic
segment, direct worker, raw candidate, constructor and static-word counts, but
is diagnostic metadata and not a verification certificate.

Compare matched complete invocations using balanced serial repetitions. The
difference, conditional on exact output equality, estimates the overhead of the
extra generic construction/metadata/verification/retention path at the same
optimizer policy. Do not transfer a single hosted result to native compiler
speed or whole self-compilation.

The split APIs permit separate measurement of raw construction and finishing.
Raw construction includes shared reachability, static preparation and direct
candidate construction; it is **not a generic-only timing**. Finishing includes
generic verification, closed verification, selected optimizations, final
verification and rendering. Report both intervals and their sum, with raw-state
retention/destruction honestly accounted for. A separate timed summary traversal
must stay outside them.

Only source delimiter/declaration checks were run in the preparation lane. Root
owns independent source acquisition, output equality and runtime measurements.
