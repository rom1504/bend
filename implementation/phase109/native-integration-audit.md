# Native frontend integration feasibility

Source-only inspection finds a smaller integration than Phase107's scalar route:
reuse `p86_plan` unchanged, including its final `nr_prepare_annotated`, and select
`NativeErasedBody` from `NR_Request.book` using `ns_body`. No thirteen-function plan
clone or checked-to-scalar lowering is needed. Nxo already accepts this exact
Bend-produced fact shape, as transported in the hosted capture experiment.

Implemented preparation tools are
[`native/prepare.py`](../../selfhost/tools/performance/phase109/native/prepare.py)
and [`native/main.bend`](../../selfhost/tools/performance/phase109/native/main.bend).
They append about 81.5 KB of shared modules and entry source to the authenticated
1,788,947-byte mature compiler source, plus roughly 4 KB of paths/frozen source
contracts. A source-only collision scan finds no new declaration overlapping the
selected compiler. Preparation checks the old-main replacement is exactly invertible.
It does not execute the compiler or modify production.

The entry runs the mature cached/live Base preparation and source checking, then:

```text
p86_plan → NR_Request.book → ns_body(entry)
         → nxo_lower_policy → ownership verification
         → NxLibrary verification → QBE text or Nx JSON
```

Both library functions are generated from actual selected erased facts; the entry
never implements their algorithms. Raw/trusted/fused policies use the same current
modules as the hosted experiment. The two accepted whole-source fixtures are
embedded and compared exactly before source checking; Base/cache remain pinned
external assets. This narrow source contract is intentional: polymorphic
`nt_reverse` erasure removes its element type, so its erased body alone does not
justify treating arbitrary user inputs as this fixed List<String>/String ABI.
Future general admission must preserve/check that information, not rely on names.

## Acquisition cost and integration gate

The previous Phase107 native image used 1,895,210 bytes of Bend source, generated
21,569,513 bytes of C and produced a 14,811,928-byte Clang image. Its retained guards
record 110.84 s for source emission (820,305,920-byte peak process-tree RSS) and
264.53 s for Clang construction (1,749,708,800-byte peak). These are historical
observations, not measurements of the new source.

The new entry should have similar source size and an estimated 20–25 MB generated
C output. Reusing the trusted native B2 for emission into Phase108 v3 runtime,
then its exact four-macro metadata bridge and cproc/QBE construction, avoids that
Clang construction dependency. Based on Phase108, allow approximately 30–60 s
for machine construction plus around two minutes of emission; these are estimates.
Allow 60–100 MB additional persistent disk and the established 4 GiB build cap /
16 GiB available-memory floor. Serialize target work on CPU3. The acquisition
commands are materialized in the preparation manifest; no execution is performed
by the source-preparation tool.

First qualification should compare raw/trusted/fused native QBE output with the
hosted output for the same two frozen source contracts, then execute the existing
ownership and derived Keep/Sink controls using that output. Also test a changed
source byte, invalid policy and cached/live Base agreement. A native-source result
establishes a real Bend-hosted path for this subset; it does not establish direct-IR
coverage of the whole compiler or change current B1/B2 production metrics.
