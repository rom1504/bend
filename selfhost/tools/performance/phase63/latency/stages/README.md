# Current-image exclusive stage diagnostics

This is a separate diagnostic successor of the controlled latency method. It
uses each successful preparation's actual driver/API/cache and inserts clocks
into a new adjacent `typed-driver-stages.mjs`; original files remain unchanged.
Removing every recorded insertion restores the original driver bytes exactly.

The imported API's entry functions get synchronous before/after observers in
that fresh diagnostic worker only. They retain arguments, return values and
function name/arity; no custom API argument is supplied to `inspect`. This is
essential: supplying an API override would disable the owned prepared-world
and frontend-prefix permissions we want to observe. Calls to ready-prefix,
world-checking and JDPlan exports are therefore measured directly. The existing
ABI adapter's phase callback separately observes encoding/invocation/decoding
when that adapter is actually used. Named-layout images may have no such work.

Host clocks cover cache read, frame header, graph/tree decoding, validation and
optional-state admission, plus source-graph and request residuals. Nested
exclusive intervals reconcile to the complete window. Never sum inclusive
parents and children; instrumentation overhead makes all these times diagnostic.
Pinned TS retains its separate load/check/emission boundaries.

After genuine-B2 preparation succeeds, root or a data-only agent can materialize:

```sh
taskset -c 0 python3 -B selfhost/tools/performance/phase63/latency/stages/make-method.py \
  selfhost/build/phase63/latency-method02 \
  selfhost/build/phase63/state05-stage-method01 \
  --preparations selfhost/build/phase63/state05-b2-latency/preparation/report.json
```

Those destinations now exist. Root alone runs targets; the runner owns its guard:

```sh
python3 selfhost/build/phase63/state05-stage-method01/run.py \
  selfhost/build/phase63/state05-stages01 \
  --bindings selfhost/build/phase63/state05-b2-latency/bindings.json \
  --preparations selfhost/build/phase63/state05-b2-latency/preparation/report.json \
  --roles baseline,candidate,typescript \
  --cases numeric-recurrence,test-map-set-ops \
  --rounds 1 --warm-requests 0 --mode stages --seconds 35
```

Full raw-byte oracles, snapshot identities, cache identities, CPU3, heap/RSS
limits and available-memory floor remain unchanged. This intentionally small
six-worker pass should be comparable in campaign cost to the clean two-source
screen; the explicit deadline is a guard, not a runtime guarantee.

`summarize.py REPORT --out NEW_JSON` is data-only. It reports actual path counts,
ABI phases, complete exclusive stage partitions and input/output identities.
Keep stage results separate from clean compiler-speed claims and generated-user-
program execution measurements. Use fresh preparations for a later driver
derivation; do not overwrite consumed diagnostic copies or methods.
