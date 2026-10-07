# Primitive selection implementation

Isolated candidate: [primitive-select01.bend](../../selfhost/tools/performance/phase61/primitive/primitive-select01.bend).
Patch: [primitive-select01.patch](../../selfhost/tools/performance/phase61/primitive/primitive-select01.patch).
Baseline/source identities: [source01.json](../../selfhost/tools/performance/phase61/primitive/source01.json).
Design and admission contract: [design](../../design/phase61/primitive-selection.md).

Root authorized application after independent static review. The exact reviewed
candidate is now in the maintained primitive module; [application receipt](../../selfhost/tools/performance/phase61/primitive/application01.json) pins the before/after bytes. The candidate replaces exactly
two `find(name,table())` calls with compiler-owned lazy selection and adds nine
bounded helpers; all 90 canonical rows and existing admission bodies remain intact.
`controls01.mjs` passed Node syntax checking and independent static review: 100
selection rows and 630 admission variants. No checked build, diagnostic,
compiler measurement or promotion is claimed. Root can apply the isolated patch
sequentially, preserving other agents' source edits.

```sh
node selfhost/tools/performance/phase61/primitive/controls02.mjs \
  selfhost/build/phase58/checked-last01 \
  selfhost/build/phase61/checked-primitive01 \
  selfhost/build/phase61/primitive-controls02
```

Run through the existing external process-tree guard on root's scheduled CPU.
This probe imports two API images and traverses bounded metadata; use the usual
1 GiB heap/2 GiB tree RSS limit and a 60-second deadline initially. Actual duration
is unknown. Broader selected conformance and exact full emission remain independent
checks. Private derivatives carry diagnostic ancestry and do not gain checked receipts.

The first executed diagnostic was refused before its semantic probes because the
candidate's real reachability removed unused table/find helpers. Its consumed
controller and [failure](../../selfhost/build/phase61/primitive-controls01/report.json)
are preserved. `controls02.mjs` keeps the actual baseline table as the independent
oracle, requires the actual candidate selector and explicitly checks that table,
find and find-row are absent in that image. The candidate derivative contains no
fabricated or dead helper. All selection/admission/emission obligations remain.
[Successor derivation](../../selfhost/tools/performance/phase61/primitive/controls02-derivation.json)
records this harness correction; [Successor execution](../../selfhost/build/phase61/primitive-controls02/report.json)
completed PASS: 100 selection rows and 630 admission variants. This establishes
focused differential helper correctness, not a latency or broad promotion claim.
