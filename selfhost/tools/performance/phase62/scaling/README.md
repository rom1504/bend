# Synthetic compiler scaling screen

These fixtures diagnose ordinary compilation costs. They are not representative
program benchmarks or optimization targets. Both roles perform an ordinary,
checked library compilation with all user exports retained. The worker executes
every generated fixture export against an independent numeric oracle **after**
all compilation timing windows. Different compilers may emit different bytes.

The two families are:

* 8 / 32 / 128 / 512 independent one-argument definitions. Each adds a different
  U32 constant to its argument. This changes declaration and export counts.
* 2 / 8 / 32 / 64 U32 parameters, with eight wide functions and eight calling
  probes at every size. Balanced addition expressions limit nesting as a
  confound. The probes force the compiler to check the full application spine.
  This is ordinary telescope width, not dependent-type normalization.

Root owns compiler execution. First reuse the successful Phase62 three-role
preparation. The controller acquires the shared execution guard, serializes
children on CPU3, and applies a 1 GiB heap / 2 GiB tree RSS guard with 4 GiB
available-memory floor. Use a fresh destination each time.

```sh
python3 selfhost/tools/performance/phase62/scaling/run.py \
  selfhost/build/phase62/scaling01 \
  --preparations selfhost/build/phase62/generations01/preparation/report.json \
  --roles b2,typescript --rounds 1 --seconds 90
```

The 16-worker screen should take tens of seconds; its actual elapsed receipt is
authoritative. It stops on the first failed worker, preserves that evidence, and
makes no successful-population claim on a partial run. `--cases definitions-8,width-2`
provides a four-worker pilot. `--prepare-only` creates sources and a plan without
executing targets. `--warm-requests 3` records three later requests separately;
these are potentially still warming, not guaranteed steady-state samples.

The clocks separate compiler import, ordinary API load and first compilation.
Prepared Base caches and source/image identities are verified outside timing.
This is not OS-cold compilation. Source size, exports and arithmetic grow along
with the named dimension; compare incremental costs rather than interpreting a
single total-time ratio as a complexity class. One round screens trends but
does not establish precise ratios or asymptotic behavior. Follow a suspicious
curve with repetition and operation counts before changing the compiler.
