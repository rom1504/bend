# Phase154 evidence and reproduction

`phase154.tar.gz`: 13,393,396 bytes, SHA256
`28bb08fbaa9fc6338920b95d8a965cb79aa9df9fdea0ab97c4915a84cb1a68d9`.
`capsule.json` records 250 exact payloads and 146 identical aliases. Every stored
member was decompressed and verified for size, SHA256 and mode. No artifact was
pruned. All 15 executed guards have sealed retention receipts.

The capsule contains the actual captured object graphs, complete book fixtures,
literal controls, checked source/API products, old/new native executable, its
QBE/assembly/object, expected and observed complete outputs, all raw timings,
physical samples, sampler, source/method snapshots, plans and process/closure
receipts. It also preserves the failed capture/check attempts and the two
superseded verifier-context controls. Offline-only plans are not executed jobs.

Restore into isolated empty scratch and verify against the manifest. Recreate
each alias from its pinned payload with the recorded mode. Do not extract over
the frozen run roots. Replaying requires the qualified Phase152 N2, current
source/Base/runtime/toolchain dependencies pinned by the corresponding manifests;
they remain external. This is exact experiment evidence, not a standalone
toolchain distribution. Absolute paths must be intentionally relocated with
the same input identities; do not silently disable preflight authentication.

The successful sequence is:

1. `capture-plan05`: use the exact current checked API to capture the compiler
   verifier slice and ordinary Map request before direct lowering. Historical
   acquisition-method/source-manifest bytes are explicitly restored, not waived.
2. `api-plan01`: check/extract the old and private numeric producer/consumer.
   `controls03` is the final 45-row finite gate using authentic ordered header
   prefixes. Controls01/02 do not substitute for this result.
3. `book-fixtures01`: exact whole-book serialization and independent host
   sharing/value roundtrip. `check-input01` validates the actual checked Bend
   decoder against all fields of both captures. No compiler semantics run in
   the host serializer.
4. `native-plan03`: check and build the 490,835-byte combined harness with
   qualified Phase152 N2. One image selects old/new and family at runtime.
   Earlier native plans retain the two ordinary source-check failures.
5. `time-compiler01`, then `time-map01`: same-image alternating four pairs,
   calibrated repetitions, complete oracle checks before and after. No
   fixed-cost subtraction, modified verifier or cached candidate bodies.
6. `profile-plan01`: reuse the native executable and existing sampler. One
   capture per role, 33 repetitions, 16ms sampling, independently gated quality.
   Profiled clocks are not substituted for clean timing.

Every executed `*-guard/process.json` supplies the exact command/resource limits.
Preparation plans and method snapshots pin the inputs consumed at that time.
`experiments/phase154/summarize.py` regenerates committed metrics and cost
accounting; `package.py` builds and verifies this capsule without pruning.

The native image hash is
`fdd0ce72723d9c90a00412d01e8b77ef6d2809b7bef6ca6035d8ed67cf80e09b`;
its combined source hash is
`ca87075d64987029c27ac7df9b999d5eda356bb651d45b66445254af731a1340`.
Its receipt is `native-plan03/native/report.json`. The external compiler's
image binding comes from `selfhost/build/phase152/native-n2/report.json`.

An independent read-only agent reviewed the final harness, contexts and decoder
provenance. It found no apparent timing shortcut and agreed that the legacy
producer/nine-helper scope prevents whole-build extrapolation. In particular,
`performanceQualified=true` in a timing receipt means adequate duration only;
the near-2× optimization decision gate **failed**.

Local retention is at `selfhost/build-retention/phase154/`. Those verified
archives are recoverability on the same filesystem, not a separate backup.
