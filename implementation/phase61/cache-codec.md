# Codec-only binary cache discriminator — rejected

Decision: retain frame2 JSON transport. Root's codec-only job completed/pass in
4.222s; no production format, migration, compiler source change or release follows.
The [raw report](../../selfhost/build/phase61/binary-codec01/report.json) binds the
actual state06 prepared cache and frozen [controller](../../selfhost/tools/performance/phase61/cache/binary-codec01.mjs).

|Decode plus required validation|Median,5 samples|Payload bytes|
|---|---:|---:|
|Actual frame2 decoder/validation|99.840ms|5,667,458|
|V8 deserialize/generic validation|225.676ms|4,939,044|

Binary was2.26039× slower, a125.837ms median penalty despite fewer bytes. Its
serialization preparation cost48.702ms is outside those windows. All10 timed
results passed full value/metadata equality checks outside the clock. Inputs and
cache bytes were rehashed at completion; the actual cache SHA is31e2e80c… and
controller SHA5f7bcf51…; full identities are retained in the report.

This is one process, resident bytes, five alternating-order rounds on Node24.18.0
(V8 13.6.233.17-node.50). Import, construction/serialization and oracle decodes
occurred before sampling, so these are warm codec samples, not cold request or
filesystem timings. Root supplied its external resource guard; author ran static
parsing only. The job imported no compiler API and made no Bend compiler requests.

Both paths keep the exact current host metadata/state predicates. Binary uses the
generic cycle-safe span walk and existing canonical-state digest fallback, without
claiming the private JSON-tree privilege. This conservative validation policy is
intentional: binary can express aliases/cycles unlike freshly parsed JSON. The
observed totals do not isolate deserialization, generic traversal, digest or GC
costs; they reject migration under this measured policy, not every possible binary
protocol. A new protocol needs strong new evidence before another iteration.

Reproduction (root-owned guarded execution, fresh Phase61 output):

```sh
node --stack-size=4096 --max-old-space-size=1024 \
  selfhost/tools/performance/phase61/cache/binary-codec01.mjs \
  selfhost/build/phase61/state06-b2-latency01/preparation/prepare-candidate.result.json \
  NEW_PHASE61_OUT
```

The producer copies exact image host helpers and appends only exports of lexical
existing validators. It creates no checked receipt or new format admission.
Historical state06 inputs, the binary payload and all five samples are preserved.
