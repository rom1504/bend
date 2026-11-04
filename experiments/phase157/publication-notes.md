# Phase157 prepared publication fallback

This source-only fallback was prepared when bendc initially refused multiline
lambda calls in the larger captured lowering workload. Root subsequently obtained
successful emission for that workload after whitespace normalization. Do not
expand this fallback unless the main comparison is independently blocked.

No source checker, compiler, generated program, benchmark or new input/oracle
materialization was run for this fallback. It is not a qualified comparison lane.

## Source and runtime contract

`selfhost/tests/phase157/publication.bend`:

- 103,064 bytes; SHA256
  `e8f050774a2187d8d2cca0f9eb25f09a6d88c3b02044b513b1e1db71d495eee4`.
- 345 declaration blocks, including nine new IO/argument/loop functions.
- Exact declaration closure from qualified source SHA256
  `027e15041035522ed7e40ef971eff75f24a09ef6a00e3f8fe335839f94bcb8a8`,
  `selfhost/tests/phase155/publication.bend`,
  `selfhost/tests/phase155/publication-transfer.bend`, and
  `selfhost/tests/phase154/input.bend`, plus the new transport.

Logical `IO.args` arguments:

```
publication-work ABS_INPUT oracle 1 4294967295
publication-work ABS_INPUT oracle 1 32
publication-work ABS_INPUT oracle 1 0
publication-work ABS_INPUT bench N 4294967295
```

Every iteration selects **only the original** `p155pt_05_raw_old`, never the
provenance or constructor-cache candidate. Common unchanged helper declarations
may contain their historical alternate branches, but original entry constants
always select the old route. It builds the complete declaration seed and suffix
schedule, processes actual source-order events with original guards, performs
final canonicalization, and observes all fields of the result through
`p155pt_text`. The limit is a prefix limit; it never truncates the input book
before seed/schedule preparation. The three admitted limits match the old gates.

`oracle` writes the full serialization to `/dev/stdout`; `bench` writes the same
complete freshly computed serialization to `/dev/null`, then repeats. Input
decoding occurs once per process. Zero repetitions retain setup/cleanup and
should be reported separately. Repetitions are runtime arguments, bounded by
65,536. Errors or failed admission produce nonzero exit, not fast successful
results. Every result is consumed by an error-checked `File.write` before the next
iteration. Runtime prefixes may differ per backend, but Bend source, Base and
logical input arguments must match.

## Existing independent complete evidence

The old successful transfer receipt compared every raw result field for original
and both historical candidates at prefixes 0, 32 and all. Its workloads contain
603 real compiler-verifier events and 504 real Map events, including loaded Base.
These are publication replays, **not dependent checking** or ordinary prepared
Base requests; the event counts do not prove the production logging threshold.

The original transfer files were safely pruned in Phase156. They remain in:

```
selfhost/build-retention/phase155/publication-transfer-prepare02--transfer-guard/root-00/files.tar.gz
3742108 bytes
SHA256 0baa2eec1692b9f5f963b7894cefeb3427a4ab00535b1d9a54ba201a8e2c9fdf
```

`receipt.json` beside that archive pins all nine member files. The tracked
`implementation/phase155/evidence/phase155.tar.gz` also contains the original
paths. Read/archive verification suffices for inspection; do not overwrite frozen
run paths when materializing a future fallback.

Important member identities:

| Member | Bytes | SHA256 |
| --- | ---: | --- |
| `report.json` | 9599 | `65b826e6209037bb84061407ce94bae0420680902aa765e7ad9eddfdfe898f7c` |
| `compiler-verifier-slice-input.graph.json` | 8065770 | `37811dd498c34c07bbda8a7034b44a1045cfa625d3992ec14dee45f36eb89743` |
| `compiler-verifier-slice-4294967295-result.graph.json` | 8226359 | `a6ea68184f0e53c5440188b2e9697e375a0600a36b00eab906df84b15726c3cf` |
| `coverage-map-churn-128-input.graph.json` | 6274273 | `52216f0b0628f62bb22c17c248434af56dba2a75e6f571da8882ff1c3ba36ab2` |
| `coverage-map-churn-128-4294967295-result.graph.json` | 6410999 | `cd6fce8b3332c3a5db65df2692e16b8e8d193ed4fadc8923d3b85c68944f9d5a` |

The archive also retains complete expected result graphs for prefixes 0 and 32.
They are semantic oracles, not checksum-only expected answers.

## Materialization recipe if needed later

1. Verify the archive and selected member identities. Decode its generic object
   graphs with the exact `experiments/phase154/tools/graph.mjs` transport.
2. Select the original input trace's `result.book`. Serialize **that entire
   source-order event list** with the lossless P88 codec from
   `experiments/phase154/tools/book-fixture.mjs`: postorder identity references,
   complete KDef/KTerm/cache fields, original string contents and metadata.
   Check exact host round-trip first. The Phase154 erased-request book is a
   different input and must not be substituted.
3. Save transport bytes under a fresh Phase157 run root and pin them. Existing
   `p154r_read` is the unchanged Bend decoder in this fallback. Independently
   check decoded structural equality against the whole captured event graph.
4. Serialize the existing **reference result graph** with exactly the public
   `p155pt_text`/`p155p_defs` all-field grammar, without running publication again.
   The result includes full book/index, full seen history, exact error, processed
   count and admission. This can be host-only structural serialization or a
   separately checked original serializer. Preserve every field; compare complete
   output bytes. Pin the resulting expected text before any backend measurement.
5. Independently check/build the same source and Base for all backends. Require
   zero exit, empty stderr and complete expected output at all three prefixes
   before timing. Then use one common bounded repetition count and fresh child
   processes, with setup/control costs visible.

The input transport and final expected-text files have **not** been created here;
their sizes/hashes and decoded-book gates remain pending. No timing, new proof,
general conformance, full compiler speed or backend support is claimed.
