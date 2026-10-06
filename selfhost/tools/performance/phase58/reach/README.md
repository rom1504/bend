This is a private checked-B1 derivative diagnostic for the preserved choice01
reachability failure. It changes no scanner, fuel cap, worklist or returned
compiler result, and emits no compiler image. The derivative is explicitly
unchecked; the genuine generator attempt remains separately verified.

Run under the root process guard (CPU 3, 1 GiB Node heap, bounded 120 seconds):

```sh
node --stack-size=4096 --max-old-space-size=1024 \
  selfhost/tools/performance/phase58/reach/reach-diagnostic01.mjs \
  selfhost/build/phase58/final-choice02/bootstrap/full77.json \
  selfhost/build/phase58/checked-choice01 \
  selfhost/build/phase58/reach-duplicates01
```

The producer pins its original frozen emission producer and retains source
inheritance, private driver selection and every frontend stage up to reach.
It omits final-emission qualification because it stops at the existing
`direct reachability edge budget` error. Diagnostic completion requires that
exact error. The same result is not a checked-emission success.

Entry-only counters preserve compiler trampolines. A definition entry records
its name until its single follow callback; no other reach definition enters
between these points. Each successful follow counts its already-computed
Some list, including all repeated references, and records unique targets.
The JS seen set mirrors successful follow insertions. Visit counts nonempty
worklist entries, already-seen entries while fuel remains, and fuel-zero
entries. No extra compiler query or forced helper call is introduced.

Diagnostic allocation and timing differ from the ordinary pipeline. The
occurrence/unique difference is a worklist duplication census, not a measured
speed gain. Only visited rendered definitions are represented; unvisited
functions and a different emitter context may have different edges.
