# Selected B2 work counters

Diagnostic only. The producer parses the exact published last01 B2 and inserts
fixed-array counters; it never imports a compiler. Runtime prefix and original
bytes are preserved with exact inversion. The derived image has no checked
sidecar. Root executes the worker commands serially under the existing CPU3,
1 GiB Node heap, 2 GiB tree-RSS and 4 GiB available-memory guard. Use 120 seconds
for preparation and 120 seconds per first-request diagnostic; retain failures.

Materialization already passed without importing a target:

```
taskset -c 0 /home/ai/.nvm/versions/node/v24.18.0/bin/node \
  selfhost/tools/performance/phase59/counters/derive-v1.mjs \
  selfhost/build/phase59/counter-image01
```

The image is `9f57bc4191d02615e48ef31f8312a061dead44f63383a98646dbd41f17fdc8b3`;
its derivation receipt is
`2227f48453eddbf2bcd711ed33641415098a3f67ff6927ae870054339b59d890`.
There are 76 metrics at 50 insertion sites. The primitive table contains 90
records/90 links and one Nil literal per execution, not a physical heap count.

The root launch uses the small serial runner, which owns those limits, all three
process receipts and a 300-second total deadline. Do not add an outer guard:

```
python3 -B selfhost/tools/performance/phase59/counters/run-v1.py \
  selfhost/build/phase59/counter-requests01
```

The equivalent worker commands below explain the protocol. Each needs its own
guard if launched manually; the worker itself does not create a supervisor.
The runner uses `counter-requests01/{preparation,lexer,evening}` instead of the
manual destinations shown here. Do not run both routes or overlap clean timing.

```
/home/ai/.nvm/versions/node/v24.18.0/bin/node --max-old-space-size=1024 --stack-size=4096 \
  selfhost/tools/performance/phase59/counters/worker-v1.mjs prepare \
  selfhost/build/phase59/preparation01/prepare-direct.result.json \
  selfhost/build/phase59/counter-image01/derivation.json \
  selfhost/build/phase59/counter-preparation01

/home/ai/.nvm/versions/node/v24.18.0/bin/node --max-old-space-size=1024 --stack-size=4096 \
  selfhost/tools/performance/phase59/counters/worker-v1.mjs sample \
  selfhost/build/phase59/counter-preparation01/report.json lexer \
  selfhost/build/phase59/counter-lexer01

/home/ai/.nvm/versions/node/v24.18.0/bin/node --max-old-space-size=1024 --stack-size=4096 \
  selfhost/tools/performance/phase59/counters/worker-v1.mjs sample \
  selfhost/build/phase59/counter-preparation01/report.json test-evening-program \
  selfhost/build/phase59/counter-evening01
```

Preparation admits the genuine parent and derivative, copies the unchanged
driver/runtime through the reviewed Phase59 setup, and primes a fresh Base cache
keyed by the diagnostic API bytes. It compiles no workload. Each fresh sample
loads that private driver/API, verifies counters stayed disabled/zero during
import, resets them immediately before one ordinary library request, and requires
the complete module bytes from the already-qualified genuine preparation.
No generated benchmark is imported or run by this diagnostic worker.

Reports expose whole-request totals. Optional stage exports exist but this worker
does not partition the request or modify the copied driver. Semantic SCC cases
and self-loop iterations count internal transfers; named `String.contains`
entries separately count searches. String input sizes are UTF-16 units, while
source loop visits need not be bytes or Unicode scalar counts. Sample errors
retain partial counters and cannot pass qualification. Counts describe executed
source operations, not physical allocations or uninstrumented speed.
