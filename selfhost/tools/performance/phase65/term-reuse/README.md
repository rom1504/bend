# Unchanged composite-term diagnostic

Status: source prepared; root has not yet executed this controller. It writes
only to a new Phase65 raw directory. No production source is changed.

Root runs under the normal single CPU3 process-tree guard, Node24.18.0,
1GiB heap, 2GiB RSS and 4GiB available-memory floor:

```sh
node --stack-size=4096 --max-old-space-size=1024 \
  selfhost/tools/performance/phase65/term-reuse/run.mjs \
  selfhost/build/phase65/baseline-state09/preparation/report.json \
  selfhost/build/phase65/term-reuse01 \
  numeric-recurrence test-map-set-ops lexer raytrace-active
```

The diagnostic accepts only selected Phase64 State09 genuine B2 `b09fe54a…`.
It pins the original prepared project, compiler source/emission lineage, API,
runtime, Base, Node, fixtures, output oracles and these four controller modules.
It inserts observations at actual generated SCC/tail-loop entries; removing the
insertions reconstructs the exact original image. Original compiler expressions
are unchanged. The derivative primes its own API-bound Base cache with observation
disabled. It preserves that owning API throughout later requests.

`controls.mjs` contains 28 small exact-result/input-immutability controls against
the same compiler's `subst` and `core_beta`. Each admitted synthetic result must
deep-equal its complete input, including metadata. Full real-source emitted bytes
then match the qualified preparation oracle. Counts group by actual exported API
demand; request-local caches reset between sources. No instrumented time is a
performance result, and counts are not V8 allocated bytes.

`observe.mjs` conservatively classifies no-op substitution: a mismatching Var is
stable without examining its payload; a matching Var is conservatively changed;
other children must be stable. An App additionally needs exact canonical metadata,
two children and a non-Lambda function. The beta predicate only follows the
function spine, matching `core_beta`'s existing argument demand. Neither is a
general normalization cache. Diagnostic weak identity caches do not authorize a
production host implementation.

Per source, observation is capped at five million predicate visits, 250,000
cached facts and recursion depth256. Unknown never grants reuse. A capped report
is a lower-bound census with explicit unknowns, not a complete estimate. Logical
entry counts still continue. No graph or terms are retained in the JSON report.

Read [the hypothesis and contracts](../../../../../implementation/phase65/term-reuse.md)
before interpreting stable-parent or child-cell counts. In particular, generated
constructor-match returns can reconstruct objects even when Bend source returns
the matched variable. A Bend candidate must preserve the original term outside
that reconstructing match boundary, and verify actual generated code.
