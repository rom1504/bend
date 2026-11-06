# Predeclared repair of insufficient timing resolution

`quality-broad-timing01` completes all45 cases and360 correct outputs/counts.
Its overall runtime aggregate correctly refuses to report a number: four timed
points have intervals below the maintained100ms minimum. Do not discard them.

The unresolved cases and their minimum observed intervals are:

- `coverage-closures-64`:4ms.
- `coverage-closures-256`:4ms.
- `coverage-list-pipeline-128`:30ms.
- `coverage-list-pipeline-512`:30ms.

Before the follow-up, select exactly these four cases, the same frozen manifest,
both actual native images, four balanced rounds and the maintained `--scale40`.
Scale40 is160ms /4ms, chosen from minimum resolution rather than speedup. Both
variants receive the same40× repetition count; source, arguments, warmups,
oracle, runtime and machine policy remain fixed. Report normalized time per call.

Keep the original incomplete aggregate. A separate explicitly resolution-repaired
summary may replace only these four point summaries when every follow-up interval
passes100ms and every output/count is exact. Preserve every original result and
record both source receipts and the different repetition count. This is not a
fresh upstream comparison or an unchanged total fixed-batch execution clock.
